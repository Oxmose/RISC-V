addi x1, x0, 20
addi x1, x1, 35
addi x2, x0, 55
bne x1, x2, error
nop
nop

addi x2, x0, 16
addi x1, x0, 10
nop
addi x1, x1, 6
nop
bne x1, x2, error
nop 
nop 

addi x2, x0, 20
addi x1, x0, 17
nop
nop
addi x1, x1, 3
nop
nop
bne x1, x2, error
nop 
nop 

success:
j success
nop 
nop
nop
nop
error:
j error
nop 
nop