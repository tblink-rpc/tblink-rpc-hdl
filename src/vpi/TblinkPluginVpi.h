/*
 * TblinkPluginVpi.h
 *
 *  Created on: Dec 22, 2021
 *      Author: mballance
 */
#include "vpi_api.h"
#include "VpiHandle.h"

namespace tblink_rpc_hdl {

class TblinkPluginVpi {
public:
	TblinkPluginVpi(vpi_api_t *vpi);

	virtual ~TblinkPluginVpi();

private:
	void register_tf();


	template <PLI_INT32 (TblinkPluginVpi::*M)()> static PLI_INT32 system_tf(PLI_BYTE8 *ud) {
		TblinkPluginVpi *this_p = reinterpret_cast<TblinkPluginVpi *>(ud);
		return (this_p->*M)();
	}

	template <PLI_INT32 (TblinkPluginVpi::*M)()> static PLI_INT32 vpi_cb(p_cb_data cbd) {
		TblinkPluginVpi *this_p = reinterpret_cast<TblinkPluginVpi *>(cbd->user_data);
		return (this_p->*M)();
	}

	// VPI callbacks
	PLI_INT32 on_startup();

	// Task Implementations
	PLI_INT32 ITbLink_inst();

	PLI_INT32 ITbLink_get_default_ep();

	PLI_INT32 IEndpoint_defineInterfaceInst();

	PLI_INT32 IEndpoint_defineInterfaceType();

	PLI_INT32 IEndpoint_findInterfaceType();

	PLI_INT32 IEndpoint_newInterfaceTypeBuilder();

	PLI_INT32 InterfaceInstWrapper_invoke_b();

	PLI_INT32 InterfaceInstWrapper_invoke_nb();

	PLI_INT32 InterfaceInstWrapper_mkValBool();

	PLI_INT32 InterfaceInstWrapper_mkValIntU();

	PLI_INT32 InterfaceInstWrapper_mkValIntS();

	PLI_INT32 InterfaceInstWrapper_mkValMap();

	PLI_INT32 InterfaceInstWrapper_mkValStr();

	PLI_INT32 InterfaceInstWrapper_mkValVec();

	PLI_INT32 InterfaceInstWrapper_nextInvokeReq();

	PLI_INT32 InterfaceInstWrapper_invoke_rsp();

	PLI_INT32 IInterfaceType_findMethod();

	PLI_INT32 IInterfaceTypeBuilder_mkTypeBool();

	PLI_INT32 IInterfaceTypeBuilder_mkTypeInt();

	PLI_INT32 IInterfaceTypeBuilder_mkTypeMap();

	PLI_INT32 IInterfaceTypeBuilder_mkTypeStr();

	PLI_INT32 IInterfaceTypeBuilder_mkTypeVec();

	PLI_INT32 IInterfaceTypeBuilder_newMethodTypeBuilder();

	PLI_INT32 IInterfaceTypeBuilder_add_method();

	PLI_INT32 IMethodType_id();

	PLI_INT32 IMethodTypeBuilder_add_param();

	PLI_INT32 IParamValInt_val_s();

	PLI_INT32 IParamValInt_val_u();

	PLI_INT32 IParamValVec_at();

	PLI_INT32 IParamValVec_push_back();

private:
	vpi_api_t					*m_vpi;
	VpiHandleSP					m_vpi_glbl;
};

} /* namespace tblink_rpc_hdl */

