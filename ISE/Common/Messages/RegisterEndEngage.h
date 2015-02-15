/**
 *	@file EndFrame.h
 *
 *	@brief
 * 		Used end a compute frames
 * 		Based upon work by Ben Atakora
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef _REGISTER_END_H
#define _REGISTER_END_H

#include "ISE.h"
#include "DatalessMessage.h"

class ISE_Export RegisterEndEngage : public Samson_Peer::DatalessMessage
{
	public:
		RegisterEndEngage() : DatalessMessage(std::string("RegisterEndEngage"),std::string("Model is registering to send and End of Engagement"))
		{
		}
		~RegisterEndEngage(){}
};

#endif // _REGISTER_END_H
