# STM32F4xx Family Configuration

# Common definitions for STM32F4xx family
add_definitions(
    -DSTM32F4
    -DUSE_HAL_DRIVER
)

# Include paths for STM32F4xx family
include_directories(
    ${CMAKE_SOURCE_DIR}/lib/cmsis/core/Include
    ${CMAKE_SOURCE_DIR}/lib/cmsis/device/Device/ST/STM32F4xx/Include
    ${CMAKE_SOURCE_DIR}/lib/hal/stm32f4xx/Inc
    ${CMAKE_SOURCE_DIR}/lib/freertos/FreeRTOS/Source/include
    ${CMAKE_SOURCE_DIR}/lib/freertos/FreeRTOS/Source/portable/GCC/ARM_CM4F
    ${CMAKE_SOURCE_DIR}/lib/bsp/discovery/Inc
)

# Common compile options for STM32F4xx
add_compile_options(
    -ffunction-sections
    -fdata-sections
    -fno-common
    -fsigned-char
)

# Common link options for STM32F4xx
add_link_options(
    -Wl,--gc-sections
    -nostartfiles
)