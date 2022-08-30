---
title: How to disable annoying zoom mode in gtk applications
---

Another short post for today, but this one is important.
The gnome devs introduced the so called
["zoom mode"](https://blogs.gnome.org/mclasen/2013/08/05/scrolling-in-gtk).
This one is really, *really*, **really** annoying. I can't imagine
why somebody even wants this!! I hate it; I even more hate the fact that
there is no "disable zoom mode" setting somewhere in the GUI...
So, thanks god, I incidentally discovered the solution [^1] [^2].


Add a file `~/.config/gtk-3.0/settings.ini` with this content, restart
the relevant GTK application and be happy:

```
[Settings]
gtk-long-press-time = 5000
```
---

[^1]: http://superuser.com/questions/927160/how-can-i-disable-slow-scrolling-in-gnome-apps

[^2]: https://forums.gentoo.org/viewtopic-p-7705894.html
