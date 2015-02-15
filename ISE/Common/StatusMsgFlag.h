/**
 *	@class StatusMsgFlag
 *
 *	@brief Bit Flag for Header field, overloasts SimMsgFlags
 *
 *	This holds a bit field
 *
 *	@note Attempts at zen rarely work.
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef STATUSMSGFLAG_H_
#define STATUSMSGFLAG_H_

class SimMsgFlag
{
public:

	enum {
		log_model = 0x0001,
		log_dispatcher = 0x0002,
		log_sender = 0x0004,
		log_master = 0x0008,
		
	};
};

#endif /*STATUSMSGFLAG_H_*/
