---
title: Poor Man's Dynamic DNS -- Take 2!
---

Recently I have [written](@/blog/2016-05-16-poor-mans-dyndns.md)
about how to create a "poor man's dyndns" service using the global
discovery system of Syncthing. Since there have been changes in the global
discovery system, my awesome shell script did not work any more... I just
decided to rewrite the whole crap in Python (and Norbert helped a lot!).

The repository is located on [Github](https://github.com/wiederma/st-ddns);
as usual I will explain the current code using the awesome asciidoctor
features. The code is extracted from commit `c6454a6`; it is not completely
polished, but everything works. So time for a blog post!

``` python
#!/usr/bin/env python3

import argparse
import base64
import logging
import shlex
import ssl
import sys
from hashlib import sha256
from subprocess import run

import requests

# We do the pinning ourselves; we don't need a monkey
# who warns us all the time that we are not safe...
# http://stackoverflow.com/a/28002687
from requests.packages.urllib3.exceptions import InsecureRequestWarning  # <1>
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

# fingerprint pinning to host
pinning = (  # <2>
    (
        'discovery-v4-1.syncthing.net',
        'SR7AARM-TCBUZ5O-VFAXY4D-CECGSDE-3Q6IZ4G-XG7AH75-OBIXJQV-QJ6NLQA',
    ),
    (
        'discovery-v4-2.syncthing.net',
        'DVU36WY-H3LVZHW-E6LLFRE-YAFN5EL-HILWRYP-OC2M47J-Z4PE62Y-ADIBDQC',
    ),
    (
        'discovery-v4-3.syncthing.net',
        'VK6HNJ3-VVMM66S-HRVWSCR-IXEHL2H-U4AQ4MW-UCPQBWX-J2L2UBK-NVZRDQZ',
    ),
    (
        'discovery-v6-1.syncthing.net',
        'SR7AARM-TCBUZ5O-VFAXY4D-CECGSDE-3Q6IZ4G-XG7AH75-OBIXJQV-QJ6NLQA',
    ),
    (
        'discovery-v6-2.syncthing.net',
        'DVU36WY-H3LVZHW-E6LLFRE-YAFN5EL-HILWRYP-OC2M47J-Z4PE62Y-ADIBDQC',
    ),
    (
        'discovery-v6-3.syncthing.net',
        'VK6HNJ3-VVMM66S-HRVWSCR-IXEHL2H-U4AQ4MW-UCPQBWX-J2L2UBK-NVZRDQZ',
    ),
)


def _luhn_mod_sum(s):  # <3>
    # https://en.wikipedia.org/wiki/Luhn_mod_N_algorithm
    a = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'
    n = len(a)
    factor = 1
    k = 0
    for i in s:
        addend = factor * a.index(i)
        factor = 1 if factor == 2 else 2
        addend = (addend // n) + (addend % n)
        k += addend
    remainder = k % n
    check_codepoint = (n - remainder) % n
    return a[check_codepoint]


def _chunk_str(s, chunk_size):  # <4>
    return [s[i:i+chunk_size] for i in range(0, len(s), chunk_size)]


def _hash_cert_bin(cert):  # <5>
    v = ssl.PEM_cert_to_DER_cert(cert)
    return sha256(v).digest()


def _hash_cert_file(path):  # <6>
    logging.debug('Reading certificate: {}'.format(path))
    with open(path) as f:
        return _hash_cert_bin(f.read())


def calc_device_id(barray):  # <7>
    s = ''.join([chr(a) for a in base64.b32encode(barray)][:52])
    c = _chunk_str(s, 13)
    k = ''.join(['%s%s' % (cc, _luhn_mod_sum(cc)) for cc in c])
    return '-'.join(_chunk_str(k, 7))


def verify_host(host, exp_fp):  # <8>
    cert = ssl.get_server_certificate((host, 443))
    fp = calc_device_id(_hash_cert_bin(cert))
    if fp == exp_fp:
        return True
    return False


#
# Commands
#
def cmd_announce(args):  # <9>
    cert = shlex.quote(args.cert)
    key = shlex.quote(args.key)

    logging.debug('Using certificate: {}'.format(cert))
    logging.debug('Using key: {}'.format(key))

    for mapping in pinning:
        disco_url = 'https://' + mapping[0] + '/v2/' + '?id=' + mapping[1]
        payload = {'addresses': ['tcp://:12345']}  # <10>

        try:
            if verify_host(*mapping) is False:
                raise RuntimeError

            r = requests.post(  # <11>
                disco_url,
                json=payload,
                verify=False,
                cert=(cert, key),
            )

        # requests does logging through the enabled logging module
        except OSError:
            continue
        except requests.exceptions.ConnectionError:
            continue

        if r.status_code != 204:
            logging.info('Announce failed')
            logging.debug(r.text)
            continue


def cmd_request(args):  # <12>
    device_id = calc_device_id(_hash_cert_file(args.cert))
    request_url = 'https://announce.syncthing.net/v2/'

    # FIXME: Use urljoin and friends here.
    r = requests.get(request_url + '?device=' + device_id, verify=False)
    if r.status_code != 200:
        logging.info('No device found!')
        logging.debug(r.text)
        exit(1)

    ip = r.text.split(':')[5].rsplit('/')[2]
    print(ip)


def cmd_gencert(args):  # <13>
    run([
        'openssl',
        'req',
        '-x509',
        '-newkey',
        'rsa:4096',
        '-keyout',
        'key.pem',
        '-out',
        'cert.pem',
        '-nodes',
    ])


def cmd_fingerprint(args):  # <14>
    device_id = calc_device_id(_hash_cert_file(args.cert))
    print(device_id)


def logging_init(loglevel):  # <15>
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


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-c',
        '--cert',
        default='./cert.pem',
        help='Use this certificate [default: ./cert.pem]',
    )
    parser.add_argument(
        '-k',
        '--key',
        default='./key.pem',
        help='Use this private key [default: ./key.pem]',
    )
    parser.add_argument(
        '-l',
        metavar='LEVEL',
        type=str,
        default='WARNING',
        help='CRITICAL, ERROR, WARNING [default], INFO, DEBUG'
    )

    subparsers = parser.add_subparsers()
    parser_announce = subparsers.add_parser(
        'announce',
        aliases=('ann',),
        help='Announce IP to the Syncthing discovery system',
    )
    parser_announce.set_defaults(func=cmd_announce)

    parser_request = subparsers.add_parser(
        'request',
        aliases=('req',),
        help='Query the ip of a given device',
    )
    parser_request.add_argument('ID')
    parser_request.set_defaults(func=cmd_request)

    parser_gencert = subparsers.add_parser(
        'gencert',
        aliases=('gc',),
        help='Generate a certificate',
    )
    parser_gencert.set_defaults(func=cmd_gencert)

    parser_fingerprint = subparsers.add_parser(
        'fingerprint',
        aliases=('fp',),
        help='Print the fingerprint of a given certificate',
    )
    parser_fingerprint.add_argument(
        'cert',
        help='The path to the certificate file',
    )
    parser_fingerprint.set_defaults(func=cmd_fingerprint)

    return parser.parse_args()


def main():
    args = parse_args()
    logging_init(args.l)
    logging.debug('Invoked with args: {}'.format(args))

    if hasattr(args, 'func'):
        args.func(args)


if __name__ == '__main__':
    main()
```

1.  This one was really annoying. `requests` prints a warning that we
     do a potentially insecure https request. I know that, BUT I do
     certificate pinning myself. So I am safe and I just wanted to get
     rid of the annoying warning.
2.  This is the hashtable, that maps discovery servers to their certificate
     id. Later in the code I download the certificate from the server and
     I check, whether it matches using the device ids (which is nothing more
     than a hash).
3.  [Luhn mod N algorithm](https://en.wikipedia.org/wiki/Luhn_mod_N_algorithm).
     Syncthing device IDs are explained in the official [documentation](https://docs.syncthing.net/dev/device-ids.html#id1). In general, it is SHA-256 hash of the certificate data in DER form plus
     check digits every 7 chars. This method implements the Luhn mod N algorithm.
4.  Divide a string into equal slices of N chars. It is needed in a few places
     in the code.
5.  Generate the SHA256 sum of a certificate in binary data.
6.  Generate the SHA256 sum of a cretificate, that is stored at the given
     filepath. I have chosen to devide that method into two separate methods,
     because this way it avoids code duplication within the source code.
7.  Convert the certificate into a Syncthing device id string according to
     the specs and utilizing the previously presented helper functions.
8.  That's the custom implementation of certificate pinning. Since the Syncthing
     device ids are based on a SHA256 hash, we can be sure that they are
     free of collisions. So, the device ids of the global discovery servers
     are stored in advance (since they are well known). When a connection to
     a discovery server is established, the fingerprint of the presented
     certificate is verified by converting it into a device id and comparing
     that value with the hard coded device ids in the code. When they match
     the discovery server is authenticated and can be trusted.
9.  The implementation of the announce command. That function is called
     by the command line interface code (= `argparse`).
10. An actual fake payload. We have wasted hours of our lifetime by figuring
     out why our scripts do not work. The HTTP POST request to the announce
     servers indeed need a payload... So let's set the port to some value,
     e.g. `1234`.
11. That is the call to `requests.post()` that transfers the data to the announce
     server. Note that `verify` is `False`, as the custom `verify_host()` method
     is called directly before the HTTP POST call. When the host cannot be
     verified an error is raised.
12. Implementation of the `request` command. It is still a bit ugly, but it
     works. It queries the discovery servers with a HTTP GET presenting
     a device id. A json response is given. When the device id was announced
     before, its current ip address is printed on stdout.
13. A shortcut for the `openssl` utility to create a certificate.
14. The implementation of `fingerprint`. The fingerprint of a given certificate
     file is computed and printed on stdout.
15. Initialize logging; the most interesting part is that the `requests` module
     can use the logging as well. It emits log messages through the configured
     logger, which is nice!

## See it in Action!

I have run the script in debug log level, in order to show what's going on.

Announce the certificate:

```
$ ./st-ddns.py -l debug announce
2016-08-04 17:29:25,244 DEBUG: Invoked with args: Namespace(cert='./cert.pem', func=<function cmd_announce at 0x7fdddcfa4950>, key='./key.pem', l='debug')
2016-08-04 17:29:25,244 DEBUG: Using certificate: ./cert.pem
2016-08-04 17:29:25,244 DEBUG: Using key: ./key.pem
2016-08-04 17:29:25,992 INFO: Starting new HTTPS connection (1): discovery-v4-1.syncthing.net
2016-08-04 17:29:27,063 DEBUG: "POST /v2/?id=SR7AARM-TCBUZ5O-VFAXY4D-CECGSDE-3Q6IZ4G-XG7AH75-OBIXJQV-QJ6NLQA HTTP/1.1" 204 0
2016-08-04 17:29:27,936 INFO: Starting new HTTPS connection (1): discovery-v4-2.syncthing.net
2016-08-04 17:29:29,170 DEBUG: "POST /v2/?id=DVU36WY-H3LVZHW-E6LLFRE-YAFN5EL-HILWRYP-OC2M47J-Z4PE62Y-ADIBDQC HTTP/1.1" 204 0
2016-08-04 17:29:30,496 INFO: Starting new HTTPS connection (1): discovery-v4-3.syncthing.net
2016-08-04 17:29:32,353 DEBUG: "POST /v2/?id=VK6HNJ3-VVMM66S-HRVWSCR-IXEHL2H-U4AQ4MW-UCPQBWX-J2L2UBK-NVZRDQZ HTTP/1.1" 204 0
```

Find out our fingerprint:

```
$ ./st-ddns.py fingerprint ./cert.pem
4EDVVKF-KPXXTJH-YHSIPVA-WVB4FFP-R3IV2IB-GJOOSQG-2P7WN24-RYS62Q3
```

Query (from another device) the ip from the discovery servers:

```
$ ./st-ddns.py -l debug req 4EDVVKF-KPXXTJH-YHSIPVA-WVB4FFP-R3IV2IB-GJOOSQG-2P7WN24-RYS62Q3
2016-08-04 17:31:32,262 DEBUG: Invoked with args: Namespace(ID='4EDVVKF-KPXXTJH-YHSIPVA-WVB4FFP-R3IV2IB-GJOOSQG-2P7WN24-RYS62Q3', cert='./cert.pem', func=<function cmd_request at 0x7f6f68ecc9d8>, key='./key.pem', l='debug')
2016-08-04 17:31:32,262 DEBUG: Reading certificate: ./cert.pem
2016-08-04 17:31:32,265 INFO: Starting new HTTPS connection (1): announce.syncthing.net
2016-08-04 17:31:32,673 DEBUG: "GET /v2/?device=4EDVVKF-KPXXTJH-YHSIPVA-WVB4FFP-R3IV2IB-GJOOSQG-2P7WN24-RYS62Q3 HTTP/1.1" 200 81
80.187.98.234
```

TIP:    Once announced, it takes a few minutes until the server answers with
        the correct ip.

It works again!
