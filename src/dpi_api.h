/*
 * dpi_api.h
 *
 *  Created on: Jul 29, 2021
 *      Author: mballance
 */

#pragma once

typedef struct dpi_api_s {
	void *(*svGetScope)();
	void *(*svSetScope)(void *);
	void (*invoke_nb)(void *call_h);
	void (*add_time_cb)(void *cb_data, uint64_t delta);

} dpi_api_t;




