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
		TbLinkAgentConfig sv_cfg = new("connect.sv.loopback");
		TbLinkAgentConfig py_cfg = new("native.loopback");
		
		m_pyagent = TbLinkAgent::type_id::create("m_pyagent", this);
		m_svagent = TbLinkAgent::type_id::create("m_svagent", this);
		
		if (!m_pyagent.init(py_cfg, this)) begin
			return;
		end
		if (!m_svagent.init(sv_cfg, this)) begin
			return;
		end
		
		// Now, can build remaining components
	endfunction
	
	function void connect_phase(uvm_phase phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this, "Main", 1);
//		phase.drop_objection(this, "Main", 1);
	endtask


endclass


