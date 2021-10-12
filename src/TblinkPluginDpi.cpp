/*
 * TblinkPluginDpi.cpp
 *
 *  Created on: Sep 20, 2021
 *      Author: mballance
 */

#include <string>
#include <string.h>
#include <vector>
#include "TbLink.h"
#include "tblink_rpc/tblink_rpc.h"
#include "TblinkPluginDpi.h"
#include "tblink_rpc/ILaunchParams.h"
#include "EndpointServicesDpi.h"
#include "ParamValStr.h"

using namespace tblink_rpc_core;

namespace tblink_rpc_hdl {

TblinkPluginDpi::TblinkPluginDpi(
		vpi_api_t		*vpi_api,
		dpi_api_t		*dpi_api,
		bool			have_blocking_tasks) :
				m_vpi_api(vpi_api), m_dpi_api(dpi_api),
				m_have_blocking_tasks(have_blocking_tasks),
				m_tblink(0), m_auto_ep(0) {
	// TODO Auto-generated constructor stub

}

TblinkPluginDpi::~TblinkPluginDpi() {
	// TODO Auto-generated destructor stub
}

int TblinkPluginDpi::init() {

	// TODO: Check auto-launch
    s_vpi_vlog_info info;
	std::vector<std::string> ret;
	ILaunchParams *params = 0;
	ILaunchType *launch_t = 0;

	m_tblink = TbLink::inst();

	if (!m_tblink) {
		fprintf(stdout, "TBLink Error: failed to obtain tblink singleton\n");
		return 0;
	}


    m_vpi_api->vpi_get_vlog_info(&info);

	// Read plusargs to determine if we need to launch a default endpoint
#ifdef UNDEFINED
    const int32_t pref_len = strlen("+tblink.arg=");
    const int32_t launch_len = strlen("+tblink.launch=");
    for (int32_t i=0; i<info.argc; i++) {
    	if (!strncmp(info.argv[i], "+tblink.arg=", pref_len)) {
    		if (!params) {
    			params = m_tblink->newLaunchParams();
    		}
    		params->add_arg(&info.argv[i][pref_len]);
    	} else if (!strncmp(info.argv[i], "+tblink.launch=", launch_len)) {
    		std::string id = &info.argv[i][launch_len];

    		if (launch_t) {
    			fprintf(stdout, "TBLink Error: multiple +tblink.launch arguments specified\n");
    			return 0;
    		}

    		launch_t = m_tblink->findLaunchType(id);

    		if (!launch_t) {
    			fprintf(stdout, "TBLink Error: failed to find launch id %s\n", id.c_str());
    			for (std::vector<ILaunchType *>::const_iterator
    					it=m_tblink->launchTypes().begin();
    					it!=m_tblink->launchTypes().end(); it++) {
    				fprintf(stdout, "  Launch Type: %s\n", (*it)->name().c_str());
    			}
    			return 0;
    		}
    	}

    	if (launch_t) {
    		EndpointServicesDpi *ep_services = new EndpointServicesDpi(
					m_dpi_api,
    				m_vpi_api,
					m_have_blocking_tasks);
    		ILaunchType::result_t launch_res = launch_t->launch(params);

    		if (!launch_res.first) {
    			fprintf(stdout, "TBLink Error: launch failed: %s\n",
    					launch_res.second.c_str());
    			return 0;
    		}
    		m_auto_ep = launch_res.first;
    		m_auto_ep->init(ep_services, 0);
    	} else if (params) {
    		fprintf(stdout, "TBLink Error: launch parameters specified, but no launch\n");
    		return 0;
    	}
    }
#endif


	return 1;
}

int32_t TblinkPluginDpi::register_dpi_bfm(
			const std::string	&inst_path,
			const std::string	&invoke_nb_f,
			const std::string	&invoke_b_f) {
	fprintf(stdout, "TblinkPluginDpi::register_dpi_bfm\n");
	return 0;
}

ParamValVec *TblinkPluginDpi::get_plusargs(const std::string &prefix) {
	ParamValVec *ret = new ParamValVec();
	uint32_t prefix_len = prefix.size();
    s_vpi_vlog_info info;

    fprintf(stdout, "--> get_plusargs\n");
    fflush(stdout);

    m_vpi_api->vpi_get_vlog_info(&info);

    fprintf(stdout, "-- post-get-args\n");
    fflush(stdout);

    for (int32_t i=0; i<info.argc; i++) {
    	int32_t arg_len = strlen(info.argv[i]);

		fprintf(stdout, "arg: %s\n", info.argv[i]);
    	// Ensure arg is longer than +<prefix>=
    	if (arg_len > prefix.size()+2) {
    		if (!strncmp(&info.argv[i][1], prefix.c_str(), prefix.size()) &&
    				info.argv[i][prefix.size()+1] == '=') {
    			ret->push_back(new ParamValStr(&info.argv[i][prefix.size()+2]));
    		}
    	}
    }

    fprintf(stdout, "<-- get_plusargs %p\n", ret);
    fflush(stdout);

	return ret;
}

} /* namespace tblink_rpc_hdl */



