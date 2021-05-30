#include "control_task.h"
#include <sys.h>
#include <math.h>
#include <stdlib.h>
#include "control.h"
#include "encoder.h"
#include "delay.h"
#include "../fmc/fmc.h"
#include "FreeRTOS.h"
#include "task.h"
#include "../fmc/fmc.h"
#include "../SYSTEM/std.h"


extern u8 controlbegin;
extern u8 begins;	

u16 dumoch1[20];
u16 temp;
s16 desired = 0;
	u16 i=0;
	u16 j=0;
	float Y;
	long int YI;
	long insignal;
  s16 debug_variable[6];
	s16 error_position;
long controller_u_raw;
s16 controller_u;
float xt;
long int xtmp;
unsigned short int abz;
unsigned char Send_Count;

float dtheta_f,ddtheta_f;
s16 dtheta,ddtheta;
s16 dtheta_back;
float xt1=0;
float rate;
static long int xtz =15000;


float Y;
float ABZ;
float Z;
u16 tttt;
float joint_angle;
s16 INC_raw;
float INC_angle;
u8 zero;
long joint_zero;
static int interact_count=0;

u16 debug_rs485[4];
TRAJ_SWITCH switch_signal = 0;
static INTERACT_STATE interact_state = 0;
static s16 interact_position;
float SPI_RAW,SPI_ZERO;

	float spi_joint;
	u16 INC_INIT;
	u8 spi_round_number;
static JOINT_INFO joint;
#ifndef TWO_TAMA
sensor_info tamagawa,spi,maxon;
	s16 enc_tama;
	s16 enc_spi;
	s16 enc_maxon;
#else
sensor_info tama1,tama2,maxon;
	s16 enc_tama1;
	s16 enc_tama2;
	s16 enc_maxon;
#endif

float desired_joint = 0;

float force ;
s16 force_raw;
static float s_k = 1;
s16 spring_error;

s16 positive_error;
s16 negetive_error;

s16 interpolation_position[10];
s16 theta_d;
s16 dp;
s16 error_pos;
#define COMPARE_DEBUG


s16  temp_desired;
void task2_task(void *pvParameters)
{
	u8 task2_num=0;
  u8 q=0;
	u16 da;
	u8 inter_count;
  uint32_t t1, t2;
	static u8 stop_begin = 0;
	static int stop_t = 0;	
	static s16 error_cnt = 0;
	static u8 dir;
	static u8 impadence_switch = 0;
	static u8 impadence_k = 1;
	#ifndef TWO_TAMA
	init_encoder(&tamagawa,&spi,&maxon);
	#else
	init_encoder(&tama1,&tama2,&maxon);
	#endif
	
	while(1)
	{
		#ifndef TWO_TAMA
		parse_encoder(&tamagawa, &spi, &maxon);
		enc_tama = tamagawa.cal;
		enc_spi = spi.cal;
		enc_maxon = maxon.cal;
		#else
		parse_encoder(&tama1,&tama2,&maxon);
		enc_tama1 = tama1.cal;
		enc_tama2 = tama2.cal;
		enc_maxon = maxon.cal;
		#endif

		/* jscope*/
		

		#ifndef 	COMPARE_DEBUG
		dumoch1[0] = fpga_read(0x41);
		delay_us(1);
		dumoch1[1] = fpga_read(0x42);
		delay_us(1);
		dumoch1[2] = fpga_read(0x43);
		delay_us(1);
		dumoch1[3] = fpga_read(0x44);
		delay_us(1);
		dumoch1[4] = fpga_read(0x45);
		delay_us(1);
		dumoch1[5] = fpga_read(0x46);
		delay_us(1);
		dumoch1[6] = fpga_read(0x47);
		delay_us(1);
		dumoch1[7] = fpga_read(0x48);
		delay_us(1);
		dumoch1[8] = fpga_read(0x49);
		delay_us(1);
		dumoch1[9] = fpga_read(0x4A);
		delay_us(1);
		dumoch1[10]= fpga_read(0x4B);
		delay_us(1);
		dumoch1[11]= fpga_read(0x4C);
		delay_us(1);
		dumoch1[12]= fpga_read(0x4D);
		delay_us(1);
		dumoch1[13]= fpga_read(0x4E);
		dumoch1[14]= fpga_read(0x4F);
		dumoch1[15]= fpga_read(0x40);

		debug_variable[0] = dumoch1[15];
		debug_variable[1] = dumoch1[8];
		debug_variable[2] = dumoch1[10];
		debug_variable[3] = dumoch1[11];
		debug_variable[4] = dumoch1[12];
		//debug_variable[5] = dumoch1[13];
		debug_variable[5] = fpga_read(0x13);
		dtheta_back = dumoch1[14];


		controller_u_raw = ((dumoch1[7])<<16) | (dumoch1[14]);
		controller_u = (dumoch1[3]);
		#else
		for(inter_count =0;inter_count<10;inter_count++)
		{
			interpolation_position[inter_count] = fpga_read((0x40+inter_count));
			delay_us(1);
		}
		theta_d = fpga_read(0x4A);
		delay_us(1);
		controller_u = fpga_read(0x4B);
		delay_us(1);
		dp = fpga_read(0x4C);
		delay_us(1);
		debug_variable[0] = fpga_read(0x4d);
		delay_us(1);
		debug_variable[1] = fpga_read(0x4e);
		delay_us(1);
		debug_variable[2] = fpga_read(0x4f);
		delay_us(1);
		#endif
		
		
		/**/
		debug_rs485[0] = fpga_read(0x14);
		debug_rs485[1] = fpga_read(0x15);
		debug_rs485[2] = fpga_read(0x16);
		debug_rs485[3] = fpga_read(0x17);
		joint_angle = ((float)((int)(debug_rs485[2]&0x01)<<16 | debug_rs485[1]))*360/131071;
		
		/**/
		#ifndef TWO_TAMA
		force = (tamagawa.joint - maxon.joint) * s_k;
		force_raw = (tamagawa.cal - maxon.cal) *s_k;
		joint.position.current = (int16_t)tamagawa.cal;
		#else
		force = (tama1.joint - tama2.joint) * s_k;
		force_raw = (enc_tama1 - enc_tama2) *s_k;
		joint.position.current = (int16_t)tama2.cal;
		#endif
		if(desired_joint >= -180 && desired_joint < 180)
			desired = desired_joint *65535/360;

		if(controlbegin  == 0x02){
		 controlbegin = 0x00;
		 begins = 0;
		 fpga_write(0x45,0);
		interact_state = START;
		}				
		if(controlbegin == 0x01)
		{
			fpga_write(0x45,1);//enable motor
			delay_us(5);
			begins = 1;
			controlbegin = 0x00;
			delay_us(1);
			fpga_write(0x44,impadence_switch);
			fpga_write(0x46,impadence_k);
		}
		if(controlbegin == 0x03) // impadence interact
		{
			fpga_write(0x45,1);//enable motor
			delay_us(5);
			begins = 2;
			controlbegin = 0x00;
			delay_us(1);
		}
		if(controlbegin == 0x04) //zero force interact
		{
			fpga_write(0x45,1);//enable motor
			delay_us(5);
			begins = 4;
			controlbegin = 0x00;
			delay_us(1);
		}
		if(controlbegin == 0x05)
		{
			fpga_write(0x45,2);//for test
			begins = 1;
			controlbegin = 0x00;
		}
		
		if(begins == 1)
		{
//					#ifndef COMPARE_DEBUG
			traj_generate(switch_signal,desired,&joint);
//					dir = constant_speed_traj(&joint);
//					#else
//					RunOnceEvery(100,random_traj(&joint));
			//theta_d = joint.position.next;
			spring_error = enc_tama1 - enc_tama2 - error_cnt;
//					#endif
			//fpga_write(0x41,joint.position.next);
			fpga_write(0x41,joint.position.next);
			delay_us(1);
			fpga_write(0x42,joint.speed.next);
			delay_us(1);
			fpga_write(0x43,joint.accelerate.next);	
		}
		else if(begins == 2)
		{
			if(interact_state == START)
			{
				traj_generate(switch_signal,desired,&joint);
				spring_error = enc_tama1 - enc_tama2 - error_cnt;
				fpga_write(0x41,joint.position.next);
				delay_us(1);
				fpga_write(0x42,joint.speed.next);
				delay_us(1);
				fpga_write(0x43,joint.accelerate.next);	
				if(interact_count >= 4000)
				{
					interact_count = 0;
					interact_state = RUNNING;
				}
				else
					interact_count++;
			}
			else if(interact_state == RUNNING)
			{
				traj_generate(switch_signal,desired,&joint);
				spring_error = enc_tama1 - enc_tama2 - error_cnt;
				fpga_write(0x41,joint.position.next);
				delay_us(1);
				fpga_write(0x42,joint.speed.next);
				delay_us(1);
				fpga_write(0x43,joint.accelerate.next);	
				if(abs(debug_variable[1])>20)
				{
					interact_count++;
				}
				else
				{
					interact_count = 0;
				}
				if(interact_count >= 5)
				{
					interact_position = joint.position.next;
					interact_state = INTERACT;
					interact_count = 0;
				}
			}
			else 
			{
				fpga_write(0x41,interact_position);
				delay_us(1);
				fpga_write(0x42,0);
				delay_us(1);
				fpga_write(0x43,0);	
				delay_us(1);
				fpga_write(0x44,0x02);
				delay_us(1);
				fpga_write(0x46,0x05);
				delay_us(1);
				spring_error = enc_tama1 - enc_tama2 - error_cnt;
				if(abs((debug_variable[1]>>5)) > 10)
				{
					interact_count = 0;
				}
				if(interact_count >= 2000)
				{
					interact_state = START;
					interact_count = 0;
					fpga_write(0x44,impadence_switch);
					fpga_write(0x46,0x00);
				}
				else
					interact_count++;
			}
		}
		else if(begins == 4)
		{
			spring_error = enc_tama1 - enc_tama2 - error_cnt;
			if(interact_state == START)
			{
				traj_generate(switch_signal,desired,&joint);
				spring_error = enc_tama1 - enc_tama2 - error_cnt;
				fpga_write(0x41,joint.position.next);
				delay_us(1);
				fpga_write(0x42,joint.speed.next);
				delay_us(1);
				fpga_write(0x43,joint.accelerate.next);	
				if(interact_count >= 4000)
				{
					interact_count = 0;
					interact_state = RUNNING;
				}
				else
					interact_count++;
			}
			else if(interact_state == RUNNING)
			{
				traj_generate(switch_signal,desired,&joint);
				spring_error = enc_tama1 - enc_tama2 - error_cnt;
				fpga_write(0x41,joint.position.next);
				delay_us(1);
				fpga_write(0x42,joint.speed.next);
				delay_us(1);
				fpga_write(0x43,joint.accelerate.next);	
				if(abs(debug_variable[1])>25)
				{
					interact_count++;
				}
				else
				{
					interact_count = 0;
				}
				if(interact_count >= 5)
				{
					interact_position = joint.position.next;
					interact_state = INTERACT;
					interact_count = 0;
				}
			}
			else 
			{
				fpga_write(0x41,0);
				delay_us(1);
				fpga_write(0x42,0);
				delay_us(1);
				fpga_write(0x43,0);	
				delay_us(1);
				fpga_write(0x44,0x03);
				delay_us(1);
				fpga_write(0x46,0x05);
				delay_us(1);
				if(abs((debug_variable[1]>>5)) > 3)
				{
					interact_count = 0;
				}
				if(interact_count >= 2000)
				{
					interact_state = START;
					interact_count = 0;
					fpga_write(0x44,impadence_switch);
					fpga_write(0x46,0x00);
				}
				else
					interact_count++;
			}				
		}
		
		
		error_pos = enc_tama1 - joint.position.next;
//		if(dir)
//		{
//			positive_error = tamagawa.cal - maxon.cal;
//			negetive_error = 0;
//		}
//		else
//		{
//			negetive_error = tamagawa.cal - maxon.cal;
//			positive_error = 0;
//		}
	vTaskDelay(1);                           
	}
}