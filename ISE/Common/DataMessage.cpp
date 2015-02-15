/**
 *	@file DataMessage.cpp
 *
 *	@class DataMessage
 *
 *	@brief Virtual classs that sets the structure for user-defined messages
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#define ISE_BUILD_DLL

#include "DataMessage.h"
#include "Options.h"

#include <sstream>

#include "ace/Message_Block.h"
#include "ace/Log_Msg.h"


namespace Samson_Peer {

// TODO  Verify this
//bool MessageBase::debug_ = false;

//...................................................................................................
DataMessage::DataMessage() : MessageBase()
{
	ACE_TRACE("DataMessage::DataMessage (void)");

	this->obj_ptr = 0;
	this->obj_ptr_len = 0;
}

//...................................................................................................
DataMessage::DataMessage(std::string key, std::string description) : MessageBase (key,description)
{
	ACE_TRACE("DataMessage::DataMessage (key)");

	this->obj_ptr = 0;
	this->obj_ptr_len = 0;
}

//...................................................................................................
DataMessage::~DataMessage()
{
	ACE_TRACE("DataMessage::~DataMessage");


}

//...................................................................................................
bool
DataMessage::de_marshall (void *ptr, size_t len)
{
	ACE_TRACE("DataMessage::de_marshall");

	if ( len == obj_ptr_len )
	{
		ACE_OS::memcpy (obj_ptr, ptr, len);  // is this memory copy is required?
		return true;
	}
	else
	{
		ACE_DEBUG ((LM_ERROR, "DataMessage::de_marshall() error was %d bytes, supposed to be %d bytes\n",
					len, this->obj_ptr_len));
		return false;
	}
}


//...................................................................................................
ACE_Message_Block *
DataMessage::marshall()
{
	ACE_TRACE("DataMessage::marshall");

	// Allocate a new Message_Block for sending this message
	ACE_Message_Block *data_mb =
		new ACE_Message_Block (
			this->obj_ptr_len,
			ACE_Message_Block::MB_DATA,
			0,
			0,
			0,
			0);

	if (data_mb == 0 )
		ACE_ERROR_RETURN ((LM_ERROR, "MessageBase::marshall() -> Data Messsage_Block Allocation Error\n"), 0);

	// copy the data into the message block  (costly?)  !!! this sets the mb length!!!!!
	if ( data_mb->copy( (const char *)this->obj_ptr,this->obj_ptr_len) == -1 )
		ACE_ERROR_RETURN ((LM_ERROR, "MessageBase::marshall() -> Data Copy Error\n"), 0);

	return data_mb;
}

}  // namespace

