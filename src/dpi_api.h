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
	void (*invoke)(void *ii_h);
	void (*delta_cb)();

	// Note: invoke_b is only used in environments where tasks
	// cannot be blocking. In most environments, 'invoke' queues
	// a blocking task invocation for later execution
	int (*invoke_b)(void *ii_h);
	void (*add_time_cb)(void *cb_data, uint64_t delta);

} dpi_api_t;




