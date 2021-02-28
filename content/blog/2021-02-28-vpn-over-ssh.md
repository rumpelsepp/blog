---
title: "VPN over SSH"
date: 2021-02-28T18:42:39+01:00
---

SSH is an awesome protocol and it can do a lot of [things](https://rumpelsepp.org/blog/ssh-through-websocket/).
I found out that OpenSSH has native [TUN device support](https://man.openbsd.org/OpenBSD-current/man5/ssh_config.5#Tunnel).
Unfortunately I was not able to set this up properly.
On my Linux boxes this failed with interesting errors.
I ended up using `strace` to find out that there is some permission idiosyncracy.

As I love using pipes in my terminal, I had an idea.
What about using [`socat`](http://www.dest-unreach.org/socat/) and piping IP traffic through the SSH tunnel?
tldr; it works.

```
$ sudo socat TUN:192.168.255.1/24,up EXEC:'ssh -l root HOST "socat TUN:192.168.255.2/24,up"'
```

Let's break this monster down.

`socat` allocates two entities and connects them via a bidirectional channel (e.g. two pipes for stdin and stdout respectively).
Let's have a look at the "ADDRESS TYPES" section in the manpage here: [`socat(1)`](http://www.dest-unreach.org/socat/doc/socat.html).
Any of these address types can be used.
So let's create a TCP listener and print everything to the terminal.

```
$ socat TCP-LISTEN:1234 -
```

This command creates a TCP listener at port 1234 and connects it to stdin/stdout of the socat process.
Eventually, this is a stupid replacement of `nc -l -p 1234`.

One step further, `socat` let's us create arbitrary processes and pipe data into them.
With the TCP listener example we can pipe data from the network in a subprocess like `grep`[^1].

```
$ socat -u TCP-LISTEN:1234 EXEC:'grep foo' &
$ echo "foobar" | nc 127.0.0.1 1234
```

[^1]: Using unidirectional mode with `-u` to avoid blocking.

The VPN stuff works like the very same.
So, let's start slowly[^2]:

[^2]: `sudo` is needed to allocate a TUN device. There are tricks to do this as a usual user, but I am too lazy to find out…

```
$ sudo socat TUN:192.168.255.1/24,up - | hexdump
```

This command allocates a TUN device, assings the ip address `192.168.255.1`, sets the device into the `up` state (= enables it), and relays everything to the terminal into `hexdump`.
When you ping the subnet via `ping 192.168.255.2` then the IP packets show up.
So now, let's send this data over an SSH tunnel.

`ssh` is awesome as it provides a bidirectional connection (via two pipes) to a remote process.
Everything which is written to `ssh`'s stdin is written to the remote process' stdin tunneled via the SSH connection!
Well, let's spawn a `socat` an the remote side as well:

```
$ sudo socat TUN:192.168.255.1/24,up EXEC:'ssh -l root HOST "socat TUN:192.168.255.2/24,up"'
```

The right argument (`EXEC:"…"`) spaws `ssh` logs into `HOST` and starts a `socat` which is connected to a tunnel device.
The remote `socat` needs to write everything to `-` (stdio) because `-` is connected to the SSH tunnel.
It works!
The only problem left is that `root` is needed on both sides.
But this can be solved somehow…
