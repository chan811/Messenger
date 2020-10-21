@Name: Chanly Ly
@Id: 011039168


.cpu cortex-a53
.fpu neon-fp-armv8

.data
.text
.align 2
.global check_space
.type check_space, %function

check_space:
    push {fp, lr}           @push lr and fp onto the stack
    add fp, sp, #4          @point fp to lr

    @r0 containts 32-int unsigned

    AND r1, r0, #0xF0000000    @extract the first 4 digits of the integer by AND with 1111 0..0 <-28 zeroes
    cmp r1, #0                 @if r1 is 0 then the first 4 digits are all zero in the integer which means there is a space
    bne endFunction            @branch to endFunction if not equal, to return 0 if not a space

    @ Returns 2 if ' ' is the first char in the packet
    mov r0, #2                 @else if r1 is zero there is a space, so return 2
    sub sp, fp, #4             @place sp at -8 on stack
    pop {fp, pc}               @pop fp and pc

endFunction:

    @ Returns 0 if ' ' is not the first char in the packet
    mov r0, #0              @return 0 if there is not a space as the first char
    sub sp, fp, #4          @place sp at -8 on stack
    pop {fp, pc}            @pop fp and pc

