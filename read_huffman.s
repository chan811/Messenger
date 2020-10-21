@Name: Chanly Ly
@Id: 011039168



.cpu cortex-a53
.fpu neon-fp-armv8

.equ LTR_TO_NXT_LTR, 56       @memory distance from &hcode[i].letter to & hcode[i + 1].letter
.equ LTR_TO_CODE, 4           @memory distance from &hcode[i].letter to &hcode[i].code[0]
.equ CODE_TO_CODE, 4          @memory distance from &hcode[i].code[j] to &hcode[i].code[j + 1]
.equ LTR_TO_SIZE, 52          @memory distance from &hcode[i].letter to &hcode[i].size

inp: .asciz "%c"

.text
.align 2
.global read_huffman
.type read_huffman, %function

read_huffman:
    push {fp, lr}           @push lr and fp onto the stack
    add fp, sp, #4          @point fp to lr

    sub sp, sp, #4          @make space for memory

    @r0 contains the file pointer
    @r1 contains the address to the huffcode

    mov r6, r0            @move fptr to r6
    mov r4, #0            @store 0 in r4, r4 contains i = 0
    mov r7, r1            @move &hcode[0].letter to r7
    mov r9, r1            @move &hcode[0].letter to r9

@for (i = 0; i < 29; i++)
whileLoop:
    cmp r4, #29           @compare i to 29
    bge endFunction       @branch to end function once finished with populating data for the 29 structs in the array of structs

    mov r5, #0            @store 0 in r5, r5 contains size = 0


@do-while loop used to scan each line
doWhileLoop:
    @ scan each char into memory, lets call it char c
    mov r0, r6               @move fptr to r0
    ldr r1, =inp             @load "%c" in r1
    mov r2, sp               @move memory, sp into r2 to get char
    bl fscanf                @call fscanf() to scan char and place into sp, memory

    @check if c == '\n' then end do-while loop
    ldrb r0, [sp]            @load the scanned char into r0
    cmp r0, #10              @compare r0 to '\n'
    beq endDoWhileLoop       @branch to endDoWhileLoop if equal

    add r5, r5, #1           @i++

    @ if (size == 1) {hcode[i].letter = c;  // store character into memory}
    @ get to proper hcode[i]
    mov r1, #LTR_TO_NXT_LTR  @store LTR_TO_NXT_LTR in r1

    mul r1, r1, r4           @r1 = i * 56, to create offset from &hcode[0].letter to &hcode[i].letter, r4 <- i

    @ else-if (size != 1)  <- go to huffmanCode because its the huffman code being scanned
    cmp r5, #1               @compare size to 1
    bne huffmanCode          @branch to huffmanCode if not equal


    strb r0, [r7, r1]     @r7 is &hcode[0].letter, r1 is offset from &hcode[0].letter to &hcode[i].letter

    add r9, r7, r1        @store &hcode[i].letter in r9

    b doWhileLoop          @branch back to doWhileLoop

huffmanCode:              @ ****store the huffman code in hcode[i].code[0] to hcode[i].code[size]****
    @code is a member array of the struct element in the hcode array

    cmp r5, #3             @compare size to 3
    blt doWhileLoop        @branch to doWhileLoop if size < 3

    add r1, r9, #LTR_TO_CODE    @r1 = &hcode[i].code[0]
    sub r2, r5, #3         @r2 = size - 3, r2 contains j
    mov r3, #CODE_TO_CODE  @store CODE_TO_CODE in r3, CODE_TO_CODE is the offset from hcode[i].code[j] to hcode[i].code[j+1]
    mul r2, r2, r3         @multiply j * 4 and store into r2 to create an offset from &hcode[i].code[0] to &hcode[i].code[whatever r2 is]
    add r2, r2, r1         @add offset to r1 to go from &hcode[i].code[0] to &hcode[i].code[j]

    @r0 contains char c stored into memory

    sub r0, r0, #'0'       @gives either integer 1 if char c = '1' or integer 0 if char c = '0'
    str r0, [r2]           @store char c as int into hcode[i].code[size - 3]

    b doWhileLoop           @branch back to doWhileLoop

@loop to scan next line for next struct in the array of structs
endDoWhileLoop:

    add r1, r9, #LTR_TO_SIZE    @r1 = &hcode[i].size where LTR_TO_SIZE is distance from &hcode[i].letter to &hcode[i].size

    sub r2, r5, #2        @r2 = size - 2, r2 now contains length of huffman code bits
    str r2, [r1]          @store size - 2 into hcode[i].size

    add r4,r4,#1          @i++
    b whileLoop           @branch back to whileLoop

endFunction:
    add sp, sp, #4          @restore sp
    sub sp, fp, #4          @place sp at -8 on stack
    pop {fp, pc}            @pop fp and pc
