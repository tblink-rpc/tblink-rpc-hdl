
/****************************************************************************
 * IInterfaceImpl.svh
 ****************************************************************************/

  
/**
 * Class: IInterfaceImpl
 * 
 * TODO: Add class documentation
 */
class IInterfaceImpl;

	// This shouldn't be needed. However, there are some cases
	// where Verilator isn't able to determine the call scope
	// and needs to reach into the class hierarchy instead
	InvokeInfo m_ii;
		
	virtual function void invoke_nb(input InvokeInfo ii);
		$display("Error: invoke_nb not overridden");
		$finish();
	endfunction

	virtual task invoke_b(input InvokeInfo ii);
		$display("Error: invoke not overridden");
		$finish();
	endtask
	
endclass


