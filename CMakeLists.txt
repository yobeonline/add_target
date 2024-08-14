cmake_minimum_required(VERSION 3.19)

project(test_add_target)

set(BUILD_TESTING ON CACHE STRING "")
set(BUILD_TESTING ON)

include(add_target.cmake)

include(FetchContent)
FetchContent_Declare(
  cmake_test
  GIT_REPOSITORY https://github.com/CMakePP/CMakeTest
  GIT_TAG v0.1.14
)
FetchContent_MakeAvailable(cmake_test)
include(cmake_test/cmake_test)

ct_add_dir("test")
