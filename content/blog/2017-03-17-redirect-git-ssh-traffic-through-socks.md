---
title: Redirect Git SSH Traffic through SOCKS
---

Today I had issues with establishing a connection to a Git server
through SSH. I found out, that it is possible to trick Git to use
a SOCKS proxy for SSH traffic. All you need to to is, setting
an environment variable:

```
$ export GIT_SSH_COMMAND='ssh -o ProxyCommand="netcat -X 5 -x SERVER:PORT %h %p"'
```

On debian the package `openbsd-netcat` is required, since the traditional
netcat does not support SOCKS.
