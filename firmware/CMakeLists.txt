cmake_minimum_required(VERSION 3.12)

# we target the RP2354A (ARM)
set(PICO_BOARD pico2)
set(PICO_PLATFORM rp2350)

# pull in pico SDK
include($ENV{PICO_SDK_PATH}/pico_sdk_init.cmake)

project(beacon C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# init pico SDK
pico_sdk_init()

# enable compiler warningss
add_compile_options(-Wall
        -Wno-format
        -Wno-unused-function
)
if (CMAKE_C_COMPILER_ID STREQUAL "GNU")
    add_compile_options(-Wno-maybe-uninitialized)
endif ()

# local libs
add_subdirectory(lib/pico-sk6812)

add_executable(${PROJECT_NAME}
        beacon.cpp
)

# link libs
target_link_libraries(${PROJECT_NAME} pico_stdlib pico-sk6812)

# create map/bin/hex file etc.
pico_add_extra_outputs(${PROJECT_NAME})

target_compile_options(${PROJECT_NAME} PRIVATE -Wall)
