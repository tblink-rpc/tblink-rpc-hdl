cmake_minimum_required(VERSION 3.11)

project(tblink-rpc-hdl)

include (ExternalProject)


message("tblink-rpc-hdl: PACKAGES_DIR=${PACKAGES_DIR}")

if(NOT WIN32)
	add_compile_options(-fPIC)
endif()

set(CMAKE_CXX_STANDARD 11)

#********************************************************************
#* Configure dependencies
#********************************************************************
if (NOT PACKAGES_DIR)
  set(PACKAGES_DIR ${CMAKE_SOURCE_DIR}/packages)

  set (GLOG_DIR "${PACKAGES_DIR}/glog") 
  set (TBLINK_RPC_CORE_DIR "${PACKAGES_DIR}/tblink-rpc-core")
 
  add_subdirectory(tests)
else()
 
endif()

if (GLOG_DIR)
  ExternalProject_Add(GLOG
    PREFIX glog
    SOURCE_DIR "${GLOG_DIR}"
    CMAKE_CACHE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/glog
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
      -DBUILD_SHARED_LIBS:BOOL=OFF
      -DCMAKE_DEBUG_POSTFIX:STRING=""
  )  
endif()

if (TBLINK_RPC_CORE_DIR)
  add_subdirectory(${TBLINK_RPC_CORE_DIR} ${CMAKE_BINARY_DIR}/tblink-rpc-core)
endif()

foreach(CompilerFlag ${CompilerFlags})
  string(REPLACE "/MD" "/MT" ${CompilerFlag} "${${CompilerFlag}}")
  string(REPLACE "/MDd" "/MTd" ${CompilerFlag} "${${CompilerFlag}}")
endforeach()

file(GLOB tblink_rpc_hdl_SRC
  src/*.cpp
  src/*.h)

add_library(tblink_rpc_hdl_static ${tblink_rpc_hdl_SRC})

add_dependencies(tblink_rpc_hdl_static 
	GLOG
	)

target_include_directories(tblink_rpc_hdl_static PRIVATE
	${PACKAGES_DIR}/tblink-rpc-core/cpp/include
	${CMAKE_CURRENT_SOURCE_DIR}/cpp
	${CMAKE_BINARY_DIR}/glog/include
	)

install(TARGETS tblink_rpc_hdl_static
    DESTINATION lib
    EXPORT tblink_rpc_hdl-targets)
    
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
	set(libglog glogd)
else()
	set(libglog glog)
endif()    

add_library(tblink_rpc_hdl SHARED ${tblink_rpc_hdl_SRC})
target_include_directories(tblink_rpc_hdl PRIVATE
	${PACKAGES_DIR}/tblink-rpc-core/cpp/include
	${CMAKE_CURRENT_SOURCE_DIR}/cpp
	${CMAKE_BINARY_DIR}/glog/include
	)
add_dependencies(tblink_rpc_hdl 
	tblink_rpc_core
	GLOG
	)
target_link_directories(
	tblink_rpc_hdl
	PRIVATE
	${CMAKE_BINARY_DIR}/glog/lib64
	)
target_link_libraries(
	tblink_rpc_hdl
	-Wl,--whole-archive
	tblink_rpc_core
	-Wl,--no-whole-archive
	${libglog}
	)


 
