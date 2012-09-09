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
 */
SetGpioFunction:
  pinNum .req r0  @ 0..53
  pinFunc .req r1  @ 0..7

  /* input validation */
  cmp pinNum, #53
  cmpls pinFunc, #7
  movhi pc, lr  @ return if pinNum > 53 or pinFunc > 7

  push {lr}  @ store return address.

  /* get GPIO address into r0 */
  .unreq pinNum
  mov r2, r0  @ Free up r0 for GetGpioAddress.
  pinNum .req r2
  bl GetGpioAddress
  gpioAddr .req r0

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
    cmp pinNum, #9  @ while pinNum > 9
    subhi pinNum, #10  @ subract 10
    addhi gpioAddr, #4  @ and add 4 to gpioAddr
    bhi pinMapLoop$

  /*
  state:
  r0: GPIO address shifted to the requested pin bank.
  r1: Pin function 0..7
  r2: GPIO pin number within the current bank.
  */

  add pinNum, pinNum, lsl #1  @ pinNum *= 3 (implemented as pinNum + pinNum * 2)
  lsl pinFunc, pinNum  @ Shift function value; 3 bits per pin.
  .unreq pinNum

  /*
  state:
  r0: GPIO address shifted to the requested pin bank.
  r1: Pin function within bank (multiplied by 3 bits per pin).
  r2: (defunct) GPIO pin number within the current bank.
  */

  /* Store computed function value at address in GPIO controller */
  @ TODO: only alter three bits, don't overwite other pin values.
  str pinFunc, [gpioAddr]

  .unreq pinFunc
  .unreq gpioAddr
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
