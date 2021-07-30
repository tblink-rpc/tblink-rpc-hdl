/*
 * EndpointServicesDpi.cpp
 *
 *  Created on: Jul 8, 2021
 *      Author: mballance
 */

#include <string.h>
#include "EndpointServicesDpi.h"
#include "TimeCallbackClosureDpi.h"

namespace tblink_rpc_hdl {

EndpointServicesDpi::EndpointServicesDpi(
		dpi_api_t			*dpi,
		vpi_api_t			*vpi,
		bool				have_blocking_tasks) :
			m_dpi(dpi), m_vpi(VpiHandle::mk(vpi)),
			m_have_blocking_tasks(have_blocking_tasks) {
	m_endpoint = 0;

	// Grab the package context for later use
	m_pkg_ctx = m_dpi->svGetScope();

}

EndpointServicesDpi::~EndpointServicesDpi() {
	// TODO Auto-generated destructor stub
}

void EndpointServicesDpi::init(tblink_rpc_core::IEndpoint *endpoint) {
	m_endpoint = endpoint;
}

/**
 * Return command-line arguments.
 */
std::vector<std::string> EndpointServicesDpi::args() {
    s_vpi_vlog_info info;
	std::vector<std::string> ret;

    m_vpi->vpi()->vpi_get_vlog_info(&info);

    for (int32_t i=0; i<info.argc; i++) {
    	ret.push_back(info.argv[i]);
    }

	return ret;
}

void EndpointServicesDpi::shutdown() {

}

int32_t EndpointServicesDpi::add_time_cb(
		uint64_t 		time,
		intptr_t		callback_id) {
	TimeCallbackClosureDpi *closure = new TimeCallbackClosureDpi(
			this,
			callback_id);

	if (m_have_blocking_tasks) {
		// Use the DPI-based route
		m_dpi->add_time_cb(closure, time);
	} else {
		// Use the VPI-based route
		s_cb_data cbd;
		s_vpi_time vt;

		memset(&cbd, 0, sizeof(cbd));
		memset(&vt, 0, sizeof(vt));
		vt.type = vpiSimTime;
		vt.low = time;
		vt.high = (time >> 32);
		cbd.reason = cbAfterDelay;
		cbd.cb_rtn = &TimeCallbackClosureDpi::vpi_time_cb;
		cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(closure);
		cbd.time = &vt;
		m_vpi->vpi()->vpi_register_cb(&cbd);
	}

	return 0;
}

void EndpointServicesDpi::cancel_callback(intptr_t id) {

}

uint64_t EndpointServicesDpi::time() {
	s_vpi_time tv;
	tv.type = vpiSimTime;

	m_vpi->vpi()->vpi_get_time(0, &tv);

	uint64_t ret = tv.high;
	ret <<= 32;
	ret |= tv.low;

	return ret;
}

// Release the environment to run
void EndpointServicesDpi::run_until_event() {

}

void EndpointServicesDpi::invoke_req(
		tblink_rpc_core::IInterfaceInst			*inst,
		tblink_rpc_core::IMethodType			*method,
		intptr_t								call_id,
		tblink_rpc_core::IParamValVectorSP		params) {
	m_dpi->svSetScope(m_pkg_ctx);
	if (method->is_blocking()) {
		// TODO: start a thread to service the request
	} else {
		m_dpi->invoke_nb(0);
	}
}


} /* namespace tblink_rpc_hdl */
