---
title: RISC-V Bare Metal Experiments
---

A wanted to do RISC-V experiments on bare metal for a long time.
I always failed due to the lack of tooling, "how to start" documentation, and my own laziness.
First some pointer what's RISC-V?
RISC-V is a free (as in free speech) instruction set architecture (ISA) which defines an assembly language and a lot more other stuff.
Any vendor can pick up the relevant documents to design and produce CPUs.
Since there is a working C compiler and all the tooling available, a RISC-V CPU can nowadays run a complete Linux distribution out of the box.
I hope it will replace the mess we are currently in with x86 and ARM…

I am (not yet) an expert in RISC-V assembler and the low level details of the code here.
But I hope I will understand all this in the future. :)
Anyway, I copy pasted a bare metal hello world program together and I want to share the code[^1] [^2].
The linker script had one problem which I fixed in my code; `lld` does not seem to support `(wxa!ri)`.
Thus I removed it.

[^1]: assembly code: https://theintobooks.wordpress.com/2019/12/28/hello-world-on-risc-v-with-qemu/
[^2]: linker script: https://github.com/michaeljclark/riscv-probe/blob/9f14353dd03af063c2bd93df5168964d77bbfa3a/env/qemu-sifive_u/default.lds

I use Arch Linux and these are the required packages: `qemu`, `qemu-extra-arch`, `clang`, `lld`, `make`.
No creepy third party software is required to run this.
My code is here: https://git.sr.ht/~rumpelsepp/riscv-experiments
It can be run like this:

```
$ make
clang -mno-relax --target=riscv32 -c -o main.o main.s
ld.lld -T link.lds -o main main.o
$ qemu-system-riscv32 -machine sifive_u -nographic -kernel main
qemu-system-riscv32: warning: No -bios option specified. Not loading a firmware.
qemu-system-riscv32: warning: This default will change in a future QEMU release. Please use the -bios option to avoid breakages when this happens.
qemu-system-riscv32: warning: See QEMU's deprecation documentation for details.
Hello
Hello
```

As I do not yet understand what's going on here, the post is finished.
But there is a minimal environment now to tinker with.
I hope this helps, have fun.
