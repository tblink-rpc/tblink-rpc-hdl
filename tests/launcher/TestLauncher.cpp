/*
 * TestLauncher.cpp
 *
 *  Created on: Jul 18, 2021
 *      Author: mballance
 */

#include "TestLauncher.h"
#include "tblink_rpc/tblink_rpc.h"

#ifndef _WIN32
#include <pthread.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <netdb.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <sys/stat.h>
#include <fcntl.h>
static const char PS = ':';
#else
#include <winsock2.h>
static const char PS = ';';
#endif
#include <spawn.h>
#include <string.h>

extern char **environ;

TestLauncher::TestLauncher() {
	// TODO Auto-generated constructor stub

}

TestLauncher::~TestLauncher() {
	// TODO Auto-generated destructor stub
}

IEndpoint *TestLauncher::launch(
			IEndpointServices		*services) {
	bool ret = true;
	std::string runner;
	IFactory *factory = tblink_rpc_get_factory();

	// First, locate the test runner
	const char *tblink_runner = getenv("TBLINK_TEST_RUNNER");
	const char *gtest_filter = getenv("GTEST_FILTER");

	if (!tblink_runner || tblink_runner == "") {
		fprintf(stdout, "Error: failed to find test runner\n");
		return 0;
	} else {
		runner = tblink_runner;
	}

	// Create the socket server
	struct sockaddr_in serv_addr;

	int32_t srv_socket = socket(AF_INET, SOCK_STREAM, 0);

    memset(&serv_addr, 0, sizeof(serv_addr));

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    serv_addr.sin_port = 0;

    if ((bind(srv_socket, (struct sockaddr *)&serv_addr, sizeof(serv_addr))) < 0) {
    	perror("Error binding");
    }

    socklen_t size = sizeof(serv_addr);
    getsockname(srv_socket, (struct sockaddr *) &serv_addr, &size);

    fprintf(stdout, "port: %d\n", serv_addr.sin_port);
    fflush(stdout);
//    cd.port = serv_addr.sin_port;
//    ASSERT_EQ(pthread_create(&thread, 0, &client_f, &cd), 0);

    listen(srv_socket, 1);

	// Spawn the interpreter
   	pid_t pid;
    {
    	std::vector<std::string> args;

    	char tmp[16], hostname[16];

//    	args.push_back("valgrind");
//    	args.push_back("--tool=memcheck");

    	sprintf(tmp, "%d", ntohs(serv_addr.sin_port));
    	args.push_back(runner);
    	args.push_back(tmp);
    	if (gtest_filter) {
    		char *gtest_filter_arg = (char *)alloca(strlen(gtest_filter)+64);
    		sprintf(gtest_filter_arg, "--gtest_filter=%s", gtest_filter);
    		args.push_back(gtest_filter_arg);
    	}
    	char **argv = (char **)alloca(sizeof(char *)*(args.size()+1));

    	for (uint32_t i=0; i<args.size(); i++) {
    		argv[i] = strdup(args.at(i).c_str());
    	}
    	argv[args.size()] = 0;

    	int status = posix_spawnp(&pid, argv[0], 0, 0, (char *const *)argv, environ);

    	if (status != 0) {
    		fprintf(stdout, "Error: Failed to launch test \"%s\"\n", runner.c_str());
    		return 0;
    	}
    }

	// Wait for a connection, or for
	// the interpreter process to exit
   	int32_t conn_socket = -1;
    {
    	// Wait for a bit to see if we get a connect request
    	fd_set rfds;
    	struct timeval tv;
    	int retval;


    	/*
    	 * Wait for a connect request for 10ms
    	 * at a time. * Wait up to five seconds total
    	 */
    	for (uint32_t i=0; i<500; i++) {
    		tv.tv_sec = 0;
    		tv.tv_usec = 10000;

    		FD_ZERO(&rfds);
    		FD_SET(srv_socket, &rfds);

    		retval = select(srv_socket+1, &rfds, 0, 0, &tv);

    		if (retval > 0) {
    			break;
    		} else {
    			// Check that the process is still alive
    			int status;
    			retval = ::waitpid(pid, &status, WNOHANG);

    			// If the process either doesn't exist
    			// or has terminated, then bail out early
    			if (retval != 0) {
    				fprintf(stdout, "Note: Python process has terminated\n");
    				retval = -1;
    				break;
    			}
    		}
    	}

    	if (retval > 0) {
    		unsigned int clilen = sizeof(serv_addr);
    		conn_socket = accept(srv_socket, (struct sockaddr *)&serv_addr, &clilen);
    	}
    }

    if (conn_socket == -1) {
    	fprintf(stdout, "Error: accept failed\n");
    	return 0;
    }

    fprintf(stdout, "Note: socket %d\n", conn_socket);

#ifdef _WIN32
   unsigned long mode = 0;
   ioctlsocket(m_conn_socket, FIONBIO, &mode);
#else
   int flags = fcntl(conn_socket, F_GETFL, 0);
   fcntl(conn_socket, F_SETFL, (flags | O_NONBLOCK));
#endif


   {
	   int flag = 1;

	   ::setsockopt(
			   conn_socket,
			   IPPROTO_TCP,
			   TCP_NODELAY,
			   (char *)&flag,
			   sizeof(int));

   }

   ITransport *transport = factory->mkSocketTransport(pid, conn_socket);
   IEndpoint *endpoint = factory->mkJsonRpcEndpoint(
		   transport,
		   	  services);

    fprintf(stdout, "connected\n");

    return endpoint;
}

static TestLauncher prvLauncher;

extern "C" ILaunch *tblink_rpc_hdl_launcher() {
	return &prvLauncher;
}
