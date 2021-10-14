/****************************************************************************
 * DpiType.svh
 ****************************************************************************/

typedef class DpiTypeVec;
typedef class DpiTypeInt;
typedef class DpiTypeMap;
  
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
				Bool, Str: begin
					DpiType type_dpi;
					$cast(type_dpi, t);
					return type_dpi.m_hndl;
				end
				Int: begin
					DpiTypeInt type_dpi;
					$cast(type_dpi, t);
					return type_dpi.m_hndl;
				end
				Map: begin
					DpiTypeMap type_dpi;
					$cast(type_dpi, t);
					return type_dpi.m_hndl;
				end
				Vec: begin
					DpiTypeVec type_dpi;
					$cast(type_dpi, t);
					return type_dpi.m_hndl;
				end
			endcase
		end
	endfunction
	
	static function DpiType mk(chandle hndl);
		if (hndl == null) begin
			return null;
		end else begin
			type_kind_e kind = _kind(hndl);
			
			case (kind)
				Bool, Str: begin
				end
				Int: begin
				end
				Map: begin
				end
				Vec: begin
				end
			endcase
		end
	endfunction
endclass

import "DPI-C" context function int tblink_rpc_IType_kind(chandle hndl);


