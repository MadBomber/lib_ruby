/**
 *	@file AdvanceTime.h
 *
 *	@class AdvanceTime
 *
 *	@brief
 * 		Used to advance time (pre-fire)
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef _ADVANCETIME_H
#define _ADVANCETIME_H

#include "DatalessMessage.h"

class ISE_Export AdvanceTime : public Samson_Peer::DatalessMessage
{

	public:
		AdvanceTime() : DatalessMessage(std::string("AdvanceTime"),std::string("Advance Time")){}
		~AdvanceTime(){}
};

#endif
