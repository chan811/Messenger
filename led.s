@Name: Chanly Ly
@Id: 011039168


.cpu cortex-a53
.fpu neon-fp-armv8

.data
fail: .asciz "setup wiringPi failed!\n"


.extern wiringPiSetup
.extern pinMode
.extern digitalWrite
.extern softPwmCreate
.extern softPwmWrite

.equ LED_PIN_RED, 0
.equ LED_PIN_GREEN, 1
.equ LED_PIN_BLUE, 2
.equ LEDPIN, 0
.equ OUTPUT, 1
.equ HIGH, 1
.equ LOW, 0

.text
.align 2
.global led
.type led, %function

led:
    push {fp, lr}       @push fp and lr on the stack
    add fp, sp, #4      @point fp to lr

    @r0 <- bit

    mov r4, r0      @store the bit in r4
    b testWiring    @branch to testWiring

testWiring:
    bl wiringPiSetup    @call wiringPiSetup() to test the wiring
    cmp r0, #-1         @checks what wiringPiSetup() returns
    beq printFail       @if -1 is returned then branch to printFail
    mov r0, #LEDPIN     @store LEDPIN in r0
    mov r1, #OUTPUT     @store OUTPUT in r1
    bl pinMode          @call pinMode()
    b ledInit           @branch to ledInit

printFail:
    ldr r0, =fail       @load fail string into r0
    bl printf           @call printf() to print the string
    b endFunction       @branch to endFunction

ledInit:
    mov r0, #LED_PIN_RED    @store LED_PIN_RED in r0
    mov r1, #0              @store 0 in r1
    mov r2, #100            @store 100 in r2
    bl softPwmCreate        @call softPwmCreate()
    mov r0, #LED_PIN_GREEN  @store LED_PIN_GREEN in r0
    mov r1, #0              @store 0 in r1
    mov r2, #100            @store 100 in r2
    bl softPwmCreate        @call softPwmCreate()
    mov r0, #LED_PIN_BLUE   @store LED_PIN_BLUE in r0
    mov r1, #0              @store 0 in r1
    mov r2, #100            @store 100 in r2
    bl softPwmCreate        @call softPwmCreate()
    b checkBit              @branch to checkBit

checkBit:
    cmp r4, #0              @compare bit to 0
    bne setGreen            @if bit != 0 branch to setGreen
    b setRed                @if bit == 0 branch to setRed

setRed:
    mov r0, #LEDPIN         @store LEDPIN in r0
    ldr r1, =LOW            @store LOW in r0
    bl digitalWrite         @call digitalWrite() to turn on led

    mov r0, #LED_PIN_RED    @store LED_PIN_RED in r0
    mov r1, #255            @store 255 in r1
    bl softPwmWrite         @call softPwmWrite() to set the value of red to 255
    mov r0, #LED_PIN_GREEN  @store LED_PIN_GREEN in r0
    mov r1, #0              @store 0 in r1
    bl softPwmWrite         @call softPwmWrite() to set the value of green to 0
    mov r0, #LED_PIN_BLUE   @store LED_PIN_BLUE in r0
    mov r1, #0              @store 0 in r1
    bl softPwmWrite         @call softPwmWrite() to set value of blue to 0
    mov r0, #500            @store 500 in r0
    bl delay                @call delay() to cause a delay before the next command
    b ledOff                @branch to ledOff

setGreen:
    mov r0, #LEDPIN         @store LEDPIN in r0
    ldr r1, =LOW            @store LOW in r0
    bl digitalWrite         @call digitalWrite() to turn on led

    mov r0, #LED_PIN_RED    @store LED_PIN_RED in r0
    mov r1, #0              @store 0 in r1
    bl softPwmWrite         @call softPwmWrite() to set value of red to 0
    mov r0, #LED_PIN_GREEN  @store LED_PIN_GREEN in r0
    mov r1, #255            @store 255 in r1
    bl softPwmWrite         @call softPwmWrite() to set value of green to 255
    mov r0, #LED_PIN_BLUE   @store LED_PIN_BLUE in r0
    mov r1, #0              @store 0 in r1
    bl softPwmWrite         @call softPwmWrite() to set value of blue to 0
    mov r0, #500            @store 500 in r0
    bl delay                @call delay() to cause a delay before the next command
    b ledOff                @branch to ledOff

ledOff:
    mov r0, #LEDPIN     @store LEDPIN in r0
    ldr r1, =HIGH       @store HIGH in r1
    bl digitalWrite     @call digitalWrite() to turn off led

    b endFunction       @branch to endFunction

endFunction:
    mov r0, r4          @return the value of bit
    sub sp, fp, #4      @place sp at -8 on stack
    pop {fp, lr}        @pop fp and lr off the stack
    bx lr               @return
