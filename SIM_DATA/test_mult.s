.text
beq x0, x7, main
nop
nop
nop
nop
nop
jalr x7, x7, 0
nop
nop
nop
nop
nop
main:
    li x5, 0x0040
    li x1, 5
    li x2, 4
    li x3, 0
    li x6, 0
    li x10, 0xFFFFFFFF
    and x4, x0, x7
    xor x4, x4, x10
    nop

    sb x1, 0, x5
    sb x2, 1, x5

mult:
    beq x3, x1, endmult
    nop
    nop
    nop
    nop
    nop
    add x6, x6, x2
    addi x3, x3, 1
    nop
    nop
    nop
    nop
    nop
    j mult
endmult:
    nop
    nop 
    nop
    nop
    nop
    sw x6, 0 ,x0
    nop
    nop
    nop
    nop
    nop
    lw x3, 0, x0
    nop
    nop
    nop
    nop
    beq x0, x0, end
end:
    lw x7, 0, x5
    nop
    nop
    nop
    nop
    nop
    add x6, x7, x2
stop:
    nop
    jalr x7, x0, 0
    nop
    nop
    nop
    nop
    nop
    nop
end_test:
    j end_test
    nop
    nop
    nop
    nop
    nop