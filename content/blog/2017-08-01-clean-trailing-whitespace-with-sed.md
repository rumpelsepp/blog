---
title: Clean trailing whitespace with sed
---

Hi. This is just a short post; but I am still alive! :)
I have recently cleaned up my neovim config, and I had 
the requirement for a script which cleans trailing whitespace.
I have come up with some cool `sed` stuff. Here is my short
script:

```
#!/bin/sed -f

:a
/^\n*$/ {
    $d
    N
    ba
}

s/[[:space:]]\+$//
```

Here are some links about this topic:

* <http://sed.sourceforge.net/>
* <http://sed.sourceforge.net/sed1line.txt>
* <https://stackoverflow.com/a/10711226/2587286>
* <https://stackoverflow.com/a/10711226/2587286>
* <http://www.grymoire.com/Unix/Sed.html>
* <https://www.gnu.org/software/sed/manual/html_node/Regular-Expressions.html>

That's it for today!
