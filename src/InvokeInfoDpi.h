/*
 * InvokeInfoDpi.h
 *
 *  Created on: Aug 3, 2021
 *      Author: mballance
 */

#pragma once
#include "tblink_rpc/IInterfaceInst.h"
#include "tblink_rpc/IMethodType.h"
#include "tblink_rpc/IParamValVec.h"

namespace tblink_rpc_hdl {

class InvokeInfoDpi {
public:
	InvokeInfoDpi(
			tblink_rpc_core::IInterfaceInst		*inst,
			tblink_rpc_core::IMethodType		*method,
			intptr_t							call_id,
			tblink_rpc_core::IParamValVec		*params
			);

	virtual ~InvokeInfoDpi();

	tblink_rpc_core::IInterfaceInst *inst() const { return m_inst; }

	tblink_rpc_core::IMethodType *method() const { return m_method; }

	intptr_t call_id() const { return m_call_id; }

	tblink_rpc_core::IParamValVec *params() const { return m_params.get(); }

	tblink_rpc_core::IParamVal *ret() const { return m_ret; }

	void ret(tblink_rpc_core::IParamVal *r) { m_ret = r; }

private:
	tblink_rpc_core::IInterfaceInst				*m_inst;
	tblink_rpc_core::IMethodType				*m_method;
	intptr_t									m_call_id;
	tblink_rpc_core::IParamValVecUP				m_params;
	tblink_rpc_core::IParamVal					*m_ret;

};

} /* namespace tblink_rpc_hdl */

