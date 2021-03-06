
/****************************************************************************
 * DpiParamVal.svh
 ****************************************************************************/

typedef class DpiParamValBool;
typedef class DpiParamValInt;
typedef class DpiParamValMap;
typedef class DpiParamValVec;
typedef class DpiParamValStr;
  
/**
 * Class: DpiParamVal
 * 
 * TODO: Add class documentation
 */
class DpiParamVal extends IParamVal;
	chandle				m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction
	
	static function kind_e _kind(chandle hndl);
		return kind_e'(_tblink_rpc_iparam_val_type(hndl));
	endfunction

	virtual function IParamVal clone();
		return _clone(m_hndl);
	endfunction
	
	static function IParamVal _clone(chandle hndl);
		chandle hndl_c = _tblink_rpc_iparam_val_clone(hndl);
		return mk(hndl_c);
	endfunction
	
	static function chandle getHndl(IParamVal v);
		if (v == null) begin
			return null;
		end else begin
			$display("getHndl: kind=%0s", v.kind());
			case (v.kind())
				Bool: begin
					DpiParamValBool dpi_v;
					$cast(dpi_v, v);
					return dpi_v.m_hndl;
				end
				Int: begin
					DpiParamValInt dpi_v;
					$cast(dpi_v, v);
					return dpi_v.m_hndl;
				end
				Map: begin
					DpiParamValMap dpi_v;
					$cast(dpi_v, v);
					return dpi_v.m_hndl;
				end
				Str: begin
					DpiParamValStr dpi_v;
					$cast(dpi_v, v);
					return dpi_v.m_hndl;
				end
				Vec: begin
					DpiParamValVec dpi_v;
					$cast(dpi_v, v);
					return dpi_v.m_hndl;
				end
			endcase
		end
	endfunction

	static function IParamVal mk(chandle hndl);
		IParamVal ret;
		
		if (hndl != null) begin
			case (_tblink_rpc_iparam_val_type(hndl))
				Bool: begin
					DpiParamValBool t = new(hndl);
					ret = t;
				end
				Int: begin
					DpiParamValInt t = new(hndl);
					ret = t;
				end
				Map: begin
					DpiParamValMap t = new(hndl);
					ret = t;
				end
				Str: begin
					DpiParamValStr t = new(hndl);
					ret = t;
				end
				Vec: begin
					DpiParamValVec t = new(hndl);
					ret = t;
				end
				default: begin
					$display("Error: unhandled value type");
					$finish();
				end
			endcase
		end
		return ret;
	endfunction
	
	static function void do_dispose(chandle hndl);
		tblink_rpc_IParamVal_dispose(hndl);
	endfunction
	
	virtual function void dispose();
		do_dispose(m_hndl);
	endfunction
	
endclass

import "DPI-C" context function void tblink_rpc_IParamVal_dispose(chandle hndl);

