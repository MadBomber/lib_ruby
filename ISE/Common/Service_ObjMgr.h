/**
 *	@class Service_ObjMgr
 *
 *	@brief Coordinates a Service with its Environment and Database
 *
 *	This object is used to coordinate a "Service" with its environment and database
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef Service_ObjMgr_h
#define Service_ObjMgr_h

#include "ISE.h"

#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>

#include "Base_ObjMgr.h"
#include "SamsonPeerData.h"
#include "PeerRoute.h"

#include "ace/Singleton.h"
#include "ace/Null_Mutex.h"
#include "ace/Recursive_Thread_Mutex.h"

namespace Samson_Peer {

// ===========================================================================
class ISE_Export Service_ObjMgr : public Base_ObjMgr
{
public:
	// = Constructor/Destructor
	Service_ObjMgr() : no_cache_(false), cache_dirty_(true) { }
	~Service_ObjMgr() { }

	//= Used becase we are a Singleton
	int initialize (const char *aKey);

	void getAllSubscribers (unsigned int job, unsigned int msg, unsigned int unit,
			std::vector<PeerRoute> &sr, std::vector<unsigned int> &pr, bool);

	void getPeerRoute (unsigned int job, unsigned int model_id,
			std::vector<PeerRoute> &sr, bool);

	int getOtherDispatchers (std::vector<unsigned int> &nodes);
	int getHigherDispatchers (std::vector<unsigned int> &nodes);
	int getJobMaster (unsigned int jobid, std::vector<PeerRoute> &sr);
	int getNodeRoute (unsigned int node_id, std::vector<PeerRoute> &sr);

	void unsubscribe(unsigned int a_peer_id, unsigned int msg, unsigned int unit);

	bool isMasterDispatcher (void);
	void DispatcherStats (unsigned int job_id, unsigned int peer_id, char dir, int nbytes, int nmsgs, double mean, double stddev, double min, double max);
	bool DispatcherInfo (unsigned int node_id, std::string &ip, std::string &fqdn);

	void setReady(int id);

	void reset_cache(void) { this->cache_dirty_=true; }

	// return an ostream pointer to a file
	ofstream *CreateOutputFile (const char *theName);

	// check connectivity to the main ISE database (Delilah)
	int persist_check() { return this->db_->persist_watchdog(); }

protected:

	virtual void setServiceID(const char *aKey);

	void getLocalSubscribersDB (unsigned int msg, unsigned int unit, std::vector<PeerRoute> &, bool);
	void getSubscribingNodesDB (unsigned int msg, unsigned int unit, std::vector<unsigned int> &, bool);
	void getPeerRouteDB (unsigned int node_id, std::vector<PeerRoute> &, bool);

	bool no_cache_;
	bool cache_dirty_;

};

// =======================================================================
// Create a Singleton for the Application
// Manage this from DispatcherFactory::fini
typedef ACE_Unmanaged_Singleton<Service_ObjMgr, ACE_Recursive_Thread_Mutex> SAMSON_OBJMGR;

} // Namespace
#endif

