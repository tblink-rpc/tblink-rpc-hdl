/*
 * InterfaceInstVpi.h
 *
 *  Created on: Jul 14, 2021
 *      Author: mballance
 */

#pragma once
#include <vector>
#include "vpi_api.h"
#include "tblink_rpc/IInterfaceInst.h"
#include "tblink_rpc/IEndpoint.h"
#include "tblink_rpc/IParamValVector.h"
#include "MethodCallVpi.h"

namespace tblink_rpc_hdl {

class EndpointServicesVpi;

/**
 * The InterfaceInst proxy implements the mailbox between
 * the TBLink core and a specific static Verilog instance
 */
class InterfaceInstProxyVpi {
public:
	InterfaceInstProxyVpi(
			vpi_api_t			*vpi,
			vpiHandle 			notify_ev);

	virtual ~InterfaceInstProxyVpi();

	tblink_rpc_core::IInterfaceInst *inst() const { return m_inst; }

	void inst(tblink_rpc_core::IInterfaceInst *i) { m_inst = i; }

	virtual void invoke_req(
			tblink_rpc_core::IInterfaceInst				*inst,
			tblink_rpc_core::IMethodType				*method,
			intptr_t									call_id,
			tblink_rpc_core::IParamValVectorSP			params);

	MethodCallVpi *claim_call();

private:

private:
	vpi_api_t							*m_vpi;
	vpiHandle							m_notify_ev;
	tblink_rpc_core::IInterfaceInst		*m_inst;
	std::vector<MethodCallVpiUP>		m_calls;

};

} /* namespace tblink_rpc_hdl */

