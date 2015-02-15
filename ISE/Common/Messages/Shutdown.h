/**
 *	@file Shutdown.h
 * 
 *	@class Shutdown
 * 
 *	@brief
 * 		Used to shutdown a model ???
 * 		Based upon work by Ben Atakora
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */


#ifndef _SHUTDOWN_HPP
#define _SHUTDOWN_HPP

#include "DataMessage.h"

class ISE_Export Shutdown : public Samson_Peer::DataMessage
{

    public:
	Shutdown() : DataMessage(std::string("Shutdown"),std::string("This model is shutting down"))
	{
		obj_ptr = reinterpret_cast<void*>(&Game);
		obj_ptr_len = sizeof(Game);
	}
	~Shutdown(){}
	  
	double EventTime() const { return Game.Event_time; }
	void EventTime (double aevent_time) { Game.Event_time = aevent_time; }

   private:
	struct
	{
        	double Event_time;
	} Game;

};

#endif
