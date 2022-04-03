include(add_target.cmake)
include(unit_test_for_cmake/unit-test.cmake)

function(test_main)
	parse_file_options("test.cpp" file options)
	EXPECT_STREQ("${file}" "test.cpp")
	EXPECT_EMPTY("${options}")

	parse_file_options("test.cpp:toto" file options)
	EXPECT_STREQ("${file}" "test.cpp")
	EXPECT_STREQ("${options}" "toto")

	parse_file_options("test.cpp:toto,tata" file options)
	EXPECT_STREQ("${file}" "test.cpp")
	EXPECT_STREQ("${options}" "toto;tata")

	parse_file_options("test.cpp" file options)
	EXPECT_STREQ("${file}" "test.cpp")
	EXPECT_EMPTY("${options}")

	parse_file_options("" file options)
	EXPECT_EMPTY("${file}")
	EXPECT_EMPTY("${options}")

	parse_file_options(":" file options)
	EXPECT_EMPTY("${file}")
	EXPECT_EMPTY("${options}")

	parse_file_options("test.cpp:" file options)
	EXPECT_STREQ("${file}" "test.cpp")
	EXPECT_EMPTY("${options}")

	parse_file_options(":toto" file options)
	EXPECT_EMPTY("${file}")
	EXPECT_EMPTY("${options}")
endfunction()

# Using same variable names as in function definition because some implementations may break in this case.
function(test_same_variable_names)
	parse_file_options("test.cpp" out_file out_options)
	EXPECT_STREQ("${out_file}" "test.cpp")
	EXPECT_EMPTY("${out_options}")

	parse_file_options("test.cpp:toto" out_file out_options)
	EXPECT_STREQ("${out_file}" "test.cpp")
	EXPECT_STREQ("${out_options}" "toto")

	parse_file_options("test.cpp" out_file out_options)
	EXPECT_STREQ("${out_file}" "test.cpp")
	EXPECT_EMPTY("${out_options}")

	parse_file_options(":" out_file out_options)
	EXPECT_EMPTY("${out_file}")
	EXPECT_EMPTY("${out_options}")

	parse_file_options("test.cpp:" out_file out_options)
	EXPECT_STREQ("${out_file}" "test.cpp")
	EXPECT_EMPTY("${out_options}")

	parse_file_options(":toto" out_file out_options)
	EXPECT_EMPTY("${out_file}")
	EXPECT_EMPTY("${out_options}")
endfunction()

test_main()
test_same_variable_names()
