/*
 * CallbackClosureVpi.cpp
 *
 *  Created on: Jul 24, 2021
 *      Author: mballance
 */

#include "CallbackClosureVpi.h"
#include "EndpointServicesVpi.h"

namespace tblink_rpc_hdl {

CallbackClosureVpi::CallbackClosureVpi(
		EndpointServicesVpi					*services,
		const std::function<void(intptr_t)> &closure,
		intptr_t							callback_id) :
				m_services(services),
				m_closure(closure),
				m_callback_id(callback_id),
				m_cb_h(0) {
	// TODO Auto-generated constructor stub

}

CallbackClosureVpi::~CallbackClosureVpi() {
	// TODO Auto-generated destructor stub
}

PLI_INT32 CallbackClosureVpi::callback(t_cb_data *cbd) {
	CallbackClosureVpi *c = reinterpret_cast<CallbackClosureVpi *>(cbd->user_data);
	c->m_closure(c->m_callback_id);

	delete c;
	return 0;
}

} /* namespace tblink_rpc_hdl */
