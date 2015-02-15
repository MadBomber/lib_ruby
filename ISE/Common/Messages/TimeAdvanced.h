/**
 *	@file TimeAdvanced.h
 *
 *	@brief
 * 		Response to advance time (pre-fire)
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>, (C) 2006
 *
 */

#ifndef _TIMEADVANCED_H
#define _TIMEADVANCED_H

#include "DatalessMessage.h"

class ISE_Export TimeAdvanced : public Samson_Peer::DatalessMessage
{

	public:
		TimeAdvanced() : DatalessMessage(std::string("TimeAdvanced"),std::string("Time was Advanced")){}
		~TimeAdvanced(){}
};

#endif
