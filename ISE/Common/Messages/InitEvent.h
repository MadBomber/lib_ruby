/**
 *	@file InitFrame.h
 * 
 *	@brief
 * 		Used to initialize the montel carlo loop, this is a bootstrap message
 * 		It will be replaced very shortly 
 * 		Based upon work by Ben Atakora
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>, (C) 2006
 *
 */

#ifndef _INITEVENT_H
#define _INITEVENT_H

#include "DataMessage.h"

class ISE_Export InitEvent: public Samson_Peer::DataMessage
{

	public:
		InitEvent() : DataMessage(std::string("InitEvent"),std::string("InitEvent"))
		{
			obj_ptr = reinterpret_cast<void*>(&data);
			obj_ptr_len = sizeof(data);
		} 
		~InitEvent(){}

		double Rate() const { return data.rate_; }
		void Rate(double r) { data.rate_ = r; }
	
		unsigned int ModelID() const { return data.model_id_; }
		void ModelID(unsigned int id) { data.model_id_ = id; }
	
	private:
		struct 
		{
			double rate_;
			ACE_UINT32 model_id_;
		} data;

};

#endif
