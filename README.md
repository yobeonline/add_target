# add_target

A CMake function to bundle all the calls to add_library, target_link_libraries, etc. into one command, hence reducing name duplication in CMake scripts.

## Example

```cmake
include(add_target.cmake)

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
```

The above call to `add_target` behaves as if the following script was executed.

```cmake
add_library(foo STATIC bar.cpp bar.h detail/impl.cpp)
target_include_directories(foo PUBLIC . PRIVATE detail)
target_link_libraries(foo PUBLIC Boost::boost)

source_group(NAME implementation FILES detail/impl.cpp)
set_source_files_properties(detail/impl.cpp PROPERTIES HEADER_FILE_ONLY ON)
```

## References

```cmake
add_target(<name>
	STATIC|SHARED|EXECUTABLE|HEADER_ONLY
		<group name or sources with options> ...
	[INCLUDES
		[PUBLIC|PRIVATE|INTERFACE] <folders> ...
	]
	[DEPENDENCIES
		[PUBLIC|PRIVATE|INTERFACE] <targets or libs> ...
	]
	[OPTIONS
		[PUBLIC|PRIVATE|INTERFACE] <flags> ...
	]
	[DEFINITIONS
		[PUBLIC|PRIVATE|INTERFACE] <defines> ...
	]
	[BOOST_TEST
		<sources> ...
	]
	[GOOGLE_TEST
		<sources> ...
	]
)
```

If `STATIC`, call `add_library(name STATIC sources)`. If or `add_executable`

