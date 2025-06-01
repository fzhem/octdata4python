cmake_minimum_required(VERSION 3.15 FATAL_ERROR)
project(octdata4python LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)

# 🔧 Match Boost build config
set(Boost_USE_STATIC_LIBS OFF)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)

# Match Boost libs per platform and Python version
if(WIN32)
  string(REPLACE "." "" PY_VER "${Python3_VERSION}")
  set(BOOST_PYTHON_COMPONENT "python${PY_VER}")
else()
  set(BOOST_PYTHON_COMPONENT "python")
endif()
message(STATUS "🐍 Boost.Python component resolved as: ${BOOST_PYTHON_COMPONENT}")

find_package(Python3 REQUIRED COMPONENTS Interpreter Development.Module)
find_package(Boost COMPONENTS ${BOOST_PYTHON_COMPONENT} numpy REQUIRED)
find_package(LibOctData REQUIRED)
find_package(OpenCV REQUIRED COMPONENTS core)

add_library(${CMAKE_PROJECT_NAME} MODULE octdata4python.cpp)

set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES PREFIX "")

if(WIN32)
  set_target_properties(${PROJECT_NAME} PROPERTIES SUFFIX ".pyd")
  message(STATUS "🪟 Windows detected: setting output suffix to .pyd")
endif()

if(CMAKE_COMPILER_IS_GNUCXX)
    set(CMAKE_CXX_FLAGS "-Wall -Wextra -Wunreachable-code -Wconversion")
endif()

if(MSVC)
  message(STATUS "🛠 MSVC detected: setting runtime library flags")
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDebugDLL")
    message(STATUS "🐞 Debug build: using MultiThreadedDebugDLL")
  endif()
endif()

target_link_libraries(octdata4python
    PRIVATE
    LibOctData::octdata
    Boost::python
    Boost::numpy
    opencv_core
    Python3::Module
)

install(TARGETS ${CMAKE_PROJECT_NAME} LIBRARY DESTINATION octdata4python/core)
