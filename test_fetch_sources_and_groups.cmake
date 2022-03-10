include(add_target.cmake)
include(unit_test_for_cmake/unit-test.cmake)

fetch_sources_and_groups("test.cpp" sources groups all)
EXPECT_EMPTY("${groups}")
EXPECT_EMPTY("${sources}")
EXPECT_STREQ("test.cpp" "${all}")

fetch_sources_and_groups("/.//;test.cpp" sources groups all)
EXPECT_EMPTY("${groups}")
EXPECT_EMPTY("${sources}")
EXPECT_STREQ("test.cpp" "${all}")

fetch_sources_and_groups("/sources//;test.cpp" sources groups all)
EXPECT_STREQ("sources" "${groups}")
EXPECT_STREQ("test.cpp" "${sources}")
EXPECT_STREQ("test.cpp" "${all}")

fetch_sources_and_groups("test.h;/sources//;test.cpp" sources groups all)
EXPECT_STREQ("sources" "${groups}")
EXPECT_STREQ("test.cpp" "${sources}")
EXPECT_STREQ("test.h;test.cpp" ${all})

fetch_sources_and_groups("test.h;/sources//;test.cpp;details//;impl.cpp" sources groups all)
EXPECT_STREQ("sources;sources/details" "${groups}")
EXPECT_STREQ("test.cpp;impl.cpp" "${sources}")
EXPECT_STREQ("test.h;test.cpp;impl.cpp" "${all}")

fetch_sources_and_groups("test.h;/sources//;test.cpp;/details//;impl.cpp" sources groups all)
EXPECT_STREQ("sources;details" "${groups}")
EXPECT_STREQ("test.cpp;impl.cpp" "${sources}")
EXPECT_STREQ("test.h;test.cpp;impl.cpp" "${all}")

fetch_sources_and_groups("test.h;/sources//;test.cpp;../details//;impl.cpp" sources groups all)
EXPECT_STREQ("sources;details" "${groups}")
EXPECT_STREQ("test.cpp;impl.cpp" "${sources}")
EXPECT_STREQ("test.h;test.cpp;impl.cpp" "${all}")

