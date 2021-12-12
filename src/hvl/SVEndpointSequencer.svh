/****************************************************************************
 * SVEndpointSequencer.svh
 ****************************************************************************/

`ifndef VERILATOR
  
/**
 * Class: SVEndpointSequencer
 * 
 * TODO: Add class documentation
 */
class SVEndpointSequencer extends IEndpointListener;
	IEndpoint				m_ep;
	semaphore				m_ev_sem = new(0);

	function new(IEndpoint ep);
		m_ep = ep;
		m_ep.addListener(this);
	endfunction
	
	task start();
		IInterfaceInst ifinsts[$];
		int last_ifinst_count = -1;
		int ret;
	
		$display("--> Wait for interfaces");
		for (int i=0; i<16; i++) begin
			last_ifinst_count = ifinsts.size();
			$display("--> #0");
			#0;
			$display("<-- #0");
			m_ep.getInterfaceInsts(ifinsts);
			$display("  last_ifinst_count=%0d ; ifinsts.size=%0d", last_ifinst_count, ifinsts.size());
			
			if (last_ifinst_count > 0 && last_ifinst_count == ifinsts.size()) begin
				break;
			end
		end
		$display("<-- Wait for interfaces");
		
		$display("done...");

		do begin
			ret = m_ep.is_init();

			if (ret == 0) begin
				#0;
				$display("--> process_one_message_b");
				ret = m_ep.process_one_message();
				$display("<-- process_one_message_b");
				
				if (ret == -1) begin
					break;
				end else begin
					ret = 0;
				end
			end
			
		end while (ret == 0);
		
		if (ret != 1) begin
			$display("TbLink Error: failed to initialize endpoint (%0d)", ret);
			$finish();
			return;
		end
		
		if (m_ep.build_complete() == -1) begin
			$display("TbLink Error: build-complete failed");
			$finish();
			return;
		end
	
		$display("--> is_build_complete");
		do begin
			ret = m_ep.is_build_complete();
			$display("is_build_complete: %0d", ret);
			
			if (ret == 0) begin
				#0;
				$display("--> process_one_message_b");
				ret = m_ep.process_one_message();
				$display("<-- process_one_message_b");
				
				if (ret == -1) begin
					break;
				end else begin
					ret = 0;
				end
			end
		end while (ret == 0);
		$display("<-- is_build_complete");
		
		if (ret != 1) begin
			$display("TbLink Error: failed to complete build phase (%0d)", ret);
			$finish();
			return;
		end

		$display("--> connect_complete");
		if (m_ep.connect_complete() == -1) begin
			$display("TbLink Error: connect-complete failed");
			$finish();
			return;
		end
		$display("<-- connect_complete");
		
		$display("--> is_connect_complete");
		do begin
			ret = m_ep.is_connect_complete();
			
			if (ret == 0) begin
				#0;
				
				$display("--> process_one_message");
				ret = m_ep.process_one_message();
				$display("<-- process_one_message");
				
				if (ret == -1) begin
					break;
				end else begin
					ret = 0;
				end
			end
		end while (ret == 0);
		
		if (ret != 1) begin
			$display("TbLink Error: failed to complete connect phase (%0d)", ret);
			$finish();
			return;
		end
		$display("<-- is_connect_complete");
		
		fork
			run();
		join_none
		$display("... leaving start()");
	endtask
	
	task run();
		IEndpoint::comm_state_e state = m_ep.comm_state();
		// TODO: Process messages (blocking) until the mode is changed
		// - Release
		// - Async
		//
		
		while (state == IEndpoint::Waiting || state == IEndpoint::Released) begin

			// Process messages while in Waiting state
			while (state == IEndpoint::Waiting) begin
				m_ep.process_one_message();
				// Allow a delta to expire in between to 
				// support loopback connections (specifically DPI<->VPI
				#0;
				
				state = m_ep.comm_state();
			end

			// Wait for events while in Released state
			while (state == IEndpoint::Released) begin
				// Wait for an event callback
				$display("--> m_ev_sem.wait");
				m_ev_sem.get(1);
				$display("<-- m_ev_sem.wait");
				
				// Allow a delta to expire in between to 
				// support loopback connections (specifically DPI<->VPI
				#0;
				
				state = m_ep.comm_state();
			end
		end
	endtask
	
	function void event_f(IEndpointEvent ev);
		$display("SVEndpointSequencer::event_f");
		m_ev_sem.put(1);
	endfunction

endclass

`else // VERILATOR
	
class SVEndpointSequencer extends IEndpointListener;
endclass

`endif

