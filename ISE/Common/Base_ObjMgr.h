/**
 *	@class Base_ObjMgr
 *
 *	@brief Coordinates the Application with its Environment and Database
 *
 *	This object manages a Simulation object
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef Base_ObjMgr_h
#define Base_ObjMgr_h

#include "ISE.h"

#include "ace/OS_NS_netdb.h"

#include "SamsonPeerData.h"
#include "DBMgr.h"

//....boost smart pointer
#include <boost/shared_ptr.hpp>

// Boost Serialization
#include <boost/serialization/string.hpp>
#include <boost/serialization/utility.hpp>
#include <boost/serialization/version.hpp>
#include <boost/serialization/serialization.hpp>

#include <string>

#include "ace/SString.h" // TODO  Replace this with <string>

#include "my_xml_oarchive.h"

struct st_mysql_res; // forward declaration (MYSQL_RES)

namespace Samson_Peer {

class PeerTable;

// ===========================================================================
class ISE_Export Base_ObjMgr
{
public:

	Base_ObjMgr();
	virtual ~Base_ObjMgr();

	//= Used becase we are the parent a Singleton
	int initialize (bool persist, bool autoconnect = true);

	unsigned int PeerID ();
	unsigned int ModelID ();
	unsigned int NodeID ();
	int PID();

	// --- used to query about other objects (not static because we are a singleton)
	bool getModelDetails (unsigned int model_id, std::string &, unsigned int &,
					 unsigned int &, int &, unsigned int &,  unsigned int &);
	void getModelKey (unsigned int model_id, char *name);

	// ----- OS Stuff
	const char *hostname ();
	const char *FQDN ();
	const char *ipaddress ();

	//  Status flag for database
	bool status (unsigned int);

	//  Used by a model to indicate they are main contact for a run (AppController)
	bool isRunMaster (unsigned int run_id);

	//  Tests a peer to see if it is a dispatcher
	bool isDispatcher(unsigned int peer_id, unsigned int &node_id);

	//  Registers the Application
	int getUniqueAppID(const char *, const char *);

	//  Returns the appMsgKey
	std::string getAppMsgKey(const int id);

	//  Returns the PeerKey
	std::string getPeerKey(const int id);

	//  Returned the PeerID from the model key and unit_id
	unsigned int getPeerID (int unit_id, const char *peer_key);

	// Count the number of instances of an AppKey
	int countAppKey(const char *);

	// generic
	int KeyValueQuery (const char *, ACE_CString &);

	// may be a model only service ???
	int getPeerTable (unsigned int, PeerTable &);
	bool checkPeersStarted (PeerTable &);

	// ---- Internal Debug Stuff ----
	virtual void print (void) const;
	const std::string report (void) const;
	const std::string report_xml (void) const;

	// Empties the Subscriber table of this model ID
	void unsubscribe();

	// this lets anyone use the database  (not desireable!!!!)
	const DBMgr *db() const;
	//const DBMgr *db() const { return const_cast<DBMgr *>(this->db_); }

	// these let anyone run a generic query
	st_mysql_res *doQuery (char *sql, bool ignoreDup);
	void freeQuery (st_mysql_res *result);

	bool verifyRunID (unsigned int jid);

	// Used by boost serialization to save/restore one of these!
	template<class Archive>// TODO move to C++ stl ??
	void serialize(Archive & ar, const unsigned int /* file_version */)
	{
		ar
		& BOOST_SERIALIZATION_NVP(peer_id_)
		& BOOST_SERIALIZATION_NVP(pid_)
		& BOOST_SERIALIZATION_NVP(node_id_)
		;
	}

protected:

	virtual void setPeerID(const char *aKey);
	virtual void removePeerID(void);

	void doSubscribe (int MsgID, int unitID=0);  // Samson Unique Message ID is known  fn(JobID, AppMsgID)

	unsigned int LookupNodeID(void);
	unsigned int LookupNodeID(const char *a); // = "127.0.0.1" );

	const std::string getRunUUID(unsigned int run_id);


	// At this time we are bound to the Database Manager!
	// Currently we are using MySQL and the API is a bit "flaky"
	// Perhaps someone will write an ActiveRecord++  ;)
	boost::shared_ptr<DBMgr> db_;

	//  used for the system information  (deprecated)
	hostent * hostrec_;

	// used for the system information
	ACE_utsname un_;

	unsigned int peer_id_;		// This is Peer.ID in the Database
	int pid_;					// unix process id
	unsigned int node_id_;		// This is Node.ID in database
	std::string ip_address_;
	bool initialized_;


};

#if defined (__ACE_INLINE__)
#include "Base_ObjMgr.inl"
#endif /* __ACE_INLINE__ */


} // Namespace

#endif
