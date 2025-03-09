# ARM GCC Toolchain Configuration

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Define toolchain programs
set(TOOLCHAIN_PREFIX "arm-none-eabi-")

# Find the compiler binaries
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    # Windows paths
    set(TOOLCHAIN_PATH "C:/Program Files (x86)/GNU Arm Embedded Toolchain" CACHE PATH "Toolchain path")
else()
    # Linux paths
    set(TOOLCHAIN_PATH "/usr/local" CACHE PATH "Toolchain path")
endif()

# Try to find toolchain in PATH first, then in TOOLCHAIN_PATH
find_program(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}gcc PATHS ${TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}g++ PATHS ${TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}gcc PATHS ${TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_AR ${TOOLCHAIN_PREFIX}ar PATHS ${TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_RANLIB ${TOOLCHAIN_PREFIX}ranlib PATHS ${TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}objcopy PATHS ${TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_OBJDUMP ${TOOLCHAIN_PREFIX}objdump PATHS ${TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_SIZE ${TOOLCHAIN_PREFIX}size PATHS ${TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)

# If not found in TOOLCHAIN_PATH, try finding in PATH
if(NOT CMAKE_C_COMPILER)
    find_program(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}gcc)
    find_program(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}g++)
    find_program(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}gcc)
    find_program(CMAKE_AR ${TOOLCHAIN_PREFIX}ar)
    find_program(CMAKE_RANLIB ${TOOLCHAIN_PREFIX}ranlib)
    find_program(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}objcopy)
    find_program(CMAKE_OBJDUMP ${TOOLCHAIN_PREFIX}objdump)
    find_program(CMAKE_SIZE ${TOOLCHAIN_PREFIX}size)
endif()

# Set compiler flags
# Core flags
set(COMMON_FLAGS "-mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16")
set(CMAKE_C_FLAGS "${COMMON_FLAGS} -std=gnu11 -Wall -Wextra -Werror" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS "${COMMON_FLAGS} -std=c++17 -fno-exceptions -fno-rtti -Wall -Wextra -Werror" CACHE INTERNAL "")
set(CMAKE_ASM_FLAGS "${COMMON_FLAGS}" CACHE INTERNAL "")

# Build-type specific flags
set(CMAKE_C_FLAGS_DEBUG "-O0 -g3 -DDEBUG" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g3 -DDEBUG" CACHE INTERNAL "")
set(CMAKE_C_FLAGS_RELEASE "-Os -DNDEBUG" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_RELEASE "-Os -DNDEBUG" CACHE INTERNAL "")

# Set linker flags
set(CMAKE_EXE_LINKER_FLAGS "${COMMON_FLAGS} -Wl,--gc-sections --specs=nano.specs --specs=nosys.specs -static" CACHE INTERNAL "")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE INTERNAL "")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "" CACHE INTERNAL "")

# These settings are specific to CMake and should be set
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)