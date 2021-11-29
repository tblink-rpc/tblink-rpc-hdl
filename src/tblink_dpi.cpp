
/*****************************************************************************
 * tblink_dpi.cpp
 *
 * Implements interface routines specific to SystemVerilog
 *
 *  Created on: Dec 13, 2020
 *      Author: mballance
 *****************************************************************************/
#define EXTERN_C extern "C"
#include <stdio.h>
#include "vpi_user.h"
#include <signal.h>
#include <string>
#include <vector>
#include <dlfcn.h>
#include <memory>
#include "dpi_api.h"
#include "vpi_api.h"
#include "ILaunch.h"
#include "EndpointServicesDpi.h"
#include "InvokeInfoDpi.h"
#include "ParamValVec.h"
#include "ParamValStr.h"
#include "TbLink.h"
#include "TblinkPluginDpi.h"
#include "TimeCallbackClosureDpi.h"
#include "glog/logging.h"
#include "tblink_rpc/tblink_rpc.h"

typedef void *chandle;

using namespace tblink_rpc_core;
using namespace tblink_rpc_hdl;

static dpi_api_t				prv_dpi;
static void						*prv_pkg_scope = 0;
static TblinkPluginDpi			*prv_plugin = 0;
static char						prv_msgbuf[128];

static void *get_pkg_scope() {
	return prv_pkg_scope;
}

static void tblink_dpi_atexit() {
	fprintf(stdout, "tblink_dpi_atexit\n");
	/*
	if (prv_endpoint) {
		prv_endpoint->shutdown();
	}
	 */
}

static void tblink_dpi_sigpipe(int sig) {
	fprintf(stdout, "tblink_vpi_sigpipe\n");
	fflush(stdout);
	/*
	if (prv_endpoint) {
		prv_endpoint->shutdown();
	}
	 */
}

static void elab_cb(intptr_t callback_id) {
	fprintf(stdout, "elab_cb\n");
	/*
	if (!prv_registered) {
		fprintf(stdout, "completing registration\n");

		prv_endpoint->build_complete();

		prv_endpoint->connect_complete();

		// Wait for next event
		prv_services->idle();
	}
	 */
}

static TblinkPluginDpi *get_plugin() {
	if (!prv_plugin) {
		ITbLink *tblink = TbLink::inst();
		ISymFinder *sym_finder = tblink->sym_finder();
		vpi_api_t *vpi_api = get_vpi_api(sym_finder);

		if (!vpi_api) {
			fprintf(stdout, "Error: Failed to obtain VPI API\n");
			fflush(stdout);
			return 0;
		}

		memset(&prv_dpi, 0, sizeof(prv_dpi));
		prv_dpi.svGetScope = sym_finder->findSymT<void *(*)()>("svGetScope");
		prv_dpi.svSetScope = sym_finder->findSymT<void *(*)(void *)>("svSetScope");
		prv_dpi.get_pkg_scope = &get_pkg_scope;
		prv_dpi.invoke = sym_finder->findSymT<void (*)(void*,void*,intptr_t,void*)>("tblink_rpc_invoke");
		prv_dpi.add_time_cb = sym_finder->findSymT<void (*)(void*,uint64_t)>("tblink_rpc_add_time_cb");
		prv_dpi.delta_cb = sym_finder->findSymT<void (*)()>("tblink_rpc_delta_cb");
		prv_dpi.dispatch_cb = sym_finder->findSymT<int (*)()>("tblink_rpc_dispatch_cb");

		prv_plugin = new TblinkPluginDpi(
				vpi_api,
				&prv_dpi);
	}

	return prv_plugin;
}

EXTERN_C int _tblink_rpc_pkg_init(
		unsigned int		have_blocking_tasks,
		int32_t				*time_precision) {
	TblinkPluginDpi *plugin = get_plugin();

	if (!plugin) {
		fprintf(stdout, "Tblink Error: failed to initialize plugin\n");
		return 0;
	}

	// Capture the package scope handle so we can
	// call back into package methods
	prv_pkg_scope = plugin->dpi_api()->svGetScope();

	*time_precision = plugin->vpi_api()->vpi_get(vpiTimePrecision, 0);
	plugin->have_blocking_tasks(have_blocking_tasks);

	return 1;
}

EXTERN_C chandle tblink_rpc_InvokeInfo_ifinst(chandle ii) {
	return reinterpret_cast<void *>(
			reinterpret_cast<InvokeInfoDpi *>(ii)->inst());
}

EXTERN_C chandle tblink_rpc_InvokeInfo_method(chandle ii) {
	return reinterpret_cast<void *>(
			reinterpret_cast<InvokeInfoDpi *>(ii)->method());
}

EXTERN_C chandle tblink_rpc_InvokeInfo_params(chandle ii_h) {
	return reinterpret_cast<void *>(
			static_cast<IParamVal *>(
					reinterpret_cast<InvokeInfoDpi *>(ii_h)->params()));
}

EXTERN_C void tblink_rpc_InvokeInfo_invoke_rsp(chandle ii_h, chandle retval_h) {
	InvokeInfoDpi *ii = reinterpret_cast<InvokeInfoDpi *>(ii_h);
	ii->inst()->invoke_rsp(
			ii->call_id(),
			reinterpret_cast<IParamVal *>(retval_h));
	delete ii;
}

EXTERN_C void *_tblink_rpc_endpoint_new(int have_blocking_tasks) {
#ifdef UNDEFINED
	// TODO: need to

	if (!prv_endpoint) {
		vpi_api_t *vpi_api = get_vpi_api();

		fprintf(stdout, "_tblink_rpc_pkg_init\n");
		fflush(stdout);

		memset(&prv_dpi, 0, sizeof(prv_dpi));
		prv_dpi.svGetScope = &svGetScope;
		prv_dpi.svSetScope = &svSetScope;
		prv_dpi.get_pkg_scope = &get_pkg_scope;
		prv_dpi.invoke_nb = &_tblink_rpc_invoke_nb;
		prv_dpi.invoke_b = &_tblink_rpc_invoke_b;
		prv_dpi.add_time_cb = &_tblink_rpc_add_time_cb;

		// Add a shutdown callback if the simulator closes down unexpectedly
		atexit(&tblink_dpi_atexit);
		signal(SIGPIPE, &tblink_dpi_sigpipe);

		if (!vpi_api) {
			fprintf(stdout, "Error: failed to load vpi API (%s)\n",
					get_vpi_api_error());
			return 0;
		}

		prv_services = EndpointServicesDpiUP(new EndpointServicesDpi(
				&prv_dpi,
				vpi_api,
				have_blocking_tasks));


	    // Create the endpoint
	    ILaunch *launcher = tblink_rpc_hdl_launcher();

	    if (!launcher) {
	    	fprintf(stdout, "Error: failed to obtain launcher\n");
	    	return 0;
	    }

//	    *time_precision = prv_services->time_precision();

	    prv_endpoint = IEndpointUP(launcher->create_ep(prv_services.get()));
	}

	return reinterpret_cast<void *>(prv_endpoint.get());
#endif
}

EXTERN_C chandle _tblink_rpc_endpoint_default() {
	return reinterpret_cast<chandle>(prv_plugin->endpoint());
}

EXTERN_C int tblink_rpc_IEndpoint_build_complete(
		chandle				endpoint_h) {
	int32_t ret = 0;
	IEndpoint *ep = reinterpret_cast<IEndpoint *>(endpoint_h);
	if (ep->build_complete() != 0) {
		return -1;
	}

	while ((ret=ep->is_build_complete()) == 0) {
		if (ep->process_one_message() == -1) {
			ret = -1;
			break;
		}
	}

	return ret;
}

EXTERN_C int tblink_rpc_IEndpoint_connect_complete(
		chandle			endpoint_h) {
	IEndpoint *ep = reinterpret_cast<IEndpoint *>(endpoint_h);
	int ret = ep->connect_complete();

	if (ret == -1) {
		return ret;
	}

	while ((ret=ep->is_connect_complete()) == 0) {
		if (ep->process_one_message() == -1) {
			ret = -1;
			break;
		}
	}

	return ret;
}

EXTERN_C int _tblink_rpc_IEndpoint_await_run_until_event(
		chandle			endpoint_h) {
	return reinterpret_cast<IEndpoint *>(endpoint_h)->await_run_until_event();
}

EXTERN_C char *tblink_rpc_IEndpoint_last_error(chandle endpoint_h) {
	strncpy(prv_msgbuf,
			reinterpret_cast<IEndpoint *>(endpoint_h)->last_error().c_str(),
			sizeof(prv_msgbuf));
	return prv_msgbuf;
}

EXTERN_C int _tblink_rpc_endpoint_shutdown(void *endpoint_h) {
	return reinterpret_cast<IEndpoint *>(endpoint_h)->shutdown();
}

EXTERN_C void *tblink_rpc_IEndpoint_findInterfaceType(
		void			*endpoint_h,
		const char		*name) {
	fprintf(stdout, "findInterfaceType: %p %s\n", endpoint_h, name);
	fflush(stdout);
	return reinterpret_cast<void *>(
			reinterpret_cast<IEndpoint *>(endpoint_h)->findInterfaceType(name));
}

EXTERN_C chandle tblink_rpc_IEndpoint_newInterfaceTypeBuilder(
		void 			*endpoint_h,
		const char		*name) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<IEndpoint *>(endpoint_h)->newInterfaceTypeBuilder(name));
}

EXTERN_C chandle tblink_rpc_IInterfaceTypeBuilder_mkTypeBool(
		chandle				iftype_b) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<IInterfaceTypeBuilder *>(iftype_b)->mkTypeBool());
}

EXTERN_C chandle tblink_rpc_IInterfaceTypeBuilder_mkTypeInt(
		chandle				iftype_b,
		uint32_t			is_signed,
		uint32_t			width) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<IInterfaceTypeBuilder *>(iftype_b)->mkTypeInt(
					is_signed,
					width));
}

EXTERN_C chandle tblink_rpc_IInterfaceTypeBuilder_mkTypeMap(
		chandle				iftype_b,
		chandle				key_t,
		chandle				elem_t) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<IInterfaceTypeBuilder *>(iftype_b)->mkTypeMap(
					reinterpret_cast<IType *>(key_t),
					reinterpret_cast<IType *>(elem_t)));
}

EXTERN_C chandle tblink_rpc_IInterfaceTypeBuilder_mkTypeStr(
		chandle				iftype_b) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<IInterfaceTypeBuilder *>(iftype_b)->mkTypeStr());
}

EXTERN_C chandle tblink_rpc_IInterfaceTypeBuilder_mkTypeVec(
		chandle				iftype_b,
		chandle				elem_t) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<IInterfaceTypeBuilder *>(iftype_b)->mkTypeVec(
					reinterpret_cast<IType *>(elem_t)));
}

EXTERN_C int tblink_rpc_IType_kind(
		chandle				itype_h) {
	return int(reinterpret_cast<IType *>(itype_h)->kind());
}

EXTERN_C chandle tblink_rpc_IInterfaceTypeBuilder_newMethodTypeBuilder(
		chandle				iftype_b,
		const char			*name,
		intptr_t			id,
		chandle				rtype,
		uint32_t			is_export,
		uint32_t			is_blocking) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<IInterfaceTypeBuilder *>(iftype_b)->newMethodTypeBuilder(
					name,
					id,
					reinterpret_cast<IType *>(rtype),
					is_export,
					is_blocking));
}

EXTERN_C chandle tblink_rpc_IInterfaceTypeBuilder_add_method(
		chandle				iftype_b,
		chandle				mtb) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<IInterfaceTypeBuilder *>(iftype_b)->add_method(
					reinterpret_cast<IMethodTypeBuilder *>(mtb)));
}

EXTERN_C void tblink_rpc_IMethodTypeBuilder_add_param(
		chandle				method_b,
		const char			*name,
		chandle				type_h) {
	reinterpret_cast<IMethodTypeBuilder *>(method_b)->add_param(
			name,
			reinterpret_cast<IType *>(type_h));
}

EXTERN_C void *_tblink_rpc_iftype_builder_define_method(
			void			*iftype_b,
			const char 		*name,
			int64_t			id,
			const char		*signature,
			uint32_t		is_export,
			uint32_t		is_blocking) {
	/* TODO:
	return reinterpret_cast<void *>(
			reinterpret_cast<IInterfaceTypeBuilder *>(iftype_b)->define_method(
					name,
					id,
					signature,
					is_export,
					is_blocking));
     */
	return 0;
}


EXTERN_C void *tblink_rpc_IEndpoint_defineInterfaceType(
		void 			*endpoint_h,
		void			*iftype_builder_h) {
	return reinterpret_cast<void *>(
			reinterpret_cast<IEndpoint *>(endpoint_h)->defineInterfaceType(
					reinterpret_cast<IInterfaceTypeBuilder *>(iftype_builder_h)));
}

static void invoke_req(
		tblink_rpc_core::IInterfaceInst			*inst,
		tblink_rpc_core::IMethodType			*method,
		intptr_t								call_id,
		tblink_rpc_core::IParamValVec			*params) {
	dpi_api_t *dpi_api = prv_plugin->dpi_api();
	dpi_api->svSetScope(dpi_api->get_pkg_scope());

	dpi_api->invoke(
			reinterpret_cast<chandle>(inst),
			reinterpret_cast<chandle>(method),
			call_id,
			reinterpret_cast<chandle>(
					static_cast<IParamVal *>(params)));
	fflush(stdout);
}

EXTERN_C chandle _tblink_rpc_IEndpoint_defineInterfaceInst(
		void 			*endpoint_h,
		void			*iftype_h,
		const char		*inst_name,
		unsigned int	is_mirror) {
	IEndpoint *endpoint = reinterpret_cast<IEndpoint *>(endpoint_h);
	return reinterpret_cast<void *>(
			reinterpret_cast<IEndpoint *>(endpoint_h)->defineInterfaceInst(
					reinterpret_cast<IInterfaceType *>(iftype_h),
					inst_name,
					is_mirror,
					std::bind(&invoke_req,
							std::placeholders::_1,
							std::placeholders::_2,
							std::placeholders::_3,
							std::placeholders::_4)));
}

EXTERN_C int32_t tblink_rpc_IEndpoint_process_one_message(
		chandle			endpoint_h) {
	return reinterpret_cast<IEndpoint *>(endpoint_h)->process_one_message();
}

EXTERN_C uint32_t tblink_rpc_IEndpoint_getInterfaceInstCount(
		chandle			endpoint_h) {
	return reinterpret_cast<IEndpoint *>(endpoint_h)->getInterfaceInsts().size();
}

EXTERN_C chandle tblink_rpc_IEndpoint_getInterfaceInstAt(
		chandle			endpoint_h,
		uint32_t		idx) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<IEndpoint *>(endpoint_h)->getInterfaceInsts().at(idx));
}

EXTERN_C void tblink_rpc_notify_time_cb(void *cb_data) {
	TimeCallbackClosureDpi *closure = reinterpret_cast<TimeCallbackClosureDpi *>(cb_data);
	closure->notify();
	delete closure;
}

EXTERN_C chandle tblink_rpc_iftype_find_method(
		chandle			iftype_h,
		const char 		*name) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<IInterfaceType *>(iftype_h)->findMethod(name));
}

EXTERN_C const char *tblink_rpc_IMethodType_name(void *hndl) {
	return reinterpret_cast<IMethodType *>(hndl)->name().c_str();
}

EXTERN_C int64_t tblink_rpc_IMethodType_id(void *hndl) {
	return reinterpret_cast<IMethodType *>(hndl)->id();
}

EXTERN_C uint32_t tblink_rpc_IMethodType_is_export(chandle hndl) {
	return reinterpret_cast<IMethodType *>(hndl)->is_export();
}

EXTERN_C uint32_t tblink_rpc_IMethodType_is_blocking(chandle hndl) {
	return reinterpret_cast<IMethodType *>(hndl)->is_blocking();
}

EXTERN_C void tblink_rpc_IParamVal_dispose(chandle hndl) {
	delete reinterpret_cast<IParamVal *>(hndl);
}

EXTERN_C uint64_t tblink_rpc_IParamValInt_val_s(chandle hndl_h) {
	return dynamic_cast<IParamValInt *>(
			reinterpret_cast<IParamVal *>(hndl_h))->val_s();
}

EXTERN_C uint64_t tblink_rpc_IParamValInt_val_u(chandle hndl_h) {
	return dynamic_cast<IParamValInt *>(
			reinterpret_cast<IParamVal *>(hndl_h))->val_u();
}

EXTERN_C void *_tblink_rpc_iparam_val_clone(void *hndl) {
	IParamVal *ret = reinterpret_cast<IParamVal *>(hndl)->clone();
	return reinterpret_cast<void *>(ret);
}
EXTERN_C uint32_t _tblink_rpc_iparam_val_type(void *hndl) {
	return reinterpret_cast<IParamVal *>(hndl)->type();
}

EXTERN_C uint32_t _tblink_rpc_iparam_val_bool_val(void *hndl) {
	return dynamic_cast<IParamValBool *>(
			reinterpret_cast<IParamVal *>(hndl))->val();
}

EXTERN_C uint32_t tblink_rpc_IParamValMap_hasKey(
		chandle			map_h,
		const char		*key) {
	return dynamic_cast<IParamValMap *>(
			reinterpret_cast<IParamVal *>(map_h))->hasKey(key);
}

EXTERN_C chandle tblink_rpc_IParamValMap_getVal(
		chandle			map_h,
		const char		*key) {
	return reinterpret_cast<chandle>(
			static_cast<IParamVal *>(
					dynamic_cast<IParamValMap *>(
							reinterpret_cast<IParamVal *>(map_h))->getVal(key)));
}

EXTERN_C void tblink_rpc_IParamValMap_setVal(
		chandle			map_h,
		const char		*key,
		chandle			val_h) {
	dynamic_cast<IParamValMap *>(reinterpret_cast<IParamVal *>(map_h))->setVal(
			key,
			reinterpret_cast<IParamVal *>(val_h));
}

EXTERN_C const char *tblink_rpc_IParamValStr_val(chandle hndl) {
	strcpy(prv_msgbuf, dynamic_cast<IParamValStr *>(
			reinterpret_cast<IParamVal *>(hndl))->val().c_str());
	return prv_msgbuf;
}

EXTERN_C uint32_t tblink_rpc_IParamValVec_size(void *hndl) {
	return dynamic_cast<IParamValVec *>(
			reinterpret_cast<IParamVal *>(hndl))->size();
}

EXTERN_C chandle tblink_rpc_IParamValVec_at(chandle hndl, uint32_t idx) {
	return reinterpret_cast<chandle>(
			dynamic_cast<IParamValVec *>(reinterpret_cast<IParamVal *>(hndl))->at(idx));
}

EXTERN_C void tblink_rpc_IParamValVec_push_back(chandle hndl, chandle val_h) {
	dynamic_cast<IParamValVec *>(reinterpret_cast<IParamVal *>(hndl))->push_back(
			reinterpret_cast<IParamVal *>(val_h));
}

EXTERN_C char *tblink_rpc_IInterfaceInst_name(
		chandle			ifinst_h) {
	strncpy(prv_msgbuf,
			reinterpret_cast<IInterfaceInst *>(ifinst_h)->name().c_str(),
			sizeof(prv_msgbuf));
	return prv_msgbuf;
}

EXTERN_C chandle tblink_rpc_IInterfaceInst_type(
		chandle			ifinst_h) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<IInterfaceInst *>(ifinst_h)->type());
}

EXTERN_C uint32_t tblink_rpc_IInterfaceInst_is_mirror(
		chandle			ifinst_h) {
	return reinterpret_cast<IInterfaceInst *>(ifinst_h)->is_mirror();
}

EXTERN_C void tblink_rpc_IInterfaceInst_invoke_rsp(
		chandle			ifinst_h,
		intptr_t		call_id,
		chandle			retval) {
	reinterpret_cast<IInterfaceInst *>(ifinst_h)->invoke_rsp(
			call_id,
			reinterpret_cast<IParamVal *>(retval));
}

EXTERN_C chandle tblink_rpc_IInterfaceInst_mkValBool(
		chandle			ifinst_h,
		uint32_t		val) {
	return reinterpret_cast<chandle>(
			dynamic_cast<IParamVal *>(
					reinterpret_cast<IInterfaceInst *>(ifinst_h)->mkValBool(val)
					));
}

EXTERN_C chandle tblink_rpc_IInterfaceInst_mkValIntU(
		chandle			ifinst_h,
		uint64_t		val,
		uint32_t		width) {
	return reinterpret_cast<chandle>(
			dynamic_cast<IParamVal *>(
				reinterpret_cast<IInterfaceInst *>(ifinst_h)->mkValIntU(
						val,
						width)));
}

EXTERN_C chandle tblink_rpc_IInterfaceInst_mkValIntS(
		chandle			ifinst_h,
		int64_t			val,
		uint32_t		width) {
	return reinterpret_cast<chandle>(
			dynamic_cast<IParamVal *>(
					reinterpret_cast<IInterfaceInst *>(ifinst_h)->mkValIntS(
							val,
							width)));
}

EXTERN_C chandle tblink_rpc_IInterfaceInst_mkValMap(
		chandle			ifinst_h) {
	return reinterpret_cast<IInterfaceInst *>(ifinst_h)->mkValMap();
}

EXTERN_C chandle tblink_rpc_IInterfaceInst_mkValStr(
		chandle			ifinst_h,
		const char		*val) {
	return reinterpret_cast<chandle>(
			dynamic_cast<IParamVal *>(
					reinterpret_cast<IInterfaceInst *>(ifinst_h)->mkValStr(val)));
}

EXTERN_C chandle tblink_rpc_IInterfaceInst_mkValVec(
		chandle			ifinst_h) {
	return reinterpret_cast<chandle>(
			dynamic_cast<IParamVal *>(
					reinterpret_cast<IInterfaceInst *>(ifinst_h)->mkValVec()));
}

EXTERN_C chandle _tblink_rpc_ifinst_invoke_nb(
		chandle			ifinst_h,
		chandle			method_h,
		chandle			params_h) {
	// TODO:
	/* TODO:
	return reinterpret_cast<chandle>(
			reinterpret_cast<IInterfaceInst *>(ifinst_h)->invoke_nb(
					reinterpret_cast<IMethodType *>(method_h),
					dynamic_cast<IParamValVec *>(
							reinterpret_cast<IParamVal *>(params_h))));
     */
	return 0;
}

EXTERN_C chandle tblink_rpc_findLaunchType(const char *id) {
	return reinterpret_cast<chandle>(TbLink::inst()->findLaunchType(id));
}

EXTERN_C void tblink_rpc_ILaunchParams_add_arg(
		chandle				params,
		const char			*arg) {
	reinterpret_cast<ILaunchParams *>(params)->add_arg(arg);
}

EXTERN_C void tblink_rpc_ILaunchParams_add_param(
		chandle				params,
		const char			*key,
		const char			*val) {
	reinterpret_cast<ILaunchParams *>(params)->add_param(key, val);
}

EXTERN_C chandle tblink_rpc_ILaunchType_newLaunchParams(chandle launch) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<ILaunchType *>(launch)->newLaunchParams());
}

EXTERN_C chandle tblink_rpc_ILaunchType_launch(
		chandle				launch,
		chandle				params,
		char				**error) {
	ILaunchType::result_t res = reinterpret_cast<ILaunchType *>(launch)->launch(
			reinterpret_cast<ILaunchParams *>(params));
	TblinkPluginDpi *plugin = get_plugin();

	if (!plugin) {
		strcpy(prv_msgbuf, "Failed to initialize DPI plug-in");
		*error = prv_msgbuf;
		return 0;
	}

	if (!res.first) {
		strncpy(prv_msgbuf, res.second.c_str(), sizeof(prv_msgbuf));
		*error = prv_msgbuf;
		return 0;
	} else {
		*error = (char *)"";
	}

	// Run the initialization phase
	if (res.first->init(
			new EndpointServicesDpi(
					plugin->dpi_api(),
					plugin->vpi_api(),
					plugin->have_blocking_tasks()),
			0) != 0) {
		strncpy(prv_msgbuf, res.first->last_error().c_str(), sizeof(prv_msgbuf));
		*error = prv_msgbuf;
		return 0;
	}

	int ret;
	while ((ret = res.first->is_init()) == 0) {
		if ((ret = res.first->process_one_message()) == -1) {
			break;
		}
	}

	if (ret != 1) {
		strncpy(prv_msgbuf, res.first->last_error().c_str(), sizeof(prv_msgbuf));
		return 0;
	}

	return res.first;
}

EXTERN_C const char *tblink_rpc_libpath() {
	ITbLink *tbl = TbLink::inst();
	strcpy(prv_msgbuf, tbl->getLibPath().c_str());
	return prv_msgbuf;
}

EXTERN_C int tblink_rpc_register_dpi_bfm(
		const char				*inst_path,
		const char				*invoke_nb_f,
		const char				*invoke_b_f) {
	TblinkPluginDpi *plugin = get_plugin();

	return plugin->register_dpi_bfm(
			inst_path, invoke_nb_f, invoke_b_f);
}

EXTERN_C chandle tblink_rpc_invoke_nb_dpi_bfm(
		const char				*inst_path,
		chandle					ifinst,
		chandle					method,
		chandle					params) {
	chandle ret = 0;
	TblinkPluginDpi *plugin = get_plugin();
	TblinkPluginDpi::invoke_info_t invoke_i =
			plugin->get_dpi_invoke_info(inst_path);

	if (std::get<1>(invoke_i) == 0) {
		fprintf(stdout,
				"TbLink Error: No DPI-invoke functions registered for scope %s\n",
				inst_path);
		fflush(stdout);
	} else {
		plugin->dpi_api()->svSetScope(std::get<0>(invoke_i));
		ret = std::get<1>(invoke_i)(ifinst, method, params);
	}

	return ret;
}

EXTERN_C int tblink_rpc_invoke_b_dpi_bfm(
		const char				*inst_path,
		chandle					*retval,
		chandle					ifinst,
		chandle					method,
		chandle					params) {
	*retval = 0;

	TblinkPluginDpi *plugin = get_plugin();
	TblinkPluginDpi::invoke_info_t invoke_i =
			plugin->get_dpi_invoke_info(inst_path);

	if (!std::get<2>(invoke_i)) {
		fprintf(stdout,
				"TbLink Error: No DPI-invoke functions registered for scope %s\n",
				inst_path);
	} else {
		plugin->dpi_api()->svSetScope(std::get<0>(invoke_i));
		return std::get<2>(invoke_i)(retval, ifinst, method, params);
	}

	return 0;
}

EXTERN_C chandle _tblink_rpc_get_plusargs(
		const char				*prefix) {
	TblinkPluginDpi *plugin = get_plugin();
	vpi_api_t *vpi_api = plugin->vpi_api();

	if (!vpi_api) {
		fprintf(stdout, "TbLink Fatal: failed to find VPI functions\n");
		return 0;
	}

	ParamValVec *ret = new ParamValVec();
	uint32_t prefix_len = strlen(prefix);
    s_vpi_vlog_info info;

    fprintf(stdout, "--> get_plusargs\n");
    fflush(stdout);

    vpi_api->vpi_get_vlog_info(&info);

    fprintf(stdout, "-- post-get-args\n");
    fflush(stdout);

    for (int32_t i=0; i<info.argc; i++) {
    	int32_t arg_len = strlen(info.argv[i]);

		fprintf(stdout, "arg: %s\n", info.argv[i]);
    	// Ensure arg is longer than +<prefix>=
    	if (arg_len > prefix_len+2) {
    		if (!strncmp(&info.argv[i][1], prefix, prefix_len) &&
    				info.argv[i][prefix_len+1] == '=') {
    			ret->push_back(new ParamValStr(&info.argv[i][prefix_len+2]));
    		}
    	}
    }

    fprintf(stdout, "<-- get_plusargs %p\n", ret);
    fflush(stdout);

	return reinterpret_cast<chandle>(static_cast<IParamVal *>(ret));
}

/********************************************************************
 * Delta callback support for automatic endpoint bring-up
 * Note: these functions are only used when running with Verilator,
 * since Verilator doesn't support behavior timing constructs (eg #10)
 ********************************************************************/

static PLI_INT32 _tblink_rpc_delta_cb(p_cb_data cbd) {
	TblinkPluginDpi *plugin = get_plugin();
	plugin->dpi_api()->svSetScope(prv_pkg_scope);
	plugin->dpi_api()->delta_cb();
	return 0;
}

EXTERN_C void tblink_rpc_register_delta_cb() {
	s_cb_data cbd;
	s_vpi_time vt;
	TblinkPluginDpi *plugin = get_plugin();

	memset(&cbd, 0, sizeof(cbd));
	memset(&vt, 0, sizeof(vt));

	vt.type = vpiSimTime;
	cbd.reason = cbAfterDelay;
	cbd.cb_rtn = &_tblink_rpc_delta_cb;
	cbd.time = &vt;
	plugin->vpi_api()->vpi_register_cb(&cbd);
}

static PLI_INT32 _tblink_rpc_dispatch_cb(p_cb_data cbd) {
	TblinkPluginDpi *plugin = get_plugin();
	plugin->dpi_api()->svSetScope(prv_pkg_scope);
	int ret = plugin->dpi_api()->dispatch_cb();
	return 0;
}

EXTERN_C void tblink_rpc_register_dispatch_cb() {
	s_cb_data cbd;
	s_vpi_time vt;
	TblinkPluginDpi *plugin = get_plugin();

	memset(&cbd, 0, sizeof(cbd));
	memset(&vt, 0, sizeof(vt));

	vt.type = vpiSimTime;
	cbd.reason = cbAfterDelay;
	cbd.cb_rtn = &_tblink_rpc_dispatch_cb;
	cbd.time = &vt;
	plugin->vpi_api()->vpi_register_cb(&cbd);
}

