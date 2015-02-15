/**
 *	@file DataMessage.h
 *
 *	@class DataMessage
 *
 *	@brief Base Class for all user-defined Data Messages
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef DataMessage_H
#define DataMessage_H

#include "MessageBase.h"

class ACE_Message_Block;

namespace Samson_Peer {

// ===========================================================================
class ISE_Export DataMessage : public MessageBase {
public:

	DataMessage();
	DataMessage(std::string appMsgKey, std::string description);
	virtual ~DataMessage();

	virtual ACE_Message_Block *marshall();
	virtual bool de_marshall(void *, size_t);

protected:

	//..............  data exchange:  not object
	void *obj_ptr;
	// Holds the current message  (for "data transfer")

	size_t obj_ptr_len;
	// Holds the length of the current message (for "data transfer")
};

} // Namespace
#endif
