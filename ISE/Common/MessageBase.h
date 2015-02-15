/**
 *	@file MessageBase.cpp
 *
 *	@class AppBase
 *
 *	@brief Virtural Base Class for all user-defined messages
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef MessageBase_H
#define MessageBase_H

#include "ISE.h"
#include "Functor.h"
#include "SamsonHeader.h"
#include "SimMsgFlag.h"
#include "SimMsgType.h"

#include <string>


// Forward Declaration (rethink)
class ACE_Message_Block;

#include "SamsonHeader.h"

namespace Samson_Peer {

// ===========================================================================
class ISE_Export MessageBase {
public:

	MessageBase();
	MessageBase(std::string appMsgKey, std::string description);
	virtual ~MessageBase();

	int info (ACE_TCHAR **strp, size_t length) const;

	int handle_event ( const ACE_Message_Block * const mb, const SamsonHeader * const sh);

	int registerToPublish (void);
	void unregisterToPublish (int);

	int subscribe (Functor *afunctor,int unitID=0);
	//int publish (unsigned int frame, unsigned int send_count, unsigned int unitID=0, unsigned int flag=0, unsigned int dest=0);
	int publish (unsigned int frame, unsigned int send_count, unsigned int unitID=0);
	int publish (SamsonHeader *);

	void print(void);

	virtual ACE_Message_Block *marshall() = 0;
	virtual bool de_marshall(void *, size_t) = 0;

	SamsonHeader *get_header() const { return header_; }

//protected:

	int run_msg_id_;
	// This is obtained from a registerToPublish  (SQL:  Message.ID)

	int app_msg_id_;
	// This is the Application Specific Message ID
	// It is created from the Application Unique Message Key
	// (SQL: AppMessage.ID,  foreign key at Message.AppMsgID )

	int msg_type_;
	// This is the message type, defaults to SimMsgType::DATA

	int msg_flag_mask_;
	// This is the default mask that this message will be XOR'd with to create, defaults to 0;

	std::string app_msg_key_;
	// This is an Application Unique Message Key
	// (SQL: AppMessage.AppMessageKey )

	std::string description_;
	// This is a description of this event

	//const SamsonHeader *header_;
	SamsonHeader *header_;
	// Holds the current Samson Message header

private:


	int publishToPeer(unsigned int modelID, unsigned int type = SimMsgType::DATA, unsigned int count=0);
	// candidate for deletion

	void setFunctor(const Functor *afunctor);
	Functor *mfunctor;
	// Function Object
};

} // Namespace
#endif
