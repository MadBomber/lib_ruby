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

#ifndef _ENDFRAME_H
#define _ENDFRAME_H

#include "DatalessMessage.h"

class ISE_Export EndFrame : public Samson_Peer::DatalessMessage
{
	public:
		EndFrame() : DatalessMessage(std::string("EndFrame"),std::string("Model has reached the end of compute frame"))
		{
		}
		~EndFrame(){}
};

#endif
