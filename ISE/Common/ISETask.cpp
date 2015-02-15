#define ACE_BUILD_SVC_DLL

#include "ISETask.h"

#include "ace/Log_Msg.h"

namespace Samson_Peer
{

// Static initialization.
ISETask *ISETask::instance_ = 0;

// -----------------------------------------------------------------
ISETask *
ISETask::instance (void)
{
	if (ISETask::instance_ == 0)
		ACE_NEW_RETURN (ISETask::instance_, ISETask, 0);

	return ISETask::instance_;
}

// -----------------------------------------------------------------
int ISETask::create_reactor(void)
{
	ACE_GUARD_RETURN(ACE_SYNCH_RECURSIVE_MUTEX, monitor, this->lock_, -1);
	ACE_ASSERT(this->my_reactor_ == 0);
	ACE_TP_Reactor * pImpl = 0;
	ACE_NEW_RETURN(pImpl, ACE_TP_Reactor, -1);
	ACE_NEW_RETURN(my_reactor_, ACE_Reactor(pImpl, 1), -1);

	// Attempt to fix a stall
	// my_reactor_->max_notify_iterations(2);

	ACE_Reactor::instance(this->my_reactor_);
	this->reactor(my_reactor_);

	// ACE_DEBUG((LM_DEBUG, ACE_TEXT("(%P|%t) Create TP_Reactor\n")));
	return 0;
}

// -----------------------------------------------------------------
int ISETask::delete_reactor(void)
{
	ACE_GUARD_RETURN(ACE_SYNCH_RECURSIVE_MUTEX, monitor, this->lock_, -1);
	delete this->my_reactor_;
	ACE_Reactor::instance((ACE_Reactor *) 0);
	this->my_reactor_ = 0;
	this->reactor(0);

	//ACE_DEBUG((LM_DEBUG, ACE_TEXT("(%P|%t) Deleted TP_Reactor\n")));
	return 0;
}

// -----------------------------------------------------------------
int ISETask::start(int num_threads)
{
	ACE_DEBUG ((LM_DEBUG,"(%P|%t) ISETask::start(%d)\n",num_threads));

	if (this->create_reactor() == -1)
		ACE_ERROR_RETURN((LM_ERROR, ACE_TEXT("(%P|%t) %p.\n"),
				ACE_TEXT("unable to create reactor")), -1);

	if (this->activate(THR_NEW_LWP, num_threads) == -1)
		ACE_ERROR_RETURN((LM_ERROR, ACE_TEXT("(%P|%t) %p.\n"),
				ACE_TEXT("unable to activate thread pool")), -1);

	for (; num_threads > 0; num_threads--)
		this->sem_.acquire();

	return 0;
}

// -----------------------------------------------------------------
int ISETask::stop(void)
{
	if (this->my_reactor_ != 0)
	{
		ACE_DEBUG((LM_DEBUG, ACE_TEXT("(%P|%t) Ending TP_Reactor event loop\n")));
		ACE_Reactor::instance()->end_reactor_event_loop();
	}

	if (this->wait() == -1)
		ACE_ERROR((LM_ERROR, ACE_TEXT("(%P|%t) %p.\n"),
				ACE_TEXT("unable to stop thread pool")));

	if (this->delete_reactor() == -1)
		ACE_ERROR((LM_ERROR, ACE_TEXT("(%P|%t) %p.\n"),
				ACE_TEXT("unable to delete reactor")));

	return 0;
}

// -----------------------------------------------------------------
int ISETask::svc(void)
{
	//ACE_DEBUG((LM_DEBUG, ACE_TEXT("(%P|%t) ISETask started\n")));

	// signal that we are ready
	this->sem_.release(1);

	while (ACE_Reactor::instance()->reactor_event_loop_done() == 0)
		ACE_Reactor::instance()->run_reactor_event_loop();

	ACE_DEBUG((LM_DEBUG, ACE_TEXT("(%P|%t) ISETask finished\n")));
	return 0;
}

} // namespace
