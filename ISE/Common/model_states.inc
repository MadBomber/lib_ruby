// -*- C++ -*-

#define ITEM(TYPE, VAR) TYPE VAR;
ITEMS
#undef ITEM

public:

template<class Archive>
void serialize(Archive & ar, const unsigned int)
{

	ACE_UINT64 sys_time_usec;
	ACE_OS::gettimeofday().to_usec(sys_time_usec);
	ar & BOOST_SERIALIZATION_NVP(sys_time_usec);

	ar & BOOST_SERIALIZATION_NVP(model_id_);
	ar & BOOST_SERIALIZATION_NVP(unit_id_);
	ar & BOOST_SERIALIZATION_NVP(node_id_);
	ar & BOOST_SERIALIZATION_NVP(run_id_);
	ar & BOOST_SERIALIZATION_NVP(app_key_);

	ar & BOOST_SERIALIZATION_NVP(timing_);
	ar & BOOST_SERIALIZATION_NVP(caseNumber_);
	ar & BOOST_SERIALIZATION_NVP(frame_count_);
	ar & BOOST_SERIALIZATION_NVP(currTime_);
	ar & BOOST_SERIALIZATION_NVP(time_step_flag_);
	ar & BOOST_SERIALIZATION_NVP(inFrame_);

	//ar & boost::serialization::base_object<Samson_Peer::SamsonModel>(*this);
	//ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(Samson_Peer::SamsonModel);

#define ITEM(TYPE, VAR) ar & BOOST_SERIALIZATION_NVP(VAR);
	ITEMS
#undef ITEM
}

#undef ITEMS


void toDB(const std::string& modelName)
{
	std::string sql;
	{
		sql_oarchive oa(sql, "modelLog");
		oa & boost::serialization::make_nvp(modelName.c_str(), *this);
	}
	Samson_Peer::SAMSON_OBJMGR::instance()->doRunQuery(sql);
}

void toXML (std::stringstream &ofs) const
{
	boost::archive::xml_oarchive oa(ofs,7);
	oa << BOOST_SERIALIZATION_NVP(this);
}


void toText (std::stringstream &ofs) const
{
	boost::archive::text_oarchive oa(ofs,7);
	oa << *this;
}

protected:


