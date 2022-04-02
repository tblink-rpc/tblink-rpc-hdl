/****************************************************************************
 * InterfaceInstFactory.svh
 ****************************************************************************/

typedef class IEndpoint;
  
/**
 * Class: InterfaceInstFactory
 * 
 * Factory for SystemVerilog interface-instance facades
 */
class InterfaceInstFactory #(type typeT, type implT);

	static function implT create(string name, IEndpoint ep=null);
		implT ret;
		
		if (ep == null) begin
			// Grab the default Endpoint
		end

	endfunction

endclass


