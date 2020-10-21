@Name: Chanly Ly
@Id: 01103968


.cpu cortex-a53
.fpu neon-fp-armv8

.data

.equ MAX_LT_SHIFT, 31         @the maximum number of times the first bit can be shifted to the left is 31 times to get to the 32nd bit position
.equ LTR_TO_SIZE, 52          @memory distance from &hcode[i].letter to &hcode[i].size
.equ LTR_TO_CODE, 4           @memory distance from &hcode[i].letter to &hcode[i].code[0]
.equ LTR_TO_NXT_LTR, 56       @memory distance from &hcode[i].letter to & hcode[i + 1].letter

.text
.align 2
.global search_hcode
.type search_hcode, %function

search_hcode:
    push {fp, lr}           @push lr and fp onto the stack
    add fp, sp, #4          @point fp to lr
    push {r1, r2, r3, r4, r5, r6, r7, r8, r9, r10}         @push all register values onto the stack

    @r0 contains &hcode[].letter
    @r1 contains current_int
    @r2 contains numBitsAdded(the number of bits being examined so far)


    mov r8, r1                     @save current_int in r8
    mov r7, r0                     @save &hcode[].letter in r7
    str r2, [sp, #-4]!             @move sp so it points to numBitsAdded, sp = numBitsAdded

    mov r4, #0                     @store 0 in r4, r4 containts i

outerWhileLoop:

    cmp r4, #29                @compare i to 29
    moveq r0, r4               @return 29 meaning not an equivalent char found in hcode[]
    beq endFunction            @branch to endFunction if equal

    mov r5, #LTR_TO_NXT_LTR    @store LTR_TO_NXT_LTR in r5
    mul r6, r4, r5             @r6 = offset from &hcode[0].letter to &hcode[i].letter
    mov r1, r6                 @store r6 in r1 so r1 = offset from &hcode[0].letter to &hcode[i].letter
    add r1, r7, r1             @r1 = &hcode[i].letter
    add r5, r6, #LTR_TO_SIZE   @r5 = offset from &hcode[0].letter to &hcode[i].size
    add r6, r6, #LTR_TO_CODE   @r6 = offset from &hcode[0].letter to &hcode[i].code

    ldr r2, [r7,r5]            @r2 = hcode[i].size

    ldr r5, [sp]               @load numBitsAdded in r5
    cmp r2, r5                 @only examine hcode[i] struct if numBitsAdded == hcode[i].size
    addne r4, r4, #1           @i++ if not equal
    bne outerWhileLoop         @branch to outerWhileLoop if not equal

    ldr r3, [r7, r6]           @r3 = hcode[i].code[0]

    mov r5, r1                 @r5 = &hcode[i].letter


    mov r1, #0                 @store 0 in r1, r1 contains j
    mov r9, #MAX_LT_SHIFT      @store MAX_LT_SHIFT in r9

    mov r10, #0                @store 0 in r10

@ loop creates an int containing only the .code portion bits of hcode[i] being looked at, with the codes in the front of the packet

innerWhileLoop:            @while (j < hcode[i].size)
    cmp r1, r2             @compare j to hcode[i].size
    bge checkBits          @branch to checkBits if j >= hcode[i].size

    mov r0, #4             @store 4 in r0
    mul r0, r1, r0         @r0 = j * 4 = offset for &hcode[i].code[0] to &hcode[i].code[j]
    add r0, r0, #4         @add 4 to r0 to get to the .code section
    ldr r0, [r5, r0]       @r0 = hcode[i].code[j]

    mov r0, r0, LSL r9     @left shift value stored at hcode[i].code[j] according to bitPosition
    ORR r10, r10,  r0      @combine with r10, which started at 0 (32 zeroes) to create an int containing the hcode[i].code[0 to j] bits in the right positions
    sub r9, r9, #1         @bitPosition--
    add r1, r1,#1          @i++

    b innerWhileLoop       @branch back to innerWhileLoop

checkBits:

    eor r1, r10, r8      @exclusive-or huffmanCode (bits to far left in 32 bit packet) with current_int, if same bits 0, if different bits 1
    cmp r1, #0           @compare r1 to 0
    addne r4, r4, #1     @i++
    bne outerWhileLoop   @branch back outerWhileLoop if r0 != 0

    moveq r0, r4         @if r1 is 1, return hcode index
    beq endFunction       @branch to endFunction if r0 == r4

endFunction:
        add sp, sp, #4                                      @restore sp
        pop {r1, r2, r3, r4, r5, r6, r7, r8, r9, r10}       @pop all register values
        sub sp, fp, #4                                      @place sp at -8 on stack
        pop {fp, pc}                                        @pop fp and pc
