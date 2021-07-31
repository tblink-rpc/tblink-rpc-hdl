/*
 * EndpointServicesDpi.cpp
 *
 *  Created on: Jul 8, 2021
 *      Author: mballance
 */

#include <string.h>
#include "tblink_rpc/IEndpoint.h"
#include "EndpointServicesDpi.h"
#include "TimeCallbackClosureDpi.h"

namespace tblink_rpc_hdl {

EndpointServicesDpi::EndpointServicesDpi(
		dpi_api_t			*dpi,
		vpi_api_t			*vpi,
		bool				have_blocking_tasks) :
			m_dpi(dpi), m_vpi(VpiHandle::mk(vpi)),
			m_have_blocking_tasks(have_blocking_tasks) {

	fprintf(stdout, "EndpointServices: have_blocking_tasks=%d\n", have_blocking_tasks);
	m_endpoint = 0;

	// Grab the package context for later use
	m_pkg_ctx = m_dpi->svGetScope();
	m_run_until_event = 0;
	m_pending_nb = 0;
	m_shutdown = false;
	m_registered = false;
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
	// Okay to terminate with VPI?
	m_vpi->vpi()->vpi_control(vpiFinish, 0);
	m_shutdown = true;

}

int32_t EndpointServicesDpi::add_time_cb(
		uint64_t 		time,
		intptr_t		callback_id) {
	fprintf(stdout, "add_time_cb: %lld\n", time);
	_add_time_cb(time, callback_id,
			std::bind(&EndpointServicesDpi::notify_time_cb, this, std::placeholders::_1));
//	TimeCallbackClosureDpi *closure = new TimeCallbackClosureDpi(
//			this,
//			callback_id,
//			std::bind(&EndpointServicesDpi::notify_time_cb, this, std::placeholders::_1));
//
//	if (m_have_blocking_tasks) {
//		// Use the DPI-based route
//		m_dpi->add_time_cb(closure, time);
//	} else {
//		// Use the VPI-based route
//		s_cb_data cbd;
//		s_vpi_time vt;
//
//		memset(&cbd, 0, sizeof(cbd));
//		memset(&vt, 0, sizeof(vt));
//		vt.type = vpiSimTime;
//		vt.low = time;
//		vt.high = (time >> 32);
//		cbd.reason = cbAfterDelay;
//		cbd.cb_rtn = &TimeCallbackClosureDpi::vpi_time_cb;
//		cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(closure);
//		cbd.time = &vt;
//		m_vpi->vpi()->vpi_register_cb(&cbd);
//	}

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

int32_t EndpointServicesDpi::time_precision() {
	int32_t ret =  m_vpi->vpi()->vpi_get(vpiTimePrecision, 0);
	fprintf(stdout, "precision: %d\n", ret);
	return ret;
}

// Release the environment to run
void EndpointServicesDpi::run_until_event() {
	m_run_until_event = true;
}

void EndpointServicesDpi::idle() {

	if (m_shutdown) {
		return;
	}

	int32_t ret = 0;
	while (!m_run_until_event && !m_shutdown && ret != -1) {
		ret = m_endpoint->await_req();
	}

//	if (m_pending_nb > 0 || m_run_until_event) {
//		// Wait for next command
//	}
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

void EndpointServicesDpi::_add_time_cb(
			uint64_t							time,
			intptr_t							callback_id,
			const std::function<void(intptr_t)>	&cb) {

	TimeCallbackClosureDpi *closure = new TimeCallbackClosureDpi(
			this,
			callback_id,
			cb);

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
}

void EndpointServicesDpi::notify_time_cb(intptr_t callback_id) {
	fprintf(stdout, "notify_time_cb\n");
	fflush(stdout);

	// Clear the flag, since we just got an event
	m_run_until_event = false;

	m_endpoint->notify_callback(callback_id);

	idle();
}

void EndpointServicesDpi::elab_cb(intptr_t callback_id) {
	;
}

} /* namespace tblink_rpc_hdl */
