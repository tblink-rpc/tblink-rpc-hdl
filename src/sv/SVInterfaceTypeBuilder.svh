/****************************************************************************
 * SVInterfaceTypeBuilder.svh
 ****************************************************************************/

  
/**
 * Class: SVInterfaceTypeBuilder
 * 
 * TODO: Add class documentation
 */
class SVInterfaceTypeBuilder extends IInterfaceTypeBuilder;
	SVInterfaceType				m_iftype;

	function new(string name);
		m_iftype = new(name);
	endfunction
	
	virtual function IMethodTypeBuilder newMethodTypeBuilder(
		string					name,
		longint					id,
		IType					rtype,
		int unsigned			is_export,
		int unsigned			is_blocking);
		SVMethodTypeBuilder mtb_sv = new(
			name, 
			id, 
			rtype, 
			(is_export!=0), 
			(is_blocking!=0));
		return mtb_sv;
	endfunction
	
	virtual function IMethodType add_method(
		IMethodTypeBuilder		mtb);
		SVMethodTypeBuilder mtb_sv;
		$cast(mtb_sv, mtb);
		m_iftype.add_method(mtb_sv.method_t);
		return mtb_sv.method_t;
	endfunction

	virtual function IType mkTypeBool();
		SVType ret;
		IType::type_kind_e kind;
		kind = IType::Bool;
		ret = new(kind);
		return ret;
	endfunction
	
	virtual function ITypeInt mkTypeInt(
		int unsigned			is_signed,
		int						width);
		SVTypeInt ret = new(is_signed, width);
		return ret;
	endfunction

	virtual function ITypeMap mkTypeMap(
		IType					key_t,
		IType					elem_t);
		SVTypeMap ret = new(key_t, elem_t);
		return ret;
	endfunction
	
	virtual function IType mkTypeStr();
		SVType ret;
		IType::type_kind_e kind;
		kind = IType::Str;
		ret = new(kind);
		return ret;
	endfunction
	
	virtual function ITypeVec mkTypeVec(
		IType					elem_t);
		SVTypeVec ret = new(elem_t);
		return ret;
	endfunction

endclass


