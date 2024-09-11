include(${CMAKE_CURRENT_LIST_DIR}/../io1_add_target.cmake)

ct_add_test(NAME io1.is_source_group.normal)
function(${CMAKETEST_TEST})
	set(out "foo")
	io1_is_source_group("test.cpp" out)
	ct_assert_false(out)

	set(out "foo")
	io1_is_source_group("test" out)
	ct_assert_false(out)
	
	set(out "foo")
	io1_is_source_group("" out)
	ct_assert_false(out)

	set(out "foo")
	io1_is_source_group("/" out)
	ct_assert_false(out)

	set(out "foo")
	io1_is_source_group("/foo" out)
	ct_assert_false(out)

	set(out "foo")
	io1_is_source_group("/foo/" out)
	ct_assert_false(out)

	set(out "foo")
	io1_is_source_group("/foo/bar" out)
	ct_assert_false(out)

	set(out "foo")
	io1_is_source_group("/foo/bar/" out)
	ct_assert_false(out)

	set(out "foo")
	io1_is_source_group("//" out)
	ct_assert_true(out)

	set(out "foo")
	io1_is_source_group("/foo//" out)
	ct_assert_true(out)

	set(out "foo")
	io1_is_source_group("foo//" out)
	ct_assert_true(out)

	set(out "foo")
	io1_is_source_group("bar/foo//" out)
	ct_assert_true(out)

	set(out "foo")
	io1_is_source_group("/bar/foo//" out)
	ct_assert_true(out)
endfunction()
