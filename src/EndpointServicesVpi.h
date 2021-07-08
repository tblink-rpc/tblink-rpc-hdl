/*
 * EndpointServicesVpi.h
 *
 *  Created on: Jul 8, 2021
 *      Author: mballance
 */

#pragma once
#include <memory>
#include "vpi_api.h"
#include "tblink_rpc/IEndpoint.h"
#include "tblink_rpc/IEndpointServices.h"

namespace tblink_rpc_hdl {

class EndpointServicesVpi;
typedef std::unique_ptr<EndpointServicesVpi> EndpointServicesVpiUP;
class EndpointServicesVpi : public tblink_rpc_core::IEndpointServices {
public:
	EndpointServicesVpi(vpi_api_t *vpi);

	virtual ~EndpointServicesVpi();

	/**
	 * Return command-line arguments.
	 */
	virtual std::vector<std::string> args() override;

	virtual void shutdown() override;

	virtual intptr_t add_time_cb(uint64_t time) override;

	virtual void cancel_callback(intptr_t id) override;

private:
	vpi_api_t				*m_vpi;

};

} /* namespace tblink_rpc_hdl */

