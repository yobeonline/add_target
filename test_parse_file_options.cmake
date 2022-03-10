include(add_target.cmake)
include(unit_test_for_cmake/unit-test.cmake)

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
