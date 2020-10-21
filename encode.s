@Name: Chanly Ly
@Id: 011039168

.cpu cortex-a53
.fpu neon-fp-armv8

.data

.equ LTR_TO_NXT_LTR, 56       @memory distance from &hcode[i].letter to & hcode[i + 1].letter
.equ LTR_TO_CODE, 4           @memory distance from &hcode[i].letter to &hcode[i].code[0]
.equ CODE_TO_CODE, 4          @memory distance from &hcode[i].code[j] to &hcode[i].code[j + 1]
.equ LTR_TO_SIZE, 52          @memory distance from &hcode[i].letter to &hcode[i].size
.equ MEMORY, 4                @memory distance in array, in this case, from &message[i] to &message[i + 1]
.equ BITS_IN_INT, 32          @each int is 32 bits
.equ BYTE, 1                  @a single byte
.equ MAX_LOWER_CASE, 122      @integer value for 'z'
.equ MIN_LOWER_CASE, 97       @integer value for 'a'
.equ MAX_UPPER_CASE, 90       @integer value for 'Z'
.equ MIN_UPPER_CASE, 65       @integer value for 'A'
.equ SOCKFP, 3
.equ SIZEOF, 4



.text
.align 2
.global encode
.type encode, %function

encode:
    push {fp, lr}       @push fp and lr onto the stack
    add fp, sp, #4      @point fp to lr

    sub sp, sp, #16     @make space for memory

    @ r0 contains &message[]
    @ r1 containss &hcode[]

    mov r4, r0    @save &message[] in r4
    mov r5, r1    @save &hcode[] in r5
    mov r6, #0    @store 0 in r6, r6 contains c_data
    mov r7, #32   @store 32 in r7, r7 is a counter
    mov r10, #0   @store 0 in r10, r10 contains i

    mov r0, r4    @store &message[] in r0
    bl strlen     @call strlen() to get the length of &message[]

    str r0, [sp, #12]     @store the string length returned by strlen() onto the stack

outerWhileLoop:
    ldr r0, [sp, #12]        @load the string length in r0

    cmp r10, r0              @compare i to string length
    beq endFunction          @branch to endFunction if i == string length

    @char c = message[i].letter
    mov r0, #BYTE            @store BYTE in r0
    mul r0, r10, r0          @r0 = i * 1 for offset from &message[i] to &message[i + 1]
    ldrb r1, [r4, r0]        @load a char from message[i] and store it in r1


    cmp r1, #MIN_UPPER_CASE @compare the char in r1 to MIN_UPPER_CASE
    blt notAlpha            @branch to notAlpha if r1 < MIN_UPPER_CASE


    addle r1, r1, #32             @replace uppercase letter with equivalent lowercase letter
    suble r2, r1, #MIN_LOWER_CASE @hcodeIndex = r2 = c - a, for the hcode array
    ble encoding                  @branch to encoding if <=


    cmp r1, #MIN_LOWER_CASE      @compare char in r1 to MIN_LOWER_CASE
    blt notAlpha                 @branch to notAlpha if r1 < MIN_LOWER_CASE

    cmp r1, #MAX_LOWER_CASE      @compare char in r1 to MAX_LOWER_CASE
    suble r2, r1, #MIN_LOWER_CASE @hcodeIndex = r2 = c - a, for the hcode array
    ble encoding                @branch to encoding if <=

    cmp r1, #MAX_LOWER_CASE      @compare char in r1 to MAX_LOWER_CASE
    bgt notAlpha                @branch to notAlpha if r1 > MAX_LOWER_CASE

notAlpha:
    cmp r1, #46          @comapre char in r1 to '.' <- #46
    bne notAlpha1        @branch to notAlpha1 if c != '.'

    mov r2, #26          @else, c == '.' or '!' or '?' store 26 in r2 for hcode array
    b encoding           @branch to encoding

notAlpha1:
    cmp r1, #33          @compare char in r1 to '!' <- #33
    bne notAlpha2        @branch to notAlpha2 if c != '!'

    mov r2, #26          @else, c == '.' or '!' or '?' store 26 in r2 for hcode array
    b encoding           @branch to encoding

notAlpha2:
    cmp r1, #63          @compare char in r1 to '?' <- #63
    bne notAlpha3        @branch to notAlpha3 if c != '?'

    mov r2, #26          @else, c == '.' or '!' or '?' store 26 in r2 for hcode array
    b encoding           @branch to encoding

notAlpha3:
    cmp r1, #32          @compare char in r1 to ' ' <- #32
    bne notAlpha4        @branch to notAlpha4 if c != ' '

    mov r2, #27          @else c == ' ' store 26 in r2 for hcode array
    b encoding           @branch to encoding

notAlpha4:
    cmp r1, #44          @compare char in r1 to ',' <- #44
    bne continue         @branch to continue if c != ','

    mov r2, #28          @else c == ',' store 26 in r2 for hcode array
    b encoding           @branch to encoding

continue:
    add r10, r10, #1         @i++

encoding:
    @get &hcode[hcodeIndex].letter, &hcode[hcodeIndex].code[0], &hcode[hcodeIndex].size
    mov r0, #LTR_TO_NXT_LTR   @store LTR_TO_NXT_LTR in r0
    mul r0, r2, r0            @r0 = hcodeIndex * 56, offset from &hcode[0].letter to &hcode[i].letter
    add r8, r5, r0            @r8 = &hcode[hcodeIndex].letter
    str r8, [sp, #8]          @store r8 = &hcode[hcodeIndex].letter on the stack
    mov r9, r8                @store &hcode[hcodeIndex].letter in r9
    add r8, r8, #LTR_TO_SIZE  @r8 = &hcode[hcodeIndex].size
    str r8, [sp]              @sp contains &hcode[hcodeIndex].size
    add r9, r9, #LTR_TO_CODE  @r9 = &hcode[i].code[0]
    str r9, [sp, #4]          @store r9 = &hcode[i].code[0]  on the stack

    ldr r1, [sp]              @r1 = &hcode[i].size
    ldr r1, [r1]              @r1 = hcode[i].size

    cmp r1, r7           @compare r1 to r7 (counter)
    blle skip2            @branch to skip2 if the 32 bit number/packet is not yet completed

    @sending code
    @r3 <- huffman code represented as a # shifted (counter - hcode[i].size) bits left
    cmp r3, #0             @if the last huffman code ORR with c_data represents char ' ', then set counter to 28, else set counter to 32

    movne r7, #BITS_IN_INT @ reset 32-bits in total counter to 32 bits total
    moveq r7, #28

    str r1, [sp, #-4]!    @save value of r1

    mov r0, #SOCKFP       @store SOCKFP in r0
    mov r1, r6            @store number/packet in r1
    mov r2, #SIZEOF       @store SIZEOF in r2
    bl write              @call write() to send int over the net

    ldr r1, [sp], #4      @load the value of r1 back into r1



    mov r6, #0           @store 0 in r6, r6 contains c_data

skip2:

    mov r3, #0           @store 0 in r3, r3 contains temp
    mov r0, #0           @store 0 in r0, r0 contains j

innerWhileLoop:
    cmp r0, r1           @compare j to hcode[index].size
    bge combineHuffCompressedData    @branch to combineHuffCompressedData if j>= hcode[i].size


    ldr r8, [sp, #4]         @load &hcode[hcodeIndex].code[0] and store it in r8
    mov r9, #MEMORY          @store MEMORY in r9
    mul r9, r0, r9           @r9 = j * 4 for offset from &hcode[i].code[0] to &hcode[i].code[j]
    add r8, r8, r9           @r8 = &hcode[i].code[j]

    ldr r8, [r8]             @load hcode[i].code[j] in r8


    mov r3, r3, LSL #1   @left shift temp by 1 spot to make room for the next bit from hcode[hcodeIndex].code[j]
    ORR r3, r3, r8       @temp | ( hcode[hcodeIndex].code[j] << j )
    add r0, r0, #1       @j++

    b innerWhileLoop     @branch back to innerWhileLoop


    ldr r8, [sp]         @r8 = &hcode[hcodeIndex].size
    ldr r8, [r8]         @r8 = hcode[hcodeIndex].size
    mov r9, r8           @store hcode[hcodeIndex].size into r9

    sub r8, r7, r8       @r8 = (counter - hcode[index].size)
    mov r3, r3, LSL r8   @temp << (counter - hcode[index].size)
    ORR r6, r6, r3       @c_data = c_data | temp;
    sub r7, r7, r9       @counter = counter - hcode[index].size;

    add r10, r10, #1         @i++
    b outerWhileLoop         @branch back to outerWhileLoop

endFunction:

    str r1, [sp, #-4]!    @save value of r1

    mov r0, #SOCKFP       @store SOCKFP in r0
    mov r1, r6            @store number/packet in r1
    mov r2, #SIZEOF       @store SIZEOF in r2
    bl write              @call write() to send int over the net

    ldr r1, [sp], #4      @load the value of r1 back into r1


    add sp, sp, #16        @unallocate memory
    sub sp, fp, #4         @place sp at -8 on stack
    pop {fp, pc}           @pop fp and pc
