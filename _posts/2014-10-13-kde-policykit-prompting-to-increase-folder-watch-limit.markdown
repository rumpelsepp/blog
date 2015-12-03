---
layout: post
title: KDE Policykit Prompting to Increase Folder Watch Limit
date: '2014-10-13 09:26:13 +0200'
tags:
- kde
- administrating
---
As mentioned [here][0], the solution is to cleanup kde-nepomuk entries in
`/etc/sysctl.d`. These entries are created on successful kauth authentication.
The obsolete nepomuk entries overwrite the baloo entries.

[0]: https://bbs.archlinux.org/viewtopic.php?id=180466#p1407397
