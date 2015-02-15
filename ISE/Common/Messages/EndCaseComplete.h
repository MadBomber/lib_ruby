/**
 *	@file EndCaseComplete.h
 *
 *	@class SamsonModel
 *
 *	@brief
 * 		Used to indicate the end of a monte carlo case
 * 		Based upon work by Ben Atakora
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */



#ifndef _ENDCASECOMPLETE_H
#define _ENDCASECOMPLETE_H

#include "ISEExport.h"
#include "DatalessMessage.h"

class ISE_Export EndCaseComplete : public Samson_Peer::DatalessMessage
{
	public:
		EndCaseComplete() : DatalessMessage(std::string("EndCaseComplete"), std::string("End Case Completed")) {}
		~EndCaseComplete(){}
};

#endif
