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

############### SLTI 0x100
addi x1, x0, 1
addi x2, x0, 25
addi x3, x0, -25

# <
slti x5, x2, 50
nop
nop
nop 
nop
bne x5, x1, error 
nop 
nop 

# =
slti x5, x2, 25
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# >
slti x5, x2, 10
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# >
slti x5, x2, -10
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# >
slti x5, x2, -25
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# NOW WITH NEGATIVE

# <
slti x5, x3, 50
nop
nop
nop 
nop
bne x5, x1, error 
nop 
nop 

# <
slti x5, x3, 25
nop
nop
nop 
nop
bne x5, x1, error 
nop 
nop 

# <
slti x5, x3, -10
nop
nop
nop 
nop
bne x5, x1, error 
nop 
nop

# =
slti x5, x3, -25
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# >
slti x5, x3, -100
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

############### SLTIU 0x250
addi x1, x0, 1
addi x2, x0, 25
addi x3, x0, -25

# <
sltiu x5, x2, 50
nop
nop
nop 
nop
bne x5, x1, error 
nop 
nop 

# =
sltiu x5, x2, 25
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# >
sltiu x5, x2, 10
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# >
sltiu x5, x2, -10
nop
nop
nop 
nop
bne x5, x1, error 
nop 
nop 

# >
sltiu x5, x2, -25
nop
nop
nop 
nop
bne x5, x1, error 
nop 
nop 

# NOW WITH NEGATIVE

# <
sltiu x5, x3, 50
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# <
sltiu x5, x3, 25
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# <
sltiu x5, x3, -10
nop
nop
nop 
nop
bne x5, x1, error 
nop 
nop

# =
sltiu x5, x3, -25
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# >
sltiu x5, x3, -100
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

############### ANDI 0x398
addi x1, x0, 0xFFFFFFFF
addi x2, x0, 0x000002A2
nop 
nop 
andi x3, x1, 0x000003D1
andi x4, x2, 0x00000122
andi x5, x1, 0x00000000
andi x6, x2, 0xFFFFFFFF 
andi x7, x1, 0x00000232
andi x8, x2, 0xFFFFFAA0

addi x9, x0, 0x000003D1
addi x10, x0, 0x00000022
addi x11, x0, 0x00000232 
addi x12, x0, 0x000002A0
 
bne x3, x9, error 
nop
nop 
bne x4, x10, error 
nop 
nop 
bne x5, x0, error 
nop 
nop 
bne x6, x2, error 
nop 
nop 
bne x7, x11, error 
nop 
nop 
bne x8, x12, error 
nop 
nop

############### ORI 0x41C
addi x1, x0, 0xFFFFFFFF
addi x2, x0, 0x000002A2
nop 
nop 
ori x3, x1, 0x000003D1
ori x4, x2, 0x00000421
ori x5, x1, 0x00000000
ori x6, x2, 0xFFFFFFFF 
ori x7, x1, 0x00000232
ori x8, x2, 0xFFFFFAA0

addi x9, x0, 0x000003D1
addi x10, x0, 0x000006A3
addi x11, x0, 0x00000232 
addi x12, x0, 0xFFFFFAA2
 
bne x3, x1, error 
nop
nop 
bne x4, x10, error 
nop 
nop 
bne x5, x1, error 
nop 
nop 
bne x6, x1, error 
nop 
nop 
bne x7, x1, error 
nop 
nop 
bne x8, x12, error 
nop 
nop

############### XORI 0x498
addi x1, x0, 0x00000456
addi x2, x0, 0x00000762
nop 
nop 
xori x3, x1, 0x000006a1
xori x4, x2, 0x00000421
xori x5, x1, 0x000003ed
xori x6, x2, 0x0000003c 

addi x9, x0, 0x000002f7
addi x10, x0, 0x00000343
addi x11, x0, 0x000007bb 
addi x12, x0, 0x0000075e
 
bne x3, x9, error 
nop
nop 
bne x4, x10, error 
nop 
nop 
bne x5, x11, error 
nop 
nop 
bne x6, x12, error 
nop 
nop


############### END 0x4FC
nop
nop

j success
nop
nop
