
/****************************************************************************
 * DpiInterfaceTypeBuilder.svh
 ****************************************************************************/

  
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

	virtual function IType mkTypeBool();
		DpiType ret;
		chandle hndl = tblink_rpc_IInterfaceTypeBuilder_mkTypeBool(m_hndl);
		ret = new(hndl);
		return ret;
	endfunction
		
	virtual function ITypeInt mkTypeInt(
		int unsigned			is_signed,
		int						width);
		return null;
	endfunction
	
	virtual function ITypeMap mkTypeMap(
		IType					key_t,
		IType					elem_t);
		return null;
	endfunction
	
	virtual function IType mkTypeStr();
		return null;
	endfunction
	
	virtual function ITypeVec mkTypeVec(
		IType					elem_t);
		return null;
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
	
import "DPI-C" context function void tblink_rpc_IMethodTypeBuilder_add_param(
	chandle			method_b,
	string			name,
	chandle			type_h);
	
import "DPI-C" context function chandle _tblink_rpc_iftype_builder_define_method(
	chandle			iftype_b,
	string			name,
	longint			id,
	string			signature,
	int unsigned	is_export,
	int unsigned	is_blocking);

