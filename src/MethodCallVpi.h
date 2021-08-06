/*
 * ParamListIteratorVpi.h
 *
 *  Created on: Jul 17, 2021
 *      Author: mballance
 */

#pragma once
#include <memory>
#include "tblink_rpc/IInterfaceInst.h"
#include "tblink_rpc/IMethodType.h"
#include "tblink_rpc/IParamValVector.h"

namespace tblink_rpc_hdl {

class MethodCallVpi;
typedef std::unique_ptr<MethodCallVpi> MethodCallVpiUP;
class MethodCallVpi {
public:
	MethodCallVpi(
			tblink_rpc_core::IInterfaceInst		*ifc,
			tblink_rpc_core::IMethodType		*method,
			intptr_t							call_id,
			tblink_rpc_core::IParamValVector	*params);

	virtual ~MethodCallVpi();

	tblink_rpc_core::IInterfaceInst	*ifc() const { return m_ifc; }

	tblink_rpc_core::IMethodType *method() const { return m_method; }

	intptr_t method_id() const { return m_method->id(); }

	intptr_t call_id() const { return m_call_id; }

	tblink_rpc_core::IParamVal *next();

	template <class T> T *nextT() {
		return dynamic_cast<T *>(next());
	}

	static MethodCallVpiUP mk(
			tblink_rpc_core::IInterfaceInst		*ifc,
			tblink_rpc_core::IMethodType		*method,
			intptr_t							call_id,
			tblink_rpc_core::IParamValVector	*params);

private:
	tblink_rpc_core::IInterfaceInst				*m_ifc;
	tblink_rpc_core::IMethodType				*m_method;
	intptr_t									m_call_id;
	tblink_rpc_core::IParamValVectorUP			m_params;
	uint32_t									m_idx;
};

} /* namespace tblink_rpc_hdl */

