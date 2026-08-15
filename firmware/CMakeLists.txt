cmake_minimum_required(VERSION 3.12)

set(PICO_BOARD pico2)
set(PICO_PLATFORM rp2350)

include($ENV{PICO_SDK_PATH}/pico_sdk_init.cmake)

project(beacon C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_compile_options(-Wall
        -Wno-format
        -Wno-unused-function
)

add_subdirectory(lib/pico-sk6812)

add_executable(${PROJECT_NAME}
        beacon.cpp
        usb_descriptors.c
)

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(${PROJECT_NAME}
        pico_stdlib
        pico-sk6812
        pico_unique_id
        tinyusb_device
        tinyusb_board
)

pico_add_extra_outputs(${PROJECT_NAME})
