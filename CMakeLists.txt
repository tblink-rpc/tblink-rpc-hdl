cmake_minimum_required(VERSION 3.11)

project(tblink-rpc-hdl)

include (ExternalProject)

if (NOT PACKAGES_DIR)
  set(PACKAGES_DIR ${CMAKE_SOURCE_DIR}/packages)
endif()

message("tblink-rpc-hdl: PACKAGES_DIR=${PACKAGES_DIR}")


if(NOT WIN32)
	add_compile_options(-fPIC)
endif()

set(CMAKE_CXX_STANDARD 11)


foreach(CompilerFlag ${CompilerFlags})
  string(REPLACE "/MD" "/MT" ${CompilerFlag} "${${CompilerFlag}}")
  string(REPLACE "/MDd" "/MTd" ${CompilerFlag} "${${CompilerFlag}}")
endforeach()

file(GLOB tblink_rpc_hdl_SRC
  src/*.cpp
  src/*.h)

add_library(tblink_rpc_hdl ${tblink_rpc_hdl_SRC})

target_include_directories(tblink_rpc_hdl PRIVATE
	${PACKAGES_DIR}/tblink-rpc-core/cpp/include
	${CMAKE_CURRENT_SOURCE_DIR}/cpp)

install(TARGETS tblink_rpc_hdl
    DESTINATION lib
    EXPORT tblink_rpc_hdl-targets)

 