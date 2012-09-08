.section .init
.globl _start
_start:

ldr r0, =0x20200000  @ GPIO controller address

/* Enable output to 16th GPIO pin. */
mov r1, #1
lsl r1, #18  @ (see below)
str r1, [r0, #4]
/*
http://www.cl.cam.ac.uk/freshers/raspberrypi/tutorials/os/ok01.html
Since we want the 16th GPIO pin, we need the second set of 4 bytes because
we're dealing with pins 10-19, and we need the 6th set of 3 bits, which is
where the number 18 (6×3) comes from in the code above.
*/

/* Turn on OK light */
mov r1, #1
lsl r1, #16  @ 16th GPIO pin.
str r1, [r0, #40]  @ Turn pin off to turn light on.

/* The end. */
loop$: b loop$
