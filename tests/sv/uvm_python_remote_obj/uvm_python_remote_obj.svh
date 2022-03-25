
/****************************************************************************
 * uvm_python_remote_seq.svh
 ****************************************************************************/

typedef class uvm_python_remote_obj;
  
/**
 * Class: uvm_python_remote_obj
 * 
 * TODO: Add class documentation
 */
class uvm_python_remote_obj extends TbLinkLaunchUvmObj #(
		uvm_python_seq_proxy #(uvm_python_seq_null #(uvm_object))
		);
	`uvm_object_utils(uvm_python_remote_obj)
	
//	typedef uvm_python_seq_proxy #(uvm_python_remote_obj) proxy_t;
	
	task doit(int a);
		$display("[%0d] --> doit(%0d)", $time, a);
		#10;
		$display("[%0d] <-- doit(%0d)", $time, a);
	endtask

endclass


