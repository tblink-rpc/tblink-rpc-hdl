
/****************************************************************************
 * TbLinkDeltaCb.svh
 ****************************************************************************/

  
/**
 * Class: TbLinkDeltaCb
 * 
 * TODO: Add class documentation
 */
class TbLinkDeltaCb #(type T=int) extends TbLinkThread;
	T				m_target;

	function new(T target);
		m_target = target;
	endfunction
	
	virtual task run();
		#0;
		m_target.delta_cb();
	endtask

endclass


