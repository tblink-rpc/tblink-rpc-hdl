/*
 * InvokeInfoDpi.cpp
 *
 *  Created on: Aug 3, 2021
 *      Author: mballance
 */

#include "InvokeInfoDpi.h"

namespace tblink_rpc_hdl {

InvokeInfoDpi::InvokeInfoDpi(
		tblink_rpc_core::IInterfaceInst			*inst,
		tblink_rpc_core::IMethodType			*method,
		intptr_t								call_id,
		tblink_rpc_core::IParamValVec			*params) :
			m_inst(inst), m_method(method), m_call_id(call_id),
			m_params(params), m_ret(0) {
	// TODO Auto-generated constructor stub

}

InvokeInfoDpi::~InvokeInfoDpi() {
	// TODO Auto-generated destructor stub
}

} /* namespace tblink_rpc_hdl */
