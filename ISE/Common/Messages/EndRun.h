/**
 *	@file EndRun.h
 *
 *	@class EndRun
 *
 *	@brief
 * 		Used to end a montel carlo loop
  * 		Based upon work by Ben Atakora
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */


#ifndef _ENDRUN_H
#define _ENDRUN_H


#include "DatalessMessage.h"

class ISE_Export EndRun : public Samson_Peer::DatalessMessage
{
	public:
		EndRun() : DatalessMessage(std::string("EndRun"), std::string("End Run Command")) {}
		~EndRun(){}
};

#endif
