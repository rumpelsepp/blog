---
title: "How to use the nvim clipboard through SSH?"
date: 2021-10-24T11:12:31+02:00
---

[Neovim](https://neovim.io/) is awesome.
By this time it supports being configured using the Lua programming language.
I am pretty happy with this, since I never got into `vimscript`…

I use neovim for everything that has to to with text.
It can be programming, taking notes, configuring services, sorting data, or just reformatting files with macros.
The fact that neovim runs in a terminal enables using it on a remote server via SSH.
Since I use it for these tasks I often have to use my system clipboard (which is provided by wayland in my case).

I have a simple shortcut for this in my `init.lua`:

```lua
vim.api.nvim_set_keymap("", "<leader>y", '"+y', { silent = true })
```

Note: Since I use a German keyboard with the Neo2 layout I have mapped `ä` to the mapleader.
There are most likely no collisions with existing shortcuts and `ä` is easier to type as `\`. :)

```lua
vim.g.mapleader = 'ä'
```

Yeah, that's it with the clipboard, I just hit `<leader>y` (in my case `äy`) and voilà, the yanked content is available via `ctrl+v` in my desktop.
But when `nvim` runs on a remote server via SSH it doesn't work.
`nvim` has so called clipboard providers which define certain commands that are called when the `+` or `*` registers are accessed.
Using this technique, `nvim` offloads the handling of the system clipboard to external shell commands, in my case `wl-copy` for yank and `wl-paste` for paste.
Since `wl-copy` cannot communicate with my wayland compositor (since the relevant UNIX domain socket is not available on the remote server) this just doesn't work.

There is a solution for this.
Programs can communicate with the terminal via so called [escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code).
The relevant command is called OSC52 (Operating System Command 52); see [here; grep for clipboard](https://www.xfree86.org/4.8.0/ctlseqs.html).
My terminal emulator mix of choice ([`tmux`](https://github.com/tmux/tmux) and [`foot`](https://codeberg.org/dnkl/foot)) both support OSC52.
Check if your terminal emulator supports OSC52; I know that [`alacritty`](https://github.com/alacritty/alacritty) supports OSC52 as well.
I always use `tmux` in my terminal, especially on remote servers and its OSC52 clipboard can be enabled in the config:

```
$ cat ~/.config/tmux/tmux.conf
set-option -g set-clipboard on
```

Then out of the box this works:

```
$ echo "foo" | tmux load-buffer -w -  # remote server
$ wl-paste -n                         # local machine
foo
```

The other way round works like this[^1]:

```
$ echo "bar" | wl-copy    # local machine
$ tmux refresh-client -l  # remote server
$ tmux save-buffer -      # remote server
bar
```

In order to use this in `nvim` the relevant snippet for `init.lua` is this one:

```lua
if vim.env.TMUX then
    vim.g.clipboard = {
        name = 'tmux',
        copy = {
            ["+"] = {'tmux', 'load-buffer', '-w', '-'},
            ["*"] = {'tmux', 'load-buffer', '-w', '-'},
        },
        paste = {
            ["+"] = {'bash', '-c', 'tmux refresh-client -l && sleep 0.2 && tmux save-buffer -'},
            ["*"] = {'bash', '-c', 'tmux refresh-client -l && sleep 0.2 && tmux save-buffer -'},
        },
        cache_enabled = false,
    }
end
```

If you do not like `tmux` and want to use OSC52 direcly, I am experimenting with writing a tool for this.
Perhaps it works, then I can release it sometime.

UPDATE: I did write a tool which works somehow: https://codeberg.org/rumpelsepp/oscclip
It is available on Arch in the AUR: https://aur.archlinux.org/packages/oscclip/

[^1]: There was a bug in `tmux` preventing this. It is already merged: https://github.com/tmux/tmux/pull/2942
