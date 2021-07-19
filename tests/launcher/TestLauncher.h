/*
 * TestLauncher.h
 *
 *  Created on: Jul 18, 2021
 *      Author: mballance
 */

#pragma once
#include "ILaunch.h"
#include "tblink_rpc/IEndpointServices.h"

class TestLauncher : public ILaunch {
public:
	TestLauncher();

	virtual ~TestLauncher();

	virtual IEndpoint *launch(
			IEndpointServices		*services) override;

	virtual std::string last_error() override {
		return m_last_error;
	}

private:
//	std::string find_runner();

private:
	std::string						m_last_error;

};

