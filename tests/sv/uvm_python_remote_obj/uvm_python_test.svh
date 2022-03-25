/****************************************************************************
 * uvm_python_test.svh
 ****************************************************************************/

/**
 * Class: uvm_python_test
 * 
 * TODO: Add class documentation
 */
class uvm_python_test extends uvm_test;
	`uvm_component_utils(uvm_python_test)
	
	TbLinkAgent					m_svagent;
	TbLinkAgent					m_pyagent;

	function new(string name, uvm_component parent=null);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		// Now, can build remaining components
		TbLinkAgentConfig sv_cfg = new("connect.sv.loopback");
		
		m_svagent = TbLinkAgent::type_id::create("m_svagent", this);
		
		if (!m_svagent.init(sv_cfg)) begin
			`uvm_fatal(get_name(), "Failed to initialize TbLink SV Agent");
			return;
		end

	endfunction
	
	function void connect_phase(uvm_phase phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		string python;
		uvm_python_remote_obj obj = new();
		TbLinkAgentConfig cfg = new("python.loopback");
		
		cfg.launch_params["module"] = "tblink_rpc.rt.cocotb";
		if ($value$plusargs("python=%s", python)) begin
			cfg.launch_params["python"] = python;
		end
		
//		cfg.launch_params["class"] = 
		
		obj.set_config(cfg);
		
		phase.raise_objection(this, "Main", 1);
		obj.launch();
		
		for (int i=0; i<5; i++) begin
			for (int j=0; j<5; j++) begin
				int val = obj.add(i, j);
				$display("a=%0d b=%0d: %0d", i, j, val);
			end
		end
		
		#1ms;
		phase.drop_objection(this, "Main", 1);
	endtask


endclass


