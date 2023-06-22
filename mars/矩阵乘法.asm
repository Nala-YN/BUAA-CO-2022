.macro  readint
li $v0,5
syscall
.end_macro
.macro done
li $v0,10
syscall
.end_macro
.macro printint(%i)
move $a0,%i  
li $v0,1
syscall
.end_macro
.macro printstr(%i)
la $a0,%i
li $v0,4
syscall
.end_macro
.macro getvalue(%i,%j,%k)
addi $v1,%i,-1
mulu $v0,$v1,$s0
addu $v0,$v0,%j
move %k,$v0
.end_macro
.data
mat1:.space 1000
mat2:.space 1000
matans:.space 1000
space: .asciiz " "
enter:.asciiz "\n"
.text
readint
move $s0,$v0  #s0=n
mulu $t0,$s0,$s0
li $t1,1 #t1=i*i 
addi $t0,$t0,1
readmat1:
readint
sll $t2,$t1,2
sw $v0,mat1($t2)
addi $t1,$t1,1
beq $t1,$t0,endmat1
jal readmat1
endmat1:
li $t1,1
readmat2:
readint
sll $t2,$t1,2
sw $v0,mat2($t2)
addi $t1,$t1,1
beq $t1,$t0,endmat2
jal readmat2
endmat2:
li $t0,1
addi $s3,$s0,1 #s3=n+1
loopi:
li $t1,1
beq $t0,$s3,endi
loopj:
beq $t1,$s3,endj
li $s5,1 #s5=k
li $t9,0
loopk:
beq $s5,$s3,endk
getvalue($t0,$s5,$s6)
sll $s6,$s6,2
getvalue($s5,$t1,$s7)
sll $s7,$s7,2
lw $t5,mat1($s6)
lw $t6,mat2($s7)
mulu $t7,$t5,$t6
addu $t9,$t9,$t7
addi $s5,$s5,1
jal loopk
endk:
printint($t9)
printstr(space)
addi $t1,$t1,1
jal loopj
endj:
printstr(enter)
addi $t0,$t0,1
jal loopi
endi:
done
