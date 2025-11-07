//
// Performance tests to compare C, Intrinsics and optimized assembly language
// on 32 and 64-bit ARM platforms using GCC
//
// Written by Larry Bank
// Project started 3/16/2016

//
// 32-bit version
//

   .global asm_integer_sum
   .global asm_float_sum
   .global asm_integer_diff
   .global asm_float_diff
   .global asm_integer_max
   .global asm_float_max
   .global asm_integer_accumulate
   .global asm_float_accumulate
   .global asm_multiply_complex

 .text
 .align 2

// call from C as asm_integer_sum(int32_t *s, int32_t *d, int n)
asm_integer_sum:
  stmfd sp!,{r4-r6}
  mov r6,#16		// offset for VLD/VST
  add r4,r0,r6		// needed for missing addressing mode of NEON
  add r5,r1,r6
  mov r3,r2		// original count
  cmp r3,#7
  ble integer_sum_bot	// not enough to do as SIMD
integer_sum_top:
  vld1.s32 {q0},[r0]
  vld1.s32 {q1},[r4]
  add r0,r0,#32
  add r4,r4,#32
  vld1.s32 {q2},[r1]
  pld [r0,#384]
  vld1.s32 {q3},[r5]
  sub r3,r3,#8
  vadd.s32 q0,q0,q2
  pld [r1,#384]
  vadd.s32 q1,q1,q3
  cmp r3,#7
  vst1.s32 {q0},[r1]
  vst1.s32 {q1},[r5]
  add r1,r1,#32
  add r5,r5,#32
  bgt integer_sum_top
integer_sum_bot:
  cmp r3,#0
  beq integer_sum_exit
integer_sum_bot2:
// take care of stragglers
  ldr r4,[r0]!
  ldr r5,[r1]
  subs r3,r3,#1
  add r4,r4,r5
  str r4,[r1]!
  bne integer_sum_bot2
integer_sum_exit:
  mov r0,r2	// return with count
  ldmlefd sp!,{r4-r6}
  bx lr

asm_float_sum:
  stmfd sp!,{r4-r6}
  mov r6,#16		// offset for VLD/VST
  add r4,r0,r6		// needed for missing addressing mode of NEON
  add r5,r1,r6
  mov r3,r2		// original count
  cmp r3,#7
  ble float_sum_bot	// not enough to do as SIMD
float_sum_top:
  vld1.f32 {q0},[r0]
  vld1.f32 {q1},[r4]
  add r0,r0,#32
  add r4,r4,#32
  vld1.f32 {q2},[r1]
  vld1.f32 {q3},[r5]
  sub r3,r3,#8
  vadd.f32 q0,q0,q2
  pld [r0,#384]
  vadd.f32 q1,q1,q3
  cmp r3,#7
  vst1.f32 {q0},[r1]
  pld [r1,#384]
  vst1.f32 {q1},[r5]
  add r1,r1,#32
  add r5,r5,#32
  bgt float_sum_top
float_sum_bot:
  cmp r3,#0
  beq float_sum_exit
float_sum_bot2:
// take care of stragglers
  vldr s0,[r0]
  vldr s1,[r1]
  add r0,r0,#4
  subs r3,r3,#1
  vadd.f32 s0,s0,s1
  vstr s0,[r1]
  add r1,r1,#4
  bne float_sum_bot2
float_sum_exit:
  mov r0,r2	// return with count
  ldmlefd sp!,{r4-r6}
  bx lr

// call from C as asm_integer_diff(int32_t *s, int32_t *d, int n)
asm_integer_diff:
  stmfd sp!,{r4-r6}
  mov r6,#16		// offset for VLD/VST
  add r4,r0,r6		// needed for missing addressing mode of NEON
  add r5,r1,r6
  mov r3,r2		// original count
  cmp r3,#7
  ble integer_diff_bot	// not enough to do as SIMD
integer_diff_top:
  vld1.s32 {q0},[r0]
  pld [r0,#384]
  vld1.s32 {q1},[r4]
  add r0,r0,#32
  add r4,r4,#32
  vld1.s32 {q2},[r1]
  pld [r1,#384]
  vld1.s32 {q3},[r5]
  sub r3,r3,#8
  vsub.s32 q0,q0,q2
  vsub.s32 q1,q1,q3
  cmp r3,#7
  vst1.s32 {q0},[r1]
  vst1.s32 {q1},[r5]
  add r1,r1,#32
  add r5,r5,#32
  bgt integer_diff_top
integer_diff_bot:
  cmp r3,#0
  beq integer_diff_exit
integer_diff_bot2:
// take care of stragglers
  ldr r4,[r0]!
  ldr r5,[r1]
  subs r3,r3,#1
  sub r4,r4,r5
  str r4,[r1]!
  bne integer_diff_bot2
integer_diff_exit:
  mov r0,r2	// return with count
  ldmlefd sp!,{r4-r6}
  bx lr

asm_float_diff:
  stmfd sp!,{r4-r6}
  mov r6,#16		// offset for VLD/VST
  add r4,r0,r6		// needed for missing addressing mode of NEON
  add r5,r1,r6
  mov r3,r2		// original count
  cmp r3,#7
  ble float_diff_bot	// not enough to do as SIMD
float_diff_top:
  vld1.f32 {q0},[r0]
  pld [r0,#384]
  vld1.f32 {q1},[r4]
  add r0,r0,#32
  add r4,r4,#32
  vld1.f32 {q2},[r1]
  pld [r1,#384]
  vld1.f32 {q3},[r5]
  sub r3,r3,#8
  vsub.f32 q0,q0,q2
  vsub.f32 q1,q1,q3
  cmp r3,#7
  vst1.f32 {q0},[r1]
  vst1.f32 {q1},[r5]
  add r1,r1,#32
  add r5,r5,#32
  bgt float_diff_top
float_diff_bot:
  cmp r3,#0
  beq float_diff_exit
float_diff_bot2:
// take care of stragglers
  vldr s0,[r0]
  vldr s1,[r1]
  add r0,r0,#4
  subs r3,r3,#1
  vsub.f32 s0,s0,s1
  vstr s0,[r1]
  add r1,r1,#4
  bne float_diff_bot2
float_diff_exit:
  mov r0,r2	// return with count
  ldmlefd sp!,{r4-r6}
  bx lr

asm_integer_max:
  vld1.s32 {q0,q1},[r0]
integer_max_top:
  vld1.s32 {q2,q3},[r0]!
  subs r2,r2,#8
  vmax.s32 q0,q0,q2
  pld [r0,#384]
  vmax.s32 q1,q1,q3
  bne integer_max_top
  vmax.s32 q0,q0,q1
  vmax.s32 d0,d0,d1
  vext.s32 d1,d0,d0,#1	// compare bottom 2
  vmax.s32 d0,d0,d1
  vmov.s32 r0,d0[0]
  str r0,[r1]
  mov r0,#1
  bx lr

asm_float_max:
  vld1.f32 {q0,q1},[r0]
float_max_top:
  vld1.f32 {q2,q3},[r0]!
  subs r2,r2,#8
  vmax.f32 q0,q0,q2
  pld [r0,#384]
  vmax.f32 q1,q1,q3
  bne float_max_top
  vmax.f32 q0,q0,q1
  vmax.f32 d0,d0,d1
  vext.f32 d1,d0,d0,#1	// compare bottom 2
  vmax.f32 d0,d0,d1
  vmov.f32 r0,d0[0]
  str r0,[r1]
  mov r0,#1
  bx lr

asm_integer_accumulate:
  stmfd sp!,{r4-r5}
  add r4,r0,#16		// needed for missing addressing mode of NEON
  mov r5,#0		// offset for VLD/VST
  vdup.s32 q2,r5
  vdup.s32 q3,r5
  mov r3,r2		// original count
  cmp r3,#7
  ble integer_accumulate_bot	// not enough to do as SIMD
integer_accumulate_top:
  vld1.s32 {q0},[r0]
  vld1.s32 {q1},[r4]
  add r0,r0,#32
  add r4,r4,#32
  sub r3,r3,#8
  vadd.s32 q2,q2,q0
  vadd.s32 q3,q3,q1
  cmp r3,#7
  bgt integer_accumulate_top
integer_accumulate_bot:
  vadd.s32 q0,q2,q3
  vadd.s32 d0,d0,d1
  vext.s32 d1,d0,d0,#1
  vadd.s32 d0,d0,d1
  vmov.s32 r4,d0[0]
  cmp r3,#0
  beq integer_accumulate_exit
integer_accumulate_bot2:
// take care of stragglers
  ldr r5,[r0]!
  subs r3,r3,#1
  add r4,r4,r5
  bne integer_accumulate_bot2
integer_accumulate_exit:
  str r4,[r1]
  mov r0,#1	// return with count
  ldmlefd sp!,{r4-r5}
  bx lr

asm_float_accumulate:
  stmfd sp!,{r4-r5}
  add r4,r0,#16		// needed for missing addressing mode of NEON
  mov r5,#0
  vdup.f32 q2,r5
  vdup.f32 q3,r5
  mov r3,r2		// original count
  cmp r3,#7
  ble float_accumulate_bot	// not enough to do as SIMD
float_accumulate_top:
  vld1.f32 {q0},[r0]
  vld1.f32 {q1},[r4]
  add r0,r0,#32
  add r4,r4,#32
  sub r3,r3,#8
  vadd.f32 q2,q2,q0
  vadd.f32 q3,q3,q1
  cmp r3,#7
  bgt float_accumulate_top
float_accumulate_bot:
  vadd.f32 q0,q2,q3
  vadd.f32 d0,d0,d1
  vext.f32 d1,d0,d0,#1
  vadd.f32 d0,d0,d1
  cmp r3,#0
  beq float_accumulate_exit
float_accumulate_bot2:
// take care of stragglers
  vldr s1,[r0]
  subs r3,r3,#1
  vadd.f32 s0,s0,s1
  bne float_sum_bot2
float_accumulate_exit:
  vstr s0,[r1]
  mov r0,#1	// return with count
  ldmlefd sp!,{r4-r5}
  bx lr

asm_multiply_complex:
  vpush {q4-q7}
  push {r4-r7}
  add r4,r0,#32		// offset to grab 8 pairs of complex values
  add r5,r1,#32
  mov r3,r2,LSR #1	// number of complex values = floats/2
multiply_complex_top:
  vld2.f32 {q0,q1},[r0]	// A0 separate the real/imaginary values
  vld2.f32 {q2,q3},[r4] // A1
  pld [r0,#384]
  vld2.f32 {q4,q5},[r1] // B0
  vld2.f32 {q6,q7},[r5] // B1
  add r0,r0,#64
  vmul.f32 q8,q0,q4	// c0_r = a[0].r * b[0].r
  vmul.f32 q9,q1,q4	// c0_i = a[0].i * b[0].r
  pld [r1,#384]
  vmls.f32 q8,q1,q5  // c0_r -= (a[0].i * b[0].i)
  vmla.f32 q9,q0,q5  // c0_i += (a[0].r * b[0].i)
  add r4,r4,#64
  vmul.f32 q10,q2,q6    // c1_r = a[1].r * b[1].r
  vmul.f32 q11,q3,q6    // c1_i = a[1].i * b[1].r
  subs r3,r3,#8		// number of complex values we processed
  vmls.f32 q10,q3,q7 // c1_r -= (a[i].i * b[1].i)
  vmla.f32 q11,q2,q7 // c1_i += (a[1].r * b[1].i)
  vst2.f32 {q8,q9},[r1]	 // store Complex 0
  vst2.f32 {q10,q11},[r5] // store Complex 1
  add r1,r1,#64
  add r5,r5,#64
  bne multiply_complex_top
  pop {r4-r7}
  vpop {q4-q7}
  mov r0,r2	// number of floats to compare
  bx lr

  .end
