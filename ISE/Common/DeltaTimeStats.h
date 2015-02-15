#ifndef DELTATIMESTATS_
#define DELTATIMESTATS_

#include "ISE.h"

class DeltaTimeStats
{
public:
	DeltaTimeStats() { this->reset(); }
	void reset (void)
	{
		this->delta_sum = 0.0;
		this->delta_sq = 0.0;
		this->delta_min = 0.0;
		this->delta_max = 0.0;
		this->count = 0;
	}
	void sample (double delta)
	{
		this->count++;
		this->delta_sum += delta;
		this->delta_sq += delta*delta;
		if (this->count > 1)
		{
			if (delta < this->delta_min) this->delta_min = delta;
			if (delta > this->delta_max) this->delta_max = delta;
		}
		else
		{
			this->delta_min = delta;
			this->delta_max = delta;
		}
	}
	void compute(int &count, double &mean, double &stddev, double &delta_min, double &delta_max )
	{
		mean = 0.0;
		stddev = 0.0;
		if ( this->count > 1 )
		{
			int theCount = this->count;
			mean =  this->delta_sum /  theCount;
			stddev = sqrt( (this->count*this->delta_sq -
					this->delta_sum*this->delta_sum)/
					theCount/
					(theCount-1)
			);
		}
		count = this->count;
		delta_min = this->delta_min;
		delta_max = this->delta_max;
	}
	void print(void)
	{
		int cnt;
		double mean, stddev, dmin, dmax;
		this->compute (cnt, mean, stddev, dmin, dmax);
		ACE_DEBUG((LM_DEBUG, "DeltaTimeStats: M=%f STD=%f, DELTA=(%f,%f) N=%d\n",
				mean, stddev, dmin, dmax, cnt
		));
	}
private:
	double delta_sum;
	double delta_sq;
	double delta_min;
	double delta_max;
	unsigned int count;
};

#endif /*DELTATIMESTATS_*/
