---
title: "Geolocation for Gammastep"
---

I use the [`gammastep`](https://gitlab.com/chinstrap/gammastep) utility for enabling a redshifty nightlight on my desktop.
Since `gammastep` supports wayland and `sway` supports the wayland protocols in play it is works for me.
Now to the annoying part of it: Geolocation.
Geolocation is needed that `gammastep` knows on which time it needs to enable the nightlight.

I am a lazy person and I want that my ducktaped computer works without my intervention most of the time.
There is [`geoclue`](https://gitlab.freedesktop.org/geoclue/geoclue) for this; which is a [nightmare to set](https://wiki.archlinux.org/title/Redshift#Automatic_location_based_on_GeoClue2) up on non-gnome.
Best part, it [doesn't work](https://gitlab.freedesktop.org/geoclue/geoclue/-/issues/151) reliably.
Annoying.

Eventually, I wrote my own simple wrapper for `gammastep` using a [web service](https://ipapi.co/) I found while I was procastinating.
Here is the shell two-liner (six-liner including shebang, blank lines, and bash settings); paste this into `~/.local/bin/gammastep-wrapper.sh`:

```bash
#!/usr/bin/env bash

set -eu

resp="$(curl -Ls https://ipapi.co/json)"
gammastep -l "$(jq ".latitude" <<< "$resp")":"$(jq ".longitude" <<< "$resp")" -m wayland
```

Paste this into `~/.config/systemd/user/gammastep.service`:

```
[Unit]
Description=Display colour temperature adjustment
PartOf=graphical-session.target
After=graphical-session.target NetworkManager-wait-online.service

[Service]
ExecStart=%h/.local/bin/gammastep-wrapper.sh

[Install]
WantedBy=graphical-session.target
```

Now you have fancy `gammastep` with geolocation capabilites which can be started via:

```
$ systemctl --user start gammastep
```

A restart of the service triggers a location update. :)
