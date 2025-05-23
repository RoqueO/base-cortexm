cmake_minimum_required(VERSION 3.20)

# Project information
project(embedded_project 
        VERSION 0.1.0
        DESCRIPTION "Embedded Project Template"
        LANGUAGES C CXX ASM)

# Set default MCU (can be overridden from command line)
set(MCU_FAMILY "stm32f4xx" CACHE STRING "MCU family")
set(MCU_MODEL "stm32f469" CACHE STRING "MCU model")

# Configure build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type" FORCE)
endif()
set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")

# Options
option(ENABLE_CODE_FORMATTING "Enable code formatting with clang-format" OFF)
option(ENABLE_STATIC_ANALYSIS "Enable static analysis with clang-tidy" OFF)
option(ENABLE_TESTS "Enable unit testing" OFF)

# Include CMake modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/mcu")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/tools")
# Already in your CMakeLists.txt
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/lib/cmake")

# Include MCU configuration
include("families/${MCU_MODEL}")

# Include optional tools
if(ENABLE_CODE_FORMATTING)
    include(code-format)
endif()

if(ENABLE_STATIC_ANALYSIS)
    include(static-analysis)
endif()

# Add include directories
include_directories(
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/mcu
)

# Add libraries
include(cmsis6)
include(STM32CubeF4)

# Add source files
file(GLOB_RECURSE SOURCE_FILES
    "src/*.c"
    "src/*.cpp"
    "src/*.s"
    "src/*.S"
)

# Startup file - todo make it dependent on the processor
SET(MCU_STARTUP 
    "mcu/startup_stm32f469xx.s"
    "mcu/system_stm32f4xx.c")

# Define target
add_executable(${PROJECT_NAME}.elf 
    ${SOURCE_FILES}
    ${MCU_STARTUP}
)

# Link with your target
target_link_libraries(${PROJECT_NAME}.elf PRIVATE 
    cmsis6
    CMSIS_STM32F4xx
    STM32F4xx_HAL
)

# Link with linker script
target_link_options(${PROJECT_NAME}.elf PRIVATE
    -T${CMAKE_SOURCE_DIR}/linker/${MCU_MODEL}.ld
)

# Debug
set_target_properties(${PROJECT_NAME}.elf PROPERTIES LINK_FLAGS "-v")

# Post-build commands (generate .bin and .hex files)
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary ${PROJECT_NAME}.elf ${PROJECT_NAME}.bin
    COMMAND ${CMAKE_OBJCOPY} -O ihex ${PROJECT_NAME}.elf ${PROJECT_NAME}.hex
    COMMAND ${CMAKE_SIZE} --format=berkeley ${PROJECT_NAME}.elf
    COMMENT "Generating binary and hex files"
)


# add_custom_target(build-all
#     COMMAND ${CMAKE_COMMAND} --build ${CMAKE_SOURCE_DIR}/build-gcc --parallel 16
#     COMMAND ${CMAKE_COMMAND} --build ${CMAKE_SOURCE_DIR}/build-clang --parallel 16
#     COMMENT "Building with both GCC and Clang toolchains"
# )

add_custom_target(build-all
    # Configure and build GCC
    COMMAND ${CMAKE_COMMAND} -S ${CMAKE_SOURCE_DIR} -B ${CMAKE_SOURCE_DIR}/build-gcc -DCMAKE_TOOLCHAIN_FILE=${CMAKE_SOURCE_DIR}/cmake/toolchains/arm-gcc.cmake -DCMAKE_BUILD_TYPE=Debug
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_SOURCE_DIR}/build-gcc --parallel 16
    
    # Configure and build Clang
    COMMAND ${CMAKE_COMMAND} -S ${CMAKE_SOURCE_DIR} -B ${CMAKE_SOURCE_DIR}/build-clang -DCMAKE_TOOLCHAIN_FILE=${CMAKE_SOURCE_DIR}/cmake/toolchains/arm-clang.cmake -DCMAKE_BUILD_TYPE=Debug
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_SOURCE_DIR}/build-clang --parallel 16
    
    COMMENT "Building with both GCC and Clang toolchains"
)