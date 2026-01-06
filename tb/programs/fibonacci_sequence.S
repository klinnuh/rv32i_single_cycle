# =============================================================
# RV32I FIBONACCI SEQUENCE TEST
# Final expected value: 0d55 / 0x37
# =============================================================
_start:
    li x1, 0          # a
    li x2, 1          # b
    li x3, 10         # N = 10, change this to desired Nth term to output

fib_loop:
    beq x3, x0, done  # if N == 0, exit loop

    add x4, x1, x2    # c = a + b
    mv  x1, x2        # a = b
    mv  x2, x4        # b = c
    addi x3, x3, -1   # N--

    beq x0, x0, fib_loop

# -----------------------------------
# Expected output F(10) = 'd55
# -----------------------------------
done:
    # Write result to memory-mapped output
    li  x5, 0x10000000
    sw  x1, 0(x5)

inf_loop:
    beq x0, x0, inf_loop  # infinite loop
