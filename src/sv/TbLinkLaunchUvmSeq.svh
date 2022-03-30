
/****************************************************************************
 * TbLinkLaunchUvmSeq.svh
 ****************************************************************************/

  
/**
 * Class: TbLinkLaunchUvmSeq
 * 
 * TODO: Add class documentation
 */
class TbLinkLaunchUvmSeq #(
		type Tp, // Proxy-class type
		type Tbase=Tp::ImplT) extends TbLinkLaunchUvmObj #(Tp, Tbase);

	function new(string name="TbLinkLaunchUvmSeq");
		super.new(name);
	endfunction
	
	task body();
		launch();
		super.body();
		shutdown();
	endtask


endclass


