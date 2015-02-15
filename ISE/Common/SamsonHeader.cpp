/**
 *
 *  @file: SamsonModel.cpp
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#define ISE_BUILD_DLL
#include "SamsonHeader.h"
#include "Options.h"
#include "ace/Log_Msg.h"

//.... for stringstream
#include <sstream>

#include <boost/shared_ptr.hpp>


// ============================================================================
Factory<EventHeader,SamsonHeader> SamsonHeader::myFactory;

// ============================================================================
char *
SamsonHeader::gethex(void) const
{
	static char result[128];

	for(int i=0,j=0; i< 48; i++)
	{
		j += sprintf(&result[j],"%02x", (unsigned char) this->hd_.collective[i]);
	}
	return result;
}


// ---------------------------------------------------------------------
void
SamsonHeader::decode (void)
{
	if (encoded_)
	{
		this->hd_.atomic.run_id_ = ntohl (this->hd_.atomic.run_id_);
		this->hd_.atomic.peer_id_ = ntohl (this->hd_.atomic.peer_id_);
		this->hd_.atomic.msg_id_ = ntohl (this->hd_.atomic.msg_id_);
		this->hd_.atomic.app_msg_id_ = ntohs (this->hd_.atomic.app_msg_id_);
		this->hd_.atomic.unit_id_ = ntohs (this->hd_.atomic.unit_id_);
		this->hd_.atomic.flags_ = ntohl (this->hd_.atomic.flags_);
		this->hd_.atomic.type_ = ntohl (this->hd_.atomic.type_);
		this->hd_.atomic.dest_peer_id_ = ntohl (this->hd_.atomic.dest_peer_id_);
		this->hd_.atomic.frame_count_ = ntohl (this->hd_.atomic.frame_count_);
		this->hd_.atomic.send_count_ = ntohl (this->hd_.atomic.send_count_);
		//for(int i=0; i< 4; i++) this->hd_.atomic.reserved_[i] = ntohl (this->hd_.atomic.reserved_[i]);
		this->hd_.atomic.message_crc32_ = ntohl (this->hd_.atomic.message_crc32_);
		this->hd_.atomic.message_length_ = ntohl (this->hd_.atomic.message_length_);

		encoded_ = false;
	}
}

// ---------------------------------------------------------------------
void
SamsonHeader::encode (void)
{
	if (!encoded_)
	{
		this->hd_.atomic.run_id_ = htonl (this->hd_.atomic.run_id_);
		this->hd_.atomic.peer_id_ = htonl (this->hd_.atomic.peer_id_);
		this->hd_.atomic.msg_id_ = htonl (this->hd_.atomic.msg_id_);
		this->hd_.atomic.app_msg_id_ = htons (this->hd_.atomic.app_msg_id_);
		this->hd_.atomic.unit_id_ = htons (this->hd_.atomic.unit_id_);
		this->hd_.atomic.flags_ = htonl (this->hd_.atomic.flags_);
		this->hd_.atomic.type_ = htonl (this->hd_.atomic.type_);
		this->hd_.atomic.dest_peer_id_ = htonl (this->hd_.atomic.dest_peer_id_);
		this->hd_.atomic.frame_count_ = htonl (this->hd_.atomic.frame_count_);
		this->hd_.atomic.send_count_ = htonl (this->hd_.atomic.send_count_);
		//for(int i=0; i< 4; i++) this->hd_.atomic.reserved_[i] = htonl (this->hd_.atomic.reserved_[i]);
		this->hd_.atomic.message_crc32_ = htonl (this->hd_.atomic.message_crc32_);
		this->hd_.atomic.message_length_ = htonl (this->hd_.atomic.message_length_);

		encoded_ = true;
	}
}

// ----------------------------------------------------------------
// = Print to stdout.
std::string
SamsonHeader::report (void) const
{
	boost::shared_ptr<std::stringstream> my_report(new std::stringstream);


	*my_report << "Samson Header:"
		"(" << this->hd_.atomic.magic_[0] <<
		this->hd_.atomic.magic_[1] <<
		int(this->hd_.atomic.version_id_) <<
		int(this->hd_.atomic.dispatched_) << ")";

	if (!this->encoded_ )
	{
		*my_report << " job=" << this->hd_.atomic.run_id_;
		*my_report << " peer=" << this->hd_.atomic.peer_id_;
		*my_report << " msg=" << this->hd_.atomic.msg_id_;
		*my_report << " app_msg=" << this->hd_.atomic.app_msg_id_;
		*my_report << " unit=" << this->hd_.atomic.unit_id_;
		*my_report << " flags=" << std::hex << std::showbase << this->hd_.atomic.flags_;
		*my_report << " type=" << std::dec << std::showbase << this->hd_.atomic.type_;
		*my_report << " dest=" << this->hd_.atomic.dest_peer_id_;
		*my_report << " frame=" << this->hd_.atomic.frame_count_;
		*my_report << " snd_cnt=" << this->hd_.atomic.send_count_;
		*my_report << " data_crc32=" << this->hd_.atomic.message_crc32_;
		*my_report << " data_len=" << this->hd_.atomic.message_length_;
	}
	else
	{
		*my_report << " job=" << ntohl (this->hd_.atomic.run_id_);
		*my_report << " peer=" << ntohl (this->hd_.atomic.peer_id_);
		*my_report << " msg=" << ntohl (this->hd_.atomic.msg_id_);
		*my_report << " app_msg=" << ntohs (this->hd_.atomic.app_msg_id_);
		*my_report << " unit=" << ntohs (this->hd_.atomic.unit_id_);
		*my_report << " flags=" << std::hex << std::showbase << ntohs (this->hd_.atomic.flags_);
		*my_report << " type=" << std::dec << std::showbase << ntohs (this->hd_.atomic.type_);
		*my_report << " dest=" << ntohl (this->hd_.atomic.dest_peer_id_);
		*my_report << " frame=" << ntohl (this->hd_.atomic.frame_count_);
		*my_report << " snd_cnt=" << ntohl (this->hd_.atomic.send_count_);
		*my_report << " data_crc32=" << ntohl (this->hd_.atomic.message_crc32_);
		*my_report << " data_len=" << ntohl (this->hd_.atomic.message_length_);
	}

	//*my_report << " reserved= (";
	//for(int i=0; i< 4; i++) *my_report << " " << this->hd_.atomic.reserved_[i];
	//*my_report << ")";

	return my_report->str();
}

/*
// ---------------------------------------------------------------------
void
SamsonHeader::transform(EventHeader *eh)
{
	if ( this->header_type() == eh->header_type() )
	{
		this->deep_copy( (SamsonHeader *)eh);
	}
	else
	{
		this->connection_id_ = eh->connection_id ();
		this->hd_.atomic.magic_[0] = 'S';
		this->hd_.atomic.magic_[1] = 'N';
		this->hd_.atomic.version_id_ = 1;
		this->hd_.atomic.dispatched_ = 0x0;
		this->hd_.atomic.run_id_ = eh->simulation_id();
		this->hd_.atomic.peer_id_ = eh->entity_id();
		this->hd_.atomic.msg_id_ = 0;
		this->hd_.atomic.app_msg_id_ = 0;
		this->hd_.atomic.unit_id_ = 0;
		this->hd_.atomic.flags_ = 0;
		this->hd_.atomic.type_ = eh->type();
		this->hd_.atomic.dest_peer_id_ = 0;
		this->hd_.atomic.frame_count_ = 0;
		this->hd_.atomic.send_count_ = 0;
		//for(int i=0; i< 4; i++) this->hd_.atomic.reserved_[i] = 0;
		this->hd_.atomic.message_crc32_ = 0;
		this->hd_.atomic.message_length_ = eh->data_length();
	}
}
*/

// ---------------------------------------------------------------------
bool
SamsonHeader::verify (void)
{
	return
		this->hd_.atomic.magic_[0] == 'S'
		|| this->hd_.atomic.magic_[1] == 'N'
		|| this->hd_.atomic.version_id_ == 1;
}



