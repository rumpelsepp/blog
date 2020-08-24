---
title: BTRFS, XFS, ZFS, ...
---

Heute mal was auf Deutsch; ich hab den Artikel schon
geschrieben und bin zu faul den zu übersetzen.

Es gibt im Bereich der Filesysteme mal was neues. Der RAID 5 und RAID 6
Code von BTRFS wurde ja bisher nie als stable bezeichnet. RAID 1 und
RAID 0 funktioniert seit 3 Jahren ziemlich gut. Mit diesem Wissen hab
ich gestern das hier gelesen:

> Btrfs RAID 5/6 Code Found To Be Very Unsafe & Will Likely Require A
> Rewrite[^1] [^2]

[^1]: https://www.phoronix.com/scan.php?page=news_item&px=Btrfs-RAID-56-Is-Bad
[^2]: https://www.mail-archive.com/linux-btrfs@vger.kernel.org/msg55161.html

Es paniken jetzt alle herum und BTRFS wird vermutlich doch nicht so
schnell das NAS Monster betreiben, obwohl es auch interessante neue
Sachen für den 4.8er Kernel gibt[^3] [^4] [^5].

[^3]: https://www.phoronix.com/scan.php?page=news_item&px=Btrfs-Linux-4.8-ENOSP
[^4]: https://www.phoronix.com/scan.php?page=news_item&px=Btrfs-Linux-4.8-Round-2
[^5]: https://patchwork.kernel.org/patch/8672551/

Nunja, im gleichen Zug les ich mal wieder was von XFS (das ist ein sehr
sehr zuverlässiges Filesystem für große Platten, aber ohne "NextGen"
Features). XFS ist ziemlich performant und läuft extrem zuverlässig,
Berichten zufolge teilweise besser als ext4 (Quelle find ich gerade
keine vernünftige).

Das spannende ist jetzt, dass die XFS Entwickler tatsächlich an "NextGen"
Feautures wie Copy-on-Write, online Scrubbing, Deduplication usw. arbeiten.  Die
Vorbereitungen dafür sind gerade noch in den 4.8er Kernel aufgenommen worden [^6].
Wenn die es schaffen, auf die wirklich gute Codebase (der Maintainer ist der
Hammer; Dave Chinner mal auf Youtube suchen) um Copy-on-Write zu ergänzen
uuuuuund vielleicht iwann RAID Support einzubaun, dann wird es wirklich
interessant. Es bleibt spannend, und es bleibt auch spannend was mit BTRFS
passiert, scheint ja irgendwie immer wieder mal ausgebremst zu werden. Läuft
bei mir eigentlich ganz gut seit drei Jahren…

[^6]: https://www.phoronix.com/scan.php?page=news_item&px=XFS-Reverse-Mapping-4.8

Achja, ZFS gibts ja noch. Das MegaMonster. Das rollt eigentlich als open-zfs
still vor sich hin und immer weiter[^7].
Mittlerweile gibt es für Linux
ein Kernel Modul[^8] mit einem Wiki[^9].
 Das zfsonlinux Projekt folgt
dem Upstream und sie tracken die Issues vom Upstream Projekt[^10]. Es gibt
eine Feature Matrix, die für Linux jetzt eigentlich auf ganz gut ausschaut[^11].

[^7]: http://open-zfs.org/wiki/Main_Page
[^8]: http://zfsonlinux.org/
[^9]: https://github.com/zfsonlinux/zfs/wiki
[^10]: https://github.com/zfsonlinux/zfs/wiki/OpenZFS-Tracking
[^11]: http://open-zfs.org/wiki/Feature_Flags

Naja genug dem Geblubber. Für eine NAS rate ich als BTRFS Jünger davon ab und
empfehle mal sich zfsonlinux anzuschaun. Es gibt auch Debian Pakete[^12] (falls das
hier jemand nutzt....). Für jeden, der keine
Lust auf Experimente hat, nimmt ein nacktes FreeBSD mit ZFS[^13]. OVH mit Kimsufi
unterstützt ZFS am Server jetzt auch, ich hab meinen gleich mal migriert. Für
die Heimbastelecke gibts noch FreeNAS[^14]; die
Web-GUI ist zwar anfangangs etwas gewöhnungsbedürftig, aber es funktioniert
echt gut. ZFS ist einfach mega für ein Datengrab, funktionierendes RAID gibts
mit dem sog. RAID-Z obendrauf[^15]. Probierts mal
aus.

[^12]: https://github.com/zfsonlinux/zfs/wiki/Debian
[^13]: https://www.freebsd.org/doc/handbook/zfs.html
[^14]: http://www.freenas.org/
[^15]: http://www.zfsbuild.com/2010/05/26/zfs-raid-levels/

Hier noch ein [Link](https://calomel.org/zfs_raid_speed_capacity.html), hab ich noch nicht vollständig gelesen, aber
potentiell interessant.
