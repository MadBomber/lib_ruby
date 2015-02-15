/*
 * PauseSimulation.h
 *
 *  Created on: Mar 29, 2010
 *      Author: lavender
 */

#ifndef PAUSESIMULATION_H_
#define PAUSESIMULATION_H_

#include "ISEExport.h"
#include "DatalessMessage.h"

class ISE_Export PauseSimulation : public Samson_Peer::DatalessMessage
{
	public:
		PauseSimulation() : DatalessMessage(std::string("PauseSimulation"), std::string("Send to run master to pause the simulation after the current frame")) {}
		~PauseSimulation(){}
};

#endif /* PAUSESIMULATION_H_ */
