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

	int (*eps_proxy_add_time_cb)(void *hndl, uint64_t time, intptr_t cb_id);
	uint64_t (*eps_proxy_time)(void *hndl);
	void (*eps_proxy_shutdown)(void *hndl);
	void (*eps_proxy_args)(void *hndl, void *vec);

	void (*epl_event)(void *hndl, void *ev);

	void (*ifi_closure_invoke_rsp)(void *, void *);
	void (*ifimpl_proxy_init)(void *, void *);
	void (*ifimpl_proxy_invoke)(void *, void *, void *, intptr_t, void *);

	void *(*ifimpl_factory_proxy_createImpl)(void *);

	void (*dlp_proxy_add_arg)(void *hndl, const char *arg);
	void (*dlp_proxy_add_param)(void *hndl, const char *key, const char *val);

	void (*tbl_proxy_notify)(void *proxy_h, void *ev_h);

	void (*toggle_vpi_ev)();

} dpi_api_t;




