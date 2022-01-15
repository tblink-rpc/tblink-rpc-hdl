/*
 * VpiInterfaceInst.cpp
 *
 *  Created on: Jan 5, 2022
 *      Author: mballance
 */

#include "VpiInterfaceInstWrapper.h"

namespace tblink_rpc_hdl {

using namespace tblink_rpc_core;

VpiInterfaceInstWrapper::VpiInterfaceInstWrapper(
		vpi_api_t				*vpi,
		vpiHandle				ev_h) :
				m_ifinst(0), m_vpi(vpi), m_ev_v(0), m_ev_h(ev_h) {

}

VpiInterfaceInstWrapper::~VpiInterfaceInstWrapper() {
	// TODO Auto-generated destructor stub
}

void VpiInterfaceInstWrapper::req_invoke(
			tblink_rpc_core::IInterfaceInst		*ifinst,
			tblink_rpc_core::IMethodType		*method,
			intptr_t							call_id,
			tblink_rpc_core::IParamValVec		*params) {
	// Add to the queue and toggle the message event
	m_invoke_q.push_back({method, call_id, params});

	s_vpi_value v;
	m_ev_v = (m_ev_v)?0:1;
	v.format = vpiIntVal;
	v.value.integer = m_ev_v;
	m_vpi->vpi_put_value(
			m_ev_h,
			&v,
			0,
			vpiNoDelay);
}

bool VpiInterfaceInstWrapper::nextInvokeReq(
			tblink_rpc_core::IMethodType	**method,
			intptr_t						&call_id,
			tblink_rpc_core::IParamValVec	**params) {
	if (m_invoke_q.size()) {
		*method = m_invoke_q[0].method;
		call_id = m_invoke_q[0].call_id;
		*params = m_invoke_q[0].params;
		m_pending_q.push_back(m_invoke_q[0]);
		m_invoke_q.erase(m_invoke_q.begin());
		return true;
	} else {
		return false;
	}
}

void VpiInterfaceInstWrapper::invoke_rsp(
			intptr_t						call_id,
			tblink_rpc_core::IParamVal		*retval) {
	m_ifinst->invoke_rsp(call_id, retval);

	// Now, remove and clean up
	for (std::vector<InvokeData>::iterator
			it=m_pending_q.begin(); it!=m_pending_q.end(); it++) {
		if (it->call_id == call_id) {
			m_pending_q.erase(it);
			delete it->params;
			break;
		}
	}
}

} /* namespace tblink_rpc_hdl */
