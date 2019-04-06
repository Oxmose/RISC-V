auipc x1, 0xA0A0A
lui x2, 0xA0A0A
addi x2, x2, 0x0 
bne x1, x2, error
nop
nop

auipc x1, 0
addi x2, x0, 0x4AC
bne x1, x2, error
nop
nop

succ:
j succ
nop 
nop 

error:
j error
nop 
nop
nop