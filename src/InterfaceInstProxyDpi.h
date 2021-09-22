/*
 * InterfaceInstProxyDpi.h
 *
 *  Created on: Jul 29, 2021
 *      Author: mballance
 */

#pragma once
#include <vector>
#include "dpi_api.h"
#include "vpi_api.h"
#include "tblink_rpc/IInterfaceInst.h"
#include "tblink_rpc/IEndpoint.h"
#include "tblink_rpc/IParamValVec.h"
#include "MethodCallVpi.h"

namespace tblink_rpc_hdl {

class InterfaceInstProxyDpi : public tblink_rpc_core::IInterfaceInst {
public:
	InterfaceInstProxyDpi(dpi_api_t *dpi_api);

	virtual ~InterfaceInstProxyDpi();

	tblink_rpc_core::IInterfaceInst *ifinst() const { return m_ifinst; }

	void ifinst(tblink_rpc_core::IInterfaceInst *i) { m_ifinst = i; }

	void invoke_req(
			tblink_rpc_core::IInterfaceInst				*inst,
			tblink_rpc_core::IMethodType				*method,
			intptr_t									call_id,
			tblink_rpc_core::IParamValVec				*params);

private:
	tblink_rpc_core::IInterfaceInst					*m_ifinst;
	dpi_api_t										*m_dpi_api;

};

} /* namespace tblink_rpc_hdl */

