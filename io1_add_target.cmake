include_guard()

if(COMMAND add_target)
  message(
    WARNING
      "add_target function already exists, breaking early instead of overriding."
  )
  return()
endif()

function(add_target target_name)
  if(TARGET ${target_name})
    message(
      FATAL_ERROR
        "${CMAKE_CURRENT_FUNCTION}: Cannot add target ${target_name} because it already exists."
    )
  endif()

  set(options "STATIC;SHARED;EXECUTALBE;WIN32_EXECUTABLE;HEADER_ONLY")
  set(multivalue_keywords
      "INCLUDES;DEPENDENCIES;OPTIONS;DEFINITIONS;FEATURES;BOOST_TEST;GOOGLE_TEST"
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
    add_library(${target_name} STATIC ${sources})
  elseif(io1_SHARED)
    add_library(${target_name} SHARED ${sources})
  elseif(io1_EXECUTABLE)
    add_executable(${target_name} ${sources})
  elseif(io1_HEADER_ONLY)
    add_library(${target_name} INTERFACE ${sources})
  elseif (io1_WIN32_EXECUTABLE)
    add_executable(${target_name} WIN32 ${sources})
  else()
    add_library(${target_name} ${sources})
  endif()

  # apply source files properties and groups
  apply_source_groups(${io1_UNPARSED_ARGUMENTS})
  apply_source_files_properties(${io1_UNPARSED_ARGUMENTS})

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

    fetch_source_files(test_sources ${io1_BOOST_TEST})

    add_executable(${test_name} ${test_sources})

    apply_source_groups(${io1_BOOST_TEST})
    apply_source_files_properties(${io1_BOOST_TEST})

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

    fetch_source_files(test_sources ${io1_GOOGLE_TEST})

    add_executable(${test_name} ${test_sources})

    apply_source_groups(${io1_GOOGLE_TEST})
    apply_source_files_properties(${io1_GOOGLE_TEST})

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

set(source_group_regex "^(.*)//$")
set(source_file_properties_regex "^(.+):?(.*)$")

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
    if("${file}" MATCHES "${source_group_regex}")
      set(new_group_path "${CMAKE_MATCH_1}")

      if(IS_ABSOLUTE "${new_group_path}")
        set(current_group_path "${new_group_path}")
      else()
        get_filename_component(current_group_path "${new_group_path}" ABSOLUTE
                               BASE_DIR "${current_group_path}")
      endif()

      string(SUBSTRING "${current_group_path}" 1 -1 current_group_name)

    elseif(NOT "${current_group_name}" STREQUAL ".")
      list(APPEND temp_out_groups "${current_group_name}")
      if("${file}" MATCHES "${source_file_properties_regex}")
        list(APPEND temp_out_sources "${CMAKE_MATCH_1}")
      else()
        list(APPEND temp_out_sources "${file}")
      endif()
    endif()
  endforeach()

  set(${out_sources}
      "${temp_out_sources}"
      PARENT_SCOPE)
  set(${out_groups}
      "${temp_out_groups}"
      PARENT_SCOPE)
endfunction()

# strip out groups strings and source file properties
function(fetch_source_files out_sources)
  foreach(str IN LISTS ARGN)
    if("${str}" MATCHES "${source_group_regex}")
      continue()
    endif()

    if("${str}" MATCHES "${source_file_properties_regex}")
      list(APPEND temp_out_sources "${CMAKE_MATCH_1}")
    else()
      list(APPEND temp_out_sources "${str}")
    endif()
  endforeach()

  set(${out_sources}
      "${temp_out_sources}"
      PARENT_SCOPE)
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
		set(${res} "TRUE" PARENT_SCOPE)
	else()
		set(${res} "FALSE" PARENT_SCOPE)
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

