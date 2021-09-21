/*
 * TblinkPluginDpi.h
 *
 *  Created on: Sep 20, 2021
 *      Author: mballance
 */

#pragma once
#include <memory>
#include "dpi_api.h"
#include "vpi_api.h"
#include "tblink_rpc/ITbLink.h"

namespace tblink_rpc_hdl {

class TblinkPluginDpi;
typedef std::unique_ptr<TblinkPluginDpi> TblinkPluginDpiUP;
/**
 * Global TbLink Entrypoint for DPI environments
 */
class TblinkPluginDpi {
public:
	TblinkPluginDpi(
			vpi_api_t		*vpi_api,
			dpi_api_t		*dpi_api,
			bool			have_blocking_tasks
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

private:
	vpi_api_t					*m_vpi_api;
	dpi_api_t					*m_dpi_api;
	bool						m_have_blocking_tasks;
	tblink_rpc_core::ITbLink	*m_tblink;
	tblink_rpc_core::IEndpoint	*m_auto_ep;

};

} /* namespace tblink_rpc_hdl */

