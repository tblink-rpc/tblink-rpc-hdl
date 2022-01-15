/*
 * TimeCallbackClosureDpi.cpp
 *
 *  Created on: Jul 29, 2021
 *      Author: mballance
 */

#include "TimeCallbackClosureDpi.h"

namespace tblink_rpc_hdl {

TimeCallbackClosureDpi::TimeCallbackClosureDpi(
		EndpointServicesDpi						*services,
		intptr_t								callback_id,
		const std::function<void (intptr_t)>	&cb) :
			m_services(services), m_callback_id(callback_id), m_cb(cb) {

}

TimeCallbackClosureDpi::~TimeCallbackClosureDpi() {
	// TODO Auto-generated destructor stub
}

void TimeCallbackClosureDpi::notify() {
	m_cb(m_callback_id);
}

PLI_INT32 TimeCallbackClosureDpi::vpi_time_cb(p_cb_data cbd) {
	TimeCallbackClosureDpi *closure = reinterpret_cast<TimeCallbackClosureDpi *>(cbd->user_data);
	closure->notify();
	delete closure;
	return 0;
}

} /* namespace tblink_rpc_hdl */
