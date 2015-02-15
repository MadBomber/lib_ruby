#ifndef LOGLOCKER_H_
#define LOGLOCKER_H_

#include "ISE.h"
#include "ace/Log_Msg.h"

class LogLocker
{
public:

  LogLocker () { ACE_LOG_MSG->acquire (); }
  virtual ~LogLocker () { ACE_LOG_MSG->release (); }
};

#endif /*LOGLOCKER_H_*/
