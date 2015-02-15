/**
 *	@file DataCountHeader.cpp
 *
 *	@class DataCountHeader
 *
 *	@brief Specialization Header for a four byte data count
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#define ISE_BUILD_DLL
#include "DataCountHeader.h"

//.... for stringstream
#include <sstream>

#include <boost/shared_ptr.hpp>

#include "ace/Log_Msg.h"


// ============================================================================
Factory<EventHeader,DataCountHeader> DataCountHeader::myFactory;

// ============================================================================
char *
DataCountHeader::gethex(void) const
{
	static char hdata[128];

	for(int i=0,j=0; i< 4; i++)
	{
		j += sprintf(&hdata[j],"%02x", (unsigned char) this->hd_.collective[i]);
	}
	return hdata;
}

// ---------------------------------------------------------------------
void
DataCountHeader::decode (void)
{
	if (encoded_)
	{
		this->hd_.atomic.data_len_ = ntohl (this->hd_.atomic.data_len_);
		this->encoded_ = false;
	}
}

// ---------------------------------------------------------------------
void
DataCountHeader::encode (void)
{
	if (!encoded_)
	{
		this->hd_.atomic.data_len_ = htonl (this->hd_.atomic.data_len_);
		this->encoded_ = true;
	}
}

// ---------------------------------------------------------------------
std::string
DataCountHeader::report (void) const
{
	boost::shared_ptr<std::stringstream> my_report(new std::stringstream);

	*my_report << " DataCount Header: length= " <<
		((encoded_)? ntohl (this->hd_.atomic.data_len_) : this->hd_.atomic.data_len_);
	return EventHeader::report() + my_report->str();
}

/*
// ---------------------------------------------------------------------
void
DataCountHeader::deep_copy (DataCountHeader *orig)
{
	memcpy(this->hd->collective, orig->addr(), sizeof(this->hd->atomic));
	this->connection_id_ = orig->connection_id();
	this->simulation_id_ = orig->simulation_id();
	this->entity_id_ = orig->entity_id();
}

// ---------------------------------------------------------------------
void
DataCountHeader::transform(EventHeader *eh)
{
	if ( this->header_type() == eh->header_type() )
	{
		this->deep_copy( (DataCountHeader *)eh);
		this->connection_id_ = eh->connection_id();
		this->simulation_id_ = eh->simulation_id();
		this->entity_id_ = eh->entity_id();
	}
	else
	{
		this->hd->atomic.data_len_ = eh->data_length();

		this->connection_id_ = eh->connection_id();
		this->simulation_id_ = eh->simulation_id();
		this->entity_id_ = eh->entity_id();
	}
}
*/
