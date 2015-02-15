/**
 *	@file SamsonModel.h
 *
 *	@class SamsonModel
 *
 *	@brief Base File for all Samson Models
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#define ISE_BUILD_DLL

#include "SamsonModel.h"
#include "SamsonHeader.h"
#include "DebugFlag.h"
#include "SharedAppMgr.h"
#include "Model_ObjMgr.h"
#include "MessageFunctor.hpp"

#include <math.h>
#include <sstream>
#include <string>

#include "ace/Reactor.h"
#include "ace/Thread_Manager.h"



namespace Samson_Peer {

double SamsonModel::deltaTimeMin = 1.0e-8;


// static int CaseCounter = 0;

//...................................................................................................
SamsonModel::SamsonModel() : AppBase(),
	timing_(),
	caseNumber_(1),
	frame_count_(0),
	currFrame_(0),
	currTime_(0.0),
	time_step_flag_(false),
	inFrame_(false),
	data_ready_(true),
	separate_advance_time_(false),
	send_end_frame_(true),
	mInitEvent (new InitEvent()),
	mInitCase (new InitCase()),
	mInitCaseCmp (new InitCaseComplete()),
	mAdvanceTime (new AdvanceTime()),
	mTimeAdvanced (new TimeAdvanced()),
	mStartFrame (new StartFrame()),
	mEndFrame (new EndFrame()),
	mEndCase (new EndCase()),
	mEndCaseCmp (new EndCaseComplete()),
	mEndRun (new EndRun()),
	mEndRunCmp (new EndRunComplete()),
	mRegisterEndEngage (new RegisterEndEngage()),
	mEndEngage (new EndEngagement()),
	mDispatcherCommand (new DispatcherCommand()),
	mPauseSimulation (new PauseSimulation()),
	mStartSimulation (new StartSimulation())
{
	ACE_TRACE("SamsonModel::SamsonModel");

	this->exec_timer_.start ();
}

//...................................................................................................
SamsonModel::~SamsonModel()
{
	ACE_hrtime_t measured;
	this->exec_timer_.stop ();
	this->exec_timer_.elapsed_microseconds (measured);
	ACE_DEBUG((LM_DEBUG,"Object Execution time %f\n", measured*1.0e-6 ));
	//  Print scheduling measurements

	if ( this->timing_.rate() > 0 ) this->schedule_stats_.print();
}

//...................................................................................................
int SamsonModel::init(int argc, ACE_TCHAR *argv[])
{
	ACE_TRACE("SamsonModel::init");

	// Receive Advance Time if we have a rate
	if ( this->timing_.rate() > 0 )
	{
		MessageFunctor<SamsonModel> advancetimefunctor (this,&SamsonModel::doAdvanceTime);
		mAdvanceTime->subscribe(&advancetimefunctor,0);
	}

	// Receive Start of Frame
	if ( this->timing_.rate() > 0 )
	{
		MessageFunctor<SamsonModel> startframefunctor (this,&SamsonModel::doStartFrame);
		mStartFrame->subscribe(&startframefunctor,0);
	}

	// Receive Monte Carlo Run InitCase
	MessageFunctor<SamsonModel> initcasefunctor (this,&SamsonModel::doInitCase);
	mInitCase->subscribe(&initcasefunctor,0);

	// Receive a Monte Carlo End of Case
	MessageFunctor<SamsonModel> endcasefunctor (this,&SamsonModel::doEndCase);
	mEndCase->subscribe(&endcasefunctor,0);

	// Receive a Monte Carlo End of Run
	MessageFunctor<SamsonModel> endrunfunctor (this,&SamsonModel::doEndRun);
	mEndRun->subscribe(&endrunfunctor,0);

	return this->AppBase::init(argc,argv);
}

//...................................................................................................
int SamsonModel::info (ACE_TCHAR **info_string, size_t length) const
{
	std::stringstream myinfo;
	myinfo << *this;
	//this->toText(myinfo);

	if (*info_string == 0)
		*info_string = ACE::strnew(myinfo.str().c_str());
	else
		ACE_OS::strncpy(*info_string, myinfo.str().c_str(), length);

	return ACE_OS::strlen(*info_string) +1;
}


//...................................................................................................
ostream& operator<<(ostream& output, const SamsonModel& p)
{
    output << dynamic_cast< const AppBase&>(p) << std::endl;
	output << "SamsonModel::"
    	<< " Case: " << p.caseNumber_
       	<< " Frame: " << p.frame_count_
       	<< " Time: " << p.currTime_
		<< " Step?: " << ((p.time_step_flag_)?"true":"false")
		<< " inFrame?: " << ((p.inFrame_)?"true":"false")
	;
	return output;
}

//////////////////////////////  Message Processing /////////////////////////////

//..............................................................................
// Object mInitCase
// calls MonteCarlo_InitCase
int SamsonModel::doInitCase (MessageBase *mb)
{
	ACE_TRACE("SamsonModel::doInitCase");

	// Reset time
	// TODO make this overridable
	this->currTime_ = 0.0;
	this->frame_count_ = 0;
	this->send_count_ = 0;
	const SamsonHeader *sh = mb->get_header();


	this->time_step_flag_ = true;
	this->caseNumber_ = mInitCase->case_number_;
	this->separate_advance_time_ = mInitCase->separate_advance_time_;
	this->send_end_frame_ = mInitCase->send_end_frame_;

	if (DebugFlag::instance ()->enabled (DebugFlag::APB_DEBUG) )
	{
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) SamsonModel::doInitCase(): Run=%d Msg=%d:%d Model=%d:%d at %f for case %d  AdvTime(%s) EndFrame(%s)\n",
			sh->run_id(),
			sh->message_id(),
			sh->app_msg_id(),
			sh->peer_id(),
			sh->unit_id(),
			this->currTime_,
			this->caseNumber_,
			(this->separate_advance_time_)?"true":"false",
			(this->send_end_frame_)?"true":"false"
		));
	}

	// Implemented in Concrete Model
	if ( MonteCarlo_InitCase (mb) > 0 ) this->sendInitCaseComplete ();

	return 1;
}

//..............................................................................
int SamsonModel::doAdvanceTime (MessageBase *mb)
{
	ACE_TRACE("SamsonModel::doAdvanceTime");

	if (DebugFlag::instance ()->enabled (DebugFlag::APB_DEBUG) )
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) SamsonModel::doAdvanceTime()\n"));

	const SamsonHeader *sh = mb->get_header();

	// Note:  Samson is a frame based system, pull the current frame from this messages
	this->currFrame_ = sh->frame_count();

	// Hold data messages until a StartFrame
	this->data_ready_=false;

	//  Calculate the current time from the message
	double t1 = this->currFrame_ * this->timing_.rate();
	if ( fabs( t1 - this->currTime_ ) > SamsonModel::deltaTimeMin &&
			(t1 - this->currTime_) > 0.0 )
	{
			this->currTime_ = t1;
	}
	else if ( this->currTime_ != 0.0 )
	{

		ACE_DEBUG ((LM_ERROR, "(%P|%t) SamsonModel::doAdvanceTime(): Run=%d Msg=%d:%d Model=%d:%d !!Error time is %f, new time = %f for case %d\n",
			sh->run_id(),
			sh->message_id(),
			sh->app_msg_id(),
			sh->peer_id(),
			sh->unit_id(),
			this->currTime_,
			t1,
			this->caseNumber_));
	}

	// TODO:  reconcile the frame and time for a "SamsonModel"

	this->sendTimeAdvanced ();

	return 1;
}

//..............................................................................
//  Object mStartFrame
//  calls  timeStep method
int SamsonModel::doStartFrame (MessageBase *mb)
{
	ACE_TRACE("SamsonModel::doStartFrame");

	// Increment the Frame Counter
	this->frame_count_++;

	// Allow data messages to be processed
	this->data_ready_=true;

	//  Calculate the current time from the message (iff there is no seperate advance time message)
	if ( !this->separate_advance_time_)
	{
		const SamsonHeader *sh = mb->get_header();

		// Note:  Samson is a frame based system, pull the current frame from this messages
		this->currFrame_ = sh->frame_count();

		double t1 = this->currFrame_ * this->timing_.rate();
		if ( fabs( t1 - this->currTime_ ) > SamsonModel::deltaTimeMin &&
				(t1 - this->currTime_) > 0.0 )
		{
				this->currTime_ = t1;
		}
	}

	if (DebugFlag::instance ()->enabled (DebugFlag::APB_DEBUG) )
	{
		const SamsonHeader *sh = mb->get_header();

		ACE_DEBUG ((LM_DEBUG, "(%P|%t) SamsonModel::doStartFrame(): Run=%d Msg=%d:%d Model=%d:%d at %f (%d*%f) for case %d (%s) (%s)\n",
			sh->run_id(),
			sh->message_id(),
			sh->app_msg_id(),
			sh->peer_id(),
			sh->unit_id(),
			this->currTime_,
			this->currFrame_,
			this->timing_.rate(),
			this->caseNumber_,
			this->time_step_flag_?"true":"false",
			this->separate_advance_time_?"true":"false"
		));
	}

	// TODO  investigate why this was set, it feels wrong
	if(this->time_step_flag_)
	{
		//  SamsonModel step should not result in an EndFrame Message
		this->inFrame_ = true;
		int result = MonteCarlo_Step (mb);
		if ( result > 0  && this->send_end_frame_)
		{
			this->sendEndFrame ();
			if (DebugFlag::instance ()->enabled (DebugFlag::APB_DEBUG) )
                                 ACE_DEBUG ((LM_DEBUG, "(%P|%t) SamsonModel::doStartFrame(): End Frame Sent\n"));

		}
		else if (DebugFlag::instance ()->enabled (DebugFlag::APB_DEBUG) )
				 ACE_DEBUG ((LM_DEBUG, "(%P|%t) SamsonModel::doStartFrame(): ????? NO End Frame Sent (%d)\n",result));

		//  TODO bad!!!  need to rethink this
		if ( result == 2 ) this->time_step_flag_ = false;
	}


	// Collect Start Frame timing
	static bool first_call = true;
	if (!first_call  && this->timing_.rate() > 0 )
	{
		ACE_hrtime_t measured;
		this->frame_timer_.stop ();
		this->frame_timer_.elapsed_microseconds (measured);
		this->schedule_stats_.sample (measured*1.0e-6);
	}
	else
		first_call = false;

	this->frame_timer_.start ();

	return 1;
}

//...................................................................................................
// Object mEndCase
int SamsonModel::doEndCase (MessageBase *mb)
{
	ACE_TRACE("SamsonModel::doEndCase");

	int retval = 0;

	if ( this->caseNumber_ != mEndCase->case_number_ )
	{
		ACE_DEBUG ((LM_ERROR, "(%P|%t) SamsonModel::doEndCase -> Invalid Case Number, expecting %d, got %d\n",
			this->caseNumber_, mEndCase->case_number_));
	}

	this->time_step_flag_ = false;

	// TODO  I need an idea how to keep out a firestorm with these, currently  only
	//  the executive and controller do this exchange !!!!
	if ( (retval = MonteCarlo_EndCase (mb)) != 0 ) this->sendEndCaseComplete ();

	if (DebugFlag::instance ()->enabled (DebugFlag::APB_DEBUG) )
	{
		const SamsonHeader *sh = mb->get_header();

		ACE_DEBUG ((LM_DEBUG, "(%P|%t) SamsonModel::doEndCase(): Run=%d Msg=%d:%d Model=%d:%d at %f for run %d -> %d\n",
			sh->run_id(),
			sh->message_id(),
			sh->app_msg_id(),
			sh->peer_id(),
			sh->unit_id(),
			this->currTime_,
			this->caseNumber_,
			retval
		));
	}

	return 1;
}

//...................................................................................................
// Object mEndRun
//  calls  MonteCarlo_EndRun()
int SamsonModel::doEndRun (MessageBase *mb)
{
	ACE_TRACE("SamsonModel::doEndRun");

	int retval = 0;

	// This send will disconnect  and allow model to close down
	if ( (retval = MonteCarlo_EndRun (mb)) > 0 )
	{
		this->sendEndRunComplete();
	}

	//if (DebugFlag::instance ()->enabled (DebugFlag::APB_DEBUG) )
	{
		const SamsonHeader *sh = mb->get_header();

		ACE_DEBUG ((LM_DEBUG, "(%P|%t) SamsonModel::doEndRun(): Run=%d Msg=%d:%d Model=%d:%d at %f -> %d\n",
			sh->run_id(),
			sh->message_id(),
			sh->app_msg_id(),
			sh->peer_id(),
			sh->unit_id(),
			this->currTime_,
			retval
		));
	}

    return 1;
}

//...................................................................................................
//  Shortcuts for sending messages

void SamsonModel::sendInitCase()
{
	SamsonHeader *sh = new SamsonHeader();

	sh->run_id (this->run_id_);
	sh->peer_id (this->model_id_);
	sh->unit_id (this->unit_id_);
	sh->enable(SimMsgFlag::trace);
	sh->dest_peer_id(0);
	sh->frame_count(this->currFrame_);
	sh->send_count(this->send_count_++);

	mInitCase->case_number_ = this->caseNumber_;
	mInitCase->separate_advance_time_ = this->separate_advance_time_;
	mInitCase->send_end_frame_ = this->send_end_frame_;
	mInitCase->publish(sh);
}

void SamsonModel::sendInitCaseComplete()
{
	SamsonHeader *sh = new SamsonHeader();

	sh->run_id (this->run_id_);
	sh->peer_id (this->model_id_);
	sh->unit_id (this->unit_id_);
	sh->enable(SimMsgFlag::trace);
	sh->dest_peer_id(0);
	sh->frame_count(this->currFrame_);
	sh->send_count(this->send_count_++);

	this->mInitCaseCmp->publish(sh);
}


void SamsonModel::sendStartFrame(unsigned int)
{
	SamsonHeader *sh = new SamsonHeader();

	sh->run_id (this->run_id_);
	sh->peer_id (this->model_id_);
	sh->unit_id (this->unit_id_);
	sh->enable(SimMsgFlag::trace);
	//sh->enable(SimMsgFlag::log_it);
	sh->dest_peer_id(0);
	sh->frame_count(this->currFrame_);
	sh->send_count(this->send_count_++);

	this->mStartFrame->publish(sh);
}


void SamsonModel::sendEndFrame()
{
	this->inFrame_ = false;

	SamsonHeader *sh = new SamsonHeader();

	sh->run_id (this->run_id_);
	sh->peer_id (this->model_id_);
	sh->unit_id (this->unit_id_);
	sh->enable(SimMsgFlag::trace);
	sh->dest_peer_id(0);
	sh->frame_count(this->currFrame_);
	sh->send_count(this->send_count_++);

	this->mEndFrame->publish(sh);
}

void SamsonModel::sendAdvanceTime(void)
{
	SamsonHeader *sh = new SamsonHeader();

	sh->run_id (this->run_id_);
	sh->peer_id (this->model_id_);
	sh->unit_id (this->unit_id_);
	sh->enable(SimMsgFlag::trace);
	//sh->enable(SimMsgFlag::log_it);
	sh->dest_peer_id(0);
	sh->frame_count(this->currFrame_);
	sh->send_count(this->send_count_++);

	this->mAdvanceTime->publish(sh);
}

void SamsonModel::sendTimeAdvanced(void)
{
	SamsonHeader *sh = new SamsonHeader();

	sh->run_id (this->run_id_);
	sh->peer_id (this->model_id_);
	sh->unit_id (this->unit_id_);
	sh->enable(SimMsgFlag::trace);
	sh->dest_peer_id(0);
	sh->frame_count(this->currFrame_);
	sh->send_count(this->send_count_++);

	mTimeAdvanced->publish(sh);
}

void SamsonModel::sendEndCase(void)
{
	SamsonHeader *sh = new SamsonHeader();

	sh->run_id (this->run_id_);
	sh->peer_id (this->model_id_);
	sh->unit_id (this->unit_id_);
	sh->enable(SimMsgFlag::trace);
	sh->dest_peer_id(0);
	sh->frame_count(this->currFrame_);
	sh->send_count(this->send_count_++);

	mEndCase->case_number_ = this->caseNumber_;
	mEndCase->publish(sh);
}

void SamsonModel::sendEndCaseComplete(void)
{
	SamsonHeader *sh = new SamsonHeader();

	sh->run_id (this->run_id_);
	sh->peer_id (this->model_id_);
	sh->unit_id (this->unit_id_);
	sh->enable(SimMsgFlag::trace);
	sh->dest_peer_id(0);
	sh->frame_count(this->currFrame_);
	sh->send_count(this->send_count_++);

	this->mEndCaseCmp->publish(sh);
}

void SamsonModel::sendEndRun(void)
{
	SamsonHeader *sh = new SamsonHeader();

	sh->run_id (this->run_id_);
	sh->peer_id (this->model_id_);
	sh->unit_id (this->unit_id_);
	sh->enable(SimMsgFlag::trace);
	sh->dest_peer_id(0);
	sh->frame_count(this->currFrame_);
	sh->send_count(this->send_count_++);

	this->mEndRun->publish(sh);
}

void SamsonModel::sendEndRunComplete(void)
{
	SamsonHeader *sh = new SamsonHeader();

	sh->run_id (this->run_id_);
	sh->peer_id (this->model_id_);
	sh->unit_id (this->unit_id_);
	sh->enable(SimMsgFlag::trace);
	sh->dest_peer_id(0);
	sh->frame_count(this->currFrame_);
	sh->send_count(this->send_count_++);

	this->mEndRunCmp->publish(sh);
}

void SamsonModel::sendRegisterEndEngage(void)
{
	SamsonHeader *sh = new SamsonHeader();

	sh->run_id (this->run_id_);
	sh->peer_id (this->model_id_);
	sh->unit_id (this->unit_id_);
	sh->enable(SimMsgFlag::trace);
	sh->dest_peer_id(0);
	sh->frame_count(this->currFrame_);
	sh->send_count(this->send_count_++);

	mRegisterEndEngage->publish(sh);
}

void SamsonModel::sendEndEngage(void)
{
	SamsonHeader *sh = new SamsonHeader();

	sh->run_id (this->run_id_);
	sh->peer_id (this->model_id_);
	sh->unit_id (this->unit_id_);
	sh->enable(SimMsgFlag::trace);
	sh->dest_peer_id(0);
	sh->frame_count(this->currFrame_);
	sh->send_count(this->send_count_++);

	ACE_DEBUG ((LM_DEBUG, "(%P|%t) SamsonModel::sendEndEngage() "));
	sh->print();

	mEndEngage->publish(sh);
}

void SamsonModel::sendDispatcherCommand(std::string &cmd)
{
	SamsonHeader *sh = new SamsonHeader();

	sh->run_id (this->run_id_);
	sh->peer_id (0);
	sh->unit_id (0);
	sh->enable(SimMsgFlag::trace);
	sh->dest_peer_id(0);

	ACE_DEBUG ((LM_DEBUG, "(%P|%t) SamsonModel::sendDispatcherCommand(%s) ",cmd.c_str()));
	sh->print();

	mDispatcherCommand->Command(cmd.c_str());
	mDispatcherCommand->publish(sh);
}

} // namespace
