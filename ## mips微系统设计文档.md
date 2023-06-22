## MIPS微系统设计文档
### 一、微系统接入乘除法器与外设驱动模块的方案
#### 关于乘除法器
将原乘除槽替换为了课下所提供的的乘除槽，将原busy信号接入in_ready接口，即若乘除法器准备好进行新的计算等价于其不处于运算阶段，将start信号接入in_valid来表示运算的开始，除此之外的接口与原乘除槽无差别。
#### 关于DM,IM和Clock
为了实现DM和IM的多周期访存，在学习了课下教程后，我尝试了其提供的短接流水线寄存器的方法，发现对我来说过于复杂，于是便选择了建立时钟IP核直接为DM和IM提供两倍于全局时钟的时钟频率，比较方便。
#### 关于uart
关于串口传输，我按照教程要求定义了4个寄存器，并将写入数据使能信号作为uart_tx模块的开始传输信号，将读取信号作为uart_rx的清零信号，由于我的CPU频率定在了20Mhz，于是在9600的波特率下得到除数因子为2083.
#### 关于digital_tube
为了使数码管能够正确显示，我定义了dt_translate函数来将输出数据转化为数码管的显示信号，另外，按照教程刷新显示的意思，两位寄存器sel用于控制第一组和第二组四位数码管的选择，当经过周期总数达到某个特定值时，sel加1，并且使sel对应的8位数码管被选择，而其他则保持无效，利用视觉暂留，便能实现在一组数码管只有一个digital_tube输出时刷新显示所有正确值。
#### Bridge和其他
其余的如led、switch模块则比较简单，只需定义相关寄存器存储值，并将其根据地址读取和输出即可，而Bridge模块正是实现各个模块在CPU读取和存储时接收到正确的使能信号和地址位数转换，使得CPU能够和外设通信。
### 二、汇编程序
#### 计算器
```
.text
dead_loop:

lw $s0, 0x7f60($0)
lw $s1, 0x7f64($0)
lw $t0, 0x7f68($0)
beq $t0, 2, ADD
nop
beq $t0, 4, SUB
nop
beq $t0, 8, MULT
nop
beq $t0, 16, DIV
nop
beq $t0, 32, AND
nop
beq $t0, 64, OR
nop
jal dead_loop
nop
ADD:
addu $s2, $s0, $s1
sb $s2, 0x7f50($0)
srl $s2,$s2,8
sb $s2,0x7f51($0)
srl $s2,$s2,8
sb $s2,0x7f52($0)
srl $s2,$s2,8
sb $s2,0x7f53($0)
j End
nop
SUB:
subu $s2, $s0, $s1
sb $s2, 0x7f50($0)
srl $s2,$s2,8
sb $s2,0x7f51($0)
srl $s2,$s2,8
sb $s2,0x7f52($0)
srl $s2,$s2,8
sb $s2,0x7f53($0)
j End
nop
MULT:
mult $s0, $s1
mflo $s2
sb $s2, 0x7f50($0)
srl $s2,$s2,8
sb $s2,0x7f51($0)
srl $s2,$s2,8
sb $s2,0x7f52($0)
srl $s2,$s2,8
sb $s2,0x7f53($0)
j End
nop
DIV:
div $s0, $s1
mflo $s2
sb $s2, 0x7f50($0)
srl $s2,$s2,8
sb $s2,0x7f51($0)
srl $s2,$s2,8
sb $s2,0x7f52($0)
srl $s2,$s2,8
sb $s2,0x7f53($0)
j End
nop
AND:
and $s2,$s0,$s1
sb $s2, 0x7f50($0)
srl $s2,$s2,8
sb $s2,0x7f51($0)
srl $s2,$s2,8
sb $s2,0x7f52($0)
srl $s2,$s2,8
sb $s2,0x7f53($0)
j End
nop
OR:
or $s2, $s0, $s1
sb $s2, 0x7f50($0)
srl $s2,$s2,8
sb $s2,0x7f51($0)
srl $s2,$s2,8
sb $s2,0x7f52($0)
srl $s2,$s2,8
sb $s2,0x7f53($0)
j End
nop

End:
j dead_loop
nop
```
### 计数器
```
.text
begin:
li $t7,20000001
sw $t7,0x7f04($0)
ori $t8,$0,1
lw $t2,0x7f60($0) #preset
lw $t1,0x7f68($0)
beq $t1,2,toPreset
nop
jal presetTo
nop
toPreset:
ori $t3,$0,0
loop1:
sw $t8,0x7f00($0)
lw $t4,0x7f60($0)
bne $t4,$t2,begin
nop
sw $t3,0x7f30($0)
sw $t3,0x7f70($0)
beq $t3,$t2,end
nop
loopcount1:
lw $s1,0x7f08($0)
beq $s1,$0,count1
nop
jal loopcount1
nop
count1:
addi $t3,$t3,1
jal loop1
nop
jal end
nop
presetTo:
or $t3,$0,$t2
loop2:
sw $t8,0x7f00($0)
lw $t4,0x7f60($0)
bne $t4,$t2,begin
nop
sw $t3,0x7f30($0)
sw $t3,0x7f70($0)
beq $t3,$0,end
nop
loopcount2:
lw $s1,0x7f08($0)
beq $s1,$0,count2
nop
jal loopcount2
nop
count2:
addi $t3,$t3,-1
jal loop2
nop
jal end
nop
end:
jal begin
nop
```
### uart回显
#### 主程序：
```
.text
# Turn On the Interrupt
ori $2, $0, 0x0401
mtc0 $2, $12

# Wait receiving data
Wait:
j Wait
nop
ori $s5,$0,0x1145
sw $s5,0x7f70($0)
or $2,$2,$t2
sb $2, 0x7f50($0)	# Display the character in the Digital Tube
srl $2,$2,8
sb $2,0x7f51($0)s
srl $2,$2,8
sb $2,0x7f52($0)
srl $2,$2,8
sb $2,0x7f53($0)

sw $t2,0x7f30($0)	# Re-Write to UART, Send out
j Wait
nop
```
#### 异常处理程序：
```

.ktext 0x4180		
# When receive completely, IntReq process in 0x4180
lw $t2, 0x7f30($0)	# Read Data From UART
ori $s5,$0,0x2333
sw $s5,0x7f70($0)
mfc0 $k0, $14		# EPC + 4, Jump out of the loop
addiu $k0, $k0, 4
mtc0 $k0, $14

eret
```
## 三、问题和解决
### 1、win10端 ise仿真在map阶段遇到无法读取license的错误。
解决：使用课程组提供的虚拟机ise。
### 2、ISE实现过慢，这几天都在debug和等ISE实现得到bit文件度过了&#x1F607;。
解决：无法解决。
### 3、计算器uart输出时卡死。
解决：主要原因在于CPU程序是循环的，在很短的时间内CPU会不断执行计算器功能，也即不断在uart中输出，在1s内在uart中输出的结果是大量的，而若用数码管输出则不会有这个问题。因此，应该增加程序设定当且仅当计算器的操作数或符号改变后在uart窗口中输出。
### 4、uart在ASCII模式下多个8位数不能连续输出在一行内，每个8位数占据一行，而在回显中则能位于一行内。
尚未解决。
### 5、仿真和调试
解决和建议：
1、即使使用了存储IP核，ISE是仍然能够提供仿真调试的，只需在tb和mips输入中给出两个频率成倍数的时钟信号，两倍频率信号接入IM和DM，正常频率信号则接入其他模块。
2、可以在mips汇编代码中加入对led灯的控制来在debug时通过led的亮灭情况来判断程序运行情况，毕竟FPGA平台并没有在线调试的功能，而led的控制只需一步写入，是最不容易出现bug的方法，相当于在运行时打断点。
3、针对digital_tube的调试，在仿真端的终点应是对应DT模块内的数据寄存器正确写入数据，另外可把数码管组的刷新率降至个位数（别忘了在实现时改回来&#x1F607;），在仿真时观察数码管选择信号sel的变化。
4、针对uart回显的调试，可先检查CPU的uart_Int中断路径是否正确，另外由于uart_count模块内count值要达到除数因子uart_rx才会输出uart_Int，而除数因子往往很大，在较短的仿真时间内不可能观察uart_Int的输出，因此可以手动更改uart_count模块内的除数因子大小至个位数，同样别忘了改回来（&#x1F607;），否则在实验时会出现类似乱码的错误。



