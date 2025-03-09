# CMSIS6 CMake Module
# This module defines the CMSIS6 header-only library target

# Check if the library is already defined
if(TARGET cmsis6)
    return()
endif()

# Ensure the submodule is checked out
if(NOT EXISTS "${CMAKE_SOURCE_DIR}/lib/CMSIS_6/README.md")
    message(WARNING "CMSIS_6 submodule not found. Please run 'git submodule update --init --recursive'")
endif()

# Define the interface library target
add_library(cmsis6 INTERFACE)

# Set include directories
target_include_directories(cmsis6 INTERFACE
    ${CMAKE_SOURCE_DIR}/lib/CMSIS_6/CMSIS/Core/Include
    ${CMAKE_SOURCE_DIR}/lib/CMSIS_6/CMSIS/DSP/Include
    ${CMAKE_SOURCE_DIR}/lib/CMSIS_6/CMSIS/NN/Include
    ${CMAKE_SOURCE_DIR}/lib/CMSIS_6/CMSIS/RTOS2/Include
    ${CMAKE_SOURCE_DIR}/lib/CMSIS_6/Device/ARM/ARMCM
)

# Add compile definitions if needed (can be uncommented and modified as required)
# target_compile_definitions(cmsis6 INTERFACE
#     ARM_MATH_CM4
#     __FPU_PRESENT=1
# )

# Make this accessible to parent scope for find_package functionality
set(CMSIS6_FOUND TRUE)
set(CMSIS6_INCLUDE_DIRS 
    ${CMAKE_SOURCE_DIR}/lib/CMSIS_6/CMSIS/Core/Include
    ${CMAKE_SOURCE_DIR}/lib/CMSIS_6/CMSIS/DSP/Include
    ${CMAKE_SOURCE_DIR}/lib/CMSIS_6/CMSIS/NN/Include
    ${CMAKE_SOURCE_DIR}/lib/CMSIS_6/CMSIS/RTOS2/Include
    ${CMAKE_SOURCE_DIR}/lib/CMSIS_6/Device/ARM/ARMCM
)

# Output status message
message(STATUS "CMSIS6 module configured")

