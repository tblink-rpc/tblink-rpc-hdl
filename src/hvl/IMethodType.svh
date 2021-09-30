
/****************************************************************************
 * IMethodType.svh
 ****************************************************************************/

  
/**
 * Class: IMethodType
 * 
 * TODO: Add class documentation
 */
class IMethodType;
	chandle			m_hndl;
		
	function string name();
		return tblink_rpc_IMethodType_name(m_hndl);
	endfunction
		
	function longint id();
		return tblink_rpc_IMethodType_id(m_hndl);
	endfunction
endclass


