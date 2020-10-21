@Name: Chanly Ly
@Id: 011039168



.cpu cortex-a53
.fpu neon-fp-armv8
.data

.equ LTR_TO_NXT_LTR, 56       @memory distance from &hcode[i].letter to & hcode[i + 1].letter

.extern count_spaces
.extern search_hcode
.extern led

.text
.align 2
.global decoder
.type decoder, %function

decoder:
    push {fp, lr}       @push fp and lr onto the stack
    add fp, sp, #4      @point fp to lr


    @r0 contains the encoded int packet
    @r1 contains &hcode[]
    @r2 contains &current_char
    @r3 contains &d_message[]

    mov r4, r0            @save encoded int packet in r4
    mov r5, r1            @save &hcode[] in r5
    mov r6, r2            @save &current_char in r6
    mov r7, r3            @save &d_message[] in r7
    mov r8, #0            @store 0 in r8, r8 contains current_int
    mov r9, #0            @store 0 in r9, r9 contains numBitsAdded
    mov r3, #0            @store 0 in r3, r3 contains sum of all matching code sizes initialized to 0

    mov r0, #23           @store 23 in r0
    str r0, [sp, #-4]!    @initialize previousChar to not letter and store into stack memory

    mov r10, #32          @store 32 in r10, r10 contains numBitsToExamine

    mov r0, r4            @store encoded int in r0
    bl check_space        @call check_space() to check for spaces in the encoded int

    cmp r0, #0            @compare the value returned by check_space() to 0
    beq whileLoop         @branch to whileLoop if check_space() returned 0

    cmp r0, #2            @compare the value returned by check_space() to 2
    moveq r4, r4, LSL #4  @shift digits over by 4
    ldreq r1, [r6]        @get index value in &current_char and store into r1
    addeq r1, r1, #1      @increase the index
    streq r1, [r6]        @store index back into &current_char


whileLoop:
    @convert int array => unsigned int
    cmp r10, #0                @compare numBitsToExamine to 0
    beq endFunction            @branch to endFunction if numBitsToExamine == 0

    mov r0, #1                 @store 1 in r0
    sub r2, r10, #1            @r2 = numBitsToExamine--
    mov r0, r0, LSL r2         @shift #1 to the same position as the bit to be examined in the integer packet
    AND r0, r0, r4             @r0 = encoded integer packet with just the bit being examined with the rest of the bits as zeroes



    cmp r3, #0                 @compare sum of all matching code sizes to 0
    movne r0, r0, LSL r3       @r0 = current_int with all bits shifted to the left

    bl led                     @call led() to blink an led on the breadboard

    ORR r8, r8, r0             @updates r8, current_int to include the next bit in encodedInt to be examined
    add r9, r9, #1             @numBitsAdded++

    str r9, [sp, #-4]!         @store numBitsAdded on the stack

    mov r2, r9                 @store numBitsAdded in r2
    mov r0, r5                 @store &hcode[i] in r0
    mov r1, r8                 @store current_int in r1
    bl search_hcode            @call search_hcode() to search the huffman code



    ldr r9, [sp], #4          @load numBitsAdded in r9

    cmp r0, #29               @branch to not char if there is not an equivalent char represented as a huffman code in the hcode[] array
    movlt r1, r9              @copy numBitsAdded to r3
    addlt r3, r3, r1          @r3 = sum of all matching code sizes
    bge not_found             @branch to not_found if

    ldr r1, [r6]              @get index value for d_message and store into r1

    mov r2, #LTR_TO_NXT_LTR   @store LTR_TO_NXT_LTR in r2
    mul r2, r2, r0            @r2 = 56 * hcodeIndex
    ldrb r2, [r5, r2]         @r2 = hcode[i].letter

    ldrb r0, [sp]             @load previousChar into r0

    cmp r2, #32               @compare current_char to ' ' <-- 32
    bne skip1                 @branch to skip1 if current_char != ' '

    cmp r0, #32               @compare previousChar to ' ' <-- 32
    bne skip1                 @branch to skip1 if previousChar != ' '

    cmp r2, r0                @compare current_char and previousChar, if both are char ' '
    subeq r1, r1, #1          @if == then decrement d_message[] index
    streq r1, [r6]            @store the decremented index back into &current_char
    beq endFunction           @branch to endFunction if current_char == previous_char

skip1:

    cmp r2, #32               @compare current_char to ' ' <-- 32
    bne skip2                 @branch to skip2 if current_char is not equal to ' '

    cmp r10, #2               @compares numBitsToExamine to 2
    ble endFunction           @branch to endFunction if numBitsToExamine <= 2

skip2:
    strb r2, [sp]             @r2 = hcode[i].letter

    strb r2, [r7, r1]         @d_message[index] = hcode[i].letter


    add r1, r1, #1            @increase index
    str r1, [r6]              @store index back into &current_char

    sub r10, r10, #1          @numBitsToExamine--

    mov r8, #0                @reset current_intto 0
    mov r9, #0                @reset numBitsAdded to 0
    b whileLoop             @branch back to whileLoop

not_found:
    sub r10, r10, #1          @numBitsToExamine--;
    b whileLoop             @branch back to whileLoop


endFunction:
    sub sp, fp, #4         @place sp at -8 on stack
    pop {fp, pc}           @pop fp and pc
