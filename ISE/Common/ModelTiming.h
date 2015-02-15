/**
 *	@file ModelTiming.h
 * 
 *	@class ModelTiming
 *
 *	This object is used to set a Model's frame rate
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef Model_Timing_H
#define Model_Timing_H

#include "ISE.h"

//....boost serialization
#include <boost/archive/basic_xml_archive.hpp>
#include <boost/archive/xml_oarchive.hpp>
#include <boost/archive/xml_iarchive.hpp>
#include <boost/serialization/version.hpp>
#include <boost/serialization/nvp.hpp>
#include <boost/serialization/utility.hpp>


namespace Samson_Peer {

// =====================================================================
class ISE_Export ModelTiming
{
public:

	ModelTiming() : frequency_(0), rate_(0.0) {}
	~ModelTiming() {}

	void set(double);
	void set(int);
	int frequency() { return this->frequency_; } 
	double rate() { return this->rate_; } 

	template<class Archive>
	void serialize(Archive & ar, const unsigned int )
	{
		ar & BOOST_SERIALIZATION_NVP(frequency_);
		ar & BOOST_SERIALIZATION_NVP(rate_);
	}

protected:
	
	//  Information about this models rate
	int frequency_;
	double rate_;
};

} // namespace

#endif
