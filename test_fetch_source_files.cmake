include(add_target.cmake)
include(unit_test_for_cmake/unit-test.cmake)

function(test_sources_alone)
	fetch_source_files(sources test.cpp)
	EXPECT_STREQ("test.cpp" "${sources}")

	fetch_source_files(sources "test.cpp;foo.txt")
	EXPECT_STREQ("test.cpp;foo.txt" "${sources}")

	fetch_source_files(sources "test.cpp" "foo.txt")
	EXPECT_STREQ("test.cpp;foo.txt" "${sources}")

	fetch_source_files(sources)
	EXPECT_EMPTY("${sources}")

	fetch_source_files(out_sources "test.cpp")
	EXPECT_STREQ("test.cpp" "${out_sources}")

	fetch_source_files(out_sources "test.cpp;foo.txt")
	EXPECT_STREQ("test.cpp;foo.txt" "${out_sources}")
endfunction()

function(test_groups_alone)
	fetch_source_files(sources "///")
	EXPECT_EMPTY("${sources}")

	fetch_source_files(sources "//")
	EXPECT_EMPTY("${sources}")

	fetch_source_files(sources "//" "a//" "/b//" "a/b/c//" "/a/b//")
	EXPECT_EMPTY("${sources}")

	fetch_source_files(sources "//;a//;/b//;a/b/c//;/a/b//")
	EXPECT_EMPTY("${sources}")
endfunction()

function(test_options)
	fetch_source_files(sources "test.cpp:header" "test.txt:file")
	EXPECT_STREQ("test.cpp;test.txt" "${sources}")

	fetch_source_files(sources "test.cpp:header;test.txt:file")
	EXPECT_STREQ("test.cpp;test.txt" "${sources}")

	fetch_source_files(sources "test.cpp:header;test.txt:file//") # last one interpreted as group
	EXPECT_STREQ("test.cpp" "${sources}")
endfunction()

function(test_all_together)
	fetch_source_files(sources "test.h" "b//" "test.cpp:header" "/a:c//" "test.txt")
	EXPECT_STREQ("test.h;test.cpp;test.txt" "${sources}")

	fetch_source_files(sources "test.h;b:c//;test.cpp:header;/a//;test.txt")
	EXPECT_STREQ("test.h;test.cpp;test.txt" "${sources}")
endfunction()

test_sources_alone()
test_groups_alone()
test_options()
test_all_together()