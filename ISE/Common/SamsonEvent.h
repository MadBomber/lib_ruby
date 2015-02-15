#ifndef SAMSONEVENT_H
#define SAMSONEVENT_H

#include "SamsonHeader.h"
#include "ace/Message_Block.h"

struct SamsonEvent
{
	SamsonHeader * sh_;
	ACE_Message_Block * mb_;
	
	SamsonEvent( ACE_Message_Block *mb, SamsonHeader *sh)
	{ 
		sh_ = sh;
		mb_ = mb;
	}

/*
	~SamsonEvent( ACE_Message_Block *mb, SamsonHeader *sh)
	{ 
		delete sh_;
		mb_->release();
	}
*/
	
	// Comparator for queueing
	friend bool operator<(const SamsonEvent &leftNode, const SamsonEvent &rightNode) { return leftNode.sh_ < rightNode.sh_; }

};

#endif /* SAMSONEVENT_H */
