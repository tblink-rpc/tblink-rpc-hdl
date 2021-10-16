
/****************************************************************************
 * loopback_smoke_test.svh
 ****************************************************************************/

  
/**
 * Class: loopback_smoke_test
 * 
 * TODO: Add class documentation
 */
class loopback_smoke_test extends uvm_test;
	`uvm_component_utils(loopback_smoke_test)
	
	loopback_smoke_driver			m_driver;
	IEndpoint						m_ep;

	function new(string name, uvm_component parent=null);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		TbLink tblink = TbLink::inst();
		IEndpoint ep = tblink.get_default_ep();
		SVEndpointLoopback ep_loopback;
		
		$display("test::build_phase");
		
		if (ep == null) begin
			`uvm_fatal("loopback_smoke_test", "No default endpoint");
			return;
		end
		
		if ($cast(ep_loopback, ep)) begin
			// The HDL endpoint is set as the default. 
			// We want the HVL endpoint
			m_ep = ep_loopback.m_peer_ep;
		end else begin
			m_ep = ep;
		end
		
		uvm_config_db #(IEndpoint)::set(this, "*", "IEndpoint", m_ep);
		
		m_driver = new("m_driver", this);
		
		if (m_ep.build_complete() == -1) begin
			`uvm_fatal("loopback_smoke_test", "tblink failed to complete build");
		end

	endfunction
	
	function void connect_phase(uvm_phase phase);
		if (m_ep.connect_complete() == -1) begin
			`uvm_fatal("loopback_smoke_test", "tblink failed to complete connect");
		end
	endfunction
	
	task run_phase(uvm_phase phase);
		$display("--> run_phase");
		phase.raise_objection(this, "Main", 1);
		for (int i=0; i<100000; i++) begin
			int rv = m_driver.m_impl.inc(i);
//			$display("inc: %0d => %0d", i, rv);
			if (rv != i+1) begin
				`uvm_fatal("loopback_smoke_test", "Incorrect result");
			end
		end
		phase.drop_objection(this, "Main", 1);
		$display("<-- run_phase");
	endtask

endclass


