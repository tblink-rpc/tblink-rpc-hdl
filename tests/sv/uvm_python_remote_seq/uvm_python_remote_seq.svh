
/****************************************************************************
 * uvm_python_remote_seq.svh
 ****************************************************************************/

typedef class uvm_python_remote_seq;
  
/**
 * Class: uvm_python_remote_seq
 * 
 * TODO: Add class documentation
 */
class uvm_python_remote_seq extends TbLinkLaunchSeq #(
		uvm_python_seq_factory,
		uvm_python_seq_proxy #(uvm_python_remote_seq));
	`uvm_object_utils(uvm_python_remote_seq)
	
	typedef uvm_python_seq_proxy #(uvm_python_remote_seq) proxy_t;

	function void init(proxy_t proxy);
	endfunction

endclass


