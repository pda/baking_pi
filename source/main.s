.section .init
.globl _start
_start:
b main

.section .text
.globl flash_once
main:
mov sp, #0x8000

/* Enable output to 16th GPIO pin. */
mov r0, #16  @ pin number
mov r1, #1  @ pin function: use pin for output
bl set_gpio_function

/* Flash OK light forever. */
flash_loop$:
  bl flash_once
  b flash_loop$

/* The end. */
end$: b end$

flash_once:
  push {lr}

  mov r0, #16  @ pin number
  mov r1, #0  @ pin value: clear pin to turn light on
  bl set_gpio

  ldr r0, =100000
  bl microsleep

  mov r0, #16  @ pin number
  mov r1, #1  @ pin value: set pin to turn light off
  bl set_gpio

  ldr r0, =900000
  bl microsleep

  pop {pc}
