---
title: Low Latency Video Streaming
---

Due to the COVID-19 madness in Germany I was forced to perform all my penetration testing remotely[^1].
This is quite challenging when you have to make sure that devices can be powercycled reliably.
Additionally, the power consumption is often an indicator for a crash.
Having on overview of the current consumption of my setup makes perfect sense.

[^1]: I break automotive ECU's at `$DAYJOB`

The powercycle problem was trivial.
I grabbed a R&S power supply which offers a [programming interface](https://cdn.rohde-schwarz.com/pws/dl_downloads/dl_common_library/dl_manuals/gb_1/h/hmc804x/HMC804x_SCPI_ProgrammersManual_en_02.pdf).
A few [lines of python](https://git.sr.ht/~rumpelsepp/netzteil/tree/master/netzteil) and I'm done.
Hint: Use the raw tcp port 5025, it is a very simple ASCII line based protocol.
Even `telnet` can be used to remote control the device.

The challanging thing was video.
During my testing I need visual feedback for what I am doing, i.e. "hit enter, look at the power consumption. Anything changed?".
A video of the power supply display would be nice…
I had set up a cheap Logitech webcam in order to stream the video over the network (through VPN and who knows…).
The problem was… 30 sec delay.
Unusable.

After *a lot* of tinkering, I found out these settings:

On the server:

```
$ cvlc v4l2:// :v4l2-vdev="/dev/video0" --sout '#transcode{vcodec=h264,venc=x264{preset=ultrafast,tune=zerolatency,intra-refresh,lookahead=10,keyint=15},scale=auto,ab=128}:std{access=http{mime=video/x-ms-wmv},dst=:8082/stream.wmv}' -v --no-sout-audio
```

On the client:

```
$ mpv --profile=low-latency --stream-lavf-o=reconnect_streamed=1 HOST:8082/stream.wmv
```

I works quite well.
Due to the massive amount of profiles and settings (and not being a video pro) I simply got lost.
Hope this help.
