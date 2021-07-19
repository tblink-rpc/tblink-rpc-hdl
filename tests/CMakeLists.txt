

ExternalProject_Add(GOOGLETEST
        PREFIX googletest
        SOURCE_DIR "${PACKAGES_DIR}/googletest"
    CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/googletest
        -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
        -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
        -DCMAKE_C_COMPILER_ID:STRING=${CMAKE_C_COMPILER_ID}
        -DCMAKE_CXX_COMPILER_ID:STRING=${CMAKE_CXX_COMPILER_ID}
        -DCMAKE_SYSTEM_NAME:STRING=${CMAKE_SYSTEM_NAME}
        )
       
file(GLOB tblink_rpc_hdl_testlauncher_SRC
	launcher/*.cpp
	launcher/*.h)

add_library(
	tblink_rpc_hdl_testlauncher 
	SHARED 
	${tblink_rpc_hdl_testlauncher_SRC})

target_include_directories(
	tblink_rpc_hdl_testlauncher
	PRIVATE
	${CMAKE_CURRENT_SOURCE_DIR}/../src
	${PACKAGES_DIR}/tblink-rpc-core/cpp/include
	)

target_link_libraries(
	tblink_rpc_hdl_testlauncher
	-Wl,--whole-archive
	tblink_rpc_hdl
	tblink_rpc_core
	-Wl,--no-whole-archive
	)
	
add_dependencies(tblink_rpc_hdl_testlauncher
	tblink_rpc_core
	)

file(GLOB tblink_rpc_hdl_testrunner_SRC
	src/*.cpp
	src/*.h)

add_executable(
	tblink_rpc_hdl_testrunner
	${tblink_rpc_hdl_testrunner_SRC})

target_include_directories(
	tblink_rpc_hdl_testrunner
	PRIVATE
	${PACKAGES_DIR}/googletest/googletest/include
	${PACKAGES_DIR}/tblink-rpc-core/cpp/include
	)

target_link_directories(
	tblink_rpc_hdl_testrunner
	PRIVATE
	${CMAKE_BINARY_DIR}/googletest/lib
	)

target_link_libraries(
	tblink_rpc_hdl_testrunner
	-Wl,--whole-archive
	tblink_rpc_core
	-Wl,--no-whole-archive
	gtest
	gtest_main
	pthread
	)


add_dependencies(tblink_rpc_hdl_testrunner
	GOOGLETEST
	)

