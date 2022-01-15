
/****************************************************************************
 * DpiInterfaceType.svh
 ****************************************************************************/

  
/**
 * Class: DpiInterfaceType
 * 
 * TODO: Add class documentation
 */
class DpiInterfaceType extends IInterfaceType;
	chandle				m_hndl;

	function new(chandle hndl);
		m_hndl = hndl;
	endfunction

	virtual function IMethodType findMethod(string name);
		DpiMethodType ret;
		chandle method_h;

		$display("m_hndl: %0p", m_hndl);
		
		method_h = tblink_rpc_IInterfaceType_findMethod(
				m_hndl,
				name);
		
		if (method_h != null) begin
			ret = new(method_h);
		end
		
		return ret;
	endfunction

endclass

import "DPI-C" context function chandle tblink_rpc_IInterfaceType_findMethod(
	chandle iftype_h,
	string name);


