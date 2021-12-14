/*
 * dpi_api.h
 *
 *  Created on: Jul 29, 2021
 *      Author: mballance
 */

#pragma once
#include <stdint.h>

typedef struct dpi_api_s {
	void *(*svGetScope)();
	void *(*svSetScope)(void *);
	void *(*get_pkg_scope)(void);
	void (*invoke)(
			void		*ifinst_h,
			void		*method_h,
			intptr_t	call_id,
			void		*params_h);

	/**
	 * Note: these callbacks are Verilator-specific
	 */
	void (*delta_cb)();
	int (*dispatch_cb)();

	void (*add_time_cb)(void *cb_data, uint64_t delta);

	void (*eps_proxy_shutdown)(void *hndl);
	void (*eps_proxy_run_until_event)(void *hndl);
	void (*eps_proxy_hit_event)(void *hndl);
	void (*eps_proxy_idle)(void *hndl);

	void (*epl_event)(void *hndl, void *ev);

	void (*ifi_closure_invoke_rsp)(void *, void *);

	void (*toggle_vpi_ev)();

} dpi_api_t;




