RType: add $t0, $0, $0 # t0 = 0
nor $t1, $0,  $0        # t1 = -1
sub $t2, $0,  $t1       # t2 = 1
or  $t3, $t2, $t0       # t3 = 1
and $t4, $t3, $t1       # t4 = 000000...0001
sll $t5, $t2, 2         # t5 = 4
srl $t6, $t1, 4         # t6 = 000011...1111
sra $t7, $t1, 4         # t7 = 111111...1111
slt $s0, $t2, $0        # s0 = 0
xor $s1, $t2, $t2       # s1 = 0

JType: j JALType        # jump to JALType
nop

JALType: jal IType      # ra = PC + 4 and jumps to IType
nop

IType: andi $s2, $t1, 1 # s2 = 1
# ori .... the code given doesn't translate ori to the right hex instruction so we didn't test it
xori $s3, $0, 0         # s3 = 0
slti $s4, $t1, 0        # s4 = 1
addi $s5, $s4, 5        # s5 = 6
sw   $t2, 4($0)         # stores t2 value in the 1st registers after reg 0
lw   $s6, 4($0)         # loads value in the 1st registers after reg 0 into s6
beq  $s5, $s4, JRType   # if s5 == s4 then jumps to JRType
bne  $s5, $s4, JRType   # if s5 != s4 then jumps to JRType
nop
nop

JRType: jr $ra