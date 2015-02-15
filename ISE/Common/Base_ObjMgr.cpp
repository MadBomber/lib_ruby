/**
 *	@file Base_ObjMgr.cpp
 *
 *	@brief common code for managing models and services
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */


#define ISE_BUILD_DLL

#include "Base_ObjMgr.h"
#include "Options.h"
#include "DebugFlag.h"
#include "PeerTable.h"

// std includes
#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <sstream>
#include <string>

//....boost smart pointer
#include <boost/shared_ptr.hpp>

// ACE includes
#include "ace/Log_Msg.h"
#include "ace/Message_Block.h"

// TODO ERROR I cannot include this file on linux or it mucks with the ACE macros for library exporting ARRRRGGGGG
//#include <my_global.h>
#include <mysql.h>

namespace Samson_Peer {


#if !defined (__ACE_INLINE__)
#include "Base_ObjMgr.inl"
#endif /* __ACE_INLINE__ */


// bridge or facade pattern...don't really care, is indirection for perceived safety
// TODO:  review this decision
st_mysql_res *Base_ObjMgr::doQuery (char *sql, bool ignoreDup) { return this->db_->doQuery(sql, ignoreDup); }
void Base_ObjMgr::freeQuery (st_mysql_res *result) { this->db_->freeQuery(result); }



//............................................................................................................
/** Base_ObjMgr - default constructor
 * allocates a database handle
 */
Base_ObjMgr::Base_ObjMgr() : hostrec_(0),peer_id_(0),pid_(0),node_id_(0),initialized_(false)
{
	ACE_TRACE("Base_ObjMgr::Base_ObjMgr");
}

//............................................................................................................
/** Base_ObjMgr - default destructor
 * TODO  is this the place to really remove this Peer's ID from the table?
 */
Base_ObjMgr::~Base_ObjMgr()
{
	ACE_TRACE("Base_ObjMgr::~Base_ObjMgr");
	ACE_DEBUG ((LM_INFO, "(%P|%t) Base_ObjMgr::~Base_ObjMgr called\n"));
	this->removePeerID();
	this->db_->close();
}

//............................................................................................................
/** Base_ObjMgr - initializer
 * allocates a database handle
 */
int Base_ObjMgr::initialize (bool persist, bool autoconnect)
{
	ACE_TRACE("Base_ObjMgr::initializer");

	int retval = -1;

	// get the host-name, this must succeed
	// TODO  recover by getting all IP addresses till one works
	ACE_OS::uname (&un_);

	//ACE_DEBUG ((LM_INFO, "(%P|%t) Base_ObjMgr::initialize ->  nodename:(%s)\n",un_.nodename));
	this->hostrec_ = ACE_OS::gethostbyname (un_.nodename);

	if (this->hostrec_ == NULL)
	{
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Base_ObjMgr::initialize -> FATAL gethostbyname failed %p\n"));
	}
	else
	{
#if 0
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) Base_ObjMgr::initialize -> Machine: %C running on %C\n",
				un_.nodename, un_.machine ));
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) Base_ObjMgr::initialize -> Platform: %C, %C, %C\n",
				un_.sysname, un_.release, un_.version ));
#endif
		// Get the Unix Process ID
		this->pid_ = ACE_OS::getpid();

		// Open the Database for processing
		this->db_.reset( new DBMgr(persist,autoconnect));

		// checks for allocation AND open error
		retval = ( (this->db_.get()==0) || this->db_->error() ) ? -1 : 1;

		// Get the Node ID (and IP ) where I am running
		if (retval == 1 )
		{
			this->node_id_ = LookupNodeID ();

			if ( this->node_id_ != 0 )
			{
				char sql[1024];
				sprintf(sql,"SELECT ip_address from nodes where id=%d", this->node_id_);
				MYSQL_RES  *result = this->db_->doQuery (sql, false);
				if ( result != NULL )
				{
					MYSQL_ROW row = mysql_fetch_row(result);
					if (row) this->ip_address_   = row[0];
					this->db_->freeQuery (result);
					//ACE_DEBUG ((LM_DEBUG, "(%P|%t) Base_ObjMgr::initialize -> Node ID: %d with IP: %s (%s)\n",
					//		this->node_id_, this->ip_address_.c_str(), this->un_.nodename));
					this->status(1);
				}
				else
				{
					retval = -1;
					ACE_DEBUG ((LM_ERROR, "(%P|%t) Base_ObjMgr::initialize -> IP lookup FAILED for Node ID: %d on %C\n",
											this->node_id_, this->un_.nodename));
				}
			}
			else
			{
				retval = -1;
				ACE_DEBUG ((LM_ERROR, "(%P|%t) Base_ObjMgr::initialize -> FAILED Node ID: %d for %C\n",
						this->node_id_, this->un_.nodename));
			}
		}
	}

	return retval;
}


//..................................................................................................
/**  getModelKey - returns the name of a given Model ID.  It is really a static member, but
 * this is not requires as we are using it as a singleton.
 *
 * @param  model_id
 * @return name (in parameter list)
 */
void
Base_ObjMgr::getModelKey (unsigned int model_id, char *name)
{
	ACE_TRACE("Base_ObjMgr::getModelKey");

	char sql[1024];
	sprintf(sql,"SELECT peer_key FROM run_peers WHERE ID  = %d;",model_id);

	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result != NULL )
	{
		MYSQL_ROW row = mysql_fetch_row(result);
		if ( row)
		{
			strcpy(name,row[0]);
		}
		else
			ACE_DEBUG ((LM_ERROR, "(%P|%t) Base_ObjMgr::getModelKey no row: (%s)\n",sql));
	}
	else
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Base_ObjMgr::getModelKey error: (%s)\n",sql));
	this->db_->freeQuery (result);

	return;
}


//..................................................................................................
/**  getModelDetails - returns details containing details about a model ID
 *
 * @param  model_id
 * @param  name - returns model name
 * @param  runid - returns Run ID
 * @param  nodeid - returns node ID
 * @param  pid -  returns PID
 * @param  unitid - returns unit ID
 * @param  statsid - returns Statistics Collection ID
 * @return true if found, false otherwise
 */
bool
Base_ObjMgr::getModelDetails (unsigned int model_id, std::string &name ,
	unsigned int &runid, unsigned int &nodeid, int &pid, unsigned int &unitid, unsigned int &statsid)
{
	ACE_TRACE("Base_ObjMgr::getModelDetails");

	bool retval = false;
	char sql[1024];
	sprintf(sql,"SELECT run_peers.peer_key, run_peers.node_id, run_peers.pid, run_models.run_id, run_models.instance "
			"FROM run_peers, run_models "
			"WHERE run_peers.id=run_models.run_peer_id and run_peers.id=%d;",
			model_id);
	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result != NULL )
	{
		MYSQL_ROW row = mysql_fetch_row(result);
		if (row)
		{
			name   = row[0];
			nodeid = atoi(row[1]);
			pid    = atoi(row[2]);
			runid  = atoi(row[3]);
			unitid = atoi(row[4]);
			statsid = atoi(row[5]);
			retval = true;
		}
		else
			ACE_DEBUG ((LM_DEBUG, "(%P|%t) Base_ObjMgr::getModelDetails no row: (%s)\n",sql));
	}
	else
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Base_ObjMgr::getModelDetails error: (%s)\n",sql));
	this->db_->freeQuery (result);

	return retval;
}


//..................................................................................................
/**
 *
 * @param
 * @return
 */
unsigned int
Base_ObjMgr::LookupNodeID(void)
{
	ACE_TRACE("Base_ObjMgr::LookupNodeID");

	char SelSQL[1024];
	sprintf(SelSQL,"SELECT id FROM nodes WHERE name = '%s' or fqdn = '%s';", this->hostname(), this->hostname());
	//ACE_DEBUG ((LM_DEBUG, "(%P|%t) Base_ObjMgr::LookupNodeID (%s)\n",SelSQL));
	return this->db_->LookupInt(SelSQL);
}

//..................................................................................................
unsigned int
Base_ObjMgr::LookupNodeID(const char *anIPAddress)
{
	ACE_TRACE("Base_ObjMgr::LookupNodeID (IP Address)");

	char SelSQL[1024], InsSQL[1024];

	std::string theIP =  (strncmp(anIPAddress,"127.0.0.1",4)==0
		|| strncmp(anIPAddress,"localhost",9)==0 ) ? this->ipaddress() : anIPAddress;

	sprintf(SelSQL,"SELECT id FROM nodes WHERE ip_address = '%s';",theIP.c_str());
	sprintf(InsSQL,"INSERT INTO nodes(name, status, ip_address, FQDN) Values('%s', %d,'%s','%s');",
	        "UNK", 0, theIP.c_str(), "UNK");
	return this->db_->LookupAddID(SelSQL,InsSQL);
}

//..................................................................................................
int
Base_ObjMgr::getUniqueAppID(const char *AppMsgKey, const char *Description)
{
	ACE_TRACE("Base_ObjMgr::getUniqueAppID");

	char SelSQL[1024], InsSQL[1024];

	sprintf(SelSQL,"SELECT id FROM app_messages  WHERE app_message_key = '%s';",AppMsgKey);
	sprintf(InsSQL,"INSERT INTO app_messages(app_message_key, description) Values('%s','%s');",
	        AppMsgKey, Description);
	return this->db_->LookupAddID(SelSQL,InsSQL);
}

//..................................................................................................
std::string
Base_ObjMgr::getAppMsgKey(const int id)
{
	ACE_TRACE("getAppmsgKey::getUniqueAppID");

	std::string retval = "missing";

	char sql[1024];

	sprintf(sql,"SELECT app_message_key FROM app_messages  WHERE id = '%d';",id);
	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result != NULL )
	{
		MYSQL_ROW row = mysql_fetch_row(result);
		if (row)
		{
			retval = row[0];
		}
		else
			ACE_DEBUG ((LM_DEBUG, "(%P|%t) Base_ObjMgr::getAppMsgKey no row: (%s)\n",sql));
	}
	else
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Base_ObjMgr::getAppMsgKey error: (%s)\n",sql));
	this->db_->freeQuery (result);

	return retval;
}

//..................................................................................................
std::string
Base_ObjMgr::getPeerKey (const int id)
{
	ACE_TRACE("getAppmsgKey::getUniqueAppID");

	std::string retval = "missing";

	char sql[1024];

	sprintf(sql,"SELECT peer_key FROM run_peers WHERE id = '%d';",id);
	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result != NULL )
	{
		MYSQL_ROW row = mysql_fetch_row(result);
		if (row)
		{
			retval = row[0];
		}
		else
			ACE_DEBUG ((LM_DEBUG, "(%P|%t) Base_ObjMgr::getAppMsgKey no row: (%s)\n",sql));
	}
	else
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Base_ObjMgr::getAppMsgKey error: (%s)\n",sql));
	this->db_->freeQuery (result);

	return retval;
}

//..................................................................................................
unsigned int
Base_ObjMgr::getPeerID (int unit_id, const char *peer_key)
{
	ACE_TRACE("getAppmsgKey::getPeerID");

	unsigned int retval = -1;

	char sql[1024];

	sprintf(sql,"SELECT run_peer_id FROM run_models, run_peers"
			" WHERE run_peers.id = run_models.run_peer_id and "
			"run_peers.peer_key = '%s' and run_models.instance = '%d';",
			peer_key, unit_id);


	// ACE_DEBUG ((LM_DEBUG, "(%P|%t) Base_ObjMgr::getPeerID: (%s)\n",sql));


	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result != NULL )
	{
		MYSQL_ROW row = mysql_fetch_row(result);
		if (row)
		{
			retval = atoi(row[0]);
		}
		else
			ACE_DEBUG ((LM_DEBUG, "(%P|%t) Base_ObjMgr::getPeerID no row: (%s)\n",sql));
	}
	else
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Base_ObjMgr::getPeerID error: (%s)\n",sql));
	this->db_->freeQuery (result);

	return retval;
}

//..................................................................................................
int
Base_ObjMgr::countAppKey(const char *anAppKey)
{
	ACE_TRACE("Base_ObjMgr::countAppKey");

	int count=0;
	char SelSQL[1024];

	sprintf(SelSQL,"SELECT count(id) FROM peers WHERE PeerKey = '%s';",anAppKey);
        MYSQL_RES  *result1 = this->db_->doQuery (SelSQL, false);
        if ( result1 != NULL )
        {
                MYSQL_ROW row = mysql_fetch_row(result1);
                if ( row)
                {
                        count  = atoi(row[0]);
                }
        }
        this->db_->freeQuery (result1);

	return count;
}

//..................................................................................................
bool
Base_ObjMgr::verifyRunID (unsigned int jid)
{
	ACE_TRACE("Base_ObjMgr::verifyRunID()");

	char sql[1024];

	sprintf(sql,"SELECT id FROM runs WHERE id = %d;",jid);
	return ( ((unsigned int) this->db_->LookupInt(sql)) == jid );
}



//..................................................................................................

int
Base_ObjMgr::KeyValueQuery (const char *key, ACE_CString &value)
{
	ACE_TRACE("Base_ObjMgr::KeyValueQuery");

	char sql[1024];
	int nrow = 0;

	sprintf(sql,"SELECT value FROM name_values WHERE name='%s'",key);

	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result != NULL )
	{
		nrow = (int) mysql_num_rows(result);
		if ( nrow == 1)
		{
			MYSQL_ROW row = mysql_fetch_row(result);
			if (row)
			{
				value.set(row[0]);
			}
			else
				ACE_DEBUG ((LM_ERROR, "(%P|%t) Base_ObjMgr::KeyValueQuery (%s) -> no row\n", sql));

		}
		this->db_->freeQuery (result);
	}

	if (DebugFlag::instance ()->enabled (DebugFlag::OBJ_DEBUG))
	{
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Base_ObjMgr::KeyValueQuery (%s) -> nrow(%d)\n(%s)\n", sql, nrow, value.c_str()));
	}

	return nrow;
}

//..................................................................................................
bool
Base_ObjMgr::isDispatcher (unsigned int peer_id, unsigned int &node_id)
{
	ACE_TRACE("Base_ObjMgr::isDispatcher");

	node_id = 0;
	bool retval;
	char sql[1024];

	sprintf(sql,"SELECT node_id FROM run_peers WHERE id=%d AND peer_key='dispatcher';", peer_id);
	//ACE_DEBUG ((LM_DEBUG, "Base_ObjMgr::isDispatcher: (%s)\n",sql));

	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result != NULL )
	{
		MYSQL_ROW row = mysql_fetch_row(result);
		if (row)
		{
			retval = true;
			node_id = atoi(row[0]);
		}
	}
	else
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Base_ObjMgr::isDispatcher error: %s\n",sql));

	//ACE_DEBUG ((LM_DEBUG, "Base_ObjMgr::isDispatcher: (%s) -> retval=%d node_id=%d\n",sql, retval, node_id));

	this->db_->freeQuery (result);
	return retval;
}

//..................................................................................................
bool
Base_ObjMgr::isRunMaster (unsigned int run_id)
{
	ACE_TRACE("Base_ObjMgr::isRunMaster");

	bool retval;
	char sql[1024];

	sprintf(sql,"SELECT run_peers.id, nodes.id, nodes.ip_address, nodes.FQDN "
			"FROM run_peers, runs, nodes "
			"WHERE runs.id =%d "
			"AND runs.run_peer_id = run_peers.id "
			"AND run_peers.node_id = nodes.id;",
			run_id);

	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result != NULL )
	{
		int nsub = (int) mysql_num_rows(result);
		if (nsub > 0 ) retval = true;
	}
	else
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Base_ObjMgr::isRunMaster error: %s\n",sql));

	this->db_->freeQuery (result);
	return retval;
}


//..................................................................................................
bool
Base_ObjMgr::status (unsigned int val)
{
	ACE_TRACE("Base_ObjMgr::status()");

	bool retval = false;
	if ( this->peer_id_ != 0 )
	{
		char sql[1024];
		sprintf(sql,"Update run_peers SET status=%d WHERE id = %d;",val,peer_id_);
		MYSQL_RES  *result = this->db_->doQuery (sql, false);
		this->db_->freeQuery (result);
		retval = true;
	}
	return retval;
}


//..................................................................................................
void
Base_ObjMgr::print (void) const
{
	ACE_DEBUG ((LM_INFO, "(%P|%t) %s\n", this->report().c_str()));
}

//..................................................................................................
const std::string
Base_ObjMgr::report (void) const
{
	std::stringstream my_report;
	my_report << "PeerID/ModelID=" << this->peer_id_ << ", PID=" << this->pid_ << ", Node=" << this->node_id_ << std::endl;
	return my_report.str();
}

//..................................................................................................
const std::string
Base_ObjMgr::report_xml (void) const
{
	std::stringstream my_report;
	{
		boost::archive::my_xml_oarchive oa(my_report,"/identity.xsl");
		oa & boost::serialization::make_nvp("identity",*this);
	}
	return my_report.str();
}


//..................................................................................................
//  A Model needs a unique ID, this registers the application

void
Base_ObjMgr::setPeerID(const char *appKey)
{

	ACE_TRACE("Base_ObjMgr::setPeerID");
	char sql[1024];

	sprintf(sql,"INSERT INTO run_peers(node_id, PID, peer_key) Values( %d, %d, '%s');",
			this->node_id_, this->pid_, appKey);
	//ACE_DEBUG ((LM_ERROR, "\nBase_ObjMgr::setPeerID -> %s\n",sql));

	this->peer_id_ = (unsigned long) this->db_->InsertGetId(sql,true);

	if ( this->peer_id_ == 0 || DebugFlag::instance ()->enabled (DebugFlag::OBJ_DEBUG))
	{
		ACE_DEBUG ((LM_DEBUG, "Base_ObjMgr::setPeerID (%s)-> %d\n", sql, this->peer_id_));
	}
}

//..................................................................................................
// When the Model is finished, unregister it.
void
Base_ObjMgr::removePeerID(void)
{
	ACE_TRACE("Base_ObjMgr::removePeerID");

	char sql[1024];

	sprintf(sql,"DELETE FROM run_peers WHERE id = %d;", this->peer_id_ );

	if ( DebugFlag::instance ()->enabled (DebugFlag::OBJ_DEBUG))
	{
		ACE_DEBUG ((LM_DEBUG, "Base_ObjMgr::removePeerID (%s)-> %d\n", sql, this->peer_id_));
	}

	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result )
	{
		if ( this->db_->affected_rows () == 0 )
			ACE_DEBUG ((LM_ERROR, "\nBase_ObjMgr::removePeerID -> Could not delete?\n\n"));
		this->db_->freeQuery (result);
	}
}

//..................................................................................................
// When the Model is finished, unregister it.
void
Base_ObjMgr::unsubscribe(void)
{
	ACE_TRACE("Base_ObjMgr::unsubscribe");

	char sql[1024];

	sprintf(sql,"DELETE FROM run_subscribers WHERE run_peer_id = %d;", this->peer_id_ );

	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result )
	{
		if ( this->db_->affected_rows () == 0 )
			ACE_DEBUG ((LM_ERROR, "\nBase_ObjMgr::unsubscribe -> Could not delete?\n\n"));
		this->db_->freeQuery (result);
	}
}

//..................................................................................................
/**  getPeerTable - returns
 *
 *  This pulls the "what models should be run" allows the controller to know when it can start.
 *
 * @param  run_id
 * @param  pt
 * @return name (in parameter list)
 */
int
Base_ObjMgr::getPeerTable (unsigned int run_id, PeerTable &pt)
{
	ACE_TRACE("Base_ObjMgr::getPeerTable");

	int peer_count = 0;

	// Set the PeerTable information
	pt.run_id = run_id;

	//  Pull the Models that are supposed to be running
	char sql[1024];
	sprintf(sql,"SELECT models.dll as dll, models.name, job_configs.model_instance as unit_id "
			"FROM runs, job_configs, models "
			"WHERE models.id=job_configs.model_id "
			"AND runs.job_id=job_configs.job_id "
			"AND runs.id=%d;",run_id);


	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result == NULL )
	{
		ACE_DEBUG ((LM_DEBUG, "Base_ObjMgr::getPeerTable error: (%s)\n",sql));
		return peer_count;
	}

	// How many models are there
	peer_count= (int) mysql_num_rows(result);

	// Build the table
	MYSQL_ROW row;
	while ( (row=mysql_fetch_row(result)) != NULL )
	{
		// Peer record consructre uses (Key, Name, UnitID)
		PeerRecord *pr = new PeerRecord(row[0],row[1],atoi(row[2]));
		pt.insert(pr);
	}

	this->db_->freeQuery (result);
	return peer_count;
}

//..................................................................................................
/**  verify_all - returns
 *
 * @param  pt
 * @return true if all runs are started or false if not
 */
bool
Base_ObjMgr::checkPeersStarted (PeerTable &pt)
{
	ACE_TRACE("Base_ObjMgr::checkPeersStarted");

	bool rtn = false;

	std::map<std::string, PeerRecord *>::iterator iter;
	for (iter = pt.pr_.begin(); iter != pt.pr_.end(); iter++)
	{
		PeerRecord *a = iter->second;

		// This nasy query uses the dll, unit_id, and run_id to uniquely fetch a "peer"
		// The model_id is just NOT being used the peer calling this (which is usually the controller) does not know what they are.

		char sql[1024];
		sprintf(sql,"SELECT SQL_NO_CACHE run_peers.id, run_peers.node_id, run_peers.PID, run_models.Rate "
				"FROM run_peers, run_models "
				"WHERE run_models.run_peer_id=run_peers.id "
				"AND run_models.model_ready=1 "
				"AND run_models.dispatcher_ready= 1 "
				"AND run_models.dll= '%s' "
				"AND run_models.instance=%d "
				"AND run_models.run_id=%d;",
				a->DLL.c_str(), a->unit_id, pt.run_id);
		//ACE_DEBUG ((LM_DEBUG, "Base_ObjMgr::checkPeersStarted: (%s)\n",sql));

		MYSQL_RES  *result = this->db_->doQuery (sql, false);

		if ( result != NULL )
		{
			int nfound = (int) mysql_num_rows(result);
			if ( nfound == 1 )
			{
				MYSQL_ROW row = mysql_fetch_row(result);
				a->peer_id = atoi(row[0]);
				a->node_id = atoi(row[1]);
				a->pid = atoi(row[2]);
				a->rate = atof(row[3]);
				rtn = true;
			}
			else
			{
				rtn = false;
			}
			this->db_->freeQuery (result);
			if ( rtn == false ) break;
		}
		else
		{
			ACE_DEBUG ((LM_ERROR, "(%P|%t) Base_ObjMgr::checkPeersStarted not found: (%s)\n",sql));
			rtn = false;
			break;
		}
	}

	return rtn;
}


//..................................................................................................
const std::string
Base_ObjMgr::getRunUUID(unsigned int run_id)
{
	std::stringstream ssql;
	std::string sql;
	std::string guid;
	int nrow = 0;

	ssql << "Select guid from runs where id= " << run_id;
	sql = ssql.str();

	MYSQL_RES *result = this->db_->doQuery(sql, false);
	if (result != NULL)
	{
		nrow = (int) mysql_num_rows(result);
		if (nrow == 1)
		{
			MYSQL_ROW row = mysql_fetch_row(result);
			if (row)
			{
				guid = row[0];
			}
			else
			{
				ACE_DEBUG((LM_ERROR,"(%P|%t) Base_ObjMgr::getRunUUID (%d) -> no row\n",run_id));
			}

		}
		this->db_->freeQuery(result);
	}

	//ACE_DEBUG ((LM_ERROR, "(%P|%t) Base_ObjMgr::getRunUUID (%s)->%s\n",sql.c_str(),guid.c_str()));

	return guid;
}

} // namespace
