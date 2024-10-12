include(${CMAKE_CURRENT_LIST_DIR}/../io1_add_target.cmake)

ct_add_test(NAME io1.update_source_group.normal)
function(${CMAKETEST_TEST})
	set(current_group "foo")
	set(updated_group "meow")
	io1_update_source_group("${current_group}" "bar" updated_group)
	ct_assert_equal(updated_group "foo/bar")

	set(current_group "foo")
	set(updated_group "meow")
	io1_update_source_group("${current_group}" "bar/meow" updated_group)
	ct_assert_equal(updated_group "foo/bar/meow")

	set(current_group "foo")
	set(updated_group "meow")
	io1_update_source_group("${current_group}" "/bar" updated_group)
	ct_assert_equal(updated_group "/bar")

	set(current_group "foo")
	set(updated_group "meow")
	io1_update_source_group("${current_group}" "./" updated_group)
	ct_assert_equal(updated_group "foo")

	set(current_group "foo/bar")
	set(updated_group "meow")
	io1_update_source_group("${current_group}" "../" updated_group)
	ct_assert_equal(updated_group "foo")

	set(current_group "foo/bar")
	set(updated_group "meow")
	io1_update_source_group("${current_group}" "../meow" updated_group)
	ct_assert_equal(updated_group "foo/meow")

	set(current_group "/foo/bar")
	set(updated_group "meow")
	io1_update_source_group("${current_group}" "../meow" updated_group)
	ct_assert_equal(updated_group "/foo/meow")

	set(current_group "/foo/bar")
	set(updated_group "meow")
	io1_update_source_group("${current_group}" "/" updated_group)
	ct_assert_equal(updated_group "/")

	set(current_group "/foo/bar")
	set(updated_group "meow")
	io1_update_source_group("${current_group}" "../../../" updated_group)
	ct_assert_equal(updated_group "/")

	set(current_group "/foo/bar")
	set(updated_group "meow")
	io1_update_source_group("${current_group}" "../../../meow" updated_group)
	ct_assert_equal(updated_group "/meow")
endfunction()
