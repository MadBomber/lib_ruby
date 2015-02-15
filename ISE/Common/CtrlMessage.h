/**
 *	@file CtrlMessage.h
 *
 *	@class CtrlMessage
 *
 *	@brief  Dataless control message
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef CtrlMessage_H
#define CtrlMessage_H

#include "MessageBase.h"

class ACE_Message_Block;

namespace Samson_Peer {

// ===========================================================================
class ISE_Export CtrlMessage : public MessageBase {
public:

	CtrlMessage();
	CtrlMessage(std::string appMsgKey, std::string description);
	virtual ~CtrlMessage();

	virtual ACE_Message_Block *marshall();
	virtual bool de_marshall(void *, size_t);
};

} // Namespace
#endif
