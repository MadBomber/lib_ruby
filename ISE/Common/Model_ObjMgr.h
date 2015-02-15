/**
 * @file Model_ObjMgr.h
 *
 * @class Model_ObjMgr
 *
 * @brief Coordinates the Application with its Environment and Database
 *
 *	This object is used to ...
 *
 * @note Attempts at zen rarely work.
 *
 * @author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef Model_ObjMgr_h
#define Model_ObjMgr_h

#include "ISE.h"

#include <string>
#include <iostream>
#include <fstream>
#include <sstream>

#include "ace/Recursive_Thread_Mutex.h"
#include "ace/Null_Mutex.h"
#include "ace/Singleton.h"

#include "Base_ObjMgr.h"
#include "SamsonPeerData.h"

namespace Samson_Peer {

// ===========================================================================
class ISE_Export Model_ObjMgr : public Base_ObjMgr
{
private:
	Model_ObjMgr();
	// Constructor is private to ensure singleton

	static Model_ObjMgr *instance_;
	// Singleton.

public:
	~Model_ObjMgr();
	// TODO  I never could get this called???

	void close(void);
	//  Close this out, called from fini

	static Model_ObjMgr *instance (void);
	// Return Singleton...cause ACE Singletons not working correctly across .so's ???  TODO research this

	int initialize (const char *AppKey, const char *AppLib, unsigned int jid, unsigned int unit_id);

	const char *AppKey() { return this->app_key_.c_str(); }
	const char *AppLib() { return this->app_lib_.c_str(); }
	const char *RunUUID () { return this->run_UUID_.c_str(); }
	unsigned int UnitID () { return this->unit_id_; }

	// Not sure how this will really be used?
	int RegisterToPublish (int appMsgID);
	void unRegisterPublish (int msgID);

	// Subscribe to a message, if it does not exist, then it is created.
	int Subscribe (int appMsgID, int unitID);
	int Subscribe (const char *appMsgKey, int unitID, const char *Description);

	int getRunPeerList(SamsonPeerData *&PeerData);

	void setRunMaster (void);

	// save the execute time for this run
	void saveExecuteTime (double interval_sec);

	// save the info to the database
	void extendedStatus (std::stringstream& msg);

	//..................................................................................................
	unsigned int RunID () { return this->run_id_; }
	void RunID (unsigned int jid) { this->run_id_ = jid; }

	// currently this set the model rate in the database
	void setRate(double arate);
	int getStepRate();
	void setReady();

	// Run a multi-query that returns NO Result
	void doRunQuery (std::string& sql);

	// ---- Internal Debug Stuff ----
	virtual void print (void) const;

	// return an ostream pointer to a file
	ofstream *CreateOutputFile (const char *theName);

	// return an ostream pointer to a file
	ifstream *OpenInputFile (const char *theName);

protected:

	void InitRunStats();
	// Initialize the runstats record

	// Insert this Model Record into the Database (calls Parent to add the Peer record)
	virtual void setPeerID(void);

	bool uuid_initialize(void);
	void doSubscribe(int msgID, int unitID);

	// This is the interface to the GUID database
	boost::shared_ptr<DBMgr> run_db_;

	unsigned int run_id_;		// This may not be right, applies to Model Objects  (TODO: refactor this to Model)
	unsigned int runstats_id_;
	unsigned int unit_id_;
	std::string app_key_;
	std::string app_lib_;
	std::string run_UUID_;

	bool run_master_;

};

//typedef ACE_Singleton<Model_ObjMgr, ACE_Null_Mutex> SAMSON_OBJMGR;
typedef Model_ObjMgr SAMSON_OBJMGR;

} // Namespace
#endif
