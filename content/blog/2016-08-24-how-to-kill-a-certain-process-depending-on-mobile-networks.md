---
title: How to kill a certain process depending on mobile networks?
---

I am often on mobile networks because I use the public transport in Munich
every day. So, I am  two times one hour in a hot and ugly train doing...
nothing. Or no, wait, I have my laptop! Ok, I am doing some strange stuff like
blogging in neovim and uploading the result to my webserver. Fine. But being on
mobile networks (I always use the portable hotspot feature of my mobile phone)
is disgusting. It often does not work and it wastes a lot of bandwidth when you
do not disable certain programs. One example is
[Syncthing](https://syncthing.net). I love using it to synchronize my data in
a secure manner; but it needs bandwidth.

I was used to stop Syncthing manually each time I connect to my mobile phone.
But I often forgot to do that. It was quite annoying.  I was often wondering if
I could automate that with some kind of script.  I could.

I use Arch Linux on my computers (despite I slowly begin to dislike systemd...)
and I use [NetworkManager](https://wiki.archlinux.org/index.php/NetworkManager)
to configure my network devices. I works well and I am happy with the result.
The cool thing is, that NetworkManager provides a component that is called
`nm-dispatcher`. That is some program which is able to call shell scripts
depending on certain "events", such as establishing a particular network
connection.

NetworkManager has a CLI tool which can be used to get a list of configured
network connections; and all these connections are identified with some
"unique" ID. So the first step is to find out the network ID of my
hotspot connection:

```
$ nmcli conn show
NAME                   UUID                                  TYPE             DEVICE
HansPeterPenis         35bd6e7b-4da1-4d67-a1a9-6c348d872786  802-11-wireless  wlp3s0
…
```

Yeah, there it is. I now can use this ID to trigger a certain script that
will then kill Syncthing when I connect to my mobile hotspot (what a complicated
sentence...). The script files for `nm-dispatcher` are in `/etc/NetworkManager/dispatcher.d/`
and they all follow some pattern:

* Owned by `root`.
* chmod of `600`
* They are executed in alphanumerical order; so some prefix like `10-`, or `20-` can be used
  to execute different scripts in sequential order.
* There is some main `case ... esac` part where the script processes the available events.

NOTE: During writing this I found out that my script does not use the UUID about which I wrote
in the previous paragraph. The name can be used, too.

So, enough explanation, here is the code.

/etc/NetworkManager/dispatcher.d/20-st-shutdown.sh

``` bash
#!/bin/sh

INTERFACE=$1  # <1>
STATUS=$2

# Make sure we're always getting the standard response strings
LANG='C'
NETWORK="$(nmcli -t -f NAME conn show --active)"  # <2>

case "$STATUS" in
	up)
		if [ "$NETWORK" = "HansPeterPenis" ] && pgrep syncthing > /dev/null; then  # <3>
			echo "On WiFi hotspot, killing Syncthing..."
			killall syncthing
			killall syncthing-inotify
		fi
	;;
esac
```

1. `nm-dispatcher` passes the interface and the event to the script. A list of all available events
    can be obtained from the `NetworkManager(8)` manpage. Currently they are: `pre-up`, `up`, `pre-down`,
    `down`, `vpn-pre-up`, `vpn-up`, `vpn-pre-down`, `vpn-down`, `hostname`, `dhcp4-change`, and
    `dhcp6-change`. We don't need the interface in this script, but I left it there for some
    reason...
2. We query the network name (or optionally the UUID of the network), that is active now.
3. In case of the event `up` (or maybe `pre-up` would be even better?) and in case Syncthing
    is running we kill it. Since Syncthing has implemented a SIGTERM handler, that all happens
    gracefully.
