.macro done
li $v0,10
syscall
.end_macro
.macro readint
li $v0,5
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
.macro readline(%i,%j,%k)
sll $v0,%k,2
lw %i,%j($v0)  
.end_macro
.data
matvalue:.space 1000
matrow:.space 1000
matcol:.space 1000
enter:.asciiz "\n"
space:.asciiz " "
.text
readint
move $s0,$v0    #s0=hang #s2=hangnow
readint
move $s1,$v0    #s1=lie  #s3=lienow
li $s2,1
li $s3,1
li $s4,0        #s4=count
loophang:
bgt $s2,$s0,loopend
looplie:
bgt $s3,$s1,looplieend
readint
bne $v0,$0,store
addi $s3,$s3,1
jal looplie
store:
sll $s5,$s4,2
sw $v0,matvalue($s5)
sw $s2,matrow($s5)
sw $s3,matcol($s5)
addi $s4,$s4,1
addi $s3,$s3,1
jal looplie
looplieend:
li $s3,1
addi $s2,$s2,1
jal loophang
loopend:
addi $s4,$s4,-1
loopprint:
bgt $0,$s4,end  
readline($a0,matrow,$s4)
printint($a0)
printstr(space)
readline($a0,matcol,$s4)
printint($a0)
printstr(space)
readline($a0,matvalue,$s4)
printint($a0)
printstr(enter)
addi $s4,$s4,-1
jal loopprint
end:
done