/**
 *	@file Model_ObjMgr.cpp
 *
 *	@class Model_ObjMgr
 *
 *	@brief common code for managing models and services
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#define ISE_BUILD_DLL

#include "Model_ObjMgr.h"
#include "Options.h"
#include "DebugFlag.h"

#include <boost/algorithm/string.hpp>

#include "ace/config.h"
#include "ace/Log_Msg.h"

#include <string>

// TODO ERROR I cannot include this file on linux or it mucks with the ACE macros for library exporting ARRRRGGGGG
//#include <my_global.h>
#include <mysql.h>

#ifndef MAXHOSTNAMELEN
#	define MAXHOSTNAMELEN 1024
#endif

namespace Samson_Peer
{

// ===========================================================================
// Static initialization.
Model_ObjMgr *Model_ObjMgr::instance_ = 0;

// TODO make inline ?
// see the notes in the header
void Model_ObjMgr::doRunQuery (std::string& sql) { this->run_db_->doMultiQuery(const_cast<char*>(sql.c_str()), false); }

// ===========================================================================
/**
 * Return Singleton.
 *
 * @param  None
 * @return The address of the Option object
 */
Model_ObjMgr * Model_ObjMgr::instance(void)
{
	if (Model_ObjMgr::instance_ == 0)
		ACE_NEW_RETURN(Model_ObjMgr::instance_, Model_ObjMgr, 0);

	return Model_ObjMgr::instance_;
}

// ===========================================================================
/**
 * Default Contructor
 * the "initialize" function must be called to initialize the model
 *
 * @param none
 * @param none
 */
Model_ObjMgr::Model_ObjMgr() :
	Base_ObjMgr(),run_id_(0),runstats_id_(0),unit_id_(0),app_key_(),app_lib_(),run_UUID_(),run_master_(false)
{
	ACE_TRACE("Model_ObjMgr::Model_ObjMgr");
}

// ===========================================================================
/**
 * Destructor
 * Cleans up Database by removing the model ID
 *
 * @param none
 */
Model_ObjMgr::~Model_ObjMgr()
{
	if ( this->initialized_ ) // should have already happened
	{
		ACE_DEBUG((LM_ERROR, "(%P|%t) Model_ObjMgr::~Model_ObjMgr -> Object Manager not closed before destructor!\n"));
		this->close();
	}
	ACE_TRACE("Model_ObjMgr::~Model_ObjMgr");
}

// ===========================================================================
/**
 * close
 * Cleans up Database by resetting run status information
 *
 * @param none
 */
void Model_ObjMgr::close()
{
	ACE_TRACE("Model_ObjMgr::close");

	if ( !this->initialized_ ) return;

	MYSQL_RES *result = 0;
	char sql[1024];
	std::string update_sql[4];

	// Update the model counts, and status completed

	int nqry = 0;
	sprintf(sql, "UPDATE runs SET status = status-1 WHERE id=%d;", this->run_id_);
	update_sql[nqry++] = sql;
	sprintf(sql, "UPDATE run_models SET status = 2 where run_peer_id=%d;", this->peer_id_);
	update_sql[nqry++] = sql;

	for (int i=0;i<nqry;i++)
	{
		result = this->db_->doQuery(update_sql[i], false);
		if (result)
		{
			if (this->db_->affected_rows() == 0)
				ACE_DEBUG((LM_ERROR,"(%P|%t) Model_ObjMgr::close -> Update failure?\n(%s)\n\n", update_sql[i].c_str()));
			this->db_->freeQuery(result);
		}
#if 0
		else
			ACE_DEBUG((LM_ERROR,"(%P|%t) Model_ObjMgr::close -> No MySQL result set on (%s)\n", update_sql[i].c_str()));
#endif
	}

	// Transfer the runtime tables to the UUID (run) database
	// TODO  Don't hardcode "Delilah"

	sprintf(sql, "INSERT run_peers SELECT * FROM Delilah.run_peers where id=%d;", this->peer_id_);
	std::string move_peer(sql);
	this->doRunQuery(move_peer);

	sprintf(sql, "INSERT run_models SELECT * FROM Delilah.run_models where run_peer_id=%d;", this->peer_id_);
	std::string move_model(sql);
	this->doRunQuery(move_model);

	// Remove the peer/model pair from the database, along withthe subscription

	nqry = 0;
	sprintf(sql, "DELETE FROM run_peers WHERE id=%d;", this->peer_id_);
	update_sql[nqry++] = sql;
	sprintf(sql, "DELETE FROM run_models WHERE run_peer_id=%d;", this->peer_id_);
	update_sql[nqry++] = sql;
	sprintf(sql, "DELETE FROM run_subscribers WHERE run_peer_id=%d;", this->peer_id_);
	update_sql[nqry++] = sql;

	if ( this->run_master_ )
	{
		sprintf(sql, "DELETE FROM run_messages WHERE run_id=%d;", this->run_id_);
		update_sql[nqry++] = sql;
	}

	for (int i=0;i<nqry;i++)
	{
		result = this->db_->doQuery(update_sql[i], false);
		if (result)
		{
			if (this->db_->affected_rows() == 0)
				ACE_DEBUG((LM_ERROR,"(%P|%t) Model_ObjMgr::close -> Update failure?\n(%s)\n\n", update_sql[i].c_str()));
			this->db_->freeQuery(result);
		}
#if 0
		else
			ACE_DEBUG((LM_ERROR,"(%P|%t) Model_ObjMgr::close -> No MySQL result set on (%s)\n", update_sql[i].c_str()));
#endif
	}


	//  This will be used to trap a need to clean up. (just in case)
	this->initialized_ = false;

}

// ===========================================================================
/**
 * This function must be called to initialize the model
 *
 * TODO correct the return values, model ID for good and -1 for bad.
 *
 * @param appKey text key
 * @param appLib
 */
int Model_ObjMgr::initialize(const char *appKey, const char *appLib,
		unsigned int rid, unsigned int unitID)
{
	ACE_TRACE("Model_ObjMgr::initialize");

	// Bring up the database
	if ( Base_ObjMgr::initialize(false) == -1 ) return -1;

	if ( !this->verifyRunID (rid) )
	{
		ACE_DEBUG((LM_ERROR,"(%P|%t) Model_ObjMgr::PeerInitialize() -> Run ID %d was not found?\n",rid));
		return -1;
	}

	this->run_id_ = rid;

	// Unit ID (or Instance ID) comes in on the command line
	this->unit_id_ = unitID;

	// Create the Run UUID Tables
	if ( !this->uuid_initialize() )
	{
		ACE_DEBUG((LM_ERROR,"(%P|%t) Model_ObjMgr::PeerInitialize() -> UIID Failure?  rid=%d uid=%d (%s)\n",
				this->run_id_, this->unit_id_, this->run_UUID_.c_str()));
		return -1;
	}

	// At this time AppKey comes in on the comand line
	this->app_key_ = appKey;

	// At this time AppLib comes in on the comand line
	this->app_lib_ = appLib;

	// app_key_, app_lib_, node_id_, run_id_, pid_  have to be set prior to this call  (-1 will indicate failure)
	this->setPeerID();

	// Initialize the RunStats Record
	this->InitRunStats();

	// This function has now been called!
	this->initialized_ = true;

	return this->peer_id_;
}

//..................................................................................................
// internal
bool Model_ObjMgr::uuid_initialize(void)
{
	bool rtnval = false;

	this->run_UUID_ = this->getRunUUID(this->run_id_);
	if ( !this->run_UUID_.empty() )
	{
		run_db_ = boost::shared_ptr<DBMgr>(new DBMgr(false,true,"localhost",this->run_UUID_.c_str()));

		std::string create_peer_table("CREATE TABLE IF NOT EXISTS run_peers LIKE Delilah.run_peers;");
		// ACE_DEBUG((LM_DEBUG,"(%P|%t) Model_ObjMgr::uuid_initialize (%s)\n",create_peer_table.c_str()));
		this->doRunQuery(create_peer_table);

		std::string create_model_table("CREATE TABLE IF NOT EXISTS run_models LIKE Delilah.run_models;");
		this->doRunQuery(create_model_table);

		std::string create_stats_table("CREATE TABLE IF NOT EXISTS dispatcher_stats LIKE Delilah.dispatcher_stats;");
		this->doRunQuery(create_stats_table);

		rtnval = true;
	}
	else
		ACE_DEBUG((LM_ERROR,"(%P|%t) Model_ObjMgr::uuid_initialize -> ERROR!!! (%s)\n",this->run_UUID_.c_str()));

	return rtnval;
}

// ........................................................................................
/**
 * Get a list of the current peers for this run_id_
 *
 * @param PeerData this is allocated and returned to the caller
 * @return the number of items in array
 */
int Model_ObjMgr::getRunPeerList(SamsonPeerData *&PeerData)
{
	if ( !this->initialized_)
	{
		ACE_DEBUG((LM_ERROR,
				"(%P|%t) Model_ObjMgr::getRunPeerList -> NOT INITIALIZED\n"));
		return 0;
	}

	int nsub=0;
	char sql[1024];

	sprintf(
			sql,
			"SELECT run_peers.ID, run_peers.peer_key, run_peers.PID, run_peers.NodeID, nodes.FQDN "
			"FROM run_peers, run_models, nodes "
			"WHERE run_peers.id = run_models.peer_id and run_peers.node_id = nodes.id and run_models.run_id = %d",
			this->run_id_);

	MYSQL_RES *result = this->db_->doQuery(sql, false);
	if (result != NULL)
	{
		nsub = (int) mysql_num_rows(result);
		if (nsub > 0)
		{
			int i=0;
			MYSQL_ROW row;
			PeerData = new SamsonPeerData[nsub];
			while ((row = mysql_fetch_row(result)))
			{
				PeerData[i].id = atoi(row[0]);
				ACE_OS::strcpy(PeerData[i].appKey, row[1]);
				PeerData[i].pid = atoi(row[2]);
				PeerData[i].peer_id = atoi(row[3]);
				ACE_OS::strcpy(PeerData[i].peerName, row[4]);
				++i;
			}
		}
		this->db_->freeQuery(result);
	}
	else
		ACE_DEBUG((LM_ERROR,
				"(%P|%t) Model_ObjMgr::getRunPeerList error: (%s)\n", sql));

	return nsub;
}

//..................................................................................................
/**
 * This allows susbcription to a static applicaton mesage ID as found in
 * the AppMessage Table
 *
 * @param appMsgID - ID from the AppMessage Table
 * @param unitID - Model Instance ID, zero for ALL instances
 * @return ID from the Message Table
 */
int Model_ObjMgr::Subscribe(int appMsgID, int unitID)
{
	if ( !this->initialized_)
	{
		ACE_DEBUG((LM_ERROR,
				"(%P|%t) Model_ObjMgr::Subscribe -> NOT INITIALIZED\n"));
		return 0;
	}

	int msgID = -1;
	char sql[1024];

	if (DebugFlag::instance ()->enabled(DebugFlag::OBJ_DEBUG))
	{
		ACE_DEBUG((LM_DEBUG, "(%P|%t) Model_ObjMgr::Subscribe(%d,%d) Start\n",
				appMsgID, unitID ));
	}

	// If a negative unitID is passed in, then use ours as the default
	//  This is used to cheat, e.g.,  Missile1 to Target1
	if (unitID < 0)
		unitID = this->unit_id_;

	sprintf(sql, "SELECT ID from run_messages where run_id=%d and app_message_id=%d",
			this->run_id_, appMsgID);
	if ( (msgID = (int) this->db_->LookupInt(sql)) == 0)
	{
		// Subscribing to a nonexistant message  (rethink this)
		msgID = this->RegisterToPublish(appMsgID);
	}
	this->doSubscribe(msgID, unitID);

	if (DebugFlag::instance ()->enabled(DebugFlag::OBJ_DEBUG))
	{
		ACE_DEBUG((LM_DEBUG,
				"(%P|%t) Model_ObjMgr::Subscribe(%d,%d) - (%s)->%d\n",
				appMsgID, unitID, sql, msgID));
	}

	return msgID; // returns the Message_ID
}

//..................................................................................................
/**
 * This allows subscription to a "known" human readable identifier as found in
 * the AppMessage Table
 *
 * @param appMsgKey - Text Key from the AppMessage Table
 * @param unitID - Model Instance ID, zero for ALL instances
 * @param description - Description text string
 * @return ID from the Message Table
 */
int Model_ObjMgr::Subscribe(const char *appMsgKey, int unitID,
		const char *description="")
{
	int id = 0;

	if ( !this->initialized_)
	{
		ACE_DEBUG((LM_ERROR,
				"(%P|%t) Model_ObjMgr::Subscribe -> NOT INITIALIZED\n"));
		return 0;
	}

	int appMsgID = this->getUniqueAppID(appMsgKey, description);
	if ( appMsgID > 0 )
	{
		id = this->Subscribe(appMsgID, unitID);
	}

	if ( id == 0  || DebugFlag::instance ()->enabled(DebugFlag::OBJ_DEBUG))
	{
		ACE_DEBUG((LM_DEBUG, "(%P|%t) Model_ObjMgr::Subscribe (%s,%d,%s)\n",
				appMsgKey, unitID, description, id));
	}

	return id; // returns the Message_ID
}

//..................................................................................................
/**
 * This fills the Subscriber table with the
 *   run specific message number from which unit_id and
 *   our model_id  so we subscribe to that message
 *
 * This is a protected function!
 *
 * A unit_id of zero subscribes to all instances of this message id
 */
void Model_ObjMgr::doSubscribe(int msgID, int unitID)
{
	char sql[1024];

	sprintf(
			sql,
			"INSERT INTO run_subscribers(run_message_id,instance,run_peer_id) Values(%d,%d,%d);",
			msgID, unitID, this->peer_id_);

	//ACE_DEBUG ((LM_DEBUG, "Model_ObjMgr::doSubscribe -> %s\n", sql));

	/* MYSQL_RES  *result = */
	this->db_->doQuery(sql, false);
	if (this->db_->affected_rows() == 0)
		ACE_DEBUG((LM_ERROR,
				"(%P|%t) Model_ObjMgr::doSubscribe(%d): Error : (%s)\n", msgID,
				sql));
	//this->db_->freeQuery (result);

	if (DebugFlag::instance ()->enabled(DebugFlag::OBJ_DEBUG))
	{
		ACE_DEBUG((LM_DEBUG,
				"(%P|%t) Model_ObjMgr::doSubscribe(%d,%d) Start\n", msgID,
				unitID ));
		ACE_DEBUG((LM_DEBUG, "(%P|%t) Model_ObjMgr::doSubscribe -> %s\n", sql));
	}
}

//..................................................................................................
// Returns the Unique Message ID
int Model_ObjMgr::RegisterToPublish(int appMsgID)
{
	if ( !this->initialized_)
	{
		ACE_DEBUG((LM_ERROR,
				"(%P|%t) Model_ObjMgr::RegisterToPublish -> NOT INITIALIZED\n"));
		return 0;
	}

	//fprintf(stderr,"Model_ObjMgr::RegisterToPublish (%d,%d)\n", appMsgID, unitID);
	char sql[1024];
	sprintf(sql,"INSERT INTO run_messages(run_id, app_message_id) Values(%d, %d);", this->run_id_, appMsgID);
	int id = (int) this->db_->InsertGetId(sql, true);

	if (DebugFlag::instance ()->enabled(DebugFlag::OBJ_DEBUG))
	{
		ACE_DEBUG((LM_DEBUG, "Model_ObjMgr::RegisterToPublish (%s)-> %d\n",
				sql, id));
	}

	// This combination of RunID and AppMsgID already existed
	if (id == 0) // is non-negative with 0 being the error TODO throw error
	{
		sprintf(sql, "SELECT id from run_messages where run_id=%d and app_message_id= %d", this->run_id_, appMsgID);
		id = (int) this->db_->LookupInt(sql);

		if (DebugFlag::instance ()->enabled(DebugFlag::OBJ_DEBUG))
		{
			ACE_DEBUG((LM_DEBUG,"(%P|%t) Model_ObjMgr::RegisterToPublish (%s)-> %d\n", sql, id));
		}
	}

	// Increment the Referrence Counter
	sprintf(sql, "UPDATE run_messages SET ref_count = ref_count+1 where id=%d ", id);
	MYSQL_RES *result = this->db_->doQuery(sql, false);
	if (this->db_->affected_rows() == 0)
		ACE_DEBUG((LM_ERROR, "(%P|%t) Model_ObjMgr::RegisterToPublish error! (%d) (%s)\n\n", appMsgID, sql));
	this->db_->freeQuery(result);

	return id; // returns the Message ID
}

//..................................................................................................
// removes the Unique Message ID, after all references to it are gone
// this is called by the entity, so use this unit_id
void Model_ObjMgr::unRegisterPublish(int msgID)
{
	if ( !this->initialized_)
	{
		ACE_DEBUG((LM_ERROR,
				"(%P|%t) Model_ObjMgr::unRegisterPublish -> NOT INITIALIZED\n"));
		return;
	}

	char sql[1024];
	MYSQL_RES *result = 0;

	// this uses the Samson Message ID!!!!!

	if (DebugFlag::instance ()->enabled(DebugFlag::OBJ_DEBUG))
	{
		ACE_DEBUG((LM_DEBUG, "(%P|%t) Model_ObjMgr::unRegisterPublish (%d)\n",
				msgID));
	}

	// Decrement the Referrence Counter
	sprintf(sql, "UPDATE run_messages SET ref_count = ref_count-1 where id=%d", msgID);
	result = this->db_->doQuery(sql, false);
	if (this->db_->affected_rows() == 0)
		ACE_DEBUG((LM_ERROR,
				"(%P|%t) Model_ObjMgr::unRegisterPublish(%d) RefCount error\n",
				msgID));
	this->db_->freeQuery(result);


#if 0
	// TODO Move this logic to a database trigger
	sprintf(sql,"Select refcount from run_messages where id=%d", msgID);
	if ( this->db_->LookupInt(sql) <= 0 )
	{
		sprintf(sql,"DELETE FROM run_messages where id=%d", msgID);
		result = this->db_->doQuery (sql, false);
		this->db_->freeQuery (result);

		sprintf(sql,"DELETE FROM run_subscribers where run_message_id=%d", msgID);
		result = this->db_->doQuery (sql, false);
		this->db_->freeQuery (result);
	}
#endif

}

//..................................................................................................
//  Initialize the runstats record
void Model_ObjMgr::InitRunStats()
{
#if 0
	char sql[1024];

	unsigned int dnode = this->LookupNodeID(Options::instance ()->host());

	sprintf(
			sql,
			"Insert into RunStats_Master (UUID, PID, JobID, ModelID, NodeID, DispNodeID, UnitID, PeerKey)"
				" Values('%s', %d, %d, %d, %d, %d, %d, '%s');",
			this->run_UUID_.c_str(), this->pid_, this->run_id_,
			this->peer_id_, this->node_id_, dnode, this->unit_id_,
			this->app_lib_.c_str());
	this->runstats_id_ = this->db_->InsertGetId(sql, true);

	// Set the model record
	sprintf(sql, "Update Model Set RunStatsID = %d where ID=%d",
			this->runstats_id_, this->peer_id_);
	MYSQL_RES *result = this->db_->doQuery(sql, false);
	if (this->db_->affected_rows() == 0)
		ACE_DEBUG((LM_ERROR, "(%P|%t) Model_ObjMgr::InitRunStats(%s) error\n",
				sql));
	this->db_->freeQuery(result);
#endif
}

//..................................................................................................
//  A Model needs a unique ID, this registers the application
void Model_ObjMgr::setPeerID()
{
	// This sets the Master Record in the table "Peer"
	// TODO can me move this up into the Base ???
	Base_ObjMgr::setPeerID(this->app_key_.c_str());

	// This sets the companion Record in the table "Model"
	char sql[1024];
	if (this->peer_id_ > 0)
	{
		unsigned int dnode = this->LookupNodeID(Options::instance ()->host());

		sprintf(
				sql,
				"INSERT INTO run_models(run_peer_id, run_id, dll, instance, dispnodeid, status) "
				"Values(%d, %d, '%s', %d, %d, 1);",
				this->peer_id_, this->run_id_, this->app_lib_.c_str(),
				this->unit_id_, dnode);
		int ignore_id = this->db_->InsertGetId(sql, true);
		ACE_UNUSED_ARG(ignore_id);

		sprintf(sql, "UPDATE runs SET status = status+1 where id=%d",
				this->run_id_);
		MYSQL_RES *result = this->db_->doQuery(sql, false);
		if (result)
		{
			if (this->db_->affected_rows() == 0)
				ACE_DEBUG((
						LM_ERROR,
						"(%P|%t) Model_ObjMgr::setPeerID -> Could not update run status?\n(%s)\n\n",
						sql));
			this->db_->freeQuery(result);
		}
	}
}

//..................................................................................................
// When the Model is finished, unregister it.
void Model_ObjMgr::setRate(double arate)
{
	if ( !this->initialized_)
	{
		ACE_DEBUG((LM_ERROR,
				"(%P|%t) Model_ObjMgr::setRate -> NOT INITIALIZED\n"));
		return;
	}

	char sql[1024];
	sprintf(sql, "UPDATE run_models SET rate=%f WHERE run_peer_id=%d;", arate,
			this->peer_id_);

	//ACE_DEBUG((LM_DEBUG,"(%P|%t) Model_ObjMgr::setRate -> (%s)\n",sql));

	MYSQL_RES *result = this->db_->doQuery(sql, false);
	if (result)
	{
		if (this->db_->affected_rows() == 0)
			ACE_DEBUG((
					LM_ERROR,
					"(%P|%t) Model_ObjMgr::setRate -> Could not set the model rate?\n(%s)\n\n",
					sql));
		this->db_->freeQuery(result);
	}
	return;
}

//..................................................................................................
// When the Model is finished, unregister it.
void Model_ObjMgr::setReady()
{
	if ( !this->initialized_)
	{
		ACE_DEBUG((LM_ERROR,
				"(%P|%t) Model_ObjMgr::setReady -> NOT INITIALIZED\n"));
		return;
	}

	char sql[1024];
	sprintf(sql, "UPDATE run_models SET model_ready=1 where run_peer_id=%d;",
			this->peer_id_);

	//ACE_DEBUG((LM_DEBUG,"(%P|%t) Model_ObjMgr::setReady -> (%s)\n",sql));

	MYSQL_RES *result = this->db_->doQuery(sql, false);
	if (result)
	{
		if (this->db_->affected_rows() == 0)
			ACE_DEBUG((
					LM_ERROR,
					"(%P|%t) Model_ObjMgr::setReady -> Could not set the model ready?\n(%s)\n\n",
					sql));
		this->db_->freeQuery(result);
	}
	return;
}

//..................................................................................................
//  A Model needs a unique ID, this registers the application
int Model_ObjMgr::getStepRate()
{
	if ( !this->initialized_)
	{
		ACE_DEBUG((LM_ERROR,
				"(%P|%t) Model_ObjMgr::getStepRate -> NOT INITIALIZED\n"));
		return 0;
	}

	int rtn = 0;

	char sql[1024];
	sprintf(sql,
			"SELECT count( id ) FROM run_models WHERE rate > 0.0 and run_id=%d;",
			this->run_id_);
	ACE_DEBUG((LM_ERROR, "\nModel_ObjMgr::getStepRate -> (%s)\n", sql));

	MYSQL_RES *result = this->db_->doQuery(sql, false);
	if (result != NULL)
	{
		MYSQL_ROW row = mysql_fetch_row(result);
		rtn = atoi(row[0]);
		this->db_->freeQuery(result);
	}
	else
		ACE_DEBUG((LM_ERROR,
				"(%P|%t) Model_ObjMgr::getRunPeerList error: (%s)\n", sql));

	return rtn;
}

//..................................................................................................
void Model_ObjMgr::print(void) const
{
	if ( !this->initialized_)
	{
		ACE_DEBUG((LM_ERROR, "(%P|%t) Model_ObjMgr::print -> NOT INITIALIZED\n"));
		return;
	}

	Base_ObjMgr::print();

	ACE_DEBUG((
			LM_INFO,
			"(%P|%t) Model_ObjMgr:: UUID=%s UnitID=%d RunStatsID=%d AppKey=%s, AppLib=%s\n",
			this->run_UUID_.c_str(), this->unit_id_, this->runstats_id_,
			this->app_key_.c_str(), this->app_lib_.c_str() ));
}

//..................................................................................................
ofstream * Model_ObjMgr::CreateOutputFile(const char *theName)
{
	ofstream *the_ofstream = 0;

	// get the location to put the file
	std::string theFilename = ".";
	const char* temp_envs[] =
	{ "ISE_RUN", "ISE_ROOT", 0 };
	for (const char** temp_env = temp_envs; *temp_env != 0; ++temp_env)
	{
		char* tdir = ACE_OS::getenv(*temp_env);
		if (tdir != 0)
		{
			theFilename = tdir;
			break;
		}
	}
	theFilename += "/output/";
	theFilename += this->RunUUID();
	theFilename += "/";
#if 0
	if (theName != 0)
	{
		theFilename += theName;
	}
	else
	{
		char filename[80];
		ACE_OS::sprintf(filename,"%s%d.txt",
				Options::instance()->appKey(),
				Options::instance()->unitID());
		theFilename += filename;
	}
#endif

	theFilename += theName;
	the_ofstream = new ofstream(theFilename.c_str(), ios::out | ios::trunc);

	return the_ofstream;
}

//..................................................................................................
ifstream * Model_ObjMgr::OpenInputFile(const char *theName)
{
	ifstream *the_ifstream = 0;

	// get the location to put the file
	std::string theFilename = ".";
	const char* temp_envs[] =
	{ "ISE_RUN", "ISE_ROOT", 0 };
	for (const char** temp_env = temp_envs; *temp_env != 0; ++temp_env)
	{
		char* tdir = ACE_OS::getenv(*temp_env);
		if (tdir != 0)
		{
			theFilename = tdir;
			break;
		}
	}
	theFilename += "/";

#if 0
	if (theName != 0)
	{
		theFilename += theName;
	}
	else
	{
		char filename[80];
		ACE_OS::sprintf(filename,"%s%d.txt",
				Options::instance()->appKey(),
				Options::instance()->unitID());
		theFilename += filename;
	}
#endif

	theFilename += theName;

	ACE_DEBUG((LM_INFO, "(%P|%t) Model_ObjMgr::OpenInputFile (%s)\n",theFilename.c_str() ));

	the_ifstream = new ifstream(theFilename.c_str());

	return the_ifstream;
}

//..................................................................................................
void
Model_ObjMgr::setRunMaster (void)
{
	ACE_TRACE("Model_ObjMgr::setRunMaster");

	char sql[1024];

	sprintf(sql,"UPDATE runs SET run_peer_id=%d where id=%d ", this->peer_id_, this->run_id_);
	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	this->db_->freeQuery (result);

	this->run_master_ = true;

	if (DebugFlag::instance ()->enabled(DebugFlag::OBJ_DEBUG))
	{
		ACE_DEBUG((LM_DEBUG, "(%P|%t) Model_ObjMgr::setRunMaster (%s)\n",sql));
	}

}

//..................................................................................................
void
Model_ObjMgr::saveExecuteTime (double interval_sec)
{
	ACE_TRACE("Model_ObjMgr::saveExecuteTime");

	char sql[1024];

	sprintf(sql,"UPDATE run_models SET execute_time=%f where run_peer_id=%d ", interval_sec, this->peer_id_ );
	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	this->db_->freeQuery (result);

	if (DebugFlag::instance ()->enabled(DebugFlag::OBJ_DEBUG))
	{
		ACE_DEBUG((LM_DEBUG, "(%P|%t) Model_ObjMgr::saveExecuteTime (%s)\n",sql));
	}

}

//..................................................................................................
void
Model_ObjMgr::extendedStatus (std::stringstream& msg)
{
	ACE_TRACE("Model_ObjMgr::extendedStatus");

	std::stringstream sql;
	sql << "UPDATE run_models SET extended_status='" << msg.str() << "' where run_peer_id=" << this->peer_id_;

	MYSQL_RES  *result = this->db_->doQuery (sql.str().c_str(), false);
	this->db_->freeQuery (result);

	if (DebugFlag::instance ()->enabled(DebugFlag::OBJ_DEBUG))
	{
		ACE_DEBUG((LM_DEBUG, "(%P|%t) Model_ObjMgr::extendedStatus (%s)\n",sql.str().c_str()));
	}

}

} // namespace
