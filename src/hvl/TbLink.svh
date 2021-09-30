
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
	
	static function TbLink inst();
		if (_tblink_inst == null) begin
			_tblink_inst = new();
		end
		return _tblink_inst;
	endfunction


endclass


