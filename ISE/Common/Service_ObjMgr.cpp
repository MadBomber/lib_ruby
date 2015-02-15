/**
 *
 * @file Service_ObjectMgr.cpp
 *
 * @author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#define ISE_BUILD_DLL

#include "Service_ObjMgr.h"
#include "SubscriptionCache.h"
#include "PeerRouteCache.h"
#include "Options.h"
#include "DebugFlag.h"
#include "LogLocker.h"

#include "ace/Log_Msg.h"

// TODO ERROR I cannot include this file on linux or it mucks with the ACE macros for library exporting ARRRRGGGGG
//#include <my_global.h>
#include <mysql.h>

namespace Samson_Peer {

//..................................................................................................
int
Service_ObjMgr::initialize (const char *aKey)
{
	ACE_TRACE("Service_ObjMgr::initialize ");

	if ( DebugFlag::instance ()->enabled (DebugFlag::OBJ_DEBUG) )
	{
		LogLocker log_lock;
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) Service_ObjMgr::initialize %s\n",aKey));
	}

	if ( Base_ObjMgr::initialize(true) == -1 ) return -1;

	//cache queries
	this->no_cache_ = Options::instance()->no_cache();

	// node_id_, run_id_, pid_  have to be set prior to this call  (-1 will indicate failure)
	this->setServiceID (aKey);

	return this->peer_id_;
}

//..................................................................................................
bool
Service_ObjMgr::isMasterDispatcher(void)
{
	ACE_TRACE("Service_ObjMgr::isMasterDispatcher ");

	//  Services do not have a Job ID
	bool result = false;
	ACE_CString val;
	if ( this->KeyValueQuery("MasterDispatcherID",val) )
	{
		if (this->node_id_ == ((unsigned int) atoi(val.c_str())) ) result = true;
	}
	return result;
}


//..................................................................................................
/**
 *
 * @param node_id  id of the computing node (input)
 * @param ip the ip address
 * @param fqdn the fully qualified domain name
 * @return true if found, false not
 */
bool Service_ObjMgr::DispatcherInfo (unsigned int node_id, std::string &ip, std::string &fqdn)
{
	bool retval = false;

	char sql[1024];
	sprintf(sql,"SELECT ip_address, FQDN FROM nodes WHERE id= %d;",node_id);

	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result != NULL )
	{
		if (mysql_num_rows(result) == 1 )
		{
			MYSQL_ROW row = mysql_fetch_row(result);
			ip = row[0];
			fqdn = row[1];
			retval = true;
		}
		else
			ACE_DEBUG ((LM_ERROR, "(%P|%t) Service_ObjMgr::DispatcherInfo error1: %s\n",sql));
		this->db_->freeQuery (result);
	}
	else
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Service_ObjMgr::DispatcherInfo error2: %s\n",sql));

	return retval;
}


//..................................................................................................
/**
 *
 * @param returns a vector of nodes_id's (ints)
 * @return the number of dispatchers
 */
int
Service_ObjMgr::getOtherDispatchers (std::vector<unsigned int> &nodes)
{
	ACE_TRACE("Service_ObjMgr::getOtherDispatchers ");

	//  Services do not have a Job ID
	int nsub=0;
	char sql[1024];

	sprintf(sql,"SELECT node_id FROM run_peers WHERE peer_key='dispatcher' AND node_id !=%d;",this->node_id_);

	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result != NULL )
	{
		nsub = mysql_num_rows(result);
		if (nsub > 0 )
		{
			MYSQL_ROW row;
			while ((row = mysql_fetch_row(result)))
			{
				nodes.push_back(atoi(row[0]));
			}
		}
		this->db_->freeQuery (result);
	}
	else
	{
		LogLocker log_lock;
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Service_ObjMgr::getOtherDispatchers error: %s\n",sql));
	}

	if ( DebugFlag::instance ()->enabled (DebugFlag::OBJ_DEBUG) )
	{
		LogLocker log_lock;
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) Service_ObjMgr::getOtherDispatchers: (%s)->%d\n", sql, nsub));
	}

	return nsub;
}

//..................................................................................................
/**
 *
 * @param returns a vector of nodes_id's (ints)
 * @return the number of dispatchers
 */
int
Service_ObjMgr::getHigherDispatchers (std::vector<unsigned int> &nodes)
{
	ACE_TRACE("Service_ObjMgr::getHigherDispatchers ");

	//  Services do not have a Job ID
	int nsub=0;
	char sql[1024];

	sprintf(sql,"SELECT node_id FROM run_peers WHERE peer_key='dispatcher' AND node_id !=%d AND id > %d;",this->node_id_, this->peer_id_);

	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result != NULL )
	{
		nsub = mysql_num_rows(result);
		if (nsub > 0 )
		{
			MYSQL_ROW row;
			while ((row = mysql_fetch_row(result)))
			{
				nodes.push_back(atoi(row[0]));
			}
		}
		this->db_->freeQuery (result);
	}
	else
	{
		LogLocker log_lock;
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Service_ObjMgr::getHigherDispatchers error: %s\n",sql));
	}

	if ( DebugFlag::instance ()->enabled (DebugFlag::OBJ_DEBUG) )
	{
		LogLocker log_lock;
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) Service_ObjMgr::getHigherDispatchers: (%s)->%d\n", sql, nsub));
	}

	return nsub;
}


//..................................................................................................
void
Service_ObjMgr::getAllSubscribers(unsigned int job, unsigned int msg, unsigned int unit,
		std::vector<PeerRoute> &sr, std::vector<unsigned int> &pr, bool show_query)
{
	ACE_TRACE("Service_ObjMgr::getAllSubscribers");

	if ( !this->no_cache_)
	{
		SubscriptionRecordKey id(msg,unit);
		if ( SUBSCR_SET::instance ()->findRouting(id,sr,pr) ) return;

		this->getLocalSubscribersDB ( msg, unit, sr, show_query);
		this->getSubscribingNodesDB ( msg, unit, pr, show_query);
		SubscriptionRecord temp(job,id,sr,pr);
		SUBSCR_SET::instance ()->bind(temp);
		this->cache_dirty_ = false;   // TODO  not working yet!
	}
	else
	{
		this->getLocalSubscribersDB ( msg, unit, sr, show_query);
		this->getSubscribingNodesDB ( msg, unit, pr, show_query);
	}

	return;
}


//..................................................................................................
// during a run when the model goes missing
void
Service_ObjMgr::unsubscribe(unsigned int a_peer_id, unsigned int msg, unsigned int unit)
{
	ACE_TRACE("Base_ObjMgr::unsubscribe(1)");

	ACE_UNUSED_ARG (msg);
	ACE_UNUSED_ARG (unit);

	// first remove from the cache lookup, if required
	if ( !this->no_cache_)
	{
		//SubscriptionRecordKey id(msg,unit);
		//SUBSCR_SET::instance ()->unbindKey(id);
		SUBSCR_SET::instance ()->destroy();
	}

	// then delete from the subscription table
	char sql[1024];
	sprintf(sql,"DELETE FROM run_subscribers WHERE run_peer_id = %d;", a_peer_id );

	if ( DebugFlag::instance ()->enabled (DebugFlag::OBJ_DEBUG))
	{
		ACE_DEBUG ((LM_DEBUG, "Base_ObjMgr::unsubscribe(%d) -> (%s)\n", a_peer_id, sql));
	}

	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result )
	{
		if ( this->db_->affected_rows () == 0 )
			ACE_DEBUG ((LM_ERROR, "\nBase_ObjMgr::unsubscribe -> Could not delete?\n\n"));
		this->db_->freeQuery (result);
	}
}

//..................................................................................................
void
Service_ObjMgr::getLocalSubscribersDB(unsigned int msg, unsigned int unit, std::vector<PeerRoute> &sr, bool show_query)
{
	ACE_TRACE("Service_ObjMgr::getLocalSubscribersDB");

	int nsub=0;
	char sql[1024];

	sprintf(sql,"SELECT run_models.run_peer_id, run_models.dispnodeid "
			"FROM  run_models, run_subscribers "
			"WHERE run_subscribers.run_message_id=%d "
			"AND run_models.run_peer_id=run_subscribers.run_peer_id "
			"AND run_subscribers.instance in (0,%d) "
			"AND run_models.dispnodeid=%d;",
			msg, unit, this->node_id_);

	if ( show_query || DebugFlag::instance ()->enabled (DebugFlag::OBJ_DEBUG) )
	{
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) Service_ObjMgr::getLocalSubscribersDB -> (%s)\n", sql));
	}

	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result != NULL )
	{
		nsub = mysql_num_rows(result);
		if (nsub > 0 )
		{
			MYSQL_ROW row;
			while ((row = mysql_fetch_row(result)))
			{
				PeerRoute temp;
				temp.peer_id = atoi(row[0]);
				temp.node_id = atoi(row[1]);
				sr.push_back(temp);
			}
		}
		this->db_->freeQuery (result);
	}
	else
	{
		LogLocker log_lock;
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Service_ObjMgr::getLocalSubscribersDB ERROR->(%s)\n",sql));
	}

	return;
}

//..................................................................................................
void
Service_ObjMgr::getSubscribingNodesDB(unsigned int msg, unsigned int unit, std::vector<unsigned int> &pr, bool show_query)
{
	ACE_TRACE("Service_ObjMgr::getSubscribingNodes ");

	//  This list will not include this Node

	int nsub=0;
	char sql[1024];

	sprintf(sql,"SELECT DISTINCT run_models.dispnodeid "
				"FROM run_models, run_subscribers "
				"WHERE run_subscribers.run_message_id = %d "
				"AND run_models.run_peer_id = run_subscribers.run_peer_id "
				"AND run_subscribers.instance in (0,%d) "
				"AND run_models.dispnodeid != %d;",
				msg, unit, this->node_id_);

	if ( show_query || DebugFlag::instance ()->enabled (DebugFlag::OBJ_DEBUG) )
	{
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) Service_ObjMgr::getSubscribingNodesDB ->(%s)\n", sql));
	}

	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result != NULL )
	{
		nsub = mysql_num_rows(result);
		if (nsub > 0 )
		{
			MYSQL_ROW row;
			while ((row = mysql_fetch_row(result)))
			{
				pr.push_back(atoi(row[0]));
			}
		}
		this->db_->freeQuery (result);
	}
	else
	{
		LogLocker log_lock;
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Service_ObjMgr::getSubscribingNodesDB error->(%s)\n",sql));
	}

	return;
}


//..................................................................................................
int
Service_ObjMgr::getJobMaster (unsigned int jobid, std::vector<PeerRoute> &sr)
{
	ACE_TRACE("Service_ObjMgr::getJobMaster ");

	int nsub=0;
	char sql[1024];

	sprintf(sql,"SELECT run_peers.id, run_peers.node_id FROM run_peers, runs, nodes "
		" WHERE runs.id =%d AND runs.run_peer_id = run_peers.id;", jobid);

	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result != NULL )
	{
		nsub = mysql_num_rows(result);
		if (nsub > 0 )
		{
			MYSQL_ROW row;
			while ((row = mysql_fetch_row(result)))
			{
				PeerRoute temp;
				temp.peer_id = atoi(row[0]);
				temp.node_id = atoi(row[1]);
				sr.push_back(temp);
			}
		}
	}
	else
	{
		LogLocker log_lock;
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Service_ObjMgr::getJobMaster error: %s\n",sql));
	}

	this->db_->freeQuery (result);
	return nsub;
}

//..................................................................................................
void
Service_ObjMgr::getPeerRoute (unsigned int job, unsigned int peer,
		std::vector<PeerRoute> &sr, bool show_query)
{
	ACE_TRACE("Service_ObjMgr::getPeerRoute");

	if ( !this->no_cache_ )
	{
		if ( PEER_ROUTE_SET::instance ()->findRouting(peer,sr) ) return;

		this->getPeerRouteDB ( peer, sr, show_query);
		PeerRouteRecord temp (job, peer, sr);
		PEER_ROUTE_SET::instance ()->bind(temp);
	}
	else
		this->getPeerRouteDB ( peer, sr, show_query);

	return;
}

//..................................................................................................
void
Service_ObjMgr::getPeerRouteDB (unsigned int peer_id, std::vector<PeerRoute> &sr, bool show_query)
{
	ACE_TRACE("Service_ObjMgr::getPeerRoute ");

	int nsub=0;
	char sql[1024];

	sprintf(sql,"SELECT id, node_id FROM run_peers WHERE id=%d;", peer_id);

	if ( show_query || DebugFlag::instance ()->enabled (DebugFlag::OBJ_DEBUG) )
	{
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) Service_ObjMgr::getPeerRouteDB -> %s\n", sql));
	}

	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result != NULL )
	{
		nsub = mysql_num_rows(result);
		if (nsub > 0 )
		{
			MYSQL_ROW row;
			while ((row = mysql_fetch_row(result)))
			{
				PeerRoute temp;
				temp.peer_id = atoi(row[0]);
				temp.node_id = atoi(row[1]);
				sr.push_back(temp);
			}
		}
		this->db_->freeQuery (result);
	}
	else
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Service_ObjMgr::getPeerRoute error: %s\n",sql));

	return;
}

//..................................................................................................
int
Service_ObjMgr::getNodeRoute (unsigned int node_id, std::vector<PeerRoute> &sr)
{
	ACE_TRACE("Service_ObjMgr::getNodeRoute ");

	int nsub=0;
	char sql[1024];

	sprintf(sql,"SELECT id FROM nodes WHERE nodes.id =%d;", node_id);

	if (DebugFlag::instance ()->enabled (DebugFlag::OBJ_DEBUG))
	{
		ACE_DEBUG ((LM_DEBUG, "Service_ObjMgr::getNodeRoute (%s)\n", sql));
	}

	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result != NULL )
	{
		nsub = mysql_num_rows(result);
		if (nsub > 0 )
		{
			MYSQL_ROW row;
			while ((row = mysql_fetch_row(result)))
			{
				PeerRoute temp;
				temp.peer_id = 0;
				temp.node_id = atoi(row[0]);
				sr.push_back(temp);
			}
		}
	}
	else
	{
		LogLocker log_lock;
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Service_ObjMgr::getNodeRoute error: %s\n",sql));
	}

	this->db_->freeQuery (result);
	return nsub;
}

//..................................................................................................
//  Any Peer needs a unique ID, this registers the application
void
Service_ObjMgr::setServiceID(const char *aKey)
{
	ACE_TRACE("Service_ObjMgr::setServiceID ");

	int id = -1;

	// this trick allows a services to restart
	char sql[1024];
	sprintf(sql,"SELECT id FROM run_peers where node_id=%d and peer_key='%s';", this->node_id_, aKey);

	if (DebugFlag::instance ()->enabled (DebugFlag::OBJ_DEBUG))
	{
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) Service_ObjMgr::setServiceID -> %s\n",sql));
	}

	id = this->db_->LookupInt (sql);

	if ( id > 0 )
	{
		this->peer_id_ = id;
		// this->app_key_ = aKey;  (not one stored for a service)
		sprintf(sql,"UPDATE run_peers SET pid = %d WHERE node_id=%d and peer_key='%s';", this->pid_, this->node_id_, aKey);
		MYSQL_RES  *result = this->db_->doQuery (sql, false);
		if ( this->db_->affected_rows () == 0 )
			ACE_DEBUG ((LM_ERROR, "(%P|%t) Service_ObjMgr::setServiceID -> Serious Error\n"));
		this->db_->freeQuery (result);
	}
	else
	{
		LogLocker log_lock;
		Base_ObjMgr::setPeerID(aKey);
	}
}

//..................................................................................................
void
Service_ObjMgr::DispatcherStats (unsigned int job_id, unsigned int peer_id, char dir, int nbytes, int nmsgs, double mean, double stddev, double min, double max)
{
	ACE_TRACE("Service_ObjMgr::DispatcherStats ");

	char sql[1024];

	boost::shared_ptr<DBMgr> job_db = boost::shared_ptr<DBMgr>(new DBMgr(false,true,"localhost",this->getRunUUID(job_id).c_str()));

	sprintf(sql,"INSERT INTO dispatcher_stats"
		"(run_peer_id, direction, n_bytes, n_msgs, mean_alive, stddev_alive, min_time_alive, max_time_alive) "
		"VALUES (%d, '%c', %d, %d, %f, %f, %f, %f);",
		peer_id, dir, nbytes, nmsgs, mean, stddev, min, max);

	if (DebugFlag::instance ()->enabled (DebugFlag::OBJ_DEBUG))
	{
		LogLocker log_lock;
		ACE_DEBUG ((LM_ERROR, "(%P|%t) Service_ObjMgr::DispatcherStats->\n%s\n",sql));
	}

	MYSQL_RES  *result = job_db->doQuery (sql, false);
	job_db->freeQuery (result);
	job_db->close();

	return;
}


//..................................................................................................
// When the Model is finished, unregister it.
void
Service_ObjMgr::setReady(int id)
{
	ACE_TRACE("Service_ObjMgr::setReady ");

	char sql[1024];
	sprintf(sql,"UPDATE run_models Set dispatcher_ready=1 where run_peer_id=%d;", id );
	//ACE_DEBUG((LM_DEBUG,"(%P|%t) Service_ObjMgr::setReady -> (%s)\n",sql));

	MYSQL_RES  *result = this->db_->doQuery (sql, false);
	if ( result )
	{
		if ( this->db_->affected_rows () == 0 )
		{
			LogLocker log_lock;
			ACE_DEBUG ((LM_ERROR, "(%P|%t) Service_ObjMgr::setReady -> Could not set the model ready?\n(%s)\n\n",sql));
		}
		this->db_->freeQuery (result);
	}
	return;
}

//..................................................................................................
ofstream *
Service_ObjMgr::CreateOutputFile (const char *theName)
{
	ofstream *the_ofstream = 0;

	// get the location to put the file
	std::string theFilename = ".";
	const char* temp_envs[] = { "ISE_RUN", "ISE_ROOT", 0 };
	for(const char** temp_env = temp_envs; *temp_env != 0; ++temp_env)
	{
		char* tdir = ACE_OS::getenv(*temp_env);
		if (tdir != 0)
		{
			theFilename = tdir;
			break;
		}
	}
	theFilename += "/output/";
	//theFilename += this->ipaddress ();
	//theFilename += "/";
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

	//std::cout << theFilename << std::endl;

	return the_ofstream;
}


} // namespace
