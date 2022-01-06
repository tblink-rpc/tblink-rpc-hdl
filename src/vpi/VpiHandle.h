/*
 * vpiHandleW.h
 *
 *  Created on: Jul 17, 2021
 *      Author: mballance
 */

#pragma once
#include <memory>
#include <string>

#include "vpi_api.h"

namespace tblink_rpc_hdl {

class VpiHandle;
typedef std::shared_ptr<VpiHandle> VpiHandleSP;
class VpiHandle {
public:
	VpiHandle(vpi_api_t *api, vpiHandle hndl);

	virtual ~VpiHandle();

	vpi_api_t *vpi() const { return m_vpi; }

	vpiHandle hndl() { return m_hndl; }

	void hndl(vpiHandle h) { m_hndl = h; }

	vpiHandle release();

	VpiHandleSP systf_h();

	VpiHandleSP tf_args();

	VpiHandleSP scan();

	VpiHandleSP handle(int type);

	int32_t get(int32_t property);

	std::string get_str(int property);

	bool val_bool();

	void val_bool(bool v);

	int64_t val_i64();

	void val_i64(int64_t v);

	int32_t val_i32();

	void val_i32(int32_t v);

	uint64_t val_ui64();

	void val_ui64(uint64_t v);

	std::string val_str();

	void *val_ptr();

	void val_ptr(void *v);

	template <class T> T *val_ptrT() {
		return reinterpret_cast<T *>(val_ptr());
	}

	template <class T> void val_ptrT(T *v) {
		val_ptr(reinterpret_cast<void *>(v));
	}

	static VpiHandleSP mk(vpi_api_t *api);

	static VpiHandleSP mk(vpi_api_t *api, vpiHandle hndl);

private:
	vpi_api_t			*m_vpi;
	vpiHandle			m_hndl;

};

} /* namespace tblink_rpc_hdl */

