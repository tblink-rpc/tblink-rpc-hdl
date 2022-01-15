import argparse
import os

def cmd_sim_plugin(args):
    import tblink_rpc_hdl.tblink_rpc_hdl_stub
    libdir = os.path.dirname(tblink_rpc_hdl.tblink_rpc_hdl_stub.__file__)
    if args.type == "dpi":
        print("%s" % os.path.join(libdir, "libtblink_rpc_hdl_dpi.so"))
    elif args.type == "vpi":
        print("%s" % os.path.join(libdir, "libtblink_rpc_hdl_vpi.so"))
    else:
        print("unsupported-plugin-%s" % args.type)

def cmd_files(args):
    pkg_dir = os.path.dirname(os.path.abspath(__file__))
    
    if os.path.isdir(os.path.join(pkg_dir, "share")):
        share_dir = os.path.join(pkg_dir, "share")
    else:
        tblink_rpc_hdl_dir = os.path.dirname(os.path.dirname(pkg_dir))
        share_dir = os.path.join(tblink_rpc_hdl_dir, "src")
    
    hvl_dir = os.path.join(share_dir, "sv")
   
    if args.target == "sv":
        files = ["tblink_rpc.sv"]
    elif args.target == "sv-uvm":
        files = ["tblink_rpc.sv", "tblink_rpc_uvm.sv"]
    else:
        raise Exception("internal error: target=%s" % args.target)
    
    print("%s" % " ".join(map(lambda p : os.path.join(hvl_dir, p), files)))


def get_parser():
    parser = argparse.ArgumentParser()
    
    subparser = parser.add_subparsers()
    subparser.required = True
    subparser.dest = "command"
    
    sim_plugin_cmd = subparser.add_parser("simplugin",
        help="Retrieve path to simulator plugin")
    sim_plugin_cmd.add_argument("type", choices={'dpi','vpi'},
        help="Selects which simulation plug-in to report")
    sim_plugin_cmd.set_defaults(func=cmd_sim_plugin)

    files_cmd = subparser.add_parser("files",
        help="Retrieves files that must be compiled" 
        )
    files_cmd.set_defaults(func=cmd_files)
    files_cmd.add_argument("target",
        help="Specifies target language",
        choices={"sv", "sv-uvm"})
        
    return parser

def main():
    
    parser = get_parser()

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
