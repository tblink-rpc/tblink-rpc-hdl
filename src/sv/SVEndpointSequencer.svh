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
		int cnt;
		int iter_limit = 20;
	
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

		cnt = 0;
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
			
			cnt += 1;
			
		end while (ret == 0 && cnt <= iter_limit);
		
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

		cnt = 0;
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
			
			cnt += 1;
		end while (ret == 0 && cnt <= iter_limit);
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

		cnt = 0;
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
			
			cnt += 1;
			
		end while (ret == 0 && cnt <= iter_limit);
		
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
		int ret;
		IEndpoint::comm_state_e state = m_ep.comm_state();
		// TODO: Process messages (blocking) until the mode is changed
		// - Release
		// - Async
		//
		
		while (state == IEndpoint::Waiting || state == IEndpoint::Released) begin

			// Process messages while in Waiting state
			$display("--> Sequencer::Waiting");
			while (state == IEndpoint::Waiting) begin
				$display("--> process_one_message");
				ret = m_ep.process_one_message();
				$display("<-- process_one_message");
				// Allow a delta to expire in between to 
				// support loopback connections (specifically DPI<->VPI)
				
				if (ret == -1) begin
					$display("TbLink Error: peer endpoint disconnected");
					$finish();
					return;
				end
				
				$display("--> delta");
				#0;
				$display("<-- delta");
				
				state = m_ep.comm_state();
			end
			$display("<-- Sequencer::Waiting");

			// Wait for events while in Released state
			$display("--> Sequencer::Released");
			while (state == IEndpoint::Released) begin
				// Wait for an event callback
				$display("--> m_ev_sem.wait");
				m_ev_sem.get(1);
				$display("<-- m_ev_sem.wait");
				
				// Allow a delta to expire in between to 
				// support loopback connections (specifically DPI<->VPI)
				#0;
				
				state = m_ep.comm_state();
			end
			$display("<-- Sequencer::Released");
		end
	endtask
	
	function void event_f(IEndpointEvent ev);
		$display("SVEndpointSequencer::event_f");
		m_ev_sem.put(1);
	endfunction

endclass

function automatic SVEndpointSequencer mkSVEndpointSequencer(IEndpoint ep);
	SVEndpointSequencer seqr = new(ep);
	return seqr;
endfunction

`else // VERILATOR
	
typedef class SVEndpointSequencer;
typedef class TbLink;

class SVEndpointSequencerThread extends TbLinkThread;
	
	SVEndpointSequencer			m_seqr;
	
	function new(SVEndpointSequencer seqr);
		m_seqr = seqr;
	endfunction
	
	virtual task run();
		m_seqr.run();
	endtask
	
endclass

class SVEndpointSequencer extends IEndpointListener;
	
	typedef enum {
		WaitBfmRegistration,
		WaitBuildComplete,
		WaitConnectComplete,
		ProcessMessages,
		Terminated
	} seqr_state_e;

	IEndpoint						m_ep;
	seqr_state_e					m_state;
	SVEndpointSequencerThread		m_thread;
	bit								m_thread_queued;
	TbLink							m_tblink;
	int								m_last_ifinst_count;
	int								m_it_count;
	
	function new(IEndpoint ep);
		m_ep = ep;
		m_state = WaitBfmRegistration;
		m_tblink = TbLink::inst();
	endfunction
	
	function void init(SVEndpointSequencerThread t);
		m_thread = t;
	endfunction
	
	task start();
		$display("SVEndpointSequencer::start");
		if (!m_thread_queued) begin
			m_thread_queued = 1;
			m_tblink.queue_thread(m_thread);
		end
	endtask
	
	virtual function void event_f(IEndpointEvent ev);
		$display("SVEndpointSequencer: event_f");
		if (!m_thread_queued) begin
			m_thread_queued = 1;
			m_tblink.queue_thread(m_thread);
		end
	endfunction
	
	task run();
		$display("SVEndpointSequencer::run");
		m_thread_queued = 0;
		case (m_state)
			WaitBfmRegistration: begin
				IInterfaceInst ifinsts[$];
				m_ep.getInterfaceInsts(ifinsts);
		
				$display("ifinst_count: %0d ifinsts.size: %0d", m_last_ifinst_count, ifinsts.size());
				if (m_last_ifinst_count > 0 && m_last_ifinst_count == ifinsts.size()) begin
					$display("Moving to BuildComplete");
					m_state = WaitBuildComplete;
					if (m_ep.build_complete() == -1) begin
						$display("TbLink Error: Build-complete failed");
						$finish();
						m_state = Terminated;
					end
				end else begin
					m_it_count++;
					if (ifinsts.size() == 0 && m_it_count >= 16) begin
						m_state = Terminated;
						$display("TbLink Error: Failed to find any BFM instances");
						$finish();
					end
				end
				m_thread_queued = 1;
				m_tblink.queue_thread(m_thread);
				m_last_ifinst_count = ifinsts.size();
			end
			WaitBuildComplete: begin
				int ret = m_ep.is_build_complete();
				$display("WaitBuildComplete: %0d", ret);
				if (ret == 1) begin
					m_state = WaitConnectComplete;
					if (m_ep.connect_complete() == -1) begin
						m_state = Terminated;
						$display("TbLink Error: Connect-complete failed");
						$finish();
					end
					m_thread_queued = 1;
					m_tblink.queue_thread(m_thread);
				end else if (ret == -1) begin
					m_state = Terminated;
					$display("TbLink Error: Is-Build-Complete failed");
					$finish();
				end
			end
			WaitConnectComplete: begin
				int ret = m_ep.is_connect_complete();
				$display("WaitConnectComplete");
				if (ret == 1) begin
					m_state = ProcessMessages;
					m_thread_queued = 1;
					m_tblink.queue_thread(m_thread);
				end else if (ret == -1) begin
					m_state = Terminated;
					$display("TbLink Error: Is-Connect-Complete failed");
					$finish();
				end
			end
			ProcessMessages: begin
				// Park for now
			end
			Terminated: begin
				// Park
			end
			default: begin
				$display("TbLink Error: unhandled sequencer state");
				$finish();
			end
		endcase
	endtask
	
	
endclass


function automatic SVEndpointSequencer mkSVEndpointSequencer(IEndpoint ep);
	SVEndpointSequencer seqr = new(ep);
	SVEndpointSequencerThread thread = new(seqr);
	seqr.init(thread);
	ep.addListener(seqr);
	return seqr;
endfunction

`endif

