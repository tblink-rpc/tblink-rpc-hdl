/*
 * DpiInterfaceImplProxy.h
 *
 *  Created on: Feb 2, 2022
 *      Author: mballance
 */

#include "dpi_api.h"
#include "tblink_rpc/IInterfaceImpl.h"

namespace tblink_rpc_hdl {

class DpiInterfaceImplProxy : public tblink_rpc_core::IInterfaceImpl {
public:
	DpiInterfaceImplProxy(dpi_api_t *dpi);

	virtual ~DpiInterfaceImplProxy();

	virtual void init(tblink_rpc_core::IInterfaceInst *ifinst) override;

	virtual void invoke(
			tblink_rpc_core::IInterfaceInst	*ifinst,
			tblink_rpc_core::IMethodType	*method,
			intptr_t						call_id,
			tblink_rpc_core::IParamValVec	*params) override;

private:
	dpi_api_t					*m_dpi;

};

} /* namespace tblink_rpc_hdl */

