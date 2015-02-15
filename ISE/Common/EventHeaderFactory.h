/**
 *	@file EventHeaderFactory.h
 * 
 *	@brief Factory to create a simulation header
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */


#ifndef _EventHeaderFactory
#define _EventHeaderFactory
#include "ISE.h"
#include "EventHeader.h"

#include <map>
#include <string>


// ===========================================================================
class ISE_Export EventHeaderFactory
{
	public:
		EventHeaderFactory();
		EventHeader *get (int );
		int lookup (const char *);
	private:

   		std::map<int,EventHeader::EventHeaderFactory *>  factories;
		std::map<std::string,int> header_string;
};

#endif
