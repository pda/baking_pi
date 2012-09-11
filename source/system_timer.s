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
 * Output: Current 64 bit value of 1MHz counter.
 * r0: lo 32 bits
 * r1: hi 32 bits
 */
get_timestamp:
  push {lr}
  bl get_system_timer_address
  ldrd r0, r1, [r0, #4]
  pop {pc}


/**
 * Sleep for the microseconds specified in r0.
 */
microsleep:
  push {r4, r5, r6, lr}

  mov r6, r0
  duration .req r6

  /* derive time to sleep until */
  until_lo .req r4
  until_hi .req r5
  bl get_timestamp
  mov until_lo, r0
  mov until_hi, r1
  add until_lo, duration
  addcs until_hi, #1
  .unreq duration

  /* loop while now < until (64 bit comparison) */
  microsleep_loop$:
    now_lo .req r0
    now_hi .req r1
    bl get_timestamp
    cmp now_hi, until_hi
    cmpeq now_lo, until_lo  @ check lo if now_hi == until_hi
    blo microsleep_loop$   @ loop if now_hi < until_hi OR now < until

  .unreq until_lo
  .unreq until_hi
  .unreq now_lo
  .unreq now_hi

  pop {r4, r5, r6, pc}
