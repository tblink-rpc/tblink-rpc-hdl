
/****************************************************************************
 * TbLink.svh
 ****************************************************************************/

// Static class members are not yet supported in Verilator
typedef class TbLink;
TbLink			_tblink_inst;
  
/**
 * Class: TbLink
 * 
 * TODO: Add class documentation
 */
class TbLink;
	IEndpoint			m_default_ep;
	ILaunchType			m_sv_launch_type_m[string];

	function new();
	endfunction
	
	function IEndpoint get_default_ep();
		if (m_default_ep == null) begin
			// TODO: query native layer to determine if a default
			// endpoint has been created there
			
			$display("Need to build new");
		end
		return m_default_ep;
	endfunction
	
	function ILaunchType findLaunchType(string id);
		ILaunchType ret;
		
		if (m_sv_launch_type_m.exists(id) != 0) begin
			ret = m_sv_launch_type_m[id];
		end else begin
			chandle launch_type_h = tblink_rpc_findLaunchType(id);
		
			if (launch_type_h != null) begin
				DpiLaunchType ret_dpi;
				ret_dpi = new(launch_type_h);
				ret = ret_dpi;
			end
		end
		
		return ret;
	endfunction
	
	function void registerLaunchType(ILaunchType lt);
		m_sv_launch_type_m[lt.name()] = lt;
	endfunction
	
	static function TbLink inst();
		if (_tblink_inst == null) begin
			_tblink_inst = new();
		end
		return _tblink_inst;
	endfunction

endclass

import "DPI-C" context function chandle tblink_rpc_findLaunchType(string id);

