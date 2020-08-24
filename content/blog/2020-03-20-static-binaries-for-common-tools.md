---
title: Static Binaries for Common Tools
---

Heya!
I often need some common tools (e.g. `strace`, `tcpdump`, …) on obscure embedded devices which do not offer a package manager.
Being tired with fighting dependencies and read only root file systems I created [binaries](http://rumpelsepp.org/binaries/)!
I wrote a small script which downloads [buildroot](https://buildroot.org/), builds it with a predefined config, and pushes the result to my server.
The results are statically linked using the musl C-library and the binaries run standalone without dependencies.
The sources are here: https://git.sr.ht/~rumpelsepp/binaries

Currently only x86\_64 is built, but I want to support more architectures making this thing usable for people.
I hope Drew is ok with buildroot causing load every now and then on builds.sr.ht…

Let's test it:

```
$ file buildroot-2020.02/output/target/usr/bin/strace
buildroot-2020.02/output/target/usr/bin/strace: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, with debug_info, not stripped
$ ldd buildroot-2020.02/output/target/usr/bin/strace
        not a dynamic executable
```
