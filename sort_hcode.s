@Name: Chanly Ly
@Id: 011039168



.cpu cortex-a53
.fpu neon-fp-armv8

.data
.equ LTR_TO_NXT_LTR, 56       @memory distance from &hcode[i].letter to & hcode[i + 1].letter
.equ LTR_TO_CODE, 4           @memory distance from &hcode[i].letter to &hcode[i].code[0]
.equ CODE_TO_CODE, 4          @memory distance from &hcode[i].code[j] to &hcode[i].code[j + 1]
.equ LTR_TO_SIZE, 52          @memory distance from &hcode[i].letter to &hcode[i].size
.equ CODE_TO_SIZE, 4          @memory distance from &hcode[i].code[11] to &hcode[i].size

.text
.align 2
.global sort_hcode
.type sort_hcode, %function

sort_hcode:
    push {fp, lr}           @push lr and fp onto the stack
    add fp, sp, #4          @point fp to lr

    @r0 contains &hcode[]

    mov r7, r0                              @save &hcode[] in r7
    mov r1, #0                              @store 0 in r1, r1 contains i

    @while (i < 28)
outerWhileLoop:
    cmp r1, #28                         @compare i to 28
    bge endFunction                     @branch to endFunction if i >= 28

    mov r3, #LTR_TO_NXT_LTR             @store LTR_TO_NXT_LTR in r3
    mul r3, r3, r1                      @r3 = i * 56, which is the offset from &hcode[0].letter to &hcode[i].letter
    add r3, r3, #LTR_TO_SIZE            @r3 = offset from &hcode[0].letter to &hcode[i].size
    mov r10, r3                         @move r3 to r10 so r10 = offset from &hcode[0].letter to &hcode[i].size
    ldr r3, [r7, r10]                   @r3 = hcode[i].size

    add r2, r1, #1                      @r2 = i + 1, r2 contains j

    @while (j < 29)
innerWhileLoop:
    cmp r2, #29                     @compare j to 29
    bge continue1                   @branch to continue1 if j > 29

    mov r8, #LTR_TO_NXT_LTR         @store LTR_TO_NXT_LTR in r8
    mul r8, r8, r2                  @r8 = = j * 56 = offset from &hcode[0] to &hcode[j]
    add r8, r8, #LTR_TO_SIZE        @r8 = offset from &hcode[0].letter to &hcode[j].size
    push {r8}                       @push r8 onto the stack so sp = offset from &hcode[0].letter to &hcode[j].size
    ldr r8, [r7, r8]                @r8 = hcode[j].size

    cmp r3, r8                      @compares hcode[i].size to hcode[j].size
    bgt switchStructs               @branch to switchStructs if hcode[i].size > hcode[j].size

    add r2, r2, #1                  @j++
    b innerWhileLoop                @branch back to innerWhileLoop

switchStructs:
    ldr r8, [sp], #4            @load offset from &hcode[0].letter to &hcode[j].size in r8
    mov r3, r10                 @move r10 to r3 so r3 = offset from &hcode[0].letter to &hcode[i].size

        @ switch letters
    sub r8, r8, #LTR_TO_SIZE    @r8 = offset from &hcode[0].letter to &hcode[j].letter
    sub r3, r3, #LTR_TO_SIZE    @r3 = offset from &hcode[0].letter to &hcode[i].letter


    ldrb r0, [r7, r3]           @load r0 = hcode[i].letter
    ldrb r9, [r7, r8]           @load r9 = hcode[j].letter
    strb r0, [r7, r8]           @store hcode[i].letter = hcode[j].letter
    strb r9, [r7, r3]           @store hcode[j].letter = hcode[i].letter

        @ switch codes
    add r3, r3, #LTR_TO_CODE    @r3 = offset from &hcode[0].letter to &hcode[i].code[0]
    add r8, r8, #LTR_TO_CODE    @r8 = offset from &hcode[0].letter to &hcode[j].code[0]

    ldr r0, [r7, r3]            @load r0 = hcode[i].code[0]
    ldr r9, [r7, r8]            @load r9 = hcode[j].code[0]
    str r0, [r7, r8]            @store hcode[j].code[0] = hcode[i].code[0]
    str r9, [r7, r3]            @store hcode[i].code[0] = hcode[j].code[0]

    mov r6, #1                  @store 1 in r6, r6 contains n

    @while (n < 12)
switchCodesLoop:

    cmp r6, #12             @compate n to 12
    bge continue2           @branch to continue2 if n >= 12

    add r3, r3, #CODE_TO_CODE   @r3 = offset from &hcode[0].letter to &hcode[i].code[n] to &hcode[i].code[n + 1]
    add r8, r8, #CODE_TO_CODE   @r8 = offset from &hcode[0].letter to &hcode[j].code[n] to &hcode[j].code[n + 1    ]

    ldr r0, [r7, r3]        @load r0 = hcode[i].code[0]
    ldr r9, [r7, r8]        @load r9 = hcode[j].code[0]
    str r0, [r7, r8]        @store hcode[j].code[0] = hcode[i].code[0]
    str r9, [r7, r3]        @store hcode[i].code[0] = hcode[j].code[0]





    ldr r0, [r7, r3]        @load r0 = hcode[i].code[0]
    ldr r9, [r7, r8]        @load r9 = hcode[j].code[0]

    add r6, r6, #1          @n++

    b switchCodesLoop       @branch back to switchCodesLoop

continue2:

    add r8, r8, #CODE_TO_SIZE   @r8 = offset from &hcode[0].code[11] to &hcode[j].size
    add r3, r3, #CODE_TO_SIZE   @r3 = offset from &hcode[0].code[11] to &hcode[i].size
    ldr r0, [r7, r3]            @r0 = hcode[i].size
    ldr r9, [r7, r8]            @r9 = hcode[j].size
    str r0, [r7, r8]            @hcode[j].size = hcode[i].size
    str r9, [r7, r3]            @hcode[i].size = hcode[j].size

    add r2, r2, #1              @j++
    ldr r3, [r7, r10]           @restore r3 to r3 = hcode[i].size after switching structs
    b innerWhileLoop            @branch back to innerWhileLoop


continue1:
    add r1, r1, #1                  @i++
    b outerWhileLoop                @branch back to outerWhileLoop

endFunction:
    sub sp, fp, #4                  @place sp at -8 on stack
    pop {fp, pc}                    @pop fp and pc



