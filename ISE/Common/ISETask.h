#ifndef ISETASK_H_
#define ISETASK_H_

#include "ISE.h"

#include "ace/Task.h"
#include "ace/Reactor.h"
#include "ace/TP_Reactor.h"
#include "ace/OS_NS_signal.h"
#include "ace/OS_NS_stdio.h"
#include "ace/OS_NS_string.h"
#include "ace/OS_NS_unistd.h"
#include "ace/Synch_Traits.h"
#include "ace/Thread_Semaphore.h"


namespace Samson_Peer {

class ISETask : public ACE_Task<ACE_MT_SYNCH>
{
public:
	static ISETask *instance (void);
	// Return Singleton.
	
	virtual ~ISETask()
	{
		stop();
	}

	virtual int svc(void);

	int start(int num_threads);
	int stop(void);

private:
	ISETask(void) :
		sem_((unsigned int) 0), my_reactor_(0)
	{
	}

	static ISETask *instance_;
	// Singleton.

	int create_reactor(void);
	int delete_reactor(void);

	ACE_SYNCH_RECURSIVE_MUTEX lock_;
	ACE_Thread_Semaphore sem_;
	ACE_Reactor *my_reactor_;
};

} // namespace

#endif /*ISETASK_H_*/
