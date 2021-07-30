/*
 * InterfaceInstProxyDpi.h
 *
 *  Created on: Jul 29, 2021
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

class InterfaceInstProxyDpi {
public:
	InterfaceInstProxyDpi();

	virtual ~InterfaceInstProxyDpi();

	virtual void invoke_req(
			tblink_rpc_core::IInterfaceInst				*inst,
			tblink_rpc_core::IMethodType				*method,
			intptr_t									call_id,
			tblink_rpc_core::IParamValVectorSP			params);

private:

};

} /* namespace tblink_rpc_hdl */

