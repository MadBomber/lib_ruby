/**
 *	@file DebugFlag.cpp
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 *	@brief Distributes command line debug options (model only for now)
 *
 */

#define ISE_BUILD_DLL
#include "DebugFlag.h"

#include "ace/Get_Opt.h"
#include "ace/Log_Msg.h"

namespace Samson_Peer {

// Static initialization.
DebugFlag *DebugFlag::instance_ = 0;


// -----------------------------------------------------------------
/**
 * Return Singleton.
 * @param  None
 * @return The address of the DebugFlag object
 */
DebugFlag *DebugFlag::instance (void)
{
	if (DebugFlag::instance_ == 0)
	    ACE_NEW_RETURN (DebugFlag::instance_, DebugFlag, 0);

  return DebugFlag::instance_;
}


// -----------------------------------------------------------------
// Parse the "command-line" arguments and set the corresponding flags.
int DebugFlag::parse_args (int argc, ACE_TCHAR *argv[])
{
	// Assign defaults.
	ACE_Get_Opt get_opt (argc, argv, ACE_TEXT("d:"));

	for (int c; (argc != 0) && ((c = get_opt ()) != -1); )
	{
		switch (c)
		{
			case 'd': // Use a different threading strategy.
			{
				for (char *flag = strtok (get_opt.optarg, ACE_TEXT(":"));
					flag != 0;
					flag = strtok (0, ACE_TEXT(":")))
				{
					if (strcmp (flag, "DB") == 0)  // Database Interface
						ACE_SET_BITS (this->options_,DebugFlag::DB_DEBUG);

					else if (strcmp (flag, "APP") == 0)
						ACE_SET_BITS (this->options_,DebugFlag::APPMGR_DEBUG);
					else if (strcmp (flag, "OBJ") == 0)
						ACE_SET_BITS (this->options_,DebugFlag::OBJ_DEBUG);
					else if (strcmp (flag, "PHI") == 0)
						ACE_SET_BITS (this->options_,DebugFlag::PH_INPUT);
					else if (strcmp (flag, "PHO") == 0)
						ACE_SET_BITS (this->options_,DebugFlag::PH_OUTPUT);
					else if (strcmp (flag, "PH") == 0)
					{
						ACE_SET_BITS (this->options_,DebugFlag::PH_INPUT);
						ACE_SET_BITS (this->options_,DebugFlag::PH_OUTPUT);
					}
					else if (strcmp (flag, "APB") == 0)
						ACE_SET_BITS (this->options_,DebugFlag::APB_DEBUG);
					else if (strcmp (flag, "MDL") == 0)
						ACE_SET_BITS (this->options_,DebugFlag::MDL_DEBUG);
					else if (strcmp (flag, "XML") == 0)
						ACE_SET_BITS (this->options_,DebugFlag::XML_DEBUG);
					else if (strcmp (flag, "NET") == 0)
						ACE_SET_BITS (this->options_,DebugFlag::NET_DEBUG);

					else if (strcmp (flag, "RTE") == 0) // PubSubDispatch (Dispatcher)
						ACE_SET_BITS (this->options_,DebugFlag::ROUTE);
					else if (strcmp (flag, "CMD") == 0) // CommandParser (Dispatcher)
						ACE_SET_BITS (this->options_,DebugFlag::CMD_DEBUG);
					else if (strcmp (flag, "FLTR") == 0) // CommandParser (Dispatcher)
						ACE_SET_BITS (this->options_,DebugFlag::FILTER_DEBUG);
					else if (strcmp (flag, "CH") == 0) // CommandParser (Dispatcher)
						ACE_SET_BITS (this->options_,DebugFlag::CHANNEL);


					else if (strcmp (flag, "ALL") == 0)
							ACE_SET_BITS (this->options_,0xffff);
				}
			}
			break;

			case 'v': // Verbose mode.
				ACE_SET_BITS (this->options_, DebugFlag::VERBOSE);
			break;

		}
	}
	return 0;
}

} // namespace
