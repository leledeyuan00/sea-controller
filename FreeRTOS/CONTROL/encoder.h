#ifndef __ENCODER_
#define __ENCODER_
 
#include <stdint.h>
#define TWO_TAMA

typedef struct
{
	uint16_t raw;
	int16_t cal;
	float single;
	float joint;
	int32_t out;
}sensor_info;

typedef enum
{
	#ifndef TWO_TAMA
	TAMA = 0,
	SPI,
	#else
	TAMA1 = 0,
	TAMA2,
	#endif
	MAXON,
	ALL_ENCODER
}ENCODER_NO;

#ifndef TWO_TAMA
extern void init_encoder(sensor_info* tamagawa, sensor_info* spi, sensor_info* maxon);

extern void parse_encoder(sensor_info* tamagawa, sensor_info* spi, sensor_info* maxon);
#else
extern void init_encoder(sensor_info* tama1, sensor_info* tama2, sensor_info* maxon);
extern void parse_encoder(sensor_info* tama1, sensor_info* tama2, sensor_info* maxon);
#endif

#endif