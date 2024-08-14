include(add_target.cmake)
include(unit_test_for_cmake/unit-test.cmake)

function(test_no_groups)
  fetch_source_groups(sources groups "")
  expect_empty("${groups}")
  expect_empty("${sources}")

  fetch_source_groups(sources groups "test.cpp")
  expect_empty("${groups}")
  expect_empty("${sources}")

  fetch_source_groups(out_sources out_groups "")
  expect_empty("${out_sources}")
  expect_empty("${out_groups}")

  fetch_source_groups(out_sources out_groups "test.cpp")
  expect_empty("${out_sources}")
  expect_empty("${out_groups}")
endfunction()

function(test_no_sources)
  fetch_source_groups(sources groups "toto//")
  expect_empty("${groups}")
  expect_empty("${sources}")

  fetch_source_groups(sources groups "/toto//;tata//")
  expect_empty("${groups}")
  expect_empty("${sources}")

  fetch_source_groups(out_sources out_groups "toto//")
  expect_empty("${out_sources}")
  expect_empty("${out_groups}")

  fetch_source_groups(out_sources out_groups "/toto//;tata//")
  expect_empty("${out_sources}")
  expect_empty("${out_groups}")
endfunction()

function(test_main)
  fetch_source_groups(
    sources groups
    "test.cpp;toto//;test.h;detail/impl.h;tata//;help.txt;/foo/bar//;readme.md")
  expect_streq("${groups}" "toto;toto;toto/tata;foo/bar")
  expect_streq("${sources}" "test.h;detail/impl.h;help.txt;readme.md")

  fetch_source_groups(
    out_sources out_groups
    "test.cpp;toto//;test.h;detail/impl.h;tata//;help.txt;/foo/bar//;readme.md")
  expect_streq("${out_groups}" "toto;toto;toto/tata;foo/bar")
  expect_streq("${out_sources}" "test.h;detail/impl.h;help.txt;readme.md")

  fetch_source_groups(sources groups "")
  expect_empty("${groups}")
  expect_empty("${sources}")

  fetch_source_groups(out_sources out_groups "")
  expect_empty("${out_groups}")
  expect_empty("${out_sources}")
endfunction()

test_no_groups()
test_no_sources()
test_main()
