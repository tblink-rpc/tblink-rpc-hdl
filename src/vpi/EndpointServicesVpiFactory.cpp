/*
 * EndpointServicesVpiFactory.cpp
 *
 *  Created on: Dec 23, 2021
 *      Author: mballance
 */

#include "EndpointServicesVpiFactory.h"
#include "EndpointServicesVpi.h"

namespace tblink_rpc_hdl {

EndpointServicesVpiFactory::EndpointServicesVpiFactory(vpi_api_t *api) : m_api(api) {
	// TODO Auto-generated constructor stub

}

EndpointServicesVpiFactory::~EndpointServicesVpiFactory() {
	// TODO Auto-generated destructor stub
}

tblink_rpc_core::IEndpointServices *EndpointServicesVpiFactory::create() {
	return new EndpointServicesVpi(m_api);
}

} /* namespace tblink_rpc_hdl */
