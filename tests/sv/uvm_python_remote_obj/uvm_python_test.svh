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
	
	function new(string name, uvm_component parent=null);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		 //
	endfunction
	
	function void connect_phase(uvm_phase phase);
	endfunction
	
	uvm_python_remote_obj m_ref_model;
	
	
	task run_phase(uvm_phase phase);
		string python;
		m_ref_model = new();

		// Create the launch configuration, specifying the Python
		// module that contains the object class
		m_ref_model.set_config(mkConfigPythonSingleObject("uvm_python_obj"));
		
		// Start the remote object. If this fails, it will
		// signal a UVM fatal error
		m_ref_model.launch();
	endtask
		
		phase.raise_objection(this, "Main", 1);
		for (int i=0; i<5; i++) begin
			for (int j=0; j<5; j++) begin
				// Call the remote object
				int val = obj.add(i, j);
				$display("[%0t] a=%0d b=%0d: %0d", $time, i, j, val);
			end
		end
		phase.drop_objection(this, "Main", 1);
	endtask
	
	function void check(
		int unsigned a, 
		int unsigned b,
		int unsigned result);
		int unsigned exp = m_ref_model.add(a, b);
		
		if (exp != result) begin
			`uvm_error("UvmPythonTest", $sformat("A=%0d B=%0d result=%0d ; exp=%0d",
					a, b, result, exp));
		end
	endfunction


endclass


