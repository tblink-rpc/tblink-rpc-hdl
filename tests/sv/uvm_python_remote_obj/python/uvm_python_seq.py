import tblink_rpc
from tblink_rpc import cocotb_compat
import cocotb
import ctypes

@tblink_rpc.iftype("uvm_python_seq")
class UvmPythonSeq(object):
    
    def __init__(self):
        self.done_ev = cocotb.triggers.Event()
        self._loop_running = False
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
        
    async def loop(self):
        while True:
            print("--> Loop", flush=True)
            await cocotb.triggers.Timer(1, 'us')
            print("<-- Loop", flush=True)
        
    @tblink_rpc.impfunc
    def add(self, a : ctypes.c_uint32, b : ctypes.c_uint32) -> ctypes.c_uint32:
        if not self._loop_running:
            self._loop_running = True
            cocotb.fork(self.loop())
        print("UvmPythonSeq.add: a=%d b=%d" % (a, b), flush=True)
        return a+b
        
    @tblink_rpc.exptask
    async def doit(self, a : ctypes.c_int32):
        pass
    