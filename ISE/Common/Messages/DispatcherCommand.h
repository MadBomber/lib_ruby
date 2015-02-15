/*
 * DispatcherCommand.h
 *
 *  Created on: Mar 24, 2010
 *      Author: lavender
 */

#ifndef DISPATCHERCOMMAND_H_
#define DISPATCHERCOMMAND_H_


#include "StringMessage.h"
#include <string.h>

class ISE_Export DispatcherCommand : public Samson_Peer::StringMessage
{
    public:
    	DispatcherCommand() : StringMessage(std::string("DispatcherCommand"),std::string("Sending command to attached dispatcher"))
	{
    		this->msg_flag_mask_ = SimMsgFlag::log_it;
    		this->msg_type_ = SimMsgType::DISPATCHER_COMMAND;
	}
	~DispatcherCommand(){}

	const char* Command() const { return this->message_.c_str(); }
	void Command (const char * const cmd) { this->message_.assign(cmd); }
	void Command (const std::string &cmd) { this->message_.assign(cmd); }
};


#endif /* DISPATCHERCOMMAND_H_ */
