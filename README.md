# add_target

A CMake function to bundle all the calls to `add_library`, `target_link_libraries`, etc. into one command, hence reducing name duplication in CMake scripts.

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
	BOOST_TEST
		test/test1.cpp
	DEPENDENCIES
		PUBLIC Boost::boost
)
```

The above call to `add_target` behaves as if the following script was executed.

```cmake
add_library(foo
	STATIC
		bar.cpp
		bar.h
		detail/impl.cpp
)
target_include_directories(foo
	PUBLIC .
	PRIVATE detail
)
target_link_libraries(foo
	PUBLIC Boost::boost
)

source_group(NAME implementation FILES detail/impl.cpp)
set_source_files_properties(detail/impl.cpp
	PROPERTIES HEADER_FILE_ONLY ON
)

if(BUILD_TESTING)
	find_package(Boost REQUIRED COMPONENTS unit_test_framework QUIET)
	add_executable(boost-test-foo test/test1.cpp)
	target_link_libraries(boost-test-foo
		PRIVATE foo Boost::unit_test_framework
	)

	add_test(
		NAME boost-test-foo
		COMMAND boost-test-foo --catch_system_error=yes --detect_memory_leaks --logger=JUNIT,all,junit_${test_name}.xml
		WORKING_DIRECTORY $<TARGET_FILE_DIR:boost-test-foo>
	)
endfi()
```

## References

```cmake
add_target(<name>
	STATIC|SHARED|HEADER_ONLY|EXECUTABLE <source> …
	[INCLUDES <folder> … ]
	[DEPENDENCIES <target> <lib> … ]
	[OPTIONS <flag> … ]
	[DEFINITIONS <define> … ]
	[BOOST_TEST <source> … ]
	[GOOGLE_TEST <source> … ]
)
```

### Target Type

The target `<name>` is created as if the following commands were called.

- `add_library(<name> STATIC <source> …)` for `STATIC`,
- `add_library(<name> SHARED <source> …)` for `SHARED`,
- `add_library(<name> INTERFACE <source> …)` for `HEADER_ONLY`,
- `add_executable(<name> <source> …)` for `EXECUTABLE`.

### Target Configuration

The target `<name>` may be configured with:

- include directories after the `INCLUDES` keyword,
- target and/or libraries dependencies after the `DEPENDENCIES` keyword,
- compile options after the `OPTIONS` keyword,
- and compile definitions after the `DEFINITIONS` keyword.

The arguments listed after each of these keywords are forwarded as is to the corresponding native CMake command. As a result, you may use the same syntax as you would if you were calling them directly.

- `INCLUDES` translates to `target_include_directories()`,
- `DEPENDENCIES` translates to `target_link_libraries()`,
- `OPTIONS` translates to `target_compile_options()`,
- and `DEFINITIONS` translates to `targetçcompile_definitions()`.

### Boost and Google Tests

The `BOOST_TEST`and `GOOGLE_TEST` keywords each create an additional executable target named `boost-test-<name>` and`google-test-<name>`  respectively. Each executable depends on target `<name>` and `Boost::unit_test_framework` or `GTest::Main`. The Boost component unit_test_framework or the GTest package are required. They are looked for by the following `find_package` calls:

```cmake
find_package(Boost REQUIRED COMPONENTS unit_test_framework QUIET)
find_package(GTest REQUIRED QUIET)
```

If testing is enabled in your CMake project (see [here](https://cmake.org/cmake/help/latest/command/enable_testing.html)), tests are added to CTest using `add_test` for Boost and `gtest_discover_tests` for GTest. The way these tests are configured is not yet specified.

### Sources Options and Groups

Everywhere source files are expected, you may use the following syntax to specify dedicated compile options or assign them source groups.

#### Options

The syntax to apply options on a source file is to append a colon to the filename followed by one of the following keywords:

- `header` to disable compilation,
- `cpp` to force compilation with a c++ compiler.

For example, `test.c:cpp` will use the c++ compiler on test.c as in the following call:

```cmake
set_source_files_properties(test.c PROPERTIES LANGUAGE CXX)
```

and `impl.cpp:header` will treat impl.cpp as a header file, as in the following call:

```cmake
set_source_files_properties(impl.cpp PROPERTIES HEADER_FILE_ONLY ON)
```

#### Source Groups

If a file name ends with "//", it is considered the name of a source group. Every subsequent filename will be assign this source group with a call to:

```cmake
source_group(NAME "<group>" FILES "<source>")
```

If a group name is absolute, ie. starts with "/", then it completely replaces the previous source group. If it is relative, then, the new source group is computed from the previous one with the same rules as file paths on Linux systems.

For example, the following source list assigns the group foo to the file test1.cpp and test2.cpp, the group foo/bar to test3.cpp and the group fizz/buzz to test4.cpp.

```cmake
/foo// test1.cpp test2.cpp bar// test3.cpp /fizz/buzz// test4.cpp
```

