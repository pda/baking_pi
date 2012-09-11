.globl microsleep

/**
 * System timer.
 * Base address: 0x20003000
 * Addr Bytes  Name        Description                Read or Write
 * 00   4      Control     Control/clear comparitors. RW
 * 04   8      Counter     Increments at 1MHz.        R
 * 0C   4      Compare 0   0th Comparison register.   RW
 * 10   4      Compare 1   1st Comparison register.   RW
 * 14   4      Compare 2   2nd Comparison register.   RW
 * 18   4      Compare 3   3rd Comparison register.   RW
 */

/**
 * Output:
 * r0: The address of the system timer.
 */
get_system_timer_address:
  ldr r0, =0x20003000
  mov pc, lr


/**
 * Sleep for the microseconds specified in r0.
 */
microsleep:
  push {r4, r5, lr}

  mov r4, r0
  duration .req r4

  bl get_system_timer_address
  mov r5, r0
  timer_addr .req r5

  until_lo .req r0
  until_hi .req r1
  now_lo .req r2
  now_hi .req r3

  /* derive time to sleep until */
  ldrd until_lo, until_hi, [timer_addr, #4]
  add until_lo, duration
  addcs until_hi, #1
  .unreq duration

  /* loop while now < until */
  microsleep_loop$:
    ldrd now_lo, now_hi, [timer_addr, #4]
    @cmp now_hi, until_hi
    @cmpeq now_lo, until_lo  @ check lo if now_hi == until_hi
    cmp now_lo, until_lo  @ check lo if now_hi == until_hi
    blo microsleep_loop$   @ loop if now_hi < until_hi OR now < until

  .unreq timer_addr
  .unreq until_lo
  .unreq until_hi
  .unreq now_lo
  .unreq now_hi

  pop {r4, r5, pc}
