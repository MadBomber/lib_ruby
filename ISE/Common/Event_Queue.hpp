////////////////////////////////////////////////////////////////////////////////
//
// Filename:         EventQueue.hpp
//
// Classification:   UNCLASSIFIED
//
// Unit Name:        Samson
//
// System Name:      MEADS Simulation
//
// Description:      Event Queue
//
// Author:           Ben Atakora
//
// Company Name:     Lockheed Martin
//                   Missiles & Fire Control
//                   Dallas, TX
//
// Revision History:
//
// <yyyymmdd> <Eng> <Description of modification>
//
////////////////////////////////////////////////////////////////////////////////
#ifndef SAMSON_EVENT_QUEUE_H
#define SAMSON_EVENT_QUEUE_H

//#include <deque>
#include <list>
//#include <vector>
//#include <algorithm>
//#include <functional>
//#include<iterator>
//#include<set>

#include "ISE.h"

enum EventType {WAIT,FRAME};

struct Event
{
   double event_time;
   double wait_time;
   unsigned int model_id;
   EventType value;
};
/*
struct Compare_Events : public std::binary_function<Event,Event,bool>
{
   bool operator()(const Event &left,const Event &right)
   {
		return(left.event_time > right.event_time);
   }
};
*/
//

// ============================================================================
class ISE_Export Event_Queue
{
  public:
	 //....................................................................
	  Event_Queue()
	  {
	  }

	 //....................................................................
	  ~Event_Queue()
	  {
	  }

	 //....................................................................
      void insert(double aevent_time,double await_time,int amodel_id,EventType avalue)
      {
         Event entry;
         entry.event_time = aevent_time;
         entry.wait_time  = await_time;
         entry.model_id   = amodel_id;
         entry.value      = avalue;
         pqueue.push_back(entry);
     }

	 //....................................................................
	 void insert(const Event &aentry)
	 {
		 pqueue.push_back(aentry);

	 }
	 
	 //....................................................................
	 void lookup(Event &aevent)
	 {
		 //std::vector<Event>::iterator iter = pqueue.begin();
		 //std::deque<Event>::iterator iter = pqueue.begin();
		 std::list<Event>::iterator iter = pqueue.begin();
		 while(iter != pqueue.end())
		 {
			 if((*iter).value == WAIT && (*iter).model_id == aevent.model_id) {
				iter = pqueue.erase(iter);
			 }
			 else
				 ++iter;
			
		 }
		 pqueue.push_back(aevent);

	 }	 		 

	 //....................................................................
	 bool empty() const
	 {
		 return pqueue.empty();
	 }

	 //....................................................................
     EventType PeekEventType() const
     {
		 EventType mvalue = WAIT;
		 if(!pqueue.empty()) {
			 //mvalue = pqueue.back().value;
			 mvalue = pqueue.front().value;
		 }
		 return mvalue; 
     }

	 //....................................................................
     int size()const
     {
         return pqueue.size();
     }

	 //....................................................................
	 Event pop()
	 {
		 Event mevent;
		// mevent = pqueue.back();
		// pqueue.pop_back();
		 mevent = pqueue.front();
		 pqueue.pop_front();
		 return mevent;
	 }
	 //....................................................................
	 void clearqueue()
	 {
		 if(!pqueue.empty())
			 pqueue.clear();
	 }	 		 	 		 

	friend ostream& operator<<(ostream& output, const Event_Queue& p)
	{
		output << std::endl <<"EventQueue::";
		
		std::list<Event> pq = p.pqueue;
		for (std::list<Event>::iterator iter = pq.begin(); iter != pq.end(); iter++)
		{
			   Event a = *iter;
				output << std::endl
				<< " T: " << a.event_time 
				<< " WT: " << a.wait_time
				<< " M: " << a.model_id
				<< " V: " << a.value
				;
		}			    

		return output;
	}
	
	private:
		//std::priority_queue<Event,std::vector<Event>,Compare_Event> pqueue;
		//std::set<Event,Compare_Events> pqueue;
		//std::vector<Event>pqueue;
		//std::deque<Event>pqueue;
		std::list<Event>pqueue;
		
};

#endif
