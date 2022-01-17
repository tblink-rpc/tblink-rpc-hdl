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

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
	endfunction
	
	function void connect_phase(uvm_phase phase);
	endfunction
	
	task run_phase(uvm_phase phase);
	endtask

endclass


