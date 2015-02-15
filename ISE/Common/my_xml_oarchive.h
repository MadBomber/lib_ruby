#ifndef MY_XML_ARCHIVE_H_
#define MY_XML_ARCHIVE_H_

//#include "DispatcherConfig.h"

#include <boost/version.hpp>
#include <boost/archive/xml_oarchive.hpp>
//#include <boost/archive/detail/archive_pointer_oserializer.hpp>

#include <boost/archive/impl/basic_xml_oarchive.ipp>
#include <boost/archive/impl/xml_oarchive_impl.ipp>
//#include <boost/archive/impl/archive_pointer_oserializer.ipp>

namespace boost {
namespace archive {

class my_xml_oarchive :
public xml_oarchive_impl<my_xml_oarchive>
{
public:
	my_xml_oarchive(std::ostream & os,std::string stylesheet) :
		xml_oarchive_impl<my_xml_oarchive>(os, 1) {init(stylesheet);}
		~my_xml_oarchive() { this->This()->put("</boost_serialization>"); }
private:
	void init(std::string& stylesheet){
		// xml header
		std::string xml_stylesheet="<?xml-stylesheet type=\"text/xsl\" href=\""+stylesheet+"\"?>\n";
		this->This()->put("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
		this->This()->put("<!DOCTYPE boost_serialization>\n");
		this->This()->put(xml_stylesheet.c_str());
		this->This()->put("<boost_serialization");

#if BOOST_VERSION >= 103700
	    write_attribute("signature", BOOST_ARCHIVE_SIGNATURE());
		write_attribute("version", BOOST_ARCHIVE_VERSION());
#else
		write_attribute("signature", ARCHIVE_SIGNATURE());
		write_attribute("version", ARCHIVE_VERSION());
#endif

		this->This()->put(">\n");
	}
};
}
}

#endif
