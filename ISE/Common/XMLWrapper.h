#ifndef XMLWRAPPER_H
#define XMLWRAPPER_H

#include <stdio.h>    // to get "printf" function
#include <stdlib.h> 
#include <string>

#include "ISE.h"

int ISE_Export ISEXMLWrapper_searchNodesAndFill(std::string app_key, int unit_id, char * elements[], double * variables[], double defaults[], char errorMsg[1024]);

#endif
