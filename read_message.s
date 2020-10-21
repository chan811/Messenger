@Name: Chanly Ly
@Id: 011039168


.cpu cortex-a53
.fpu neon-fp-armv8

.data
inp: .asciz "%c"
.extern feof
.equ BYTE, 1
.equ NULL, 0

.text
.align 2
.global read_message
.type read_message, %function

read_message:
    push {fp, lr}           @push lr and fp onto the stack
    add fp, sp, #4          @point fp to lr
    sub sp, sp, #4          @makes space for memory

    @r0 contains fptr
    @r1 contains &message[]


    mov r4, r0              @save fptr in r4
    mov r5, r1              @save &message[] in r5
    mov r10, #0             @store 0 in r10, r10 contains i

whileLoop:
    mov r0, r4          @move fptr to r0
    ldr r1, =inp        @load "%c" in r1
    mov r2, sp          @move memory, sp into r2 to get char
    bl fscanf           @call fscanf() to scan char and place into sp, memory
    ldrb r0, [sp]       @load the scanned char into r0


    mov r0, r4          @move fptr to r0
    bl feof             @call feof() to check if fptr is at EOF

    cmp r0, #1          @compare the value feof() returned to 1, feof will return true, 1 if end of file reached
    beq endFunction     @branch to endFunction if fptr is at EOF

    ldrb r0, [sp]       @reload char back into r0

    mov r1, #BYTE       @store BYTE into r1
    mul r1, r1, r10     @r1 = i * BYTE

    cmp r0, #32         @compare char to 32
    movlt r0, #32       @if r0 < 32, move 32 in r0

    strb r0, [r5, r1]   @put char stored into r0 into message[i] array

    cmp r0, #31         @compare char to 31
    add r10, r10, #1    @i++

    b whileLoop         @branch back to whileLoop

endFunction:
    mov r0, r10         @return the number of chars in the message
    add sp, sp, #4      @restore sp
    sub sp, fp, #4      @place sp at -8 on stack
    pop {fp, pc}        @pop fp and pc
