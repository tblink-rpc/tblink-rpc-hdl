
import cocotb
import tblink_rpc
from tblink_rpc import cocotb_compat


@cocotb.test()
async def entry(dut):
    print("Hello")

    print("--> init", flush=True)
    await cocotb_compat.init()
    print("<-- init", flush=True)
    pass