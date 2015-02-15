/**
 *	@file DBMgr.cpp
 *
 *	@class DBMgr
 *
 *	@brief Used to coordinate with Database, used for both Service and Model
 *
 *	This object is used to encapsulate the interface to the MySQL database
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#define ISE_BUILD_DLL

#include "DBMgr.h"
#include "DebugFlag.h"

#include "ace/Log_Msg.h"
#include "ace/Reactor.h"

// TODO ERROR I cannot include this file on linux or it mucks with the ACE macros for library exporting ARRRRGGGGG
//#include <my_global.h>
#include <mysql.h>

// Need function prototype...this is a potential problem
extern "C" { char my_init(void); }

#include <errmsg.h>
#include <time.h>
#include <string>

namespace Samson_Peer {

// =================================================================================================
// Trick to keep ensure the database connection does not die as we don't recover very well!
// returns -1 for error, 0 for good
int DBMgr::persist_watchdog (void)
{
	//ACE_DEBUG ((LM_INFO, "(%P|%t) MySQLWatchDog::handle_timeout\n"));
	int retval = -1;

	std::string qry_str("select 1 from Dual");
	MYSQL_RES  *result = this->doQuery (qry_str, false);
	if ( result != NULL )
	{
		mysql_free_result(result);
		retval = 0;
	}

	return retval;
}

// =================================================================================================
// put here dues to mysql compilation problem on windows!
int DBMgr::affected_rows() { return (int) mysql_affected_rows(conn_); }

// =================================================================================================

//..................................................................................................
/**
 * Constructor, this does not do the opening to the database, sets a state flag
 *
 * I have mixed feelings about peristance, this is a tunable parameter on the client
 * and if there is no activity, then shutting down the connection is a good idea.
 * The dilema is that there is no "active signal from the server that our connection
 * needs to be started again.
 *
 * @param pers should the connection be peristant
 * @return none
 */
DBMgr::DBMgr (bool pers, bool autoConnect, const char *host, const char *db)
{
	// mysql stuff
	this->conn_ = 0;
	this->state_ = isDisconnected;
	this->persist_ = pers;
	this->db_ = db;
	this->host_ = host;
	this->error_ = false;

	this->host_ = ACE_OS::getenv("ISE_QUEEN");  // TODO  fix to do localhost if not set

	// Initialize global variables, and thread handler in thread-safe programs
	my_init();

	// Initialize the MySQL C API library
	mysql_library_init(-1,0,0);

	if (DebugFlag::instance ()->enabled (DebugFlag::DB_DEBUG) )
	{
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) DBMgr::DBMgr(%d,%d,%s,%s)\n", this->persist_, autoConnect, this->host_.c_str(), this->db_.c_str()));
	}

	if (autoConnect) this->open();
}


//..................................................................................................

/**
 * Destructor, it makes sure we are disconnected before terminating
 *
 * @return none
 */
DBMgr::~DBMgr ()
{
	ACE_TRACE("DBMgr::~DBMgr");
	if (this->state_ == isConnected) this->close();

	// 	Finalize the MySQL C API library
	mysql_library_end();
}

//..................................................................................................

/**
 * Open out connecton to the database
 */
void
DBMgr::open (void)
{

	ACE_TRACE("DBMgr::open");


	if ( this->state_ == isDisconnected )
	{
		this->error_ = false;

		// allocates and retrieves the database handle
		this->conn_ = mysql_init (this->conn_);
		if ( this->conn_ == NULL )
		{
			ACE_DEBUG((LM_ERROR,"(%P|%t) DBMgr::open() mysql_init allocation failure\n"));
			this->error_  = true;
			return;
		}
#if 0
		else if (DebugFlag::instance ()->enabled (DebugFlag::DB_DEBUG) )
		{
			 ACE_DEBUG ((LM_DEBUG, "(%P|%t) DBMgr::open() connection addr %x\n",this->conn_));
		}
#endif

		//  complete connection  (returns NULL for failure and the value of the first argument for success )
		//  The host is from the ISE_QUEEN environmental variable
		//  The username is Samson with no password
		//  The database name defaults to Samson

		if (mysql_real_connect(this->conn_, this->host_.c_str(), "Samson", "Samson", this->db_.c_str(), 0, NULL,
				(this->persist_ ? CLIENT_INTERACTIVE : 0)) == NULL)
		{
			ACE_DEBUG((LM_ERROR,"(%P|%t) DBMgr::open() Database connection failure %s on %s (FATAL?)\n",
					this->db_.c_str(), this->host_.c_str()));
			this->print_error ();
			this->close ();
			this->error_  = true;
			return;
		}

		mysql_set_server_option(this->conn_, MYSQL_OPTION_MULTI_STATEMENTS_ON);

		this->state_ = isConnected;
	}

	if (DebugFlag::instance ()->enabled (DebugFlag::DB_DEBUG) )
	{
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) DBMgr::open() (Complete)\n"));
	}

}

//..................................................................................................

/**
 * Closes our connection to the Database
 */
void
DBMgr::close (void)
{
	ACE_TRACE("DBMgr::close");

	if ( this->conn_ )
	{
		//ACE_DEBUG ((LM_DEBUG, "(%P|%t) DBMgr::close()\n"));
		mysql_close (this->conn_);  // returns handle, no error return
		this->conn_ = 0;
	}

	// I moved this, outside of if test...I need this set to be able to re-connect.
	this->state_ = isDisconnected;

	if (DebugFlag::instance ()->enabled (DebugFlag::DB_DEBUG) )
	{
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) DBMgr::close()\n"));
	}
}

//..................................................................................................

/**
 * A generic print error routing
 */
void
DBMgr::print_error ()
{
    if ( this->conn_ != NULL )
    {
#if MYSQL_VERSION_ID >= 40101
        ACE_DEBUG((LM_ERROR,"(%P|%t) DBMgr::Error-> Errno=%u State=%s  (%s)\n", mysql_errno(conn_), mysql_sqlstate(conn_), mysql_error(conn_)));
#else
        ACE_DEBUG((LM_ERROR,"(%P|%t) DBMgr::Error-> Errno=%u State=%s\n", mysql_errno(conn_), mysql_error(conn_)));
#endif
	}
}

//..................................................................................................

/**
 * A generic doQuery routing, pass in the SQL and let 'er rip!
 *
 * @param sql the sql code to be executed
 * @param ignoreDup if the returned error code was a duplication entry
 * @return the results of the query
 */
MYSQL_RES *
DBMgr::doQuery (const char * const sql, bool ignoreDup )
{
	ACE_TRACE("DBMgr::doQuery");

	ACE_Guard<ACE_Recursive_Thread_Mutex> locker (mutex_);

REQUERY:

	MYSQL_RES *result = NULL;
	int err = 0;

	if ( !this->error_ )
	{
		// Try one last time to open the database, if it fails return the NULL
		if ( this->state_ == isDisconnected ) this->open();

		if ( this->state_ == isConnected )
		{
			if ( (err = mysql_query(this->conn_,sql)) != 0 )
			{
				if ( err == CR_SERVER_LOST || err == CR_SERVER_GONE_ERROR )
				{
					this->close();
					ACE_OS::sleep(1);
					ACE_DEBUG((LM_ERROR,"(%P|%t) DBMgr::doQuery(%s)-> REQUERY(%d)\n",sql,mysql_errno(this->conn_)));
					goto REQUERY;
				}
				else if ( ignoreDup && mysql_errno(this->conn_) != 1062 )
				{
					ACE_DEBUG((LM_ERROR,"(%P|%t) DBMgr::doQuery(%s)->%d\n",sql,err));
					this->print_error();
				}
			}
			else
			{
				result = mysql_store_result(this->conn_);
			}
		}
		else
		{
			ACE_DEBUG((LM_ERROR,"(%P|%t) DBMgr::doQuery(%s)-> OPEN FAILED(%d)\n",sql,mysql_errno(this->conn_)));
		}
	}
	return result;
}


void
DBMgr::doMultiQuery(char *sql, bool ignoreDup)
{
	ACE_TRACE("DBMgr::doMultiQuery");

	if ( !this->error_ )
	{
		ACE_Guard<ACE_Recursive_Thread_Mutex> locker (mutex_);
REQUERY:
		MYSQL_RES *result = NULL;
		int err = 0;

		if ( this->state_ == isDisconnected ) this->open();

		if (this->state_ == isConnected )
		{
			if ( (err=mysql_query(this->conn_,sql) != 0))
			{
				if ( err == CR_SERVER_LOST || err == CR_SERVER_GONE_ERROR )
				{
					this->close();
					ACE_OS::sleep(1);
					ACE_DEBUG((LM_ERROR,"(%P|%t) DBMgr::doQuery(%s)-> doMultiQuery(%d)\n",sql,mysql_errno(this->conn_)));
					goto REQUERY;
				}
				else if (ignoreDup && mysql_errno(this->conn_) != 1062)
				{
					ACE_DEBUG((LM_ERROR, "(%P|%t) DBMgr::doMultiQuery(%s)->%d\n",sql,err));
					this->print_error();
				}
			}
			else
			{
				do
				{
					result = mysql_store_result(this->conn_);

					if (result)
					{
						//process_result_set(this->conn_, result);
						mysql_free_result(result);
					}

					err = mysql_next_result(this->conn_);
				}
				while (err == 0);

			}
		}
	}
}


//..................................................................................................

/**
 * I was having troubles knowing when to free and when not, this takes care of that
 *
 * @param result the result from a previously executed query
 */
void
DBMgr::freeQuery(MYSQL_RES *result)
{
	if (result != NULL )
		mysql_free_result(result);
	/*
	else if (DebugFlag::instance ()->enabled (DebugFlag::DB_DEBUG) )
	{
		ACE_DEBUG ((LM_DEBUG, "DBMgr::freeQuery()  ERROR  FREEING NULL RESULT\n"));
	}
	*/

}

//..................................................................................................

/**
 * This is mostly for debug, generic print for a query
 *
 * @param result the result from a previously executed query
 */
void
DBMgr::printQryResult(MYSQL_RES *result)
{
	MYSQL_ROW row;
	int num_fields = mysql_num_fields(result);
	int j = 0;
	while ((row = mysql_fetch_row(result)))
	{
		unsigned long *lengths;
		lengths = mysql_fetch_lengths(result);
		fprintf(stderr,"Result[%d]: ",++j);
		for(int i = 0; i < num_fields; ++i)
		{
			ACE_DEBUG((LM_DEBUG,"[%.*s] ", (int) lengths[i], row[i] ? row[i] : "NULL"));
		}
		ACE_DEBUG((LM_DEBUG,"\n"));
	}
}

//..................................................................................................

/**
 * This is very MySQL specific.  It adds a new record and return the "autonumber" field
 *
 * @param sql sql code to insert a record
 * @param ignoreDup flag to gracefully allow duplicate entries
 * @return integral ID
 */
unsigned long
DBMgr::InsertGetId (char *sql, bool ignoreDup)
{
	ACE_TRACE("DBMgr::InsertGetId");

	ACE_Guard<ACE_Recursive_Thread_Mutex> locker (mutex_);

	unsigned long id = 0;

	MYSQL_RES  *result = this->doQuery (sql, ignoreDup);
	if ( this->conn_ )
	{
		if ( this->affected_rows () > 0 )
			id = (unsigned long) mysql_insert_id(this->conn_);
		else if (!ignoreDup )
		{
			ACE_DEBUG ((LM_ERROR, "(%P|%t) DBMgr::InsertGetId Duplicate? (%s)\n",sql));
		}
		this->freeQuery (result);
	}

	if (DebugFlag::instance ()->enabled (DebugFlag::DB_DEBUG) )
	{
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) DBMgr::InsertGetId(%s)->%d\n",sql,id));
	}

	return id;
}

//..................................................................................................

/**
 * uses the supplied select and insert queries to either create or
 * return the first field in the table which is assumed to be the ID
 *
 * @param SelSQL select sql code
 * @param InsSQL insert sql code
 * @return integral ID
 */
unsigned long
DBMgr::LookupAddID (char *SelSQL, char *InsSQL, bool debug)
{
	ACE_TRACE("DBMgr::LookupAddID");

	ACE_Guard<ACE_Recursive_Thread_Mutex> locker (mutex_);

	bool add = false;
	unsigned long id = 0;

	// TODO Formalize recovery from a race conditions

	do
	{
		int cntr = 1;
		MYSQL_RES  *result = this->doQuery (SelSQL, false);
		if ( result != NULL )
		{
			unsigned long nrow = (unsigned long) mysql_num_rows(result);
			if ( nrow > 0)
			{
				MYSQL_ROW row = mysql_fetch_row(result);
				id = atol(row[0]);

				if (nrow > 1 && DebugFlag::instance ()->enabled (DebugFlag::DB_DEBUG) )
				{
					ACE_DEBUG ((LM_DEBUG, "(%P|%t) DBMgr::LookupAddID(%s) returned %d rows\n",SelSQL,nrow));
					this->printQryResult (result);

				}
			}
			else  // nrow == 0
			{
				add = true;
			}
			this->freeQuery (result);

			if(add)
			{
				id = this->InsertGetId(InsSQL,true);
				add = false;
			}

			if ( cntr++ > 10 )
			{
				ACE_DEBUG ((LM_DEBUG, "(%P|%t) DBMgr::LookupAddID failed after 10 tries!!!!\n(%s)->%d\n(%s)\n",SelSQL,nrow,InsSQL));
				break;
			}
			if ( id==0 ) ACE_OS::sleep(cntr++);
		}
	} while (id==0);


	if (DebugFlag::instance ()->enabled (DebugFlag::DB_DEBUG) || debug )
	{
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) DBMgr::LookupAddID:\n   %s\n   %s\n   Result=%d\n",
					SelSQL, InsSQL,id));
	}

	return id;
}

//..................................................................................................

/**
 * Used the sql to return the first field of the table which is assumed to be
 * an integral ID
 *
 * @param SelSQL select cod
 * @return the integral ID or 0 if not found
 */
unsigned long
DBMgr::LookupInt (char *SelSQL)
{
	ACE_TRACE("DBMgr::LookupInt");

	ACE_Guard<ACE_Recursive_Thread_Mutex> locker (mutex_);

	int val = 0;

	if (DebugFlag::instance ()->enabled (DebugFlag::DB_DEBUG) )
	{
		ACE_DEBUG ((LM_DEBUG, "(%P|%t) DBMgr::LookupInt (%s)\n", SelSQL));
	}

	MYSQL_RES  *result = this->doQuery (SelSQL, false);
	if ( result != NULL )
	{
		unsigned long nrow = (unsigned long) mysql_num_rows(result);
		if ( nrow == 1)
		{
			MYSQL_ROW row = mysql_fetch_row(result);
			val = atol(row[0]);
		}
		this->freeQuery (result);
	}

	return val;
}

/**
 * Used to delete a record from a table given the Integer Key (ID)
 *
 * @param Table
 * @param id
 */
void
DBMgr::DeleteRecord(char *Table, int id)
{
	ACE_TRACE("DBMgr::DeleteRecord");

	ACE_Guard<ACE_Recursive_Thread_Mutex> locker (mutex_);

	char sql[1024];
	sprintf(sql,"Delete from %s where ID=%d",Table,id);
	MYSQL_RES  *result = this->doQuery (sql, false);
	this->freeQuery (result);
}

} // namespace
