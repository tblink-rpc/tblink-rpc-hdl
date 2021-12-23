/*
 * InterfaceInstInvokeClosure.cpp
 *
 *  Created on: Dec 14, 2021
 *      Author: mballance
 */

#include "InterfaceInstInvokeClosure.h"

namespace tblink_rpc_hdl {

InterfaceInstInvokeClosure::InterfaceInstInvokeClosure(
		dpi_api_t		*dpi_api) : m_dpi_api(dpi_api) {

}

InterfaceInstInvokeClosure::~InterfaceInstInvokeClosure() {
	// TODO Auto-generated destructor stub
}

void InterfaceInstInvokeClosure::response_f(
		tblink_rpc_core::IParamVal *retval) {
	m_dpi_api->svSetScope(m_dpi_api->get_pkg_scope());
	m_dpi_api->ifi_closure_invoke_rsp(
			reinterpret_cast<void *>(this),
			reinterpret_cast<void *>(retval));
}

} /* namespace tblink_rpc_hdl */
