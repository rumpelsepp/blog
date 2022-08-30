---
title: Use virtualenv in fish
---

I do very much python programming and I use the [fish shell](https://fishshell.com/) 
as the main interface to my computer. What is the easiest way to integrate some
[virtualenv](http://docs.python-guide.org/en/latest/dev/virtualenvs/) management in fish?
There are some shellscripts available for zsh or bash, but as always they are too 
bloated; in other words I do not need 99% of the provided functionality. I even do
not know whether these scripts (the most noted may be 
[virtualenvwrapper](https://virtualenvwrapper.readthedocs.io/en/latest/)) are available 
for fish.

NOTE: I am too lazy to explain what a virtualenv is. When you do not know what that is,
      this article won't help.

What does the electrical engineer do? He creates his own script... It turns out, that 
this is _really_ simple. Since I am a nice person, I share it with the internet (say
thanks internet!).

$HOME/.config/fish/functions/venv.fish

``` fish
function venv
    switch (echo $argv[1])
    case "create"
        python3 -m venv "$HOME/.venvs/$argv[2]"
    case "use"
        source "$HOME/.venvs/$argv[2]/bin/activate.fish"
    case "*"
        echo "usage: venv create|use VENV"
    end
end
```

Fish is able to autoload functions. You only have to place a file in the 
config directory `$HOME/.config/fish/functions` containing the functions.

The following examples show the simple usage of these functions:

```
$ venv create testenv
$ venv use testenv
(testenv) $
```

To disable a virtualenv just type `deactivate`. To remove a virtualenv remove the
directory `$HOME/.venvs/VIRTUALENV`. There is no need for bloated wrapper scripts.
