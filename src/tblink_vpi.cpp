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
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "vpi_api.h"
#include "EndpointServicesVpi.h"
#include "ILaunch.h"
#include "tblink_rpc/IEndpoint.h"

using namespace tblink_rpc_core;
using namespace tblink_rpc_hdl;

//static PyLauncherUP				prv_launcher;
//static BackendVpi				*prv_backend;

static bool						prv_registered = false;
static EndpointServicesVpiUP	prv_services;
static IEndpointUP				prv_endpoint;

static PLI_INT32 end_elab_cb(p_cb_data cbd) {
    fprintf(stdout, "end_elab_cb\n");

    if (!prv_registered) {
    	// If nothing else has registered, go ahead
    	// and mark ourselves built and connected
    	fprintf(stdout, "--> build_complete\n");
    	prv_endpoint->build_complete();
    	fprintf(stdout, "<-- build_complete\n");

    	fprintf(stdout, "--> connect_complete\n");
    	prv_endpoint->connect_complete();
    	fprintf(stdout, "<-- connect_complete\n");

    	// TODO: wait for a message to

    } else {
    	vpi_api_t *vpi_api = get_vpi_api();

    	// Need to take another spin to be sure
    	s_cb_data cbd;
    	s_vpi_time time;


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

	return 0;
}

static PLI_INT32 on_startup(p_cb_data cbd) {
    vpi_api_t *vpi_api = get_vpi_api();

    fprintf(stdout, "on_startup\n");

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

    // Set a callback to allow static instances to register
    {
    	s_cb_data cbd;
    	s_vpi_time time;


    	memset(&cbd, 0, sizeof(cbd));
    	memset(&time, 0, sizeof(time));
    	time.type = vpiSimTime;
    	cbd.reason = cbAfterDelay;
    	cbd.cb_rtn = &end_elab_cb;
    	cbd.time = &time;
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

    fprintf(stdout, "register_tblink_tf\n");

    if (!vpi_api) {
    	fprintf(stdout, "Error: failed to load VPI API (%s)\n",
    			get_vpi_api_error());
    	return;
    }

	memset(&cbd, 0, sizeof(cbd));
	cbd.reason = cbStartOfSimulation;
	cbd.cb_rtn = &on_startup;
	vpi_api->vpi_register_cb(&cbd);
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

