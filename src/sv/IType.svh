/****************************************************************************
 * IType.svh
 ****************************************************************************/

  
/**
 * Class: IType
 * 
 * TODO: Add class documentation
 */
class IType;
	
	typedef enum {
		Bool,
		Int,
		Map,
		Str,
		Vec
	} type_kind_e;

	virtual function type_kind_e kind();
		$display("Tblink Error: IType::kind not implemented");
		$finish(1);
		return Bool;
	endfunction

endclass


