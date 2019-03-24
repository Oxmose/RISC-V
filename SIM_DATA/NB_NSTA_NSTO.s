##
## NO Bypass, Stall nor Stomp logic
##
.text
#############################################################
# Check by hand, automatic tests NEED the following to work
#############################################################

# J
j beq_test
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop

# BEQ 
beq_test:
# 0x2C
beq x0, x0, test_bne 
nop
nop
j error
nop
nop

# BNE
test_bne:
# 0x44
bne x0, x0, error
nop
nop
j auto_tests
nop
nop

error:
# 0x5C
j error
nop
nop
nop
nop

success: 
# 0x70
j success
nop
nop
nop
nop

#############################################################
# Automatic tests
#############################################################
auto_tests:

############### ADDI 0x84
addi x1, x0, 5
addi x2, x0, 10
addi x3, x0, 20
nop
addi x1, x1, 10
addi x2, x2, 10
addi x3, x3, -5
nop
nop
nop
nop
# Check : 0xB0
bne x1, x3, error
nop
nop
bne x3, x1, error
nop
nop
beq x1, x2, error
nop
nop
beq x2, x3, error
nop
nop

############### REG RESET 0xE0
add x1, x0, x0 
add x3, x0, x0
add x2, x0, x0
nop
nop
nop
nop
nop 


############### END 0x100
nop
nop

j success
nop
nop