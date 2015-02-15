#ifndef _MONTECARLO_HPP
#define _MONTECARLO_HPP

#include "ISE.h"
#include "MessageBase.h"

// =====================================================================
class ISE_Export  MonteCarloCmp  :  public Samson_Peer::MessageBase
{
	public:
		MonteCarloCmp() : MessageBase("MonteCarloCmp","MonteCarloCmp")
		{
			obj_ptr = reinterpret_cast<void*>(&Run);
			obj_ptr_len = sizeof(Run);
		}
		~MonteCarloCmp(){}
	  int getRunNumber()
	  {
	     return Run.Run_Number;
	  }
	  void setRunNumber (int arun_number)
	  {
		  Run.Run_Number = arun_number;
	  }
	  int getModelId()
	  {
	    return Run.Model_id;
	  }
	  void setModelID(int amodel_id)
	  {
	     Run.Model_id = amodel_id;
	  }

   private:
	  struct
	  {
		 int Run_Number;
	     int Model_id;
	  } Run;

};

#endif
