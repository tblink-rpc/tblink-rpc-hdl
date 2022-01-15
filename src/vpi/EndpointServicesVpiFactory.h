/*
 * EndpointServicesVpiFactory.h
 *
 *  Created on: Dec 23, 2021
 *      Author: mballance
 */

#pragma once
#include "vpi_api.h"
#include "tblink_rpc/IEndpointServicesFactory.h"

namespace tblink_rpc_hdl {

class EndpointServicesVpiFactory : public tblink_rpc_core::IEndpointServicesFactory {
public:
	EndpointServicesVpiFactory(vpi_api_t *api);

	virtual ~EndpointServicesVpiFactory();

	virtual tblink_rpc_core::IEndpointServices *create() override;

private:
	vpi_api_t						*m_api;

};

} /* namespace tblink_rpc_hdl */

