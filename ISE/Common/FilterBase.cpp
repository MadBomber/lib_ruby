/**
 *	@file FilterBase.cpp
 *
 *	@brief Base File for all Samson Filters
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>  2006
 *
 */

#define ISE_BUILD_DLL

#include "FilterBase.h"
#include "DebugFlag.h"
#include "SamsonHeader.h"
#include "Service_ObjMgr.h"
#include "MessageFunctor.hpp"

#include <sstream>
#include <string>

#include "ace/Reactor.h"
#include "ace/Thread_Manager.h"

// used to get the command line
#include "ace/Get_Opt.h"


namespace Samson_Peer {


//...................................................................................................
FilterBase::FilterBase() // : ACE_Service_Object()
{
	ACE_TRACE("FilterBase::FilterBase");

}

//...................................................................................................
FilterBase::~FilterBase()
{
	ACE_TRACE("FilterBase::~FilterBase");
}

//...................................................................................................
int FilterBase::init(int argc, ACE_TCHAR *argv[])
{
	ACE_TRACE("FilterBase::init");
	ACE_UNUSED_ARG (argc);
	ACE_UNUSED_ARG (argv);


/*
	ACE_Get_Opt get_opt (argc, argv, ACE_TEXT("f:s"));

	// pull the number of models to control from the command line
	for (int c; (argc != 0) && ((c = get_opt ()) != -1); )
	{
		switch (c)
		{
			case 'f':
				this->input_file_name_ = get_opt.opt_arg ();
			break;

			case 's':
				this->save_state_ = true;
			break;
		}
	}
*/
	return 1;
}

//...................................................................................................
int FilterBase::fini(void)
{
	ACE_TRACE("FilterBase::fini");
	return 0;
}

//...................................................................................................
int FilterBase::info (ACE_TCHAR **info_string, size_t length) const
{
	std::stringstream myinfo;
	myinfo << *this;

	if (*info_string == 0)
		*info_string = ACE::strnew(myinfo.str().c_str());
	else
		ACE_OS::strncpy(*info_string, myinfo.str().c_str(), length);

	return ACE_OS::strlen(*info_string) +1;
}

//...................................................................................................
ostream& operator<<(ostream& output, const FilterBase& )
{
    output << "FilterBase:: need to implement << method ";
	return output;
}


} // namespace
