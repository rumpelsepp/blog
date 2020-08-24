---
title: Android VPN leaks ipv6
---
Ich hab mir jetzt endlich nen VPN Server zugelegt um in offenen WLANs
sicher zu surven zu können (konkret: OpenVPN + FreeBSD bei digital
ocean). Mein VPN Server macht aktuell nur ipv4, weil die kleinste
digital ocean kiste (wie ich gelernt habe) aktuell kein /112 oder /64er
netz bekommt. Stört mich soweit nicht, koennte laut Support aber noch
kommen.

ABER:
Wenn ein Gerät per VPN online ist und beide, ipv4 und ipv6 macht, dann
kann ipv6 traffic neben dem VPN vorbei leaken. Es ist mir aufgefallen,
dass trotz VPN google meine position anhand der IP wusste. eigentlich
sollte da jetzt ja immer Frankfurt drinstehen... Tja, das Linux Hotel
hat WLAN mit ipv6 Support und der Traffic leaked einfach an meinem VPN
vorbei.

Abhilfe: Wenn ich im VPN bin, ipv6 ausmachen. Alles gut.

Frage: Wie zur Hölle mach ich das auf android? Ich hab jetzt über ne
Stunde gegoogled und nix vernünftiges gefunden. IPV6 in ein leeres VPN
LAN routen ist doof, weil dann die meisten Webseiten einfach tod sind.
IPv6 irgendwie über Firewall wegblocken sollte den gleichen Effekt
bringen (glaub ich). Einfach ipv6 ausknipsen wäre das sinnvollste, aber
bei Android (!= einfaches Linux) ..... Arrrgh.

Ich hatte dann den Vorschlag bekommen folgendes auszuprobieren und ggf.
zu scripten:

	echo 1 > /proc/sys/net/ipv6/conf/wlan0/disable_ipv6

Das wäre natürlich eine Möglichkeit, ja. Ich hab nur irgendwie Bedenken,
dass es nicht wirklich gut funktioniert. Script gebotschte und Android...
klingt irgendwie nach einer sehr bösen Kombination.

Ich hab es jetzt anders gelöst, einen Hurricane Electric Tunnel auf
meinem Server! Damit umgehe ich das zu kurze Prefix von Digital Ocean
ganz einfach.

Auf FreeBSD [einfach](https://www.freebsd.org/doc/handbook/network-ipv6.html)
aufzusetzen:

/etc/rc.conf:

``` sh
# Hurricane Electric
gif_interfaces="gif0"
gifconfig_gif0="SERVERIP4 ENDPUNKTIP4"
ifconfig_gif0_ipv6="inet6 SERVERIP6 ENDPUNKTIP6 prefixlen 128"

# Gateway
ipv6_activate_all_interfaces="yes"
ipv6_defaultrouter="ENDPUNKTIP6"
ifconfig_vtnet0_ipv6="ENDPUNKTIP6 prefixlen 64"
rtadvd_enable="YES"
rtadvd_interfaces="vtnet0"
ipv6_gateway_enable="YES"
```

Als ENDPUNKTIP6 einfach `...:1` nehmen; als SERVERIP6 dann die `....:2`.
Die ifconfig (ohne loopback) schaut so aus. Das `gif0` macht den Hurricane
Electric Tunnel; das `vtnet0` ist mein netzwerkkarte, das `tun0` ist mein
`openvpn` device.

```
$ ifconfig
vtnet0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
ptions=6c07bb<RXCSUM,TXCSUM,VLAN_MTU,VLAN_HWTAGGING,JUMBO_MTU,VLAN_HWCSUM,TSO4,TSO6,LRO,VLAN_HWTSO,LINKSTATE,RXCSUM_IPV6,TXCSUM_IPV6>
        ether 04:01:25:41:24:01
        inet6 fe80::601:25ff:fe41:2401%vtnet0 prefixlen 64 scopeid 0x1
        inet 188.166.164.127 netmask 0xfffff800 broadcast 188.166.167.255
        inet6 2001:470:1f0a:6cb::1 prefixlen 64
        inet 10.19.0.5 netmask 0xffff0000 broadcast 10.19.255.255
        nd6 options=21<PERFORMNUD,AUTO_LINKLOCAL>
        media: Ethernet 10Gbase-T <full-duplex>
        status: active
gif0: flags=8051<UP,POINTOPOINT,RUNNING,MULTICAST> metric 0 mtu 1280
        options=80000<LINKSTATE>
        tunnel inet 188.166.164.127 --> 216.66.80.30
        inet6 2001:470:1f0a:6cb::2 --> 2001:470:1f0a:6cb::1 prefixlen 128
        inet6 fe80::601:25ff:fe41:2401%gif0 prefixlen 64 scopeid 0x4
        nd6 options=21<PERFORMNUD,AUTO_LINKLOCAL>
tun0: flags=8051<UP,POINTOPOINT,RUNNING,MULTICAST> metric 0 mtu 1500
        options=80000<LINKSTATE>
        inet6 fe80::601:25ff:fe41:2401%tun0 prefixlen 64 scopeid 0x5
        inet 10.8.0.1 --> 10.8.0.2 netmask 0xffffffff
        inet6 2001:470:1f0b:6cb::1 prefixlen 64
        nd6 options=21<PERFORMNUD,AUTO_LINKLOCAL>
        Opened by PID 89727
```

Funktioniert jetzt alles gut. Ich bekomm am Handy jetzt ipv4 und ipv6 zugewiesen,
alles funktioniert. Der ping über den VPN Tunnel ist auch gar ned mal sooooo schlecht:

```
stefan@kronos ~> ping -4 google.de
PING google.de (216.58.198.131) 56(84) bytes of data.
64 bytes from fra02s17-in-f3.1e100.net (216.58.198.131): icmp_seq=1 ttl=58 time=24.7 ms
64 bytes from fra02s17-in-f3.1e100.net (216.58.198.131): icmp_seq=2 ttl=58 time=25.2 ms
64 bytes from fra02s17-in-f3.1e100.net (216.58.198.131): icmp_seq=3 ttl=58 time=24.8 ms
64 bytes from fra02s17-in-f3.1e100.net (216.58.198.131): icmp_seq=4 ttl=58 time=25.6 ms
64 bytes from fra02s17-in-f3.1e100.net (216.58.198.131): icmp_seq=5 ttl=58 time=25.8 ms
64 bytes from fra02s17-in-f3.1e100.net (216.58.198.131): icmp_seq=6 ttl=58 time=25.5 ms
64 bytes from fra02s17-in-f3.1e100.net (216.58.198.131): icmp_seq=7 ttl=58 time=25.4 ms
64 bytes from fra02s17-in-f3.1e100.net (216.58.198.131): icmp_seq=8 ttl=58 time=25.0 ms
64 bytes from fra02s17-in-f3.1e100.net (216.58.198.131): icmp_seq=9 ttl=58 time=24.9 ms
^C
--- google.de ping statistics ---
9 packets transmitted, 9 received, 0% packet loss, time 8013ms
rtt min/avg/max/mdev = 24.744/25.254/25.837/0.365 ms
```

```
stefan@kronos ~> ping -6 google.de
PING google.de(fra02s17-in-x03.1e100.net (2a00:1450:4001:806::2003)) 56 data bytes
64 bytes from fra02s17-in-x03.1e100.net (2a00:1450:4001:806::2003): icmp_seq=1 ttl=58 time=25.4 ms
64 bytes from fra02s17-in-x03.1e100.net (2a00:1450:4001:806::2003): icmp_seq=2 ttl=58 time=25.2 ms
64 bytes from fra02s17-in-x03.1e100.net (2a00:1450:4001:806::2003): icmp_seq=3 ttl=58 time=26.0 ms
64 bytes from fra02s17-in-x03.1e100.net (2a00:1450:4001:806::2003): icmp_seq=4 ttl=58 time=31.1 ms
64 bytes from fra02s17-in-x03.1e100.net (2a00:1450:4001:806::2003): icmp_seq=5 ttl=58 time=25.6 ms
64 bytes from fra02s17-in-x03.1e100.net (2a00:1450:4001:806::2003): icmp_seq=6 ttl=58 time=25.6 ms
64 bytes from fra02s17-in-x03.1e100.net (2a00:1450:4001:806::2003): icmp_seq=7 ttl=58 time=26.1 ms
64 bytes from fra02s17-in-x03.1e100.net (2a00:1450:4001:806::2003): icmp_seq=8 ttl=58 time=25.4 ms
64 bytes from fra02s17-in-x03.1e100.net (2a00:1450:4001:806::2003): icmp_seq=9 ttl=58 time=26.0 ms
^C
--- google.de ping statistics ---
9 packets transmitted, 9 received, 0% packet loss, time 8011ms
rtt min/avg/max/mdev = 25.282/26.313/31.147/1.736 ms
```

Als Vergleich dazu, mein native ipv4:

```
stefan@kronos ~> ping -4 google.de
PING google.de (172.217.19.195) 56(84) bytes of data.
64 bytes from fra02s21-in-f3.1e100.net (172.217.19.195): icmp_seq=1 ttl=57 time=23.9 ms
64 bytes from fra02s21-in-f3.1e100.net (172.217.19.195): icmp_seq=2 ttl=57 time=23.3 ms
64 bytes from fra02s21-in-f3.1e100.net (172.217.19.195): icmp_seq=3 ttl=57 time=23.9 ms
64 bytes from fra02s21-in-f3.1e100.net (172.217.19.195): icmp_seq=4 ttl=57 time=24.0 ms
^C
--- google.de ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
rtt min/avg/max/mdev = 23.390/23.843/24.085/0.267 ms
```

Kann man so lassen glaub ich. :)
