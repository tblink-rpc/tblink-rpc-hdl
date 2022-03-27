import tblink_rpc
import ctypes

@tblink_rpc.iftype("uvm_python_obj")
class UvmPythonObj(object):
    
    @tblink_rpc.impfunc
    def add(self, a : ctypes.c_uint32, b : ctypes.c_uint32) -> ctypes.c_uint32:
        print("UvmPythonSeq.add: a=%d b=%d" % (a, b), flush=True)
        return a+b
        

