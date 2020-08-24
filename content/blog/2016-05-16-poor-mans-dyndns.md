---
title: Poor Man's Dynamic DNS
---

When you want to connect to a computer remotely, you usually need to know its
IP address. Major ISPs assign you a dynamic IP address, to avoid that you
actually run a production server at home. To avoid connecting to IP addresses
directly, there is the Domain Name System (DNS). It maps symbolic names, a
domain foo.bar, to IP addresses. Basically it works like this:

* Application wants to connect to foo.bar.
* Operating System asks the configured DNS server, whether it know the IP address
  of foo.bar.
* DNS Server returns the IP. Application connects to the desired IP address.

When you want to assign your computer a public domain, to be able to connect to
the machine from everywhere, there is a lot of stuff to do. You have to
configure zone files, you have to order the domain, ...  Most importantly: It
costs you money.

What can you do to avoid paying money and configuring DNS zones? Just use my
poor man's DynDNS solution!

wikipedia.org

> Dynamic DNS (DDNS or DynDNS) is a method of automatically updating a name
> server in the Domain Name System (DNS), often in real time, with the active
> DDNS configuration of its configured hostnames, addresses or other information.

You may know [Syncthing](https://syncthing.net/). I love that software! Well,
why the hell are you now talking about a file synchronization tool?!?
It is easy. Syncthing uses a global discovery system to find out the ip
addresses of the involved nodes; it is based on https.

## Let's start with the terminal!

So, let's generate a certificate first:

```
$ openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -nodes
Generating a 4096 bit RSA private key
................++
.........................................++
writing new private key to 'key.pem'
```-
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
```-
Country Name (2 letter code) [AU]:
State or Province Name (full name) [Some-State]:
Locality Name (eg, city) []:
Organization Name (eg, company) [Internet Widgits Pty Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:
Email Address []:
```

We have now two files: `cert.pem` and `key.pem`. We are using asymmetric
cryptography; that means we have a private and a public key. The public key is
stored in the certificate `cert.pem`; the private key is in the file `key.pem`.

We can use our private key to announce ourselves to the global discovery system
of Syncthing. We use `curl` for that; `curl` is awesome.

```
$ url="https://discovery-v4-1.syncthing.net/?id=SR7AARM-TCBUZ5O-VFAXY4D-CECGSDE-3Q6IZ4G-XG7AH75-OBIXJQV-QJ6NLQA"
$ curl -H "Content-Type: application/json" -d '{ "direct": []}' -k --cert cert.pem --key key.pem "$url"
```

Wow, such a long command... But it is not very complicated. We do a http POST request
and we send a special header to the server:

``` json
{ "direct": []}
```

That header advices the discovery system to save the source ip of the request. Since
I want to announce my own computer, that's fine. BTW this is documented in the
[manpage](https://docs.syncthing.net/specs/globaldisco-v3.html).

## Query the IP Address of a Device

So, I have announced my computer. What now? I can query it from somewhere else!
At first you have to find out the DeviceID. That is basically the SHA256 value
of your certificate. But it is not that easy, because there are some redundant
characters added, to detect spelling errors. There is a Python script to calculate
the DeviceID. I have stolen parts of it from Github, but I forgot the origin;
if the author reads this, I am happy to add a link here :).

``` python
#!/usr/bin/env python3

import base64
import fileinput
import ssl
import sys
from hashlib import sha256


def chunk_str(s, chunk_size):
    return [s[i:i+chunk_size] for i in range(0, len(s), chunk_size)]


def luhn_checksum(s):
    a = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    factor = 1
    k = 0
    n = len(a)
    for i in s:
        addend = factor * a.index(i)
        factor = 1 if factor == 2 else 2
        addend = (addend // n) + (addend % n)
        k += addend
    remainder = k % n
    checkCodepoint = (n - remainder) % n
    return a[checkCodepoint]


def get_device_id(barray):
    s = "".join([chr(a) for a in base64.b32encode(barray)][:52])
    c = chunk_str(s, 13)
    k = "".join(["%s%s" % (cc, luhn_checksum(cc)) for cc in c])
    return "-".join(chunk_str(k, 7))


def get_device_id_from_string(s):
    s = s.upper()
    s = s.replace("-", "")
    assert(len(s) == 56)
    c = chunk_str(s, 14)
    did = ""
    for cc in c:
        csum = luhn_checksum(cc[0:13])
        if csum != cc[13]:
            return False
        did += cc[0:13]
    did += "===="
    return base64.b32decode(did)


if len(sys.argv) != 2:
    print('usage: {} FILENAME'.format(sys.argv[0]))
    exit(1)

with open(sys.argv[1], 'r') as f:
    v = ssl.PEM_cert_to_DER_cert(f.read())
    digest = sha256(v).digest()
    print(get_device_id(digest))
```

We are now able to get our DeviceID:

```
$ python device-id.py cert.pem
C2LDKGL-PWIZTSB-7T2ZY4P-DJ3IJDK-Q4RHWYS-KHDXVA4-DA3UYM7-DALW6QL
```

And now, magic, we can do a http POST to actually get the stored IP address:

```
$ deviceid="$(python device-id.py cert.pem)"
$ url="https://discovery-v4-1.syncthing.net/?id=SR7AARM-TCBUZ5O-VFAXY4D-CECGSDE-3Q6IZ4G-XG7AH75-OBIXJQV-QJ6NLQA&device=$deviceid"
$ curl -ks "$url" | json_pp
{
   "Seen" : "2016-05-16T00:07:14.686768Z",
   "relays" : [
      {
         "latency" : 37,
         "url" : "relay://212.47.253.154:22067/?id=PBVWSWM-CLLQRSY-636WRYT-EY7KCHX-BV7YNDD-M2VXSJM-OWYCUI7-BGKNWAQ&pingInterval=1m0s&networkTimeout=2m0s&sessionLimitBps=4194304&globalLimitBps=5242880&statusAddr=:22070&providedBy="
      }
   ],
   "direct" : [
      "tcp://217.254.150.103:22000"
   ]
}
```

Again, that's really long... What happens here? Nothing magic. We just do a http GET
on the public server `https://discovery-v4-1.syncthing.net/`. The `id` parameter is
predefined in Syncthing. That is needed for certificate pinning; but that's out of
scope guys! There is another parameter: `device`. We just insert our DeviceID there
(the backslashes are added to escape some characters properly. You can also put
the whole url in `"`.) We then get a JSON string back.

**UPDATE**: I prettyfied the commands and the output a bit.

## And now? How can I use that crap?

A usecase scenario may be, that you may access you NAS from outside your home
network. Just setup a portforwarding, and let the computer announce itself every
30 minutes. You can build a wrapper script for SSH like this (untested):

``` bash
#!/bin/sh

deviceid="$(python device-id.py cert.pem)"
url="https://discovery-v4-1.syncthing.net/?id=SR7AARM-TCBUZ5O-VFAXY4D-CECGSDE-3Q6IZ4G-XG7AH75-OBIXJQV-QJ6NLQA&device=$deviceid"
ip=$(curl -ks "$url"  \
    | grep -Eo "\"direct\":\[\"tcp://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+\"\]" \
    | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+")
ssh "$ip"
```

Have fun! :)

*Update*: The discovery server has changed and it returns a differnt JSON string now.
I will adjust this shortly!
