/**
 *	@file DebugFlag.h
 *
 *	@brief Distributes command line options for controlling debug, used for both Service and Model
 *
 *	This Singleton object is used to disseminate default and command
 *	line debugging options throughout the program
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef DEBUGFLAG_H_
#define DEBUGFLAG_H_

#include "ISE.h"

#include "ace/Global_Macros.h"


namespace Samson_Peer {

// ===========================================================================
class ISE_Export DebugFlag
{
	// = TITLE
	//     Singleton that consolidates all DebugFlags for both Sevices and Models.
public:
	// = Debug options that can be enabled/disabled.
	enum
	{
		// = The types of debugging strategies.
		OFF           = 0x0000,
		VERBOSE       = 0x0001,
		DB_DEBUG      = 0x0002,
		OBJ_DEBUG     = 0x0004,
		APPMGR_DEBUG  = 0x0008,
		PH_INPUT      = 0x0010,
		APB_DEBUG     = 0x0020,
		MDL_DEBUG     = 0x0040,
		XML_DEBUG     = 0x0080,
		NET_DEBUG     = 0x0100,
		ROUTE         = 0x0200,
		CMD_DEBUG     = 0x0400,
		FILTER_DEBUG  = 0x0800,
		CHANNEL       = 0x1000,
		PH_OUTPUT     = 0x2000
	};

	static DebugFlag *instance (void);

	int parse_args (int argc, ACE_TCHAR *argv[]);
	// Parse the arguments and set the options.

	// = Accessor methods.
	int enabled (int option) { return ACE_BIT_ENABLED (this->options_, option); }
	// Determine if an option is enabled.

	void enable (int option) { ACE_SET_BITS (this->options_, option); }
	// Enable an option

	void disable (int option) { ACE_CLR_BITS (this->options_, option); }
	// Disable an option

	void print (void) { ACE_DEBUG ((LM_DEBUG, "(%P|%t) DebugFlag(%x)\n", this->options_)); }

	unsigned long get_flags(void) { return this->options_; }

	void set_flags(unsigned long o) { this->options_ = o; }

	void off() { this->options_ = 0xffff; }

	void on() { this->options_ = 0x0000; }


	// Trap gdb where I want it!
	int DebugWait;

private:

	unsigned long options_;
	// Flag to indicate if we want debugging.

	static DebugFlag *instance_;
	// Singleton.

	DebugFlag (void): DebugWait(1), options_ (0) {}
	// Ensures Singleton

	~DebugFlag (void) {};

};

} // namespace

#endif /*DEBUGFLAG_H_*/
