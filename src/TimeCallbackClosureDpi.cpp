/*
 * TimeCallbackClosureDpi.cpp
 *
 *  Created on: Jul 29, 2021
 *      Author: mballance
 */

#include "TimeCallbackClosureDpi.h"

namespace tblink_rpc_hdl {

TimeCallbackClosureDpi::TimeCallbackClosureDpi(
		EndpointServicesDpi		*services,
		intptr_t				callback_id) :
			m_services(services), m_callback_id(callback_id) {

}

TimeCallbackClosureDpi::~TimeCallbackClosureDpi() {
	// TODO Auto-generated destructor stub
}

void TimeCallbackClosureDpi::notify() {

}

PLI_INT32 TimeCallbackClosureDpi::vpi_time_cb(p_cb_data cbd) {
	TimeCallbackClosureDpi *closure = reinterpret_cast<TimeCallbackClosureDpi *>(cbd->user_data);
	closure->vpi_time_cb();
	delete closure;
	return 0;
}

void TimeCallbackClosureDpi::vpi_time_cb() {
	notify();
}

} /* namespace tblink_rpc_hdl */
