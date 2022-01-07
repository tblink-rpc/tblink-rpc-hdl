/*
 * TblinkPluginVpi.cpp
 *
 *  Created on: Dec 22, 2021
 *      Author: mballance
 */

#include <string>
#include <string.h>
#include <vector>
#include "Debug.h"
#include "EndpointServicesVpi.h"
#include "EndpointServicesVpiFactory.h"
#include "tblink_rpc/ITbLink.h"
#include "TbLink.h"
#include "TblinkPluginVpi.h"
#include "VpiEndpointSequencer.h"
#include "VpiInterfaceInstWrapper.h"

#define EN_DEBUG_TBLINK_PLUGIN_VPI

#ifdef EN_DEBUG_TBLINK_PLUGIN_VPI
#define DEBUG_ENTER(fmt, ...) DEBUG_ENTER_BASE(TblinkPluginVpi, fmt, ##__VA_ARGS__)
#define DEBUG_LEAVE(fmt, ...) DEBUG_LEAVE_BASE(TblinkPluginVpi, fmt, ##__VA_ARGS__)
#define DEBUG(fmt, ...) DEBUG_BASE(TblinkPluginVpi, fmt, ##__VA_ARGS__)
#else
#define DEBUG_ENTER(fmt, ...)
#define DEBUG_LEAVE(fmt, ...)
#define DEBUG(fmt, ...)
#endif

namespace tblink_rpc_hdl {

using namespace tblink_rpc_core;

TblinkPluginVpi::TblinkPluginVpi(vpi_api_t *vpi) :
		m_vpi(vpi), m_vpi_glbl(VpiHandleSP(new VpiHandle(vpi, 0))) {
	DEBUG_ENTER("TblinkPluginVpi");
	ITbLink *tblink = TbLink::inst();

	tblink->setDefaultServicesFactory(new EndpointServicesVpiFactory(vpi));

	register_tf();
	DEBUG_LEAVE("TblinkPluginVpi");
}

TblinkPluginVpi::~TblinkPluginVpi() {
	// TODO Auto-generated destructor stub
}

void TblinkPluginVpi::register_tf() {
	DEBUG_ENTER("register_tf");
    s_vpi_systf_data tf_data;

    tf_data.type = vpiSysFunc;
    tf_data.sysfunctype = vpiSizedFunc;
    tf_data.compiletf = 0;
    tf_data.sizetf = 0;
    tf_data.user_data = reinterpret_cast<PLI_BYTE8 *>(this);

    tf_data.tfname = "$tblink_rpc_ITbLink_inst";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::ITbLink_inst>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_ITbLink_get_default_ep";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::ITbLink_get_default_ep>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_IEndpoint_defineInterfaceInst";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IEndpoint_defineInterfaceInst>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_IEndpoint_defineInterfaceType";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IEndpoint_defineInterfaceType>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_IEndpoint_findInterfaceType";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IEndpoint_findInterfaceType>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_IEndpoint_newInterfaceTypeBuilder";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IEndpoint_newInterfaceTypeBuilder>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_InterfaceInstWrapper_invoke_b";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::InterfaceInstWrapper_invoke_b>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_InterfaceInstWrapper_invoke_nb";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::InterfaceInstWrapper_invoke_nb>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.type = vpiSysTask;
    tf_data.tfname = "$tblink_rpc_InterfaceInstWrapper_invoke_rsp";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::InterfaceInstWrapper_invoke_rsp>;
    m_vpi->vpi_register_systf(&tf_data);
    tf_data.type = vpiSysFunc;

    tf_data.tfname = "$tblink_rpc_InterfaceInstWrapper_mkValBool";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::InterfaceInstWrapper_mkValBool>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_InterfaceInstWrapper_mkValIntU";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::InterfaceInstWrapper_mkValIntU>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_InterfaceInstWrapper_mkValIntS";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::InterfaceInstWrapper_mkValIntS>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_InterfaceInstWrapper_mkValMap";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::InterfaceInstWrapper_mkValMap>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_InterfaceInstWrapper_mkValStr";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::InterfaceInstWrapper_mkValStr>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_InterfaceInstWrapper_mkValVec";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::InterfaceInstWrapper_mkValVec>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_InterfaceInstWrapper_nextInvokeReq";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::InterfaceInstWrapper_nextInvokeReq>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_IInterfaceType_findMethod";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IInterfaceType_findMethod>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_IInterfaceTypeBuilder_mkTypeBool";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IInterfaceTypeBuilder_mkTypeBool>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_IInterfaceTypeBuilder_mkTypeInt";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IInterfaceTypeBuilder_mkTypeInt>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_IInterfaceTypeBuilder_mkTypeMap";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IInterfaceTypeBuilder_mkTypeMap>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_IInterfaceTypeBuilder_mkTypeStr";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IInterfaceTypeBuilder_mkTypeStr>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_IInterfaceTypeBuilder_mkTypeVec";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IInterfaceTypeBuilder_mkTypeVec>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_IInterfaceTypeBuilder_newMethodTypeBuilder";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IInterfaceTypeBuilder_newMethodTypeBuilder>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_IInterfaceTypeBuilder_add_method";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IInterfaceTypeBuilder_add_method>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_IMethodType_id";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IMethodType_id>;
    m_vpi->vpi_register_systf(&tf_data);

    // add_param doesn't return a value, in contrast with the other TbLink functions
    tf_data.type = vpiSysTask;
    tf_data.tfname = "$tblink_rpc_IMethodTypeBuilder_add_param";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IMethodTypeBuilder_add_param>;
    m_vpi->vpi_register_systf(&tf_data);
    tf_data.type = vpiSysFunc;

    tf_data.tfname = "$tblink_rpc_IParamValInt_val_s";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IParamValInt_val_s>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_IParamValInt_val_u";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IParamValInt_val_u>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_IParamValVec_at";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IParamValVec_at>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_rpc_IParamValVec_push_back";
    tf_data.calltf = &system_tf<&TblinkPluginVpi::IParamValVec_push_back>;
    m_vpi->vpi_register_systf(&tf_data);

#ifdef UNDEFINED
    tf_data.tfname = "$tblink_ifinst_call_claim";
    tf_data.calltf = &system_tf<&EndpointServicesVpi::ifinst_call_claim>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_ifinst_call_id";
    tf_data.calltf = &system_tf<&EndpointServicesVpi::ifinst_call_id>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_ifinst_call_next_ui";
    tf_data.calltf = &system_tf<&EndpointServicesVpi::ifinst_call_next_ui>;
    m_vpi->vpi_register_systf(&tf_data);

    tf_data.tfname = "$tblink_ifinst_call_complete";
    tf_data.type = vpiSysTask;
    tf_data.calltf = &system_tf<&EndpointServicesVpi::ifinst_call_complete>;
    m_vpi->vpi_register_systf(&tf_data);
#endif

    s_cb_data cbd;
    memset(&cbd, 0, sizeof(cbd));
    cbd.user_data = reinterpret_cast<PLI_BYTE8 *>(this);
    cbd.cb_rtn = &vpi_cb<&TblinkPluginVpi::on_startup>;
    cbd.reason = cbStartOfSimulation;
    m_vpi->vpi_register_cb(&cbd);
}

PLI_INT32 TblinkPluginVpi::on_startup() {
	DEBUG_ENTER("on_startup");
	ITbLink *tblink = TbLink::inst();
	t_vpi_vlog_info info;

	m_vpi->vpi_get_vlog_info(&info);

	// TODO: determine what (if anything) needs to be launched
	std::vector<std::string>							launch_args;
	std::vector<std::pair<std::string,std::string>>		launch_params;
	std::string launch;

	for (uint32_t i=0; i<info.argc; i++) {
		DEBUG("Arg[%d] %s", i, info.argv[i]);
		if (!strncmp(info.argv[i], "+tblink.launch=", strlen("+tblink.launch="))) {
			launch = &info.argv[i][strlen("+tblink.launch=")];
		} else if (!strncmp(info.argv[i], "+tblink.arg=", strlen("+tblink.arg="))) {
			launch_args.push_back(&info.argv[i][strlen("+tblink.arg=")]);
		} else if (!strncmp(info.argv[i], "+tblink.param", strlen("+tblink.param"))) {
			const char *pname_p = &info.argv[i][strlen("+tblink.param")+1];
			std::string pname_val = pname_p;
			int32_t eq_idx = pname_val.find('=');

			if (eq_idx == std::string::npos) {
				fprintf(stdout, "TbLink Error: malformed param plusarg %s\n", info.argv[i]);
				fflush(stdout);
				m_vpi->vpi_control(vpiFinish);
			} else {
				std::string pname = pname_val.substr(0, eq_idx);
				std::string pval = pname_val.substr(eq_idx+1);
				launch_params.push_back({pname, pval});
			}
		}
	}

	if (launch != "") {
		ILaunchType *launch_t = tblink->findLaunchType(launch);

		// We need the endpoint services for the default endpoint
		// to be active. The default services are passive
		EndpointServicesVpi *services = new EndpointServicesVpi(m_vpi);

		if (!launch_t) {
			fprintf(stdout, "TbLink Error: Failed to find launch type %s\n", launch.c_str());
			return -1;
		}

		ILaunchParams *params = launch_t->newLaunchParams();
		for (auto it=launch_args.begin(); it!=launch_args.end(); it++) {
			params->add_arg(*it);
		}
		for (auto it=launch_params.begin(); it!=launch_params.end(); it++) {
			params->add_param(it->first, it->second);
		}

		ILaunchType::result_t result = launch_t->launch(params, services);

		if (!result.first) {
			fprintf(stdout, "TbLink Error: Failed to launch %s: %s\n",
					launch.c_str(), result.second.c_str());
			fflush(stdout);
			m_vpi->vpi_control(vpiFinish);
			return -1;
		} else {
			VpiEndpointSequencer *seqr = new VpiEndpointSequencer(m_vpi, result.first);
			if (result.first->init(services) == -1) {
				fprintf(stdout, "TbLink Error: Initialization failed\n");
				m_vpi->vpi_control(vpiFinish);
				result.first = 0;
			}
		}

		tblink->setDefaultEP(result.first);
	}

	DEBUG_LEAVE("on_startup");
	return 0;
}


PLI_INT32 TblinkPluginVpi::ITbLink_inst() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();

	systf_h->val_ptr(static_cast<ITbLink *>(TbLink::inst()));
	return 0;
}

PLI_INT32 TblinkPluginVpi::ITbLink_get_default_ep() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();

	systf_h->val_ptr(TbLink::inst()->getDefaultEP());
	return 0;
}

PLI_INT32 TblinkPluginVpi::IEndpoint_defineInterfaceInst() {
	DEBUG_ENTER("IEndpoint_defineInterfaceInst");
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IEndpoint *ep = args->scan()->val_ptrT<IEndpoint>();
	IInterfaceType *iftype = args->scan()->val_ptrT<IInterfaceType>();
	std::string inst_name = args->scan()->val_str();
	bool is_mirror = args->scan()->val_bool();
	vpiHandle ev_h = args->scan()->hndl();

	VpiInterfaceInstWrapper *iwrap = new VpiInterfaceInstWrapper(
			m_vpi,
			ev_h);

	if (inst_name == "") {
		// Obtain the current module-scope name
		VpiHandleSP scope = systf_h->handle(vpiScope);
		inst_name = scope->get_str(vpiFullName);
	}

	DEBUG_ENTER("--> Calling defineInterfaceInst");
	IInterfaceInst *ifinst = ep->defineInterfaceInst(
			iftype,
			inst_name,
			is_mirror,
			std::bind(&VpiInterfaceInstWrapper::req_invoke, iwrap,
					std::placeholders::_1,
					std::placeholders::_2,
					std::placeholders::_3,
					std::placeholders::_4));
	DEBUG_LEAVE("--> Calling defineInterfaceInst");
	iwrap->ifinst(ifinst);

	systf_h->val_ptrT<VpiInterfaceInstWrapper>(iwrap);

	DEBUG_LEAVE("IEndpoint_defineInterfaceInst");
	return 0;
}

PLI_INT32 TblinkPluginVpi::IEndpoint_defineInterfaceType() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IEndpoint *ep = args->scan()->val_ptrT<IEndpoint>();
	IInterfaceTypeBuilder *iftype_b =
			args->scan()->val_ptrT<IInterfaceTypeBuilder>();

	systf_h->val_ptrT<IInterfaceType>(
			ep->defineInterfaceType(iftype_b));

	return 0;
}

PLI_INT32 TblinkPluginVpi::IEndpoint_findInterfaceType() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IEndpoint *ep = args->scan()->val_ptrT<IEndpoint>();
	std::string name = args->scan()->val_str();

	systf_h->val_ptrT(ep->findInterfaceType(name));

	return 0;
}

PLI_INT32 TblinkPluginVpi::IEndpoint_newInterfaceTypeBuilder() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IEndpoint *ep = args->scan()->val_ptrT<IEndpoint>();
	std::string name = args->scan()->val_str();

	systf_h->val_ptrT<IInterfaceTypeBuilder>(
			ep->newInterfaceTypeBuilder(name));

	return 0;
}

PLI_INT32 TblinkPluginVpi::InterfaceInstWrapper_invoke_b() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	/**
	 * ifinst
	 * method
	 * params
	 * retval
	 * done_ev
	 */
	VpiInterfaceInstWrapper *ifinst_w = args->scan()->val_ptrT<VpiInterfaceInstWrapper>();
	IInterfaceInst *ifinst = ifinst_w->ifinst();
	IMethodType *method = args->scan()->val_ptrT<IMethodType>();
	IParamValVec *params = dynamic_cast<IParamValVec *>(
			args->scan()->val_ptrT<IParamVal>());

	IParamVal *retval = 0;

	ifinst->invoke_nb(
			method,
			params,
			[&](IParamVal *retval_p) {
				if (retval_p) {
					retval = retval_p->clone();
				}
			});

	if (retval) {
		switch (retval->type()) {
		case IParamVal::Bool: {

		} break;
		case IParamVal::Int: {

		} break;
		case IParamVal::Map: {

		} break;
		}
		delete retval;
	} else {
		systf_h->val_i64(-1);
	}

	return 0;
}

PLI_INT32 TblinkPluginVpi::InterfaceInstWrapper_invoke_nb() {
	DEBUG_ENTER("InterfaceInstWrapper_invoke_nb");
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	/**
	 * ifinst
	 * method
	 * params
	 */
	VpiInterfaceInstWrapper *ifinst_w = args->scan()->val_ptrT<VpiInterfaceInstWrapper>();
	IInterfaceInst *ifinst = ifinst_w->ifinst();
	IMethodType *method = args->scan()->val_ptrT<IMethodType>();
	IParamValVec *params = dynamic_cast<IParamValVec *>(
			args->scan()->val_ptrT<IParamVal>());

	IParamVal *retval = 0;

	ifinst->invoke_nb(
			method,
			params,
			[&](IParamVal *retval_p) {
				if (retval_p) {
					retval = retval_p->clone();
				}
			});

	if (retval) {
		switch (retval->type()) {
		case IParamVal::Bool: {

		} break;
		case IParamVal::Int: {

		} break;
		case IParamVal::Map: {

		} break;
		}
		delete retval;
	} else {
		systf_h->val_i64(-1);
	}

	DEBUG_LEAVE("InterfaceInstWrapper_invoke_nb");
	return 0;
}

PLI_INT32 TblinkPluginVpi::InterfaceInstWrapper_mkValBool() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();
	VpiInterfaceInstWrapper *ifinst_w = args->scan()->val_ptrT<VpiInterfaceInstWrapper>();
	IInterfaceInst *ifinst = ifinst_w->ifinst();

	systf_h->val_ptrT<IParamVal>(
			static_cast<IParamVal *>(ifinst->mkValBool(
					args->scan()->val_bool())));
	return 0;
}

PLI_INT32 TblinkPluginVpi::InterfaceInstWrapper_mkValIntU() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();
	VpiInterfaceInstWrapper *ifinst_w = args->scan()->val_ptrT<VpiInterfaceInstWrapper>();
	IInterfaceInst *ifinst = ifinst_w->ifinst();

	uint64_t val = args->scan()->val_ui64();
	int32_t width = args->scan()->val_i32();

	systf_h->val_ptrT<IParamVal>(
			static_cast<IParamVal *>(ifinst->mkValIntU(
					val, width)));
	return 0;
}

PLI_INT32 TblinkPluginVpi::InterfaceInstWrapper_mkValIntS() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();
	VpiInterfaceInstWrapper *ifinst_w = args->scan()->val_ptrT<VpiInterfaceInstWrapper>();
	IInterfaceInst *ifinst = ifinst_w->ifinst();

	uint64_t val = args->scan()->val_ui64();
	int32_t width = args->scan()->val_i32();

	systf_h->val_ptrT<IParamVal>(
			static_cast<IParamVal *>(ifinst->mkValIntS(
					val, width)));
	return 0;
}

PLI_INT32 TblinkPluginVpi::InterfaceInstWrapper_mkValMap() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();
	VpiInterfaceInstWrapper *ifinst_w = args->scan()->val_ptrT<VpiInterfaceInstWrapper>();
	IInterfaceInst *ifinst = ifinst_w->ifinst();

	systf_h->val_ptrT<IParamVal>(
			static_cast<IParamVal *>(ifinst->mkValMap()));

	return 0;
}

PLI_INT32 TblinkPluginVpi::InterfaceInstWrapper_mkValStr() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();
	VpiInterfaceInstWrapper *ifinst_w = args->scan()->val_ptrT<VpiInterfaceInstWrapper>();
	IInterfaceInst *ifinst = ifinst_w->ifinst();

	std::string val = args->scan()->val_str();

	systf_h->val_ptrT<IParamVal>(
			static_cast<IParamVal *>(ifinst->mkValStr(val)));

	return 0;
}

PLI_INT32 TblinkPluginVpi::InterfaceInstWrapper_mkValVec() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();
	VpiInterfaceInstWrapper *ifinst_w = args->scan()->val_ptrT<VpiInterfaceInstWrapper>();
	IInterfaceInst *ifinst = ifinst_w->ifinst();

	systf_h->val_ptrT<IParamVal>(
			static_cast<IParamVal *>(ifinst->mkValVec()));

	return 0;
}

PLI_INT32 TblinkPluginVpi::InterfaceInstWrapper_nextInvokeReq() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();
	VpiInterfaceInstWrapper *ifinst_w = args->scan()->val_ptrT<VpiInterfaceInstWrapper>();

	IMethodType  *method = 0;
	intptr_t     call_id = 0;
	IParamValVec *params = 0;
	bool valid = ifinst_w->nextInvokeReq(
			&method,
			call_id,
			&params);

	args->scan()->val_ptrT<IMethodType>(method);
	args->scan()->val_i64(call_id);
	args->scan()->val_ptrT<IParamVal>(static_cast<IParamVal *>(params));

	systf_h->val_bool(valid);

	return 0;
}

PLI_INT32 TblinkPluginVpi::IInterfaceType_findMethod() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IInterfaceType *iftype = args->scan()->val_ptrT<IInterfaceType>();
	std::string name = args->scan()->val_str();

	IMethodType *method = iftype->findMethod(name);
	systf_h->val_ptrT<IMethodType>(method);

	return 0;
}

PLI_INT32 TblinkPluginVpi::InterfaceInstWrapper_invoke_rsp() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();
	VpiInterfaceInstWrapper *ifinst_w = args->scan()->val_ptrT<VpiInterfaceInstWrapper>();

	intptr_t call_id = args->scan()->val_i64();
	IParamVal *retval = args->scan()->val_ptrT<IParamVal>();

	ifinst_w->invoke_rsp(call_id, retval);

	return 0;
}

PLI_INT32 TblinkPluginVpi::IInterfaceTypeBuilder_mkTypeBool() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IInterfaceTypeBuilder *iftype_b =
			args->scan()->val_ptrT<IInterfaceTypeBuilder>();

	systf_h->val_ptrT<IType>(iftype_b->mkTypeBool());

	return 0;
}

PLI_INT32 TblinkPluginVpi::IInterfaceTypeBuilder_mkTypeInt() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IInterfaceTypeBuilder *iftype_b =
			args->scan()->val_ptrT<IInterfaceTypeBuilder>();
	bool is_signed = args->scan()->val_i32();
	int32_t width = args->scan()->val_i32();

	systf_h->val_ptrT<IType>(static_cast<IType *>(
			iftype_b->mkTypeInt(is_signed, width)));

	return 0;
}

PLI_INT32 TblinkPluginVpi::IInterfaceTypeBuilder_mkTypeMap() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IInterfaceTypeBuilder *iftype_b =
			args->scan()->val_ptrT<IInterfaceTypeBuilder>();
	IType *key_t = args->scan()->val_ptrT<IType>();
	IType *elem_t = args->scan()->val_ptrT<IType>();

	systf_h->val_ptrT<IType>(static_cast<IType *>(
			iftype_b->mkTypeMap(key_t, elem_t)));

	return 0;
}

PLI_INT32 TblinkPluginVpi::IInterfaceTypeBuilder_mkTypeStr() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IInterfaceTypeBuilder *iftype_b =
			args->scan()->val_ptrT<IInterfaceTypeBuilder>();

	systf_h->val_ptrT<IType>(iftype_b->mkTypeStr());

	return 0;
}

PLI_INT32 TblinkPluginVpi::IInterfaceTypeBuilder_mkTypeVec() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IInterfaceTypeBuilder *iftype_b =
			args->scan()->val_ptrT<IInterfaceTypeBuilder>();
	IType *elem_t = args->scan()->val_ptrT<IType>();

	systf_h->val_ptrT<IType>(static_cast<IType *>(
			iftype_b->mkTypeVec(elem_t)));

	return 0;
}

PLI_INT32 TblinkPluginVpi::IInterfaceTypeBuilder_newMethodTypeBuilder() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	VpiHandleSP iftype_b_h = args->scan();
	fprintf(stdout, "iftype_b_h: %p\n", iftype_b_h->hndl());
	fflush(stdout);

	IInterfaceTypeBuilder *iftype_b = iftype_b_h->val_ptrT<IInterfaceTypeBuilder>();
//			args->scan()->val_ptrT<IInterfaceTypeBuilder>();
	std::string name = args->scan()->val_str();
	intptr_t id = args->scan()->val_i64();
	IType *rtype = args->scan()->val_ptrT<IType>();
	bool is_export = args->scan()->val_i32();
	bool is_blocking = args->scan()->val_i32();

	systf_h->val_ptrT<IMethodTypeBuilder>(
			iftype_b->newMethodTypeBuilder(
					name,
					id,
					rtype,
					is_export,
					is_blocking));
	return 0;
}

PLI_INT32 TblinkPluginVpi::IInterfaceTypeBuilder_add_method() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	VpiHandleSP iftype_b_h = args->scan();
	IInterfaceTypeBuilder *iftype_b = iftype_b_h->val_ptrT<IInterfaceTypeBuilder>();
//			args->scan()->val_ptrT<IInterfaceTypeBuilder>();
	VpiHandleSP method_b_h = args->scan();
	IMethodTypeBuilder *method_b = method_b_h->val_ptrT<IMethodTypeBuilder>();
//			args->scan()->val_ptrT<IMethodTypeBuilder>();

	systf_h->val_ptrT<IMethodType>(
			iftype_b->add_method(method_b));

	return 0;
}

PLI_INT32 TblinkPluginVpi::IMethodType_id() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IMethodType *method = args->scan()->val_ptrT<IMethodType>();
	systf_h->val_i64(method->id());

	return 0;
}

PLI_INT32 TblinkPluginVpi::IMethodTypeBuilder_add_param() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IMethodTypeBuilder *method_b =
			args->scan()->val_ptrT<IMethodTypeBuilder>();
	std::string name = args->scan()->val_str();
	IType *type = args->scan()->val_ptrT<IType>();

	method_b->add_param(name, type);

	return 0;
}

PLI_INT32 TblinkPluginVpi::IParamValInt_val_s() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IParamValInt *param = dynamic_cast<IParamValInt *>(
			args->scan()->val_ptrT<IParamVal>());
	systf_h->val_i64(param->val_s());

	return 0;
}

PLI_INT32 TblinkPluginVpi::IParamValInt_val_u() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IParamValInt *param = dynamic_cast<IParamValInt *>(
			args->scan()->val_ptrT<IParamVal>());
	systf_h->val_ui64(param->val_u());

	return 0;
}

PLI_INT32 TblinkPluginVpi::IParamValVec_at() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IParamValVec *vec = dynamic_cast<IParamValVec *>(
			args->scan()->val_ptrT<IParamVal>());
	uint32_t idx = args->scan()->val_ui64();
	systf_h->val_ptrT<IParamVal>(vec->at(idx));

	return 0;
}

PLI_INT32 TblinkPluginVpi::IParamValVec_push_back() {
	VpiHandleSP systf_h = m_vpi_glbl->systf_h();
	VpiHandleSP args = systf_h->tf_args();

	IParamValVec *vec = dynamic_cast<IParamValVec *>(
			args->scan()->val_ptrT<IParamVal>());
	IParamVal *val = args->scan()->val_ptrT<IParamVal>();
	vec->push_back(val);

	return 0;
}

} /* namespace tblink_rpc_hdl */
