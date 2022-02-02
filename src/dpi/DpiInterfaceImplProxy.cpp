/*
 * DpiInterfaceImplProxy.cpp
 *
 *  Created on: Feb 2, 2022
 *      Author: mballance
 */

#include "DpiInterfaceImplProxy.h"

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
	m_dpi->ifimpl_proxy_invoke(
			reinterpret_cast<void *>(dynamic_cast<IInterfaceImpl *>(this)),
			reinterpret_cast<void *>(ifinst),
			reinterpret_cast<void *>(method),
			call_id,
			reinterpret_cast<void *>(params));
}

} /* namespace tblink_rpc_hdl */
