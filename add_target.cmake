cmake_minimum_required(VERSION 3.18)

if (COMMAND add_target)
	message(WARNING "add_target function already exists, breaking early instead of overriding.")
	return()
endif()


function(add_target target_name)
	if (TARGET ${target_name})
		message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: Cannot add target ${target_name} because it already exists.")
	endif()

	set(options "STATIC;SHARED;EXECUTALBE;HEADER_ONLY")
	set(multivalue_keywords "INCLUDES;DEPENDENCIES;OPTIONS;DEFINITIONS;BOOST_TEST;GOOGLE_TEST")

	cmake_parse_arguments(PARSE_ARGV 1 io1
		"${options}"
		""
		"${multivalue_keywords}"
	)


	# options are mutually exclusive
	# the found_options list must have length one
	# at the end of this loop
	foreach(option IN LISTS options)
		if (io1_${option})
			list(APPEND found_option ${option})
		endif()
	endforeach()
	list(LENGTH found_option found_option_count)
	if (found_option_count EQUAL 0)
		message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: missing target type.")
	elseif (NOT found_option_count EQUAL 1)
		message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: cannot define multiple target types.")
	endif()
	
	# target sources are the leftover values
	fetch_source_files(sources ${io1_UNPARSED_ARGUMENTS})

	# create the target with the type detected by found_option
	if (DEFINED io1_STATIC)
		add_library(${target_name} STATIC ${sources})
	elseif(DEFINED io1_SHARED)
		add_library(${target_name} SHARED ${sources})
	elseif(DEFINED io1_EXECUTABLE)
		add_executable(${target_name} ${sources})
	elseif(DEFINED io1_HEADER_ONLY)
		add_library(${target_name} INTERFACE ${sources})
	endif()

	# apply source files properties and groups
	apply_source_groups(${io1_UNPARSED_ARGUMENTS})
	apply_source_files_properties(${io1_UNPARSED_ARGUMENTS})

	message(STATUS "${CMAKE_CURRENT_FUNCTION}: created ${found_option} target ${target_name}.")
	

	# configure the target from the multi-value keywords
	if (DEFINED io1_INCLUDES)
		target_include_directories(${target_name} ${io1_INCLUDES})
	endif()
	if (DEFINED io1_DEPENDENCIES)
		target_link_libraries(${target_name} ${io1_DEPENDENCIES})
	endif()
	if (DEFINED io1_OPTIONS)
		target_compile_options(${target_name} ${io1_OPTIONS})
	endif()
	if(DEFINED io1_DEFINITIONS)
		target_compile_definitions(${target_name} ${io1_DEFINITIONS})
	endif()
	if(DEFINED io1_BOOST_TEST AND BUILD_TESTING)
		set(test_name "boost-test-${target_name}")
		if (TARGET ${test_name})
			message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: cannot create boost test target ${test_name} because it already exists.")
		else()
			message(STATUS "${CMAKE_CURRENT_FUNCTION}: created boost test target ${test_name}.")
		endif()

		find_package(Boost REQUIRED COMPONENTS unit_test_framework)
		add_executable(${test_name} ${test_sources})
		target_link_libraries(${test_name} PRIVATE ${target_name} Boost::unit_test_framework)

		add_test(
		    NAME ${test_name}
		    COMMAND ${test_name} --catch_system_error=yes --detect_memory_leaks --logger=JUNIT,all,junit_${test_name}.xml
		    WORKING_DIRECTORY $<TARGET_FILE_DIR:${test_name}>)

	endif()
	if(DEFINED io1_GOOGLE_TEST AND BUILD_TESTING)
		if (NOT COMMAND gtest_discover_tests)
			include(GoogleTest)
		endif()

		set(test_name "google-test-${target_name}")
		if (TARGET ${test_name})
			message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: cannot create google test target ${test_name} because it already exists.")
		else()
			message(STATUS "${CMAKE_CURRENT_FUNCTION}: created google test target ${test_name}.")
		endif()

		find_package(GTest REQUIRED)
		add_executable(${test_name} ${test_sources})
		target_link_libraries(${test_name} PRIVATE ${target_name} GTest::Main)

		gtest_discover_tests(${test_name}
			WORKING_DIRECTORY $<TARGET_FILE_DIR:${test_name}>
		)
	endif()

endfunction()

set(source_group_regex "^(.*)//$")
set(source_file_properties_regex "^(.*):(.*)$")

function(apply_source_groups)
	fetch_source_groups(sources groups ${ARGN})

	foreach(source group IN ZIP_LISTS sources groups)
		source_group(NAME "${group}" FILES "${source}")
	endforeach()
endfunction()

function(fetch_source_groups out_sources out_groups)
	set(current_group_name ".")
	set(current_group_path "/.")
	
	foreach(file IN LISTS ARGN)
		if ("${file}" MATCHES "${source_group_regex}")
			set(new_group_path "${CMAKE_MATCH_1}")
		
			if (IS_ABSOLUTE "${new_group_path}")
				set(current_group_path "${new_group_path}")
			else()
				get_filename_component(current_group_path "${new_group_path}" ABSOLUTE BASE_DIR "${current_group_path}")
			endif()

			string(SUBSTRING "${current_group_path}" 1 -1 current_group_name)

		elseif (NOT "${current_group_name}" STREQUAL ".")
			list(APPEND temp_out_groups "${current_group_name}")
			if ("${file}" MATCHES "${source_file_properties_regex}")
				list(APPEND temp_out_sources "${CMAKE_MATCH_1}")
			else()
				list(APPEND temp_out_sources "${file}")
			endif()
		endif()
	endforeach()

	set(${out_sources} "${temp_out_sources}" PARENT_SCOPE)
	set(${out_groups} "${temp_out_groups}" PARENT_SCOPE)
endfunction()

# strip out groups strings and source file properties
function(fetch_source_files out_sources)
	foreach(str IN LISTS ARGN)
		if ("${str}" MATCHES "${source_group_regex}")
			continue()
		endif()
		
		if("${str}" MATCHES "${source_file_properties_regex}")
			list(APPEND temp_out_sources "${CMAKE_MATCH_1}")
		else()
			list(APPEND temp_out_sources "${str}")
		endif()
	endforeach()
	
	set(${out_sources} "${temp_out_sources}" PARENT_SCOPE)
endfunction()

function(apply_source_files_properties)
	foreach(str IN LISTS ARGN)
		if ("${str}" MATCHES "${source_group_regex}")
			continue()
		endif()
		
		parse_file_options("${str}" file options)

		cmake_parse_arguments(io1 "cpp;header" "" "" ${options})
		if (DEFINED io1_cpp)
			set_source_files_properties("${file}" PROPERTIES LANGUAGE CXX)
		endif()
		if (DEFINED io1_header)
			set_source_files_properties("${file}" PROPERTIES HEADER_FILE_ONLY ON)
		endif()
	endforeach()
endfunction()

# expects "file.c[:opt1,opt2,opt3,...]" and parse it into "file.c" and the list "opt1;opt2;opt3"
function(parse_file_options str out_file out_options)
	if ("${str}" MATCHES "${source_file_properties_regex}")
		set(${out_file} "${CMAKE_MATCH_1}" PARENT_SCOPE)
		string(REPLACE "," ";" temp_out_options "${CMAKE_MATCH_2}")
		set(${out_options} "${temp_out_options}" PARENT_SCOPE)
	else()
		set(${out_file} "${str}" PARENT_SCOPE)
		set(${out_options} "" PARENT_SCOPE)
	endif()
endfunction()

