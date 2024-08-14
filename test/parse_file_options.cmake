include(cmake_test/cmake_test)

ct_add_test(NAME parse_file_options.main)
function(${CMAKETEST_TEST})
  parse_file_options("test.cpp" file options)
  ct_assert_equal(file "test.cpp")
  ct_assert_not_defined(options)

  parse_file_options("test.cpp:toto" file options)
  ct_assert_equal(file "test.cpp")
  ct_assert_equal(options, "toto")

  parse_file_options("test.cpp:toto,tata" file options)
  ct_assert_equal(file "test.cpp")
  ct_assert_equal(options, "toto;tata")

  parse_file_options("test.cpp" file options)
  ct_assert_equal(file "test.cpp")
  ct_assert_not_defined(options)

  parse_file_options("" file options)
  ct_assert_not_defined(file)
  ct_assert_not_defined(options)

  parse_file_options(":" file options)
  ct_assert_not_defined(file)
  ct_assert_not_defined(options)

  parse_file_options("test.cpp:" file options)
  ct_assert_equal(file "test.cpp")
  ct_assert_not_defined(options)

  parse_file_options(":toto" file options)
  ct_assert_not_defined(file)
  ct_assert_not_defined(options)
endfunction()


# Using same variable names as in function definition because some
# implementations may break in this case.
ct_add_test(NAME parse_file_options.same_variable_names)
function(${CMAKETEST_TEST})
  parse_file_options("test.cpp" out_file out_options)
  ct_assert_equal(out_file "test.cpp")
  ct_assert_not_defined(out_options)

  parse_file_options("test.cpp:toto" out_file out_options)
  ct_assert_equal(out_file "test.cpp")
  ct_assert_equal(out_options "toto")

  parse_file_options("test.cpp" out_file out_options)
  ct_assert_equal(out_file "test.cpp")
  ct_assert_not_defined(out_options "toto")

  parse_file_options(":" out_file out_options)
  ct_assert_not_defined(out_file)
  ct_assert_not_defined(out_options)

  parse_file_options("test.cpp:" out_file out_options)
  ct_assert_equal(out_file "test.cpp")
  ct_assert_not_defined(out_options)

  parse_file_options(":toto" out_file out_options)
  ct_assert_not_defined(out_file)
  ct_assert_not_defined(out_options)
endfunction()
