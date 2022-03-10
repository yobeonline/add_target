cmake_minimum_required(VERSION 3.18)

if (COMMAND add_target)
	return()
endif()

function(add_target name)
	if (TARGET ${name})
		message(FATAL_ERROR "Cannot add target ${name} because it already exists.")
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
	foreach(opt IN LISTS options)
		if (DEFINED io1_${opt})
			list(APPEND found_option ${opt})
		endif()
	endforeach()
	list(LENGTH found_option found_option_count)
	if (found_option_count EQUAL 0)
		message(FATAL_ERROR "add_target: missing target type.")
	elseif (NOT found_option_count EQUAL 1)
		message(FATAL_ERROR "add_target: cannot define multiple target types.")
	endif()
	
	# target sources are the leftover values
	fetch_sources_and_groups("${io1_UNPARSED_ARGUMENTS})" source_list group_list all_sources)
	apply_source_groups("${source_list}" "${group_list}")
	apply_source_options("${all_sources}" sources)

	# create the target with the type detected by found_option
	if (DEFINED io1_STATIC)
		add_library(${name} STATIC ${sources})
	elseif(DEFINED io1_SHARED)
		add_library(${name} SHARED ${sources})
	elseif(DEFINED io1_EXECUTABLE)
		add_executable(${name} ${sources})
	elseif(DEFINED io1_HEADER_ONLY)
		add_library(${name} INTERFACE ${sources})
	endif()
	message(STATUS "add_target: created ${found_option} target ${name}.")
	

	# configure the target from the multi-value keywords
	if (DEFINED io1_INCLUDES)
		target_include_directories(${name} ${io1_INCLUDES})
	endif()
	if (DEFINED io1_DEPENDENCIES)
		target_link_libraries(${name} ${io1_DEPENDENCIES})
	endif()
	if (DEFINED io1_OPTIONS)
		target_compile_options(${name} ${io1_OPTIONS})
	endif()
	if(DEFINED io1_DEFINITIONS)
		target_compile_definitions(${name} ${io1_DEFINITIONS})
	endif()
	if(DEFINED io1_BOOST_TEST AND BUILD_TESTING)
		set(test_name "boost-test-${name}")
		if (TARGET ${test_name})
			message(FATAL_ERROR "add_target: cannot create boost test target ${test_name} because it already exists.")
		else()
			message(STATUS "add_target: created boost test target ${test_name}.")
		endif()

		find_package(Boost REQUIRED COMPONENTS unit_test_framework)
		add_executable(${test_name} ${test_sources})
		target_link_libraries(${test_name} PRIVATE ${name} Boost::unit_test_framework)

		add_test(
		    NAME ${test_name}
		    COMMAND ${test_name} --catch_system_error=yes --detect_memory_leaks --logger=JUNIT,all,junit_${test_name}.xml
		    WORKING_DIRECTORY $<TARGET_FILE_DIR:${test_name}>)

	endif()
	if(DEFINED io1_GOOGLE_TEST AND BUILD_TESTING)
		if (NOT COMMAND gtest_discover_tests)
			include(GoogleTest)
		endif()

		set(test_name "google-test-${name}")
		if (TARGET ${test_name})
			message(FATAL_ERROR "add_target: cannot create google test target ${test_name} because it already exists.")
		else()
			message(STATUS "add_target: created google test target ${test_name}.")
		endif()

		find_package(GTest REQUIRED)
		add_executable(${test_name} ${test_sources})
		target_link_libraries(${test_name} PRIVATE ${name} GTest::Main)

		gtest_discover_tests(${test_name}
			WORKING_DIRECTORY $<TARGET_FILE_DIR:${test_name}>
		)
	endif()

endfunction()

function(fetch_sources_and_groups files source_list group_list all_sources)
	set(current_group_name ".")
	set(current_group_path "/.")
	
	unset(${source_list})
	unset(${group_list})
	unset(${all_sources})

	foreach(file IN LISTS files)
		if ("${file}" MATCHES "^(.*)//$")
			set(new_group_path "${CMAKE_MATCH_1}")
		
			if (IS_ABSOLUTE "${new_group_path}")
				set(current_group_path "${new_group_path}")
			else()
				get_filename_component(current_group_path "${new_group_path}" ABSOLUTE BASE_DIR "${current_group_path}")
			endif()

			string(SUBSTRING "${current_group_path}" 1 -1 current_group_name)

		else()
			if (NOT "${current_group_name}" STREQUAL ".")
				list(APPEND temp_group_list "${current_group_name}")
				list(APPEND temp_source_list "${file}")
			endif()
			list(APPEND temp_all_sources "${file}")
		endif()
	endforeach()

	set(${all_sources} "${temp_all_sources}" PARENT_SCOPE)
	set(${source_list} "${temp_source_list}" PARENT_SCOPE)
	set(${group_list} "${temp_group_list}" PARENT_SCOPE)
endfunction()

# parse file.c[:opt1,opt2,opt3,...]
function(parse_file_options str file options)
	if ("${str}" MATCHES "^(.*):(.*)$")
		set(${file} "${CMAKE_MATCH_1}" PARENT_SCOPE)
		string(REPLACE "," ";" temp "${CMAKE_MATCH_2}") # it does not work with ${options} instead of temp, no clue why
		set(${options} "${temp}" PARENT_SCOPE)
	else()
		set(${file} "${str}" PARENT_SCOPE)
		unset(${options} PARENT_SCOPE)
	endif()
endfunction()

function(apply_source_options files sources)
	foreach(file IN LISTS files)
		parse_file_options("${file}" f opt)
		apply_file_options("${f}" "${opt}")
	endforeach()
endfunction()

# apply the provided group to each file
# asserts that files and groups have the same size.
function(apply_source_groups files groups)
	foreach(file group IN ZIP_LISTS files groups)
		source_group(NAME ${group} FILES ${file})
	endforeach()
endfunction()

# apply options provided as file.c:opt1,opt2,opt3,... if any
function(apply_file_options file options)
	cmake_parse_arguments(io1 "cpp;header" "" "" ${options})
	if (DEFINED io1_cpp)
		set_source_files_properties("${file}" PROPERTIES LANGUAGE CXX)
	endif()
	if (DEFINED io1_header)
		set_source_files_properties("${file}" PROPERTIES HEADER_FILE_ONLY ON)
	endif()
endfunction()
