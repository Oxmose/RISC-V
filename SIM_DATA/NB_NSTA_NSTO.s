##
## NO Bypass, Stall nor Stomp logic
##
.text
#############################################################
# Check by hand, automatic tests NEED the following to work
#############################################################

# J
j lui_test
nop
nop
nop
nop
nop
nop

#LUI 
lui_test:
lui x1, 0x00000FFF
lui x2, 0x000A0A0A
lui x3, 0x00000001
lui x4, 0x00012345

# BEQ 
beq_test:
beq x1, x0, error
nop 
nop
beq x0, x0, test_bne 
nop
nop
j error
nop
nop

# BNE
test_bne:
bne x0, x0, error
nop
nop
bne x1, x0, auto_tests
nop
nop

error:
j error
nop
nop
nop
nop

success: 
j success
nop
nop
nop
nop

#############################################################
# Automatic tests
#############################################################
auto_tests:

##########################################################################
#                                        IMMEDIATES
##########################################################################
############### ADDI
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

############### REG RESET
add x1, x0, x0 
add x3, x0, x0
add x2, x0, x0
nop
nop
nop
nop
nop 

############### SLTI
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

############### SLTIU
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

############### ANDI
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

############### ORI 
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

############### XORI
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


############### SLLI 
addi x1, x0, 0xFFFFFFFF
addi x2, x0, 0x0000070A
addi x3, x0, 0x00000001 
addi x4, x0, 0x00000111

slli x1, x1, 24
slli x2, x2, 5
slli x3, x3, 16
slli x4, x4, 31

lui x5, 0xFF000 
lui x6, 0xe 
lui x7, 0x10
lui x8, 0x00080000
nop
addi x6, x6, 0x140

bne x1, x5, error 
nop 
nop 
bne x2, x6, error 
nop 
nop 
bne x3, x7, error 
nop 
nop 
bne x4, x8, error 
nop 
nop 

############### SRLI
lui x1, 0x0000FF
lui x2, 0x70A
lui x3, 0x10000 
lui x4, 0x80000

srli x1, x1, 24
srli x2, x2, 15
srli x3, x3, 16
srli x4, x4, 31

addi x5, x0, 0xe1 
lui x6, 1 
addi x7, x0, 1

bne x1, x0, error 
nop 
nop 
bne x2, x5, error 
nop
nop 
bne x3, x6, error 
nop 
nop 
bne x4, x7, error 
nop 
nop 

############### SRAI
lui x1, 0x0000FF
lui x2, 0x70A
lui x3, 0xA0000 
lui x4, 0x80000

srai x1, x1, 24
srai x2, x2, 15
srai x3, x3, 16
srai x4, x4, 31

addi x5, x0, 0xe1 
lui x6, 0xFFFFA 
addi x7, x0, 0xFFFFFFFF

bne x1, x0, error 
nop 
nop 
bne x2, x5, error 
nop
nop 
bne x3, x6, error 
nop 
nop 
bne x4, x7, error 
nop 
nop 

############### AUIPC
########################## THIS SHOULD BE MODIFIED IF THE ADDRESS 
########################## OF THE CURRENT IMSTRUCTION IS NO LONGER 
########################## THE SAME

auipc x1, 0xA0A0A
lui x2, 0xA0A0A
nop
nop
nop
nop
addi x2, x2, 0x624
nop
nop
nop
nop
bne x1, x2, error
nop
nop

auipc x1, 0
addi x2, x0, 0x65C
nop
nop
nop
nop
bne x1, x2, error
nop
nop

##########################################################################
#                                        REGISTERS
##########################################################################
############### ADD
addi x1, x0, 5
addi x2, x0, 10
addi x3, x0, 20
addi x4, x0, -5
nop
nop
nop
nop
add x1, x1, x2
add x2, x2, x2
add x3, x3, x4
nop
nop
nop
nop

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

############### SUB
addi x1, x0, 5
addi x2, x0, 10
addi x3, x0, 20
addi x4, x0, -5
addi x5, x0, 5
addi x6, x0, -10
addi x7, x0, 25

sub x1, x2, x1 # 5
sub x2, x2, x3 # -10
sub x3, x3, x4 # 25
nop

bne x1, x5, error
nop
nop
bne x2, x6, error
nop
nop
bne x3, x7, error
nop
nop

############### REG RESET
add x1, x0, x0 
add x3, x0, x0
add x2, x0, x0
nop
nop
nop
nop
nop 

############### SLT
addi x6, x0, 50
addi x7, x0, 25
addi x8, x0, 10
addi x9, x0, -10
addi x10, x0, -25

addi x1, x0, 1
addi x2, x0, 25
addi x3, x0, -25

# <
slt x5, x2, x6
nop
nop
nop 
nop
bne x5, x1, error 
nop 
nop 

# =
slt x5, x2, x7
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# >
slt x5, x2, x8
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# >
slt x5, x2, x9
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# >
slt x5, x2, x10
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# NOW WITH NEGATIVE
addi x11, x0, -100

# <
slt x5, x3, x6
nop
nop
nop 
nop
bne x5, x1, error 
nop 
nop 

# <
slt x5, x3, x7
nop
nop
nop 
nop
bne x5, x1, error 
nop 
nop 

# <
slt x5, x3, x9
nop
nop
nop 
nop
bne x5, x1, error 
nop 
nop

# =
slt x5, x3, x10
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# >
slt x5, x3, x11
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

############### SLTU
addi x1, x0, 1
addi x2, x0, 25
addi x3, x0, -25

# <
sltu x5, x2, x6
nop
nop
nop 
nop
bne x5, x1, error 
nop 
nop 

# =
sltu x5, x2, x7
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# >
sltu x5, x2, x8
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# >
sltu x5, x2, x9
nop
nop
nop 
nop
bne x5, x1, error 
nop 
nop 

# >
sltu x5, x2, x10
nop
nop
nop 
nop
bne x5, x1, error 
nop 
nop 

# NOW WITH NEGATIVE

# <
sltu x5, x3, x6
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# <
sltu x5, x3, x7
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# <
sltu x5, x3, x9
nop
nop
nop 
nop
bne x5, x1, error 
nop 
nop

# =
sltu x5, x3, x10
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

# >
sltu x5, x3, x11
nop
nop
nop 
nop
bne x5, x0, error 
nop 
nop 

############### AND

lui x1, 0x6602
lui x11, 0x3d32
lui x21, 0x2402
lui x2, 0x1f049
lui x12, 0x24457
lui x22, 0x4041
lui x3, 0x5511
lui x13, 0x29b4f
lui x23, 0x1101
lui x4, 0x841a
lui x14, 0x1ac65
lui x24, 0x8400
lui x5, 0x2f6d
lui x15, 0x10ace
lui x25, 0xa4c
lui x6, 0x14551
lui x16, 0x1be8
lui x26, 0x140
lui x7, 0x25e5
lui x17, 0x3d2
lui x27, 0x1c0
lui x8, 0x630f
lui x18, 0x470
lui x28, 0x0
lui x9, 0x301b
lui x19, 0x20803
lui x29, 0x3
addi x1, x1, 0x266
addi x11, x11, 0x4ca
addi x21, x21, 0x42
addi x2, x2, 0x60c
addi x12, x12, 0x7e8
addi x22, x22, 0x608
addi x3, x3, 0x624
addi x13, x13, 0x165
addi x23, x23, 0x24
addi x4, x4, 0x7d8
addi x14, x14, 0x2d
addi x24, x24, 0x8
addi x5, x5, 0x5e0
addi x15, x15, 0x1aa
addi x25, x25, 0x1a0
addi x6, x6, 0x7e5
addi x16, x16, 0x1b6
addi x26, x26, 0x1a4
addi x7, x7, 0x160
addi x17, x17, 0x661
addi x27, x27, 0x60
addi x8, x8, 0x2a0
addi x18, x18, 0x5cd
addi x28, x28, 0x80
addi x9, x9, 0x498
addi x19, x19, 0x49e
addi x29, x29, 0x498
and x1, x1, x11
and x2, x2, x12
and x3, x3, x13
and x4, x4, x14
and x5, x5, x15
and x6, x6, x16
and x7, x7, x17
and x8, x8, x18
and x9, x9, x19
bne x1, x21, error
nop
nop
bne x2, x22, error
nop
nop
bne x3, x23, error
nop
nop
bne x4, x24, error
nop
nop
bne x5, x25, error
nop
nop
bne x6, x26, error
nop
nop
bne x7, x27, error
nop
nop
bne x8, x28, error
nop
nop
bne x9, x29, error
nop
nop

############### OR

lui x1, 0x2620
lui x11, 0x4e73
lui x21, 0x6e73
lui x2, 0xed0
lui x12, 0xa45a
lui x22, 0xaeda
lui x3, 0x15203
lui x13, 0x1b0f5
lui x23, 0x1f2f7
lui x4, 0xe222
lui x14, 0x6fe1
lui x24, 0xefe3
lui x5, 0xbed0
lui x15, 0x121eb
lui x25, 0x1bffb
lui x6, 0x14040
lui x16, 0x1f43a
lui x26, 0x1f47a
lui x7, 0x15f25
lui x17, 0xdf5a
lui x27, 0x1df7f
lui x8, 0x217cc
lui x18, 0x1a18c
lui x28, 0x3b7cc
lui x9, 0x20ca9
lui x19, 0x3e03
lui x29, 0x23eab
addi x1, x1, 0x3e0
addi x11, x11, 0x1f8
addi x21, x21, 0x3f8
addi x2, x2, 0x5a
addi x12, x12, 0x114
addi x22, x22, 0x15e
addi x3, x3, 0x2d4
addi x13, x13, 0xd9
addi x23, x23, 0x2dd
addi x4, x4, 0xc0
addi x14, x14, 0x7ff
addi x24, x24, 0x7ff
addi x5, x5, 0x115
addi x15, x15, 0x25a
addi x25, x25, 0x35f
addi x6, x6, 0x21d
addi x16, x16, 0x1e0
addi x26, x26, 0x3fd
addi x7, x7, 0x32
addi x17, x17, 0x6e9
addi x27, x27, 0x6fb
addi x8, x8, 0x18e
addi x18, x18, 0x186
addi x28, x28, 0x18e
addi x9, x9, 0x4e6
addi x19, x19, 0x253
addi x29, x29, 0x6f7
or x1, x1, x11
or x2, x2, x12
or x3, x3, x13
or x4, x4, x14
or x5, x5, x15
or x6, x6, x16
or x7, x7, x17
or x8, x8, x18
or x9, x9, x19
bne x1, x21, error
nop
nop
bne x2, x22, error
nop
nop
bne x3, x23, error
nop
nop
bne x4, x24, error
nop
nop
bne x5, x25, error
nop
nop
bne x6, x26, error
nop
nop
bne x7, x27, error
nop
nop
bne x8, x28, error
nop
nop
bne x9, x29, error
nop
nop

############### XOR
lui x1, 0x1a55e
lui x11, 0x3540
lui x21, 0x1901e
lui x2, 0x5f0
lui x12, 0x2f1a5
lui x22, 0x2f455
lui x3, 0xbe06
lui x13, 0x1afe
lui x23, 0xa4f8
lui x4, 0x5ecb
lui x14, 0x32e7
lui x24, 0x6c2c
lui x5, 0xdf94
lui x15, 0x1191e
lui x25, 0x1c68a
lui x6, 0x6496
lui x16, 0x31a7a
lui x26, 0x37eec
lui x7, 0x20a7c
lui x17, 0x4034
lui x27, 0x24a48
lui x8, 0x48ff
lui x18, 0x4304
lui x28, 0xbfb
lui x9, 0x1c30
lui x19, 0x1045f
lui x29, 0x1186f
addi x1, x1, 0x4b1
addi x11, x11, 0xc2
addi x21, x21, 0x473
addi x2, x2, 0xf2
addi x12, x12, 0x7ce
addi x22, x22, 0x73c
addi x3, x3, 0x740
addi x13, x13, 0x6ac
addi x23, x23, 0x1ec
addi x4, x4, 0x636
addi x14, x14, 0x8c
addi x24, x24, 0x6ba
addi x5, x5, 0x110
addi x15, x15, 0x556
addi x25, x25, 0x446
addi x6, x6, 0x5ac
addi x16, x16, 0x7fc
addi x26, x26, 0x250
addi x7, x7, 0x7c6
addi x17, x17, 0x748
addi x27, x27, 0x8e
addi x8, x8, 0x3ba
addi x18, x18, 0x434
addi x28, x28, 0x78e
addi x9, x9, 0x700
addi x19, x19, 0x31d
addi x29, x29, 0x41d
xor x1, x1, x11
xor x2, x2, x12
xor x3, x3, x13
xor x4, x4, x14
xor x5, x5, x15
xor x6, x6, x16
xor x7, x7, x17
xor x8, x8, x18
xor x9, x9, x19
bne x1, x21, error
nop
nop
bne x2, x22, error
nop
nop
bne x3, x23, error
nop
nop
bne x4, x24, error
nop
nop
bne x5, x25, error
nop
nop
bne x6, x26, error
nop
nop
bne x7, x27, error
nop
nop
bne x8, x28, error
nop
nop
bne x9, x29, error
nop
nop

############### SLL
addi x1, x0, 0xFFFFFFFF
addi x2, x0, 0x0000070A
addi x3, x0, 0x00000001 
addi x4, x0, 0x00000111

addi x5, x0, 24
addi x6, x0, 5
addi x7, x0, 16
addi x8, x0, 31

sll x1, x1, x5
sll x2, x2, x6
sll x3, x3, x7
sll x4, x4, x8

lui x9, 0xFF000 
lui x10, 0xe 
lui x11, 0x10
lui x12, 0x00080000
nop
addi x10, x10, 0x140

bne x1, x9, error 
nop 
nop 
bne x2, x10, error 
nop 
nop 
bne x3, x11, error 
nop 
nop 
bne x4, x12, error 
nop 
nop 

############### SRL
lui x1, 0x0000FF
lui x2, 0x70A
lui x3, 0x10000 
lui x4, 0x80000

addi x5, x0, 24
addi x6, x0, 15
addi x7, x0, 16
addi x8, x0, 31

srl x1, x1, x5
srl x2, x2, x6
srl x3, x3, x7
srl x4, x4, x8

addi x9, x0, 0xe1 
lui x10, 1 
addi x11, x0, 1

bne x1, x0, error 
nop 
nop 
bne x2, x9, error 
nop
nop 
bne x3, x10, error 
nop 
nop 
bne x4, x11, error 
nop 
nop 

############### SRA
lui x1, 0x0000FF
lui x2, 0x70A
lui x3, 0xA0000 
lui x4, 0x80000

addi x5, x0, 24
addi x6, x0, 15
addi x7, x0, 16
addi x8, x0, 31

sra x1, x1, x5
sra x2, x2, x6
sra x3, x3, x7
sra x4, x4, x8

addi x9, x0, 0xe1 
lui x10, 0xFFFFA 
addi x11, x0, 0xFFFFFFFF

bne x1, x0, error 
nop 
nop 
bne x2, x9, error 
nop
nop 
bne x3, x10, error 
nop 
nop 
bne x4, x11, error 
nop 
nop 
############### END
nop
nop

j success
nop
nop
