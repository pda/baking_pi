.section .init
.globl _start
_start:
b main

.section .text
main:
mov sp, #0x8000

/* Enable output to 16th GPIO pin. */
pin_num .req r0
pin_func .req r1
mov pin_num, #16
mov pin_func, #1  @ Use pin as output.
bl set_gpio_function
.unreq pin_num
.unreq pin_func

/* Flash OK light forever. */
flash_loop$:

  /* clear pin to turn light off */
  pin_num .req r0
  pin_val .req r1
  mov pin_num, #16
  mov pin_val, #0
  bl set_gpio
  .unreq pin_num
  .unreq pin_val

  bl sleep$

  /* set pin to turn light on */
  pin_num .req r0
  pin_val .req r1
  mov pin_num, #16
  mov pin_val, #1
  bl set_gpio
  .unreq pin_num
  .unreq pin_val

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
