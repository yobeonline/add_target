include(${CMAKE_CURRENT_LIST_DIR}/../io1_add_target.cmake)

ct_add_test(NAME io1.add_source_file.normal)
function(${CMAKETEST_TEST})
	file(WRITE "foo/main.cpp" "int main() { return 0; }\n")

	project(foo LANGUAGES CXX)
	add_library(foo STATIC)
	io1_add_source_file(foo "foo/main.cpp" "" "")
	
	get_target_property(prop foo SOURCES)
	ct_assert_equal(prop "foo/main.cpp") # main.cpp was added to sources
	
	get_source_file_property(prop "foo/main.cpp" LOCATION)
	ct_assert_equal(prop "${CMAKE_CURRENT_SOURCE_DIR}/foo/main.cpp")

	get_source_file_property(prop "foo/main.cpp" HEADER_FILE_ONLY)
	ct_assert_equal(prop "NOTFOUND") # main.cpp is not a header
endfunction()

ct_add_test(NAME io1.add_source_file.header)
function(${CMAKETEST_TEST})
	file(WRITE "foo_header/main.cpp" "int main() { return 0; }\n")
	file(WRITE "foo_header/header.cpp" "int main();\n")
	
	project(foo_header LANGUAGES CXX)
	add_library(foo_header STATIC "foo_header/main.cpp")
	io1_add_source_file(foo_header "foo_header/header.cpp" "header" "")

	get_target_property(prop foo_header SOURCES)
	ct_assert_equal(prop "foo_header/main.cpp;foo_header/header.cpp") # header.cpp was added to sources

	get_source_file_property(prop "foo_header/header.cpp" LOCATION)
	ct_assert_equal(prop "${CMAKE_CURRENT_SOURCE_DIR}/foo_header/header.cpp")

	get_source_file_property(prop "foo_header/header.cpp" HEADER_FILE_ONLY)
	ct_assert_equal(prop "ON") # header.cpp is a header
endfunction()

ct_add_test(NAME io1.add_source_file.cpp)
function(${CMAKETEST_TEST})
	file(WRITE "foo_cpp/main.c" "int main() { return 0; }\n")

	project(foo_cpp LANGUAGES CXX)
	add_library(foo_cpp STATIC)
	io1_add_source_file(foo_cpp "foo_cpp/main.c" "cpp" "")

	get_target_property(prop foo_cpp SOURCES)
	ct_assert_equal(prop "foo_cpp/main.c") # main.c was added to sources

	get_source_file_property(prop "foo_cpp/main.c" LANGUAGE)
	ct_assert_equal(prop "CXX") # main.c is compiled as CXX and not C

	get_source_file_property(prop "foo_cpp/main.c" HEADER_FILE_ONLY)
	ct_assert_equal(prop "NOTFOUND") # main.c is not a header
endfunction()

ct_add_test(NAME io1.add_source_file.cpp_header)
function(${CMAKETEST_TEST})
	file(WRITE "foo_cpp_header/main.cpp" "int main() { return 0; }\n")
	file(WRITE "foo_cpp_header/header.c" "int main();\n")

	project(foo_cpp_header LANGUAGES CXX)
	add_library(foo_cpp_header STATIC foo_cpp_header/main.cpp)
	io1_add_source_file(foo_cpp_header "foo_cpp_header/header.c" "cpp;header" "")

	get_target_property(prop foo_cpp_header SOURCES)
	ct_assert_equal(prop "foo_cpp_header/main.cpp;foo_cpp_header/header.c") # header.c was added to sources

	get_source_file_property(prop "foo_cpp_header/header.c" LANGUAGE)
	ct_assert_equal(prop "CXX") # header.c is compiled as CXX and not C

	get_source_file_property(prop "foo_cpp_header/header.c" HEADER_FILE_ONLY)
	ct_assert_equal(prop "ON") # header.c is a header
endfunction()

ct_add_test(NAME io1.add_source_file.header_cpp)
function(${CMAKETEST_TEST})
	file(WRITE "foo_header_cpp/main.cpp" "int main() { return 0; }\n")
	file(WRITE "foo_header_cpp/header.c" "int main();\n")

	project(foo_header_cpp LANGUAGES CXX)
	add_library(foo_header_cpp STATIC foo_header_cpp/main.cpp)
	io1_add_source_file(foo_header_cpp "foo_header_cpp/header.c" "header;cpp" "")

	get_target_property(prop foo_header_cpp SOURCES)
	ct_assert_equal(prop "foo_header_cpp/main.cpp;foo_header_cpp/header.c") # header.c was added to sources

	get_source_file_property(prop "foo_header_cpp/header.c" LANGUAGE)
	ct_assert_equal(prop "CXX") # header.c is compiled as CXX and not C

	get_source_file_property(prop "foo_header_cpp/header.c" HEADER_FILE_ONLY)
	ct_assert_equal(prop "ON") # header.c is a header
endfunction()

