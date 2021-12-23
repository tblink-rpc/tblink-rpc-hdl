
/****************************************************************************
 * IInterfaceTypeBuilder.svh
 ****************************************************************************/

  
/**
 * Class: IInterfaceTypeBuilder
 * 
 * TODO: Add class documentation
 */
class IInterfaceTypeBuilder;
	
	virtual function IMethodTypeBuilder newMethodTypeBuilder(
		string					name,
		longint					id,
		IType					rtype,
		int unsigned			is_export,
		int unsigned			is_blocking);
		return null;
	endfunction
	
	virtual function IMethodType add_method(
		IMethodTypeBuilder		mtb);
		return null;
	endfunction
	
	virtual function IType mkTypeBool();
		return null;
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


