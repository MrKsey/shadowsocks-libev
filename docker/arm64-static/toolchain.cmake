# CMake toolchain file for cross-compiling to aarch64-linux-gnu
# Used by: cmake -DCMAKE_TOOLCHAIN_FILE=<this-file> ...

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# Use full paths via find_program for reliability in subdirectories
find_program(AARCH64_GCC aarch64-linux-gnu-gcc REQUIRED)
find_program(AARCH64_GXX aarch64-linux-gnu-g++ REQUIRED)
find_program(AARCH64_AR aarch64-linux-gnu-ar REQUIRED)
find_program(AARCH64_RANLIB aarch64-linux-gnu-ranlib REQUIRED)
find_program(AARCH64_STRIP aarch64-linux-gnu-strip REQUIRED)

set(CMAKE_C_COMPILER ${AARCH64_GCC})
set(CMAKE_CXX_COMPILER ${AARCH64_GXX})

set(CMAKE_AR ${AARCH64_AR})
set(CMAKE_RANLIB ${AARCH64_RANLIB})
set(CMAKE_STRIP ${AARCH64_STRIP})

# Also set compiler-integrated AR/RANLIB for LTO-aware tools
set(CMAKE_C_COMPILER_AR ${AARCH64_AR})
set(CMAKE_CXX_COMPILER_AR ${AARCH64_AR})
set(CMAKE_C_COMPILER_RANLIB ${AARCH64_RANLIB})
set(CMAKE_CXX_COMPILER_RANLIB ${AARCH64_RANLIB})

# Where to find headers and libraries for the target
set(CMAKE_FIND_ROOT_PATH /opt/aarch64)

# Search only in target paths for libraries/includes
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
