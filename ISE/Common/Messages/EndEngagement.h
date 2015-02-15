////////////////////////////////////////////////////////////////////////////////
//
// Filename:         EndEngagement.hpp
//
// Classification:   UNCLASSIFIED
//
// Unit Name:        Samson
//
// System Name:      MEADS Simulation
//
// Description:
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


#ifndef _ENDENGAGEMENT_HPP
#define _ENDENGAGEMENT_HPP

#include "ISE.h"
#include "DatalessMessage.h"

class ISE_Export EndEngagement : public Samson_Peer::DatalessMessage
{
	public:
		EndEngagement() : DatalessMessage(std::string("EndEngagement"),std::string("Model is at End of Engagement"))
		{
		}
		~EndEngagement(){}
};
#endif
