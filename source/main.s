/**
 * .init
 */
.section .init
.globl _start
_start:
b main

/**
 * .text
 */
.section .text
main:
mov sp, #0x8000

/* Enable output to 16th GPIO pin. */
mov r0, #16  @ pin number
mov r1, #1  @ pin function: use pin for output
bl set_gpio_function

/* Wait a moment after bootloader flashes */
ldr r0, =500000  @ 500ms
bl microsleep

/* Flash OK light based on pattern. */
pattern .req r4
ldr pattern, =pattern_data  @ load address of data
ldr pattern, [pattern]  @ load actual data from address
sequence .req r5
mov sequence, #0
flash_loop$:
  mov r0, #16  @ pin number
  mov r1, #1  @ pin value read from pattern bitfield
  lsl r1, sequence
  and r1, pattern
  bl set_gpio

  ldr r0, =200000  @ 250ms
  bl microsleep

  add sequence, #1
  and sequence, #0b11111 @ mod 32
  b flash_loop$


/**
 * .data
 */
.section .data
.align 2

pattern_data:
.int 0b11111010101110001000100011101010
