.section .init
.globl _start
_start:
b main

.section .text
main:
mov sp, #0x8000

/* Enable output to 16th GPIO pin. */
pinNum .req r0
pinFunc .req r1
mov pinNum, #16
mov pinFunc, #1  @ Use pin as output.
bl SetGpioFunction
.unreq pinNum
.unreq pinFunc

/* Flash OK light forever. */
flash_loop$:

  /* clear pin to turn light off */
  pinNum .req r0
  pinVal .req r1
  mov pinNum, #16
  mov pinVal, #0
  bl SetGpio
  .unreq pinNum
  .unreq pinVal

  bl sleep$

  /* set pin to turn light on */
  pinNum .req r0
  pinVal .req r1
  mov pinNum, #16
  mov pinVal, #1
  bl SetGpio
  .unreq pinNum
  .unreq pinVal

  bl sleep$

  /* repeat forever */
  b flash_loop$

/* The end. */
end$: b end$

/* sleep for 2^20 iterations */
sleep$:
  mov r2, #1
  lsl r2, #20
  sleep_loop$:
  sub r2, #1
  cmp r2, #0  @ TODO: use teq, not cmp
  bne sleep_loop$
  mov pc, lr
