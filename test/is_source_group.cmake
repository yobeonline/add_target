include(${CMAKE_CURRENT_LIST_DIR}/../io1_add_target.cmake)

ct_add_test(NAME io1.is_source_group.normal)
function(${CMAKETEST_TEST})
	set(res "foo")
	io1_is_source_group("test.cpp" res)
	ct_assert_not_defined(res)

	set(res "foo")
	io1_is_source_group("test" res)
	ct_assert_not_defined(res)
	
	set(res "foo")
	io1_is_source_group("" res)
	ct_assert_not_defined(res)

	set(res "foo")
	io1_is_source_group("/" res)
	ct_assert_not_defined(res)

	set(res "foo")
	io1_is_source_group("/foo" res)
	ct_assert_not_defined(res)

	set(res "foo")
	io1_is_source_group("/foo/" res)
	ct_assert_not_defined(res)

	set(res "foo")
	io1_is_source_group("/foo/bar" res)
	ct_assert_not_defined(res)

	set(res "foo")
	io1_is_source_group("/foo/bar/" res)
	ct_assert_not_defined(res)

	set(res "foo")
	io1_is_source_group("//" res)
	ct_assert_equal(res "")

	set(res "foo")
	io1_is_source_group("///" res)
	ct_assert_equal(res "/")

	set(res "foo")
	io1_is_source_group("/foo//" res)
	ct_assert_equal(res "/foo")

	set(res "bar")
	io1_is_source_group("foo//" res)
	ct_assert_equal(res "foo")

	set(res "foo")
	io1_is_source_group("foo///" res)
	ct_assert_equal(res "foo/")

	set(res "foo")
	io1_is_source_group("bar/foo//" res)
	ct_assert_equal(res "bar/foo")

	set(res "foo")
	io1_is_source_group("/bar/foo//" res)
	ct_assert_equal(res "/bar/foo")

	set(res "foo")
	io1_is_source_group("/bar/foo///" res)
	ct_assert_equal(res "/bar/foo/")
endfunction()
