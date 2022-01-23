/*
 * EndpointServicesDpi.cpp
 *
 *  Created on: Jul 8, 2021
 *      Author: mballance
 */

#include <string.h>
#include "Debug.h"
#include "tblink_rpc/IEndpoint.h"
#include "EndpointServicesDpi.h"
#include "TimeCallbackClosureDpi.h"

#define EN_DEBUG_ENDPOINT_SERVICES_DPI

#ifdef EN_DEBUG_ENDPOINT_SERVICES_DPI
#define DEBUG_ENTER(fmt, ...) DEBUG_ENTER_BASE(EndpointServicesDpi, fmt, ##__VA_ARGS__)
#define DEBUG_LEAVE(fmt, ...) DEBUG_LEAVE_BASE(EndpointServicesDpi, fmt, ##__VA_ARGS__)
#define DEBUG(fmt, ...) DEBUG_BASE(EndpointServicesDpi, fmt, ##__VA_ARGS__)
#else
#define DEBUG_ENTER(fmt, ...)
#define DEBUG_LEAVE(fmt, ...)
#define DEBUG(fmt, ...)
#endif

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
	m_run_until_event = 0;
	m_hit_event = false;
	m_pending_nb = 0;
	m_shutdown = false;
	m_registered = false;
	m_build_connect_catcher_count = 0;
}

EndpointServicesDpi::~EndpointServicesDpi() {
	// TODO Auto-generated destructor stub
}

void EndpointServicesDpi::init(tblink_rpc_core::IEndpoint *endpoint) {
	m_endpoint = endpoint;

	// Add a callback to ensure we run build/connect
	// if the testbench environment does not

	// TODO: more appropriate for an auto-started endpoint
//	_add_time_cb(0, 0, std::bind(&EndpointServicesDpi::build_connect_catcher, this));
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

int32_t EndpointServicesDpi::add_time_cb(
		uint64_t 		time,
		intptr_t		callback_id) {
	DEBUG_ENTER("add_time_cb");
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

	DEBUG_LEAVE("add_time_cb");

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
	return ret;
}

void EndpointServicesDpi::invoke_req(
		tblink_rpc_core::IInterfaceInst			*inst,
		tblink_rpc_core::IMethodType			*method,
		intptr_t								call_id,
		tblink_rpc_core::IParamValVec			*params) {
	// TODO:
}

void EndpointServicesDpi::_add_time_cb(
			uint64_t							time,
			intptr_t							callback_id,
			const std::function<void(intptr_t)>	&cb) {
	DEBUG_ENTER("_add_time_cb");

	TimeCallbackClosureDpi *closure = new TimeCallbackClosureDpi(
			this,
			callback_id,
			cb);

	if (m_have_blocking_tasks) {
		// Use the DPI-based route
		DEBUG("Use DPI-based path");
		m_dpi->add_time_cb(closure, time);
	} else {
		// Use the VPI-based route
		s_cb_data cbd;
		s_vpi_time vt;

		DEBUG("Use VPI-based path");

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
	DEBUG_LEAVE("_add_time_cb");
}

void EndpointServicesDpi::notify_time_cb(intptr_t callback_id) {
	// Clear the flag, since we just got an event
	m_run_until_event = false;

	m_endpoint->notify_callback(callback_id);
}

void EndpointServicesDpi::build_connect_catcher() {
	m_build_connect_catcher_count++;

	/* TODO:
	if (m_endpoint->state() == tblink_rpc_core::IEndpoint::Init) {
		if (m_build_connect_catcher_count < 10) {
			// Reset the callback
			_add_time_cb(0, 0, std::bind(&EndpointServicesDpi::build_connect_catcher, this));
		} else if (m_endpoint->state() == tblink_rpc_core::IEndpoint::Init) {
			fprintf(stdout, "Note: TBLink auto-running build/connect sequence\n");
			if (!m_endpoint->build_complete()) {
				fprintf(stdout, "Error: TBLink build-complete failed\n");
				shutdown();
			} else if (!m_endpoint->connect_complete()) {
				fprintf(stdout, "Error: TBLink connect-complete failed\n");
				shutdown();
			} else {
				fprintf(stdout, "Note: waiting for first command\n");
				idle();
			}
		}
	}
	 */
}

} /* namespace tblink_rpc_hdl */
