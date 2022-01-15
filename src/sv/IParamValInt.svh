
/****************************************************************************
 * IParamValInt.svh
 ****************************************************************************/

  
/**
 * Class: IParamValInt
 * 
 * TODO: Add class documentation
 */
class IParamValInt extends IParamVal;
	
	virtual function longint val_s();
		return -1;
	endfunction
	
	virtual function longint unsigned val_u();
		return 0;
	endfunction
		
endclass

