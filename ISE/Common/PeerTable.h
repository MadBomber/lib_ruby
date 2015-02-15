#ifndef PEERTABLE_H_
#define PEERTABLE_H_

#include "ISE.h"

#include <string>
#include <sstream>
#include <map>

#include "ace/Log_Msg.h"


template <class T>
std::string to_string(T t, std::ios_base & (*f)(std::ios_base&))
{
  std::ostringstream oss;
  oss << f << t;
  return oss.str();
}

namespace Samson_Peer {

//..................................................................................
class PeerRecord
{
	public:

		PeerRecord(unsigned int _pid, unsigned int _uid, unsigned int _nid, int _PID, double _stime, float _rate, char *dll_name, char*mdl_name)
		{
				peer_id = _pid;
				unit_id = _uid;
				node_id = _nid;
				pid = _PID;
				stime = _stime;
				rate = _rate;
				DLL = dll_name;
				name = mdl_name;
				powered_down = false;
				waiting_on_endframe = false;
				waiting_on_timeadvance = false;
		}

		PeerRecord(char *dll_name, char*mdl_name, unsigned int _uid)
		{
				peer_id = 0;
				unit_id = _uid;
				node_id = 0;
				pid = 0;
				stime = 0.0;
				rate = 0.0;
				DLL = dll_name;
				name = mdl_name;
				powered_down = false;
				waiting_on_endframe = false;
				waiting_on_timeadvance = false;
		}

		unsigned int peer_id;		//  Model or Service ID
		unsigned int unit_id;		//  Unit ID
		unsigned int node_id;		//  Node ID
		int pid;					//  Process ID
		std::string name;			//  Model or Service ID Name  (RDBMS field is 32!!)
		std::string DLL;			//  Shared Library Name  (RDBMS field is 80!!)
		bool powered_down;	 		//  if command was sent
		bool waiting_on_endframe;	//  StartFrame sent, waiting on EndFrame
		bool waiting_on_timeadvance;	// TimeAdvance

		float rate;
		double stime;

		static void header ()
		{
			ACE_DEBUG ((LM_DEBUG,
				"JobID  ID    Model Name  UID  Node   PID     rate    stime   EndFr TimAdv\n"
				"----- ----- ------------ --- ----- -------- ------ -------- ------ ------\n"));
		}

		void print () {
			ACE_DEBUG ((LM_DEBUG,
				"%5d %12s %20s %3d %5d %8d %6.2f %6.2f %6s %6s\n",
				this->peer_id,
				this->DLL.c_str(),
				this->name.c_str(),
				this->unit_id,
				this->node_id,
				this->pid,
				this->rate,
				this->stime,
				(this->waiting_on_endframe?"true ":"false"),
				(this->waiting_on_timeadvance?"true ":"false")
				));
		}

		friend ostream& operator<< (ostream& output, const PeerRecord& p)
		{
			output << std::endl
			<< " ID: " << p.peer_id
			<< " DLL: " << p.DLL.c_str()
			<< " Name: " << p.name.c_str()
			<< " uid: " << p.unit_id
			<< " node: " << p.node_id
			<< " pid: " << p.pid
			<< " stime: " << p.stime
			<< " rate: " << p.rate
			<< " PWR?: " << (p.powered_down?"true":"false")
			<< " EF?: " << (p.waiting_on_endframe?"true":"false")
			<< " ETA?: " << (p.waiting_on_timeadvance?"true":"false")
			;

			return output;
		}

};

class PeerTable
{
	public:
		unsigned int run_id; // *** The Map Key ***
		typedef std::map<std::string, PeerRecord *> PeerMap;
		typedef std::map<std::string, PeerRecord *>::iterator  PeerMapIterator;

		PeerMap pr_;

		PeerMapIterator begin() { return pr_.begin (); }
		PeerMapIterator end() { return pr_.end (); }

		PeerTable () { this->run_id = 0; }
		PeerTable (unsigned int _jid) { this->run_id = _jid; }
		~PeerTable () { this->empty(); }

		void empty ()
		{
			PeerMapIterator iter;
			for (iter = pr_.begin(); iter != pr_.end(); iter++)
			{
				PeerRecord *a = iter->second;
				delete a;
			}
			this->pr_.clear();
		}

		void insert (PeerRecord *_s)
		{
			std::string key =  _s->DLL + to_string<int>(_s->unit_id, std::dec);
			pr_.insert( std::make_pair(key, _s) );
		}

		void print (void)
		{
			ACE_DEBUG ((LM_DEBUG, "RunID = %5d\n",this->run_id));
			PeerMapIterator iter;
			for (iter = pr_.begin(); iter != pr_.end(); iter++)
			{
				PeerRecord *a = iter->second;
				ACE_DEBUG ((LM_DEBUG, "%s -> ",iter->first.c_str()));
				a->print();
			}
		}

		double getRate (unsigned int mid)
		{
			PeerMapIterator iter;
			for (iter = pr_.begin(); iter != pr_.end(); iter++)
			{
				PeerRecord *a = iter->second;
				if (a->peer_id == mid ) return a->rate;
			}
			return 0.0;
		}

		friend ostream& operator<< (ostream& output, const PeerTable& p)
		{
			   output << "\nPeerTable:: " << " Run: " << p.run_id;

			   PeerMap pm  = p.pr_;
			   for (PeerMapIterator iter = pm.begin(); iter != pm.end(); iter++)
			   {
				   PeerRecord *a = iter->second;
				   output << *a;
			   }
			   return output;

		}
};

} // namespaces

#endif /*PEERTABLE_H_*/
