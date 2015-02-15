/**
 *	@file SamsonHeader.h
 *
 *	@class SamsonHeader
 *
 *	@brief Samson Header - Fixed sized header. Between Primary Entities
 *
 *     This is designed to have a sizeof (32) to avoid alignment
 *     problems on most platforms.
 *
 *	Header Format
 *
 * 	Bytes	Content
 * 		2	Magic Key(2 byte char) - "SN"
 * 		1	header version (byte - later split into major/minor nibbles)
 * 		1	dispatched flag (control dispatcher loop-back)
 * 		4	Run ID (unsigned int)
 * 		4	Sender Peer(/Model/Entity) ID (unsigned int)
 * 		4	Message ID specific to this Run (unsigned int)
 * 		2	Application Message ID - NOT specific to this Run (unsigned short)
 * 		2	Sender Unit ID which is the instance ID of this Model (unsigned short)
 * 		2	flags (unsigned short) - (bit field)  see SimMsgFlag.h
 * 		2	type (unsigned short) - (enumeration) see SimMsgType.h
 * 		4	Destination Model ID (unsigned int)
 * 		4	message length (long unsigned int)
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef _SamsonHeader
#define _SamsonHeader

#include "ISE.h"
#include "EventHeader.h"
#include "SimMsgFlag.h"
#include "SimMsgType.h"
#include "ace/Message_Block.h"
#include "ace/Log_Msg.h"

//....boost type of for cross-platform
#include <boost/typeof/typeof.hpp>

//....boost serialization
#include <boost/archive/basic_xml_archive.hpp>
#include <boost/archive/xml_oarchive.hpp>
#include <boost/archive/xml_iarchive.hpp>
#include <boost/serialization/version.hpp>
#include <boost/serialization/nvp.hpp>
#include <boost/serialization/utility.hpp>

// ===========================================================================
typedef
union {
	struct {
		unsigned char magic_[2];
		unsigned char version_id_;
		unsigned char dispatched_;

		ACE_UINT32 run_id_;         //  Run ID
		ACE_UINT32 peer_id_;		//  Model(/Peer) ID
		ACE_UINT32 msg_id_;         //  Run Message ID  (Run dependent)
		ACE_UINT16 app_msg_id_;     //  Application Message ID  (Run independent)
		ACE_UINT16 unit_id_;        //  Instance identifier
		ACE_UINT32 flags_;          //  Bit Flags
		ACE_UINT32 type_;           //  Message Type Enumeration
		ACE_UINT32 dest_peer_id_;	//  For direct model-to-model communications
		ACE_UINT32 frame_count_; 	//  Frame Counter
		ACE_UINT32 send_count_; 	//  Send Counter
		ACE_UINT32 message_crc32_;  //  Data CRC32 Checksum that follows this header
		ACE_UINT32 message_length_; //  Data Length that follows this header

	} atomic;
	char collective[48];
} SamsonHeaderData;

// ===========================================================================
class ISE_Export SamsonHeader : public EventHeader
{
// = TITLE
//     Fixed sized header. Between Primary Entities
//
// = DESCRIPTION
//     This is designed to have a sizeof (48) to avoid alignment
//     problems on most platforms.
//
//	Header Format
//
//		Bytes	Content
//		2	Magic Key(2 byte char) - "SN"
//		1	Header version (byte - later split into major/minor nibbles)
//		1	dispatched flag (control dispatcher loop-back)
//		4	Run ID (unsigned int)
//		4	Sender Peer ID (unsigned int)
//		4	Message ID (unsigned short)
//		2	Application Message ID (unsigned short)
//		2	Sender Unit ID (unsigned short)
//		4	flags (unsigned short) - (bit flag)  see SimMsgFlag.h
//		4	type (unsigned short) - (enumeration) see SimMsgType.h
//		4   Destination Peer ID (unsigned int)
//		4	Frame Number (unsigned int)
//		4	Destination Peer ID or Connection ID (unsigned int)
//		4	Send Count (unsigned int)
//		4	CRC32 Checksum (unsigned int)
//		4	message length (long unsigned int)

public:

	SamsonHeader() : EventHeader(EventHeader::SAMSONHEADER)
	{
		this->hd_.atomic.magic_[0] = 'S';
		this->hd_.atomic.magic_[1] = 'N';
		this->hd_.atomic.version_id_ = 1;
		this->hd_.atomic.dispatched_ = 0;

		this->hd_.atomic.run_id_ = 0;
		this->hd_.atomic.peer_id_ = 0;
		this->hd_.atomic.msg_id_ = 0;
		this->hd_.atomic.app_msg_id_ = 0;
		this->hd_.atomic.unit_id_ = 0;
		this->hd_.atomic.flags_ = 0;
		this->hd_.atomic.type_ = 0;
		this->hd_.atomic.frame_count_ = 0;
		this->hd_.atomic.send_count_ = 0;
		this->hd_.atomic.message_crc32_ = 0;
		this->hd_.atomic.message_length_ = 0;

		encoded_ = false;
	}

	~SamsonHeader()
	{
	}

	// = Decode from network byte order to host byte order.
	void decode (void);

	// = Encode from host byte order to network byte order.
	void encode (void);

	// return printable header
	std::string report (void) const;

	// Get the length of this header
	ACE_UINT32 header_length(void) const { return sizeof(this->hd_.atomic);}

	// Get the length of the data
	ACE_UINT32 data_length(void) const { return this->hd_.atomic.message_length_; }
	void data_length(ACE_INT32 len) { this->hd_.atomic.message_length_ = len; EventHeader::data_length(len); }


	// simulation_id is run_id for Samson
	ACE_UINT32 simulation_id(void) const { return this->hd_.atomic.run_id_; }
	void simulation_id(ACE_UINT32 id) { this->hd_.atomic.run_id_ = id; }

	ACE_UINT32 run_id(void) const { return this->hd_.atomic.run_id_; }
	void run_id(ACE_UINT32 id) { this->hd_.atomic.run_id_ = id; }


	// entity_id are peer_id for Samson
	ACE_UINT32 entity_id(void) const { return this->hd_.atomic.peer_id_; }
	void entity_id(ACE_UINT32 id) { this->hd_.atomic.peer_id_ = id; }

	ACE_UINT32 peer_id(void) const { return this->hd_.atomic.peer_id_; }
	void peer_id(ACE_UINT32 id) { this->hd_.atomic.peer_id_ = (ACE_UINT32) id; }


	// UnitID is a Samson specific descriminator
	ACE_INT32 unit_id(void) const { return this->hd_.atomic.unit_id_; }
	void unit_id(ACE_UINT32 id) { this->hd_.atomic.unit_id_ = (ACE_UINT16) id; }


	// UnitID is a Samson specific descriminator
	ACE_UINT32 dispatched(void) const { return this->hd_.atomic.dispatched_; }
	void dispatched(ACE_UINT32 id) { this->hd_.atomic.dispatched_ = (unsigned char) id; }

	// Message ID for a given Run
	ACE_INT32 message_id(void) const { return this->hd_.atomic.msg_id_; }
	void message_id(ACE_INT32 id) { this->hd_.atomic.msg_id_ = (ACE_UINT32) id; }

	// App Msg ID is for a Model
	//  It is not used much, more for the human to debug things
	ACE_UINT32 app_msg_id(void) const { return this->hd_.atomic.app_msg_id_; }
	void app_msg_id(ACE_UINT32 id) { this->hd_.atomic.app_msg_id_ = (ACE_UINT16) id; }

	// Destination Model ID (used for p2p)
	ACE_UINT32 dest_peer_id(void) const { return this->hd_.atomic.dest_peer_id_; }
	void dest_peer_id(ACE_UINT32 id) { this->hd_.atomic.dest_peer_id_ = id; }

	// Destination Model ID (used for p2p)
	ACE_UINT32 frame_count(void) const { return this->hd_.atomic.frame_count_; }
	void frame_count(ACE_UINT32 cnt) {  this->hd_.atomic.frame_count_ = cnt; }

	// Destination Model ID (used for p2p)
	ACE_UINT32 crc32(void) const { return this->hd_.atomic.message_crc32_; }
	void crc32(ACE_UINT32 cnt) {  this->hd_.atomic.message_crc32_ = cnt; }

	// Destination Model ID (used for p2p)
	ACE_UINT32 send_count(void) const { return this->hd_.atomic.send_count_; }
	void send_count(ACE_UINT32 cnt) {  this->hd_.atomic.send_count_ = cnt; }

	// This always set to data ???????????  so why have it
	ACE_UINT32 type(void) const { return this->hd_.atomic.type_; }
	void type(ACE_UINT32 tid) { this->hd_.atomic.type_ = (ACE_INT32) tid; }

	// Set/Get the header header data
	void  set(char *data) { memcpy(this->hd_.collective, data, sizeof(this->hd_.atomic)); }
	char *addr(void) { return this->hd_.collective; }

	// Set/Get the bit flags
	void bit_flags ( ACE_UINT32 flag_ ) { this->hd_.atomic.flags_ = flag_; }
	ACE_UINT32 bit_flags (void) const { return this->hd_.atomic.flags_; }

	void clear_flags (void) { this->hd_.atomic.flags_ = 0x0; }

	bool enabled (int option) const { return ACE_BIT_ENABLED (this->hd_.atomic.flags_, option); }
	void enable (int option)
	{
		// # define ACE_SET_BITS(WORD, BITS) (WORD |= (BITS))
		ACE_SET_BITS (this->hd_.atomic.flags_, option);
	}
	void disable (int option)
	{
		// # define ACE_CLR_BITS(WORD, BITS) (WORD &= ~(BITS))
		ACE_CLR_BITS (this->hd_.atomic.flags_, option);
	}

	// return a printable hex string of this header
	char *gethex(void) const;

	// Shortcuts!
	bool discardHeader (void)
	{
		return ACE_BIT_ENABLED (this->hd_.atomic.flags_, SimMsgFlag::strip_header);
	}
	bool isData (void) const
	{
		return ( this->hd_.atomic.type_ == SimMsgType::DATA ||
			this->hd_.atomic.type_ == SimMsgType::ROUTE );
	}
	bool isCmd (void) const
	{
		return !( this->hd_.atomic.type_ == SimMsgType::DATA ||
			this->hd_.atomic.type_ == SimMsgType::ROUTE );
	}

	virtual void deep_copy (SamsonHeader *sh)
	{
		EventHeader::deep_copy(sh);
		this->hd_ = sh->hd_;
	}

	virtual void transform(EventHeader *eh)
	{
		if ( this->derived_header_type_ndx_ == SAMSONHEADER)
			this->deep_copy(dynamic_cast<SamsonHeader*>(eh));
		else
		{
			EventHeader::deep_copy(eh);
			this->hd_.atomic.magic_[0] = 'S';
			this->hd_.atomic.magic_[1] = 'N';
			this->hd_.atomic.version_id_ = 1;
			this->hd_.atomic.dispatched_ = 0;

			this->hd_.atomic.run_id_ = 0;
			this->hd_.atomic.peer_id_ = 0;
			this->hd_.atomic.msg_id_ = 0;
			this->hd_.atomic.app_msg_id_ = 0;
			this->hd_.atomic.unit_id_ = 0;
			this->hd_.atomic.flags_ = 0;
			this->hd_.atomic.type_ = 0;
			this->hd_.atomic.frame_count_ = 0;
			this->hd_.atomic.send_count_ = 0;
			this->hd_.atomic.message_crc32_ = 0;
			this->hd_.atomic.message_length_ = eh->data_length();
		}
	}

	// a cursory validity verification.
	bool verify (void);

	// Comparator for queuing
	friend bool operator<(const SamsonHeader &leftNode, const SamsonHeader &rightNode) {

	 if (leftNode.hd_.atomic.frame_count_ < rightNode.hd_.atomic.frame_count_) return true;

	 if ((leftNode.hd_.atomic.frame_count_ == rightNode.hd_.atomic.frame_count_) &&
			 (leftNode.hd_.atomic.app_msg_id_ < rightNode.hd_.atomic.app_msg_id_) )return true;

	 return false;
	}


	// Used to create a header of this type
	static Factory<EventHeader,SamsonHeader> myFactory;

	template<class Archive>
	void serialize(Archive & ar, const unsigned int ) const
	{
		#define AR(NAME, VALUE) { BOOST_TYPEOF(SamsonHeaderData().atomic.VALUE) i=hd_.atomic.VALUE; ar & boost::serialization::make_nvp(NAME, i); }
		AR("header_run_id"          , run_id_)
		AR("header_model_id"        , peer_id_)
		AR("header_msg_id"          , msg_id_)
		AR("header_app_msg_id"      , app_msg_id_)
		AR("header_unit_id"         , unit_id_)
		AR("header_flags"           , flags_)
		AR("header_type"            , type_)
		AR("header_dest_model_id"   , dest_peer_id_)
		AR("header_frame_count"     , frame_count_)
		AR("header_send_count"      , send_count_)
		AR("header_message_crc32"   , message_crc32_)
		AR("header_message_length"  , message_length_)
	}

protected:

	SamsonHeaderData hd_;

};

#endif
