/*
 * TimeCallbackClosureDpi.cpp
 *
 *  Created on: Jul 29, 2021
 *      Author: mballance
 */

#include "Debug.h"
#include "TimeCallbackClosureDpi.h"

#define EN_DEBUG_TIME_CALLBACK_CLOSURE_DPI

#ifdef EN_DEBUG_TIME_CALLBACK_CLOSURE_DPI
#define DEBUG_ENTER(fmt, ...) DEBUG_ENTER_BASE(TimeCallbackClosureDpi, fmt, ##__VA_ARGS__)
#define DEBUG_LEAVE(fmt, ...) DEBUG_LEAVE_BASE(TimeCallbackClosureDpi, fmt, ##__VA_ARGS__)
#define DEBUG(fmt, ...) DEBUG_BASE(TimeCallbackClosureDpi, fmt, ##__VA_ARGS__)
#else
#define DEBUG_ENTER(fmt, ...)
#define DEBUG_LEAVE(fmt, ...)
#define DEBUG(fmt, ...)
#endif


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
	DEBUG_ENTER("notify");
	m_cb(m_callback_id);
	DEBUG_LEAVE("notify");
}

PLI_INT32 TimeCallbackClosureDpi::vpi_time_cb(p_cb_data cbd) {
	TimeCallbackClosureDpi *closure = reinterpret_cast<TimeCallbackClosureDpi *>(cbd->user_data);
	closure->notify();
	delete closure;
	return 0;
}

} /* namespace tblink_rpc_hdl */
