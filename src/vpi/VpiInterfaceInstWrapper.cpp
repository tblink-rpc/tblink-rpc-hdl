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
	// TODO: Add to the queue and toggle the message event
}

} /* namespace tblink_rpc_hdl */
