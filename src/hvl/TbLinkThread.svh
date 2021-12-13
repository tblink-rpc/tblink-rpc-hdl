/****************************************************************************
 * TblinkThread.svh
 ****************************************************************************/

typedef class TbLinkThread;

/**
 * TbLinkThread
 * 
 * Base class for dynamically-created tblink-rpc threads
 */
class TbLinkThread;
	TbLinkThread		m_next;
	
	function new();
	endfunction
	
	function TbLinkThread next();
		return m_next;
	endfunction
	
	function void set_next(TbLinkThread t);
		m_next = t;
	endfunction
	
	virtual task run();
		$display("Error: base run method invoked");
		$finish();
	endtask
endclass

`ifdef UNDEFINED
mailbox #(TbLinkThread)		prv_dispatch_q = new();
bit prv_dispatcher_running = 0;

task _tblink_dispatcher();
	TbLinkThread t;
		
	forever begin
		prv_dispatch_q.get(t);
		t.run();
	end
endtask
	
function void _tblink_start_dispatcher();
	if (prv_dispatcher_running == 0) begin
		prv_dispatcher_running = 1;
		fork
			_tblink_dispatcher();
		join_none
	end
endfunction
`endif
