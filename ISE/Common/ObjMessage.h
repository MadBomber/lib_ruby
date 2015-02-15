/**
 *	@file ObjMessage.h
 *
 *	@class ObjMessage
 *
 *	@brief Base Class for all user-defined Object Messages
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */

#ifndef ObjMessage_H
#define ObjMessage_H

//.... for stringstream
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
#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>
#include <boost/serialization/version.hpp>
#include <boost/serialization/nvp.hpp>
#include <boost/serialization/utility.hpp>

class ACE_Message_Block;

//namespace Samson_Peer {

// ===========================================================================
// Curiously Recurring Template Pattern
//  This is used when the message is derived from "ObjMessage"
template <class Tobj>
class ISE_Export ObjMessage : public Samson_Peer::MessageBase {
public:
	typedef ObjMessage<Tobj> Base;

	ObjMessage(std::string key, std::string description) : Samson_Peer::MessageBase (key, description)
	{
		this->msg_type_ = SimMsgType::DATA;
		this->msg_flag_mask_ =  SimMsgFlag::object | SimMsgFlag::text_boost_serialize;
	}


	bool de_marshall(void *ptr, size_t len)
	{
		std::string is((const char *)(ptr),len);
		//ACE_DEBUG ((LM_DEBUG, "(%d)%s\n", is.length(), is.c_str()));

		try {
			std::stringstream ifs(is);
			boost::archive::xml_iarchive ia(ifs,7);
			Tobj &theObj = this->getChild();
			ia >> BOOST_SERIALIZATION_NVP(theObj);
		}
		catch (boost::archive::archive_exception const& e) {
			ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: %s ", e.what()));
			return false;
		}
		catch (...) {
			ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: final\n"));
			return false;
		}
		return true;
	}

	ACE_Message_Block *marshall()
	{
		std::stringstream ofs;
		try {
			boost::archive::xml_oarchive oa(ofs,7);
			Tobj &theObj = this->getChild();

			oa << BOOST_SERIALIZATION_NVP(theObj);
			//ACE_DEBUG ((LM_DEBUG, "(%d)%s\n", ofs.str().length(), ofs.str().c_str()));
		}
		catch (boost::archive::archive_exception const& e) {
			ACE_DEBUG((LM_ERROR,"(%P|%t) error while marshalling state: %s\n", e.what()));
			return 0;
		}
		catch (...) {
			ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: final\n"));
			return 0;
		}

		// Allocate a new Message_Block for sending this message
		ACE_Message_Block *data_mb =
		new ACE_Message_Block (
				ofs.str().length(),
				ACE_Message_Block::MB_DATA,
				0,
				0,
				0,
				0); //Options::instance ()->locking_strategy ());

		if (data_mb == 0 )
			ACE_ERROR_RETURN ((LM_ERROR, "ObjMessage::marshall() -> Data Messsage_Block Allocation Error\n"), 0);

		// copy the data into the message block  (costly?)  !!! this sets the mb length!!!!!
		if ( data_mb->copy( (const char *)ofs.str().data(),ofs.str().length()) == -1 )
			ACE_ERROR_RETURN ((LM_ERROR, "ObjMessage::marshall() -> Data Copy Error\n"), 0);

		return data_mb;
	}

	void toDB()
	{
		std::string sql;
		{
			sql_oarchive oa(sql,"mLog");
			oa & boost::serialization::make_nvp(app_msg_key_.c_str(),getChild());
		}
		//ACE_DEBUG ((LM_DEBUG, "(%P|%t) toDB (%x)->(%x):  %d\n", this, this->header_, this->header_->run_id()));
		//ACE_DEBUG ((LM_DEBUG, "%s\n", sql.c_str()));
		Samson_Peer::SAMSON_OBJMGR::instance()->doRunQuery(sql);
	}

protected:

	Tobj &getChild()
	{
		return static_cast<Tobj&>(*this);
	}
};


// ===========================================================================
//  The message is NOT in the inheritance chain, but it must provide
//  static data members  Key and Description.
template< class Tobj>
class ObjMessageTempl : public Samson_Peer::MessageBase
{
public:
	ObjMessageTempl(Tobj &aTobj) :
		Samson_Peer::MessageBase(aTobj.Key, aTobj.Description),
		theObj(aTobj)
		{
		}
	virtual ~ObjMessageTempl() {}



	bool de_marshall(void *ptr, size_t len)
	{
		try {
			std::string is((const char *)(ptr),len);
			std::stringstream ifs(is);
			boost::archive::text_iarchive ia(ifs,7);
			ia >> BOOST_SERIALIZATION_NVP(theObj);
		}
		catch (boost::archive::archive_exception const& e) {
			ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: %s ", e.what()));
			return false;
		}
		catch (...) {
			ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: final\n"));
			return false;
		}
		return true;
	}

	ACE_Message_Block *marshall()
	{
		std::stringstream ofs;
		try {
			boost::archive::text_oarchive oa(ofs,7);
			oa << BOOST_SERIALIZATION_NVP(theObj);
		}
		catch (boost::archive::archive_exception const& e) {
			ACE_DEBUG((LM_ERROR,"(%P|%t) error while marshalling state: %s ", e.what()));
			return 0;
		}
		catch (...) {
			ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: final\n"));
			return 0;
		}

		// Allocate a new Message_Block for sending this message
		ACE_Message_Block *data_mb =
			new ACE_Message_Block (
					ofs.str().length(),
					ACE_Message_Block::MB_DATA,
					0,
					0,
					0,
					0); //Options::instance ()->locking_strategy ());

		if (data_mb == 0 )
			ACE_ERROR_RETURN ((LM_ERROR, "ObjMessage::marshall() -> Data Messsage_Block Allocation Error\n"), 0);

		// copy the data into the message block  (costly?)  !!! this sets the mb length!!!!!
		if ( data_mb->copy( (const char *)ofs.str().data(),ofs.str().length()) == -1 )
			ACE_ERROR_RETURN ((LM_ERROR, "ObjMessage::marshall() -> Data Copy Error\n"), 0);

		return data_mb;
	}

	Tobj *get_object() { return &theObj; }

protected:
	Tobj &theObj;
};





//}  // namespace


#endif

