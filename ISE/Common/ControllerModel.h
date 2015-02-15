/*
 * ControllerModel.h
 *
 *  Created on: Jun 16, 2009
 *      Author: lavender
 */

#ifndef CONTROLLERMODEL_H_
#define CONTROLLERMODEL_H_


#include "ISE.h"

#include "SamsonModel.h"


namespace Samson_Peer {

// =====================================================================
class ISE_Export SamsonControllerModel : public SamsonModel
{
public:

	// Used to subscribe to the proper messages
	virtual int init(int argc, ACE_TCHAR *argv[]);

	// Unlike "most" service objects, I need to override!
	SamsonControllerModel();
	virtual ~SamsonControllerModel();


protected:

	// Shortcuts for messages to send
	void sendStartFrame(unsigned int modelID);
	void sendInitCase(void);
	void sendEndCase(void);
	void sendEndRun(void);
	void sendTimeAdvanced(void);
	void sendAdvanceTime(void);
	void sendRegisterEndEngage(void);
	void sendEndEngage(void);

	// AdvanceTime or StartFrame message moves times?
	bool separate_advance_time_;

	// Is an EndFrame message to be sent?
	bool send_end_frame_;

};

} // namespace

#endif



















#endif /* CONTROLLERMODEL_H_ */
