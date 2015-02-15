/*
 * DatalessMessage.h
 *
 *  Created on: Jun 24, 2009
 *      Author: lavender
 */


#ifndef DATALESSMESSAGE_H_
#define DATALESSMESSAGE_H_

#include "MessageBase.h"

class ACE_Message_Block;

namespace Samson_Peer {

// ===========================================================================
class ISE_Export DatalessMessage : public MessageBase {
public:

	DatalessMessage () : MessageBase () {}
	DatalessMessage (std::string appMsgKey, std::string description) : MessageBase (appMsgKey, description)
	{
		this->msg_type_ = SimMsgType::DATA;
		this->msg_flag_mask_ =  SimMsgFlag::control;
	}
	virtual ~DatalessMessage () {}

	virtual ACE_Message_Block *marshall () { return 0; }
	virtual bool de_marshall (void *, size_t) { return true; }
};

} // Namespace

#endif /* DATALESSMESSAGE_H_ */
