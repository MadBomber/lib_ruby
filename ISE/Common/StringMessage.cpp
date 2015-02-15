/*
 * StringMessages.cpp
 *
 *  Created on: Mar 25, 2010
 *      Author: lavender
 */


/**
 *	@file StringMessage.cpp
 *
 *	@class StringMessage
 *
 *	@brief Virtual classs that sets the structure for user-defined messages
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#define ISE_BUILD_DLL

#include "StringMessage.h"
#include "Options.h"

#include <sstream>

#include "ace/Message_Block.h"
#include "ace/Log_Msg.h"


namespace Samson_Peer {

// TODO  Verify this
//bool MessageBase::debug_ = false;

//...................................................................................................
StringMessage::StringMessage() : MessageBase()
{
	ACE_TRACE("StringMessage::StringMessage (void)");
}

//...................................................................................................
StringMessage::StringMessage(std::string key, std::string description) : MessageBase (key,description)
{
	ACE_TRACE("StringMessage::StringMessage (key)");
}

//...................................................................................................
StringMessage::~StringMessage()
{
	ACE_TRACE("StringMessage::~StringMessage");
}

//...................................................................................................
bool
StringMessage::de_marshall (void *ptr, size_t len)
{
	ACE_TRACE("StringMessage::de_marshall");

		// we are "assuming that inputs are a string
		message_.assign ( (const char *)(ptr), len);
		return true;
}


//...................................................................................................
ACE_Message_Block *
StringMessage::marshall()
{
	ACE_TRACE("StringMessage::marshall");

	// Allocate a new Message_Block for sending this message
	ACE_Message_Block *data_mb =
		new ACE_Message_Block (
			message_.length(),
			ACE_Message_Block::MB_DATA,
			0,
			0,
			0,
			0);

	if (data_mb == 0 )
		ACE_ERROR_RETURN ((LM_ERROR, "MessageBase::marshall() -> Data Messsage_Block Allocation Error\n"), 0);

	// copy the data into the message block  (costly?)  !!! this sets the mb length!!!!!
	if ( data_mb->copy( message_.c_str(), message_.length() ) == -1 )
		ACE_ERROR_RETURN ((LM_ERROR, "MessageBase::marshall() -> Data Copy Error\n"), 0);

	return data_mb;
}

}  // namespace

