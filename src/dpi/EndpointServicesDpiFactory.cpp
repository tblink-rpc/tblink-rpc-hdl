/*
 * EndpointServicesDpiFactory.cpp
 *
 *  Created on: Dec 4, 2021
 *      Author: mballance
 */

#include "EndpointServicesDpiFactory.h"
#include "EndpointServicesDpi.h"

namespace tblink_rpc_hdl {

EndpointServicesDpiFactory::EndpointServicesDpiFactory(
		dpi_api_t			*dpi,
		vpi_api_t			*vpi) : m_dpi(dpi), m_vpi(vpi) {
	// TODO Auto-generated constructor stub

}

EndpointServicesDpiFactory::~EndpointServicesDpiFactory() {
	// TODO Auto-generated destructor stub
}

tblink_rpc_core::IEndpointServices *EndpointServicesDpiFactory::create() {
	return new EndpointServicesDpi(m_dpi, m_vpi, true);
}

} /* namespace tblink_rpc_hdl */
