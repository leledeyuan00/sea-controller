#include "control.h"
#include <sys.h>
#include <math.h>
#include <stdlib.h>
#define PI 3.1415926

void traj_generate(TRAJ_SWITCH switch_signal, s16 desired, JOINT_INFO* joint)
{
	static u8 generate_begin = 0;
	static int inc_position;
	static s16 saved_position;
	static s16 saved_desired = 65535;
	static float t;
	static u8 dot_begin,trajectory_begin;
	static u16 xtz = 0;
	static u8 traj_cnt;
	
	
	if(switch_signal == DOT)
	{
		trajectory_begin =0;
		if (desired != saved_desired){
		dot_begin = 1;		
		inc_position = desired - saved_desired;
		saved_position = saved_desired;
		saved_desired = desired;			
		t = 0;
		}
		if(dot_begin)
		{
			if(t <= PI)
			{
				t = t + ( PI /1000);
				joint->position.next = -(inc_position/2) *cos(t)+ inc_position/2 + saved_position;
				joint->speed.next = (inc_position/2) * sin(t);
				joint->accelerate.next = (inc_position/2) *cos(t);
			}
			else
			{	
				dot_begin = 0;
				
				joint->position.next = desired;
				joint->speed.next = 0;
				joint->accelerate.next = 0;
			}
		}
	}
	else if(switch_signal == HAND){
		if(trajectory_begin == 0)
		{
			trajectory_begin = 1;
			dot_begin = 0;
			t = 0;
			traj_cnt = 0;
		}
		if(t >= 2* PI)
		{
			t = 0 + (2 * PI / 1000);
		}
		else
			t = t + (2 * PI / 1000);
		
		joint->position.next = 4096*sin(t) + 4096;
		joint->speed.next = 4096*cos(t);
		joint->accelerate.next = -4096 * sin(t);
	}
	else{
		if(trajectory_begin == 0 )
		{
			trajectory_begin = 1;
			dot_begin = 0;
			t = 0;
		}
		if(t>= 2*PI)
			t = 0 + (2 * PI /4000);
		else
			t = t + (2 * PI /4000);
		
		joint->position.next = 8192*sin(t) + xtz;
		joint->speed.next = 8192*cos(t);
		joint->accelerate.next = -8192 * sin(t);
	}
}

uint8_t constant_speed_traj(JOINT_INFO* joint)
{
	static s16 position_1,position_2,position_3,position_4;
	static s16 speed_1,speed_2,speed_3;
	static float t = 0;
	static u8 dir = 1;
	
	if(t>= 6)
		t = 0 + 0.001;
	else
		t = t + 0.001;
	
	if(t < 0.5 && t>=0)
	{
		joint->position.next = 4000*t*t - 11000;
		joint->speed.next = 8000 * t ;
		joint->accelerate.next = 8000 ;
	}
	else if(t>= 0.5 && t<2.5)
	{
		joint->position.next = 10000*t-15000;
		joint->speed.next = 10000;
		joint->accelerate.next = 0;
	}
	else if(t>=2.5 && t <3.5)
	{
		joint->position.next = (-4000*t*t) + (24000*t) - 25000;
		joint->speed.next = (-8000*t+24000);
		joint->accelerate.next = -8000;
	}
	else if(t>= 3.5 && t < 5.5)
	{
		joint->position.next = -10000*t + 45000;
		joint->speed.next = -10000;
		joint->accelerate.next = 0;
	}
	else if(t>=5.5 && t<6)
	{
		joint->position.next = 4000*t*t - 48000*t + 133000;
		joint->speed.next = 8000*t - 48000;
		joint->accelerate.next = 8000;
	}
	
	if(t>=0 && t<3)
		dir = 1;
	else
		dir = -1;
	return dir;
}

void random_traj(JOINT_INFO* joint)
{
	static u16 random_seed=0;
	float random_value;
	float random_position,last_position,next_speed,last_speed,next_acc;
	
	srand(random_seed);
	random_value = ((float)rand())/(RAND_MAX+1.0);
	
	random_seed = (int)(random_value *1000);
	
	random_position = (random_value-0.5) * 2000;
	
	next_speed = (random_position - last_position)*10;
	
	next_acc = (next_speed - last_speed) *10;
	
	joint->position.next = (s16)random_position;
	joint->speed.next = (s16)next_speed;
	joint->accelerate.next = (s16)next_acc;
	
	last_position = random_position;
	last_speed = next_speed;
}