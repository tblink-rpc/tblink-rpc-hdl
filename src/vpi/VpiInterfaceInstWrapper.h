/*
 * VpiInterfaceInst.h
 *
 *  Created on: Jan 5, 2022
 *      Author: mballance
 */

#pragma once
#include <vector>
#include "vpi_api.h"
#include "tblink_rpc/IInterfaceImpl.h"
#include "tblink_rpc/IInterfaceInst.h"

namespace tblink_rpc_hdl {

class VpiInterfaceInstWrapper : public tblink_rpc_core::IInterfaceImpl {
public:
	VpiInterfaceInstWrapper(
			vpi_api_t							*vpi,
			vpiHandle							ev_h);

	virtual ~VpiInterfaceInstWrapper();

	tblink_rpc_core::IInterfaceInst *ifinst() const { return m_ifinst; }

	void ifinst(tblink_rpc_core::IInterfaceInst *i) { m_ifinst = i; }

	virtual void invoke(
			tblink_rpc_core::IInterfaceInst		*ifinst,
			tblink_rpc_core::IMethodType		*method,
			intptr_t							call_id,
			tblink_rpc_core::IParamValVec		*params) override;

	bool nextInvokeReq(
			tblink_rpc_core::IMethodType	**method,
			intptr_t						&call_id,
			tblink_rpc_core::IParamValVec	**params);

	void invoke_rsp(
			intptr_t						call_id,
			tblink_rpc_core::IParamVal		*retval);

private:
	struct InvokeData {
		tblink_rpc_core::IMethodType		*method;
		intptr_t							call_id;
		tblink_rpc_core::IParamValVec		*params;
	};

private:
	tblink_rpc_core::IInterfaceInst				*m_ifinst;
	vpi_api_t									*m_vpi;
	uint32_t									m_ev_v;
	vpiHandle									m_ev_h;
	std::vector<InvokeData>						m_invoke_q;
	std::vector<InvokeData>						m_pending_q;

};

} /* namespace tblink_rpc_hdl */

