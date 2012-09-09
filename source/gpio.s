.globl GetGpioAddress
.globl SetGpioFunction
.globl SetGpio

/**
 * Output:
 * r0: The address of the GPIO controller.
 */
GetGpioAddress:
  ldr r0, =0x20200000
  mov pc, lr


/**
 * Selects the function for the given pin number.
 * WARNING: currently zeroes out nearby pin functions.
 * Input:
 * r0: GPIO pin number, 0..53
 * r1: Pin function, 0..7
 */
SetGpioFunction:
  /* input validation */
  cmp r0, #53
  cmpls r1, #7  @ only if r0 <= 53
  movhi pc, lr  @ return if r0 > 53 or r1 > 7

  push {lr}  @ store return address.

  /* get GPIO address into r0 */
  mov r2, r0  @ Free up r0 for GetGpioAddress.
  bl GetGpioAddress

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
  pinMapLoop$:
    cmp r2, #9
    subhi r2, #10
    addhi r2, #4
    bhi pinMapLoop$

  /*
  state:
  r0: GPIO address shifted to the requested pin bank.
  r1: Pin function 0..7
  r2: GPIO pin number within the current bank.
  */

  add r2, r2, lsl #1  @ r2 *= 3 (implemented as r2 + r2 * 2)
  lsl r1, r2  @ Shift function value; 3 bits per pin.

  /*
  state:
  r0: GPIO address shifted to the requested pin bank.
  r1: Pin function within bank (multiplied by 3 bits per pin).
  r2: (defunct) GPIO pin number within the current bank.
  */

  /* Store computed function value at address in GPIO controller */
  @ TODO: only alter three bits, don't overwite other pin values.
  str r1, [r0]

  pop {pc}


/**
 * Set or clear GPIO pin output.
 */
SetGpio:
  pinNum .req r0
  pinVal .req r1

  /* input validation */
  cmp pinNum, #53
  movhi pc, lr  @ return if pinNum > 53

  push {lr}  @ store return address.

  /* get GPIO address into r0 */
  mov r2, pinNum
  .unreq pinNum
  pinNum .req r2
  bl GetGpioAddress
  gpioAddr .req r0

  /* set gpioAddr to bank for given pin */
  pinBank .req r3
  lsr pinBank, pinNum, #5  @ pinBank = pinNum / 32
  lsl pinBank, #2  @ pinBank *= 4 (bytes per bank)
  add gpioAddr, pinBank
  .unreq pinBank

  /* calculate setBit based on pinNum */
  and pinNum, #31  @ pin number relative to bank-shifted gpioAddr.
  setBit .req r3
  mov setBit, #1
  lsl setBit, pinNum
  .unreq pinNum

  teq pinVal, #0
  .unreq pinVal
  strne setBit, [gpioAddr, #28]  @ set pin output.
  streq setBit, [gpioAddr, #40]  @ clear pin output.

  .unreq setBit
  .unreq gpioAddr
  pop {pc}
