/**
 *	@file EndCase.h
 *
 *	@class SamsonModel
 *
 *	@brief
 * 		Used to indicate the end of a monte carlo case
 * 		Based upon work by Ben Atakora
 *
 */



#ifndef _ENDCASE_H
#define _ENDCASE_H


#include "ISEExport.h"
#include "XmlObjMessage.h"

struct ISE_Export EndCase : public XmlObjMessage<EndCase>
{
	EndCase (void) : XmlObjMessage<EndCase>(std::string("EndCase"), std::string("End Case Command")) {}

	#define ITEMS \
	ITEM(ACE_INT32,		case_number_)
	#include "messages.inc"

};

#endif
