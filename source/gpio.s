.globl get_gpio_address
.globl set_gpio_function
.globl set_gpio

/**
 * Output:
 * r0: The address of the GPIO controller.
 */
get_gpio_address:
  ldr r0, =0x20200000
  mov pc, lr


/**
 * Selects the function for the given pin number.
 * WARNING: currently zeroes out nearby pin functions.
 */
set_gpio_function:
  pin_num .req r0  @ 0..53
  pin_func .req r1  @ 0..7

  /* input validation */
  cmp pin_num, #53
  cmpls pin_func, #7
  movhi pc, lr  @ return if pin_num > 53 or pin_func > 7

  push {lr}  @ store return address.

  /* get GPIO address into r0 */
  .unreq pin_num
  mov r2, r0  @ Free up r0 for get_gpio_address.
  pin_num .req r2
  bl get_gpio_address
  gpio_addr .req r0

  /*
  state:
  r0: GPIO address
  r1: Pin function 0..7
  r2: GPIO pin number
  */

  /*
  GPIO functions are stored in blocks of 10. First determine which block of ten
  our pin number is in.  If pin number is higher than 9, subtract 10 from pin
  number, adds 4 to GPIO Controller address.
  */
  pin_map_loop$:
    cmp pin_num, #9  @ while pin_num > 9
    subhi pin_num, #10  @ subract 10
    addhi gpio_addr, #4  @ and add 4 to gpio_addr
    bhi pin_map_loop$

  /*
  state:
  r0: GPIO address shifted to the requested pin bank.
  r1: Pin function 0..7
  r2: GPIO pin number within the current bank.
  */

  add pin_num, pin_num, lsl #1  @ pin_num *= 3 (implemented as pin_num + pin_num * 2)
  lsl pin_func, pin_num  @ Shift function value; 3 bits per pin.
  .unreq pin_num

  /*
  state:
  r0: GPIO address shifted to the requested pin bank.
  r1: Pin function within bank (multiplied by 3 bits per pin).
  r2: (defunct) GPIO pin number within the current bank.
  */

  /* Store computed function value at address in GPIO controller */
  @ TODO: only alter three bits, don't overwite other pin values.
  str pin_func, [gpio_addr]

  .unreq pin_func
  .unreq gpio_addr
  pop {pc}


/**
 * Set or clear GPIO pin output.
 */
set_gpio:
  pin_num .req r0
  pin_val .req r1

  /* input validation */
  cmp pin_num, #53
  movhi pc, lr  @ return if pin_num > 53

  push {lr}  @ store return address.

  /* get GPIO address into r0 */
  mov r2, pin_num
  .unreq pin_num
  pin_num .req r2
  bl get_gpio_address
  gpio_addr .req r0

  /* set gpio_addr to bank for given pin */
  pin_bank .req r3
  lsr pin_bank, pin_num, #5  @ pin_bank = pin_num / 32
  lsl pin_bank, #2  @ pin_bank *= 4 (bytes per bank)
  add gpio_addr, pin_bank
  .unreq pin_bank

  /* calculate set_bit based on pin_num */
  and pin_num, #31  @ pin number relative to bank-shifted gpio_addr.
  set_bit .req r3
  mov set_bit, #1
  lsl set_bit, pin_num
  .unreq pin_num

  teq pin_val, #0
  .unreq pin_val
  strne set_bit, [gpio_addr, #28]  @ set pin output.
  streq set_bit, [gpio_addr, #40]  @ clear pin output.

  .unreq set_bit
  .unreq gpio_addr
  pop {pc}
