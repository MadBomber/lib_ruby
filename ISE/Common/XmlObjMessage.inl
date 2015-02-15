/*
 * XmlObjMessage.ing
 *
 *  Created on: Jun 25, 2009
 *      Author: lavender
 */


template <class Tobj>
XmlObjMessage<Tobj>::XmlObjMessage(std::string key, std::string description) : Samson_Peer::MessageBase (key, description)
{
	this->msg_type_ = SimMsgType::DATA;
	this->msg_flag_mask_ =  SimMsgFlag::object | SimMsgFlag::xml_boost_serialize;
}

template <class Tobj>
bool
XmlObjMessage<Tobj>::de_marshall(void *ptr, size_t len)
{
	std::string is((const char *)(ptr),len);

#if 0
	//if (Samson_Peer::DebugFlag::instance ()->enabled (DebugFlag::APPMGR_DEBUG) )
	{
		ACE_DEBUG ((LM_DEBUG, "XmlObjMessage::de_marshall (%d)\n%s\n", is.length(), is.c_str()));
	}
#endif

	std::stringstream ifs(is);

	try {
		boost::archive::xml_iarchive ia(ifs,7);
		Tobj &theObj = this->getChild();
		ia >> BOOST_SERIALIZATION_NVP(theObj);
	}
	catch (boost::archive::archive_exception const& e) {
		ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: %s\n", e.what()));
		return false;
	}
	catch (std::exception const& e) {
		ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: %s ", e.what()));
		return false;
	}
	catch (...) {
		ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: final\n"));
		return false;
	}

	return true;
}

template <class Tobj>
ACE_Message_Block *
XmlObjMessage<Tobj>::marshall()
{
	std::stringstream ofs;

	try {
		boost::archive::xml_oarchive oa(ofs,7);
		Tobj &theObj = this->getChild();

		oa << BOOST_SERIALIZATION_NVP(theObj);

#if 0
		//if (Samson_Peer::DebugFlag::instance ()->enabled (DebugFlag::APPMGR_DEBUG) )
		{
			ACE_DEBUG ((LM_DEBUG, "XmlObjMessage::marshall (%d)\n%s\n", ofs.str().length(), ofs.str().c_str()));
		}
#endif

	}
	catch (boost::archive::archive_exception const& e) {
		ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: %s ", e.what()));
		return 0;
	}
	catch (std::exception const& e) {
		ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: %s ", e.what()));
		return 0;
	}
	catch (...) {
		ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: final"));
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
		ACE_ERROR_RETURN ((LM_ERROR, "XmlObjMessage::marshall() -> Data Messsage_Block Allocation Error\n"), 0);

	// copy the data into the message block  (costly?)  !!! this sets the mb length!!!!!
	if ( data_mb->copy( (const char *)ofs.str().data(),ofs.str().length()) == -1 )
		ACE_ERROR_RETURN ((LM_ERROR, "XmlObjMessage::marshall() -> Data Copy Error\n"), 0);

	return data_mb;
}

template <class Tobj>
void
XmlObjMessage<Tobj>::toDB()
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




template <class Tobj>
bool
XmlObjMessageTempl<Tobj>::de_marshall(void *ptr, size_t len)
{
	std::string is((const char *)(ptr),len);
	std::stringstream ifs(is);

	try {
		boost::archive::xml_iarchive ia(ifs,7);
		ia >> BOOST_SERIALIZATION_NVP(theObj);
	}
	catch (boost::archive::archive_exception const& e) {
		ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: %s\n", e.what()));
		return false;
	}
	catch (std::exception const& e) {
		ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: %s ", e.what()));
		return false;
	}
	catch (...) {
		ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: final\n"));
		return false;
	}
	return true;
}

template <class Tobj>
ACE_Message_Block *
XmlObjMessageTempl<Tobj>::marshall()
{
	std::stringstream ofs;
	try {
		boost::archive::xml_oarchive oa(ofs,7);
		oa << BOOST_SERIALIZATION_NVP(theObj);
	}
	catch (boost::archive::archive_exception const& e) {
		ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: %s ", e.what()));
		return 0;
	}
	catch (std::exception const& e) {
		ACE_DEBUG((LM_ERROR,"(%P|%t) error while de-marshalling state: %s ", e.what()));
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
		ACE_ERROR_RETURN ((LM_ERROR, "XmlObjMessage::marshall() -> Data Messsage_Block Allocation Error\n"), 0);

	// copy the data into the message block  (costly?)  !!! this sets the mb length!!!!!
	if ( data_mb->copy( (const char *)ofs.str().data(),ofs.str().length()) == -1 )
		ACE_ERROR_RETURN ((LM_ERROR, "XmlObjMessage::marshall() -> Data Copy Error\n"), 0);

	return data_mb;
}

