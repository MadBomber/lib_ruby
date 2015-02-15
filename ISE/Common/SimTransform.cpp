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

#define ISE_BUILD_DLL

#include "SimTransform.h"

#include <iostream>
#include <iomanip>

// ===========================================================================
// ===========================================================================

char const *SimTransform::alphabet_ =
		"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

char const *SimTransform::hexUpper_ = "0123456789ABCDEF";
char const *SimTransform::hexLower_ = "0123456789abcdef";



// ======================================================================================
SimTransform::SimTransform(char *data)
{
	this->data_ = data;
	this->len_ = ACE_OS::strlen(data);
	this->result_ = 0;
	this->result_len_ =0;
}

// ======================================================================================
SimTransform::SimTransform(char *data, unsigned int len)
{
	this->data_ = data;
	this->len_ = len;
	this->result_ = 0;
	this->result_len_ =0;
}


// ======================================================================================
SimTransform::~SimTransform()
{
	delete[] this->result_;
}


// ======================================================================================
int
SimTransform::ConvToNumber(char inByte)
{
	if (inByte >= '0' && inByte <= '9')
		return inByte - '0';
	if (inByte >= 'A' && inByte <= 'F')
		return inByte - 'A' + 10;
	if (inByte >= 'a' && inByte <= 'f')
		return inByte - 'a' + 10;
	return -1;
}

// ======================================================================================
void
SimTransform::decode_base64 ()
{
	char inalphabet[256], decoder[256];
	char *buf = new char[this->len_];

	ACE_OS::memset (inalphabet, 0, sizeof (inalphabet));
	ACE_OS::memset (decoder, 0, sizeof (decoder));

	for (int i = ACE_OS::strlen (SimTransform::alphabet_) - 1;
		i >= 0;
		i--)
	{
		inalphabet[(unsigned int) SimTransform::alphabet_[i]] = 1;
		decoder[(unsigned int) SimTransform::alphabet_[i]] = i;
	}

	char *indata = this->data_;
	char *outdata = buf;

	int bits = 0;
	int c = 0;
	int char_count = 0;
	int error = 0;

	for( unsigned int ii=0; ii<this->len_; ii++)
	{
		c = indata[ii];
		if (c == '=') break;
		if (c > 255 || ! inalphabet[c]) continue;
		bits += decoder[c];
		char_count++;
		if (char_count == 4)
		{
          *outdata++ = (bits >> 16);
          *outdata++ = ((bits >> 8) & 0xff);
          *outdata++ = (bits & 0xff);
          bits = 0;
          char_count = 0;
		}
    	else
			bits <<= 6;
    }

	if (c == '\0')
	{
		if (char_count)
		{
			ACE_DEBUG ((LM_DEBUG,
				"base64 encoding incomplete: at least %d bits truncated\n",
				((4 - char_count) * 6)));
			error++;
		}
    }
	else
	{
		// c == '='
		switch (char_count)
		{
			case 1:
				ACE_DEBUG ((LM_DEBUG,
					"base64 encoding incomplete: at least 2 bits missing\n"));
				error++;
			break;

			case 2:
				*outdata++ = (bits >> 10);
			break;
        case 3:
          *outdata++ = (bits >> 16);
          *outdata++ = ((bits >> 8) & 0xff);
          break;
        }
    }
	*outdata = '\0';

    if ( error )
    	delete buf;
    else
    {
    	this->result_ = buf;
        this->result_len_ = outdata - buf;
    }
	return;
}



// ==========================================================================
void
SimTransform::encode_base64()
{
	char *buf = new char[2*this->len_];
	int c;
	int error = 0;
	int char_count = 0;
	int bits = 0;
	char *indata = this->data_;
	char *outdata = buf;
	const unsigned char ASCII_MAX = ~0;

	for( unsigned int ii=0; ii<this->len_; ii++)
	{
		c = indata[ii];
		if (c > (int)ASCII_MAX)
        {
        	ACE_DEBUG ((LM_DEBUG, "encountered char > 255 (decimal %d)\n", c));
            error++;
            break;
        }
		bits += c;
		char_count++;

		if (char_count == 3)
		{
			*outdata++ = SimTransform::alphabet_[bits >> 18];
			*outdata++ = SimTransform::alphabet_[(bits >> 12) & 0x3f];
    		*outdata++ = SimTransform::alphabet_[(bits >> 6) & 0x3f];
    		*outdata++ = SimTransform::alphabet_[bits & 0x3f];
          bits = 0;
          char_count = 0;
        }
		else
        	bits <<= 8;
    }

	if (!error)
	{
		if (char_count != 0)
		{
          bits <<= 16 - (8 * char_count);
          *outdata++ = SimTransform::alphabet_[bits >> 18];
          *outdata++ = SimTransform::alphabet_[(bits >> 12) & 0x3f];

          if (char_count == 1)
            {
              *outdata++ = '=';
              *outdata++ = '=';
            }
          else
            {
              *outdata++ = SimTransform::alphabet_[(bits >> 6) & 0x3f];
              *outdata++ = '=';
            }
		}
		*outdata = '\0';
	}

    if ( error )
    	delete buf;
    else
    {
    	this->result_ = buf;
        this->result_len_ = outdata - buf;
    }
	return;
}




// ======================================================================================
void
SimTransform::decode_base16 ()
{
	char *buf = new char[this->len_];
	char *indata = this->data_;
	char *outdata = buf;

	int c;
	int last = -1;
	int error = 0;

	for( unsigned int ii=0; ii<this->len_; ii++)
	{
    	c = indata[ii];
		int i=ConvToNumber(c);
		if (i >= 0)
		{
			if (last >= 0)
			{
				*outdata++ =((last << 4) | i);
				last = -1;
			}
			else
				last = i;
		}
    }
	*outdata = '\0';

    if ( error )
    	delete buf;
    else
    {
    	this->result_ = buf;
        this->result_len_ = outdata - buf;
    }
	return;
}




// ==========================================================================
void
SimTransform::encode_base16 (bool uppercase)
{
	char *buf = new char[2*this->len_+1];
	unsigned int c;
	int error;
	error = 0;
	char *indata = this->data_;
	char *outdata = buf;
	const unsigned char ASCII_MAX = ~0;

	const char *ahex = uppercase ? SimTransform::hexUpper_ : SimTransform::hexLower_;

	for( unsigned int ii=0;ii<this->len_; ii++)
	{
    	c = (unsigned char) indata[ii];
		if (c > (int)ASCII_MAX)
		{
			ACE_DEBUG ((LM_DEBUG, "encountered char > 255 (decimal %d)\n", c));
			error++;
            break;
        }
		*outdata++ =  ahex[c >> 4];
		*outdata++ =  ahex[c & 0x0F];
	}
	*outdata = '\0';

    if ( error )
    	delete buf;
    else
    {
    	this->result_ = buf;
        this->result_len_ = outdata - buf;
    }
	return;
}


// ==========================================================================
void
SimTransform::make_printable()
{
	char *buf = new char[this->len_+1];
	int error;
	error = 0;
	char *indata = this->data_;
	char *outdata = buf;
	const unsigned char PRINT_MIN = 0x20;
	const unsigned char PRINT_MAX = 0x7E;

	for( unsigned int ii=0;ii<this->len_; ii++)
	{
		*outdata++ = ( PRINT_MIN <= indata[ii] && indata[ii] <= PRINT_MAX) ? indata[ii] : PRINT_MIN;
	}
	*outdata = '\0';

    	this->result_ = buf;
        this->result_len_ = outdata - buf;

	return;
}
	

// ==========================================================================

