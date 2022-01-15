/*
 * EndpointServicesVpi.cpp
 *
 *  Created on: Jul 8, 2021
 *      Author: mballance
 */
#include <functional>
#include <string.h>
#include "CallbackClosureVpi.h"
#include "Debug.h"
#include "EndpointServicesVpi.h"
#include "InterfaceInstProxyVpi.h"
#include "MethodCallVpi.h"
#include "tblink_rpc/IInterfaceTypeBuilder.h"
#include "tblink_rpc/IParamValInt.h"

#define EN_DEBUG_ENDPOINT_SERVICES_VPI

#ifdef EN_DEBUG_ENDPOINT_SERVICES_VPI
#define DEBUG_ENTER(fmt, ...) DEBUG_ENTER_BASE(EndpointServicesVpi, fmt, ##__VA_ARGS__)
#define DEBUG_LEAVE(fmt, ...) DEBUG_LEAVE_BASE(EndpointServicesVpi, fmt, ##__VA_ARGS__)
#define DEBUG(fmt, ...) DEBUG_BASE(EndpointServicesVpi, fmt, ##__VA_ARGS__)
#else
#define DEBUG(fmt, ...)
#define DEBUG_ENTER(fmt, ...)
#define DEBUG_LEAVE(fmt, ...)
#endif

using namespace tblink_rpc_core;

namespace tblink_rpc_hdl {

EndpointServicesVpi::EndpointServicesVpi(vpi_api_t *vpi, bool is_active) :
		m_vpi(vpi), m_is_active(is_active), m_global(VpiHandle::mk(vpi)) {

	m_callback_id = 1;
	m_endpoint = 0;
	m_registered = true;
	m_cached_time = 0;
	m_run_until_event = 0;
	m_pending_nb_calls = 0;
	m_pending_bl_calls = 0;
	m_shutdown = false;

	m_last_registered_ifinsts = 0;
	m_count = 0;
}

EndpointServicesVpi::~EndpointServicesVpi() {
	// TODO Auto-generated destructor stub
}

void EndpointServicesVpi::init(tblink_rpc_core::IEndpoint *endpoint) {
	m_endpoint = endpoint;

	m_endpoint->addListener(std::bind(
			&EndpointServicesVpi::event, this, std::placeholders::_1));

	if (m_is_active) {
		// Initiate the actively-managed startup sequence
		s_cb_data cbd;
	   	s_vpi_time time;
	    memset(&cbd, 0, sizeof(cbd));
	   	memset(&time, 0, sizeof(time));
	    cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(this);
	    cbd.cb_rtn = &vpi_cb<&EndpointServicesVpi::active_startup_await_registration>;
	    cbd.reason = cbAfterDelay;
	    time.type = vpiSimTime;
	    cbd.time = &time;
	    m_vpi->vpi_register_cb(&cbd);
	}
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

void EndpointServicesVpi::event(const tblink_rpc_core::IEndpointEvent *ev) {
	;
}

PLI_INT32 EndpointServicesVpi::time_cb(p_cb_data cbd) {
	std::function<void(intptr_t)> *closure =
			reinterpret_cast<std::function<void(intptr_t)> *>(cbd->user_data);
	(*closure)(reinterpret_cast<intptr_t>(cbd->obj));

	delete closure;

	return 0;
}

void EndpointServicesVpi::notify_time_cb(intptr_t callback_id) {
	DEBUG_ENTER("notify_time_cb: %d", callback_id);

	// Remove the callback from the map
	std::map<intptr_t, CallbackClosureVpi *>::const_iterator it;

	if ((it=m_cb_closure_m.find(callback_id)) != m_cb_closure_m.end()) {
		m_cb_closure_m.erase(it);
	}

	m_endpoint->notify_callback(callback_id);

	post_ev();

	DEBUG_LEAVE("notify_time_cb: %d", callback_id);
}

/**
 * Wait for BFMs to register
 */
PLI_INT32 EndpointServicesVpi::active_startup_await_registration() {
	DEBUG_ENTER("active_startup_await_registration");
	s_cb_data cbd;
   	s_vpi_time time;
	int32_t n_ifinsts = m_endpoint->getInterfaceInsts().size();

    memset(&cbd, 0, sizeof(cbd));
   	memset(&time, 0, sizeof(time));
    cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(this);
    cbd.reason = cbAfterDelay;
    time.type = vpiSimTime;
    cbd.time = &time;

   	m_count++;

	if ((m_last_registered_ifinsts && m_last_registered_ifinsts == n_ifinsts) || m_count > 16) {
		// Notify that our build process is complete
		if (m_endpoint->build_complete() == -1) {
			// TODO: Something went wrong. Bail out
		} else {
			cbd.cb_rtn = &vpi_cb<&EndpointServicesVpi::active_startup_await_is_build_complete>;
			m_count = 0;
		}
	} else {
	    cbd.cb_rtn = &vpi_cb<&EndpointServicesVpi::active_startup_await_registration>;
	}
    m_vpi->vpi_register_cb(&cbd);
	DEBUG_LEAVE("active_startup_await_registration");
	return 0;
}

/**
 * Wait for the build sequence to complete
 */
PLI_INT32 EndpointServicesVpi::active_startup_await_is_build_complete() {
	DEBUG_ENTER("active_startup_await_is_build_complete");
	int ret;
	s_cb_data cbd;
   	s_vpi_time time;

    memset(&cbd, 0, sizeof(cbd));
   	memset(&time, 0, sizeof(time));
    cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(this);
    cbd.reason = cbAfterDelay;
    time.type = vpiSimTime;
    cbd.time = &time;

    ret = m_endpoint->is_build_complete();
    if (ret == -1) {
		// TODO: Something went wrong. Bail out
    } else {
    	if (ret == 1) {
    		// Connect and
    		if ((ret=m_endpoint->connect_complete()) == -1) {
    			// TODO: Something went wrong. Bail out
    		}
    		cbd.cb_rtn = &vpi_cb<&EndpointServicesVpi::active_startup_await_is_connect_complete>;
    	} else {
    		// Need to go around the loop again
    		cbd.cb_rtn = &vpi_cb<&EndpointServicesVpi::active_startup_await_is_build_complete>;
    	}
	}

    if (ret != -1) {
    	m_vpi->vpi_register_cb(&cbd);
    }

	DEBUG_LEAVE("active_startup_await_is_build_complete");
	return 0;
}

PLI_INT32 EndpointServicesVpi::active_startup_await_is_connect_complete() {
	DEBUG_ENTER("active_startup_await_is_connect_complete");
	int ret;

   	ret = m_endpoint->is_connect_complete();

   	if (ret == 1) {
   		DEBUG("Connected");
   	} else if (ret == -1) {

   	} else {
   		s_cb_data cbd;
   		s_vpi_time time;

   		DEBUG("Retry is-connected");
   		memset(&cbd, 0, sizeof(cbd));
   		memset(&time, 0, sizeof(time));
   		cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(this);
   		cbd.reason = cbAfterDelay;
   		time.type = vpiSimTime;
   		cbd.time = &time;
   		cbd.cb_rtn = &vpi_cb<&EndpointServicesVpi::active_startup_await_is_connect_complete>;
    	m_vpi->vpi_register_cb(&cbd);
   	}


	DEBUG_LEAVE("active_startup_await_is_connect_complete");
	return 0;
}

PLI_INT32 EndpointServicesVpi::on_startup() {
	s_cb_data cbd;

   	s_vpi_time time;
    memset(&cbd, 0, sizeof(cbd));
   	memset(&time, 0, sizeof(time));
    cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(this);
    cbd.cb_rtn = &vpi_cb<&EndpointServicesVpi::start_of_simulation>;
    cbd.reason = cbAfterDelay;
    time.type = vpiSimTime;
    cbd.time = &time;
    m_vpi->vpi_register_cb(&cbd);

    memset(&cbd, 0, sizeof(cbd));
   	memset(&time, 0, sizeof(time));
    cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(this);
    cbd.reason = cbEndOfSimulation;
    cbd.cb_rtn = &vpi_cb<&EndpointServicesVpi::end_of_simulation>;
    m_vpi->vpi_register_cb(&cbd);

	return 0;
}

PLI_INT32 EndpointServicesVpi::start_of_simulation() {

    if (!m_registered) {
    	// If nothing else has registered, go ahead
    	// and mark ourselves built and connected
    	m_endpoint->build_complete();

    	m_endpoint->connect_complete();

    	// Decide what needs to happen next
    	idle();
    } else {
    	// Need to take another spin to be sure
    	s_cb_data cbd;
    	s_vpi_time time;

    	m_registered = false;

    	memset(&cbd, 0, sizeof(cbd));
    	memset(&time, 0, sizeof(time));

    	cbd.reason = cbAfterDelay;
    	cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(this);
    	cbd.cb_rtn = &vpi_cb<&EndpointServicesVpi::start_of_simulation>;
    	time.type = vpiSimTime;
    	cbd.time = &time;
    	m_vpi->vpi_register_cb(&cbd);
    }

	return 0;
}

PLI_INT32 EndpointServicesVpi::delta() {
	idle();

	return 0;
}

PLI_INT32 EndpointServicesVpi::end_of_simulation() {

//	if (m_endpoint && m_endpoint->type() == IEndpoint::Active) {
		m_endpoint->shutdown();
//	}

	return 0;
}

void EndpointServicesVpi::post_ev() {
	// We're no longer waiting for an event. It just happened
	m_run_until_event--;

	// Go wait for the next command
	idle();
}

/**
 *
 */
void EndpointServicesVpi::idle() {
#ifdef UNDEFINED
	int32_t ret = 0;

	if (m_shutdown) {
		// If we're in shutdown mode, don't wait for any more messages
		return;
	}

//	fprintf(stdout, "idle: nb_calls=%d run_until=%d\n", m_pending_nb_calls, m_run_until_event);
//	fflush(stdout);

	// Only check for new messages if we haven't already
	// been told to run until the next event
//	if (m_endpoint->type() == IEndpoint::Active) {
		while (
			m_pending_nb_calls == 0 &&
			m_run_until_event==0 &&
			!m_shutdown) {
			// Wait for a request
			ret = m_endpoint->await_req();
		}
//	}

	if (m_pending_nb_calls > 0 && !m_shutdown) {
		// schedule a delta and wait for completion
    	s_cb_data cbd;
    	s_vpi_time time;

    	m_registered = false;

    	memset(&cbd, 0, sizeof(cbd));
    	memset(&time, 0, sizeof(time));

    	time.type = vpiSimTime;
    	cbd.reason = cbAfterDelay;
    	cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(this);
    	cbd.cb_rtn = &vpi_cb<&EndpointServicesVpi::delta>;
    	cbd.time = &time;
    	m_vpi->vpi_register_cb(&cbd);
	}
#endif
}

int32_t EndpointServicesVpi::add_time_cb(
		uint64_t 		time,
		intptr_t		callback_id) {
	DEBUG_ENTER("add_time_callback");

	// Need to take another spin to be sure
	s_cb_data cbd;
	s_vpi_time vt;

	CallbackClosureVpi *closure = new CallbackClosureVpi(
			this,
			std::bind(&EndpointServicesVpi::notify_time_cb, this, std::placeholders::_1),
			callback_id);

	memset(&cbd, 0, sizeof(cbd));
	memset(&vt, 0, sizeof(vt));
	vt.type = vpiSimTime;
	vt.low = time;
	vt.high = (time >> 32);
	cbd.reason = cbAfterDelay;
	cbd.cb_rtn = &CallbackClosureVpi::callback;
	cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(closure);
	cbd.time = &vt;
	vpiHandle cb_id = m_vpi->vpi_register_cb(&cbd);

	closure->cb_h(cb_id);
	m_cb_closure_m.insert({callback_id, closure});

	DEBUG_LEAVE("add_time_callback");

	return (cb_id != 0);
}

void EndpointServicesVpi::cancel_callback(intptr_t id) {
	// TODO: find the callback id...

}

uint64_t EndpointServicesVpi::time() {
	s_vpi_time tv;
	tv.type = vpiSimTime;

	m_vpi->vpi_get_time(0, &tv);

	uint64_t ret = tv.high;
	ret <<= 32;
	ret |= tv.low;

	return ret;
}

int32_t EndpointServicesVpi::time_precision() {
	int32_t ret =  m_vpi->vpi_get(vpiTimePrecision, 0);
	fprintf(stdout, "precision: %d\n", ret);
	return ret;
}

void EndpointServicesVpi::inc_pending_nb_calls() {
	m_pending_nb_calls++;
}

void EndpointServicesVpi::dec_pending_nb_calls() {
	m_pending_nb_calls--;
}

} /* namespace tblink_rpc_hdl */
