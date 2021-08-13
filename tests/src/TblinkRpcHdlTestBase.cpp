/*
 * TblinkRpcHdlTestBase.cpp
 *
 *  Created on: Jul 18, 2021
 *      Author: mballance
 */

#include "TblinkRpcHdlTestBase.h"
#include "TestEndpointServices.h"
#include "JsonRpcEndpoint.h"
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
#include "glog/logging.h"
#include <stdint.h>

TblinkRpcHdlTestBase::TblinkRpcHdlTestBase() {
	m_waiting_shutdown = false;
	m_have_shutdown = false;

}

TblinkRpcHdlTestBase::~TblinkRpcHdlTestBase() {
	// TODO Auto-generated destructor stub
}

void TblinkRpcHdlTestBase::SetUp() {
	fprintf(stdout, "SetUp\n");
	std::vector<std::string> cmdline = ::testing::internal::GetArgvs();
	int32_t port = -1;

	FLAGS_log_dir = ".";
	google::InitGoogleLogging(cmdline.at(0).c_str());


	// Take the first non-option argument
	for (uint32_t i=1; i<cmdline.size(); i++) {
		if (cmdline.at(i)[0] != '-' && cmdline.at(i)[0] != '+') {
			port = strtol(cmdline.at(i).c_str(), 0, 0);
		}
	}

	if (port == -1) {
		FAIL() << "no port argument specified";
	}

	int sockfd = socket(AF_INET, SOCK_STREAM, 0);
	struct sockaddr_in serv_addr;

	memset(&serv_addr, 0, sizeof(serv_addr));
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
	serv_addr.sin_port = htons(port);

	if (connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
		FAIL() << "failed to connect";
	}

	fprintf(stdout, "Note: connected\n");
	fflush(stdout);

	{
	   int flag = 1;

	   ::setsockopt(
		   sockfd,
		   IPPROTO_TCP,
		   TCP_NODELAY,
		   (char *)&flag,
		   sizeof(int));
	}


	IFactory *factory = tblink_rpc_get_factory();
	m_transport = factory->mkSocketTransport(0, sockfd);
	m_endpoint = factory->mkJsonRpcEndpoint(this);
	dynamic_cast<JsonRpcEndpoint *>(m_endpoint)->init(m_transport);

    for (std::vector<std::string>::const_iterator
    		it=cmdline.begin();
    		it!=cmdline.end(); it++) {

    	fprintf(stdout, "arg: %s\n", it->c_str());
    }


}

// Tears down the test fixture.
void TblinkRpcHdlTestBase::TearDown() {
	fprintf(stdout, "--> TearDown\n");
	fflush(stdout);

	m_endpoint->shutdown();

	m_waiting_shutdown = true;

	while (!m_have_shutdown && m_endpoint->yield() != -1) {
		;
	}

	m_waiting_shutdown = false;

	fprintf(stdout, "<-- TearDown\n");
	fflush(stdout);
}

bool TblinkRpcHdlTestBase::init() {
    if (!m_endpoint->build_complete()) {
    	return false;
    }

    if (m_post_build_hook) {
    	m_post_build_hook();
    }

    if (!m_endpoint->connect_complete()) {
    	return false;
    }

    if (m_post_connect_hook) {
    	m_post_connect_hook();
    }

    return true;
}

void TblinkRpcHdlTestBase::init(IEndpoint *endpoint) {
	m_endpoint = endpoint;
}

/**
 * Return command-line arguments.
 */
std::vector<std::string> TblinkRpcHdlTestBase::args() {
	return ::testing::internal::GetArgvs();
}

void TblinkRpcHdlTestBase::shutdown() {
	m_have_shutdown = true;
	if (!m_waiting_shutdown) {
		FAIL() << "received unexpected shutdown";
		exit(1);
	}
}

int32_t TblinkRpcHdlTestBase::add_time_cb(
		uint64_t 		time,
		intptr_t		callback_id) {
	return -1;
}

void TblinkRpcHdlTestBase::cancel_callback(intptr_t id) {

}

TEST_F(TblinkRpcHdlTestBase, smoke) {
	fprintf(stdout, "smoke\n");

	m_endpoint->build_complete();

	IInterfaceInst *t0=0, *t1=0;

	fprintf(stdout, "Test: post-build-complete\n");
	fflush(stdout);
	for (std::vector<IInterfaceInst*>::const_iterator
			it=m_endpoint->getInterfaceInsts().begin();
			it!=m_endpoint->getInterfaceInsts().end(); it++) {
		if ((*it)->name() == "smoke.t0") {
			t0 = *it;
		} else if ((*it)->name() == "smoke.t1") {
			t1 = *it;
		}
		fprintf(stdout, "InterfaceInst: %s\n", (*it)->name().c_str());
	}
	fprintf(stdout, "Test: post-print-interfaces\n");
	fflush(stdout);

	ASSERT_TRUE(t0);
	ASSERT_TRUE(t1);

	IMethodType *inc = t0->type()->findMethod("inc");
	ASSERT_TRUE(inc);

	m_endpoint->connect_complete();

	IParamValVector *params = t0->mkVector();
	params->push_back(t0->mkValIntS(1));
	IParamValUP ret(t0->invoke_nb(
			inc,
			params));

#ifdef UNDEFINED
	IMethodType *inc_b = t0->type()->findMethod("inc_b");

	if (inc_b) {
		fprintf(stdout, "Have inc_b\n");
		IParamValVector *params = t0->mkVector();
		params->push_back(t0->mkValIntS(1));
		volatile bool done = false;
		t0->invoke(
				inc_b,
				params,
				[&](IParamVal *retval) { done = true; });

		while (!done) {
			fprintf(stdout, "--> run_until_event\n");
			fflush(stdout);
			int ret = 0;
			if ((ret=m_endpoint->run_until_event()) == -1) {
				break;
			}
			fprintf(stdout, "<-- run_until_event %d\n", ret);
			fflush(stdout);
		}

		ASSERT_EQ(done, true);

	} else {
		fprintf(stdout, "No inc_b\n");
	}
#endif

	int32_t time_precision = m_endpoint->time_precision();

	uint32_t scale = 1;
	while (time_precision < -9) {
		scale *= 1000;
		time_precision += 3;
	}

	for (uint32_t i=0; i<100; i++) {
		fprintf(stdout, "--> Iteration %d\n", i);
		fflush(stdout);
		volatile bool hit = false;
		fprintf(stdout, "--> add_callback\n");
		intptr_t callback_id = m_endpoint->add_time_callback(
				scale*10, [&]() { hit = true;});
		fprintf(stdout, "<-- add_callback %lld\n", callback_id);
		fflush(stdout);

		// Poll until the callback is hit
		int ret = 0;
		while (!hit) {
			fprintf(stdout, "--> run_until_event\n");
			if ((ret=m_endpoint->run_until_event()) == -1) {
				break;
			}
			fprintf(stdout, "<-- run_until_event %d\n", ret);
		}

		fprintf(stdout, "[%lld] Done: hit=%d\n",
				m_endpoint->time(), hit);
		ASSERT_NE(ret, -1);
		ASSERT_EQ(hit, true);
		ASSERT_EQ(m_endpoint->time(), (i+1)*10*scale);

		fprintf(stdout, "<-- Iteration %d\n", i);
		fflush(stdout);
	}

}


TEST_F(TblinkRpcHdlTestBase, single_time_cb) {
	m_endpoint->build_complete();
	m_endpoint->connect_complete();

	int32_t time_precision = m_endpoint->time_precision();

	uint32_t scale = 1;
	while (time_precision < -9) {
		scale *= 1000;
		time_precision += 3;
	}

	fprintf(stdout, "scale: %d\n", scale);
	fflush(stdout);

	for (uint32_t i=0; i<100; i++) {
		volatile bool hit = false;
		intptr_t callback_id = m_endpoint->add_time_callback(
				scale*10, [&]() { hit = true;});

		// Poll until the callback is hit
		int ret = 0;
		ret=m_endpoint->run_until_event();

		fprintf(stdout, "[%lld] Done: hit=%d\n",
				m_endpoint->time(), hit);
		ASSERT_NE(ret, -1);
		ASSERT_EQ(hit, true);
		ASSERT_EQ(m_endpoint->time(), (i+1)*10*scale);
	}
}

TEST_F(TblinkRpcHdlTestBase, dual_layer_time_cb) {
	m_endpoint->build_complete();
	m_endpoint->connect_complete();

	volatile bool cb1_hit = false;
	intptr_t callback1_id = m_endpoint->add_time_callback(
			10*100, [&]() { cb1_hit = true;});

	for (uint32_t i=0; i<100; i++) {
		volatile bool hit = false;
		intptr_t callback_id = m_endpoint->add_time_callback(
				10, [&]() { hit = true;});

		// Poll until the callback is hit
		int ret = 0;

		// cb1 might be triggered first
		while (!hit) {
			ret=m_endpoint->run_until_event();
		}

		fprintf(stdout, "[%lld] Done: hit=%d\n",
				m_endpoint->time(), hit);
		ASSERT_NE(ret, -1);
		ASSERT_EQ(hit, true);
		ASSERT_EQ(m_endpoint->time(), (i+1)*10);
	}

	if (!cb1_hit) {
		int ret=m_endpoint->run_until_event();
		ASSERT_NE(ret, -1);
	}
	ASSERT_EQ(cb1_hit, true);
	ASSERT_EQ(m_endpoint->time(), 100*10);
}
