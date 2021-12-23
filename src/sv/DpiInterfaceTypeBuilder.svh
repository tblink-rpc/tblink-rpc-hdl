
/****************************************************************************
 * DpiInterfaceTypeBuilder.svh
 ****************************************************************************/

typedef class DpiMethodType;
typedef class DpiMethodTypeBuilder;
  
/**
 * Class: DpiInterfaceTypeBuilder
 * 
 * TODO: Add class documentation
 */
class DpiInterfaceTypeBuilder extends IInterfaceTypeBuilder;
	chandle			m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction

	virtual function IMethodTypeBuilder newMethodTypeBuilder(
		string					name,
		longint					id,
		IType					rtype,
		int unsigned			is_export,
		int unsigned			is_blocking);
		DpiMethodTypeBuilder mtb;
		chandle rtype_h = DpiType::getHndl(rtype);
		chandle mtb_h;
		
		mtb_h = tblink_rpc_IInterfaceTypeBuilder_newMethodTypeBuilder(
				m_hndl,
				name,
				id,
				rtype_h,
				is_export,
				is_blocking);
		
		mtb = new(mtb_h);
		
		return mtb;
	endfunction
	
	virtual function IMethodType add_method(
		IMethodTypeBuilder		mtb);
		DpiMethodTypeBuilder mtb_dpi;
		DpiMethodType ret;
		chandle method_h;
		
		$cast(mtb_dpi, mtb);
		
		method_h = tblink_rpc_IInterfaceTypeBuilder_add_method(
				m_hndl,
				mtb_dpi.m_hndl);
		
		ret = new(method_h);
				
		return ret;
	endfunction
	
	virtual function IType mkTypeBool();
		DpiType ret;
		chandle hndl;
	        hndl = tblink_rpc_IInterfaceTypeBuilder_mkTypeBool(m_hndl);
		
		ret = new(hndl);
		
		return ret;
	endfunction
		
	virtual function ITypeInt mkTypeInt(
		int unsigned			is_signed,
		int						width);
		DpiTypeInt ret;
		chandle type_h = tblink_rpc_IInterfaceTypeBuilder_mkTypeInt(
				m_hndl,
				is_signed,
				width);
		
		ret = new(type_h);
		
		return ret;
	endfunction
	
	virtual function ITypeMap mkTypeMap(
		IType					key_t,
		IType					elem_t);
		chandle key_t_h = DpiType::getHndl(key_t);
		chandle elem_t_h = DpiType::getHndl(elem_t);
		DpiTypeMap ret;
		chandle type_h = tblink_rpc_IInterfaceTypeBuilder_mkTypeMap(
				m_hndl,
				key_t_h,
				elem_t_h);
		
		ret = new(type_h);
		
		return ret;
	endfunction
	
	virtual function IType mkTypeStr();
		DpiType ret;
		chandle type_h = tblink_rpc_IInterfaceTypeBuilder_mkTypeStr(m_hndl);
		
		ret = new(type_h);
		
		return ret;
	endfunction
	
	virtual function ITypeVec mkTypeVec(
		IType					elem_t);
		chandle elem_t_h = DpiType::getHndl(elem_t);
		DpiTypeVec ret;
		chandle type_h = tblink_rpc_IInterfaceTypeBuilder_mkTypeVec(
				m_hndl,
				elem_t_h);
		
		ret = new(type_h);
		
		return ret;
	endfunction

endclass

import "DPI-C" context function chandle tblink_rpc_IInterfaceTypeBuilder_mkTypeBool(
	chandle			iftype_b);
import "DPI-C" context function chandle tblink_rpc_IInterfaceTypeBuilder_mkTypeInt(
	chandle			iftype_b,
	int unsigned	is_signed,
	int unsigned	width);
import "DPI-C" context function chandle tblink_rpc_IInterfaceTypeBuilder_mkTypeMap(
	chandle			iftype_b,
	chandle			key_t,
	chandle			elem_t);
import "DPI-C" context function chandle tblink_rpc_IInterfaceTypeBuilder_mkTypeStr(
	chandle			iftype_b);
import "DPI-C" context function chandle tblink_rpc_IInterfaceTypeBuilder_mkTypeVec(
	chandle			iftype_b,
	chandle			elem_t);
import "DPI-C" context function chandle tblink_rpc_IInterfaceTypeBuilder_newMethodTypeBuilder(
	chandle			iftype_b,
	string			name,
	longint			id,
	chandle			rtype,
	int unsigned	is_export,
	int unsigned	is_blocking);
import "DPI-C" context function chandle tblink_rpc_IInterfaceTypeBuilder_add_method(
	chandle			iftype_b,
	chandle			mtb);
	
