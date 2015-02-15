/*
 * Simplej_SpaceTrack.h
 *
 *  Created on: Jul 14, 2009
 *
 * TODO: Extract SimpleJ Header/Footer into seperate file
 * TODO: Create Link-16 common header file
 * TODO: Make this header file specific to only the Link-16 SpaceTrack message
 */

#ifndef SIMPLEJ_SPACETRACK_H_
#define SIMPLEJ_SPACETRACK_H_


#include <iomanip>
#include <iostream>
#include <vector>
#include <string>


#include <stdlib.h>

typedef std::vector<unsigned char> Vec;

// ========================================================
// The trick...an N bit integer for the bit field
// TODO:  trap invalid (too long) assignment
template <int N>
class Int
{
	unsigned int val;
public:
	Int():val(0){}
	Int(unsigned int init):val(init){}
	unsigned int operator=(unsigned int nval){return val=nval;}
	operator unsigned int&(){return val;}
};

// ========================================================
//  Uses the vector to accumulate the message
class Pack
{
public:
	Pack(Vec& v):v(v),ptr(&v[0]),offset(0){}
	template <int N>
	void apply(Int<N>& val)
	{
		union {
			unsigned long long word;
			unsigned char byte[8];
		} silly;


		silly.word=val<<offset|*ptr;
		unsigned char *p=&silly.byte[0];
		offset+=N;
		switch (offset >> 3) {
		case 4: *ptr++ = *p++;
		case 3: *ptr++ = *p++;
		case 2: *ptr++ = *p++;
		case 1: *ptr++ = *p++;
		case 0: *ptr   = *p  ;
		}
		offset&=7;
	}

	unsigned short checksum()
	{
		unsigned short  sum = 0;
		Vec::iterator it;
		for ( it=v.begin(); it < v.end(); it++ )
		{
			sum += (unsigned int)(*it);
		}
		//cout << "Checksum -> " <<  v.size() << " " << hex << sum << endl;
		return sum;
	}

	void add_checksum()
	{
		union {
			unsigned char a[2];
			unsigned short b;
		} sum;
		sum.b = checksum();
		//cout << "Checksum -> " << hex << sum.b << " (" << int(sum.a[0]) << "," << int(sum.a[1]) << ")" << endl;
		v.push_back(sum.a[0]);
		v.push_back(sum.a[1]);
	}

	void print_hex()
	{
		using namespace std;
		vector<unsigned char>::iterator it;
		cout << "  Pack<" << dec << v.size() << ">(";
		for ( it=v.begin() ; it < v.end(); it++ ) cout << setfill('0') << setw(2) << hex << int(*it);
		cout << ")" << endl;
	}


private:
	Vec& v;
	unsigned char* ptr;  // the "write pointer" in the Vector V
	int offset;
};

// ========================================================
//  Uses the vector to decompose the message
class Unpack
{
public:
	Unpack(Vec& v):v(v),ptr(&v[0]),offset(0){}
	template <int N>
	void apply(Int<N>& val)
	{
		union {
			unsigned long long word;
			unsigned int  half[2];
			unsigned char byte[8];
		};
		word=0;
		unsigned char *p=&byte[0];
		switch ((offset+N) >> 3)
		{
			case 4: *p++ = *ptr++;
			case 3: *p++ = *ptr++;
			case 2: *p++ = *ptr++;
			case 1: *p++ = *ptr++;
			case 0: *p   = *ptr  ;
		}
		word>>=offset;
		word&=(1<<N)-1;
		offset+=N;
		offset&=7;
		val=half[0];
	}
	unsigned int length() { return ptr - &v[0]; }

	unsigned short checksum()
	{
		unsigned short  sum = 0;
		Vec::iterator it;
		for ( it=v.begin() ; it < v.end()-2; it++ )
		{
			sum += (unsigned int)(*it);
		}

		return sum;
	}

	void print_hex()
	{
		using namespace std;
		vector<unsigned char>::iterator it;
		cout << "Unpack<" << dec << v.size() << ">(";
		for ( it=v.begin() ; it < v.end(); it++ ) cout << setfill('0') << setw(2) << hex << int(*it);
		cout << ")" << endl;
	}


private:
	Vec& v;
	unsigned char* ptr;
	unsigned int offset;
};


// ========================================================
struct SimpleJ_Header
{
#define TYPES \
	TYPE(Sync_Byte_1            ,                01001001 ) \
	TYPE(Sync_Byte_2            ,                00110110 ) \
	TYPE(Length                 ,        0000000000111100 ) \
	TYPE(Sequence_Num           ,        1100011001110001 ) \
	TYPE(Source_Node            ,                01111101 ) \
	TYPE(Source_Sub_Node        ,                11001110 ) \
	TYPE(Destination_Node       ,                10000001 ) \
	TYPE(Destinatione_Sub_Node  ,                11001110 ) \
	TYPE(Packet_Size            ,                00011010 ) \
	TYPE(Packet_Type            ,                00000001 ) \
	TYPE(Transit_Time           ,        0000000000000000 )

	SimpleJ_Header() {
#include "link16.inc"
	}
};

// ========================================================
struct SimpleJ_Link16_Type_Header
{
#define TYPES \
	TYPE(Message_Sub_Type       ,                00000010 ) \
	TYPE(R_C_Flag               ,                00000000 ) \
	TYPE(Net_Num                ,                00000000 ) \
	TYPE(Seq_Slot_Count_F2      ,                00000000 ) \
	TYPE(NPG_Num                ,        0000000000000111 ) \
	TYPE(Seq_Slot_Count_F1      ,        0000000000000000 ) \
	TYPE(STN                    ,        0000000000000001 ) \
	TYPE(Word_Count             ,        0000000000001111 ) \
	TYPE(Loopback_ID            ,        0000000000000000 )

	SimpleJ_Link16_Type_Header() {
#include "link16.inc"
	}
};


// ========================================================
struct Link16_Common
{
#define TYPES \
	TYPE(Word_Format            ,                      00 ) \
	TYPE(Label_J_Series         ,                   00011 ) \
	TYPE(Sublabel_J_Series      ,                     110 ) \
	TYPE(Message_len_indicator  ,                     010 )
	Link16_Common() {
#include "link16.inc"
	}
};
// ========================================================
struct Link16_SpaceTrack
{
#define TYPES \
	TYPE(Disused                ,                       0 ) \
	TYPE(Force_Tell             ,                       0 ) \
	TYPE(Special_Proc           ,                       0 ) \
	TYPE(Sim_Indic              ,                       0 ) \
	TYPE(Space_Indic            ,                       0 ) \
	TYPE(TN_LS_3_bit            ,                     111 ) \
	TYPE(TN_Mid_3_bit           ,                     001 ) \
	TYPE(TN_MS_3_bit            ,                     010 ) \
	TYPE(TN_LS_5_bit            ,                   00000 ) \
	TYPE(TN_MS_5_bit            ,                   00001 ) \
	TYPE(Minute                 ,                  111111 ) \
	TYPE(Second                 ,                  111111 ) \
	TYPE(Track_Quality          ,                    1000 ) \
	TYPE(Identity               ,                    0001 ) \
	TYPE(Space_Platform         ,                  000011 ) \
	TYPE(Space_Activ            ,                 0000000 ) \
	TYPE(Unused0                ,              0000000000 ) \
	TYPE(Word_Format1           ,                      10 ) \
	TYPE(X_Position             , 00100011110001101100111 ) \
	TYPE(X_Velocity             ,          11111011010011 ) \
	TYPE(Y_Position             , 00000101111001100110111 ) \
	TYPE(Space_Amplification    ,                   00000 ) \
	TYPE(Amplification_Conf     ,                     000 ) \
	TYPE(Unused1                ,              0000000000 ) \
	TYPE(Word_Format2           ,                      10 ) \
	TYPE(Y_Velocity             ,          00001100001010 ) \
	TYPE(Z_Position             , 00110100011001100011101 ) \
	TYPE(Z_Velocity             ,          00001001011110 ) \
	TYPE(Lost_Track             ,                       0 ) \
	TYPE(Boost_Indicator        ,                       0 ) \
	TYPE(Data_Indicator         ,                     000 ) \
	TYPE(Spare                  ,            000000000000 ) \
	TYPE(Unused2                ,              0000000000 )

	Link16_SpaceTrack() {
#include "link16.inc"
	}
};

// ========================================================
struct SimpleJ_Footer
{
#define TYPES \
	TYPE(Checksum               ,        0000110000100110 )

	SimpleJ_Footer() {
#include "link16.inc"
	}
};


#endif /* SIMPLEJ_SPACETRACK_H_ */
