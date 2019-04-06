addi x1, x0, 0
addi x2, x0, 0
addi x3, x0, 0
j next_inst
addi x1, x1, 1
next_inst:
addi x3, x3, 1
j next_inst
j end
addi x2, x2, 1
end:
nop 
nop
j end
nop 
nop