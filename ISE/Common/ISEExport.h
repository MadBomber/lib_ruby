// -*- C++ -*-
//
// Definition for Win32 Export directives.
// This file is generated automatically by generate_export_file.pl ISE
// ------------------------------
#ifndef ISE_EXPORT_H
#define ISE_EXPORT_H

#include "ace/config-all.h"

#if defined (ACE_AS_STATIC_LIBS) && !defined (ISE_HAS_DLL)
#  define ISE_HAS_DLL 0
#endif /* ACE_AS_STATIC_LIBS && ISE_HAS_DLL */

#if !defined (ISE_HAS_DLL)
#  define ISE_HAS_DLL 1
#endif /* ! ISE_HAS_DLL */

#if defined (ISE_HAS_DLL) && (ISE_HAS_DLL == 1)
#  if defined (ISE_BUILD_DLL)
#    define ISE_Export ACE_Proper_Export_Flag
#    define ISE_SINGLETON_DECLARATION(T) ACE_EXPORT_SINGLETON_DECLARATION (T)
#    define ISE_SINGLETON_DECLARE(SINGLETON_TYPE, CLASS, LOCK) ACE_EXPORT_SINGLETON_DECLARE(SINGLETON_TYPE, CLASS, LOCK)
#  else /* ISE_BUILD_DLL */
#    define ISE_Export ACE_Proper_Import_Flag
#    define ISE_SINGLETON_DECLARATION(T) ACE_IMPORT_SINGLETON_DECLARATION (T)
#    define ISE_SINGLETON_DECLARE(SINGLETON_TYPE, CLASS, LOCK) ACE_IMPORT_SINGLETON_DECLARE(SINGLETON_TYPE, CLASS, LOCK)
#  endif /* ISE_BUILD_DLL */
#else /* ISE_HAS_DLL == 1 */
#  define ISE_Export
#  define ISE_SINGLETON_DECLARATION(T)
#  define ISE_SINGLETON_DECLARE(SINGLETON_TYPE, CLASS, LOCK)
#endif /* ISE_HAS_DLL == 1 */

// Set ISE_NTRACE = 0 to turn on library specific tracing even if
// tracing is turned off for ACE.
#if !defined (ISE_NTRACE)
#  if (ACE_NTRACE == 1)
#    define ISE_NTRACE 1
#  else /* (ACE_NTRACE == 1) */
#    define ISE_NTRACE 0
#  endif /* (ACE_NTRACE == 1) */
#endif /* !ISE_NTRACE */

#if (ISE_NTRACE == 1)
#  define ISE_TRACE(X)
#else /* (ISE_NTRACE == 1) */
#  if !defined (ACE_HAS_TRACE)
#    define ACE_HAS_TRACE
#  endif /* ACE_HAS_TRACE */
#  define ISE_TRACE(X) ACE_TRACE_IMPL(X)
#  include "ace/Trace.h"
#endif /* (ISE_NTRACE == 1) */

#endif /* ISE_EXPORT_H */

// End of auto generated file.
