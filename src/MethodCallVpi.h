/*
 * ParamListIteratorVpi.h
 *
 *  Created on: Jul 17, 2021
 *      Author: mballance
 */

#pragma once
#include <memory>
#include "tblink_rpc/IInterfaceInst.h"
#include "tblink_rpc/IParamValVector.h"

namespace tblink_rpc_hdl {

class MethodCallVpi;
typedef std::unique_ptr<MethodCallVpi> MethodCallVpiUP;
class MethodCallVpi {
public:
	MethodCallVpi(
			tblink_rpc_core::IInterfaceInst		*ifc,
			intptr_t							method_id,
			intptr_t							call_id,
			tblink_rpc_core::IParamValVectorSP	params);

	virtual ~MethodCallVpi();

	tblink_rpc_core::IInterfaceInst	*ifc() const { return m_ifc; }

	intptr_t method_id() const { return m_method_id; }

	intptr_t call_id() const { return m_call_id; }

	tblink_rpc_core::IParamValSP next();

	static MethodCallVpiUP mk(
			tblink_rpc_core::IInterfaceInst		*ifc,
			intptr_t							method_id,
			intptr_t							call_id,
			tblink_rpc_core::IParamValVectorSP	params);

private:
	tblink_rpc_core::IInterfaceInst				*m_ifc;
	intptr_t									m_method_id;
	intptr_t									m_call_id;
	tblink_rpc_core::IParamValVectorSP			m_params;
	uint32_t									m_idx;
};

} /* namespace tblink_rpc_hdl */

