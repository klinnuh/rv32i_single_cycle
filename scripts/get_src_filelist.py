# Auto generate and list sv files to sourcecode.list

import os
from pathlib import PurePosixPath

RTL_DIR = "../rtl"
TB_DIR = "../tb"

design_files = [f for f in os.listdir(RTL_DIR) if f.endswith((".sv"))]
# tb_files = [f for f in os.listdir(TB_DIR) if f.endswith((".sv", ".svh"))]

f_file_path = "../scripts/sourcecode.list"

with open(f_file_path, "w") as f:
    # Write design files
    f.write("\n# Design\n")
    f.write("..rtl/dut_pkg.sv\n")
    for file in design_files:
        f.write(str(PurePosixPath(RTL_DIR, file)) + "\n")
    
    f.write("\n# TB\n")
    
    # Write tb files
    # for file in tb_files:
    #     f.write(str(PurePosixPath(TB_DIR, file)) + "\n")
    
    f.write(f"../tb/tb_pkg.sv\n../tb/top.sv")
        
print(f"Files Generated")
