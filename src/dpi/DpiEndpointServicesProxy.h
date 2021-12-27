/*
 * DpiEndpointServicesProxy.h
 *
 *  Created on: Nov 18, 2021
 *      Author: mballance
 */

#pragma once
#include "tblink_rpc/IEndpointServices.h"
#include "dpi_api.h"

namespace tblink_rpc_hdl {

class DpiEndpointServicesProxy : public tblink_rpc_core::IEndpointServices {
public:
	DpiEndpointServicesProxy(dpi_api_t *dpi_api);

	virtual ~DpiEndpointServicesProxy();

	virtual void init(tblink_rpc_core::IEndpoint *endpoint) override;

	/**
	 * Return command-line arguments.
	 */
	virtual std::vector<std::string> args() override;

	virtual int32_t add_time_cb(
			uint64_t 		time,
			intptr_t		callback_id) override;

	virtual void cancel_callback(intptr_t id) override;

	virtual uint64_t time() override;

	/**
	 * Returns the time precision as an exponent:
	 * 0: 1s
	 * -3: 1ms
	 * -6: 1us
	 * -9: 1ns
	 * -12: 1ps
	 */
	virtual int32_t time_precision() override;

private:
	dpi_api_t				*m_dpi_api;
};

} /* namespace tblink_rpc_hdl */

