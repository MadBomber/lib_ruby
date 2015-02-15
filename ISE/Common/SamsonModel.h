/**
 *	@file SamsonModel.h
 *
 *	@class SamsonModel
 *
 *	@brief Base File for all SAMSON Models
 *
 *	This object is used as the base class of all SAMSON models
 *
 *	@note Attempts at zen rarely work.
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>, (C) 2006
 *
 */

#ifndef Samson_Model_Appbase_H
#define Samson_Model_Appbase_H

#include "ISE.h"

#include "AppBase.h"
#include "ModelTiming.h"
#include "Model_ObjMgr.h"
#include "sql_oarchive.h"
#include "DeltaTimeStats.h"

//... messages this will publish and/or subscribe
#include "Messages/InitEvent.h"
#include "Messages/StartFrame.h"
#include "Messages/EndFrame.h"
#include "Messages/InitCase.h"
#include "Messages/InitCaseComplete.h"
#include "Messages/Shutdown.h"
#include "Messages/InitCase.h"
#include "Messages/EndCase.h"
#include "Messages/EndCaseComplete.h"
#include "Messages/EndRun.h"
#include "Messages/EndRunComplete.h"
#include "Messages/AdvanceTime.h"
#include "Messages/TimeAdvanced.h"
#include "Messages/RegisterEndEngage.h"
#include "Messages/EndEngagement.h"
#include "Messages/DispatcherCommand.h"
#include "Messages/PauseSimulation.h"
#include "Messages/StartSimulation.h"

#include "ace/High_Res_Timer.h"

class SamsonHeader; // forward declaration (not in Samson_Peer namespace)

namespace Samson_Peer {

// =====================================================================
class ISE_Export SamsonModel : public AppBase
{
public:

	// TODO  evaluate elevating this
	static double deltaTimeMin;

	// to get state information
	virtual int info (ACE_TCHAR **info_string, size_t length) const;

	// Used to subscribe to the proper messages
	virtual int init(int argc, ACE_TCHAR *argv[]);

	// Unlike "most" service objects, I need to override!
	SamsonModel();
	virtual ~SamsonModel();

	// output my state!
	friend ISE_Export ostream& operator<<(ostream& output, const SamsonModel& p);


	template<class Archive>
	void serialize(Archive & ar, const unsigned int )
	{
		ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(AppBase);

		// ar & BOOST_SERIALIZATION_NVP(timing_);
		ar & BOOST_SERIALIZATION_NVP(caseNumber_);
		ar & BOOST_SERIALIZATION_NVP(frame_count_);
		ar & BOOST_SERIALIZATION_NVP(currTime_);
		ar & BOOST_SERIALIZATION_NVP(time_step_flag_);
		ar & BOOST_SERIALIZATION_NVP(inFrame_);
	}

	void toDB(const std::string& modelName)
	{
		std::string sql;
		{
			sql_oarchive oa(sql, "SamsonModel");
			oa & boost::serialization::make_nvp(modelName.c_str(), *this);
		}
		Samson_Peer::SAMSON_OBJMGR::instance()->doRunQuery(sql);
	}

	void toXML (std::stringstream &ofs) const
	{
		boost::archive::xml_oarchive oa(ofs,7);
		oa << BOOST_SERIALIZATION_NVP(this);
	}

	void toText (std::stringstream &ofs) const
	{
		boost::archive::text_oarchive oa(ofs);
		oa << *this;
	}

	void StartFrameOnly(void) { this->separate_advance_time_=false; }
	void NoEndFrameResponse(void) { this->send_end_frame_=false; }

	virtual unsigned int current_frame (void) { return this->currFrame_; }

	virtual bool data_ready (void) { return this->data_ready_; }

	// send out a dispatcher command
	void sendDispatcherCommand(std::string &cmd);

protected:

	// Message Processing Functions that can be overridden in the model
	virtual int MonteCarlo_InitCase (MessageBase *) = 0;
	virtual int MonteCarlo_Step (MessageBase *) = 0;
	virtual int MonteCarlo_EndCase (MessageBase *) = 0;
	virtual int MonteCarlo_EndRun (MessageBase *) = 0;

	// Message Processing Functions (NON-VIRTUAL)
	int doAdvanceTime (MessageBase *);
	int doStartFrame (MessageBase *);
	int doInitCase (MessageBase *);
	int doEndCase (MessageBase *);
	int doEndRun (MessageBase *);

	// Shortcuts for messages to send
	void sendStartFrame(unsigned int modelID);
	void sendEndFrame();

	void sendInitCaseComplete(void);
	void sendInitCase(void);

	void sendEndCase(void);
	void sendEndCaseComplete(void);

	void sendEndRun(void);
	void sendEndRunComplete(void);

	void sendTimeAdvanced(void);
	void sendAdvanceTime(void);

	void sendRegisterEndEngage(void);
	void sendEndEngage(void);

	// Sets the timing for a model
	ModelTiming timing_;

	// Current Case Number being worked
	int caseNumber_;

	// Current frame count, set by doStartFrame (our internal counter)
	unsigned int frame_count_;

	// Current frame count, set by doStartFrame (message)
	unsigned int currFrame_;

	// Current time, set by doStartFrame (message)
	double currTime_;

	//  Advance Time
	bool time_step_flag_;

	// InFrame
	bool inFrame_;

	// Ready to accept data messages
	bool data_ready_;

	// AdvanceTime or StartFrame message moves times?
	bool separate_advance_time_;

	// Is an EndFrame message to be sent?
	bool send_end_frame_;

	// Elapsed time from construct to destruct
	ACE_High_Res_Timer exec_timer_;

	// timer to track start of frames
	ACE_High_Res_Timer frame_timer_;

	// Collect timer Stats
	DeltaTimeStats schedule_stats_;

	// MessageBase Objects for ALL simulation models
	boost::scoped_ptr<InitEvent> mInitEvent;
	boost::scoped_ptr<InitCase> mInitCase;
	boost::scoped_ptr<InitCaseComplete> mInitCaseCmp;
	boost::scoped_ptr<AdvanceTime> mAdvanceTime;
	boost::scoped_ptr<TimeAdvanced> mTimeAdvanced;
	boost::scoped_ptr<StartFrame> mStartFrame;
	boost::scoped_ptr<EndFrame>mEndFrame;
	boost::scoped_ptr<EndCase> mEndCase;
	boost::scoped_ptr<EndCaseComplete> mEndCaseCmp;
	boost::scoped_ptr<EndRun> mEndRun;
	boost::scoped_ptr<EndRunComplete> mEndRunCmp;
	boost::scoped_ptr<RegisterEndEngage> mRegisterEndEngage;
	boost::scoped_ptr<EndEngagement> mEndEngage;
	boost::scoped_ptr<DispatcherCommand> mDispatcherCommand;
	boost::scoped_ptr<PauseSimulation> mPauseSimulation;
	boost::scoped_ptr<StartSimulation> mStartSimulation;
};

} // namespace

#endif
