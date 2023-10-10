.data
.global pai       @ 声明全局标识符 "pai"
pai:
    .float 3.14159265  @ 初始化 "pai" 变量为 3.14159265

.text
    .global getCircumference  @ 声明全局函数 "getCircumference"
    .type getCircumference, %function  @ 定义 "getCircumference" 函数的元信息
getCircumference:
    str fp, [sp, #-4]!  @ 保存当前栈帧的栈指针到栈上，并更新栈指针
    add fp, sp, #0     @ 设置新的栈帧指针
    sub sp, sp, #20    @ 分配 20 字节的栈空间用于局部变量

    str r0, [fp, #-16]   @ 将参数 r0 存储到栈帧上的位置

    vstr.32 s0, [fp, #-20]  @ 将单精度浮点寄存器 s0 的值存储到栈帧上的位置

    ldr r3, [fp, #-16]  @ 加载参数 r0 到 r3 寄存器
    cmp r3, #0          @ 比较 r3 和 0
    bne .NotEqualZeroLabel @ 如果不等于 0，则跳转到 .NotEqualZeroLabel 标签

    ldr r1, =pai
    vldr.32 s15, [r1]    @ 加载单精度浮点常数到 s15 寄存器
    vadd.f32 s15, s15, s15  @ 将 s15 寄存器的值加倍
    vldr.32 s14, [fp, #-20]  @ 加载栈帧上的单精度浮点数到 s14 寄存器
    vmul.f32 s15, s14, s15  @ 计算 s14 * s15 的结果并存储到 s15 寄存器
    vstr.32 s15, [fp, #-8]  @ 将结果存储到栈帧上的位置
    b .EndLabel               @ 跳转到 .EndLabel 标签

.NotEqualZeroLabel:
    vldr.32 s15, [fp, #-20]  @ 加载栈帧上的单精度浮点数到 s15 寄存器
    vmov.f32 s14, #4.0e+0    @ 将单精度浮点常数 4.0 存储到 s14 寄存器
    vmul.f32 s15, s15, s14   @ 计算 s15 * s14 的结果并存储到 s15 寄存器
    vstr.32 s15, [fp, #-8]   @ 将结果存储到栈帧上的位置

.EndLabel:
    ldr r3, [fp, #-8]   @ 加载栈帧上的单精度浮点数到 r3 寄存器
    vmov s15, r3        @ 将 r3 寄存器的值存储到单精度浮点寄存器 s15 中
    vmov.f32 s0, s15    @ 复制 s15 寄存器的值到 s0 寄存器
    add sp, fp, #0      @ 恢复栈指针
    @ sp needed
    ldr fp, [sp], #4    @ 恢复栈帧指针
    bx lr               @ 返回

    .global getArea  @ 声明全局函数 "getArea"
    .type getArea, %function  @ 定义 "getArea" 函数的元信息
getArea:
    str fp, [sp, #-4]!  @ 保存当前栈帧的栈指针到栈上，并更新栈指针
    add fp, sp, #0     @ 设置新的栈帧指针
    sub sp, sp, #20    @ 分配 20 字节的栈空间用于局部变量

    str r0, [fp, #-16]   @ 将参数 r0 存储到栈帧上的位置

    vstr.32 s0, [fp, #-20]  @ 将单精度浮点寄存器 s0 的值存储到栈帧上的位置

    ldr r3, [fp, #-16]  @ 加载参数 r0 到 r3 寄存器
    cmp r3, #0          @ 比较 r3 和 0
    bne .NotEqualZeroLabel2 @ 如果不等于 0，则跳转到 .NotEqualZeroLabel2 标签

    ldr r1, =pai
    vldr.32 s14, [r1]   @ 加载单精度浮点常数到 s14 寄存器
    vldr.32 s15, [fp, #-20]  @ 加载栈帧上的单精度浮点数到 s15 寄存器
    vmul.f32 s15, s14, s15  @ 计算 s14 * s15 的结果并存储到 s15 寄存器
    vldr.32 s14, [fp, #-20]  @ 再次加载栈帧上的单精度浮点数到 s14 寄存器
    vmul.f32 s15, s14, s15  @ 计算 s14 * s15 的结果并存储到 s15 寄存器
    vstr.32 s15, [fp, #-8]  @ 将结果存储到栈帧上的位置
    b .EndLabel2        @ 跳转到 .EndLabel2 标签

.NotEqualZeroLabel2:
    vldr.32 s15, [fp, #-20]  @ 加载栈帧上的单精度浮点数到 s15 寄存器
    vmul.f32 s15, s15, s15  @ 计算 s15 * s15 的结果并存储到 s15 寄存器
    vstr.32 s15, [fp, #-8]   @ 将结果存储到栈帧上的位置

.EndLabel2:
    ldr r3, [fp, #-8]   @ 加载栈帧上的单精度浮点数到 r3 寄存器
    vmov s15, r3        @ 将 r3 寄存器的值存储到单精度浮点寄存器 s15 中
    vmov.f32 s0, s15    @ 复制 s15 寄存器的值到 s0 寄存器
    add sp, fp, #0      @ 恢复栈指针
    @ sp needed
    ldr fp, [sp], #4    @ 恢复栈帧指针
    bx lr               @ 返回

.section .rodata
.InputTypePrompt:
    .ascii "Input the type (0 for circle, others for square): \000"  @ 提示消息
    .align 2
.FormatInteger:
    .ascii "%d\000"  @ 格式化字符串
    .align 2
.InputNumberPrompt:
    .ascii "Input a number: \000"  @ 提示消息
    .align 2
.FormatFloat:
    .ascii "%f\000"  @ 格式化字符串
    .align 2
.InvalidNumberMessage:
    .ascii "Invalid number. Please enter a non-negative value.\000"  @ 提示消息
    .align 2
.CircumferenceMessage:
    .ascii "Circumference of the square: %.4f\012\000"  @ 提示消息
    .align 2
.AreaMessage:
    .ascii "Area of the circle: %.4f\012\000"  @ 提示消息
    
    .text
    .align 2
    .global main  @ 声明全局函数 "main"
    .type main, %function  @ 定义 "main" 函数的元信息
main:
    @ 栈帧设置和局部变量分配
    push {fp, lr}       @ 保存当前函数的栈帧指针和返回地址
    add fp, sp, #4      @ 设置新的栈帧指针
    sub sp, sp, #24     @ 分配 24 字节的栈空间用于局部变量

    @ 读取输入类型
    ldr r2, .bridge         @ 加载 .bridge 标签的地址到 r2 寄存器
.LPIC9:
    add r3, pc, r3      @ 计算全局偏移地址
    str r3, [fp, #-8]   @ 将 r3 寄存器的值存储到栈帧上的位置
    mov r3, #0           @ 将常数 0 存储到 r3 寄存器
    ldr r3, .bridge+4       @ 加载 .bridge+4 标签的地址到 r3 寄存器
.LPIC0:
    add r3, pc, r3      @ 计算全局偏移地址
    mov r0, r3          @ 将 r3 寄存器的值存储到 r0 寄存器（用于 printf 调用）
    bl printf      @ 调用 printf 函数以打印消息
    sub r3, fp, #24     @ 计算栈帧上局部变量的地址并存储到 r3 寄存器
    mov r1, r3          @ 将 r3 寄存器的值存储到 r1 寄存器
    ldr r3, .bridge+8     @ 加载 .bridge+8 标签的地址到 r3 寄存器
.LPIC1:
    add r3, pc, r3      @ 计算全局偏移地址
    mov r0, r3          @ 将 r3 寄存器的值存储到 r0 寄存器（用于 scanf 调用）
    bl scanf  @ 调用 scanf 函数以读取输入
    ldr r3, .bridge+12     @ 加载 .bridge+12 标签的地址到 r3 寄存器
.LPIC2:
    add r3, pc, r3      @ 计算全局偏移地址
    mov r0, r3          @ 将 r3 寄存器的值存储到 r0 寄存器（用于 printf 调用）
    bl printf      @ 调用 printf 函数以打印消息
    sub r3, fp, #20     @ 计算栈帧上局部变量的地址并存储到 r3 寄存器
    mov r1, r3          @ 将 r3 寄存器的值存储到 r1 寄存器
    ldr r3, .bridge+16     @ 加载 .bridge+16 标签的地址到 r3 寄存器
.LPIC3:
    add r3, pc, r3      @ 计算全局偏移地址
    mov r0, r3          @ 将 r3 寄存器的值存储到 r0 寄存器（用于 scanf 调用）
    bl scanf  @ 调用 scanf 函数以读取输入

    vldr.32 s15, [fp, #-20]  @ 加载栈帧上的单精度浮点数到 s15 寄存器
    vcmpe.f32 s15, #0        @ 比较 s15 和 0
    vmrs APSR_nzcv, FPSCR    @ 获取浮点标志寄存器的状态
    bpl .getCircumferenceAndArea                  @ 如果 s15 大于等于 0，则跳转到 .getCircumferenceAndArea 标签

    ldr r3, .bridge+20    @ 加载 .bridge+20 标签的地址到 r3 寄存器
.LPIC4:
    add r3, pc, r3    @ 计算全局偏移地址
    mov r0, r3        @ 将 r3 寄存器的值存储到 r0 寄存器（用于 puts 调用）
    bl puts      @ 调用 puts 函数以打印错误消息
    b .ExitLabel            @ 跳转到 .ExitLabel 标签

.getCircumferenceAndArea:
    ldr r3, [fp, #-24]  @ 加载栈帧上的整数到 r3 寄存器
    vldr.32 s15, [fp, #-20]  @ 加载栈帧上的单精度浮点数到 s15 寄存器
    vmov.f32 s0, s15   @ 复制 s15 寄存器的值到 s0 寄存器
    mov r0, r3         @ 将 r3 寄存器的值存储到 r0 寄存器（用于 getCircumference 调用）
    bl getCircumference  @ 调用 getCircumference 函数计算周长
    vstr.32 s0, [fp, #-16]   @ 将结果存储到栈帧上的位置

    ldr r3, [fp, #-24]  @ 加载栈帧上的整数到 r3 寄存器
    vldr.32 s15, [fp, #-20]  @ 加载栈帧上的单精度浮点数到 s15 寄存器
    vmov.f32 s0, s15   @ 复制 s15 寄存器的值到 s0 寄存器
    mov r0, r3         @ 将 r3 寄存器的值存储到 r0 寄存器（用于 getArea 调用）
    bl getArea    @ 调用 getArea 函数计算面积
    vstr.32 s0, [fp, #-12]   @ 将结果存储到栈帧上的位置

    ldr r3, [fp, #-24]  @ 加载栈帧上的整数到 r3 寄存器
    cmp r3, #0         @ 比较 r3 和 0
    bne .SquareLabel            @ 如果不等于 0，则跳转到 .SquareLabel 标签

    vldr.32 s15, [fp, #-16]  @ 加载栈帧上的单精度浮点数到 s15 寄存器
    vcvt.f64.f32 d7, s15   @ 将 s15 寄存器的单精度浮点数转换为双精度浮点数
    vmov r2, r3, d7        @ 将双精度浮点数的高位存储到 r2 寄存器
    ldr r1, .bridge+24        @ 加载 .bridge+24 标签的地址到 r1 寄存器
.LPIC5:
    add r1, pc, r1        @ 计算全局偏移地址
    mov r0, r1            @ 将 r1 寄存器的值存储到 r0 寄存器（用于 printf 调用）
    bl printf        @ 调用 printf 函数以打印消息

    vldr.32 s15, [fp, #-12]  @ 加载栈帧上的单精度浮点数到 s15 寄存器
    vcvt.f64.f32 d7, s15   @ 将 s15 寄存器的单精度浮点数转换为双精度浮点数
    vmov r2, r3, d7        @ 将双精度浮点数的高位存储到 r2 寄存器
    ldr r1, .bridge+28        @ 加载 .bridge+28 标签的地址到 r1 寄存器
.LPIC6:
    add r1, pc, r1        @ 计算全局偏移地址
    mov r0, r1            @ 将 r1 寄存器的值存储到 r0 寄存器（用于 printf 调用）
    bl printf        @ 调用 printf 函数以打印消息
    b .ExitLabel                @ 跳转到 .ExitLabel 标签

.SquareLabel:
    vldr.32 s15, [fp, #-16]  @ 加载栈帧上的单精度浮点数到 s15 寄存器
    vcvt.f64.f32 d7, s15   @ 将 s15 寄存器的单精度浮点数转换为双精度浮点数
    vmov r2, r3, d7        @ 将双精度浮点数的高位存储到 r2 寄存器
    ldr r1, .bridge+32        @ 加载 .bridge+32 标签的地址到 r1 寄存器
.LPIC7:
    add r1, pc, r1        @ 计算全局偏移地址
    mov r0, r1            @ 将 r1 寄存器的值存储到 r0 寄存器（用于 printf 调用）
    bl printf        @ 调用 printf 函数以打印消息

    vldr.32 s15, [fp, #-12]  @ 加载栈帧上的单精度浮点数到 s15 寄存器
    vcvt.f64.f32 d7, s15   @ 将 s15 寄存器的单精度浮点数转换为双精度浮点数
    vmov r2, r3, d7        @ 将双精度浮点数的高位存储到 r2 寄存器
    ldr r1, .bridge+36        @ 加载 .bridge+36 标签的地址到 r1 寄存器
.LPIC8:
    add r1, pc, r1        @ 计算全局偏移地址
    mov r0, r1            @ 将 r1 寄存器的值存储到 r0 寄存器（用于 printf 调用）
    bl printf        @ 调用 printf 函数以打印消息

.ExitLabel:
    mov r0, r3            @ 将 r3 寄存器的值存储到 r0 寄存器
    sub sp, fp, #4         @ 恢复栈指针
    @ sp needed
    pop {fp, pc}           @ 弹出栈帧指针和返回地址

.bridge:
    .word _GLOBAL_OFFSET_TABLE_-(.LPIC9+8)  @ 全局偏移表地址
    .word .InputTypePrompt-(.LPIC0+8)  @ .InputTypePrompt 地址
    .word .FormatInteger-(.LPIC1+8)  @ .FormatInteger 地址
    .word .InputNumberPrompt-(.LPIC2+8)  @ .InputNumberPrompt 地址
    .word .FormatFloat-(.LPIC3+8)  @ .FormatFloat 地址
    .word .InvalidNumberMessage-(.LPIC4+8)  @ .InvalidNumberMessage 地址
    .word .CircumferenceMessage-(.LPIC5+8)  @ .CircumferenceMessage 地址
    .word .AreaMessage-(.LPIC6+8)  @ .AreaMessage 地址
    .word .CircumferenceMessage-(.LPIC7+8)  @ .CircumferenceMessage 地址
    .word .AreaMessage-(.LPIC8+8)  @ .AreaMessage 地址
