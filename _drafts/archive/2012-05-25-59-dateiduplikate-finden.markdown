---
layout: post
title: Dateiduplikate finden
date: '2012-05-25 11:08:39 +0200'
tags:
- scripting
---
Jeder, der große Foto- oder mp3 Sammlungen hat, kennt sicher das Problem, dass
sich mit der Zeit doppelte Dateien ansammeln. Nachfolgendes Shellscript findet
doppelte Dateien.

```bash
#!/usr/bin/env bash

# SHA256 Checksummen aller Dateien berechnen und in ein Logfile speichern
find -type f -exec sha256sum {} >/tmp/usSHA256SUM.tmp \;

# Logfile nach Checksummen sortieren
sort < /tmp/usSHA256SUM.tmp > /tmp/sSHA256SUM.tmp

# Duplikate der Checksummen finden und speichern
cut -f 1 -d " " /tmp/sSHA256SUM.tmp | uniq -d > /tmp/duplicates.tmp

# Checksummen den Dateien zuordnen und ausgeben
grep -F -f /tmp/duplicates.tmp /tmp/sSHA256SUM.tmp

# Cleanup
rm /tmp/sSHA256SUM.tmp /tmp/usSHA256SUM.tmp /tmp/duplicates.tmp
```

Für weitere Infos bietet sich das Ubuntu Wiki und - selbstverständlich - die
Manpages, wie z.B. `man grep` an.

* http://wiki.ubuntuusers.de/find
* http://wiki.ubuntuusers.de/sort
* http://wiki.ubuntuusers.de/cut
* http://wiki.ubuntuusers.de/uniq
* http://wiki.ubuntuusers.de/grep
