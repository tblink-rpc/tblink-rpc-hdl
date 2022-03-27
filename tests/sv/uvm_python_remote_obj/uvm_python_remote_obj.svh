/****************************************************************************
 * uvm_python_remote_seq.svh
 ****************************************************************************/

/**
 * Class: uvm_python_remote_obj
 * 
 * Implements the SystemVerilog view of the remote object.
 * 
 * There are no method implementations here because all the 
 * calls go SV->Python in this example.
 * 
 * The base class (uvm_python_obj_null) is auto-generated.
 */
class uvm_python_remote_obj extends TbLinkLaunchUvmObj #(
		uvm_python_obj_proxy #(uvm_python_obj_null #(uvm_object))
		);
	`uvm_object_utils(uvm_python_remote_obj)
	
endclass


