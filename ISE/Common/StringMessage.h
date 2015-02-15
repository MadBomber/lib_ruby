/*
 * StringMessage.h
 *
 *  Created on: Mar 25, 2010
 *      Author: lavender
 */

#ifndef STRINGMESSAGE_H_
#define STRINGMESSAGE_H_

#include "MessageBase.h"

namespace Samson_Peer {

// ===========================================================================
class ISE_Export StringMessage : public MessageBase {
public:

	StringMessage();
	StringMessage(std::string appMsgKey, std::string description);
	virtual ~StringMessage();

	virtual ACE_Message_Block *marshall();
	virtual bool de_marshall(void *, size_t);

protected:

	//..............  data exchange:  not object
	std::string message_;
	// Holds the current message  (for "data transfer")
};

} // namespace

#endif /* STRINGMESSAGE_H_ */
