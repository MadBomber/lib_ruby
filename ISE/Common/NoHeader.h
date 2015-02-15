/**
 *	@class NoHeader
 *
 *	@brief No Header
 *
 *	This object is used for an ise "No Header" message. The header is for ISE routing,
 *  and is used only in the dispatching. The data is treated as a "blob"
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef _NoHeader
#define _NoHeader

#include "EventHeader.h"
#include "ace/Log_Msg.h"


// ===========================================================================
class ISE_Export NoHeader : public EventHeader
{
// = TITLE
//     Fixed NO header.
//
// = DESCRIPTION
//     This is designed to have a sizeof (16) to avoid alignment
//     problems on most platforms.
public:

	// = Default constructor
	NoHeader() : EventHeader(EventHeader::NOHEADER), simulation_id_(0) {}

	// = Decode from network byte order to host byte order.
	void decode (void) {}

	// = Encode from host byte order to network byte order.
	void encode (void){}

	std::string report(void) const {  return EventHeader::report(); }

	ACE_UINT32 header_length(void) const { return 0; }

	ACE_UINT32 simulation_id(void) const { return simulation_id_; }
	void simulation_id(ACE_UINT32 sid) { this->simulation_id_ = sid; }

	ACE_UINT32 entity_id(void) const { return this->handle_; }
	void entity_id(ACE_UINT32 id) { this->handle_ = id; }

	ACE_UINT32 type(void) const { return SimMsgType::UNKNOWN; }
	void type(ACE_UINT32 tid) { ACE_UNUSED_ARG(tid); }

	void set(char *data) { ACE_UNUSED_ARG(data); }
	char *addr(void) { return 0; }

	char *gethex(void) const ;

	bool discardHeader (void) { return true; }

	bool isData (void) const { return true; }
	bool isCmd (void) const { return false; }

	void deep_copy (NoHeader *orig)
	{
		EventHeader::deep_copy(orig);
		this->simulation_id_ = orig->simulation_id_;
	}

	void transform(EventHeader *eh)
	{
		if ( this->derived_header_type_ndx_ == NOHEADER)
			this->deep_copy(dynamic_cast<NoHeader*>(eh));
		else
			EventHeader::transform(eh);
	}

	static Factory<EventHeader,NoHeader> myFactory;
private:

	// = Data items not part of this header, but still used
	ACE_UINT32 simulation_id_;
};


#endif
