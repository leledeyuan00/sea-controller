#include "sys.h"
#include "delay.h"
#include "usart.h"
#include "led.h"
#include "sdram.h"
#include "key.h"
#include "FreeRTOS.h"
#include "task.h"
#include "../fmc/fmc.h"
#include "DataScope_DP.h"
#include "string.h"
#include "math.h"
#include "../CONTROL/control.h"
#include "../CONTROL/encoder.h"
#include "../SYSTEM/task_sys.h"
#define pi (3.1415926)

				
int main(void)
{
  HAL_Init();                    
  Stm32_Clock_Init(360,16,2,8);   
//mcu_system_clk_config();	
	fsmc.initialize();
	delay_init(180);                          
	Uart2_Init(115200); 
  Uart3_Init(115200);  	
  LED_Init();                     
	initial_task();
}


void task1_task(void *pvParameters)
{
	u16 task1_num=0;
	while(1)
	{
		task1_num++;
	
		LED0=!LED0;
		delay_ms(50);
		LED0=!LED0;
		delay_ms(50);
		LED0=!LED0;
		delay_ms(50);
		LED0=!LED0;
		vTaskDelay(1000);
	}
}