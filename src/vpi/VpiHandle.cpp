/*
 * vpiHandleW.cpp
 *
 *  Created on: Jul 17, 2021
 *      Author: mballance
 */

#include "VpiHandle.h"

namespace tblink_rpc_hdl {

VpiHandle::VpiHandle(vpi_api_t *vpi, vpiHandle hndl)
		: m_vpi(vpi), m_hndl(hndl) {
	// TODO Auto-generated constructor stub

}

VpiHandle::~VpiHandle() {
	if (m_hndl) {
		m_vpi->vpi_free_object(m_hndl);
	}
}

vpiHandle VpiHandle::release() {
	vpiHandle ret = m_hndl;
	m_hndl = 0;
	return ret;
}

VpiHandleSP VpiHandle::systf_h() {
	return VpiHandle::mk(m_vpi, m_vpi->vpi_handle(vpiSysTfCall, 0));
}

VpiHandleSP VpiHandle::tf_args() {
	vpiHandle args = m_vpi->vpi_iterate(vpiArgument, m_hndl);
    return VpiHandle::mk(
    		m_vpi,
			args);
}

VpiHandleSP VpiHandle::scan() {
	vpiHandle next = m_vpi->vpi_scan(m_hndl);

	if (!next) {
		m_hndl = 0;
	}

	return VpiHandle::mk(
			m_vpi,
			next);
}

VpiHandleSP VpiHandle::handle(int type) {
	vpiHandle hndl = m_vpi->vpi_handle(type, m_hndl);
	return VpiHandle::mk(
			m_vpi,
			hndl);
}

int32_t VpiHandle::get(int32_t property) {
	return m_vpi->vpi_get(property, m_hndl);
}

std::string VpiHandle::get_str(int property) {
	std::string ret = m_vpi->vpi_get_str(property, m_hndl);
	return ret;
}

bool VpiHandle::val_bool() {
	return val_i64();
}

void VpiHandle::val_bool(bool v) {
	val_i32(v);
}

int64_t VpiHandle::val_i64() {
    int arg_t = m_vpi->vpi_get(vpiType, m_hndl);
    intptr_t pval;

    if (arg_t == vpiReg || arg_t == vpiNet) {
    	s_vpi_value val;
        int arg_sz = m_vpi->vpi_get(vpiSize, m_hndl);

        val.format = vpiVectorVal;
        val.value.vector = 0;
        m_vpi->vpi_get_value(m_hndl, &val);

        if (arg_sz >= 32) {
                pval = (uint32_t)val.value.vector[0].aval;
                arg_sz -= 32;
        } else {
                pval = ((uint32_t)val.value.vector[0].aval & ((1 << arg_sz)-1));
                arg_sz = 0;
        }

        if (arg_sz > 0) {
        	uint64_t tv = ((uint32_t)val.value.vector[1].aval & ((1 << arg_sz)-1));
            pval |= tv << 32;
        }
    } else {
    	s_vpi_value val;
    	val.format = vpiIntVal;
    	m_vpi->vpi_get_value(m_hndl, &val);
    	pval = (uint32_t)val.value.integer;
    }

    return pval;
}

void VpiHandle::val_i64(int64_t v) {
    s_vpi_value val;
    s_vpi_vecval vv[2];

    // Set return value
    vv[0].bval = 0;
    vv[1].bval = 0;
    vv[0].aval = v;
    vv[1].aval = (v >> 32);

    val.format = vpiVectorVal;
    val.value.vector = vv;
    m_vpi->vpi_put_value(m_hndl, &val, 0, vpiNoDelay);
}

int32_t VpiHandle::val_i32() {
	return val_i64();
}

void VpiHandle::val_i32(int32_t v) {
    s_vpi_value val;

    val.format = vpiIntVal;
    val.value.integer = v;
    m_vpi->vpi_put_value(m_hndl, &val, 0, vpiNoDelay);
}

uint64_t VpiHandle::val_ui64() {
	return val_i64();
}

void VpiHandle::val_ui64(uint64_t v) {
	return val_i64(v);
}

std::string VpiHandle::val_str() {
	s_vpi_value val;
	val.format = vpiStringVal;
    int arg_t = m_vpi->vpi_get(vpiType, m_hndl);
	m_vpi->vpi_get_value(m_hndl, &val);
	return val.value.str;
}

void *VpiHandle::val_ptr() {
	return reinterpret_cast<void *>(val_i64());
}

void VpiHandle::val_ptr(void *v) {
	val_i64(reinterpret_cast<int64_t>(v));
}

VpiHandleSP VpiHandle::mk(vpi_api_t *api) {
	return VpiHandleSP(new VpiHandle(api, 0));
}

VpiHandleSP VpiHandle::mk(vpi_api_t *api, vpiHandle hndl) {
	return VpiHandleSP(new VpiHandle(api, hndl));
}

} /* namespace tblink_rpc_hdl */
