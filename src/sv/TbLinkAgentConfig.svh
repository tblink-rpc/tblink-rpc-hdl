
/****************************************************************************
 * TbLinkAgentConfig.svh
 ****************************************************************************/

  
/**
 * Class: TbLinkAgentConfig
 * 
 * TODO: Add class documentation
 */
class TbLinkAgentConfig;
	string					launch_type;
	string					launch_args[$];
	string					launch_params[string];
	
	static const string		FIELD = "tblink.agent.config";

	function new(string launch_type);
		this.launch_type = launch_type;
	endfunction
	
	static function TbLinkAgentConfig get(uvm_component ctxt);
		TbLinkAgentConfig cfg;
		
		if (!uvm_config_db #(TbLinkAgentConfig)::get(ctxt, "", FIELD, cfg)) begin
			cfg = null;
		end
		
		return cfg;
	endfunction
	
	function void set(uvm_component ctxt, string inst_name="*");
		uvm_config_db #(TbLinkAgentConfig)::set(ctxt, inst_name, FIELD, this);
	endfunction
	

endclass


