
/****************************************************************************
 * DpiParamVal.svh
 ****************************************************************************/

typedef class DpiParamValBool;
typedef class DpiParamValMap;
  
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
	
	virtual function kind_e kind();
		return _kind(m_hndl);
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
			case (v.kind())
				Bool: begin
					DpiParamValBool dpi_v;
					`DYN_CAST(dpi_v, v);
					return dpi_v.m_hndl;
				end
				Int: begin
					DpiParamValInt dpi_v;
					`DYN_CAST(dpi_v, v);
					return dpi_v.m_hndl;
				end
				Map: begin
					DpiParamValMap dpi_v;
					`DYN_CAST(dpi_v, v);
					return dpi_v.m_hndl;
				end
				Str: begin
					/*
					DpiParamValStr dpi_v;
					`DYN_CAST(dpi_v, v);
					return dpi_v.m_hndl;
					 */
				end
				Vec: begin
					/*
					DpiParamValVec dpi_v;
					`DYN_CAST(dpi_v, v);
					return dpi_v.m_hndl;
					 */
				end
			endcase
		end
	endfunction

	static function IParamVal mk(chandle hndl);
		IParamVal ret;
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
				/*
				Str: begin
					ParamValStr t = new();
					ret = t;
				end
			 */
			Vec: begin
				IParamValVec t = new();
				ret = t;
			end
			default: begin
				$display("Error: unhandled value type");
				$finish();
			end
		endcase
//		ret.m_hndl = hndl;
		return ret;
	endfunction
	
endclass


