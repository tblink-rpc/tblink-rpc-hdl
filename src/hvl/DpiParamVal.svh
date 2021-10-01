
/****************************************************************************
 * DpiParamVal.svh
 ****************************************************************************/

typedef class DpiParamValBool;
  
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

	static function IParamVal mk(chandle hndl);
		IParamVal ret;
		case (_tblink_rpc_iparam_val_type(hndl))
			Bool: begin
				DpiParamValBool t = new(hndl);
				ret = t;
			end
			/*
				Int: begin
					ParamValInt t = new();
					ret = t;
				end
				Map: begin
					ParamValMap t = new();
					ret = t;
				end
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


