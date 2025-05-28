cmake_minimum_required(VERSION 3.15 FATAL_ERROR)

project(octdata4python LANGUAGES CXX)

find_package(Boost COMPONENTS python numpy REQUIRED)
find_package(LibOctData REQUIRED)
find_package(OpenCV REQUIRED COMPONENTS core)

set(CMAKE_CXX_STANDARD 17)

if(CMAKE_COMPILER_IS_GNUCXX)
        set(CMAKE_CXX_FLAGS "-Wall -Wextra -Wunreachable-code -Wconversion")
#       set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -static-libstdc++")
endif()

add_library(octdata4python MODULE octdata4python.cpp)

set_target_properties(octdata4python PROPERTIES PREFIX "")

target_link_libraries(octdata4python
    PRIVATE
    LibOctData::octdata
    Boost::python
    Boost::numpy
    opencv_core
)

install(TARGETS octdata4python LIBRARY DESTINATION octdata4python)
