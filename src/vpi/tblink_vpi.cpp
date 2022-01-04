
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
#include "TbLink.h"
#include "TblinkPluginVpi.h"
#include "tblink_rpc/IEndpoint.h"

using namespace tblink_rpc_core;
using namespace tblink_rpc_hdl;


static TblinkPluginVpi			*prv_plugin = 0;

static void tblink_vpi_atexit() {
	fprintf(stdout, "tblink_vpi_atexit\n");
}

static void tblink_vpi_sigpipe(int sig) {
	fprintf(stdout, "tblink_vpi_sigpipe\n");
	fflush(stdout);
}

static void vpi_startup(void) {
	ITbLink *tblink = TbLink::inst();
    vpi_api_t *vpi_api = get_vpi_api(tblink->sym_finder());

    prv_plugin = new TblinkPluginVpi(vpi_api);
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

