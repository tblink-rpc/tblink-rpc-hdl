
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
#include <string.h>
#include "vpi_user.h"
#include <signal.h>
#include <string>
#include <vector>
#include <dlfcn.h>
#include <memory>
#include "dpi_api.h"
#include "vpi_api.h"
#include "DpiEndpointLoopback.h"
#include "DpiEndpointLoopbackVpi.h"
#include "DpiEndpointListenerProxy.h"
#include "DpiEndpointServicesProxy.h"
#include "DpiInterfaceImplProxy.h"
#include "DpiInterfaceImplFactoryProxy.h"
#include "DpiLaunchParamsProxy.h"
#include "DpiTbLinkListenerProxy.h"
#include "EndpointServicesDpi.h"
#include "EndpointServicesDpiFactory.h"
#include "InterfaceInstInvokeClosure.h"
#include "ParamValVec.h"
#include "ParamValStr.h"
#include "TbLink.h"
#include "TblinkPluginDpi.h"
#include "TimeCallbackClosureDpi.h"
#include "tblink_rpc/tblink_rpc.h"

typedef void *chandle;

using namespace tblink_rpc_core;
using namespace tblink_rpc_hdl;

static dpi_api_t				prv_dpi;
static void						*prv_pkg_scope = 0;
static TblinkPluginDpi			*prv_plugin = 0;
static char						prv_msgbuf[128];

static TblinkPluginDpi *get_plugin();

static void *get_pkg_scope() {
	TblinkPluginDpi *plugin = get_plugin();
	if (!prv_pkg_scope) {
		prv_pkg_scope = prv_dpi.svGetScope();
	}
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

static void tblink_rpc_toggle_vpi_ev();

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
//		prv_dpi.invoke = sym_finder->findSymT<void (*)(void*,void*,intptr_t,void*)>("tblink_rpc_invoke");
		prv_dpi.add_time_cb = sym_finder->findSymT<void (*)(void*,uint64_t)>("tblink_rpc_add_time_cb");
		prv_dpi.delta_cb = sym_finder->findSymT<void (*)()>("tblink_rpc_delta_cb");
		prv_dpi.dispatch_cb = sym_finder->findSymT<int (*)()>("tblink_rpc_dispatch_cb");
		prv_dpi.eps_proxy_add_time_cb = sym_finder->findSymT<int(*)(void*,uint64_t,intptr_t)>(
				"tblink_rpc_DpiEndpointServicesProxy_add_time_cb");
		prv_dpi.eps_proxy_time = sym_finder->findSymT<uint64_t(*)(void*)>(
				"tblink_rpc_DpiEndpointServicesProxy_time");
		prv_dpi.eps_proxy_shutdown = sym_finder->findSymT<void(*)(void*)>("tblink_rpc_DpiEndpointServicesProxy_shutdown");

		prv_dpi.epl_event = sym_finder->findSymT<void(*)(void*,void*)>(
				"tblink_rpc_DpiEndpointListenerProxy_event");

		prv_dpi.ifi_closure_invoke_rsp = sym_finder->findSymT<void(*)(void*,void*)>(
				"tblink_rpc_closure_invoke_rsp");
		prv_dpi.ifimpl_proxy_invoke = sym_finder->findSymT<void(*)(void*,void*,void*,intptr_t,void*)>(
				"tblink_rpc_DpiInterfaceImplProxy_invoke");
		prv_dpi.ifimpl_factory_proxy_createImpl = sym_finder->findSymT<void *(*)(void*)>(
				"tblink_rpc_DpiInterfaceImplFactory_createImpl");

		prv_dpi.dlp_proxy_add_arg = sym_finder->findSymT<void(*)(void *, const char *)>(
				"tblink_rpc_DpiLaunchParamsProxy_add_arg");
		prv_dpi.dlp_proxy_add_param = sym_finder->findSymT<void(*)(void *, const char *, const char *)>(
				"tblink_rpc_DpiLaunchParamsProxy_add_param");

		prv_dpi.tbl_proxy_notify = sym_finder->findSymT<void(*)(void *, void *)>(
				"tblink_rpc_DpiTbLinkListenerProxy_notify");

		prv_dpi.toggle_vpi_ev = &tblink_rpc_toggle_vpi_ev;

		prv_plugin = new TblinkPluginDpi(
				vpi_api,
				&prv_dpi);

		tblink->setDefaultServicesFactory(
				new EndpointServicesDpiFactory(&prv_dpi, vpi_api));
	}

	return prv_plugin;
}

EXTERN_C int _tblink_rpc_pkg_init(
		unsigned int		have_blocking_tasks,
		int32_t				*time_precision) {
	TblinkPluginDpi *plugin = get_plugin();

	fprintf(stdout, "_tblink_rpc_pkg_init\n");
	fflush(stdout);

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

EXTERN_C chandle tblink_rpc_IInterfaceInstInvokeClosure_new() {
	TblinkPluginDpi *plugin = get_plugin();
	return reinterpret_cast<chandle>(new InterfaceInstInvokeClosure(
			plugin->dpi_api()));
}

EXTERN_C void tblink_rpc_IInterfaceInstInvokeClosure_dispose(chandle closure_h) {
	delete reinterpret_cast<InterfaceInstInvokeClosure *>(closure_h);
}

EXTERN_C int tblink_rpc_IInterfaceInst_invoke(
		chandle			ifinst_h,
		chandle			method_h,
		chandle			params_h,
		chandle			closure_h) {
	return reinterpret_cast<IInterfaceInst *>(ifinst_h)->invoke(
			reinterpret_cast<IMethodType *>(method_h),
			dynamic_cast<IParamValVec *>(
					reinterpret_cast<IParamVal *>(params_h)),
			std::bind(
					&InterfaceInstInvokeClosure::response_f,
					reinterpret_cast<InterfaceInstInvokeClosure *>(closure_h),
					std::placeholders::_1));
}

EXTERN_C chandle tblink_rpc_DpiInterfaceImplProxy_new() {
	TblinkPluginDpi *plugin = get_plugin();
	return reinterpret_cast<chandle>(
			dynamic_cast<IInterfaceImpl *>(
					new DpiInterfaceImplProxy(plugin->dpi_api())));
}

EXTERN_C chandle tblink_rpc_DpiInterfaceImplFactoryProxy_new() {
	TblinkPluginDpi *plugin = get_plugin();
	return reinterpret_cast<chandle>(
			dynamic_cast<IInterfaceImplFactory *>(
					new DpiInterfaceImplFactoryProxy(plugin->dpi_api())));
}

EXTERN_C chandle tblink_rpc_DpiEndpointLoopback_new() {
	TblinkPluginDpi *plugin = get_plugin();
	return reinterpret_cast<chandle>(
			reinterpret_cast<IEndpoint *>(
					new DpiEndpointLoopback(plugin->dpi_api(), 0)));
}

EXTERN_C chandle tblink_rpc_DpiEndpointLoopbackVpi_new() {
	TblinkPluginDpi *plugin = get_plugin();
	IEndpoint *ep = reinterpret_cast<IEndpoint *>(
					new DpiEndpointLoopbackVpi(plugin->dpi_api(), 0));
	return reinterpret_cast<chandle>(ep);
}

EXTERN_C chandle tblink_rpc_IEndpointLoopback_peer(chandle ep_h) {
	IEndpointLoopback *ep_loop = dynamic_cast<IEndpointLoopback *>(
			reinterpret_cast<IEndpoint *>(ep_h));
	return reinterpret_cast<chandle>(ep_loop->peer());
}

EXTERN_C chandle tblink_rpc_DpiEndpointListenerProxy_connect(chandle ep_h) {
	TblinkPluginDpi *plugin = get_plugin();
	DpiEndpointListenerProxy *proxy = new DpiEndpointListenerProxy(plugin->dpi_api());
	reinterpret_cast<IEndpoint *>(ep_h)->addListener(proxy);
	return reinterpret_cast<chandle>(static_cast<IEndpointListener *>(proxy));
}

EXTERN_C void tblink_rpc_DpiEndpointListenerProxy_disconnect(
		chandle		ep_h,
		chandle		proxy_h) {
	reinterpret_cast<IEndpoint *>(ep_h)->removeListener(
			reinterpret_cast<IEndpointListener *>(proxy_h));
}

EXTERN_C chandle tblink_rpc_DpiEndpointServicesProxy_new() {
	TblinkPluginDpi *plugin = get_plugin();
	return reinterpret_cast<chandle>(
			static_cast<IEndpointServices *>(new DpiEndpointServicesProxy(
					plugin->dpi_api())));
}

EXTERN_C chandle tblink_rpc_DpiLaunchParamsProxy_new() {
	TblinkPluginDpi *plugin = get_plugin();
	return reinterpret_cast<chandle>(
			static_cast<ILaunchParams *>(new DpiLaunchParamsProxy(
					plugin->dpi_api())));
}

EXTERN_C void tblink_rpc_DpiLaunchParamsProxy_del(chandle hndl) {
	delete reinterpret_cast<ILaunchParams *>(hndl);
}

EXTERN_C int tblink_rpc_ITbLinkEvent_kind(chandle ev) {
	return static_cast<int>(reinterpret_cast<ITbLinkEvent *>(ev)->kind());
}

EXTERN_C chandle tblink_rpc_DpiTbLinkListenerProxy_new() {
	TblinkPluginDpi *plugin = get_plugin();
	DpiTbLinkListenerProxy *p = new DpiTbLinkListenerProxy(plugin->dpi_api());
	return reinterpret_cast<chandle>(static_cast<ITbLinkListener *>(p));
}

EXTERN_C int tblink_rpc_IEndpoint_getFlags(
		chandle				endpoint_h) {
	return static_cast<int>(
			reinterpret_cast<IEndpoint *>(endpoint_h)->getFlags());
}

EXTERN_C void tblink_rpc_IEndpoint_setFlag(
		chandle				endpoint_h,
		int					f) {
	reinterpret_cast<IEndpoint *>(endpoint_h)->setFlag(
			static_cast<IEndpointFlags>(f));
}

EXTERN_C int tblink_rpc_IEndpoint_init(
		chandle				endpoint_h,
		chandle				services_h) {
	return reinterpret_cast<IEndpoint *>(endpoint_h)->init(
			reinterpret_cast<IEndpointServices *>(services_h));
}

EXTERN_C int tblink_rpc_IEndpoint_is_init(
		chandle				endpoint_h) {
	return reinterpret_cast<IEndpoint *>(endpoint_h)->is_init();
}

EXTERN_C int tblink_rpc_IEndpoint_build_complete(
		chandle				endpoint_h) {
	return reinterpret_cast<IEndpoint *>(endpoint_h)->build_complete();
}

EXTERN_C int tblink_rpc_IEndpoint_is_build_complete(
		chandle				endpoint_h) {
	return reinterpret_cast<IEndpoint *>(endpoint_h)->is_build_complete();
}

EXTERN_C int tblink_rpc_IEndpoint_connect_complete(
		chandle			endpoint_h) {
	return reinterpret_cast<IEndpoint *>(endpoint_h)->connect_complete();
}

EXTERN_C int tblink_rpc_IEndpoint_is_connect_complete(
		chandle			endpoint_h) {
	return reinterpret_cast<IEndpoint *>(endpoint_h)->is_connect_complete();
}

EXTERN_C int tblink_rpc_IEndpoint_comm_state(
		chandle			endpoint_h) {
	return reinterpret_cast<IEndpoint *>(endpoint_h)->comm_state();
}

EXTERN_C void tblink_rpc_IEndpoint_notify_callback(
		chandle			endpoint_h,
		intptr_t		id) {
	reinterpret_cast<IEndpoint *>(endpoint_h)->notify_callback(id);
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

EXTERN_C int tblink_rpc_IEndpointEvent_kind(chandle ev) {
//	return reinterpret_cast<int>(
return			static_cast<int>(reinterpret_cast<IEndpointEvent *>(ev)->kind());
}

EXTERN_C chandle tblink_rpc_IInterfaceType_findMethod(
		chandle				iftype_h,
		const char			*name) {
	return reinterpret_cast<IInterfaceType *>(iftype_h)->findMethod(name);
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

EXTERN_C void *tblink_rpc_IEndpoint_defineInterfaceType(
		void 			*endpoint_h,
		void			*iftype_builder_h,
		void			*ifimpl_f,
		void			*ifimpl_mirror_f) {
	return reinterpret_cast<void *>(
			reinterpret_cast<IEndpoint *>(endpoint_h)->defineInterfaceType(
					reinterpret_cast<IInterfaceTypeBuilder *>(iftype_builder_h),
					reinterpret_cast<IInterfaceImplFactory *>(ifimpl_f),
					reinterpret_cast<IInterfaceImplFactory *>(ifimpl_mirror_f)));
}

EXTERN_C chandle _tblink_rpc_IEndpoint_defineInterfaceInst(
		chandle 		endpoint_h,
		chandle			iftype_h,
		const char		*inst_name,
		unsigned int	is_mirror,
		chandle			ifimpl_h) {
	IEndpoint *endpoint = reinterpret_cast<IEndpoint *>(endpoint_h);
	return reinterpret_cast<void *>(
			reinterpret_cast<IEndpoint *>(endpoint_h)->defineInterfaceInst(
					reinterpret_cast<IInterfaceType *>(iftype_h),
					inst_name,
					is_mirror,
					reinterpret_cast<IInterfaceImpl *>(ifimpl_h)));
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
	fprintf(stdout, "tblink_rpc_IMethodType_id: %p 0x%08llx\n",
			hndl, reinterpret_cast<IMethodType *>(hndl)->id());
	fflush(stdout);
	fprintf(stdout, "  name: %s\n",
			reinterpret_cast<IMethodType *>(hndl)->name().c_str());
	fflush(stdout);
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
	IParamVal *v = reinterpret_cast<IParamVal *>(hndl);
	IParamValVec *vv = dynamic_cast<IParamValVec *>(v);
	if (vv->size()) {
		return reinterpret_cast<chandle>(vv->at(idx));
	} else {
		return 0;
	}
}

EXTERN_C void tblink_rpc_IParamValVec_push_back(chandle hndl, chandle val_h) {
	dynamic_cast<IParamValVec *>(reinterpret_cast<IParamVal *>(hndl))->push_back(
			reinterpret_cast<IParamVal *>(val_h));
}

EXTERN_C chandle tblink_rpc_IInterfaceInst_endpoint(
		chandle			ifinst_h) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<IInterfaceInst *>(ifinst_h)->endpoint());
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

EXTERN_C chandle tblink_rpc_findLaunchType(const char *id) {
	return reinterpret_cast<chandle>(TbLink::inst()->findLaunchType(id));
}

EXTERN_C chandle tblink_rpc_TbLink_inst() {
	return reinterpret_cast<chandle>(
			static_cast<ITbLink *>(TbLink::inst()));
}

EXTERN_C void tblink_rpc_TbLink_addListener(
		chandle				tblink,
		chandle				listener) {
	reinterpret_cast<ITbLink *>(tblink)->addListener(
			reinterpret_cast<ITbLinkListener *>(listener));
}

EXTERN_C void tblink_rpc_TbLink_removeListener(
		chandle				tblink,
		chandle				listener) {
	reinterpret_cast<ITbLink *>(tblink)->removeListener(
			reinterpret_cast<ITbLinkListener *>(listener));
}

EXTERN_C void tblink_rpc_TbLink_addEndpoint(
		chandle				tblink,
		chandle				ep) {
	reinterpret_cast<ITbLink *>(tblink)->addEndpoint(
			reinterpret_cast<IEndpoint *>(ep));
}

EXTERN_C void tblink_rpc_TbLink_removeEndpoint(
		chandle				tblink,
		chandle				ep) {
	reinterpret_cast<ITbLink *>(tblink)->removeEndpoint(
			reinterpret_cast<IEndpoint *>(ep));
}

EXTERN_C uint32_t tblink_rpc_TbLink_getEndpoints_size(
		chandle				tblink) {
	return reinterpret_cast<ITbLink *>(tblink)->getEndpoints().size();
}

EXTERN_C chandle tblink_rpc_TbLink_getEndpoints_at(
		chandle				tblink,
		uint32_t			idx) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<TbLink *>(tblink)->getEndpoints().at(idx));
}

EXTERN_C void tblink_rpc_TbLink_setDefaultEP(
		chandle				tblink,
		chandle				ep) {
	reinterpret_cast<ITbLink *>(tblink)->setDefaultEP(
			reinterpret_cast<IEndpoint *>(ep));
}

EXTERN_C chandle tblink_rpc_TbLink_getDefaultEP(
		chandle				tblink) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<ITbLink *>(tblink)->getDefaultEP());
}

EXTERN_C void tblink_rpc_ParseLaunchPlusargs(
		chandle				params_proxy,
		char				**errmsg) {
	TblinkPluginDpi *plugin = get_plugin();
	ILaunchParams *params = reinterpret_cast<ILaunchParams *>(params_proxy);
	s_vpi_vlog_info info;

	plugin->vpi_api()->vpi_get_vlog_info(&info);
	prv_msgbuf[0] = 0;
	*errmsg = prv_msgbuf;

	for (int32_t i=0; i<info.argc; i++) {
		if (!strncmp(info.argv[i], "+tblink.arg=", strlen("+tblink.arg="))) {
			params->add_arg(&info.argv[i][strlen("+tblink.arg=")]);
		} else if (!strncmp(info.argv[i], "+tblink.param+", strlen("+tblink.param+"))) {
			std::string key_val = &info.argv[i][strlen("+tblink.param+")];
			int32_t eq_idx = key_val.find('=');

			if (eq_idx != std::string::npos) {
				params->add_param(
						key_val.substr(0, eq_idx),
						key_val.substr(eq_idx+1));
			} else {
				sprintf(prv_msgbuf, "malformed param entry \"%s\"", info.argv[i]);
			}
		} else if (info.argv[i][0] == '+') {
			// Pass all plusargs directly
			std::string val = &info.argv[i][1];
			int eq_idx = val.rfind('=');

			if (eq_idx == std::string::npos) {
				// No value
				params->add_param(val, "");
			} else {
				params->add_param(
						val.substr(0, eq_idx),
						val.substr(eq_idx+1));
			}
		}
	}
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

EXTERN_C int tblink_rpc_ILaunchParams_has_param(
		chandle				params,
		const char			*key) {
	return reinterpret_cast<ILaunchParams *>(params)->has_param(key);
}

EXTERN_C const char *tblink_rpc_ILaunchParams_get_param(
		chandle				params,
		const char			*key) {
	strcpy(prv_msgbuf,
			reinterpret_cast<ILaunchParams *>(params)->get_param(key).c_str());
	return prv_msgbuf;
}

EXTERN_C chandle tblink_rpc_ILaunchType_newLaunchParams(chandle launch) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<ILaunchType *>(launch)->newLaunchParams());
}

EXTERN_C chandle tblink_rpc_ILaunchType_launch(
		chandle				launch,
		chandle				params,
		chandle				services_h,
		char				**error) {
	ILaunchType::result_t res;
	TblinkPluginDpi *plugin = get_plugin();

	if (!plugin) {
		strcpy(prv_msgbuf, "Failed to initialize DPI plug-in");
		*error = prv_msgbuf;
		return 0;
	}

	IEndpointServices *services = reinterpret_cast<IEndpointServices *>(services_h);

	res = reinterpret_cast<ILaunchType *>(launch)->launch(
			reinterpret_cast<ILaunchParams *>(params),
			services);

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
					plugin->have_blocking_tasks())) != 0) {
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
	IInterfaceInst *ifinst_p = reinterpret_cast<IInterfaceInst *>(ifinst);
	IMethodType *method_p = reinterpret_cast<IMethodType *>(method);

	fprintf(stdout, "ifinst=%p ifinst_p=%p method=%p method_p=%p\n",
			ifinst, ifinst_p, method, method_p);
	fflush(stdout);

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
	IInterfaceInst *ifinst_p = reinterpret_cast<IInterfaceInst *>(ifinst);
	IMethodType *method_p = reinterpret_cast<IMethodType *>(method);

	fprintf(stdout, "ifinst=%p ifinst_p=%p method=%p method_p=%p\n",
			ifinst, ifinst_p, method, method_p);
	fflush(stdout);

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

static vpiHandle notify_ev = 0;
static bool notify_ev_val = 0;

static void tblink_rpc_toggle_vpi_ev() {
	TblinkPluginDpi *plugin = get_plugin();
	s_vpi_value val;

	val.format = vpiIntVal;
	notify_ev_val = (notify_ev_val)?0:1;
	val.value.integer = notify_ev_val;

	plugin->vpi_api()->vpi_put_value(notify_ev, &val, 0, vpiNoDelay);
}

static PLI_INT32 tblink_rpc_register_vpi_ev(PLI_BYTE8 *cbd) {
	TblinkPluginDpi *plugin = get_plugin();
	VpiHandleSP vpi = VpiHandle::mk(plugin->vpi_api());

	VpiHandleSP systf_h = vpi->systf_h();
	VpiHandleSP args_h = systf_h->tf_args();
	notify_ev = args_h->scan()->release();

	fprintf(stdout, "register_ev: notify_ev=%p\n", notify_ev);
	fflush(stdout);

	return 0;
}

static void vpi_startup(void) {
	fprintf(stdout, "--> vpi_startup\n");

	ITbLink *tblink = TbLink::inst();
	ISymFinder *sym_finder = tblink->sym_finder();
	vpi_api_t *vpi_api = get_vpi_api(sym_finder);

	fprintf(stdout, "<-- vpi_startup\n");

	{
		s_vpi_systf_data tf_data;
		tf_data.type = vpiSysTask;
		tf_data.sysfunctype = vpiSysTask;
		tf_data.compiletf = 0;
		tf_data.sizetf = 0;
		tf_data.user_data = 0;
		tf_data.tfname = "$tblink_rpc_register_vpi_ev";
		tf_data.calltf = &tblink_rpc_register_vpi_ev;
		vpi_api->vpi_register_systf(&tf_data);
	}

}

void (*vlog_startup_routines[])() = {
	vpi_startup,
    0
};


// For non-VPI compliant applications that cannot find vlog_startup_routines symbol
void vlog_startup_routines_bootstrap() {
    for (int i = 0; vlog_startup_routines[i]; i++) {
    	void (*routine)() = vlog_startup_routines[i];
        routine();
    }
}
