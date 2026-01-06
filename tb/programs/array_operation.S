# =========================================================
# RV32I Array Processing
# - Each element of array DATA is multiplied by 2 using a subroutine
# =========================================================
_start:
    la    x5, 0             # x5 = base address of array in data memory
    addi  x6, x0, 5         # x6 = array length
    addi  x7, x0, 0         # x7 = index

LOOP:
    slli  x8, x7, 2         # x8 = index*4 (PC)
    add   x9, x5, x8        # x9 = &DATA[index]
    lw    x10, 0(x9)        # x10 = DATA[index]

    # Call subroutine to double the element
    jal   x1, MULTIPLY_2_ELEMENT
    sw    x10, 0(x9)        # store processed element back
    addi  x7, x7, 1         # index++
    blt   x7, x6, LOOP      # continue loop if index < length

# -----------------------------
# OUTPUT to memory-mapped register
# -----------------------------

OUTPUT:
    li    x12, 0x10000000   # MMIO output address
    addi  x7, x0, 0         # index = 0

OUT_LOOP:
    slli  x8, x7, 2         # offset = index*4
    add   x9, x5, x8        # addr = base + offset
    lw    x10, 0(x9)        # load processed element
    sw    x10, 0(x12)       # write to MMIO
    addi  x7, x7, 1         # index++
    blt   x7, x6, OUT_LOOP  # repeat while index < length

END:
    j END                   # stop simulation here

# -----------------------------
# Subroutine: multiply by 2
# -----------------------------
MULTIPLY_2_ELEMENT:
    slli  x10, x10, 1      # multiply x10 by 2
    jalr  x0, x1, 0            # return to caller

# -----------------------------
# Data
# -----------------------------
    .data
DATA:
    .word 1, 2, 3, 4, 5
