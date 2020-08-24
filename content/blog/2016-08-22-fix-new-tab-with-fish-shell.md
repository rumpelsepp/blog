---
title: Fix "New Tab" with fish shell
---

Several terminal emulators support a keybinding like `CTRL + SHIFT + T`
in order to open a new tab; I use the really lightweight and super awesome 
[`termite`](https://github.com/thestinger/termite) terminal emulator:

> Termite is a minimal terminal emulator designed for use with tiling window
> managers. It is a modal application, similar to Vim, with an insert mode and
> command mode where keybindings have different functions. Termite is based on
> the VTE library. The configuration file allows to change colors and set some
> options. Termite supports transparency along with both the 256 color and true
> color (16 million colors) palettes. It has a similar look and feel to urxvt.
> -- https://wiki.archlinux.org/index.php/Termite

Since I love awesome stuff, I also use [fish shell](http://fishshell.com/) extensively.
The problems with fish shell are: 

* Do not set it as your login shell! Things will break; use bash instead. Start 
  fish as a program in your terminal emulator.
* Starting termite like `termite -e fish` and mapping this to special keybinding 
  works, but it breaks the `CTRL + SHIFT + T` keybinding. The
  newly created terminal tab is started with `bash` which has the cwd in `$HOME`.

How to fix this? First, `termite` is a terminal emulator that is based on the 
[VTE](https://developer.gnome.org/vte/unstable/) library. That means, according to
the documentation, the file `/etc/profile.d/vte.sh` has to be sourced to be able
to create new tabs in *the same* directory as the previous one (instead of `$HOME`).
I suggest checking for the existance of the file as well:

~/.bashrc

``` bash
VTE_FILE="/etc/profile.d/vte.sh"
if [ -e "$VTE_FILE" ]; then
    source "$VTE_FILE"
fi
```

Next, I want that `fish` is started after I have started the terminal emulator.
I have found out, that the coolest way to do this is by using `exec`; because we
don't want to break any non interactive scripts, we add a check at the beginning 
of the `~/.bashrc` file as well:

~/.bashrc

``` bash
#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ...

exec fish
```

`exec` causes the bash process being entirely replaced by a fish process. That means,
that the terminal window is closed when issueing kbd:[CTRL] + kbd:[D]. Yeah, almost there!

Another annoying "feature" of termite is that it comes with its own termcap
file, so `$TERM` is set to something like `xterm-termite` by default. I hate
that! It breaks every ssh session on every machine where termite is not
installed... I always set it to `xterm-256color` instead. It prevents things
from breaking and I cannot, by the shoes of my mother, see any difference from
`xterm-termite`. But this creepy thing can be used to detect that bash is
running inside termite!! That's awesome, because it can be used to protect this
`exec fish` snipped from being executed by accident in script started by the
system or whatever.

Here is the full code:

~/.bashrc

``` bash
#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ...

# Workaround for broken ssh sessions all the time.
# Also start fish-shell and enable CTRL+SHIFT+T.
if [ "$TERM" = "xterm-termite" ]; then
    export TERM="xterm-256color"
    VTE_FILE="/etc/profile.d/vte.sh"
    if [ -e "$VTE_FILE" ]; then
        source "$VTE_FILE"
    fi
    exec fish
fi
```

*UPDATE*: If you also want to detect, that the current bash session has been
launched in a `neovim` terminal buffer using the neovim command `:te`, then you
can check the existance of the environment variable `NVIM_LISTEN_ADDRESS`. So,
if you also want the fish shell to be spawned in neovim terminal buffers, then 
modify the `if` statement as follows:

``` bash
if [ "$TERM" = "xterm-termite" ] || [ -n "$NVIM_LISTEN_ADDRESS" ]; then
```
