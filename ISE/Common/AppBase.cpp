/**
 *	@file AppBase.cpp
 *
 *	@brief Base File for all Samson Models
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>  2006
 *
 */

#define ISE_BUILD_DLL

#include "AppBase.h"
#include "DebugFlag.h"
#include "SamsonHeader.h"
#include "SharedAppMgr.h"
#include "Model_ObjMgr.h"
#include "MessageFunctor.hpp"

#include <sstream>
#include <string>

#include "ace/Reactor.h"
#include "ace/Thread_Manager.h"

// used to get the command line
#include "ace/Get_Opt.h"


namespace Samson_Peer {


//...................................................................................................
AppBase::AppBase() // : ACE_Service_Object()

{
	ACE_TRACE("AppBase::AppBase");

	this->stdin_registered_ = false;
	this->save_state_ = false;
	this->send_count_ =0;

	// This is a duplication for speed
	this->run_id_   = SAMSON_OBJMGR::instance()->RunID ();
	this->model_id_ = SAMSON_OBJMGR::instance()->ModelID ();
	this->unit_id_  = SAMSON_OBJMGR::instance()->UnitID ();
	this->node_id_  = SAMSON_OBJMGR::instance()->NodeID ();
	this->app_key_  = SAMSON_OBJMGR::instance()->AppKey ();

	this->input_file_name_ = "NOT SPECIFIED";

	if (DebugFlag::instance ()->enabled (DebugFlag::APB_DEBUG) )
	{
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) Appbase::AppBase() constructor completed\n"));
	}
}

//...................................................................................................
AppBase::~AppBase()
{
	ACE_TRACE("AppBase::~AppBase");
	//SAMSON_OBJMGR::instance()->unsubscribe();
}

//...................................................................................................
int AppBase::init(int argc, ACE_TCHAR *argv[])
{
	ACE_TRACE("AppBase::init");


	ACE_Get_Opt get_opt (argc, argv, ACE_TEXT("f:s"), 0);

	// pull the number of models to control from the command line
	for (int c; (c = get_opt ()) != -1; )
	{
		switch (c)
		{
			case 'f':
				this->input_file_name_ = get_opt.opt_arg ();
			break;

			case 's':
				this->save_state_ = true;
			break;
		}
	}

	SAMSON_OBJMGR::instance ()->setReady ();

	return 1;
}

//...................................................................................................
int AppBase::fini(void)
{
	ACE_TRACE("AppBase::fini");

	ACE_DEBUG ((LM_DEBUG, "(%P|%t) AppBase::fini() not overidden\n"));
	return 0;
}

//...................................................................................................
int AppBase::info (ACE_TCHAR **info_string, size_t length) const
{
	std::stringstream myinfo;
	myinfo << *this;
	//this->toText(myinfo);

	if (*info_string == 0)
		*info_string = ACE::strnew(myinfo.str().c_str());
	else
		ACE_OS::strncpy(*info_string, myinfo.str().c_str(), length);

	return ACE_OS::strlen(*info_string) +1;
}

//...................................................................................................
ostream& operator<<(ostream& output, const AppBase& p)
{
    output << "AppBase:: "
    	<< "Model: " << p.model_id_
    	<< " Unit: " << p.unit_id_
 		<< " Node: " << p.node_id_
 		<< " Job: "  << p.run_id_
 		<< " Key: "  << p.app_key_
 		<< " input file: " << p.input_file_name_
    	<< " State: " << ((p.save_state_)?"true":"false");

	return output;
}

//...................................................................................................
void
AppBase::setJobPeerList()
{
	this->spd_ = SAMSON_APPMGR::instance()->getRunPeerList(this->npeers_);   // TODO passing a ref ICK!!!!
}

//...................................................................................................
void
AppBase::printJobPeerList()
{
	for (int i=0; i< this->npeers_; ++i) this->spd_[i].print();
}

//...................................................................................................
//.. Get the Key for a given Model (used for debugging)
// TODO  re-evaluate this
char *
AppBase::getAppKey(unsigned int id)
{
	// make it use SamsonPeerData soon
	static char name[32];
	SAMSON_OBJMGR::instance()->getModelKey (id, name);
	return name;
}

//...................................................................................................
//.. This is to call a model just after the "HELLO" exchange
int AppBase::helloResponse(void)
{
	ACE_TRACE("AppBase::helloResponse");

//	static bool warned = false;
//	if ( !warned)
	if (DebugFlag::instance ()->enabled (DebugFlag::APB_DEBUG) )
	{
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) AppBase::helloResponse() was not overridden\n"));
//		warned = true;
	}
	return 0;
}

//...................................................................................................
//.. This is to call a model just after the "GOODBYE_REQUEST"
int AppBase::closeSimulation(void)
{
	this->sendCtrlMsg (SimMsgType::GOODBYE, SimMsgFlag::nowhere);
	ACE_OS::sleep(1);
	ACE_Reactor::instance ()->end_reactor_event_loop ();
	return 0;
}

//...................................................................................................
//.. This is to send a "GOODBYE_REQUEST" to the job
int AppBase::stopSimulation(void)
{
	this->sendCtrlMsg (SimMsgType::GOODBYE_REQUEST, SimMsgFlag::job);
	return 0;
}

//...................................................................................................
//.. This is to send a "STATUS_REQUEST" to the job
int AppBase::requestJobStatus(void)
{
	this->sendCtrlMsg (SimMsgType::STATUS_REQUEST, SimMsgFlag::job|SimMsgFlag::status_log_local);
	return 0;
}

//...................................................................................................
//.. This is to send a generic request to the dispatcher
int AppBase::sendCtrlMsg (int type, unsigned int flag)
{
	return SAMSON_APPMGR::instance()->sendCtrlMsg (type, flag);
}

//...................................................................................................
//..
int AppBase::sendMsgOnCID (int cid, const char  *msg, unsigned int len)
{
	return SAMSON_APPMGR::instance()->sendMsgOnCID (cid, msg, len);
}

} // namespace
