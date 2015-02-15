#ifndef ISE_TRACE_H
#define ISE_TRACE_H

#include "ace/Trace.h"

// 0 turns on ACE_TRACE
//#undef  ACE_NTRACE
#ifndef ACE_NTRACE
#define ACE_NTRACE 0
#endif
// 1 strips debug logging from the copiler
#define ACE_NDEBUG 0

#endif
