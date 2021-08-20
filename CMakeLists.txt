cmake_minimum_required(VERSION 3.11)

project(tblink-rpc-hdl)

include (ExternalProject)


message("tblink-rpc-hdl: PACKAGES_DIR=${PACKAGES_DIR}")


if(NOT WIN32)
	add_compile_options(-fPIC)
endif()

set(CMAKE_CXX_STANDARD 11)

if (NOT PACKAGES_DIR)
  set(PACKAGES_DIR ${CMAKE_SOURCE_DIR}/packages)
 
  ExternalProject_Add(glog
    PREFIX glog
    SOURCE_DIR "${PACKAGES_DIR}/glog"
    CMAKE_CACHE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/glog
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
      -DBUILD_SHARED_LIBS:BOOL=OFF
      -DCMAKE_DEBUG_POSTFIX:STRING=""
  )  
 
  add_subdirectory(tests)
  add_subdirectory(${PACKAGES_DIR}/tblink-rpc-core)
endif()

foreach(CompilerFlag ${CompilerFlags})
  string(REPLACE "/MD" "/MT" ${CompilerFlag} "${${CompilerFlag}}")
  string(REPLACE "/MDd" "/MTd" ${CompilerFlag} "${${CompilerFlag}}")
endforeach()

file(GLOB tblink_rpc_hdl_SRC
  src/*.cpp
  src/*.h)

add_library(tblink_rpc_hdl ${tblink_rpc_hdl_SRC})

add_dependencies(tblink_rpc_hdl 
	glog
	)

target_include_directories(tblink_rpc_hdl PRIVATE
	${PACKAGES_DIR}/tblink-rpc-core/cpp/include
	${CMAKE_CURRENT_SOURCE_DIR}/cpp
	${CMAKE_BINARY_DIR}/glog/include
	)

install(TARGETS tblink_rpc_hdl
    DESTINATION lib
    EXPORT tblink_rpc_hdl-targets)





 