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

  set (TBLINK_RPC_CORE_DIR "${PACKAGES_DIR}/tblink-rpc-core")
 
  add_subdirectory(tests)
else()
 
endif()

if (TBLINK_RPC_CORE_DIR)
  add_subdirectory(${TBLINK_RPC_CORE_DIR} ${CMAKE_BINARY_DIR}/tblink-rpc-core)
endif()

foreach(CompilerFlag ${CompilerFlags})
  string(REPLACE "/MD" "/MT" ${CompilerFlag} "${${CompilerFlag}}")
  string(REPLACE "/MDd" "/MTd" ${CompilerFlag} "${${CompilerFlag}}")
endforeach()

file(GLOB tblink_rpc_hdl_dpi_SRC
  src/dpi/*.cpp
  src/dpi/*.h)
 
list(APPEND tblink_rpc_hdl_dpi_SRC
  src/vpi/vpi_api.cpp
  src/vpi/VpiHandle.cpp
  )
 
file(GLOB tblink_rpc_hdl_vpi_SRC
  src/vpi/*.cpp
  src/vpi/*.h)

# add_library(tblink_rpc_hdl_static ${tblink_rpc_hdl_SRC})
# 
# target_include_directories(tblink_rpc_hdl_static PRIVATE
# 	${PACKAGES_DIR}/tblink-rpc-core/cpp/include
# 	${PACKAGES_DIR}/tblink-rpc-core/cpp
# 	${CMAKE_CURRENT_SOURCE_DIR}/cpp
# 	${CMAKE_BINARY_DIR}/glog/include
# 	)
# 
# install(TARGETS tblink_rpc_hdl_static
#     DESTINATION lib
#     EXPORT tblink_rpc_hdl-targets)
    
add_library(tblink_rpc_hdl_dpi SHARED ${tblink_rpc_hdl_dpi_SRC})
target_include_directories(tblink_rpc_hdl_dpi PRIVATE
	${PACKAGES_DIR}/tblink-rpc-core/cpp/include
	${PACKAGES_DIR}/tblink-rpc-core/cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/vpi
	)

add_dependencies(tblink_rpc_hdl_dpi
	tblink_rpc_core
	)

target_link_libraries(
	tblink_rpc_hdl_dpi
	-Wl,--whole-archive
	tblink_rpc_core
	-Wl,--no-whole-archive
	)

add_library(tblink_rpc_hdl_vpi SHARED ${tblink_rpc_hdl_vpi_SRC})
target_include_directories(tblink_rpc_hdl_vpi PRIVATE
	${PACKAGES_DIR}/tblink-rpc-core/cpp/include
	${PACKAGES_DIR}/tblink-rpc-core/cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/vpi
	)

add_dependencies(tblink_rpc_hdl_vpi
	tblink_rpc_core
	)

target_link_libraries(
	tblink_rpc_hdl_vpi
	-Wl,--whole-archive
	tblink_rpc_core
	-Wl,--no-whole-archive
	)

 
