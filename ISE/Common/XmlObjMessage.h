/**
 *	@file XmlObjMessage.h
 *
 *	@class XmlObjMessage
 *
 *	@brief Base Class for all user-defined Object Messages
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef XmlObjMessage_H
#define XmlObjMessage_H

//.... for stringstream / string
#include <sstream>
#include <string>

//....ACE includes
#include "ace/Message_Block.h"

//....local includes
#include "ISE.h"
#include "DBMgr.h"
#include "MessageBase.h"
#include "Model_ObjMgr.h"
#include "sql_oarchive.h"

//....boost serialization
#include <boost/archive/basic_xml_archive.hpp>
#include <boost/archive/xml_oarchive.hpp>
#include <boost/archive/xml_iarchive.hpp>
#include <boost/serialization/version.hpp>
#include <boost/serialization/nvp.hpp>
#include <boost/serialization/utility.hpp>

class ACE_Message_Block;

//namespace Samson_Peer {

// ===========================================================================
// Curiously Recuring Template Pattern

template <class Tobj>
class ISE_Export XmlObjMessage : public Samson_Peer::MessageBase {
public:
	typedef XmlObjMessage<Tobj> Base;

	XmlObjMessage(std::string key, std::string description);
	virtual bool de_marshall(void *ptr, size_t len);
	virtual ACE_Message_Block *marshall();
	void toDB();

protected:

	Tobj &getChild()
	{
		return static_cast<Tobj&>(*this);
	}
};


// ===========================================================================
//  The message is NOT in the inheritance chain, but it must provide
//  static datamembers  Key and Description.
template< class Tobj>
class XmlObjMessageTempl : public Samson_Peer::MessageBase
{
public:
	XmlObjMessageTempl(Tobj &aTobj) :
		Samson_Peer::MessageBase(aTobj.Key, aTobj.Description),
		theObj(aTobj)
	{
	}
	virtual ~XmlObjMessageTempl() {}
	virtual bool de_marshall(void *ptr, size_t len);
	virtual ACE_Message_Block *marshall();
	Tobj *get_object() { return &theObj; }

protected:
	Tobj &theObj;
};


#include "XmlObjMessage.inl"


//}  // namespace


#endif

