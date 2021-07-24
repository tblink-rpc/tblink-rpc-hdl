/*
 * TestEndpointServices.cpp
 *
 *  Created on: Jul 18, 2021
 *      Author: mballance
 */

#include "TestEndpointServices.h"
#include "gtest/gtest.h"

TestEndpointServices::TestEndpointServices() : m_endpoint(0) {
	// TODO Auto-generated constructor stub

}

TestEndpointServices::~TestEndpointServices() {
	// TODO Auto-generated destructor stub
}

void TestEndpointServices::init(IEndpoint *endpoint) {
	m_endpoint = endpoint;
}

/**
 * Return command-line arguments.
 */
std::vector<std::string> TestEndpointServices::args() {
	return ::testing::internal::GetArgvs();
}

void TestEndpointServices::shutdown() {
	FAIL() << "received unexpected shutdown";
}

int32_t TestEndpointServices::add_time_cb(
		uint64_t		time,
		intptr_t		callback_id) {
	return -1;
}

void TestEndpointServices::cancel_callback(intptr_t id) {

}


