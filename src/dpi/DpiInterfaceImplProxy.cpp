/*
 * DpiInterfaceImplProxy.cpp
 *
 *  Created on: Feb 2, 2022
 *      Author: mballance
 */

#include "Debug.h"
#include "tblink_rpc/IParamValVec.h"
#include "DpiInterfaceImplProxy.h"

#define EN_DEBUG_DPI_INTERFACE_IMPL_PROXY

#ifdef EN_DEBUG_DPI_INTERFACE_IMPL_PROXY
#define DEBUG_ENTER(fmt, ...) DEBUG_ENTER_BASE(DpiInterfaceImplProxy, fmt, ##__VA_ARGS__)
#define DEBUG_LEAVE(fmt, ...) DEBUG_LEAVE_BASE(DpiInterfaceImplProxy, fmt, ##__VA_ARGS__)
#define DEBUG(fmt, ...) DEBUG_BASE(DpiInterfaceImplProxy, fmt, ##__VA_ARGS__)
#else
#define DEBUG_ENTER(fmt, ...)
#define DEBUG_LEAVE(fmt, ...)
#define DEBUG(fmt, ...)
#endif

namespace tblink_rpc_hdl {

using namespace tblink_rpc_core;

DpiInterfaceImplProxy::DpiInterfaceImplProxy(dpi_api_t *dpi) : m_dpi(dpi) {
	// TODO Auto-generated constructor stub

}

DpiInterfaceImplProxy::~DpiInterfaceImplProxy() {
	// TODO Auto-generated destructor stub
}

void DpiInterfaceImplProxy::init(IInterfaceInst *ifinst) {
	// Ignore
}

void DpiInterfaceImplProxy::invoke(
			IInterfaceInst	*ifinst,
			IMethodType		*method,
			intptr_t		call_id,
			IParamValVec	*params) {
	DEBUG_ENTER("invoke invoke_f=%p", m_dpi->ifimpl_proxy_invoke);
	m_dpi->svSetScope(m_dpi->get_pkg_scope());
	m_dpi->ifimpl_proxy_invoke(
			reinterpret_cast<void *>(dynamic_cast<IInterfaceImpl *>(this)),
			reinterpret_cast<void *>(ifinst),
			reinterpret_cast<void *>(method),
			call_id,
			reinterpret_cast<void *>(
					dynamic_cast<IParamVal *>(params)));
	DEBUG_LEAVE("invoke");
}

} /* namespace tblink_rpc_hdl */
