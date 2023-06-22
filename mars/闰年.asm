.data

.text
li $v0,5
syscall
move $t0,$v0
li $v0,4
div $t0,$v0
mfhi $t1
beq $t1,$0,yes0
jal no
yes0:
li $v0,100
div $t0,$v0
mfhi $t1
beq $t1,$0,is100
jal yes
is100:
li $v0,400
div $t0,$v0
mfhi $t1
beq $t1,$0,yes
jal no
no:
li $a0,0
jal end
yes:
li $a0,1
jal end
end:
li $v0,1
syscall
li $v0,10
syscall
