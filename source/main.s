.section .init
.globl _start
_start:
b main

.section .text
main:
mov sp, #0x8000

/* Enable output to 16th GPIO pin. */
mov r0, #16  @ pin number
mov r1, #1  @ pin function: use pin for output
bl set_gpio_function

/* Flash OK light forever. */
flash_loop$:

  mov r0, #16  @ pin number
  mov r1, #0  @ pin value: clear pin to turn light on
  bl set_gpio

  bl sleep$

  mov r0, #16  @ pin number
  mov r1, #1  @ pin value: set pin to turn light off
  bl set_gpio

  bl sleep$

  /* repeat forever */
  b flash_loop$

/* The end. */
end$: b end$

/* sleep for 2 million iterations */
sleep$:
  ldr r0, =2000000
  sleep_loop$:
    sub r0, #1
    teq r0, #0
    bne sleep_loop$
  mov pc, lr
