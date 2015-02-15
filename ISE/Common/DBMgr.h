/**
 *	@class DBMgr
 *
 *	@brief Handles all interactions with the central database
 *
 *	This object is used as the main interface to the central database
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef DBMgr_h
#define DBMgr_h

#include "ISE.h"

#include <string>

#include "ace/Thread_Mutex.h"
#include "ace/Recursive_Thread_Mutex.h"
#include "ace/Event_Handler.h"
#include "ace/Service_Object.h"


struct st_mysql_res; // forward declaration (MYSQL_RES)
struct st_mysql; // forward declaration (MYSQL)

namespace Samson_Peer {

// ================================================================================
class ISE_Export DBMgr
{
public:
	DBMgr (bool pers=false, bool autoConnect=false, const char *host="localhost", const char *db="Delilah");
	~DBMgr();

	//MYSQL_RES *doQuery (char *sql, bool ignoreDup);
	//void freeQuery (MYSQL_RES *result);
	//void printQryResult (MYSQL_RES *result);

	st_mysql_res *doQuery ( const char * const sql, bool ignoreDup);
	st_mysql_res *doQuery ( std::string& sql, bool ignoreDup) { return doQuery(const_cast<char*>(sql.c_str()), ignoreDup); }

	void doMultiQuery(char *sql, bool ignoreDup);
	void doMultiQuery(std::string& sql, bool ignoreDup) { doMultiQuery(const_cast<char*>(sql.c_str()), ignoreDup); }
	void freeQuery (st_mysql_res *result);
	void printQryResult (st_mysql_res *result);

	void DeleteRecord(char *Table, int id);

	unsigned long InsertGetId (char *sql, bool ignoreDup);
	unsigned long LookupAddID (char *SelSQL, char *InsSQL, bool debug=false);
	unsigned long LookupInt (char *SelSQL);

	//int affected_rows() { return (int) mysql_affected_rows(conn_); }
	int affected_rows();

	void open (void);
	void close (void);

	bool error (void) { return this->error_; }

	int persist_watchdog (void);

protected:

	void print_error (void);

	st_mysql *conn_;
	//MYSQL *conn_;

	bool error_;
	bool persist_;

	std::string host_;
	std::string db_;

	enum { isConnected, isDisconnected } state_;

	ACE_Recursive_Thread_Mutex mutex_;
};

}  // namespace

#endif
