/****************************************************************************
 * ITypeMap.svh
 ****************************************************************************/

  
/**
 * Class: ITypeMap
 * 
 * TODO: Add class documentation
 */
class ITypeMap extends IType;

	virtual function IType key_t();
		return null;
	endfunction
	
	virtual function IType elem_t();
		return null;
	endfunction

endclass


