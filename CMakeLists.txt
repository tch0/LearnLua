#===========================================================================================================================#
#                    CMake version
#===========================================================================================================================#
cmake_minimum_required(VERSION 3.16)
message("## cmake: ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}.${CMAKE_PATCH_VERSION}")


#===========================================================================================================================#
#                    Check OS
#===========================================================================================================================#
if (APPLE)
    option(TCH_OS_MACOSX "MacOSX" ON)
    option(TCH_OS_UNIX "Unix" ON)
    message("## system: apple")

elseif(UNIX AND NOT APPLE)
    option(TCH_OS_LINUX "Liunx" ON)
    option(TCH_OS_UNIX "Unix" ON)
    message("## system: Linux")

elseif(WIN32)
    option(TCH_OS_WIN32 "Win32" ON)
    message("## system: windows")
endif()

#===========================================================================================================================#
#                    output paths
#===========================================================================================================================#
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/publish)


#===========================================================================================================================#
#                    Project
#===========================================================================================================================#
project(LearnLua
    VERSION 0.1.0
    DESCRIPTION "Learn about Lua"
    LANGUAGES CXX
)


# some directories of project
message("## proejct: ${PROJECT_NAME} ${PROJECT_VERSION}")
message("## CMAKE_BINARY_DIR: ${CMAKE_BINARY_DIR}")
message("## CMAKE_ARCHIVE_OUTPUT_DIRECTORY: ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")
message("## CMAKE_LIBRARY_OUTPUT_DIRECTORY: ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
message("## CMAKE_RUNTIME_OUTPUT_DIRECTORY: ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")


#===========================================================================================================================#
#                    System Config header
#===========================================================================================================================#
configure_file(
    ${CMAKE_SOURCE_DIR}/sysconfig/SysConfig.h.in
    ${CMAKE_BINARY_DIR}/sysconfig/SysConfig.h
)
set(sysconfig_dir ${CMAKE_BINARY_DIR}/sysconfig)


#===========================================================================================================================#
#             distinguish different compilers
#===========================================================================================================================#
set(CXX_COMPILER_IS_GCC OFF)            # gcc
set(CXX_COMPILER_IS_CLANG OFF)          # clang
set(CXX_COMPILER_IS_MSVC OFF)           # msvc
set(CXX_COMPILER_IS_CLANG_CL OFF)       # clang-cl
set(CXX_COMPILER_IS_GNU_LIKE OFF)       # gcc, clang, clang-cl
set(CXX_COMPILER_IS_GCC_CLANG OFF)      # gcc, clang
set(CXX_COMPILER_IS_CLANG_ALL OFF)      # clang, clang-cl
set(CXX_COMPILER_IS_MSVC_LIKE OFF)      # msvc, clang-cl
if (CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    set(CXX_COMPILER_IS_GCC ON)
    set(CXX_COMPILER_IS_GNU_LIKE ON)
    set(CXX_COMPILER_IS_GCC_CLANG ON)
    message("## Compiler: gcc")
elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    if (CMAKE_CXX_SIMULATE_ID MATCHES "MSVC" AND CMAKE_CL_64)
        set(CXX_COMPILER_IS_CLANG_CL ON)
        set(CXX_COMPILER_IS_GNU_LIKE ON)
        set(CXX_COMPILER_IS_CLANG_ALL ON)
        set(CXX_COMPILER_IS_MSVC_LIKE ON)
        message("## Compiler: clang-cl")
    else ()
        set(CXX_COMPILER_IS_CLANG ON)
        set(CXX_COMPILER_IS_GNU_LIKE ON)
        set(CXX_COMPILER_IS_GCC_CLANG ON)
        set(CXX_COMPILER_IS_CLANG_ALL ON)
        message("## Compiler: clang")
    endif ()
elseif (CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    set(CXX_COMPILER_IS_MSVC ON)
    set(CXX_COMPILER_IS_MSVC_LIKE ON)
    message("## Compiler: msvc")
else ()
    message(FATAL_ERROR "Unsupported Compiler!")
endif ()


#===========================================================================================================================#
#                    System Config header
#===========================================================================================================================#
configure_file(
    ${CMAKE_SOURCE_DIR}/sysconfig/SysConfig.h.in
    ${CMAKE_BINARY_DIR}/sysconfig/SysConfig.h
)
set(sysconfig_dir ${CMAKE_BINARY_DIR}/sysconfig)


#===========================================================================================================================#
#            compiler flags
#===========================================================================================================================#
# general compiler flags, C++ standard, warnings, etc.
add_library(general_cxx_compiler_flags INTERFACE)
# C++ standard
target_compile_features(general_cxx_compiler_flags INTERFACE cxx_std_20)
# warning options for different toolchain
target_compile_options(general_cxx_compiler_flags INTERFACE
    $<$<BOOL:${CXX_COMPILER_IS_GNU_LIKE}>:$<BUILD_INTERFACE:
        -Wall
        -Wextra
        -Wshadow
        -pedantic-errors
        -Wformat=2
        -Wno-unused-parameter
    >>
    $<$<BOOL:${CXX_COMPILER_IS_MSVC}>:$<BUILD_INTERFACE:
        /W3
    >>
)

# extra compiler flags, like for inevitable annoying third-party library headers' warnings
add_library(extra_cxx_compiler_flags INTERFACE)
target_compile_options(extra_cxx_compiler_flags INTERFACE
    # "$<${CXX_COMPILER_IS_GNU_LIKE}:$<BUILD_INTERFACE:-Wno-volatile>>"
)


#===========================================================================================================================#
#            macros that help to collect headers and sources
#===========================================================================================================================#
# collect header directories and header files
macro(collect_header_files dir return_dir_list return_header_list)
    set(header_list "")
    file(GLOB_RECURSE header_list
        ${dir}/*.h
        ${dir}/*.hpp
    )
    set(dir_list "")
    foreach(file_path ${header_list})
        get_filename_component(dir_path ${file_path} PATH)
        set(dir_list ${dir_list} ${dir_path})
    endforeach()
    list(REMOVE_DUPLICATES dir_list)
    set(${return_dir_list} ${dir_list})
    set(${return_header_list} ${header_list})
endmacro()

macro(collect_sources_files dir return_list)
    file(GLOB_RECURSE ${return_list}
        ${dir}/*.cpp
        ${dir}/*.cc
        ${dir}/*.cxx
    )
endmacro()


#===========================================================================================================================#
#            Unity building setting
#===========================================================================================================================#
set (CMAKE_UNITY_BUILD_BATCH_SIZE 100)
option(OPTION_UNITY_BUILD "global unity build setting" OFF)
message("## Unity build: ${OPTION_UNITY_BUILD}, Batch size: ${CMAKE_UNITY_BUILD_BATCH_SIZE}")


#===========================================================================================================================#
#            3rd party libraries
#===========================================================================================================================#
# 3rdparty libraries
list(APPEND 3rdparty_libs "")

set(3rdparty_include_dir ${CMAKE_SOURCE_DIR}/3rdparty-install/include)
set(3rdparty_lib_dir ${CMAKE_SOURCE_DIR}/3rdparty-install/lib)


#===========================================================================================================================#
#  check format is supported or not on your compiler, use fmt library if not supported yet!
#===========================================================================================================================#
add_library(format_bridge INTERFACE)
include(CheckCXXSourceCompiles)
check_cxx_source_compiles("#include <format>\nint main() { return 0; }" format_supported)
if (NOT format_supported)
    target_include_directories(format_bridge INTERFACE ${CMAKE_SOURCE_DIR}/3rdparty-install/include/format_bridge)
    message("## <format> is not support on your compiler yet, use fmt library instead!")
endif()


#===========================================================================================================================#
#            copy necessary files after every build (only when different)
#===========================================================================================================================#
function(copy_dir_to_target_file_dir target dirname source)
    if (CMAKE_VERSION VERSION_GREATER_EQUAL 3.26)
        add_custom_command(TARGET ${target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different ${source} $<TARGET_FILE_DIR:${target}>/${dirname} # copy_directory_if_different need cmake 3.26
            COMMAND_EXPAND_LISTS
        )
    elseif()
            add_custom_command(TARGET ${target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${source} $<TARGET_FILE_DIR:${target}>/${dirname}
            COMMAND_EXPAND_LISTS
        )
    endif()
endfunction()


#===========================================================================================================================#
#            functions for defining instance
#===========================================================================================================================#
# define instance from sources
# usage example: (define_instance_from_sources test test.cpp test.h hello.cpp)
function(define_instance_from_sources target ...)
    set(sources ${ARGV})
    list(POP_FRONT sources)
    add_executable(${target} ${sources})
    target_include_directories(${target}
        PRIVATE
            ${sysconfig_dir}
            ${3rdparty_include_dir}
    )
    target_link_libraries(${target}
        PRIVATE
            lua
            general_cxx_compiler_flags
            extra_cxx_compiler_flags
            format_bridge
            ${3rdparty_libs}
    )
    target_link_directories(${target}
        PRIVATE
            ${3rdparty_lib_dir}
    )
    set_target_properties(${target} PROPERTIES VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
    if (${OPTION_UNITY_BUILD})
        set_target_properties(${target} PROPERTIES UNITY_BUILD ON) # UNITY building
    endif()
    source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${sources})
endfunction()

#define instance from directories
function(define_instance_from_directories target ...)
    # collect all sources/headers/header directories
    set(dirs ${ARGV})
    list(POP_FRONT dirs)
    set(all_sources "")
    set(all_headers "")
    set(all_header_dirs "")
    foreach(dir ${dirs})
        collect_header_files(${dir} current_header_dirs current_headers)
        collect_sources_files(${dir} current_sources)
        list(APPEND all_sources ${current_sources})
        list(APPEND all_headers ${current_headers})
        list(APPEND all_header_dirs ${current_header_dirs})
    endforeach()
    # target definition
    add_executable(${target} ${all_sources} ${all_headers})
    target_include_directories(${target}
        PRIVATE
            ${all_header_dirs}
            ${sysconfig_dir}
            ${3rdparty_include_dir}
    )
    target_link_libraries(${target}
        PRIVATE
            lua
            general_cxx_compiler_flags
            extra_cxx_compiler_flags
            format_bridge
            ${3rdparty_libs}
    )
    target_link_directories(${target}
        PRIVATE
            ${3rdparty_lib_dir}
    )
    set_target_properties(${target} PROPERTIES VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
    if (${OPTION_UNITY_BUILD})
        set_target_properties(${target} PROPERTIES UNITY_BUILD ON) # UNITY building
    endif()
    source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${all_sources} ${all_headers})
endfunction()


#===========================================================================================================================#
#            targets / subdirectories
#===========================================================================================================================#
# lua
add_subdirectory(lua)
# instances: to be added
