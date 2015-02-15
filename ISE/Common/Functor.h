#ifndef Samson_Functor_H
#define Samson_Functor_H

namespace Samson_Peer { class MessageBase; }

class Functor
{
	public:
		virtual ~Functor(){}
		virtual int operator()(Samson_Peer::MessageBase *) const = 0;
		virtual Functor *clone() const = 0;         // virtual constructor
};

#endif 
