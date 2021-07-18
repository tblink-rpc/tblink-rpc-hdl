/*
 * InterfaceInstVpi.cpp
 *
 *  Created on: Jul 14, 2021
 *      Author: mballance
 */

#include "InterfaceInstProxyVpi.h"

using namespace tblink_rpc_core;
namespace tblink_rpc_hdl {

InterfaceInstProxyVpi::InterfaceInstProxyVpi(
		vpi_api_t			*vpi,
		vpiHandle 			notify_ev) :
				m_vpi(vpi), m_notify_ev(notify_ev), m_inst(0) {

}

InterfaceInstProxyVpi::~InterfaceInstProxyVpi() {
	// TODO Auto-generated destructor stub
}

void InterfaceInstProxyVpi::invoke_req(
		tblink_rpc_core::IInterfaceInst				*inst,
		tblink_rpc_core::IMethodType				*method,
		intptr_t									call_id,
		tblink_rpc_core::IParamValVectorSP			params) {
	m_calls.push_back(MethodCallVpi::mk(
			m_inst,
			method->id(),
			call_id,
			params));
}

MethodCallVpi *InterfaceInstProxyVpi::claim_call() {
	MethodCallVpi *ret = 0;
	if (m_calls.size() > 0) {
		ret = m_calls.at(0).release();
		m_calls.erase(m_calls.begin());
	}

	return ret;
}

} /* namespace tblink_rpc_hdl */
