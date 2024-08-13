cmake_minimum_required(VERSION 3.19)

project(test_add_target)

include(add_target.cmake)

include(FetchContent)
FetchContent_Declare(
  cmake_test
  GIT_REPOSITORY https://github.com/CMakePP/CMakeTest
)
FetchContent_MakeAvailable(cmake_test)
include(cmake_test/cmake_test)

ct_add_dir("${CMAKE_CURRENT_SOURCE_DIR}/test")
