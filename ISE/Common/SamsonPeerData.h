#ifndef SamsonPeerData_h
#define SamsonPeerData_h

#include "ace/Log_Msg.h"

namespace Samson_Peer {

// this ought to be an object, but no time
struct SamsonPeerData {
	int id;
	char appKey[32];
	int pid;
	int peer_id;
	char peerName[255];

	void print ()
	{
		ACE_DEBUG ((LM_DEBUG, "ID(%d) AppKey(%s) PID(%d) Peer(%d,%s)\n",
					id, appKey, pid, peer_id, peerName));
	}
};

} // namespace

#endif
