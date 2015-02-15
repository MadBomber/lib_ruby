////////////////////////////////////////////////////////////////////////////////
//
// Filename:         MessageFunctor.hpp
//
// Classification:   UNCLASSIFIED
//
// Unit Name:        Samson
//
// System Name:      MEADS Simulation
//
// Description:      Functor class
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


#ifndef MESSAGEFUNCTOR_HPP
#define MESSAGEFUNCTOR_HPP

#include "Functor.h"

template<class Model>
class MessageFunctor  :  public Functor
{

	public:
		MessageFunctor (Model *amodel, int (Model::*modelfunction) (Samson_Peer::MessageBase *)) : 
			mmodel(amodel), modelfunction_(modelfunction) {}

		//~MessageFunctor() { delete mmodel; }

		int operator ()(Samson_Peer::MessageBase *mb ) const 
		{ 
			return (*mmodel.*modelfunction_)(mb); 
		}

		Functor * clone () const 
		{ 
			return new MessageFunctor<Model>(*this); 
		}

	private:
		Model * mmodel;
		int (Model::*modelfunction_) (Samson_Peer::MessageBase *);
};

#endif
