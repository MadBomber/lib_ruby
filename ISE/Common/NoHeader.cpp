/**
 *  @file  NoHeader.cpp
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#define ISE_BUILD_DLL

#include "ISE.h"
#include "NoHeader.h"

// ============================================================================
Factory<EventHeader,NoHeader> NoHeader::myFactory;

// ============================================================================
char *
NoHeader::gethex(void) const
{
	static char hdata[] = "NONE";
	return hdata;
}

/*
// ----------------------------------------------------------------
void
NoHeader::deep_copy (NoHeader *orig)
{
	this->connection_id_ = orig->connection_id();
	this->simulation_id_ = orig->simulation_id();
	this->entity_id_ = orig->entity_id();
	this->data_len_ = orig->data_length();
}

// ----------------------------------------------------------------
void
NoHeader::transform(EventHeader *eh)
{
	this->connection_id_ = eh->connection_id();
	this->simulation_id_ = eh->simulation_id();
	this->entity_id_ = eh->entity_id();
	this->data_len_ = eh->data_length();
}
*/
