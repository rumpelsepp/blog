---
title: Announcing /dns-query
---

Hi!

I am happy to announce that I am now hosting a public DoH resolver which is free to use.
There is no logging and I host an unbound instance which is doing all the recursive resolving and DNSSEC validation stuff.
The URL you can use is: https://rumpelsepp.org/dns-query

```
$ curl -L --doh-url https://rumpelsepp.org/dns-query rumpelsepp.org/myip
{"ip":"87.144.169.243","names":["p5790A9F3.dip0.t-ipconnect.de."],"geo_ip":{"country_code":"DE","country_name":"Germany","city":"Munich","postal":"80796","latitude":48.15,"longitude":11.5833}}
```

Works!

## Update

I submitted this here: https://github.com/DNSCrypt/dnscrypt-resolvers/pull/239
I might get more traffic once this is merged, let's see what will happen.

UPDATE: 31.03.2021: I had stability issues and dropped this for the time being.
