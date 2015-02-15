/**
 *	@file InitCaseComplete.h
 *
 *	@class InitCaseComplete
 *
 *	@brief
 * 		Used to initialize the montel carlo loop, this is a bootstrap message
 * 		It will be replaced very shortly
 * 		Based upon work by Ben Atakora
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>, (C) 2006
 *
 */

#ifndef _COMPLETE_HPP
#define _COMPLETE_HPP

#include "DatalessMessage.h"

class ISE_Export InitCaseComplete : public Samson_Peer::DatalessMessage
{
	public:
		InitCaseComplete() : DatalessMessage(std::string("InitCaseComplete"), std::string("Initialize Case Completed")) {}
		~InitCaseComplete(){}
};

#endif
