include(add_target.cmake)
include(unit_test_for_cmake/unit-test.cmake)

function(test_main)
  parse_file_options("test.cpp" file options)
  expect_streq("${file}" "test.cpp")
  expect_empty("${options}")

  parse_file_options("test.cpp:toto" file options)
  expect_streq("${file}" "test.cpp")
  expect_streq("${options}" "toto")

  parse_file_options("test.cpp:toto,tata" file options)
  expect_streq("${file}" "test.cpp")
  expect_streq("${options}" "toto;tata")

  parse_file_options("test.cpp" file options)
  expect_streq("${file}" "test.cpp")
  expect_empty("${options}")

  parse_file_options("" file options)
  expect_empty("${file}")
  expect_empty("${options}")

  parse_file_options(":" file options)
  expect_empty("${file}")
  expect_empty("${options}")

  parse_file_options("test.cpp:" file options)
  expect_streq("${file}" "test.cpp")
  expect_empty("${options}")

  parse_file_options(":toto" file options)
  expect_empty("${file}")
  expect_empty("${options}")
endfunction()

# Using same variable names as in function definition because some
# implementations may break in this case.
function(test_same_variable_names)
  parse_file_options("test.cpp" out_file out_options)
  expect_streq("${out_file}" "test.cpp")
  expect_empty("${out_options}")

  parse_file_options("test.cpp:toto" out_file out_options)
  expect_streq("${out_file}" "test.cpp")
  expect_streq("${out_options}" "toto")

  parse_file_options("test.cpp" out_file out_options)
  expect_streq("${out_file}" "test.cpp")
  expect_empty("${out_options}")

  parse_file_options(":" out_file out_options)
  expect_empty("${out_file}")
  expect_empty("${out_options}")

  parse_file_options("test.cpp:" out_file out_options)
  expect_streq("${out_file}" "test.cpp")
  expect_empty("${out_options}")

  parse_file_options(":toto" out_file out_options)
  expect_empty("${out_file}")
  expect_empty("${out_options}")
endfunction()

test_main()
test_same_variable_names()
