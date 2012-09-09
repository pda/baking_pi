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

/* Flash OK light forever. */
mov r1, #1
lsl r1, #16  @ 16th GPIO pin.
flash_loop$:
  str r1, [r0, #40]  @ Turn pin off to turn light on.
  bl sleep$
  str r1, [r0, #28]  @ Turn pin on to turn light off.
  bl sleep$
  b flash_loop$  @ repeat.

/* The end. */
end$: b end$

/* sleep for 2^20 iterations */
sleep$:
  mov r2, #1
  lsl r2, #20
  sleep_loop$:
  sub r2, #1
  cmp r2, #0
  bne sleep_loop$
  mov pc, lr
