/*
 * EndpointServicesVpi.cpp
 *
 *  Created on: Jul 8, 2021
 *      Author: mballance
 */

#include "EndpointServicesVpi.h"

namespace tblink_rpc_hdl {

EndpointServicesVpi::EndpointServicesVpi(vpi_api_t *vpi) : m_vpi(vpi) {
	// TODO Auto-generated constructor stub

}

EndpointServicesVpi::~EndpointServicesVpi() {
	// TODO Auto-generated destructor stub
}


std::vector<std::string> EndpointServicesVpi::args() {
    s_vpi_vlog_info info;
	std::vector<std::string> ret;

    m_vpi->vpi_get_vlog_info(&info);

    for (int32_t i=0; i<info.argc; i++) {
    	ret.push_back(info.argv[i]);
    }

	return ret;
}

void EndpointServicesVpi::shutdown() {
		m_vpi->vpi_control(vpiFinish, 0);
}

intptr_t EndpointServicesVpi::add_time_cb(uint64_t time) {

}

void EndpointServicesVpi::cancel_callback(intptr_t id) {

}

} /* namespace tblink_rpc_hdl */
