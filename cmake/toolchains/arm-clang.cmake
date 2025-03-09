# ARM Clang/LLVM Toolchain Configuration

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Define toolchain programs
# Note: LLVM/Clang uses a different prefix structure than GCC

# Find the compiler binaries
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    # Windows paths
    set(CLANG_PATH "C:/Program Files/LLVM" CACHE PATH "LLVM/Clang installation path")
    set(ARM_TOOLCHAIN_PATH "C:/Program Files (x86)/GNU Arm Embedded Toolchain" CACHE PATH "ARM toolchain for binutils")
else()
    # Linux paths
    set(CLANG_PATH "/usr/lib/llvm" CACHE PATH "LLVM/Clang installation path")
    set(ARM_TOOLCHAIN_PATH "/home/roqueo/buildtools/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi" CACHE PATH "ARM toolchain for binutils")
endif()

# Try to find Clang in specified paths first, then in PATH
find_program(CMAKE_C_COMPILER clang PATHS ${CLANG_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_CXX_COMPILER clang++ PATHS ${CLANG_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_ASM_COMPILER clang PATHS ${CLANG_PATH}/bin NO_DEFAULT_PATH)

# ARM binutils are still needed (from ARM GCC toolchain)
set(TOOLCHAIN_PREFIX "arm-none-eabi-")
find_program(CMAKE_AR ${TOOLCHAIN_PREFIX}ar PATHS ${ARM_TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_RANLIB ${TOOLCHAIN_PREFIX}ranlib PATHS ${ARM_TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}objcopy PATHS ${ARM_TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_OBJDUMP ${TOOLCHAIN_PREFIX}objdump PATHS ${ARM_TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_SIZE ${TOOLCHAIN_PREFIX}size PATHS ${ARM_TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)

# If not found in specified paths, try finding in PATH
if(NOT CMAKE_C_COMPILER)
    find_program(CMAKE_C_COMPILER clang)
    find_program(CMAKE_CXX_COMPILER clang++)
    find_program(CMAKE_ASM_COMPILER clang)
endif()

if(NOT CMAKE_AR)
    find_program(CMAKE_AR ${TOOLCHAIN_PREFIX}ar)
    find_program(CMAKE_RANLIB ${TOOLCHAIN_PREFIX}ranlib)
    find_program(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}objcopy)
    find_program(CMAKE_OBJDUMP ${TOOLCHAIN_PREFIX}objdump)
    find_program(CMAKE_SIZE ${TOOLCHAIN_PREFIX}size)
endif()

# Set target triple for ARM Cortex-M4
set(TARGET_TRIPLE "thumbv7em-none-eabi")

# Set Clang compiler flags
# Core flags - Cortex-M4 with FPU
set(COMMON_FLAGS "--target=${TARGET_TRIPLE} -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16")
set(CMAKE_C_FLAGS "${COMMON_FLAGS} -std=gnu11 -Wall -Wextra -Werror" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS "${COMMON_FLAGS} -std=c++17 -fno-exceptions -fno-rtti -Wall -Wextra -Werror" CACHE INTERNAL "")
set(CMAKE_ASM_FLAGS "${COMMON_FLAGS}" CACHE INTERNAL "")

# Build-type specific flags
set(CMAKE_C_FLAGS_DEBUG "-O0 -g3 -DDEBUG" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g3 -DDEBUG" CACHE INTERNAL "")
set(CMAKE_C_FLAGS_RELEASE "-Os -DNDEBUG" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_RELEASE "-Os -DNDEBUG" CACHE INTERNAL "")

# Set linker flags - Clang needs specific options for the linker
# Use lld as the default linker or fall back to using arm-none-eabi-ld through GCC
# Note: -fuse-ld=lld is necessary when we want to use LLVM's lld linker
set(CMAKE_EXE_LINKER_FLAGS "${COMMON_FLAGS} -fuse-ld=lld -Wl,--gc-sections" CACHE INTERNAL "")

# Add ARM architecture specific library paths for the linker
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --sysroot=${ARM_TOOLCHAIN_PATH}/arm-none-eabi" CACHE INTERNAL "")

# Equivalent to --specs=nano.specs --specs=nosys.specs in GCC
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -lnosys -lc -lm" CACHE INTERNAL "")

# Add the correct library paths
set(ARM_TOOLCHAIN_LIBS "${ARM_TOOLCHAIN_PATH}/arm-none-eabi/lib")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -L${ARM_TOOLCHAIN_LIBS}/thumb/v7e-m+fp/hard" CACHE INTERNAL "")

set(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE INTERNAL "")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "" CACHE INTERNAL "")

# These settings are specific to CMake and should be set
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

