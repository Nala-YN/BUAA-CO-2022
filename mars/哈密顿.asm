.data
graph:.space 264
book:.space 40
.macro getmit(%i,%j)
mul $v0,%i,$s6
add $v0,$v0,%j
.end_macro
.text
#$s6:n #$s5:m #$s4:ans
li $v0,5
syscall
move $s6,$v0
li $v0,5
syscall
move $s5,$v0
#t0=i t1=x t2=y
li $t0,0
loop:
bge $t0,$s5,endloop
li $v0,5
syscall
subi $v0,$v0,1
move $t1,$v0
li $v0,5
syscall
subi $v0,$v0,1
move $t2,$v0
getmit($t1,$t2)
li $t3,1
sll $v0,$v0,2
sw $t3,graph($v0)
getmit($t2,$t1)
sll $v0,$v0,2
sw $t3,graph($v0)
addi $t0,$t0,1
jal loop
endloop:
li $a0,0
jal dfs
move $a0,$s4
li $v0,1
syscall
li $v0,10
syscall




dfs:
   subi $sp,$sp,12
   sw $ra,0($sp)
   sw $a0,8($sp)
   sw $s1,4($sp)
   move $a0,$s1
   sll $v0,$a0,2
   li $v1,1
   sw $v1,book($v0)
   #s0=flag #s1=i
   li $s0,1
   li $s1,0
   loopflag:
   bge $s1,$s6,endloopflag
   sll $v0,$s1,2
   lw $v1,book($v0)
   and $s0,$s0,$v1
   addi $s1,$s1,1
   jal loopflag
   endloopflag:
   seq $v1,$s0,1 
   getmit($a0,$0)
   sll $v0,$v0,2
   lw $v0,graph($v0)
   seq $v0,$v0,1
   and $v0,$v0,$v1
   beq $v0,1,true
   li $s1,0
   loopsearch:
   bge $s1,$s6,loopsearchend
   getmit($a0,$s1)
   sll $v0,$v0,2
   lw $v1 graph($v0)
   sll $v0,$s1,2
   lw $v0,book($v0)
   xor $v0,1
   and $v0,$v0,$v1
   beq $v0,1,dfs
   addi $s1,$s1,1
   jal loopsearch
   addi $s1,$s1,1
   jal loopsearch
   loopsearchend:
   sll $v0,$a0,2
   sw $0,book($v0)
   preret:
   lw $a0,8($sp)
   lw $s1,4($sp)
   lw $ra,0($sp)
   addi $sp,$sp,12
   jr $ra
   true:
   li $s4,1
   jal preret
   
   
