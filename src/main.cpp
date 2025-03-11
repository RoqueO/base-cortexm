/**
 * @file main.c
 * @brief Main application entry point
 */

 #include "stm32f4xx_hal.h"
 #include "stm32f469xx.h"

 /**
  * @brief System Clock Configuration
  */
 void SystemClock_Config(void)
 {
     // Configure system clock for STM32F469
     RCC_OscInitTypeDef RCC_OscInitStruct;
     RCC_ClkInitTypeDef RCC_ClkInitStruct;
 
     // Configure the main internal regulator output voltage
     __HAL_RCC_PWR_CLK_ENABLE();
     __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);
 
     // Initialize HSE Oscillator and PLL
     RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
     RCC_OscInitStruct.HSEState = RCC_HSE_ON;
     RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
     RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
     RCC_OscInitStruct.PLL.PLLM = 8;
     RCC_OscInitStruct.PLL.PLLN = 360;
     RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
     RCC_OscInitStruct.PLL.PLLQ = 7;
     RCC_OscInitStruct.PLL.PLLR = 6;
     HAL_RCC_OscConfig(&RCC_OscInitStruct);
 
     // Activate the OverDrive to reach the 180 MHz Frequency
     HAL_PWREx_EnableOverDrive();
 
     // Select PLL as system clock source and configure the HCLK, PCLK1 and PCLK2 clocks dividers
     RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2;
     RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
     RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
     RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;
     RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;
     HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_5);
 }
 
 /**
  * @brief Initialize GPIO
  */
 static void GPIO_Init(void)
 {
     // Example: Initialize LED GPIO (adjust for your specific board)
     GPIO_InitTypeDef GPIO_InitStruct;
     
     // Enable GPIO clock
     __HAL_RCC_GPIOG_CLK_ENABLE();
     
     // Configure GPIO pin
     GPIO_InitStruct.Pin = GPIO_PIN_6;
     GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
     GPIO_InitStruct.Pull = GPIO_NOPULL;
     GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
     HAL_GPIO_Init(GPIOG, &GPIO_InitStruct);
 }
 
 /**
  * @brief Main function
  */
 int main(void)
 {
     // Reset of all peripherals, initialize the Flash interface and the Systick
     HAL_Init();
     
     // Configure the system clock
     SystemClock_Config();
     
     // Initialize GPIO
     GPIO_Init();
     
     // Main loop
     while (1)
     {
         // Toggle LED
         HAL_GPIO_TogglePin(GPIOG, GPIO_PIN_6);
         
         // Delay
         HAL_Delay(500);
     }
 }
 
 /**
  * @brief This function handles System tick timer.
  */
 void SysTick_Handler(void)
 {
     HAL_IncTick();
 }