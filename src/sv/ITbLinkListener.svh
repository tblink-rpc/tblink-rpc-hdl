
/****************************************************************************
 * ITbLinkListener.svh
 ****************************************************************************/

  
/**
 * Class: ITbLinkListener
 * 
 * TODO: Add class documentation
 */
class ITbLinkListener;

	virtual function void notify(ITbLinkEvent ev);
		$display("TbLink Error: ITbLinkListener::notify not implemented");
		$finish(1);
	endfunction


endclass


