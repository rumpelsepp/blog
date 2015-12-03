---
layout: post
title: How to use Pepper Flash with Firefox?
date: '2015-04-15 15:11:50 +0200'
---
Flash Support for linux has been abandoned by adobe a few years ago. Although
flash actually is a real mess it is needed on some places, such as n24.de. On
arch linux there is the `flashplugin` package which provides flash 11 or so. As
this version is quite old nothing really works well…

Today I discovered the possibility to use Google's PepperFlash plugin within
Firefox using the package `freshplayerplugin`. Internally they use some kind of
experimental wrappers. I didn't bother with these internals, I just installed
it:

```
$ pacaur -S freshplayerplugin google-chrome
```

The chrome package is needed because it actually provides PepperFlash. After
restarting Firefox I can watch n24.de with Firefox (without crashing!). Awesome!
