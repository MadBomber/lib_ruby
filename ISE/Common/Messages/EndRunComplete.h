/**
 *	@file EndRunComplete.h
 *
 *	@brief
 * 		Used to indicate the endmontel carlo case processing is complete
 * 		Based upon work by Ben Atakora
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>, (C) 2006
 *
 */


#ifndef _ENDRUNCOMPLETE_H
#define _ENDRUNCOMPLETE_H

#include "DatalessMessage.h"

class ISE_Export EndRunComplete : public Samson_Peer::DatalessMessage
{
	public:
		EndRunComplete() : DatalessMessage(std::string("EndRunComplete"), std::string("End Run Completed")) {}
		~EndRunComplete(){}
};


#endif
