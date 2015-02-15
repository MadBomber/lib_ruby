// -*- C++ -*-

#define ITEM(TYPE, VAR) TYPE VAR;
  ITEMS
#undef ITEM

template<class Archive>
void serialize(Archive & ar, const unsigned int v)
{
	ACE_UINT64 sys_time_usec;
	ACE_OS::gettimeofday().to_usec(sys_time_usec);
	ar & BOOST_SERIALIZATION_NVP(sys_time_usec);
	
	if(v==2) header_->SamsonHeader::serialize(ar, v); // this archives the header !!
	
	#define ITEM(TYPE, VAR) ar & BOOST_SERIALIZATION_NVP(VAR);
	ITEMS
	#undef ITEM
}

#undef ITEMS

