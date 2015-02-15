#ifndef SQL_HEADER_
#define SQL_HEADER_

#include <set>
#include <string>
#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/xml_oarchive.hpp>
#include <boost/serialization/nvp.hpp>
#include <boost/array.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/type_traits.hpp>

namespace {
template <typename T> const char* type_name(T) { return "unknown";}
const char* type_name(bool) { return "INT";}
const char* type_name(char*) { return "VARCHAR(32)";}
const char* type_name(const char*) { return "VARCHAR(32)";}
const char* type_name(const unsigned char*) { return "VARCHAR(32)";}
const char* type_name(unsigned char) { return "unsigned char";}
const char* type_name(unsigned short) { return "INT(11) UNSIGNED";}
const char* type_name(unsigned int) { return "INT(11) UNSIGNED";}
const char* type_name(unsigned long) { return "INT(11) UNSIGNED";}
const char* type_name(unsigned long long) { return "BIGINT(21) UNSIGNED";}
const char* type_name(char) { return "char";}
const char* type_name(short) { return "INT";}
const char* type_name(int) { return "INT";}
const char* type_name(long) { return "INT";}
const char* type_name(long long) { return "BIGINT(21)";}
const char* type_name(float) { return "DOUBLE";}
const char* type_name(double) { return "DOUBLE";}
const char* type_name(long double) { return "long double";}
const char* type_name(std::string) { return "VARCHAR(32)";}

std::set<std::string> createdTables;
}

class sql_oarchive
{
public:
  sql_oarchive(std::string& sql, std::string comment):first(true),sql(sql),prefix(""),comment(comment) {}
  ~sql_oarchive()
  {
    if(needsCreating) beg+=" PRIMARY KEY (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='"+comment+"'; ";
    mid.replace(mid.length()-2,2," ) VALUES ( ");
    end.replace(end.length()-2,2," );");
    sql=beg+mid+end;
  }
  template <class T, bool b>
  void save(const boost::serialization::nvp<T>& p, const boost::integral_constant<bool, b>&)
  {
    if(first) {
      first=false;
      needsCreating = createdTables.insert(p.first).second;
      if(needsCreating) beg = std::string("CREATE TABLE IF NOT EXISTS `")+p.first+"` (  `id` int NOT NULL AUTO_INCREMENT,";
      mid+=std::string("INSERT INTO ")+p.first+" ( ";
    } else {
      prefix+=std::string(p.first)+'_';
    }
    p.value().template serialize<sql_oarchive>(*this,2);
    prefix="";
  }
  template <class T>
  void save(const boost::serialization::nvp<T>& p, const boost::true_type&)
  {
    std::string name=prefix+p.first;
    if(needsCreating) beg+=std::string(" `")+name+"` "+type_name(*p.second)+" NOT NULL,";
    mid+=std::string("`")+name+"`, ";
    end+='"'+boost::lexical_cast<std::string>(*p.second)+'"'+", "; 
  }
private:
  bool first, needsCreating;
  std::string& sql;
  std::string  beg;
  std::string  mid;
  std::string  end;
  std::string  prefix;
  std::string  comment;
};

template <class T>
sql_oarchive& operator&(sql_oarchive& oa, const boost::serialization::nvp<T>& p)
{
  oa.save(p, boost::integral_constant<bool, boost::is_arithmetic<T>::value
                                          ||boost::is_same<T,char*>::value
                                          ||boost::is_same<T,const char*>::value
                                          ||boost::is_same<typename boost::remove_cv<T>::type,std::string>::value>());
  return oa;
}

template <class T,unsigned int N>
sql_oarchive& operator&(sql_oarchive& oa, const boost::serialization::nvp<boost::array<T,N> >& p)
{
  //BOOST_STATIC_ASSERT((boost::is_same<bool,typeof(p.second[0])>::value));
  using boost::serialization::make_nvp;
  for(unsigned int i=0; i<N; ++i) {
    std::string name=p.name()+boost::lexical_cast<std::string>(i);
    oa & make_nvp(name.c_str(), p.value()[i]);
  }
  return oa;
}

template <class T>
sql_oarchive& operator<<(sql_oarchive& oa, const boost::serialization::nvp<T>& p)
{
  oa & p;
  return oa;
}

#endif
