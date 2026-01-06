# =============================================================
# RV32I DEPENDENT INSTRUCTION CHAIN TEST
# Final expected value: 0xDEADBEEF
# =============================================================
_start:
    addi x1, x0, 1          # x1 = 1   (start dependency chain)

# -------------------------
# Basic ALU
# -------------------------
    add  x2, x1, x1         # x2 = 2
    sub  x3, x2, x1         # x3 = 1
    xor  x4, x3, x1         # x4 = 1 ^ 1 = 0
    or   x5, x4, x3         # x5 = 0 | 1 = 1
    and  x6, x5, x2         # x6 = 1 & 2 = 0

# -------------------------
# Shifts
# -------------------------
    addi x6, x6, 8          # x6 = 8
    sll  x7, x6, x1         # x7 = 8 << 1 = 16
    srl  x8, x7, x1         # x8 = 16 >> 1 = 8
    sra  x9, x8, x1         # x9 = 8 >> 1 = 4 (arith same for positive)

# Signed shifts
    addi x10, x9, -16       # x10 = 4 - 16 = -12
    sra  x11, x10, x1       # x11 = -12 >> 1 = -6

# -------------------------
# SLT
# -------------------------
    slt  x12, x11, x9       # x12 = (-6 < 4)?1:0 = 1
    sltu x13, x12, x11      # x13 = (1 < -6 unsigned)?0:1 = 1 (0x1FFF...?)

# -------------------------
# Immediate ALU
# -------------------------
    addi x14, x13, 5        # x14 = 1 + 5 = 6
    xori x15, x14, 0xAA     # x15 = 6 ^ 0xAA = 0xA4
    ori  x16, x15, 0x0F     # x16 = 0xA4 | 0x0F = 0xAF
    andi x17, x16, 0x3F     # x17 = 0xAF & 0x3F = 0x2F
    slli x18, x17, 1        # x18 = 0x2F << 1 = 0x5E
    srli x19, x18, 1        # x19 = 0x2F
    srai x20, x19, 1        # x20 = 0x17

# -------------------------
# LUI / AUIPC
# -------------------------
    lui  x21, 0xDEADB       # x21 = 0xDEADB000
    auipc x22, 0x00001      # x22 = PC + 0x1000
    add  x23, x21, x22      # x23 = combine upper immediate + PC

# -------------------------
# Memory load/store
# -------------------------
    addi x24, x0, 2000
    addi x25, x24, 1823

    sw   x25, 0(x20)        # MEM = x25
    lw   x26, 0(x20)        # x26 = MEM

    lb   x27, 0(x20)
    lh   x28, 0(x20)
    lbu  x29, 0(x20)
    lhu  x30, 0(x20)  

# -------------------------
# Branches (dependent)
# -------------------------
    beq  x30, x30, L1       # not taken
    addi x30, x30, 1        # dependency

L1:
    bne  x30, x0, L2        # not taken
    addi x30, x30, 1        # dependency

L2:
    bltu  x29, x30, L3      # not taken
    addi x30, x30, 1        # dependency

L3:
    bge  x29, x29, L4       # not taken
    addi x30, x30, 1

L4:
# -------------------------
# Jumps
# -------------------------
    jal  x5, JUMP1          # x5 = RA, jump to JUMP1
    addi x30, x30, 999      # skipped

JUMP1:
    add x31, x21, x30       # combine upper immediate and chain value

# -------------------------
# FINAL EXPECTED VALUE = 0xDEADBEEF
# -------------------------
    // Memory mapped output
    li  x5, 0x10000000
    sw  x31, 0(x5)

END:
    j END
