# STM32CubeF4 CMake File
# Defines interface libraries for STM32F4xx HAL and CMSIS

# Check if target is already defined
if(TARGET STM32F4xx_HAL)
    return()
endif()

# Define paths
set(STM32CUBE_F4_PATH ${CMAKE_CURRENT_LIST_DIR}/../STM32CubeF4)
set(STM32F4XX_HAL_PATH ${STM32CUBE_F4_PATH}/Drivers/STM32F4xx_HAL_Driver)
set(CMSIS_PATH ${STM32CUBE_F4_PATH}/Drivers/CMSIS)
set(CMSIS_DEVICE_PATH ${CMSIS_PATH}/Device/ST/STM32F4xx)

# Check if STM32CubeF4 files exist
if(NOT EXISTS ${STM32F4XX_HAL_PATH})
    message(WARNING "STM32CubeF4 HAL drivers not found at ${STM32F4XX_HAL_PATH}")
    set(STM32CUBEF4_FOUND FALSE PARENT_SCOPE)
    return()
endif()

if(NOT EXISTS ${CMSIS_DEVICE_PATH})
    message(WARNING "STM32F4xx CMSIS device files not found at ${CMSIS_DEVICE_PATH}")
    set(STM32CUBEF4_FOUND FALSE PARENT_SCOPE)
    return()
endif()

# Set variables for find_package functionality
set(STM32CUBEF4_FOUND TRUE)

# CMSIS STM32F4xx Library
add_library(CMSIS_STM32F4xx INTERFACE)
target_include_directories(CMSIS_STM32F4xx INTERFACE
    ${CMSIS_DEVICE_PATH}/Include
    ${CMSIS_PATH}/Include
)

# Set include directories for find_package functionality
set(CMSIS_STM32F4XX_INCLUDE_DIRS 
    ${CMSIS_DEVICE_PATH}/Include
    # ${CMSIS_PATH}/Include
)

# STM32F4xx HAL Library
add_library(STM32F4xx_HAL STATIC)
target_include_directories(STM32F4xx_HAL PUBLIC
    ${STM32F4XX_HAL_PATH}/Inc
)

# Set include directories for find_package functionality
set(STM32F4XX_HAL_INCLUDE_DIRS 
    ${STM32F4XX_HAL_PATH}/Inc
)

# Find all source files for the HAL library
file(GLOB_RECURSE STM32F4XX_HAL_SOURCES
    ${STM32F4XX_HAL_PATH}/Src/*.c
)

# Add sources to the HAL library
target_sources(STM32F4xx_HAL PRIVATE
    ${STM32F4XX_HAL_SOURCES}
)

target_link_libraries(STM32F4xx_HAL 
    PRIVATE
        CMSIS_STM32F4xx
)

# supress warnings
target_compile_options(STM32F4xx_HAL 
    PRIVATE 
        -w
)

# Make the libraries available in the parent scope
set(STM32F4xx_HAL_LIBRARY STM32F4xx_HAL CACHE INTERNAL "STM32F4xx HAL Library")
set(CMSIS_STM32F4xx_LIBRARY CMSIS_STM32F4xx CACHE INTERNAL "CMSIS STM32F4xx Library")

message(STATUS "STM32F4xx HAL and CMSIS libraries configured")

