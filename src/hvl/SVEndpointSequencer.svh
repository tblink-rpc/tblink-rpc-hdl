/****************************************************************************
 * SVEndpointSequencer.svh
 ****************************************************************************/

  
/**
 * Class: SVEndpointSequencer
 * 
 * TODO: Add class documentation
 */
class SVEndpointSequencer;
	IEndpoint				m_ep;

	function new(IEndpoint ep);
		m_ep = ep;
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
		// TODO: Process messages (blocking) until the mode is changed
		// - Release
		// - Async
		//
		$display("--> await_run_until_event");
		repeat (100) begin
			$display("... delta");
			#0;
		end
		/*
		if (m_ep.await_run_until_event() == -1) begin
			$display("TbLink Error: failed while waiting for run-until-event");
			$finish(1);
		end
		 */
		$display("<-- await_run_until_event");				
	endtask

endclass


