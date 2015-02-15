/**
 *	@file FilterBase.h
 *
 *	@brief Base File for all ISE Filter DLLs
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef FilterBase_H
#define FilterBase_H

#include "ISE.h"
#include "Service_ObjMgr.h"
#include "EventHeaderFactory.h"

#include <string>

#include "ace/SString.h"
#include "ace/Service_Config.h"
#include "ace/Service_Object.h"



class SamsonHeader;  // forward declaration not in Samson_Peer namespace

namespace Samson_Peer {

// ===================================================================================
// The Curiously Recurring Template Pattern (CRTP)
class ISE_Export FilterBase : public ACE_Service_Object
{
public:

	// Unlike "most" service objects, I need to override!
	FilterBase();
	virtual ~FilterBase();

	// These are inherited and should be passed down
	// These are called upon shared object load/unload.
	virtual int init(int argc, ACE_TCHAR *argv[]);
	virtual int fini(void);

	// inherited, yet I have to call it...hmmmm
	virtual int info (ACE_TCHAR **info_string, size_t length) const;

	// ...the meat of the matter
	virtual int process( ACE_Message_Block *event, EventHeader *eh) = 0;

	// output my state!
	friend ostream& operator<<(ostream& output, const FilterBase& p);

};

} // namespace

#endif
