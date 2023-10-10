.global main	@定义全局标签 main，表示程序的入口点。

.section .data	@数据段，定义MAX_COUNT及format标签
MAX_COUNT:
    .word 10
format:
    .asciz "Total Sum of the first %d numbers is: %d\n"

.section .bss	@.bss段定义两个四字节空间的变量，分别存储计数器的值和计算结果
counter:
    .space 4
result:
    .space 4

.text
main:	@main是程序入口点，初始化counter（计数器）和result（结果）变量
@将计数器counter初始值设置为1
    ldr r0, =counter @将 counter 变量的地址加载到 r0 寄存器中
    mov r1, #1	@将值1存储在 r1 寄存器中，表示计数器的初始值。
    str r1, [r0] @将 r1 寄存器中的值存储到 counter 变量的地址
@将结果result初始值设置为0
    mov r0, #0 @将值0存储在 r0 寄存器中，表示结果的初始值
    ldr r4, =result  @ 将 result 变量的地址加载到 r4 寄存器中
    str r0, [r4]     @ 将r0寄存器中的值存储到r4寄存器中指定的地址
    @str r0, [result]

loop_start: @循环开始，程序将在这里进入循环来计算总和。\

    @ 将 counter 变量的值加载到 r1 寄存器中，以便程序可以在寄存器中操作该值。
    ldr r0, =counter @将counter变量地址加载到r0
    ldr r1, [r0]	@将 counter 变量的值加载到了 r1 寄存器中，以便后续可以使用 r1 寄存器中的值进行操作。

    @ 比较计数器和MAX_COUNT（循环结束条件判断）
    ldr r2, =MAX_COUNT
    ldr r2, [r2]	@加载 MAX_COUNT 的值到 r2 寄存器中
    cmp r1, r2
    bgt loop_end	@如果 r1 大于 r2，则跳转到 loop_end，结束循环。

    @ 调用calculateSum函数
    bl calculateSum

    @ 将返回值添加到结果中
    @ 将计数器的值加到结果中
    ldr r4, =result  @ 将result标签的地址加载到r4寄存器中
    ldr r2, [r4]
	add r2, r2, r0
	str r2, [r4]
    @ 增加计数器
    ldr r0, =counter
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]

    @ 比较计数器和MAX_COUNT
    cmp r1, r3
    ble loop_start
    @ 继续循环
    @b loop_start

loop_end:
    @ 准备参数并调用printf函数来打印结果
    ldr r0, =format	@将 format 变量的内存地址存储在 r0 寄存器中，以便后续可以将该地址传递给 printf 函数。
    ldr r3, =MAX_COUNT
    ldr r1, [r3]	@将 MAX_COUNT 变量的值存储在 r1 寄存器中，以便后续可以将该地址传递给 printf 函数。
    ldr r4, =result  @ 将 result 变量的内存地址存储在 r4 寄存器中，以便后续可以将该地址用于加载 result 变量的值。
    ldr r2, [r4]     @ 加载了 result 变量的值到 r2 寄存器中
    bl printf	@ printf 函数，向其传递参数 r0、r1 和 r2

    @ 退出程序
    mov r0, #0	@将零存储在 r0 寄存器中，用于表示程序的返回状态正常
    bx lr	@

calculateSum:
    @ 计算和
    mov r2, #0  @ 初始化总和sum = 0
    mov r3, #1  @ 初始化循环计数器i = 1
    @ldr r4, =MAX_COUNT
    ldr r4, [r0]	@加载 n的值到 r4 寄存器中
loop_sum:
    cmp r3, r4  @ 比较i和MAX_COUNT
    bgt loop_end_sum	@i 大于 MAX_COUNT，则跳转到 loop_end_sum 标签，循环结束
    add r2, r2, r3  @ sum += i
    add r3, r3, #1  @ i++
    b loop_sum

loop_end_sum:
    mov r0, r2  @ 将 r2 寄存器中的值（sum）复制到 r0 寄存器中，用于返回结果
    bx lr	@用 bx 指令跳转回到函数调用点
