# ARM Clang/LLVM Toolchain Configuration using GCC path detection

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Define toolchain programs
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(CLANG_PATH "C:/Program Files/LLVM" CACHE PATH "LLVM/Clang installation path")
    set(ARM_TOOLCHAIN_PATH "C:/Program Files (x86)/GNU Arm Embedded Toolchain" CACHE PATH "ARM toolchain for binutils")
else()
    set(CLANG_PATH "/usr/lib/llvm" CACHE PATH "LLVM/Clang installation path")
    set(ARM_TOOLCHAIN_PATH "/home/roqueo/buildtools/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi" CACHE PATH "ARM toolchain for binutils")
endif()

# Find compiler binaries
find_program(CMAKE_C_COMPILER clang PATHS ${CLANG_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_CXX_COMPILER clang++ PATHS ${CLANG_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_ASM_COMPILER clang PATHS ${CLANG_PATH}/bin NO_DEFAULT_PATH)

# Find ARM binutils
set(TOOLCHAIN_PREFIX "arm-none-eabi-")
find_program(CMAKE_AR ${TOOLCHAIN_PREFIX}ar PATHS ${ARM_TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_RANLIB ${TOOLCHAIN_PREFIX}ranlib PATHS ${ARM_TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}objcopy PATHS ${ARM_TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_OBJDUMP ${TOOLCHAIN_PREFIX}objdump PATHS ${ARM_TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)
find_program(CMAKE_SIZE ${TOOLCHAIN_PREFIX}size PATHS ${ARM_TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)

# Try PATH if not found
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

# Find ARM GCC for path detection
find_program(ARM_GCC ${TOOLCHAIN_PREFIX}gcc PATHS ${ARM_TOOLCHAIN_PATH}/bin NO_DEFAULT_PATH)
if(NOT ARM_GCC)
    find_program(ARM_GCC ${TOOLCHAIN_PREFIX}gcc)
endif()

# Target triple for ARM Cortex-M4
set(TARGET_TRIPLE "arm-none-eabi")

# Architecture flags - similar to the makefile
set(ARCH_FLAGS "-mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16")
set(ARCH_FLAGS_LIST ${ARCH_FLAGS})
separate_arguments(ARCH_FLAGS_LIST)

# Use GCC to detect paths - similar to the makefile approach
if(ARM_GCC)
    # Get sysroot from GCC
    set(ARM_GCC_FLAG "-print-sysroot")
    execute_process(
        COMMAND ${ARM_GCC} ${ARCH_FLAGS_LIST} ${ARM_GCC_FLAG}
        OUTPUT_VARIABLE ARM_SYSROOT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    
    # Get multi-directory from GCC
    set(ARM_GCC_FLAG "-print-multi-directory")
    execute_process(
        COMMAND ${ARM_GCC} ${ARCH_FLAGS_LIST} ${ARM_GCC_FLAG}
        OUTPUT_VARIABLE ARM_MULTI_DIR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    
    # Get libgcc path from GCC
    set(ARM_GCC_FLAG "-print-libgcc-file-name")
    execute_process(
        COMMAND ${ARM_GCC} ${ARCH_FLAGS_LIST} ${ARM_GCC_FLAG}
        OUTPUT_VARIABLE ARM_LIBGCC
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    
    get_filename_component(ARM_LIBGCC_DIR ${ARM_LIBGCC} DIRECTORY)
    
    message(STATUS "ARM sysroot: ${ARM_SYSROOT}")
    message(STATUS "ARM multi-dir: ${ARM_MULTI_DIR}")
    message(STATUS "ARM libgcc: ${ARM_LIBGCC}")
else()
    message(FATAL "ARM GCC not found.")
endif()

# Compile a library
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Set Clang compiler flags
set(COMMON_FLAGS "--target=${TARGET_TRIPLE} ${ARCH_FLAGS}")
set(CMAKE_C_FLAGS "${COMMON_FLAGS} -std=gnu11 -Wall -Wextra" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS "${COMMON_FLAGS} -std=c++17 -fno-exceptions -fno-rtti -fno-unwind-tables -fno-use-cxa-atexit -Wall -Wextra" CACHE INTERNAL "")
set(CMAKE_ASM_FLAGS "${COMMON_FLAGS}" CACHE INTERNAL "")

# Build-type specific flags
set(CMAKE_C_FLAGS_DEBUG "-O0 -g3 -DDEBUG" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g3 -DDEBUG" CACHE INTERNAL "")
set(CMAKE_C_FLAGS_RELEASE "-Oz -DNDEBUG" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_RELEASE "-Oz -DNDEBUG" CACHE INTERNAL "")

# Set linker flags with the detected paths
set(CMAKE_EXE_LINKER_FLAGS "${COMMON_FLAGS} -fuse-ld=lld -Wl,--gc-sections")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --sysroot=${ARM_SYSROOT}")

if(ARM_MULTI_DIR)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -L${ARM_SYSROOT}/lib/${ARM_MULTI_DIR}")
endif()

if(ARM_LIBGCC_DIR)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -L${ARM_LIBGCC_DIR}")
endif()

if(ARM_LIBGCC)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -L${ARM_LIBGCC}")
endif()

# Standard libraries
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -lnosys --specs=nano.specs -lc_nano -lm -lgcc" CACHE INTERNAL "")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -nostdlib" CACHE INTERNAL "")

# Add this right before the CMAKE_EXE_LINKER_FLAGS line
# set(CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
# Replace your current CMAKE_EXE_LINKER_FLAGS setting with this
# set(CMAKE_EXE_LINKER_FLAGS "${COMMON_FLAGS} -fuse-ld=lld -Wl,--gc-sections -nostdlib --sysroot=${ARM_SYSROOT}" CACHE INTERNAL "")

set(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE INTERNAL "")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "" CACHE INTERNAL "")

# CMake specific settings
set(CMAKE_SYSROOT ${ARM_SYSROOT})
set(CMAKE_FIND_ROOT_PATH ${ARM_SYSROOT})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)