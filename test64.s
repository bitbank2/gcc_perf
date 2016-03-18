//
// Performance tests to compare C, Intrinsics and optimized assembly language
// on 32 and 64-bit ARM platforms using GCC
//
// Written by Larry Bank
// Project started 3/16/2016

//
// 64-bit version
//
// AARCH64 calling convention
// X0-X7 arguments and return value
// X8 indirect result (struct) location
// X9-X15 temporary registers
// X16-X17 intro-call-use
// X18 Platform specific use
// X19-X28 callee-saved registers
// X29 frame pointer
// X30 link register (LR)
// X31 SP and zero (XZR)
// V0-V7, V16-V31 volatile
// V8-V15 callee-saved registers
//
  .align 2
  .global asm_float_sum
  .type asm_float_sum, %function
asm_float_sum:
// x0 = *in, x1 = *out, x2 = iLen
   mov x9,x2		// count
   mov x10,#15		// min loop count
   cmp x9,x10
   b.le float_sum_bot	// not enough to do as SIMD
float_sum_top:
   ld1 {v0.16b, v1.16b, v2.16b, v3.16b},[x0],#64 // read 16 floats from source pointer
   ld1 {v4.16b, v5.16b, v6.16b, v7.16b},[x1]
   sub x9,x9,#16
   fadd v0.4s, v0.4s, v4.4s
   fadd v1.4s, v1.4s, v5.4s
   fadd v2.4s, v2.4s, v6.4s
   fadd v3.4s, v3.4s, v7.4s
   cmp x9,x10
   st1 {v0.16b, v1.16b, v2.16b, v3.16b},[x1],#64
   b.gt float_sum_top
float_sum_bot:
// take care of straglers
   cmp x9,#0
   b.eq float_sum_exit
float_sum_bot2:
   ldr s3,[x0],#4
   ldr s4,[x1]
   subs x9,x9,#1
   fadd s3,s3,s4
   str s3,[x1],#4
   b.ne float_sum_bot2
float_sum_exit:
   mov x0,x2	// return with total count
   ret

  .align 2
  .global asm_integer_sum
  .type asm_integer_sum, %function
asm_integer_sum:
// x0 = *in, x1 = *out, x2 = iLen
   mov x9,x2		// count
   mov x10,#15		// min loop count
   cmp x9,x10
   b.le integer_sum_bot	// not enough to do as SIMD
integer_sum_top:
   ld1 {v0.16b, v1.16b, v2.16b, v3.16b},[x0],#64 // read 16 ints from source pointer
   ld1 {v4.16b, v5.16b, v6.16b, v7.16b},[x1]
   sub x9,x9,#16
   add v0.4s, v0.4s, v4.4s
   add v1.4s, v1.4s, v5.4s
   add v2.4s, v2.4s, v6.4s
   add v3.4s, v3.4s, v7.4s
   cmp x9,x10
   st1 {v0.16b, v1.16b, v2.16b, v3.16b},[x1],#64
   b.gt integer_sum_top
integer_sum_bot:
// take care of straglers
   cmp x9,#0
   b.eq integer_sum_exit
integer_sum_bot2:
   ldr w3,[x0],#4
   ldr w4,[x1]
   subs x9,x9,#1
   add w3,w3,w4
   str w3,[x1],#4
   b.ne integer_sum_bot2
integer_sum_exit:
   mov x0,x2	// return with total count
   ret

  .align 2
  .global asm_float_product
  .type asm_float_product, %function
asm_float_product:
   ret

  .align 2
  .global asm_integer_product
  .type asm_integer_product, %function
asm_integer_product:
   ret

  .align 2
  .global asm_integer_max
  .type asm_integer_max, %function
asm_integer_max:
   ld1 {v0.16b, v1.16b},[x0]
integer_max_top:
   ld1 {v2.16b, v3.16b},[x0]
   subs x2,x2,#8
   add x0,x0,#16
   smax v0.4s,v0.4s,v2.4s
   smax v1.4s,v1.4s,v3.4s
   b.ne integer_max_top
   smax v0.4s,v0.4s,v1.4s
   ext v1.16b,v0.16b,v0.16b,#8
   smax v0.4s,v0.4s,v0.4s
   ext v1.16b,v0.16b,v0.16b,#4
   smax v0.4s,v0.4s,v1.4s
   mov w0,v0.s[0]
   str w0,[x1]
   mov x0,#1
   ret

  .align 2
  .global asm_float_max
  .type asm_float_max, %function
asm_float_max:
   ld1 {v0.16b, v1.16b},[x0]
float_max_top:
   ld1 {v2.16b, v3.16b},[x0]
   subs x2,x2,#8
   add x0,x0,#16
   fmax v0.4s,v0.4s,v2.4s
   fmax v1.4s,v1.4s,v3.4s
   b.ne float_max_top
   fmax v0.4s,v0.4s,v1.4s
   ext v1.16b,v0.16b,v0.16b,#8
   fmax v0.4s,v0.4s,v0.4s
   ext v1.16b,v0.16b,v0.16b,#4
   fmax v0.4s,v0.4s,v1.4s
   mov w0,v0.s[0]
   str w0,[x1]
   mov x0,#1
   ret

  .align 2
  .global asm_integer_accumulate
  .type asm_integer_accumulate, %function
asm_integer_accumulate:
// x0 = *in, x1 = *out, x2 = iLen
   mov x9,x2		// count
   mov x10,#0
   dup v4.4s,w10	// sum = 0
   mov x10,#15		// min loop count
   cmp x9,x10
   b.le integer_acc_bot	// not enough to do as SIMD
integer_acc_top:
   ld1 {v0.16b, v1.16b, v2.16b, v3.16b},[x0],#64 // read 16 floats from source pointer
   sub x9,x9,#16
   add v4.4s, v4.4s, v0.4s
   add v4.4s, v4.4s, v1.4s
   cmp x9,x10
   add v4.4s, v4.4s, v2.4s
   add v4.4s, v4.4s, v3.4s
   b.gt integer_acc_top
integer_acc_bot:
   addp v4.4s,v4.4s,v4.4s
   addp v4.4s,v4.4s,v4.4s
   mov w4,v4.s[0]
// take care of straglers
   cmp x9,#0
   b.eq integer_acc_exit
integer_acc_bot2:
   ldr w3,[x0],#4
   subs x9,x9,#1
   add w4,w4,w3
   b.ne integer_acc_bot2
integer_acc_exit:
   str w4,[x1]
   mov x0,#1	// return with total count
   ret

  .align 2
  .global asm_float_accumulate
  .type asm_float_accumulate, %function
asm_float_accumulate:
// x0 = *in, x1 = *out, x2 = iLen
   mov x9,x2		// count
   mov x10,#0
   dup v4.4s,w10	// sum = 0
   mov x10,#15		// min loop count
   cmp x9,x10
   b.le float_acc_bot	// not enough to do as SIMD
float_acc_top:
   ld1 {v0.16b, v1.16b, v2.16b, v3.16b},[x0],#64 // read 16 floats from source pointer
   sub x9,x9,#16
   fadd v4.4s, v4.4s, v0.4s
   fadd v4.4s, v4.4s, v1.4s
   cmp x9,x10
   fadd v4.4s, v4.4s, v2.4s
   fadd v4.4s, v4.4s, v3.4s
   b.gt float_acc_top
float_acc_bot:
   faddp v4.4s,v4.4s,v4.4s
   faddp v4.4s,v4.4s,v4.4s
   mov s4,v4.s[0]
// take care of straglers
   cmp x9,#0
   b.eq float_acc_exit
float_acc_bot2:
   ldr s3,[x0],#4
   subs x9,x9,#1
   fadd s4,s4,s3
   b.ne float_acc_bot2
float_acc_exit:
   str s4,[x1]
   mov x0,#1	// return with total count
   ret

  .align 2
  .global asm_multiply_complex
  .type asm_multiply_complex, %function
asm_multiply_complex:
  add x4,x0,#32		// offset to grab 8 pairs of complex values
  add x5,x1,#32
  lsr x3,x2,#1		// number of complex values = floats/2
multiply_complex_top:
  ld2 {v0.4s,v1.4s},[x0]	// A0 separate the real/imaginary values
  ld2 {v2.4s,v3.4s},[x4]	// A1
//  pld [r0,#384]
  ld2 {v4.4s,v5.4s},[x1] // B0
  ld2 {v6.4s,v7.4s},[x5] // B1
  add x0,x0,#64
  fmul v16.4s,v0.4s,v4.4s	// c0_r = a[0].r * b[0].r
  fmul v17.4s,v1.4s,v4.4s	// c0_i = a[0].i * b[0].r
//  pld [r1,#384]
  fmls v16.4s,v1.4s,v5.4s  // c0_r -= (a[0].i * b[0].i)
  fmla v17.4s,v0.4s,v5.4s  // c0_i += (a[0].r * b[0].i)
  add x4,x4,#64
  fmul v18.4s,v2.4s,v6.4s    // c1_r = a[1].r * b[1].r
  fmul v19.4s,v3.4s,v6.4s    // c1_i = a[1].i * b[1].r
  subs x3,x3,#8		// number of complex values we processed
  fmls v18.4s,v3.4s,v7.4s // c1_r -= (a[i].i * b[1].i)
  fmla v19.4s,v2.4s,v7.4s // c1_i += (a[1].r * b[1].i)
  st2 {v16.4s,v17.4s},[x1]	 // store Complex 0
  st2 {v18.4s,v19.4s},[x5] // store Complex 1
  add x1,x1,#64
  add x5,x5,#64
  b.ne multiply_complex_top
  mov x0,x2	// number of floats to compare
   ret

  .align 2
  .global asm_integer_diff
  .type asm_integer_diff, %function
asm_integer_diff:
// x0 = *in, x1 = *out, x2 = iLen
   mov x9,x2		// count
   mov x10,#15		// min loop count
   cmp x9,x10
   b.le integer_diff_bot	// not enough to do as SIMD
integer_diff_top:
   ld1 {v0.16b, v1.16b, v2.16b, v3.16b},[x0],#64 // read 16 ints from source pointer
   ld1 {v4.16b, v5.16b, v6.16b, v7.16b},[x1]
   sub x9,x9,#16
   sub v0.4s, v0.4s, v4.4s
   sub v1.4s, v1.4s, v5.4s
   sub v2.4s, v2.4s, v6.4s
   sub v3.4s, v3.4s, v7.4s
   cmp x9,x10
   st1 {v0.16b, v1.16b, v2.16b, v3.16b},[x1],#64
   b.gt integer_diff_top
integer_diff_bot:
// take care of straglers
   cmp x9,#0
   b.eq integer_diff_exit
integer_diff_bot2:
   ldr w3,[x0],#4
   ldr w4,[x1]
   subs x9,x9,#1
   sub w3,w3,w4
   str w3,[x1],#4
   b.ne integer_diff_bot2
integer_diff_exit:
   mov x0,x2	// return with total count
   ret

  .align 2
  .global asm_float_diff
  .type asm_float_diff, %function
asm_float_diff:
// x0 = *in, x1 = *out, x2 = iLen
   mov x9,x2		// count
   mov x10,#15		// min loop count
   cmp x9,x10
   b.le float_diff_bot	// not enough to do as SIMD
float_diff_top:
   ld1 {v0.16b, v1.16b, v2.16b, v3.16b},[x0],#64 // read 16 floats from source pointer
   ld1 {v4.16b, v5.16b, v6.16b, v7.16b},[x1]
   sub x9,x9,#16
   fsub v0.4s, v0.4s, v4.4s
   fsub v1.4s, v1.4s, v5.4s
   fsub v2.4s, v2.4s, v6.4s
   fsub v3.4s, v3.4s, v7.4s
   cmp x9,x10
   st1 {v0.16b, v1.16b, v2.16b, v3.16b},[x1],#64
   b.gt float_diff_top
float_diff_bot:
// take care of straglers
   cmp x9,#0
   b.eq float_diff_exit
float_diff_bot2:
   ldr s3,[x0],#4
   ldr s4,[x1]
   subs x9,x9,#1
   fsub s3,s3,s4
   str s3,[x1],#4
   b.ne float_diff_bot2
float_diff_exit:
   mov x0,x2	// return with total count
   ret

  .end
