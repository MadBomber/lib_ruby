#ifndef PEER_ROUTE_H_
#define PEER_ROUTE_H_

#include "ISE.h"

#include <string>
#include <iostream>
#include <fstream>
#include <sstream>

#include <boost/shared_ptr.hpp>

namespace Samson_Peer {

// ===========================================================================
struct PeerRoute
{
	unsigned int peer_id;
	unsigned int node_id;
	
	// ---------------------------------------------------------------------
	void print (void) const
	{
		ACE_DEBUG ((LM_DEBUG, "%s\n", (this->report()).c_str()));
	}

	// ----------------------------------------------------------------
	std::string report (void) const
	{
		boost::shared_ptr<std::stringstream> my_report(new std::stringstream);

		*my_report << "PeerRoute:"
			" peer=" << this->peer_id <<
			" node=" << this->node_id;
		
		return my_report->str();
	}
};

}  // namespace

#endif /*PEER_ROUTE_H_*/
