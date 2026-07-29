;need a tiny assembly file whose only job is to be the physical first bytes of the kernel, acting as an anchor that safely calls your C function.

bits 32
[extern main] ;main is defined in kernel.c
call main ;CPU lands here, and we safely call the C function
jmp $ ;infinite loop to prevent the CPU from executing random instructions after main returns