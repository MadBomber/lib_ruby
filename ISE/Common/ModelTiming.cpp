/**
 *	@file ModelTiming.h
 * 
 *	@class ModelTiming
 * 
 *	@brief Base File for all Samson Models
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#define ISE_BUILD_DLL

#include "DebugFlag.h"
#include "ModelTiming.h"
#include "Model_ObjMgr.h"

namespace Samson_Peer {


//...................................................................................................
void
ModelTiming::set(int freq)
{
	if ( freq != 0)
	{
		this->frequency_ = freq;
		this->rate_ = 1.0/this->frequency_;
	}
	else
	{
		this->rate_ = 0.0;
		this->frequency_ = 0;
	}

	if (DebugFlag::instance ()->enabled (DebugFlag::VERBOSE))
	{
		ACE_DEBUG ((LM_INFO, "(%P|%t) ModelTiming::set(%d) -> rate %f\n", freq, this->rate_));
	}

	SAMSON_OBJMGR::instance ()->setRate (this->rate_); // sets the database
}

//...................................................................................................
void
ModelTiming::set(double arate)
{
	if ( arate != 0.0)
	{
		this->rate_ = arate;
		this->frequency_ = int(1.0 / arate);
	}
	else
	{
		this->rate_ = 0.0;
		this->frequency_ = 0;
	}

	SAMSON_OBJMGR::instance ()->setRate (this->rate_); // sets the database
	//SAMSON_OBJMGR::instance ()->setReady ();  //  this is the last event in the chain, chould I set this or let each client.
}

} // namespace
