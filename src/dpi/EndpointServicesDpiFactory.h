/*
 * EndpointServicesDpiFactory.h
 *
 *  Created on: Dec 4, 2021
 *      Author: mballance
 */

#pragma once
#include "dpi_api.h"
#include "tblink_rpc/IEndpointServicesFactory.h"
#include "vpi_api.h"

namespace tblink_rpc_hdl {

class EndpointServicesDpiFactory : public tblink_rpc_core::IEndpointServicesFactory {
public:
	EndpointServicesDpiFactory(
			dpi_api_t			*dpi,
			vpi_api_t			*vpi);

	virtual ~EndpointServicesDpiFactory();

	virtual tblink_rpc_core::IEndpointServices *create() override;

private:
	dpi_api_t					*m_dpi;
	vpi_api_t					*m_vpi;

};

} /* namespace tblink_rpc_hdl */

