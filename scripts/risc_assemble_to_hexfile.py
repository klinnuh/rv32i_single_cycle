import argparse
import subprocess
import os
import sys

def run_cmd(cmd):
    print(f"[CMD] {' '.join(cmd)}")
    result = subprocess.run(cmd)
    if result.returncode != 0:
        print(f"ERROR: Command failed -> {' '.join(cmd)}")
        sys.exit(1)

def safe_delete(path):
    if os.path.exists(path):
        print(f"[CLEAN] Removing {path}")
        os.remove(path)

def main():
    parser = argparse.ArgumentParser(description="Compile RV32I assembly into hex file for Verilog.")
    parser.add_argument("asm_file", help="Input .S assembly file")
    args = parser.parse_args()

    asm_file = args.asm_file
    base = os.path.splitext(asm_file)[0]

    elf_file = base + ".elf"
    bin_file = base + ".bin"
    hex_file = base + ".hex"

    print("--------------------------------------------")
    print(f"Input file: {asm_file}")
    print(f"Output base name: {base}")
    print("--------------------------------------------")

    # --------------------------------------------
    # 1. Compile assembly -> ELF
    # --------------------------------------------
    run_cmd([
        "riscv64-unknown-elf-gcc",
        "-march=rv32i",
        "-mabi=ilp32",
        "-nostartfiles",
        "-Ttext=0x0",
        "-o", elf_file,
        asm_file
    ])

    # --------------------------------------------
    # 2. ELF -> binary
    # --------------------------------------------
    run_cmd([
        "riscv64-unknown-elf-objcopy",
        "-O", "binary",
        elf_file,
        bin_file
    ])

    # --------------------------------------------
    # 3. BIN -> HEX (32-bit aligned)
    # --------------------------------------------
    with open(hex_file, "w") as f:
        subprocess.run(
            ["xxd", "-p", "-c", "4", bin_file],
            stdout=f
        )

    # --------------------------------------------
    # 4. Cleanup intermediate files
    # --------------------------------------------
    safe_delete(elf_file)
    safe_delete(bin_file)
    
    print("--------------------------------------------")
    print("SUCCESS! Generated:")
    print(f"  {hex_file} (SystemVerilog-ready)")
    print("--------------------------------------------")


if __name__ == "__main__":
    main()
