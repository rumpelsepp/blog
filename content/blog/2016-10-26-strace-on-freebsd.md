---
title: strace on FreeBSD -> truss
---

This is just a short post, more of a reminder for myself. If one searches
[`strace`](http://man7.org/linux/man-pages/man1/strace.1.html) for FreeBSD, he
might not be successful as there is no `strace` for FreeBSD. **BUT** there is
[`truss`](https://www.freebsd.org/cgi/man.cgi?query=truss&manpath=FreeBSD+11.0-RELEASE+and+Ports),
which does pretty much the same as `strace`; `truss` is part of the base system
and can be used for the same purpose as `strace`.
