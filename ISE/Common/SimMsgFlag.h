/**
 *	@class SimMsgFlag
 *
 *	@brief Bit Flag for Header field
 *
 *	This holds a bit field
 *
 *	@note Attempts at zen rarely work.
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef SIM_MSG_FLAG_H
#define SIM_MSG_FLAG_H

class SimMsgFlag
{
public:

	enum {

	  	//  First sets typing/control  (default is data)
		object        = 0x00000001,
		strip_header  = 0x00000002,
		trace         = 0x00000004,
		log_it		  = 0x00000008,

		//  Second is encoding  (default is NO encoding)
		b64_encode  = 0x00000010,
		gzip        = 0x00000020,
		b16_encode  = 0x00000040,

		// Third and Fourth is for routing (default is pub/sub)
		master_only   = 0x00000100,
		nowhere       = 0x00000200,
		job           = 0x00000400,
		p2p           = 0x00000800,
		p2ch          = 0x00001000,
		control		  = 0x00002000, //  This is to handle data(less) control messages

		// valid for a Object message only
		xml_boost_serialize     = 0x00100000,
		text_boost_serialize    = 0x00200000,
		json_serialize          = 0x00400000,

		// valid for a Status Message only  (set by SimMsgType::STATUS_REQUEST)
		status_log_local        = 0x00100000,
		status_log_dispatcherd  = 0x00200000,
		status_log_sender       = 0x00400000
	};
};

#endif
