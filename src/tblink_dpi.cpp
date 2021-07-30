
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
#include <string>
#include <vector>
#include <dlfcn.h>
#include <memory>
#include "dpi_api.h"
#include "vpi_api.h"
#include "ILaunch.h"
#include "EndpointServicesDpi.h"
#include "TimeCallbackClosureDpi.h"
#include "glog/logging.h"

// Externs for DPI-Exported methods
extern "C" {
void *svGetScope() __attribute__((weak));
void *svSetScope(void *) __attribute__((weak));
void _tblink_rpc_add_time_cb(void *cb_data, uint64_t delta) __attribute__((weak));
void _tblink_rpc_invoke_nb(void *call_h) __attribute__((weak));

void *svGetScope() {
	return 0;
}

void *svSetScope(void *) {
	return 0;
}

void _tblink_rpc_add_time_cb(void *cb_data, uint64_t delta) {
	;
}

void _tblink_rpc_invoke_nb(void *call_h) {

}

}

using namespace tblink_rpc_core;
using namespace tblink_rpc_hdl;

static EndpointServicesDpiUP	prv_services;
static IEndpointUP				prv_endpoint;
static dpi_api_t				prv_dpi;
static bool						prv_registered = false;

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

EXTERN_C void *_tblink_rpc_pkg_init(int32_t have_blocking_tasks) {
	vpi_api_t *vpi_api = get_vpi_api();

	fprintf(stdout, "_tblink_rpc_pkg_init\n");
	fflush(stdout);

	memset(&prv_dpi, 0, sizeof(prv_dpi));
	prv_dpi.svGetScope = &svGetScope;
	prv_dpi.svSetScope = &svSetScope;
	prv_dpi.invoke_nb = &_tblink_rpc_invoke_nb;
	prv_dpi.add_time_cb = &_tblink_rpc_add_time_cb;

	{
		void *lib = dlopen(0, RTLD_LAZY);
		void *sym = dlsym(lib, "_tblink_register_timed_callback");
		fprintf(stdout, "lib=%p sym=%p\n");
		fflush(stdout);
	}

	if (!vpi_api) {
		fprintf(stdout, "Error: failed to load vpi API (%s)\n",
				get_vpi_api_error());
		return 0;
	}

	prv_services = EndpointServicesDpiUP(new EndpointServicesDpi(
			&prv_dpi,
			vpi_api,
			have_blocking_tasks));

    // Launch everything
    ILaunch *launcher = tblink_rpc_hdl_launcher();

    if (!launcher) {
    	fprintf(stdout, "Error: failed to obtain launcher\n");
    	return 0;
    }

    prv_endpoint = IEndpointUP(launcher->launch(prv_services.get()));

    // Add a delta callback to check for more things registering
    prv_services->_add_time_cb(0, 0, &elab_cb);

	return prv_endpoint.get();
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

EXTERN_C void *_tblink_rpc_endpoint_newInterfaceTypeBuilder(
		void 			*endpoint_h,
		const char		*name) {
	return reinterpret_cast<void *>(
			reinterpret_cast<IEndpoint *>(endpoint_h)->newInterfaceTypeBuilder(name));
}

EXTERN_C void *_tblink_rpc_endpoint_defineInterfaceType(
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
		tblink_rpc_core::IParamValVectorSP		params) {
	// ..
}

EXTERN_C void *_tblink_rpc_endpoint_defineInterfaceInst(
		void 			*endpoint_h,
		void			*iftype_h,
		const char		*inst_name) {
	return reinterpret_cast<void *>(
			reinterpret_cast<IEndpoint *>(endpoint_h)->defineInterfaceInst(
					reinterpret_cast<IInterfaceType *>(iftype_h),
					inst_name,
					&invoke_req));
	// TODO:
}

EXTERN_C int _tblink_rpc_notify_time_cb(void *cb_data) {
	TimeCallbackClosureDpi *closure = reinterpret_cast<TimeCallbackClosureDpi *>(cb_data);
	fprintf(stdout, "_tblink_rpc_notify_time_cb\n");
	fflush(stdout);
	closure->notify();
	delete closure;
	return 0;
}

