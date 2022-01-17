/*
 * DpiInterfaceImpl.cpp
 *
 *  Created on: Jan 15, 2022
 *      Author: mballance
 */

#include "tblink_rpc/IInterfaceInst.h"
#include "DpiInterfaceImpl.h"

namespace tblink_rpc_hdl {

using namespace tblink_rpc_core;
using chandle=void *;

DpiInterfaceImpl::DpiInterfaceImpl(dpi_api_t *dpi) : m_dpi(dpi) {
	// TODO Auto-generated constructor stub

}

DpiInterfaceImpl::~DpiInterfaceImpl() {
	// TODO Auto-generated destructor stub
}

void DpiInterfaceImpl::invoke(
			tblink_rpc_core::IInterfaceInst		*ifinst,
			tblink_rpc_core::IMethodType		*method,
			intptr_t							call_id,
			tblink_rpc_core::IParamValVec		*params) {
	tblink_rpc_core::IParamVal *params_v = static_cast<tblink_rpc_core::IParamVal *>(params);
	m_dpi->svSetScope(m_dpi->get_pkg_scope());

	m_dpi->invoke(
			reinterpret_cast<chandle>(ifinst),
			reinterpret_cast<chandle>(method),
			call_id,
			reinterpret_cast<chandle>(params_v));
}


} /* namespace tblink_rpc_hdl */
