/**
 *	@file EventHeaderFactory.h
 * 
 *	@class EventHeaderFactory
 * 
 *	@brief Factory to create a simulation header
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#define ISE_BUILD_DLL
#include "EventHeaderFactory.h"
#include "DataCountHeader.h"
#include "NoHeader.h"
#include "SamsonHeader.h"

// ============================================================================
EventHeader *
EventHeaderFactory::get (int type)
{
	return this->factories[type]->createInstance();
}

// ============================================================================
int
EventHeaderFactory::lookup (const char *val )
{
	std::string sval(val);
	return (header_string.find(sval) !=  header_string.end() ) ? header_string[sval] : 0;
}

// ============================================================================
EventHeaderFactory::EventHeaderFactory()
{
	header_string[std::string("samson")] = 1;
	header_string[std::string("datacount")] = 2;
	header_string[std::string("none")] = 3;

	factories[1] =  &SamsonHeader::myFactory;
	factories[2] =  &DataCountHeader::myFactory;
	factories[3] =  &NoHeader::myFactory;
}

