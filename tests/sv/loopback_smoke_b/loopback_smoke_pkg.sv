/****************************************************************************
 * loopback_smoke_pkg.sv
 ****************************************************************************/
`include "uvm_macros.svh"
  
/**
 * Package: loopback_smoke_pkg
 * 
 * TODO: Add interface documentation
 */
package loopback_smoke_pkg;
	import uvm_pkg::*;
	import tblink_rpc::*;

	`include "loopback_smoke_bfm_impl.svh"
	`include "loopback_smoke_driver.svh"
	`include "loopback_smoke_test.svh"

endpackage


