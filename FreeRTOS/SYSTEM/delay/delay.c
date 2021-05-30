#include "delay.h"
#include "sys.h"

#if SYSTEM_SUPPORT_OS
#include "FreeRTOS.h"					
#include "task.h"
#endif


static u32 fac_us=0;							

#if SYSTEM_SUPPORT_OS		
    static u16 fac_ms=0;				        
#endif

 
extern void xPortSysTickHandler(void);

void SysTick_Handler(void)
{  
    if(xTaskGetSchedulerState()!=taskSCHEDULER_NOT_STARTED)
    {
        xPortSysTickHandler();	
    }
    HAL_IncTick();
}
			   

void delay_init(u8 SYSCLK)
{
	  u32 reload;
    HAL_SYSTICK_CLKSourceConfig(SYSTICK_CLKSOURCE_HCLK);
	  fac_us=SYSCLK;						    
	  reload=SYSCLK;					        
	  reload*=1000000/configTICK_RATE_HZ;
	  fac_ms=1000/configTICK_RATE_HZ;
    SysTick->CTRL|=SysTick_CTRL_TICKINT_Msk;
	  SysTick->LOAD=reload;	
	  SysTick->CTRL|=SysTick_CTRL_ENABLE_Msk;
}								    

//delay nus
//nus:0~190887435(max 2^32/fac_us@fac_us=22.5)	    								   
void delay_us(u32 nus)
{		
	u32 ticks;
	u32 told,tnow,tcnt=0;
	u32 reload=SysTick->LOAD;				    	 
	ticks=nus*fac_us; 						
	told=SysTick->VAL;        			
	while(1)
	{
		tnow=SysTick->VAL;	
		if(tnow!=told)
		{	    
			if(tnow<told)tcnt+=told-tnow;	
			else tcnt+=reload-tnow+told;	    
			told=tnow;
			if(tcnt>=ticks)break;			
		}  
	};									    
}  
	
//nms:delay nms
//nms:0~65535
void delay_ms(u32 nms)
{	
	if(xTaskGetSchedulerState()!=taskSCHEDULER_NOT_STARTED)
	{		
		if(nms>=fac_ms)					 
		{ 
   			vTaskDelay(nms/fac_ms);	 		
		}
		nms%=fac_ms;						   
	}
	delay_us((u32)(nms*1000));				
}

//without task swtich
//nms:delay nms
void delay_xms(u32 nms)
{
	  u32 i;
	  for(i=0;i<nms;i++) delay_us(1000);
}
