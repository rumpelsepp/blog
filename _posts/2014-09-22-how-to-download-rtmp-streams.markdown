---
layout: post
title: How to download rtmp streams?
date: '2014-09-22 19:43:55 +0200'
tags:
- python
- scripting
---
From wikipedia:

> Real Time Messaging Protocol (RTMP) was initially a proprietary protocol
> developed by Macromedia for streaming audio, video and data over the Internet,
> between a Flash player and a server. Macromedia is now owned by Adobe, which has
> released an incomplete version of the specification of the protocol for public
> use.

Many media sites (N24, zdf, ard, ...) use rtmp streams to prevent people from
downloading the videos. Well, there is a little command line tool which allows
downloading rtmp streams. It is called [rtmpdump][0] and is available in the
arch linux repositories.

To use rtmpdump you have to extract the required parameters from the html source
code. For N24 it looks like this (it is *really* ugly!):
http://pastebin.com/raw.php?i=brF5DvUL

To use rtmpdump we need to set the `-r`, `-W` and `-y` parameters; with `-o` we
can specify a filename. An explanation of these parameters could be found with
`rtmpdump -h`. An appropriate rtmpdump call for the html code above would look
like the following:

```
rtmpdump \
  -r "rtmp://pssimn24livefs.fplive.net:1935/pssimn24/" \
  -W "http://www.n24.de/_swf/HomePlayer.swf?cachingVersion=2.66" \
  -y "mp4:cm2013/cmp/e214/89ed/ac91/30c0/0a1db4af7089b0c05161ea2dcca58546_1000.mp4" \
  -o "myvideo.mp4"
```

As you can see I have extracted these values from the [source code][1] of the
website. For n24 it is:

* `-r`: `_n24VideoCfg.flash.videoFlashconnectionUrl`
* `-W`: `_n24VideoCfg.flash.SWFUrl` (prepend the baseurl!)
* `-y`: `_n24VideoCfg.flash.videoFlashSource`

For simplification I have written a little python wrapper which extracts these
parameters from a given URL and builds the rtmpdump command line string:

```python
import re
import sys
import subprocess
import urllib.request
from urllib.parse import urlparse


url = sys.argv[1]
url_parsed = urlparse(url)
response = urllib.request.urlopen(url)
html = response.read().decode()

regex = re.compile(
    r'<title.*?>(?P<title>.+?)</title>|'
    r'(?:_n24VideoCfg.flash.videoFlashconnectionUrl = )["\'](?P<param_r>.*)["\'];|'
    r'(?:_n24VideoCfg.flash.SWFUrl = )["\'](?P<param_W>.*)["\'];|'
    r'(?:_n24VideoCfg.flash.videoFlashSource = )["\'](?P<param_y>.*)["\'];|'
)

title = ''
rtmpdump_params = {}

for match in regex.finditer(html):
    typ = match.lastgroup

    if typ == 'title':
        title = match.group('title')
    elif typ == 'param_r':
        rtmpdump_params['-r'] = match.group('param_r')
    elif typ == 'param_W':
        rtmpdump_params['-W'] = match.group('param_W')
    elif typ == 'param_y':
        rtmpdump_params['-y'] = match.group('param_y')

subprocess.call([
    'rtmpdump',
    '-r', rtmpdump_params['-r'],
    '-W', url_parsed[0]  + '://' + url_parsed[1] + rtmpdump_params['-W'],
    '-y', rtmpdump_params['-y'],
    '-o', title + '.mp4'
])
```

[0]: https://www.archlinux.org/packages/?name=rtmpdump
[1]: http://pastebin.com/raw.php?i=brF5DvUL
