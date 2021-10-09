
/****************************************************************************
 * SVMethodTypeBuilder.svh
 ****************************************************************************/

  
/**
 * Class: SVMethodTypeBuilder
 * 
 * TODO: Add class documentation
 */
class SVMethodTypeBuilder extends IMethodTypeBuilder;
	SVMethodType		method_t;

	function new(
		string			name,
		longint			id,
		IType			rtype,
		bit				is_export,
		bit				is_blocking);
		method_t = new(name, id, rtype, is_export, is_blocking);
	endfunction
	
	virtual function void add_param(
		string					name,
		IType					ptype);
		method_t.add_param(name, ptype);
	endfunction

endclass


