---
title: Announcing /myip
---

Hi there, I am happy to announce a tool I developed a few hours ago.
I often configure VPNs and routing and a common task is finding out the internet gateway's IP address.
There is now [`myip`](https://rumpelsepp.org/myip) available free for everybody to use:

```
$ curl -s https://rumpelsepp.org/myip | jq '.'
{
    "ip": "2003:cd:3721:3f00:fb43:5549:ab58:2a7a",
    "names": [
        "p200300CD37213F00FB435549AB582A7A.dip0.t-ipconnect.de."
    ],
    "geo_ip": {
        "country_code": "DE",
        "country_name": "Germany",
        "city": "Munich",
        "postal": "80796",
        "latitude": 48.15,
        "longitude": 11.5833
    }
}

```

The sourcecode is here: https://git.sr.ht/~rumpelsepp/myip