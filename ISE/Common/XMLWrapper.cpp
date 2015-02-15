#define ISE_BUILD_DLL

#include <stdio.h>    // to get "printf" function
#include <stdlib.h>   // to get "free" function

#include "XMLWrapper.h"
#include "ace/Get_Opt.h"
#include "xmlParser.h"

XMLNode ISEXMLWrapper_getXMLRoot(std::string app_key, int unit_id, char *errorMsg);
XMLNode ISEXMLWrapper_getXMLRoot(std::string directory, std::string app_key, int unit_id, char *errorMsg);
XMLNode ISEXMLWrapper_getXMLRoot(std::string fullpath, char *errorMsg);

int ISEXMLWrapper_fillVariables(XMLNode parentNode, char * elements[], double * variables[], double defaults[], int use_defaults, char *errorMsg);
int ISEXMLWrapper_getDouble(XMLNode parentNode, char *nodeName, double *value, double defaultValue, int use_defaults, char *errorMsg);

int ISEXMLWrapper_searchNodesAndFill(std::string app_key, int unit_id, char * elements[], double * variables[], double defaults[], char *errorMsg)
{
	XMLNode xNode, childNode;
	int model_position=0, no_more_models = 0, base_pos = -1, override_pos = -1, status=1;
	
	//Convert unit_id to string for XML text comparison
	char unit_id_str[20];
	sprintf(unit_id_str, "%d", unit_id);
	
	//Look For:		'ISE_ROOT/input/[app_key]_[unit_id].xml'.
	//Alternative:	'ISE_ROOT/input/[app_key].xml'.
	//Find Root Node: 'ISEModelData'
	//Return reference to Root
	XMLNode xMainNode = ISEXMLWrapper_getXMLRoot(app_key, unit_id, errorMsg); 

	//If no reference is returned...
	if (xMainNode.isEmpty())
	{
		//sprintf(errorMsg, "No XML File to Parse\n");
		status = 3;
	}
	else
	{
		do
		{
			//Iterate through each 'Model' Node within root xml node...
			xNode = xMainNode.getChildNode("Model", &model_position);

			if (xNode.isEmpty())
				no_more_models = 1;
			else
			{
				//Look for Model->UnitID field
				childNode = xNode.getChildNode("UnitID");

				//If UnitID does not exist or if its equal to -1: use info as Base Information (base)
				if (childNode.isEmpty() || (strcmp(childNode.getText(), "-1") == 0))
				{
					base_pos = model_position-1;

					//Fill Model variables with XML data defined within Model->Initialization Node
					ISEXMLWrapper_fillVariables(xNode, elements, variables, defaults, 1, errorMsg);
				}
				//If UnitID is equal to the current model's unit_id (override), save position for later
				else if (strcmp(childNode.getText(), unit_id_str) == 0)
				{
					override_pos = model_position-1;
				}
			}

			//Continue to look until no more model nodes found, 
			//or both a base and override position has been found
		} while (!no_more_models && !((base_pos >= 0) && (override_pos >= 0)));
	}

	//If not base information was found, initialize model variables with default values
	if (base_pos < 0)
	{
		//sprintf(errorMsg, "");
		ISEXMLWrapper_fillVariables(XMLNode::emptyXMLNode, elements, variables, defaults, 1, errorMsg);
		if (status != 3) status = 2;
	}

	//If information for a specific model's unit_id was found (override), 
	//return to the node and populate model variables
	if (override_pos >= 0)
	{
		xNode = xMainNode.getChildNode("Model", override_pos);
		
		*errorMsg = 0;
		ISEXMLWrapper_fillVariables(xNode, elements, variables, defaults, 0, errorMsg);
		status = 0;
	}

	return status;
}


int ISEXMLWrapper_fillVariables(XMLNode parentNode, char * elements[], double * variables[], double defaults[], int use_defaults, char *errorMsg)
{
	//By default, assume there is an 'Initialization' Node within the current node
	XMLNode childNode = parentNode.getChildNode("Initialization");

	char tempErrorMsg[1024];
	int status = 0;

	//For each element being searched for...
	for(int i = 0; elements[i] != 0; i++ )
	{
		//Find element within Model->Initialization Node, parse text, and store double value in model variable
		if (ISEXMLWrapper_getDouble(childNode, elements[i], variables[i], defaults[i], use_defaults, tempErrorMsg) != 0)
		{
			strcat(errorMsg,tempErrorMsg);
			status = 1;
		}
	}

	return status;

}

XMLNode ISEXMLWrapper_getXMLRoot(std::string app_key, int unit_id, char *errorMsg)
{
	//If no directory is specified, look at environmental variables for root
	std::string theFilename = "./";
	const char* temp_envs[] = { "ISE_RUN", "ISE_ROOT", 0 };
	for(const char** temp_env = temp_envs; *temp_env != 0; ++temp_env)
	{
		char* tdir = ACE_OS::getenv(*temp_env);
		if (tdir != 0)
		{
			theFilename = tdir;
			break;
		}
	}

	theFilename += "/input";
	return ISEXMLWrapper_getXMLRoot(theFilename, app_key, unit_id, errorMsg);
}

XMLNode ISEXMLWrapper_getXMLRoot(std::string directory, std::string app_key, int unit_id, char *errorMsg)
{
	//If no file name is specified, try...

	std::string theFilename = directory;
	char delimiter = '_';
	std::string suffix = ".xml";
	FILE * handle;

	char unit_id_str[20];
	sprintf(unit_id_str, "%d", unit_id);
	
	//[app_key]_[unit_id].xml
	theFilename += "/";
	theFilename += app_key;
	theFilename += delimiter;
	theFilename += unit_id_str;
	theFilename += suffix;

	//Does the file exist?
	handle = fopen(theFilename.c_str(),"r");
	if (handle == 0)
	{
		//If not, try [app_key].xml
		theFilename = directory;
		theFilename += "/";
		theFilename += app_key;
		theFilename += suffix;

		//Does that file exist?
		handle = fopen(theFilename.c_str(),"r");
		if (handle == 0)
		{
			sprintf(errorMsg, "Can't find filename at: %s\n", theFilename.c_str());
			return XMLNode::emptyXMLNode;
		}
	}

	fclose(handle);
	return ISEXMLWrapper_getXMLRoot(theFilename, errorMsg);
}

XMLNode ISEXMLWrapper_getXMLRoot(std::string fullpath, char* )
{
	FILE * handle = fopen(fullpath.c_str(),"r");
	if (handle == 0)
	{
		return XMLNode::emptyXMLNode;
	}
	else
	{
		fclose(handle);
		return XMLNode::openFileHelper(fullpath.c_str(), "ISEModelData");
	}
}


int ISEXMLWrapper_getDouble(XMLNode parentNode, char nodeName[1024], double * value, double defaultValue, int use_default, char *errorMsg)
{
	std::string nodeText;

	if (!parentNode.isEmpty())
	{
		if (!parentNode.getChildNode(nodeName).isEmpty())
			nodeText = parentNode.getChildNode(nodeName).getText();
		else
			nodeText = "";
	}
	else
		nodeText = "";

	char * p;
	
	if (nodeText != "")
	{
		*value = strtod(nodeText.c_str(), &p);
		return 0;
	}
	else
	{
		if (use_default)
		{
			*value = defaultValue;
			sprintf(errorMsg, "Missing XML File w/ Node '%s'. Using default value: %f\n", nodeName, *value);
		}
		else
		{
			sprintf(errorMsg, "Missing XML File w/ Node '%s'. Not using a default value!\n", nodeName);
		}

		return -1;
	}
	
}



