
/****************************************************************************
 * loopback_smoke_driver.svh
 ****************************************************************************/

  
/**
 * Class: loopback_smoke_driver
 * 
 * TODO: Add class documentation
 */
class loopback_smoke_driver extends uvm_component;
	`uvm_component_utils(loopback_smoke_driver)
	IEndpoint					m_ep;
	
	typedef loopback_smoke_driver this_t;
	loopback_smoke_bfm_impl	#(this_t)	m_impl;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	// Dummy in this application
	function void inc();
	endfunction
	
	function void build_phase(uvm_phase phase);
		string ifinst_path;
		IInterfaceType iftype;
		IInterfaceInst ifinst;
		$display("driver::build_phase");
		
		if (!uvm_config_db #(IEndpoint)::get(this, "", "IEndpoint", m_ep)) begin
			`uvm_fatal("loopback_smoke_driver", "No endpoint registered");
			return;
		end
		
		if (!uvm_config_db #(string)::get(this, "", "IInterfaceInst", ifinst_path)) begin
			`uvm_fatal("loopback_smoke_driver", "No interface path specified");
			return;
		end
		
		iftype = loopback_smoke_bfm_define_type(m_ep);
		
		ifinst = m_ep.defineInterfaceInst(
				iftype,
				ifinst_path,
				1,
				m_impl
				);
		
		if (ifinst == null) begin
			`uvm_fatal("loopback_smoke_driver", "Failed to find interface inst");
			return;
		end
		
		m_impl = new(ifinst, this);
	endfunction
	
	function void connect_phase(uvm_phase phase);
		
	endfunction
	
	task run_phase(uvm_phase phase);
	endtask

endclass


