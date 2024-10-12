include_guard()

if(COMMAND io1_add_target)
	message(
		WARNING
		"io1_add_target function already exists, breaking early instead of overriding."
	)
	return()
endif()

function(io1_add_target target_name)
	if(TARGET ${target_name})
	message(
		FATAL_ERROR
		"${CMAKE_CURRENT_FUNCTION}: Cannot add target ${target_name} because it already exists."
	)
	endif()

	set(options "STATIC;SHARED;EXECUTALBE;WIN32_EXECUTABLE;HEADER_ONLY")
	set(multivalue_keywords
		"INCLUDES;DEPENDS;OPTIONS;DEFINITIONS;FEATURES;BOOST_TEST;GOOGLE_TEST"
	)

	cmake_parse_arguments(PARSE_ARGV 1 io1 "${options}" ""
						"${multivalue_keywords}")

	# options are mutually exclusive the found_options list must have length one
	# at the end of this loop
	foreach(option IN LISTS options)
	if(io1_${option})
		list(APPEND found_option ${option})
	endif()
	endforeach()

	list(LENGTH found_option found_option_count)
	if(NOT found_option_count LESS_EQUAL 1)
	message(
		FATAL_ERROR
			"${CMAKE_CURRENT_FUNCTION}: cannot define multiple target types.")
	endif()

	# target sources are the leftover values
	fetch_source_files(sources ${io1_UNPARSED_ARGUMENTS})

	# create the target with the type detected by found_option
	if(io1_STATIC)
		add_library(${target_name} STATIC)
	elseif(io1_SHARED)
		add_library(${target_name} SHARED)
	elseif(io1_EXECUTABLE)
		add_executable(${target_name})
	elseif(io1_HEADER_ONLY)
		add_library(${target_name} INTERFACE)
	elseif (io1_WIN32_EXECUTABLE)
		add_executable(${target_name} WIN32)
	else()
		add_library(${target_name})
	endif()

	# adding sources
	io1_target_add_sources(${target_name} ${io1_UNPARSED_ARGUMENTS})

	message(
		STATUS
			"${CMAKE_CURRENT_FUNCTION}: created ${found_option} target ${target_name}."
	)

	# configure the target from the multi-value keywords
	if(DEFINED io1_INCLUDES)
		target_include_directories(${target_name} ${io1_INCLUDES})
	endif()
	if(DEFINED io1_DEPENDENCIES)
		target_link_libraries(${target_name} ${io1_DEPENDENCIES})
	endif()
	if(DEFINED io1_OPTIONS)
		target_compile_options(${target_name} ${io1_OPTIONS})
	endif()
	if(DEFINED io1_DEFINITIONS)
		target_compile_definitions(${target_name} ${io1_DEFINITIONS})
	endif()
	if(DEFINED io1_FEATURES)
		target_compile_features(${target_name} ${io1_FEATURES})
	endif()

	if(DEFINED io1_BOOST_TEST)
		set(test_name "boost-test-${target_name}")
		if(TARGET ${test_name})
			message(
				FATAL_ERROR
					"${CMAKE_CURRENT_FUNCTION}: cannot create boost test target ${test_name} because it already exists."
		  )
		endif()

		find_package(
			Boost REQUIRED
			COMPONENTS unit_test_framework
			QUIET)


		add_executable(${test_name})
		io1_target_add_sources(${test_name} ${io1_BOOST_TEST})

		target_link_libraries(${test_name} PRIVATE ${target_name}
												   Boost::unit_test_framework)

		message(
			STATUS
			"${CMAKE_CURRENT_FUNCTION}: created boost test target ${test_name}.")

		if(BUILD_TESTING)
			add_test(
				NAME ${test_name}
				COMMAND ${test_name} --catch_system_error=yes --detect_memory_leaks
						--logger=JUNIT,all,junit_${test_name}.xml
				WORKING_DIRECTORY $<TARGET_FILE_DIR:${test_name}>)
		else()
			message(
				STATUS
					"${CMAKE_CURRENT_FUNCTION}: skipped declaring ${test_name} to CTest because BUILD_TESTING is false."
			)
		endif()
	endif()
	if(DEFINED io1_GOOGLE_TEST)
		if(NOT COMMAND gtest_discover_tests)
			include(GoogleTest)
		endif()

		set(test_name "google-test-${target_name}")
		if(TARGET ${test_name})
			message(
			FATAL_ERROR
				"${CMAKE_CURRENT_FUNCTION}: cannot create google test target ${test_name} because it already exists."
		)
		endif()

		find_package(GTest REQUIRED QUIET)

		add_executable(${test_name})
		io1_target_add_sources(${test_name} ${io1_GOOGLE_TEST})

		target_link_libraries(${test_name} PRIVATE ${target_name} GTest::Main)
		message(
			STATUS
				"${CMAKE_CURRENT_FUNCTION}: created google test target ${test_name}.")

		if(BUILD_TESTING)
			gtest_discover_tests(${test_name}
							   WORKING_DIRECTORY $<TARGET_FILE_DIR:${test_name}>)
		else()
			message(
			STATUS
				"${CMAKE_CURRENT_FUNCTION}: skipped declaring ${test_name} to CTest because BUILD_TESTING is false."
		  )
		endif()
	endif()

endfunction()

function(io1_target_add_sources target_name)
	set(current_group "/")
	foreach(str IN LISTS ${ARGN})
		io1_is_source_group("${str}" res)
		if(DEFINED res)
			io1_update_source_group("${current_group}" "${res}" current_group)
		else()
			io1_parse_file_options("${str}" filename options)
			io1_add_source_file(${target_name} "${filename}" ${options} "${current_group}")
		endif()
	endforeach()
endfunction()

# update a given source group
function(io1_update_source_group current_group str updated_group)
	if(IS_ABSOLUTE "${str}")
		message("${str} is absolute")
		set(${updated_group} "${str}" PARENT_SCOPE)
	else()
		message("${str} is not absolute")
		get_filename_component(temp "${str}" ABSOLUTE BASE_DIR "${current_group}")
		message("${temp} is ${str} relative to ${current_group}")
		set(${updated_group} "${temp}" PARENT_SCOPE)
	endif()

endfunction()

# adds src to target, applying options and source group
function(io1_add_source_file target file props group)
	get_target_property(type ${target} TYPE)
	if (${type} STREQUAL "INTERFACE_LIBRARY")
		target_sources(${target} INTERFACE ${file})
	else()
		target_sources(${target} PRIVATE ${file})
	endif()
	
	source_group(NAME "${group}" FILES "${file}")

	cmake_parse_arguments(io1 "cpp;header" "" "" ${props})
	if(io1_header)
		set_source_files_properties("${file}" PROPERTIES HEADER_FILE_ONLY ON)
	endif()
	if(io1_cpp)
		set_source_files_properties("${file}" TARGET_DIRECTORY ${target} PROPERTIES LANGUAGE CXX)
	endif()
endfunction()

# any string that ends with // is a source group
function(io1_is_source_group str res)
	if("${str}" MATCHES "^(.*)//$")
		set(${res} "${CMAKE_MATCH_1}" PARENT_SCOPE)
	else()
		unset(${res} PARENT_SCOPE)
	endif()
endfunction()

# expects "file.c[:opt1,opt2,opt3,...]" and parse it into "file.c" and the list
# "opt1 opt2 opt3"
function(io1_parse_file_options str out_file out_options)
	if("${str}" MATCHES "^(.*):(.*)$")
		if ("${CMAKE_MATCH_1}" STREQUAL "")
			message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: ignored orphaned source option '${CMAKE_MATCH_2}'.")
		else()
			set(${out_file}	"${CMAKE_MATCH_1}" PARENT_SCOPE)

			if("${CMAKE_MATCH_2}" STREQUAL "")
				unset(${out_options} PARENT_SCOPE)
			else()
				string(REPLACE "," ";" temp_out_options "${CMAKE_MATCH_2}")
				set(${out_options} "${temp_out_options}" PARENT_SCOPE)
			endif()
		endif()
	else()
		set(${out_file} "${str}" PARENT_SCOPE)
		unset(${out_options} PARENT_SCOPE)
	endif()
endfunction()

