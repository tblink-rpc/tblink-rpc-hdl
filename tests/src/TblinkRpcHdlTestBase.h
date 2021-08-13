/*
 * TblinkRpcHdlTestBase.h
 *
 *  Created on: Jul 18, 2021
 *      Author: mballance
 */

#pragma once
#include "gtest/gtest.h"
#include "tblink_rpc/tblink_rpc.h"

using namespace tblink_rpc_core;

class TblinkRpcHdlTestBase :
		public ::testing::Test,
		public virtual IEndpointServices {
public:

	TblinkRpcHdlTestBase();

	virtual ~TblinkRpcHdlTestBase();

	virtual void SetUp() override;

	// Tears down the test fixture.
	virtual void TearDown() override;

	virtual bool init();

	virtual void init(IEndpoint *endpoint) override;

	/**
	 * Return command-line arguments.
	 */
	virtual std::vector<std::string> args() override;

	virtual void shutdown() override;

	virtual int32_t add_time_cb(
			uint64_t 		time,
			intptr_t		callback_id) override;

	virtual uint64_t time() override { return 0; }

	virtual int32_t time_precision() override { return 0; }

	virtual void run_until_event() override { }

	// Notify that we've hit an event
	virtual void hit_event() override { }

	virtual void idle() override { }

	virtual void cancel_callback(intptr_t id) override;



protected:
	bool					m_waiting_shutdown;
	bool					m_have_shutdown;
	std::function<void()>	m_post_build_hook;
	std::function<void()>	m_post_connect_hook;

	ITransport				*m_transport;
	IEndpoint				*m_endpoint;


};

