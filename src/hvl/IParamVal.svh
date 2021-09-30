
/****************************************************************************
 * IParamVal.svh
 ****************************************************************************/

  
/**
 * Class: IParamVal
 * 
 * TODO: Add class documentation
 */
class IParamVal;
	chandle			m_hndl;
			
	typedef enum {
		Bool=0,
		Int,
		Map,
		Str,
		Vec
	} Type;
		
	function Type param_type();
		return Type'(_tblink_rpc_iparam_val_type(m_hndl));
	endfunction
		
	function IParamVal clone();
		chandle hndl = _tblink_rpc_iparam_val_clone(m_hndl);
		return mk(hndl);
	endfunction
		
	static function IParamVal mk(chandle hndl);
		IParamVal ret;
		case (_tblink_rpc_iparam_val_type(hndl))
			Bool: begin
				IParamValBool t = new();
				ret = t;
			end
				Int: begin
					IParamValInt t = new();
					ret = t;
				end
			/*
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
		ret.m_hndl = hndl;
		return ret;
	endfunction
endclass

