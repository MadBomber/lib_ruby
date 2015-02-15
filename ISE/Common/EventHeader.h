/**
 * @file EventHeader.h
 *
 * @brief Virtual Base Class for ALL Simulation Headers
 *
 *   The header is very important.  This section of code will be in development
 *   for a long time.  I am hoping to home in on a processing concept that
 *   will work.
 *
 *   Concept:
 *
 *   A message arrives.  The header is assigned per the "Connection Handler"
 *   or as I will call it "channel".  We will read the header, dynamically
 *   allocating the header object off the application heap.
 *
 *   Hand off concept:
 *
 *   1. The receiving Connection_Handler will create a message-block chain
 *      containing the address of the object the header object, continued by the data.
 *
 *   2. Event_Channel_Mgr will determine the proper processing of this event.
 *
 *   3. The transmitting Connection_Handler will create a message_block chain
 *      containing the header formatted for the destaination and the data.
 *
 * @@TODO: Research pruning a message block chain, or having an element that
 *    belongs to multiple chains.
 *
 * @author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */


#ifndef _EVENT_HEADER
#define _EVENT_HEADER

#include <string>
#include <sstream>

#include <boost/shared_ptr.hpp>

#include "ace/ACE.h"
#include "ace/Basic_Types.h"
#include "ace/Time_Value.h"
#include "ace/OS_NS_sys_time.h"
#include "ace/Log_Msg.h"

#include "ISE.h"
#include "SimMsgType.h"
#include "Factory_T.h"

// ===========================================================================
class ISE_Export EventHeader   // This is a pure virtual class!!!
{
public:

	enum  {
		BADHEADER = 0,	// This is an error, we lost our header
		SAMSONHEADER,	// This is a ...
		DATACOUNT,	// This is a simplified header for simulation end-points
		NOHEADER	// No Header????
	};


	//  For the most part we do not need a very sophisitcated header to process
	//  commands.  I would like to use XML 1.0 or XML-RPM or SOAP or some
	//  rigorus 'tag-based' data stream as the contolling mechanism.
	//  But for now I can see some need for the header doing the majority
	//  of the work.

	virtual ACE_UINT32 header_length(void) const = 0;

	virtual ACE_UINT32 simulation_id(void) const = 0;
	virtual void simulation_id(ACE_UINT32 cid) = 0;

	virtual ACE_UINT32 entity_id(void) const = 0;
	virtual void entity_id(ACE_UINT32 eid) = 0;

	virtual ACE_UINT32 type(void) const = 0;
	virtual void type(ACE_UINT32 tid)= 0;

	virtual void decode (void) = 0;
	virtual void encode (void) = 0;

	virtual void set(char *data) = 0;
	virtual char *addr(void) = 0;
	virtual char *gethex(void) const = 0;

	virtual bool isData (void) const = 0;
	virtual bool isCmd (void) const= 0;

	virtual bool discardHeader (void) = 0;

	// print options
	// virtual std::string report(void) const = 0;

	virtual bool verify (void) { return true; }

	//===============================================
	// Connection ID is an internal use item
	ACE_UINT32 connection_id(void) const { return this->connection_id_; }
	void connection_id(ACE_UINT32 id) { this->connection_id_ = (ACE_UINT32) id; }

	//===============================================
	// Handle is an internal use item
	ACE_UINT32 handle(void) const { return this->handle_; }
	void handle(ACE_UINT32 id) { this->handle_ = (ACE_UINT32) id; }

	//===============================================
	// data length is used internally, but is special!
	virtual ACE_UINT32 data_length(void) const { return this->data_len_; }
	virtual void data_length(ACE_INT32 len) {  this->data_len_ = len; }

	//===============================================
	// Constructor(s)
	EventHeader() :
		derived_header_type_ndx_(EventHeader::BADHEADER),
		connection_id_(0),
		handle_(0),
		data_len_(0),
		encoded_ (false)
	{
		this->entry_time_ = ACE_OS::gettimeofday();
	}

	EventHeader(int val) :
		derived_header_type_ndx_(val),
		connection_id_(0),
		handle_(0),
		data_len_(0),
		encoded_ (false)
	{
		this->entry_time_ = ACE_OS::gettimeofday();
	}

	// ---------------------------------------------------------------------
	void print (void) const
	{
		ACE_DEBUG ((LM_DEBUG, "%s\n", (this->report()).c_str()));
	}

	// Virtual Destructor is required as this is an Abstract Class
	virtual ~EventHeader() {}

	// return the header type
	int header_type(void) { return derived_header_type_ndx_; }

	// Event Timer
	double delta_time(void)
	{
		ACE_Time_Value now(ACE_OS::gettimeofday());
		ACE_Time_Value delta = now - entry_time_;
		return delta.usec()*1.0e-6;
	}

	bool encoded() { return encoded_; }
	void encoded(bool e) { encoded_ = e; }

	virtual void deep_copy(EventHeader *eh)
	{
		this->derived_header_type_ndx_ = eh->derived_header_type_ndx_;
		this->entry_time_ = eh->entry_time_;
		this->connection_id_ = eh->connection_id_;
		this->handle_ = eh->handle_;
		this->data_len_ = eh->data_len_;
		this->encoded_ = eh->encoded_;
	}


	virtual std::string report (void) const
	{
		boost::shared_ptr<std::stringstream> my_report(new std::stringstream);


		*my_report << "Event Header:"
			"(" << derived_header_type_ndx_
			<< "," << connection_id_
			<< "," << handle_
			<< "," << data_len_
			<< ")";

		return my_report->str();
	}


	virtual void transform(EventHeader *eh) { this->deep_copy(eh); }

	typedef FactoryPlant<EventHeader>  EventHeaderFactory;

protected:
	int derived_header_type_ndx_;	// CLUDGE: must match the enum above
	ACE_Time_Value entry_time_;		// Used for book-keeping
	ACE_INT32 connection_id_;		// This is the channel (Connection Record ID)
	ACE_INT32 handle_;				// The "handle" where this messageis from
	ACE_UINT32 data_len_;
	bool encoded_;
};


#endif
