#include "encoder.h"
#include "../SYSTEM/fmc/fmc.h"
#include "../SYSTEM/delay/delay.h"

#ifndef TWO_TAMA
static uint8_t read_addr[ALL_ENCODER] = {0x12 , 0x21 , 0x61};
static uint8_t write_addr[ALL_ENCODER]= {0x11 , 0x00 , 0x61};

static uint16_t encoder_zero[ALL_ENCODER] = {0x6b90,0x006d,0};
#else
static uint8_t read_addr[ALL_ENCODER] = {0x12 , 0x32 , 0x61};
static uint8_t write_addr[ALL_ENCODER]= {0x11 , 0x31 , 0x61};

static uint16_t encoder_zero[ALL_ENCODER] = {0x3D85, 0xB79B, 0};
#endif
//#define GEAR_DEBUG
#ifndef TWO_TAMA
void init_encoder(sensor_info* tamagawa, sensor_info* spi, sensor_info* maxon)
{
	uint16_t encoder_raw[ALL_ENCODER];
	sensor_info tama_temp,spi_temp,maxon_temp;
	uint8_t spi_round_number;
		
	fpga_write(write_addr[TAMA],encoder_zero[TAMA]);
	delay_us(1);
	spi_temp.raw = (fpga_read(read_addr[SPI])>>6)&0x03ff;
	delay_us(1);
	maxon_temp.raw = fpga_read(read_addr[MAXON]);
	delay_us(1);
	#ifdef GEAR_DEBUG
	maxon_temp.raw = (fpga_read((read_addr[MAXON]+1))<<16)|maxon_temp.raw;
	delay_us(1);
	#endif
	tama_temp.raw = fpga_read(0x11);
	delay_us(1);
	tama_temp.cal = fpga_read(read_addr[TAMA]);
			
	if(spi_temp.raw >= encoder_zero[SPI])
		spi_temp.cal = spi_temp.raw - encoder_zero[SPI];
	else
		spi_temp.cal = spi_temp.raw + 1024 - encoder_zero[SPI];
	
	spi_round_number = tama_temp.cal / (65535 /3);
	tama_temp.single = (float)(tama_temp.cal % (65535/3)) * 360 /65535;
	spi_temp.single = (float)(spi_temp.cal) * 120 /1024;

	if(spi_temp.single > 115 && tama_temp.single <5)
	{
		if(spi_round_number == 0)
			spi_round_number = 2;
		else
			spi_round_number -= 1;
	}
	else if(spi_temp.single <5 && tama_temp.single >115)
	{
		if(spi_round_number == 2)
			spi_round_number = 0;
		else
			spi_round_number += 1;
	}
	spi_temp.joint = (spi_round_number * 120) + spi_temp.single;
	if(spi_temp.joint >=180)
		spi_temp.joint = spi_temp.joint - 360;
	spi_temp.out = (int32_t)(spi_temp.joint * 485999 / 360);

	tama_temp.joint = (int16_t)tama_temp.cal * 360/65535;
	
	fpga_write(write_addr[MAXON],(uint16_t)spi_temp.out);
	delay_us(1);
	fpga_write((write_addr[MAXON]+1),(uint16_t)(spi_temp.out>>16));
	delay_us(1);
	
	
	maxon_temp.cal = fpga_read(read_addr[MAXON]);
	
	maxon_temp.joint = (int16_t)maxon_temp.cal * 360/65535;
	
	tamagawa = &tama_temp;
	
	spi->raw = spi_temp.raw;
	spi->cal = spi_temp.cal;
	spi->single = spi_temp.single;
	spi->joint = spi_temp.joint;
	spi->out = spi_temp.out;
		
	maxon = &maxon_temp;	
};


void parse_encoder(sensor_info* tamagawa, sensor_info* spi, sensor_info* maxon)
{
	uint16_t encoder_raw[ALL_ENCODER];
	sensor_info tama_temp,spi_temp,maxon_temp;
	uint8_t spi_round_number;
		
	tama_temp.raw = fpga_read(0x11);
	delay_us(1);
	spi_temp.raw = (fpga_read(read_addr[SPI])>>6)&0x03ff;
	delay_us(1);
	maxon_temp.raw = fpga_read(read_addr[MAXON]);
	delay_us(1);
	#ifdef GEAR_DEBUG
	maxon_temp.raw = (fpga_read((read_addr[MAXON]+1))<<16)|maxon_temp.raw;
	delay_us(1);
	#endif
	
	tama_temp.cal = fpga_read(read_addr[TAMA]);
		
	if(spi_temp.raw >= encoder_zero[SPI])
		spi_temp.cal = spi_temp.raw - encoder_zero[SPI];
	else
		spi_temp.cal = spi_temp.raw + 1024 - encoder_zero[SPI];
	
	spi_round_number = tama_temp.cal / (65535 /3);
	tama_temp.single = (float)(tama_temp.cal % (65535/3)) * 360 /65535;
	spi_temp.single = (float)spi_temp.cal * 120 /1024;

	if(spi_temp.single > 115 && tama_temp.single <5)
	{
		if(spi_round_number == 0)
			spi_round_number = 2;
		else
			spi_round_number -= 1;
	}
	else if(spi_temp.single <5 && tama_temp.single >115)
	{
		if(spi_round_number == 2)
			spi_round_number = 0;
		else
			spi_round_number += 1;
	}
	spi_temp.joint = (spi_round_number * 120) + spi_temp.single;
	if(spi_temp.joint >=180)
		spi_temp.joint = spi_temp.joint - 360;
	spi_temp.out = (int32_t)(spi_temp.joint * 485999 / 360);
	
	tama_temp.joint = (float)((int16_t)tama_temp.cal) * 360/65535;
	
//		if(spi_temp.joint == 0)
//	{
//		fpga_write(write_addr[MAXON],0);
//		delay_us(1);
//		fpga_write((write_addr[MAXON]+1),0);
//		delay_us(1);
//	}
	
	maxon_temp.cal = maxon_temp.raw;
	
	maxon_temp.joint = (float)((int16_t)maxon_temp.cal) * 360/65535;
	tamagawa->joint = tama_temp.joint;
	tamagawa->raw = tama_temp.raw;
	tamagawa->cal = tama_temp.cal;
	
	spi->raw = spi_temp.raw;
	spi->cal = spi_temp.cal;
	spi->joint = spi_temp.joint;
	
	maxon->raw = maxon_temp.raw;
	maxon->cal = maxon_temp.cal;
	maxon->joint = maxon_temp.joint;
	maxon->out = maxon_temp.out;
};
#else
void init_encoder(sensor_info* tama1, sensor_info* tama2, sensor_info* maxon)
{
	sensor_info tama1_temp,tama2_temp,maxon_temp;
	
	fpga_write(write_addr[TAMA1],encoder_zero[TAMA1]);
	delay_us(1);
	fpga_write(write_addr[TAMA2],encoder_zero[TAMA2]);
	delay_us(1);
	
	tama1_temp.raw = fpga_read(0x11);
	delay_us(1);
	tama2_temp.raw = fpga_read(0x31);
	delay_us(1);
	
	tama1_temp.cal = fpga_read(read_addr[TAMA1]);
	tama1_temp.joint = ((float)tama1_temp.cal) * 360 /65535;
	delay_us(1);
	tama2_temp.cal = fpga_read(read_addr[TAMA2]);
	tama2_temp.joint = ((float)tama2_temp.cal) * 360 /65535;
	delay_us(1);
	
	maxon_temp.cal = fpga_read(read_addr[MAXON]);
	maxon_temp.joint = ((float)maxon_temp.cal) * 360 /65535;
	
	tama1->raw = tama1_temp.raw;
	tama1->cal = tama1_temp.cal;
	tama1->joint = tama1_temp.joint;
	
	tama2->raw = tama2_temp.raw;
	tama2->cal = tama2_temp.cal;
	tama2->joint = tama2_temp.joint;
	
	maxon->cal = maxon_temp.cal;
	maxon->joint = maxon_temp.joint;
}
void parse_encoder(sensor_info* tama1, sensor_info* tama2, sensor_info* maxon)
{
	sensor_info tama1_temp,tama2_temp,maxon_temp;
		
	tama1_temp.raw = fpga_read((read_addr[TAMA1]-1));
	delay_us(1);
	tama2_temp.raw = fpga_read((read_addr[TAMA2]-1));
	delay_us(1);
	
	tama1_temp.cal = fpga_read(read_addr[TAMA1]);
	tama1_temp.joint = ((float)tama1_temp.cal) * 360 /65535;
	delay_us(1);
	tama2_temp.cal = fpga_read(read_addr[TAMA2]);
	tama2_temp.joint = ((float)tama2_temp.cal) * 360 /65535;
	delay_us(1);
	if(tama2_temp.joint == 0)
	{
		fpga_write(write_addr[MAXON],0);
		delay_us(1);
		fpga_write((write_addr[MAXON]+1),0);
		delay_us(1);
	}
	
	maxon_temp.cal = fpga_read(read_addr[MAXON]);
	maxon_temp.joint = ((float)maxon_temp.cal) * 360 /65535;
	
	tama1->raw = tama1_temp.raw;
	tama1->cal = tama1_temp.cal;
	tama1->joint = tama1_temp.joint;
	
	tama2->raw = tama2_temp.raw;
	tama2->cal = tama2_temp.cal;
	tama2->joint = tama2_temp.joint;
	
	maxon->cal = maxon_temp.cal;
	maxon->joint = maxon_temp.joint;
}
#endif