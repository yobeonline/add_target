include(add_target.cmake)
include(unit_test_for_cmake/unit-test.cmake)

function(test_no_groups)
	fetch_source_groups(sources groups "")
	EXPECT_EMPTY("${groups}")
	EXPECT_EMPTY("${sources}")

	fetch_source_groups(sources groups "test.cpp")
	EXPECT_EMPTY("${groups}")
	EXPECT_EMPTY("${sources}")

	fetch_source_groups(out_sources out_groups "")
	EXPECT_EMPTY("${out_sources}")
	EXPECT_EMPTY("${out_groups}")

	fetch_source_groups(out_sources out_groups "test.cpp")
	EXPECT_EMPTY("${out_sources}")
	EXPECT_EMPTY("${out_groups}")
endfunction()

function(test_no_sources)
	fetch_source_groups(sources groups "toto//")
	EXPECT_EMPTY("${groups}")
	EXPECT_EMPTY("${sources}")

	fetch_source_groups(sources groups "/toto//;tata//")
	EXPECT_EMPTY("${groups}")
	EXPECT_EMPTY("${sources}")

	fetch_source_groups(out_sources out_groups "toto//")
	EXPECT_EMPTY("${out_sources}")
	EXPECT_EMPTY("${out_groups}")

	fetch_source_groups(out_sources out_groups "/toto//;tata//")
	EXPECT_EMPTY("${out_sources}")
	EXPECT_EMPTY("${out_groups}")
endfunction()

function(test_main)
	fetch_source_groups(sources groups "test.cpp;toto//;test.h;detail/impl.h;tata//;help.txt;/foo/bar//;readme.md")
	EXPECT_STREQ("${groups}" "toto;toto;toto/tata;foo/bar")
	EXPECT_STREQ("${sources}" "test.h;detail/impl.h;help.txt;readme.md")

	fetch_source_groups(out_sources out_groups "test.cpp;toto//;test.h;detail/impl.h;tata//;help.txt;/foo/bar//;readme.md")
	EXPECT_STREQ("${out_groups}" "toto;toto;toto/tata;foo/bar")
	EXPECT_STREQ("${out_sources}" "test.h;detail/impl.h;help.txt;readme.md")

	fetch_source_groups(sources groups "")
	EXPECT_EMPTY("${groups}")
	EXPECT_EMPTY("${sources}")

	fetch_source_groups(out_sources out_groups "")
	EXPECT_EMPTY("${out_groups}")
	EXPECT_EMPTY("${out_sources}")
endfunction()

test_no_groups()
test_no_sources()
test_main()