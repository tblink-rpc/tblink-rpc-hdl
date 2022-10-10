
import cocotb
import tblink_rpc
from tblink_rpc import cocotb_compat
import ctypes

@tblink_rpc.iftype("uvm_python_seq")
class UvmPythonSeq(object):
    
    def __init__(self):
        self.done_ev = cocotb.triggers.Event()
        pass
    
    @tblink_rpc.imptask
    async def body(self):
        print("--> body")
       
        print("--> Call doit(5)")
        await self.doit(5);
        print("<-- Call doit(5)")
        
        print("--> Call doit(6)")
        await self.doit(6);
        print("<-- Call doit(6)")

        # Notify that we're done        
        self.done_ev.set()
        print("<-- body")
        
    @tblink_rpc.exptask
    async def doit(self, a : ctypes.c_int32):
        pass

class MySeq(UvmPythonSeq):

    async def body(self):
        pass


@cocotb.test()
async def entry(dut):
    # TODO: pre-init to obtain arguments

    print("Hello: dut=%s" % str(dut))

    print("--> init", flush=True)
    await cocotb_compat.init()
    print("<-- init", flush=True)

    # Maybe need a different way to
    # replace the default implementation
    seq : UvmPythonSeq = None
    for ifc in cocotb_compat.ifinsts():
        print("ifc: %s" % str(ifc))
        seq = ifc
        
    print("--> wait done", flush=True)
    await seq.done_ev.wait()
    print("<-- wait done", flush=True)

