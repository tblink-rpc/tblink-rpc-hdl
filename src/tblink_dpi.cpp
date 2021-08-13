
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
#include "TimeCallbackClosureDpi.h"
#include "glog/logging.h"

typedef void *chandle;

// Externs for DPI-Exported methods
extern "C" {
void *svGetScope() __attribute__((weak));
void *svSetScope(void *) __attribute__((weak));
void _tblink_rpc_add_time_cb(void *cb_data, uint64_t delta) __attribute__((weak));
void _tblink_rpc_invoke_nb(void *ii_h) __attribute__((weak));
void _tblink_rpc_invoke_b(void *ii_h) __attribute__((weak));

void *svGetScope() {
	return 0;
}

void *svSetScope(void *) {
	return 0;
}

void _tblink_rpc_add_time_cb(void *cb_data, uint64_t delta) {
	;
}

void _tblink_rpc_invoke_nb(void *ii_h) {
}

void _tblink_rpc_invoke_b(void *ii_h) {
}

}

using namespace tblink_rpc_core;
using namespace tblink_rpc_hdl;

static EndpointServicesDpiUP	prv_services;
static IEndpointUP				prv_endpoint;
static dpi_api_t				prv_dpi;
static bool						prv_registered = false;
static void						*prv_pkg_scope = 0;

static void *get_pkg_scope() {
	return prv_pkg_scope;
}

static void tblink_dpi_atexit() {
	fprintf(stdout, "tblink_dpi_atexit\n");
	if (prv_endpoint) {
		prv_endpoint->shutdown();
	}
}

static void tblink_dpi_sigpipe(int sig) {
	fprintf(stdout, "tblink_vpi_sigpipe\n");
	fflush(stdout);
	if (prv_endpoint) {
		prv_endpoint->shutdown();
	}
}

static void elab_cb(intptr_t callback_id) {
	fprintf(stdout, "elab_cb\n");
	if (!prv_registered) {
		fprintf(stdout, "completing registration\n");

		prv_endpoint->build_complete();

		prv_endpoint->connect_complete();

		// Wait for next event
		prv_services->idle();
	}

}

EXTERN_C int _tblink_rpc_pkg_init(
		int32_t	*time_precision) {
	vpi_api_t *vpi_api = get_vpi_api();

	if (!vpi_api) {
		fprintf(stdout, "Error: Failed to obtain VPI API\n");
		fflush(stdout);
		return 0;
	}

	*time_precision = vpi_api->vpi_get(vpiTimePrecision, 0);
	prv_pkg_scope = svGetScope();

    // Add a delta callback to check for more things registering
//    prv_services->_add_time_cb(0, 0, &elab_cb);

	return 1;
}

EXTERN_C int _tblink_rpc_endpoint_launch(chandle ep_h) {
    // Create the endpoint
    ILaunch *launcher = tblink_rpc_hdl_launcher();

    if (!launcher) {
    	fprintf(stdout, "Error: failed to obtain launcher\n");
    	return 0;
    }

    if (launcher->launch(prv_endpoint.get())) {
    	return 1;
    } else {
    	return 0;
    }
}


EXTERN_C chandle _tblink_rpc_endpoint_invoke_info_inst(chandle ii) {
	return reinterpret_cast<void *>(
			reinterpret_cast<InvokeInfoDpi *>(ii)->inst());
}

EXTERN_C chandle _tblink_rpc_endpoint_invoke_info_method(chandle ii) {
	return reinterpret_cast<void *>(
			reinterpret_cast<InvokeInfoDpi *>(ii)->method());
}

EXTERN_C chandle _tblink_rpc_endpoint_invoke_info_params(chandle ii_h) {
	return reinterpret_cast<void *>(
			static_cast<IParamVal *>(
					reinterpret_cast<InvokeInfoDpi *>(ii_h)->params()));
}

EXTERN_C void _tblink_rpc_endpoint_invoke_info_invoke_rsp(chandle ii_h) {
	InvokeInfoDpi *ii = reinterpret_cast<InvokeInfoDpi *>(ii_h);
	ii->inst()->invoke_rsp(
			ii->call_id(),
			ii->ret());
	delete ii;
}

EXTERN_C void *_tblink_rpc_endpoint_new(int have_blocking_tasks) {
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
}
EXTERN_C int _tblink_rpc_endpoint_build_complete(void *endpoint_h) {
	return reinterpret_cast<IEndpoint *>(endpoint_h)->build_complete();
}

EXTERN_C int _tblink_rpc_endpoint_connect_complete(void *endpoint_h) {
	return reinterpret_cast<IEndpoint *>(endpoint_h)->connect_complete();
}

EXTERN_C int _tblink_rpc_endpoint_shutdown(void *endpoint_h) {
	return reinterpret_cast<IEndpoint *>(endpoint_h)->shutdown();
}

EXTERN_C void *_tblink_rpc_endpoint_findInterfaceType(
		void			*endpoint_h,
		const char		*name) {
	fprintf(stdout, "findInterfaceType: %p %s\n", endpoint_h, name);
	fflush(stdout);
	return reinterpret_cast<void *>(
			reinterpret_cast<IEndpoint *>(endpoint_h)->findInterfaceType(name));
}

EXTERN_C void *_tblink_rpc_endpoint_newInterfaceTypeBuilder(
		void 			*endpoint_h,
		const char		*name) {
	return reinterpret_cast<void *>(
			reinterpret_cast<IEndpoint *>(endpoint_h)->newInterfaceTypeBuilder(name));
}

EXTERN_C void *_tblink_rpc_iftype_builder_define_method(
			void			*iftype_b,
			const char 		*name,
			int64_t			id,
			const char		*signature,
			uint32_t		is_export,
			uint32_t		is_blocking) {
	return reinterpret_cast<void *>(
			reinterpret_cast<IInterfaceTypeBuilder *>(iftype_b)->define_method(
					name,
					id,
					signature,
					is_export,
					is_blocking));
}


EXTERN_C void *_tblink_rpc_endpoint_defineInterfaceType(
		void 			*endpoint_h,
		void			*iftype_builder_h) {
	return reinterpret_cast<void *>(
			reinterpret_cast<IEndpoint *>(endpoint_h)->defineInterfaceType(
					reinterpret_cast<IInterfaceTypeBuilder *>(iftype_builder_h)));
}

EXTERN_C void *_tblink_rpc_endpoint_defineInterfaceInst(
		void 			*endpoint_h,
		void			*iftype_h,
		const char		*inst_name) {
	return reinterpret_cast<void *>(
			reinterpret_cast<IEndpoint *>(endpoint_h)->defineInterfaceInst(
					reinterpret_cast<IInterfaceType *>(iftype_h),
					inst_name,
					std::bind(&EndpointServicesDpi::invoke_req, prv_services.get(),
							std::placeholders::_1,
							std::placeholders::_2,
							std::placeholders::_3,
							std::placeholders::_4)));
}

EXTERN_C int _tblink_rpc_notify_time_cb(void *cb_data) {
	TimeCallbackClosureDpi *closure = reinterpret_cast<TimeCallbackClosureDpi *>(cb_data);
	fprintf(stdout, "_tblink_rpc_notify_time_cb\n");
	fflush(stdout);
	closure->notify();
	delete closure;
	return 0;
}

EXTERN_C chandle tblink_rpc_iftype_find_method(
		chandle			iftype_h,
		const char 		*name) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<IInterfaceType *>(iftype_h)->findMethod(name));
}

EXTERN_C const char *_tblink_rpc_method_type_name(void *hndl) {
	return reinterpret_cast<IMethodType *>(hndl)->name().c_str();
}

EXTERN_C int64_t _tblink_rpc_method_type_id(void *hndl) {
	return reinterpret_cast<IMethodType *>(hndl)->id();
}

EXTERN_C uint64_t _tblink_rpc_iparam_val_int_val_u(chandle hndl_h) {
	fprintf(stdout, "val_int: hndl=%p\n", hndl_h);
	fflush(stdout);
	return dynamic_cast<IParamValInt *>(
			reinterpret_cast<IParamVal *>(hndl_h))->val_u();
}

EXTERN_C void *_tblink_rpc_iparam_val_clone(void *hndl) {
	return reinterpret_cast<void *>(
			reinterpret_cast<IParamVal *>(hndl)->clone());
}
EXTERN_C uint32_t _tblink_rpc_iparam_val_type(void *hndl) {
	return reinterpret_cast<IParamVal *>(hndl)->type();
}

EXTERN_C uint32_t _tblink_rpc_iparam_val_bool_val(void *hndl) {
	return dynamic_cast<IParamValBool *>(
			reinterpret_cast<IParamVal *>(hndl))->val();
}

EXTERN_C chandle _tblink_rpc_iparam_val_vector_new() {
	return reinterpret_cast<void *>(
			static_cast<IParamVal *>(
					prv_endpoint->mkVector()));
}

EXTERN_C uint32_t _tblink_rpc_iparam_val_vector_size(void *hndl) {
	return dynamic_cast<IParamValVector *>(
			reinterpret_cast<IParamVal *>(hndl))->size();
}

EXTERN_C void *_tblink_rpc_iparam_val_vector_at(void *hndl, uint32_t idx) {
	fprintf(stdout, "vector_at: hndl=%p\n", hndl);
	fprintf(stdout, "  vv=%p\n",
			dynamic_cast<IParamValVector *>(reinterpret_cast<IParamVal *>(hndl)));
	fflush(stdout);
	return reinterpret_cast<void *>(
			dynamic_cast<IParamValVector *>(reinterpret_cast<IParamVal *>(hndl))->at(idx));
}

EXTERN_C void _tblink_rpc_iparam_val_vector_push_back(void *hndl, void *val_h) {
	dynamic_cast<IParamValVector *>(reinterpret_cast<IParamVal *>(hndl))->push_back(
			reinterpret_cast<IParamVal *>(val_h));
}

EXTERN_C chandle _tblink_rpc_ifinst_invoke_nb(
		chandle			ifinst_h,
		chandle			method_h,
		chandle			params_h) {
	return reinterpret_cast<chandle>(
			reinterpret_cast<IInterfaceInst *>(ifinst_h)->invoke_nb(
					reinterpret_cast<IMethodType *>(method_h),
					dynamic_cast<IParamValVector *>(
							reinterpret_cast<IParamVal *>(params_h))));
}
