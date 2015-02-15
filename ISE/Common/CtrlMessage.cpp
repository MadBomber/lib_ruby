/**
 *	@file CtrlMessage.cpp
 *
 *	@class CtrlMessage
 *
 *	@brief Dataless MEssage
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#define ISE_BUILD_DLL

#include "CtrlMessage.h"
#include "Options.h"

#include <sstream>

#include "ace/Message_Block.h"
#include "ace/Log_Msg.h"

namespace Samson_Peer {

// TODO  Verify this
//bool MessageBase::debug_ = false;

//...................................................................................................
CtrlMessage::CtrlMessage() : MessageBase()
{
	ACE_TRACE("CtrlMessage::CtrlMessage (void)");
	this->msg_type_ = SimMsgType::CONTROL;
}

//...................................................................................................
CtrlMessage::CtrlMessage(std::string key, std::string description) : MessageBase (key,description)
{
	ACE_TRACE("CtrlMessage::CtrlMessage (key)");
	this->msg_type_ = SimMsgType::CONTROL;
}

//...................................................................................................
CtrlMessage::~CtrlMessage()
{
	ACE_TRACE("CtrlMessage::~CtrlMessage");
}

//...................................................................................................
bool
CtrlMessage::de_marshall (void *, size_t)
{
	ACE_TRACE("CtrlMessage::de_marshall");
	return true;
}


//...................................................................................................
ACE_Message_Block *
CtrlMessage::marshall()
{
	ACE_TRACE("CtrlMessage::marshall");
	return 0;
}

}  // namespace

