/**
 *	@file InitCase.h
 *
 *	@class SamsonModel
 *
 *	@brief
 * 		Used to initialize the montel carlo loop, this is a bootstrap message
 * 		It will be replaced very shortly
 * 		Based upon work by Ben Atakora
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */


#ifndef _INITCASE_H
#define _INITCASE_H

#include "ISEExport.h"
#include "XmlObjMessage.h"

struct ISE_Export InitCase : public XmlObjMessage<InitCase>
{
	InitCase (void) : XmlObjMessage<InitCase>(std::string("InitCase"), std::string("Initialize Case")) {}

	#define ITEMS \
	ITEM(ACE_INT32,		case_number_) \
	ITEM(bool,			separate_advance_time_) \
	ITEM(bool,			send_end_frame_)
	#include "messages.inc"

};

#endif
