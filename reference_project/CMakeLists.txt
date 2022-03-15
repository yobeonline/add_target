cmake_minimum_required(VERSION 3.18)

project(foo)
add_library(Boost::boost INTERFACE IMPORTED)

add_library(foo STATIC bar.cpp bar.h detail/impl.cpp)
target_include_directories(foo PUBLIC . PRIVATE detail)
target_link_libraries(foo PUBLIC Boost::boost)

source_group(NAME implementation FILES detail/impl.cpp)
set_source_files_properties(detail/impl.cpp PROPERTIES HEADER_FILE_ONLY ON)
