/*
 * ParamListIteratorVpi.cpp
 *
 *  Created on: Jul 17, 2021
 *      Author: mballance
 */

#include "MethodCallVpi.h"

using namespace tblink_rpc_core;
namespace tblink_rpc_hdl {

MethodCallVpi::MethodCallVpi(
		IInterfaceInst				*ifc,
		IMethodType					*method,
		intptr_t					call_id,
		IParamValVector				*params) :
				m_ifc(ifc), m_method(method),
				m_call_id(call_id), m_params(params), m_idx(0) {

}

MethodCallVpi::~MethodCallVpi() {
	// TODO Auto-generated destructor stub
}

tblink_rpc_core::IParamVal *MethodCallVpi::next() {
	if (m_idx < m_params->size()) {
		IParamVal *ret = m_params->at(m_idx);
		m_idx++;
		return ret;
	} else {
		return 0;
	}
}

MethodCallVpiUP MethodCallVpi::mk(
			IInterfaceInst						*ifc,
			IMethodType							*method,
			intptr_t							call_id,
			tblink_rpc_core::IParamValVector	*params) {
	return MethodCallVpiUP(new MethodCallVpi(ifc, method, call_id, params));
}

} /* namespace tblink_rpc_hdl */
