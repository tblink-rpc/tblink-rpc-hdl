/*
 * TestEndpointServices.h
 *
 *  Created on: Jul 18, 2021
 *      Author: mballance
 */

#pragma once
#include "tblink_rpc/tblink_rpc.h"

using namespace tblink_rpc_core;
class TestEndpointServices : public IEndpointServices {
public:
	TestEndpointServices();

	virtual ~TestEndpointServices();

	virtual void init(IEndpoint *endpoint) override;

	/**
	 * Return command-line arguments.
	 */
	virtual std::vector<std::string> args() override;

	virtual void shutdown() override;

	virtual intptr_t add_time_cb(
			uint64_t 	time,
			intptr_t	callback_id) override;

	virtual void cancel_callback(intptr_t id) override;

private:
	IEndpoint					*m_endpoint;


};

