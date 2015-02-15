/**
 *	@file MessageBase.cpp
 *
 *	@brief Virtual classs that sets the structure for user-defined messages
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#define ISE_BUILD_DLL

#include "MessageBase.h"
#include "SharedAppMgr.h"
#include "DebugFlag.h"
#include "Model_ObjMgr.h"
#include "SamsonHeader.h"

#include <sstream>

#include "ace/Message_Block.h"



namespace Samson_Peer {

//...................................................................................................
MessageBase::MessageBase() :
	run_msg_id_(0),app_msg_id_(0),msg_type_(SimMsgType::DATA),msg_flag_mask_(0),
	app_msg_key_("UNK"),description_("Unknown"),header_(0), mfunctor(0)
{
}

//...................................................................................................
MessageBase::MessageBase(std::string key, std::string description) :
	run_msg_id_(0),msg_type_(SimMsgType::DATA),msg_flag_mask_(0),header_(0), mfunctor(0)
{
	this->app_msg_id_ = SAMSON_OBJMGR::instance()->getUniqueAppID(key.c_str(), description.c_str());
	this->app_msg_key_ = key;
	this->description_ = description;
}

//...................................................................................................
MessageBase::~MessageBase()
{
	if(mfunctor)
		delete mfunctor;
}

//TODO messages, subscribers, appmessages not being removed from database ? get each model to unRegisterToPublish/unSubscribe

//...................................................................................................
int
MessageBase::info (ACE_TCHAR **strp, size_t length) const
{
	ACE_TCHAR buf[BUFSIZ];

	ACE_OS::sprintf(buf,"SID:%5d AID:%5d Key:%32s Descr:%s", run_msg_id_, app_msg_id_, app_msg_key_.c_str(), description_.c_str());

	if (*strp == 0 && (*strp = ACE_OS::strdup (buf)) == 0)
		return -1;
	else
		ACE_OS::strncpy (*strp, buf, length);
	return ACE_OS::strlen (buf);
}


//...................................................................................................
//  must return 0 to continue on!
int
MessageBase::handle_event ( const ACE_Message_Block * const mb, const SamsonHeader * const sh)
{
	int retval = -1;  // this will cause the connection to close
	this->header_ = const_cast<SamsonHeader *>(sh);

	if (mb)
	{
		ACE_Message_Block *msg_data = const_cast<ACE_Message_Block *>(mb);

		//ACE_DEBUG ((LM_ERROR, "(%P|%t)  de-marshall (%x)->(%x) \n", this, this->header_));
		bool result = this->de_marshall( msg_data->base(), msg_data->length());

		if ( !result )
		{
			ACE_DEBUG ((LM_DEBUG, "(%P|%t) MessageBase::handle_event(%D) -> de_marshall error\n"));
			sh->print();
			ACE_LOG_MSG->log_hexdump (LM_DEBUG,(char *) msg_data->base(), msg_data->length());
			return 0;
		}
		//ACE_DEBUG ((LM_ERROR, "(%P|%t)  Header valid (%x)->(%x) \n", this, this->header_));
	}

	if(mfunctor)
	{
		if (DebugFlag::instance ()->enabled (DebugFlag::APB_DEBUG) )
			ACE_DEBUG ((LM_DEBUG, "(%P|%t) MessageBase::handle_event(%D) -> %s\n",this->app_msg_key_.c_str()));
		retval = (*mfunctor) (this);         // call operator()(MessageBase *)
	}
	else
		ACE_DEBUG ((LM_ERROR, "(%P|%t) MessageBase::handle_event(%D) -> ERROR no call to be made\n"));

	this->header_ = 0;  // only valid during this call
	//ACE_DEBUG ((LM_ERROR, "(%P|%t)  Header invalid (%x)->(%x) \n", this, this->header_));

	return retval;
}

//...................................................................................................
int
MessageBase::registerToPublish (void)
{
	// This registers with the master database  (either this or subscribe is called)
	this->run_msg_id_ = SAMSON_OBJMGR::instance()->RegisterToPublish(this->app_msg_id_);

	return this->run_msg_id_;
}

//...................................................................................................
void
MessageBase::unregisterToPublish (int a_run_msg_id)
{
	SAMSON_OBJMGR::instance()->unRegisterPublish(a_run_msg_id);
}


//...................................................................................................
int
MessageBase::subscribe(Functor *afunctor,int unitID)
{
	// set functor object
	setFunctor(afunctor);

	// This registers with the master database
	this->run_msg_id_ = SAMSON_OBJMGR::instance()->Subscribe(this->app_msg_id_, unitID);

	// This registers with the App Manager
	if ( SAMSON_APPMGR::instance()->registerProcess (this->app_msg_id_, this) != 0 )
	{
		ACE_DEBUG ((LM_ERROR, "(%P|%t) MessageBase::subscribe failed to bind for %s app=%d msg=%d uid=%d functor=%x\n",
			this->app_msg_key_.c_str(), this->app_msg_id_, this->run_msg_id_, unitID, afunctor));
	}

	return this->run_msg_id_;
}

//...................................................................................................
/*
int
MessageBase::publish(unsigned int current_frame, unsigned int send_count,
	unsigned int unitID, unsigned int flag, unsigned int dest)
{
	int retval = -1;

	if ( this->run_msg_id_ == 0 ) this->registerToPublish();


	if ( this->run_msg_id_ > 0 )
	{
		//  This allows us to cheat by being someone else
		int theUnitID = (unitID > 0)? unitID : SAMSON_OBJMGR::instance()->UnitID ();

		// allocated a header
		SamsonHeader *sh = new SamsonHeader();

		// required for storing the header out in the database!!!!
		this->header_ = const_cast<SamsonHeader *>(sh);

		//  Where is the best place to get these  from here
		sh->run_id (SAMSON_OBJMGR::instance()->RunID ());
		sh->peer_id (SAMSON_OBJMGR::instance()->ModelID ());
		sh->unit_id (theUnitID);

		sh->message_id (this->run_msg_id_);
		sh->app_msg_id (this->app_msg_id_);

		// set the message type
		sh->type (this->msg_type_);

		// set the bit flags
		sh->bit_flags(flag);

		// set the destination
		sh->dest_peer_id(dest);

		sh->frame_count(current_frame);
		sh->send_count(send_count);

		// Marshall the data
		ACE_Message_Block *data_mb = this->marshall();

		// set the header's data length
		if ( data_mb == 0 )
			sh->data_length(0);
		else
			sh->data_length(data_mb->length());

		// send the message
		retval = SAMSON_APPMGR::instance()->publish (data_mb, sh);
	}
	else
	{
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) MessageBase::publish() failed due to negative message id\n"));
		this->print();
	}

	return retval;
}
*/

//...................................................................................................
int
MessageBase::publish(unsigned int current_frame, unsigned int send_count, unsigned int unitID)
{
	int retval = -1;

	if ( this->run_msg_id_ == 0 ) this->registerToPublish();


	if ( this->run_msg_id_ > 0 )
	{

		if (DebugFlag::instance ()->enabled (DebugFlag::APB_DEBUG) )
			ACE_DEBUG ((LM_DEBUG, "(%P|%t) MessageBase::publish() -> %s\n",this->app_msg_key_.c_str()));

		//  This allows us to cheat by being someone else
		int theUnitID = (unitID > 0)? unitID : SAMSON_OBJMGR::instance()->UnitID ();

		// allocated a header
		SamsonHeader *sh = new SamsonHeader();

		// required for storing the header out in the database!!!!
		this->header_ = const_cast<SamsonHeader *>(sh);

		//  Where is the best place to get these  from here
		sh->run_id (SAMSON_OBJMGR::instance()->RunID ());
		sh->peer_id (SAMSON_OBJMGR::instance()->ModelID ());
		sh->unit_id (theUnitID);

		sh->message_id (this->run_msg_id_);
		sh->app_msg_id (this->app_msg_id_);

		// set the message type
		sh->type (this->msg_type_);

		// set the bit flags
		sh->bit_flags(msg_flag_mask_);

		// set the destination
		sh->dest_peer_id(0);

		sh->frame_count(current_frame);
		sh->send_count(send_count);

		// Marshall the data
		ACE_Message_Block *data_mb = this->marshall();

		// set the header's data length
		if ( data_mb == 0 )
			sh->data_length(0);
		else
			sh->data_length(data_mb->length());

		// send the message
		retval = SAMSON_APPMGR::instance()->publish (data_mb, sh);
	}
	else
	{
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) MessageBase::publish() failed due to negative message id\n"));
		this->print();
	}

	return retval;
}


//...................................................................................................
int
MessageBase::publish(SamsonHeader *sh)
{
	int retval = -1;

	if ( this->run_msg_id_ == 0 ) this->registerToPublish();


	if ( this->run_msg_id_ > 0 )
	{
		// required for storing the header out in the database!!!!
		this->header_ = const_cast<SamsonHeader *>(sh);

		// this is ONLY known inside of the MessageBase object!!!
		sh->message_id (run_msg_id_);
		sh->app_msg_id (app_msg_id_);

		sh->type (this->msg_type_);
		sh->enable (this->msg_flag_mask_);

		// Marshall the data
		ACE_Message_Block *data_mb = this->marshall();

		// set the header's data length
		if ( data_mb == 0 )
			sh->data_length(0);
		else
			sh->data_length(data_mb->length());

		if (DebugFlag::instance ()->enabled (DebugFlag::APB_DEBUG) )
			ACE_DEBUG ((LM_DEBUG, "(%P|%t) MessageBase::publish() -> %s (%x == %x)\n",
					this->app_msg_key_.c_str(), this->msg_flag_mask_, sh->bit_flags()));

		// send the message
		retval = SAMSON_APPMGR::instance()->publish (data_mb, sh);
	}
	else
	{
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) MessageBase::publish() failed due to negative message id\n"));
		this->print();
	}

	return retval;
}


//...................................................................................................
int
MessageBase::publishToPeer(unsigned int destModelID, unsigned int type, unsigned int count)
{
	int retval = -1;

	if ( this->run_msg_id_ == 0 ) this->registerToPublish();

	if ( this->run_msg_id_ > 0 )
	{
		// allocated a header
		SamsonHeader *sh = new SamsonHeader();

		// required for storing the header out in the database!!!!
		this->header_ = const_cast<SamsonHeader *>(sh);

		//  Where is the best place to get these ?
		sh->run_id (SAMSON_OBJMGR::instance()->RunID ());
		sh->peer_id (SAMSON_OBJMGR::instance()->ModelID ());
		sh->unit_id (SAMSON_OBJMGR::instance()->UnitID ());  // cannot fake out unit here

		sh->message_id (run_msg_id_);
		sh->app_msg_id (app_msg_id_);

		//  make this a peer-to-peer message
		sh->dest_peer_id(destModelID);

		//  set the proper flags for a p2p message
		sh->bit_flags(SimMsgFlag::p2p);

		// set the message type
		sh->type (type);

		// Marshall the data
		ACE_Message_Block *data_mb = this->marshall();
		if ( data_mb == 0 ) return -1;

		// set the header's data length
		sh->data_length(data_mb->length());

		// used for framecount
		sh->frame_count(count);

		// send the message
		retval = SAMSON_APPMGR::instance()->publish (data_mb, sh);
	}
	else
	{
		ACE_DEBUG ((LM_ERROR, "(%P|%t) MessageBase::publishToPeer() failed due to negative message id\n"));
		this->print();
	}

	return retval;
}

//...................................................................................................
void
MessageBase::print(void)
{
	ACE_DEBUG ((LM_INFO, "(%P|%t) MessageBase -> id=%d -> %d \"%s\"\n",
			run_msg_id_, app_msg_id_, app_msg_key_.c_str() ));
}

//...................................................................................................
void MessageBase::setFunctor(const Functor *afunctor)
{
	//if ( mfunctor != afunctor)
	{
		Functor *temp;
		temp = afunctor->clone();
		delete mfunctor;
		mfunctor = temp;
	}
}

}  // namespace

