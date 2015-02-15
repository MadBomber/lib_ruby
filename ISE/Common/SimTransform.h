/**
 *	@file SimTransform.h
 *
 *	@class SimTransform
 *
 *	@brief Encode/Decode Base 16/64
 *
 *	@author Jack K. Lavender, Jr. <jack.lavender@lmco.com>
 *
 */


#ifndef SIM_TRANSFORM_H
#define SIM_TRANSFORM_H

#include "ISE.h"

// ===================================================================================
class ISE_Export SimTransform
{
	public:
		SimTransform(char *data, unsigned int len);
		SimTransform(char *data);
		~SimTransform();

		void decode_base64();
		void encode_base64();
		void decode_base16();
		void encode_base16(bool uppercase = false);

		void make_printable();

		void result(char *data, int *len){ *len = this->result_len_; data =  this->result_; }
		const char *result() { return this->result_; }
		unsigned int nresult() { return this->result_len_; }

	private:

		static int ConvToNumber(char inByte);
		// Utility for Encoding/Decoding Functions

		static char const *alphabet_;
 		// Used for B64 Encoding

		static char const *hexUpper_;
		static char const *hexLower_;
		// Used for B16 Encoding

		char *data_;
		unsigned int len_;
		// input data

		char *result_;
		unsigned int result_len_;
};


#endif
