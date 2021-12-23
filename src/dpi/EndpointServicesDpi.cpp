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

void EndpointServicesDpi::shutdown() {
	// Okay to terminate with VPI?
	m_vpi->vpi()->vpi_control(vpiFinish, 0);
	m_shutdown = true;

}

int32_t EndpointServicesDpi::add_time_cb(
		uint64_t 		time,
		intptr_t		callback_id) {
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
	return ret;
}

// Release the environment to run
void EndpointServicesDpi::run_until_event() {
	m_run_until_event = true;
}

// Notify that we've hit an event
void EndpointServicesDpi::hit_event() {
	m_run_until_event = false;
	m_hit_event = true;
}

void EndpointServicesDpi::idle() {
//	fprintf(stdout, "idle\n");
//	fflush(stdout);
	if (m_shutdown) {
		return;
	}

	if (m_hit_event) {
		// reschedule this for a delta away
		m_hit_event = false;
		_add_time_cb(0, 0, std::bind(&EndpointServicesDpi::idle, this));
	} else {
		int32_t ret = 0;
		while (!m_run_until_event && !m_shutdown && ret != -1) {
			ret = m_endpoint->await_req();
		}
	}
}

void EndpointServicesDpi::invoke_req(
		tblink_rpc_core::IInterfaceInst			*inst,
		tblink_rpc_core::IMethodType			*method,
		intptr_t								call_id,
		tblink_rpc_core::IParamValVec			*params) {
	/*
	InvokeInfoDpi *ii = new InvokeInfoDpi(
			inst,
			method,
			call_id,
			params);
	fprintf(stdout, "params=%p ii->params()=%p\n", params, ii->params());
	fflush(stdout);
	m_dpi->svSetScope(m_dpi->get_pkg_scope());
	if (method->is_blocking()) {
		m_dpi->invoke_b(reinterpret_cast<void *>(ii));
	} else {
		m_dpi->invoke_nb(reinterpret_cast<void *>(ii));
		tblink_rpc_core::IParamVal *ret = ii->ret();
		inst->invoke_rsp(call_id, ret);

		delete ii;
	}
	 */
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
