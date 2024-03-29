---
title: Fix first weekday with `cal` in debian
---

This is another short blog post. Since I have migrated to
debian from arch linux I had some minor problems. The most
annoying problem for, as a german, was that the `cal` command
had the first weekday set to sunday... IMO that should be easy
to fix. Haha... This is what I tried:

1. Set the environment variable `LC_TIME` to something like
  `de_DE.UTF-8`. The month names became german, but the first
  weekday did not change.
2. I studied the manpage and discovered the flag `-M`. I got
  an exit code `64` and the help page of the `cal` tool. WTF?!?!.
3. I studied the manpage `locale` and also read some cross
  referenced manpages, since I had the opinion that my
  environment variables are wrong. No solution found...
4. Coincidentally, I realized, that there are two commands!!
  There also is `ncal`, which is mentioned in the SYNOPSIS
  section of the `cal` manpage. I have no idea why this command
  is there. It does almost the same and it correctly interprets
  `LC_TIME`. The only thing to remember is to supply the `-b` flag
  in order to generate the same output as `cal`. I have set an
  alias in my `fish` config like this:

```
alias cal="ncal -b"
```

Now my calendars render correctly again! No idea why such an oddysee
was necessary… Here is the result:

```
$ env LC_TIME=de_DE.UTF-8 /usr/bin/cal
     März 2017
So Mo Di Mi Do Fr Sa
          1  2  3  4
 5  6  7  8  9 10 11
12 13 14 15 16 17 18
19 20 21 22 23 24 25
26 27 28 29 30 31

$ env LC_TIME=de_DE.UTF-8 /usr/bin/ncal -b
     März 2017
Mo Di Mi Do Fr Sa So
       1  2  3  4  5
 6  7  8  9 10 11 12
13 14 15 16 17 18 19
20 21 22 23 24 25 26
27 28 29 30 31
```

Really annoying...
