/**
 *	@file DataCountHeader.cpp
 *
 *	@brief Data Count Header
 *
 *	This Header has a simple 4 byte unsigned integer that tell the reciever
 *      how many bytes are in the message
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef _DATACOUNT_HEADER
#define _DATACOUNT_HEADER

#include "ISE.h"
#include "EventHeader.h"

typedef
	union {
		struct {
			ACE_UINT32 data_len_;
			// Length of the data_ payload, in bytes.
		} atomic;
		char collective[4];
} DataCountHeaderData;


// ===========================================================================
class ISE_Export DataCountHeader : public EventHeader
{
// = TITLE
//     Fixed sized header.
//
// = DESCRIPTION
//     This is designed to have a sizeof (16) to avoid alignment
//     problems on most platforms.

public:

	DataCountHeader() :
		EventHeader(EventHeader::DATACOUNT),
		simulation_id_(0)
	{
		this->hd_.atomic.data_len_ = 0;
	}

	~DataCountHeader()
	{
	}


	// = Decode from network byte order to host byte order.
	void decode (void);

	// = Encode from host byte order to network byte order.
	void encode (void);

	// return printable header
	std::string report(void) const;

	ACE_UINT32 header_length(void) const { return sizeof(this->hd_.atomic); }

	ACE_UINT32 data_length(void) const { return this->hd_.atomic.data_len_; }
	void data_length(ACE_INT32 len) {  this->hd_.atomic.data_len_ = len; EventHeader::data_length(len); }

	ACE_UINT32 simulation_id(void) const { return simulation_id_; }
	void simulation_id(ACE_UINT32 cid) { this->simulation_id_ = cid; }

	ACE_UINT32 entity_id(void) const { return this->handle_; }
	void entity_id(ACE_UINT32 id) { this->handle_ = id; }

	ACE_UINT32 type(void) const { return SimMsgType::UNKNOWN; }
	void type(ACE_UINT32 tid) { ACE_UNUSED_ARG(tid); }

	void  set(char *data) { memcpy(this->hd_.collective, data, sizeof(this->hd_.atomic)); }
	char *addr(void) { return this->hd_.collective; }

	char *gethex(void) const;

	bool discardHeader (void) { return false; }

	//  These are for the Dispatcher to interpret
	bool isData (void) const { return true; }	// is always a Data Message
	bool isCmd (void) const { return false; }	// is never a Command Message


	virtual void deep_copy (DataCountHeader *dch)
	{
		EventHeader::deep_copy(dch);
		this->simulation_id_ = dch->simulation_id_;
		this->hd_.atomic.data_len_ = dch->data_length();
	}

	virtual void transform(EventHeader *eh)
	{
		if ( this->derived_header_type_ndx_ == DATACOUNT)
			this->deep_copy(dynamic_cast<DataCountHeader*>(eh));
		else
		{
			EventHeader::transform(eh);
			this->hd_.atomic.data_len_ = eh->data_length();
		}
	}

	static Factory<EventHeader,DataCountHeader> myFactory;

private:

	DataCountHeaderData hd_;

	// = Data items not part of this header, but still used
	ACE_UINT32 simulation_id_;
};


#endif
