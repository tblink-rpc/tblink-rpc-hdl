/*
 * InterfaceInstProxyDpi.cpp
 *
 *  Created on: Jul 29, 2021
 *      Author: mballance
 */

#include "InterfaceInstProxyDpi.h"
#include "InvokeInfoDpi.h"

namespace tblink_rpc_hdl {

InterfaceInstProxyDpi::InterfaceInstProxyDpi(dpi_api_t *dpi_api) :
	m_ifinst(0), m_dpi_api(dpi_api) {
	// TODO Auto-generated constructor stub

}

InterfaceInstProxyDpi::~InterfaceInstProxyDpi() {
	// TODO Auto-generated destructor stub
}

void InterfaceInstProxyDpi::invoke_req(
			tblink_rpc_core::IInterfaceInst				*inst,
			tblink_rpc_core::IMethodType				*method,
			intptr_t									call_id,
			tblink_rpc_core::IParamValVec				*params) {
	InvokeInfoDpi *ii = new InvokeInfoDpi(
			inst,
			method,
			call_id,
			params);
	fprintf(stdout, "params=%p ii->params()=%p\n", params, ii->params());
	fflush(stdout);
	m_dpi_api->svSetScope(m_dpi_api->get_pkg_scope());
	// Always call the single invocation function. From there we
	// can determine what to do
	m_dpi_api->invoke(reinterpret_cast<void *>(ii));
}

} /* namespace tblink_rpc_hdl */
