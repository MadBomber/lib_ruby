/**
 *	@file StartFrame.h
 *
 *	@brief
 * 		Used to begin a compute frame
 * 		Based upon work by Ben Atakora
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef _STARTFRAME_H
#define _STARTFRAME_H

#include "DatalessMessage.h"

class ISE_Export StartFrame : public Samson_Peer::DatalessMessage
{
	public:
		StartFrame() : DatalessMessage(std::string("StartFrame"),std::string("Start a compute frame"))
		{
		}
		~StartFrame(){}
};

#endif
