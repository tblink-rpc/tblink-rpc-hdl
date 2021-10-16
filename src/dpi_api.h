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

} dpi_api_t;




