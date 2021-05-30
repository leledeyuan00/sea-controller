#ifndef __CONTROL_
#define __CONTROL_

#include <sys.h>

typedef struct
{
	s16 current;
	s16 next;
}STATE_INFO;

typedef enum
{
	DOT = 0,
	TRAJ,
	HAND,
	ALL_POSITION
}TRAJ_SWITCH;

typedef struct
{
	STATE_INFO position;
	STATE_INFO speed;
	STATE_INFO accelerate;
}JOINT_INFO;

typedef enum
{
	START = 0,
	RUNNING,
	INTERACT,
	ALL_STATE
}INTERACT_STATE;

extern void traj_generate(TRAJ_SWITCH switch_signal,s16 desired ,JOINT_INFO* joint);
extern uint8_t constant_speed_traj(JOINT_INFO* joint);
extern void random_traj(JOINT_INFO* joint);
extern void begin_task(int begin);

#endif

