/**
 *	@file AppBase.h
 *
 *	@brief Base File for all ISE Models  provices the init, info, fini interfaces
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef Samson_Appbase_H
#define Samson_Appbase_H

#include "ISE.h"

#include "SamsonPeerData.h"
#include "sql_oarchive.h"
#include "Model_ObjMgr.h"

#include <string>

#include "ace/SString.h"
#include "ace/Service_Config.h"
#include "ace/Service_Object.h"

//... boost smart pointers
#include <boost/scoped_ptr.hpp>

//....boost serialization
#include <boost/archive/basic_xml_archive.hpp>
#include <boost/archive/xml_oarchive.hpp>
#include <boost/archive/xml_iarchive.hpp>
#include <boost/serialization/version.hpp>
#include <boost/serialization/nvp.hpp>
#include <boost/serialization/utility.hpp>


class SamsonHeader;  // forward declaration not in Samson_Peer namespace

namespace Samson_Peer {

// ===================================================================================
// The Curiously Recurring Template Pattern (CRTP)
class ISE_Export AppBase : public ACE_Service_Object
{
public:

	// Unlike "most" service objects, I need to override!
	AppBase();
	virtual ~AppBase();

	// These are inherited and should be passed down
	// These are called upon shared object load/unload.
	virtual int init(int argc, ACE_TCHAR *argv[]);
	virtual int fini(void);

	// inherited, yet I have to call it...hmmmm
	virtual int info (ACE_TCHAR **info_string, size_t length) const;

	// This fetches a list of peers for this job (job-peers) from the database
	// It is intended for the job controller, but any peer can get this list.
	void setJobPeerList();

	bool stdin_registered (void) { return this->stdin_registered_; }

	// Get the Key for a given Model (used for debugging)
	char *getAppKey(unsigned int id);

	// Called from SharedAppMgr by the "Hello" message exchange.
	// Expected to be implemented by model
	virtual int helloResponse (void);

	// Called from the "GOODBYE_REQUEST" by the SharedAppMgr
	virtual int closeSimulation(void);

	// Send a "GOODBYE_REQUEST" to the job
	virtual int stopSimulation(void);

	// Send a "STATUS_REQUEST" to the job
	virtual int requestJobStatus(void);

	// output my state!
	friend ostream& operator<<(ostream& output, const AppBase& p);

	// save off the current state
	//void toDB(const std::string& modelName);

	template<class Archive>
	void serialize(Archive & ar, const unsigned int )
	{
		ACE_UINT64 sys_time_usec;
		ACE_OS::gettimeofday().to_usec(sys_time_usec);
		ar & BOOST_SERIALIZATION_NVP(sys_time_usec);

		ar & BOOST_SERIALIZATION_NVP(model_id_);
		ar & BOOST_SERIALIZATION_NVP(unit_id_);
		ar & BOOST_SERIALIZATION_NVP(node_id_);
		ar & BOOST_SERIALIZATION_NVP(run_id_);
		ar & BOOST_SERIALIZATION_NVP(app_key_);
		ar & BOOST_SERIALIZATION_NVP(send_count_);
	}

	void toDB (const std::string& modelName)
	{
		std::string sql;
		{
			sql_oarchive oa(sql, "AppBase");
			oa & boost::serialization::make_nvp(modelName.c_str(), *this);
		}
		Samson_Peer::SAMSON_OBJMGR::instance()->doRunQuery(sql);
	}


	void toXML (std::stringstream &ofs) const
	{
		boost::archive::xml_oarchive oa(ofs,7);
		oa << BOOST_SERIALIZATION_NVP(this);
	}


	void toText (std::stringstream &ofs) const
	{
		boost::archive::xml_oarchive oa(ofs,7);
		oa << BOOST_SERIALIZATION_NVP(this);
		//boost::archive::text_oarchive oa(ofs);
		//oa << *this;
	}

	virtual unsigned int current_frame (void) { return 0; }
	virtual bool data_ready (void) { return true; }

protected:

	// For now store information that is in the ObjectManager
	// Look at simplifying later
	unsigned int model_id_;
	unsigned int unit_id_;
	unsigned int node_id_;
	unsigned int run_id_;
	std::string  app_key_;
	std::string  input_file_name_;

	// The list of job-peers
	SamsonPeerData *spd_;

	//  Can I accept input fromt the keyboard
	bool stdin_registered_;

	// Number of Peers (not sure what I use this for)
	int npeers_;

	// Save the state information
	bool save_state_;

	// Current message sent count (our internal counter)
	unsigned int send_count_;

	// Print the list of job-peers
	void printJobPeerList();

	// send a generic control message to the attached dispatcher
	int sendCtrlMsg(int type, unsigned int flag);

	// .............
	int sendMsgOnCID (int cid, const char  *msg, unsigned int len);
};

} // namespace

#endif
