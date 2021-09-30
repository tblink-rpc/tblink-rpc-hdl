
/****************************************************************************
 * DpiType.svh
 ****************************************************************************/

  
/**
 * Class: DpiType
 * 
 * TODO: Add class documentation
 */
class DpiType extends IType;
	chandle			m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction

	virtual function type_kind_e kind();
		$display("Tblink Error: IType::kind not implemented");
		$finish(1);
	endfunction

endclass


