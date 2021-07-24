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

static bool						prv_registered = true;
static EndpointServicesVpiUP	prv_services;
static IEndpointUP				prv_endpoint;

static void tblink_vpi_atexit() {
	fprintf(stdout, "tblink_vpi_atexit\n");
	prv_endpoint->shutdown();
}

static void tblink_vpi_sigpipe(int sig) {
	fprintf(stdout, "tblink_vpi_sigpipe\n");
	fflush(stdout);
	prv_endpoint->shutdown();
}

static PLI_INT32 end_elab_cb(p_cb_data cbd) {
    fprintf(stdout, "end_elab_cb\n");
    fflush(stdout);

    if (!prv_registered) {
    	// If nothing else has registered, go ahead
    	// and mark ourselves built and connected
    	fprintf(stdout, "--> build_complete\n");
    	prv_endpoint->build_complete();
    	fprintf(stdout, "<-- build_complete\n");

    	fprintf(stdout, "--> connect_complete\n");
    	prv_endpoint->connect_complete();
    	fprintf(stdout, "<-- connect_complete\n");

    	// TODO: process events until we've exhausted
    	// pending messages
    	fprintf(stdout, "--> yield_blocking\n");
    	int32_t ret;
    	while ((ret=prv_endpoint->yield_blocking()) > 0) {
    		fprintf(stdout, "... waiting\n");
    	}
    	fprintf(stdout, "<-- yield_blocking\n");

    	if (ret == -1) {
    		// TODO: // Prevent
    	}

    } else {
    	vpi_api_t *vpi_api = get_vpi_api();

    	// Need to take another spin to be sure
    	s_cb_data cbd;
    	s_vpi_time time;

    	prv_registered = false;


    	memset(&cbd, 0, sizeof(cbd));
    	memset(&time, 0, sizeof(time));
    	time.type = vpiSimTime;
    	cbd.reason = cbAfterDelay;
    	cbd.cb_rtn = &end_elab_cb;
    	cbd.time = &time;
    	vpi_api->vpi_register_cb(&cbd);
    }

    return 0;
}

static PLI_INT32 on_shutdown(p_cb_data cbd) {
    fprintf(stdout, "on_shutdown\n");
    fflush(stdout);

    // TODO: check status
    if (prv_endpoint) {
    	prv_endpoint->shutdown();
    }

	return 0;
}

static PLI_INT32 on_startup(p_cb_data cbd) {
    vpi_api_t *vpi_api = get_vpi_api();

    fprintf(stdout, "on_startup\n");




    // Set a callback to allow static instances to register
    {
    	s_cb_data cbd;
    	s_vpi_time time;


    	memset(&cbd, 0, sizeof(cbd));
    	memset(&time, 0, sizeof(time));
    	time.type = vpiSimTime;
//    	cbd.reason = cbAfterDelay;
    	cbd.reason = cbStartOfSimulation;
    	cbd.cb_rtn = &end_elab_cb;
//    	cbd.time = &time;
    	vpi_api->vpi_register_cb(&cbd);
    }

    // Set a callback for end of simulation
    {
    	s_cb_data cbd;

    	memset(&cbd, 0, sizeof(cbd));
    	cbd.reason = cbEndOfSimulation;
    	cbd.cb_rtn = &on_shutdown;
    	vpi_api->vpi_register_cb(&cbd);
    }
    fprintf(stdout, "prv_endpoint: %p\n", prv_endpoint.get());

	return 0;
}

static void register_tblink_tf(void) {
	s_cb_data cbd;
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

    fprintf(stdout, "register_tblink_tf\n");

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

    prv_endpoint = IEndpointUP(launcher->launch(prv_services.get()));

    if (!prv_endpoint) {
    	fprintf(stdout, "Error: failed to launch peer\n");
		vpi_api->vpi_control(vpiFinish, 1);
    }

	memset(&cbd, 0, sizeof(cbd));
	cbd.reason = cbStartOfSimulation;
	cbd.cb_rtn = &on_startup;
	vpi_api->vpi_register_cb(&cbd);

	// Add a shutdown callback if the simulator closes down unexpectedly
	atexit(&tblink_vpi_atexit);
	signal(SIGPIPE, &tblink_vpi_sigpipe);
}

void (*vlog_startup_routines[])() = {
	register_tblink_tf,
    0
};


// For non-VPI compliant applications that cannot find vlog_startup_routines symbol
void vlog_startup_routines_bootstrap() {
    for (int i = 0; vlog_startup_routines[i]; i++) {
    	void (*routine)() = vlog_startup_routines[i];
        routine();
    }
}

