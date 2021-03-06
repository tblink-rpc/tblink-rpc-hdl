/*
 * TblinkPluginDpi.h
 *
 *  Created on: Sep 20, 2021
 *      Author: mballance
 */

#pragma once
#include <memory>
#include <unordered_map>

#include "../vpi/vpi_api.h"
#include "dpi_api.h"
#include "tblink_rpc/ITbLink.h"
#include "ParamValVec.h"

namespace tblink_rpc_hdl {

using namespace tblink_rpc_core;

class TblinkPluginDpi;
typedef std::unique_ptr<TblinkPluginDpi> TblinkPluginDpiUP;
/**
 * Global TbLink Entrypoint for DPI environments
 */
class TblinkPluginDpi {
public:
	typedef void *(*nb_f_t)(void *ifinst, void *method, void *params);
	typedef int (*b_f_t)(void **reval, void *ifinst, void *method, void *params);
	typedef std::tuple<void *, nb_f_t, b_f_t> invoke_info_t;

public:
	TblinkPluginDpi(
			vpi_api_t		*vpi_api,
			dpi_api_t		*dpi_api,
			bool			have_blocking_tasks=true
			);

	virtual ~TblinkPluginDpi();

	int init();

	tblink_rpc_core::IEndpoint *endpoint() {
		return m_auto_ep;
	}

	vpi_api_t *vpi_api() const { return m_vpi_api; }

	dpi_api_t *dpi_api() const { return m_dpi_api; }

	bool have_blocking_tasks() const {
		return m_have_blocking_tasks;
	}

	void have_blocking_tasks(bool h) {
		m_have_blocking_tasks = h;
	}

	int32_t register_dpi_bfm(
			const std::string	&inst_path,
			const std::string	&invoke_nb_f,
			const std::string	&invoke_b_f);

	invoke_info_t get_dpi_invoke_info(
			const std::string	&inst_path);

	ParamValVec *get_plusargs(
			const std::string	&prefix);

private:
	vpi_api_t					*m_vpi_api;
	dpi_api_t					*m_dpi_api;
	bool						m_have_blocking_tasks;
	tblink_rpc_core::ITbLink	*m_tblink;
	tblink_rpc_core::IEndpoint	*m_auto_ep;
	std::unordered_map<std::string, invoke_info_t>	m_dpi_invoke_m;

};

} /* namespace tblink_rpc_hdl */

