/**
 *	@class SimMsgType
 *
 *	@brief Enumerate Type Flags for Headers
 *
 *	This object is used to ...
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>, (C) 2006
 *
 */

#ifndef SimMsgType_H
#define SimMsgType_H

class SimMsgType
{
public:

	// These are the message type_ codes
	enum  {

		UNKNOWN = -1,
		//  -1: There is no type for a DataCount header

		ROUTE = 0,
		//  0: A normal event, which is forwarded to the <Consumers>. (not currently used)

		SUBSCRIBE,
		//  1: A subscription to <Suppliers> managed by the <Event_Channel>. (not currently used)

		DATA,
		//  2: This is data message. See SimMsgFlag for subtyping.

		RECOVERABLE_ERROR_STATUS_RESPONSE,
		//  3: Error has occurred

		FATAL_ERROR_STATUS_RESPONSE,
		//  4: Error has occurred

		OK_STATUS_RESPONSE,
		//  5: OK

		STATUS_REQUEST,
		//  6: Request for status

		XML_COMMAND,
		//  7: The data that follows is and XML command to be parsed.

		START_FRAME,
		//   8: Start of a time tick simulation frame,
		//   This was envisioned to be both a Request/Response
		//   Currently this only a Command

		END_FRAME_REQUEST,
		//   9: End of a frame Request
		//  Currently this is the only thing used.

		END_FRAME_OK_RESPONSE,
		//  10: End of frame Response  (not used)

		END_FRAME_ERROR_RESPONSE,
		//  11: End of frames Response  (not used)

		END_FRAME_COMMAND,
		//  12: End of Frame,  any error must be a terminal error:  FATAL_ERROR_STATUS_RESPONSE

		START_SIMULATION,
		//  13: Used to start the simulation

		END_SIMULATION,
		//  14: Used to stop the simulation (END_SIMULATION)

		START_CASE,
		//  15: Used to start a Monte-Carlo case (START_CASE)

		END_CASE,
		//  16: Used to stop a Monte-Carlo case (END_CASE)

		BREAKWIRE,
		//  17: Used to transmit a breakwire event (start of missile flight)

		IGNITION,
		//  18: (NOT USED) Used to indicate Rocket Motor Ignition

		INVOKE_REQUEST,
		//  19: A DCE-CORBA like request to invoke a procecure.  (Future)

		INVOKE_RESPONSE,
		//  20: A DCE-CORBA like response to a previous request. (Future)

		LOCATE_REQUEST,
		//  21: A DCE-CORBA like request to perform an location lookup.  (Future)

		LOCATE_RESPONSE,
		//  22: A DCE-CORBA like response to a previous location lookup request. (Future)

		HELLO,
		//  23: A channel has come alive (HELLO)

		INIT,
		//  24: Used to initialize (INIT)

		GOODBYE,
		//  25: Shutting down this connection (GOODBYE)

		D2D_CONNECT,
		//  26: Temporary? used by dispatcher to connect to all other dispatchers

		GOODBYE_REQUEST,
		//  27: Request a process to terminate, should result in a GOODBYE response

		DISPATCHER_COMMAND,
		//  28: Request a process to terminate, should result in a GOODBYE response

		LOG_CHANNEL_STATUS,
		//  29: Log the Connection Handler Status (currently list saved messages)

		ADVANCE_TIME_REQUEST,
		//  30: Pre-fire in Ptolemy II parlance, this is used to advance the clock one tick

		TIME_ADVANCED,
		//  31: Response to the Advance Time Request.  (Error response is not yet defined)

		CONTROL,
		//  32: Framework Control message.  Data may or may not be attached

		LOG_EVENT_CHANNEL_STATUS
		//  33: Log the current EventChannel Status
	};
};

#endif

