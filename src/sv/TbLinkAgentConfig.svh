
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
	string					ep_args[$];
	
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

function automatic TbLinkAgentConfig mkConfigPythonSingleObject(
	string cls_module,
	string cls="");
	TbLinkAgentConfig ret = new("python.loopback");
	string python;
	
	ret.launch_params["module"] = "tblink_rpc.rt.cocotb";
	
	if ($value$plusargs("python=%s", python)) begin
		ret.launch_params["python"] = python;
	end
	
	ret.ep_args.push_back("+regression_runner=tblink_rpc.rt.cocotb.single_entrypoint_runner");
	ret.ep_args.push_back($sformatf("+m=%0s", cls_module));
	
	// Pass the *actual* classname to use (if specified)
	if (cls != "") begin
		ret.ep_args.push_back($sformatf("+class=%0s", cls));
	end
	
	return ret;
endfunction

