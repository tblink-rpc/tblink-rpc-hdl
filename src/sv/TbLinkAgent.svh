/****************************************************************************
 * TbLinkAgent.svh
 ****************************************************************************/


/**
 * Class: TbLinkAgent
 * 
 * TODO: Add class documentation
 */
class TbLinkAgent extends uvm_component;
	`uvm_component_utils(TbLinkAgent)
	
	IEndpoint				m_ep;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		TbLink tblink = TbLink::inst();
		TbLinkAgentConfig cfg = TbLinkAgentConfig::get(this);
		ILaunchParams params;
		ILaunchType launch_t;
		string errmsg;
		
		if (cfg == null) begin
			`uvm_fatal("TbLinkAgent", "Failed to obtain agent configuration");
			return;
		end
		
		launch_t = tblink.findLaunchType(cfg.launch_type);
		
		if (launch_t == null) begin
			`uvm_fatal("TbLinkAgent", $sformatf("Failed to find launch type %0s", 
					cfg.launch_type));
			return;
		end
	
		params = launch_t.newLaunchParams();
		
		foreach (cfg.launch_args[i]) begin
			params.add_arg(cfg.launch_args[i]);
		end
		foreach (cfg.launch_params[k]) begin
			params.add_param(k, cfg.launch_params[k]);
		end
	
		m_ep = launch_t.launch(params, null, errmsg);
		
		if (m_ep == null) begin
			`uvm_fatal("TbLinkAgent", $sformatf("Failed to launch type %0s (%0s)",
					cfg.launch_type, errmsg));
			return;
		end
		
		
	endfunction
	
	function void connect_phase(uvm_phase phase);
	endfunction
	
	task run_phase(uvm_phase phase);
	endtask

endclass


