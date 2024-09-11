include(${CMAKE_CURRENT_LIST_DIR}/../io1_add_target.cmake)
file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/foo.cpp" "int main() { return 0; }")

ct_add_test(NAME io1.add_source_file.normal)
function(${CMAKETEST_TEST})
	add_library(foo STATIC)
	set_target_properties(foo PROPERTIES LINKER_LANGUAGE CXX)

	io1_add_source_file(foo "foo.cpp")
	get_source_file_property(prop "foo.cpp" LANGUAGE)
	ct_assert_equal(prop "NOTFOUND")
	
	get_source_file_property(prop "foo.cpp" HEADER_FILE_ONLY)
	ct_assert_equal(prop "NOTFOUND")
endfunction()

ct_add_test(NAME io1.add_source_file.header)
function(${CMAKETEST_TEST})
	add_library(foo_header STATIC)
	set_target_properties(foo_header PROPERTIES LINKER_LANGUAGE CXX)

	io1_add_source_file(foo_header "foo.cpp:header")
	get_source_file_property(prop "foo.cpp" LANGUAGE)
	#ct_assert_equal(prop "NOTFOUND")
	
	get_source_file_property(prop "foo.cpp" HEADER_FILE_ONLY)
	ct_assert_equal(prop "ON")
endfunction()
