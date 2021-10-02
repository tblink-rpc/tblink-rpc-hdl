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
		return _kind(m_hndl);
	endfunction
	
	static function type_kind_e _kind(chandle hndl);
		return type_kind_e'(tblink_rpc_IType_kind(hndl));
	endfunction
	
	static function chandle getHndl(IType t);
		if (t == null) begin
			return null;
		end else begin
			case (t.kind())
			endcase
		end
	endfunction
	
	static function DpiType mk(chandle hndl);
		if (hndl == null) begin
			return null;
		end else begin
			type_kind_e kind = _kind(hndl);
			
			case (kind)
			endcase
		end
	endfunction
endclass

import "DPI-C" context function int tblink_rpc_IType_kind(chandle hndl);


