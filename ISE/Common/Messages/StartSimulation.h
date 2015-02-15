/*
 * StartSimulation.h
 *
 *  Created on: Mar 29, 2010
 *      Author: lavender
 */

#ifndef STARTSIMULATION_H_
#define STARTSIMULATION_H_

#include "ISEExport.h"
#include "DatalessMessage.h"

class ISE_Export StartSimulation : public Samson_Peer::DatalessMessage
{
	public:
		StartSimulation() : DatalessMessage(std::string("StartSimulation"), std::string("Send to run master to start the simulation")) {}
		~StartSimulation(){}
};

#endif /* STARTSIMULATION_H_ */
