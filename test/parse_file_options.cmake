include(${CMAKE_CURRENT_LIST_DIR}/../io1_add_target.cmake)

# variable names out_file and out_options are also local names
# of parse_file_options, keep them in sync
ct_add_test(NAME io1.parse_file_options.normal)
function(${CMAKETEST_TEST})
	set(out_file "foo")
	set(out_options "bar")
	io1_parse_file_options("test.cpp" out_file out_options)

	ct_assert_equal(out_file "test.cpp")
	ct_assert_not_defined(out_options)
endfunction()

ct_add_test(NAME io1.parse_file_options.with_one_option)
function(${CMAKETEST_TEST})
	set(out_file "foo")
	set(out_options "bar")
	io1_parse_file_options("test.cpp:toto" out_file out_options)

	ct_assert_equal(out_file "test.cpp")
	ct_assert_equal(out_options "toto")
endfunction()

ct_add_test(NAME io1.parse_file_options.with_two_options)
function(${CMAKETEST_TEST})
	set(out_file "foo")
	set(out_options "bar")
	io1_parse_file_options("test.cpp:toto,tata" out_file out_options)

	ct_assert_equal(out_file "test.cpp")
	ct_assert_equal(out_options "toto;tata")
endfunction()

ct_add_test(NAME io1.parse_file_options.with_no_option)
function(${CMAKETEST_TEST})
	set(out_file "foo")
	set(out_options "bar")
	io1_parse_file_options("test.cpp:" out_file out_options)

	ct_assert_equal(out_file "test.cpp")
	ct_assert_not_defined(out_options)
endfunction()

ct_add_test(NAME io1.parse_file_options.orphaned_option EXPECTFAIL)
function(${CMAKETEST_TEST})
	io1_parse_file_options(":toto" out_file out_options)
endfunction()

ct_add_test(NAME io1.parse_file_options.orphaned_no_option EXPECTFAIL)
function(${CMAKETEST_TEST})
	io1_parse_file_options(":" out_file out_options)
endfunction()
