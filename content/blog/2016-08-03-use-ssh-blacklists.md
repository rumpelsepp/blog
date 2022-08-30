---
title: Use SSH Blacklists on FreeBSD
---

**NOTE: openbl has been discontinued. So, I leave this article for the archive…**

Since I am a very lazy person, I am quoting the introduction of https://openbl.org:

> The OpenBL.org project (formerly known as the SSH blacklist) is about
> detecting, logging and reporting various types of internet abuse. Currently our
> hosts monitor ports 21 (FTP), 22 (SSH), 23 (TELNET), 25 (SMTP), 110 (POP3), 143
> (IMAP), 587 (Submission), 993 (IMAPS) and 995 (POP3S) for bruteforce login
> attacks as well as scans on ports 80 (HTTP) and 443 (HTTPS) for vulnerable
> installations of phpMyAdmin and other web applications.

The traditional method to protect a server from SSH bruteforce attacks is `fail2ban`;
I hate `fail2ban`:

* It is a very ugly (they call it legacy) Python script which runs as root; 24/7.
* It parses logfiles in order to derive and apply firewall rules.
* It eats ressources, as they were burgers.
* It is ugly to setup, due to its legacyness
* ...

Since I run my own mailserver (under FreeBSD of course), I am familiar with so called
public blacklists. That is some list, were admins (= some script) report abusers
automatically. These lists are updated frequently and can be used by poor guys
like me, who want to benefit from the gathered data (= IP addresses of abusers).
The question was, are there any of those blacklists especially for SSH brute-forcers?

There are. I have found two which are usable:

* `https://www.openbl.org/lists/base_all.txt` *Update: This link is dead now!!*
* https://www.spamhaus.org/drop/edrop.txt

The task is, to add these IP addresses to a firewall block rule and update it, let's
say, once a day. Since I failed in verifying ip addresses in POSIX shell, I wrote
a little, sweet and tiny (= ugly) Python script, which downloads the ip list
asynchronously (just because I can!). It concatenates the two lists together,
verifies each ip address to be valid, and adds them to my `ipfw` firewall rules.

IMPORTANT: It is very, _very_, *very* important to verify, that the downloaded strings
           are actual ip addresses. Imagine you download shellcode, e.g. `; rm -rf /*`,
           which is being executed on your server...

## Python Script

Enough bullshitting now. Let's dive into the code... Here is the script, which is
explained using the really awesome `asciidoctor` features.

``` python
#!/usr/bin/env python3

import argparse
import asyncio
import logging
import shlex
from subprocess import run
from ipaddress import ip_address, ip_network
import aiohttp  # <1>


DEFAULT_BLs = (  # <2>
    "https://www.openbl.org/lists/base_all.txt",
    "https://www.spamhaus.org/drop/edrop.txt",
)
FIREWALL = 'ipfw'  # <3>
IPFW_TABLE = '5'


async def ips_fetch(session, url):  # <4>
    logging.info('Reading BL: {}'.format(url))
    async with session.get(url) as r:
        if r.status != 200:
            return False
        return await r.text()


async def bls_fetch(bls, session):
    results = await asyncio.gather(
        *[ips_fetch(session, bl) for bl in bls]
    )
    return results


def ip_verify(addr):  # <5>
    try:
        return ip_address(addr)
    except ValueError:
        try:
            return ip_network(addr)
        except ValueError:
            return False


def fw_ip_add(ip, args):  # <6>
    if args.f == 'ipfw':
        run(['ipfw', '-qf', 'table', '5', 'add', shlex.quote(str(ip))])
    elif args.f == 'dummy':
        pass
    else:
        print('Firewall not supported')
        exit(1)


def fw_prepare(args):  # <7>
    if args.f == 'ipfw':
        run(['ipfw', '-qf', 'add', 'deny', 'ip', 'from', 'table(5)', 'to', 'me'])
        run(['ipfw', '-qf', 'table', shlex.quote(str(args.ipfw_table)), 'flush'])
    elif args.f == 'dummy':
        pass
    else:
        print('Firewall not supported')
        exit(1)


def logging_init(loglevel):  # <8>
    # From python docs. No magic stackoverflow involved. :)
    # https://docs.python.org/3/howto/logging.html#logging-to-a-file
    numeric_level = getattr(logging, loglevel.upper(), None)
    if not isinstance(numeric_level, int):
        print('Invalid log level: "{}"'.format(loglevel))
        exit(1)

    logging.basicConfig(
        format='%(asctime)s %(levelname)s: %(message)s',
        level=numeric_level,
    )


def parse_args():  # <9>
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-d',
        action='store_true',
        help='Dry run, does not alter firewall rules'
    )
    parser.add_argument(
        '-b',
        metavar='URL',
        nargs='+',
        default=DEFAULT_BLs,
        help='Specify blacklists to process'
    )
    parser.add_argument(
        '-f',
        metavar='FIREWALL',
        default=FIREWALL,
        help='Specify firewall backend [default: ipfw]'
    )
    parser.add_argument(
        '--ipfw-table',
        metavar='TABLE',
        default=IPFW_TABLE,
        help='Specify table for ipfw [default: 5]'
    )
    parser.add_argument(
        '-l',
        metavar='LEVEL',
        type=str,
        default='INFO',
        help='CRITICAL, ERROR, WARNING, INFO [default], DEBUG'
    )

    return parser.parse_args()


def main():
    args = parse_args()
    logging_init(args.l)

    if not args.d:
        logging.debug('Preparing firewall tables')
        fw_prepare(args)

    # Async magic!
    loop = asyncio.get_event_loop()  # <10>
    with aiohttp.ClientSession(loop=loop) as session:
        ips = loop.run_until_complete(
            bls_fetch(args.b, session)
        )
    loop.close()

    ips = ('\n'.join(ips)).splitlines()  # <11>
    # Poor man's comment remover
    ips = map(lambda ip: ip.split('#')[0].split(';')[0].strip(), ips)

    ctr = 0  # <12>

    for ip in ips:  # <13>
        ip_verified = ip_verify(ip)
        if ip_verified is False:
            logging.debug('Invalid ip address: "{}"'.format(ip))
            logging.debug('Continuing with next ip')
            continue
        if not args.d:
            logging.debug('Blocking "{}"'.format(ip_verified))
            fw_ip_add(ip_verified, args)
            ctr += 1
        else:
            logging.debug('Would block "{}"'.format(ip_verified))
    logging.info('{} ips blocked'.format(ctr))


if __name__ == '__main__':
    main()
```

Thanks to `asciidoctor` and the `jekyll-asciidoc` plugin, I am now able to
comment on selected lines of code, which is awesome. Thanks to the creators
of `asciidoctor`, keep on the awesome work! 
EDIT: Migrated to markdown, works as well. :)

1. Load the https://aiohttp.readthedocs.io[`aiohttp` library]. There are no
    technical reasons against `requests` or the stdlib. I just wanted to try
    the new asynchronous capabilities of Python 3.5. One can replace it safely
    with the http library of choice; but the script has to be adapted then...
2. These are the blacklists which I use per default. Since I like Python
    programming a lot, I decided to make the blacklists configurable, and
    overwritable by the commandline options.
3. My collegues still use `iptables`, so I designed the script to be extendible
    to other firewall backends. I use `ipfw` on FreeBSD, it should not be
    difficult to adapt the script to, e.g. `iptables`.
4. To use the `async def` methods, a recent Python implementation has to be
    used, I use 3.5 currently. These two methods download the ip list from the
    configured blacklists. I have mostly copied the code from the `aiohttp`
    documentation. In the end, the `bls_fetch` method returns a string that
    contains the concatenated content of all configured blacklists.
5. That's the actual part why I have chosen to implement this script in
    Python. The gathered ip addresses (and address ranges) can simply be
    verified by instantiating an ipaddress object. When it fails, an exception
    is raised. I trust the Python stdlib to be correct.
6. Just add the given ip address to the firewall table by calling the `ipfw`
    binary. Please note, that all given strings MUST be sanitized using the
    `shlex` module when calling a binary!!
7. Do some preparations, add the lookup table, flush it, make coffe, ...
8. Initialize logging framework. I want logging, when this crap is run by `cron`.
9. That's the argument parser, most variables can be overwritten on the commandline.
10. That's needed because of `aiohttp`; it might be possible to replace it with
    a simple call to `requests.get()` or something...
11. String post processing. The downloaded string has to be converted to the proper
    Python data types, and most importantly, comments should be removed in advance.
12. A simple counter, to count how many ip addresses have been added to the block list.
13. That's the main loop of my script. It iterates over the list of ip addresses,
    calls the verify methods and, if true, adds them to the firewall block table.

And finally add this script to cron, e.g. like this:

/etc/crontab

```
# ...
@daily  root    nice -n  5 /usr/local/bin/openbl.py
```

I have tested the script for two days now. It seems to work quite well; it indeed
blocks potential abusers:

```
$ ipfw -cde list
....
01200   417   25127 deny ip from table(5) to me
....
```

So, I hope this was useful, and I hope my server is now more secure, unless someone
hacks openbl.org and locks me out of my server... :D
