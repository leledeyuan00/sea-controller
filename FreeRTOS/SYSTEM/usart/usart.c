#include "usart.h"
#include "delay.h"
////////////////////////////////////////////////////////////////////////////////// 	 
#if SYSTEM_SUPPORT_OS
#include "FreeRTOS.h" 
#endif
#include "../fmc/fmc.h"
//#define PUTCHAR_PROTOTYPE int fputc(int ch, FILE *f)	
#if 1
#pragma import(__use_no_semihosting)                            
struct __FILE 
{ 
	int handle; 
}; 

FILE __stdout;       
void _sys_exit(int x) 
{ 
	x = x; 
} 
int fputc(int ch, FILE *f)
{ 	
	while((USART1->SR&0X40)==0);
	USART1->DR = (u8) ch;      
	return ch;
}
#endif 

#if EN_USART1_RX  
u8 begins;	
float ep=600;
float ei=2;
float ed=10;

u8 controlbegin=0;
u8 USART_RX_BUF[USART_REC_LEN];    

u16 USART_RX_STA=0;      

u8 aRxBuffer[RXBUFFERSIZE];
UART_HandleTypeDef UART1_Handler; 
UART_HandleTypeDef UART2_Handler;
UART_HandleTypeDef UART3_Handler;

void uart_init(u32 bound)
{	
	  UART1_Handler.Instance=USART1;
	  UART1_Handler.Init.BaudRate=bound;
	  UART1_Handler.Init.WordLength=UART_WORDLENGTH_8B;
	  UART1_Handler.Init.StopBits=UART_STOPBITS_1;
  	UART1_Handler.Init.Parity=UART_PARITY_NONE;
	  UART1_Handler.Init.HwFlowCtl=UART_HWCONTROL_NONE;
	  UART1_Handler.Init.Mode=UART_MODE_TX_RX;
	  HAL_UART_Init(&UART1_Handler);
	
	  HAL_UART_Receive_IT(&UART1_Handler, (u8 *)aRxBuffer, RXBUFFERSIZE);
  
}
void Uart2_Init(u32 bound)
{	
	  UART2_Handler.Instance=USART2;
	  UART2_Handler.Init.BaudRate=bound;
	  UART2_Handler.Init.WordLength=UART_WORDLENGTH_8B;
	  UART2_Handler.Init.StopBits=UART_STOPBITS_1;
  	UART2_Handler.Init.Parity=UART_PARITY_NONE;
	  UART2_Handler.Init.HwFlowCtl=UART_HWCONTROL_NONE;
	  UART2_Handler.Init.Mode=UART_MODE_TX_RX;
	  HAL_UART_Init(&UART2_Handler);
	
	  HAL_UART_Receive_IT(&UART2_Handler, (u8 *)aRxBuffer, RXBUFFERSIZE);
  
}
void Uart3_Init(u32 bound)
{	
	  UART3_Handler.Instance=USART3;					   
	  UART3_Handler.Init.BaudRate=bound;				  
	  UART3_Handler.Init.WordLength=UART_WORDLENGTH_8B;
	  UART3_Handler.Init.StopBits=UART_STOPBITS_1;
	  UART3_Handler.Init.Parity=UART_PARITY_NONE;	
	  UART3_Handler.Init.HwFlowCtl=UART_HWCONTROL_NONE; 
  	UART3_Handler.Init.Mode=UART_MODE_TX_RX;
	  HAL_UART_Init(&UART3_Handler);
	
	  HAL_UART_Receive_IT(&UART3_Handler, (u8 *)aRxBuffer, RXBUFFERSIZE); 
}

void HAL_UART_MspInit(UART_HandleTypeDef *huart)
{
  
	  GPIO_InitTypeDef GPIO_Initure;
	  if(huart->Instance==USART1)
	  {
	    	__HAL_RCC_GPIOA_CLK_ENABLE();	
		    __HAL_RCC_USART1_CLK_ENABLE();
	
		    GPIO_Initure.Pin=GPIO_PIN_9;	
		    GPIO_Initure.Mode=GPIO_MODE_AF_PP;
		    GPIO_Initure.Pull=GPIO_PULLUP;		
		    GPIO_Initure.Speed=GPIO_SPEED_FAST;	
		    GPIO_Initure.Alternate=GPIO_AF7_USART1;
		    HAL_GPIO_Init(GPIOA,&GPIO_Initure);

		    GPIO_Initure.Pin=GPIO_PIN_10;
		    HAL_GPIO_Init(GPIOA,&GPIO_Initure);
		
        #if EN_USART1_RX
		       HAL_NVIC_EnableIRQ(USART1_IRQn);				
		       HAL_NVIC_SetPriority(USART1_IRQn,3,3);
        #endif	
	  }
		else if(huart->Instance==USART2)
	  {
	    	__HAL_RCC_GPIOA_CLK_ENABLE();	
		    __HAL_RCC_USART2_CLK_ENABLE();
	
		    GPIO_Initure.Pin=GPIO_PIN_2;	
		    GPIO_Initure.Mode=GPIO_MODE_AF_PP;
		    GPIO_Initure.Pull=GPIO_PULLUP;		
		    GPIO_Initure.Speed=GPIO_SPEED_FAST;	
		    GPIO_Initure.Alternate=GPIO_AF7_USART2;
		    HAL_GPIO_Init(GPIOA,&GPIO_Initure);

		    GPIO_Initure.Pin=GPIO_PIN_3;
		    HAL_GPIO_Init(GPIOA,&GPIO_Initure);
		
     		HAL_NVIC_EnableIRQ(USART2_IRQn);				
		    HAL_NVIC_SetPriority(USART2_IRQn,3,3);
     
	  }
		else if(huart->Instance==USART3)
	  {
	    	__HAL_RCC_GPIOB_CLK_ENABLE();	
		    __HAL_RCC_USART3_CLK_ENABLE();
	
		    GPIO_Initure.Pin=GPIO_PIN_10;	
		    GPIO_Initure.Mode=GPIO_MODE_AF_PP;
		    GPIO_Initure.Pull=GPIO_PULLUP;		
		    GPIO_Initure.Speed=GPIO_SPEED_FAST;	
		    GPIO_Initure.Alternate=GPIO_AF7_USART3;
		    HAL_GPIO_Init(GPIOB,&GPIO_Initure);

		    GPIO_Initure.Pin=GPIO_PIN_11;
		    HAL_GPIO_Init(GPIOB,&GPIO_Initure);
		
     		HAL_NVIC_EnableIRQ(USART3_IRQn);				
		    HAL_NVIC_SetPriority(USART3_IRQn,3,3);
     
	  }
}

void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart)
{
	  if(huart->Instance==USART1)
	  {
		   if((USART_RX_STA&0x8000)==0)
		   {
			     if(USART_RX_STA&0x4000)
			     {
				       if(aRxBuffer[0]!=0x0a)USART_RX_STA=0;
				       else USART_RX_STA|=0x8000;	
			     }
			     else 
			     {	
				       if(aRxBuffer[0]==0x0d)USART_RX_STA|=0x4000;
				       else
				       {
					         USART_RX_BUF[USART_RX_STA&0X3FFF]=aRxBuffer[0] ;
					         USART_RX_STA++;
					         if(USART_RX_STA>(USART_REC_LEN-1))USART_RX_STA=0; 
				       }		 
			     }
		   }
	  }
		
		HAL_UART_Receive_IT(&UART2_Handler,(u8 *)aRxBuffer, RXBUFFERSIZE);
	if(huart->Instance==USART2)
	{
		
		 if(aRxBuffer[0] == 0xAA)
		 {
			   		 
		 }
		 else if(aRxBuffer[0] == 0xAB)
		 {
			   
		 }
	}
	
}
 
//usart 1 function
void USART1_IRQHandler(void)                	
{ 
	u32 timeout=0;
	u32 maxDelay=0x1FFFF;

	HAL_UART_IRQHandler(&UART1_Handler);
	
	timeout=0;
  while (HAL_UART_GetState(&UART1_Handler) != HAL_UART_STATE_READY)
	{
	    timeout++;////timeout handle
      if(timeout>maxDelay) break;			
	}
     
	timeout=0;
	while(HAL_UART_Receive_IT(&UART1_Handler, (u8 *)aRxBuffer, RXBUFFERSIZE) != HAL_OK)
	{
	    timeout++; 
	    if(timeout>maxDelay) break;	
	}
} 
#endif	
void USART3_IRQHandler(void)                	
{ 
	u32 timeout=0;
	u32 maxDelay=0x1FFFF;

	HAL_UART_IRQHandler(&UART3_Handler);	
	
} 
void USART2_IRQHandler(void)                	
{ 
	u32 timeout=0;
	u32 maxDelay=0x1FFFF;

	HAL_UART_IRQHandler(&UART2_Handler);	
	
} 




