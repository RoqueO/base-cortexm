# STM32F469 Configuration

# Include common STM32F4xx settings
include(${CMAKE_SOURCE_DIR}/cmake/mcu/stm32f4xx.cmake)

# STM32F469 specific definitions
add_definitions(
    -DSTM32F469xx
)

# Memory layout settings can be added here if needed