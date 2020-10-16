---
title: "SSH Through Websocket"
date: 2020-10-15T22:12:42+02:00
---

Have you ever been in a restricted corporate network where the only way to reach the internet is a dumb HTTP Proxy?
It sucks.
That's why i wrote [`webcat`](https://git.sr.ht/~rumpelsepp/webcat).
Webcat aims to be the swiss army knife for websocket connections as [`netcat`](https://man.openbsd.org/nc.1) is for plain TCP.
It does not aim to provide a shitload of features as [`websocat`](https://github.com/vi/websocat) does.

Basically, `webcat` does the same as `nc` does, but for websockets.
It can spawn a server, or act as a client.
Below are a few examples of how to use `webcat` to raise your attention.
In order to use `webcat` on a server, a reverse proxy like `nginx` or `caddy` with TLS is desired.
I will not go into the correct configuration of such a reverse proxy.

## SOCKS Tunnel via SSH

[`openssh`](https://man.openbsd.org/ssh) provides the `-D` flag.
With this flag, `openssh` connects to the remote host as usual, but additionally it spawns a local SOCKS server.
This SOCKS server can be used by arbitrary software[^1] to perform a dynamic port forwarding.
As the manpage explains it:

> Whenever a connection is made to this port, the connection is forwarded over the secure channel, and the application protocol is then used to determine where to connect to from the remote machine.

In other words you can access the internet through a SSH tunnel which is in a Websocket tunnel which goes over your fancy corporate shit proxy.
`-N` and `-T` is useful of you want to disable the pty and shell functionality for this ssh session.
In order to use the Websocket tunnel, `webcat` will be used via the `ProxyCommand` setting:

[^1]: Usually via the `all_proxy` environment variable.

First, a few preparations are required.
On the server webcat.example.org, `webcat` must be listening like this:

```
$ webcat -l 127.0.0.1:4444 -p /ssh -t 127.0.0.1:22
```

On a webserver like [`caddy`](https://caddyserver.com/) a config snippet like this is required:

```
reverse_proxy /ssh localhost:4444
```

nginx requires this:

```
location /ssh {
        proxy_pass http://127.0.0.1:4444;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_http_version 1.1;
}
```

Now the following forwarding on the server is established:

```
port 443 -> caddy <-> webcat <-> ssh port 22
```

Now this whole setup can be used like the following:

```
$ ssh -NT -D 127.0.0.1:1080 -o 'ProxyCommand=webcat -k 25 -t wss://webcat.example.org/ssh' user@example.org
```

Eventually, the internet can be accessed via example.org like this:

```
$ all_proxy=localhost:1080 curl https://google.de
```

## Reverse Tunnel via SSH

With the preparation from the previous example a reverse tunnel is straightforward.
A reverse tunnel has these three parties: Target (T), Server (S), and Initiator (I).
In this scenario, I wants to connect to T who is behind a corporate firewall, NAT, and a lot of virus scanners.
To solve this problem I jumps over S to T.
This solution works only, if T is connected to S and maintains this connection to be reachable.
Since the connection between S and T is also "secured" by a shitty HTTP proxy, it must be tunneled through `webcat`.
`webcat` understands any HTTP or SOCKS proxy configuration and uses it automatically.

### T <-> S

Let's do a reverse port forwarding with SSH through Websocket and expose this connection on a UNIX domain socket **on the server**.
It is a bit more secure to not open any ports on the server.

```
$ ssh -o 'ProxyCommand=./webcat -k 25 -t wss://webcat.example.org/ssh/' -TN -R "reverse.sock":localhost:22 user@example.org
```

### I <-> S

Thats easy.
Forward a local port (e.g. 2222) to the previously opened unix domain socket `reverse.sock`.
If a Websocket tunnel is desired, just set `ProxyCommand` as well.
I omit it here.

```
$ ssh -TN -L 2222:reverse.sock user@example.org
```

### I <-> T

Connect to the local port 2222 which:

* forwards to S
* is piped into `reverse.socks`
* which is connected to the reverse tunnel to T on port 22
* which goes through the `webcat` tunnel.

```
$ ssh -p 2222 user@localhost
```

The whole picture might be this:

```
      home network           |                internet                   |        super secure network
initiator <-> port 2222 <-> ssh <-> server S <-> reverse.socks <-> ssh through webcat <-> target <-> port 22
```

Happy tunneling.
I am not responsible for any data leaks you create with my software.
Use it at your own risk!

## Bonus Points

The `ProxyCommand` and many other settings can be put into `~/.ssh/config` and you can entirely forget about this.
Just read the wonderful [manpages](https://www.openssh.com/manual.html), e.g. [`ssh(1)`](https://man.openbsd.org/ssh) or [`ssh_config(5)`](https://man.openbsd.org/ssh_config).
