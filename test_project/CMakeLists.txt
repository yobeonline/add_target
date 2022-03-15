cmake_minimum_required(VERSION 3.18)

project(foo)
add_library(Boost::boost INTERFACE IMPORTED)
include(../add_target)

add_target(foo
	STATIC
		bar.cpp
		bar.h
		/implementation//
		detail/impl.cpp:header
	INCLUDES
		PUBLIC .
		PRIVATE detail
	DEPENDENCIES
		PUBLIC Boost::boost
)
