/*****************************************************************************
 * tblink_vpi.cpp
 *
 * Implements interface routines specific to Verilog VPI
 *
 *  Created on: Mar 10, 2021
 *      Author: mballance
 *
 *****************************************************************************/
#define EXTERN_C extern "C"
#include <memory>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "vpi_api.h"
#include "EndpointServicesVpi.h"
#include "ILaunch.h"
#include "tblink_rpc/IEndpoint.h"
#include "glog/logging.h"

using namespace tblink_rpc_core;
using namespace tblink_rpc_hdl;

static EndpointServicesVpiUP	prv_services;
static IEndpointUP				prv_endpoint;

static void tblink_vpi_atexit() {
	fprintf(stdout, "tblink_vpi_atexit\n");
	if (prv_endpoint->type() == IEndpoint::Active) {
		prv_endpoint->shutdown();
	}
}

static void tblink_vpi_sigpipe(int sig) {
	fprintf(stdout, "tblink_vpi_sigpipe\n");
	fflush(stdout);
	prv_endpoint->shutdown();
}

static void vpi_startup(void) {
    vpi_api_t *vpi_api = get_vpi_api();

    FLAGS_log_dir = ".";
//    FLAGS_logtostderr = 1;
    google::InitGoogleLogging("tblink_vpi");

    VLOG(1) << "Hello World";
    VLOG(1) << "Hello World\n";

    if (!vpi_api) {
    	fprintf(stdout, "Error: failed to load VPI API (%s)\n",
    			get_vpi_api_error());
    	return;
    }

    fprintf(stdout, "vpi_startup\n");

    // Create services and endpoint here,
    // since we'll need to have them available in order
    // to register interface types
    prv_services = EndpointServicesVpiUP(new EndpointServicesVpi(vpi_api));

    // Launch everything
    ILaunch *launcher = tblink_rpc_hdl_launcher();

    if (!launcher) {
    	fprintf(stdout, "Error: failed to obtain launcher\n");
		vpi_api->vpi_control(vpiFinish, 1);
    }

    prv_endpoint = IEndpointUP(launcher->create_ep(prv_services.get()));

    if (!prv_endpoint) {
    	fprintf(stdout, "Error: failed to launch peer\n");
		vpi_api->vpi_control(vpiFinish, 1);
    }

	// Add a shutdown callback if the simulator closes down unexpectedly
	atexit(&tblink_vpi_atexit);
	signal(SIGPIPE, &tblink_vpi_sigpipe);

	launcher->launch(prv_endpoint.get());
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

