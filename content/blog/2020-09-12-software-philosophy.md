---
title: "Software Philosophy"
date: 2020-09-12T00:37:09+02:00
draft: true
---

Motivated by the current trend towards a more complex and less understandable[^1] [^2] [^3] [^4] [^5] [^6] software world, I tried to formulate my personal software philosophy.
I came up with these four headlines.

[^1]: https://drewdevault.com/2020/08/13/Web-browsers-need-to-stop.html
[^2]: http://webgpu.io/
[^3]: https://www.w3.org/TR/webrtc/
[^4]: https://www.docker.com/
[^5]: https://kubernetes.io/
[^6]: https://wicg.github.io/web-codecs/

## Simplicity and Readability Counts

> You do not write code for computers, but for *humans*.

This very statement says it all.
Since we developers must deal with all the mess we create, it is priority number one to create a *readable* mess.
The human brain is some kind of a ring buffer.
After time we forget things.
It must be easy to re-read and re-understand a codebase.
In order to achieve this goal there are a few things I consider important:

* Do not overengineer.
  Think twice if feature X is needed and if it is really an improvement.
  Unused code rots.
* Keep things at the bare minimum.
  Define interfaces for extendability.
  Use interfaces which are already there, e.g. stdin/stdout is often a good one.
* Do not reinvent the wheel, reuse past work as much as possible.
  It doesn't matter if it's your work or the work of other people.
  If things are reused, they naturally improve over time and your software benefits.
* (Re-)Read the code you have written and the code written by others.
  Restructure complex parts and do little cleanups regularly.
* Try hard writing readable code in the first place and don't clean it up later.
  The problem with this is: You won't cleanup anything!

## The Power of (Good) Defaults

Configuring things is *annoying*.
It is even more annoying when non-trivial initial configuration is required.
This might be unavoidable for server software such as e-mail.
But it is avoidable for things like a text editor.
I used to use `vim` a long time ago.
The defaults are annoying[^7] and small tweaks (e.g. `set background=dark`) are always needed.
I migrated to [`nvim`](https://neovim.io/) which has “strong defaults” as a design goal.
Deploying a fresh Linux machine and installing/configuring a few programmes is refreshing now, since I can just use my tools without any tweaks.

[^7]: It got better the last years, though.

To make your software usable my thoughts are:

* Run reasonably out of the box with no (best) or minimal (ok) configuration.
  Make a required initial configuration as easy as possible.
  Document all the settings at a central and easy to find location.
* Make it easy to discover available options (e.g. manpage, builtin help, autocompletion, …).
  Deploy the documentation with the tool and make it a part of the program enabling learning by doing.
  Do not reference to a README somewhere.
  Most important: make this command for your tool `tool` exit with a zero (= success) exit code: `man tool`.
* Do not hide features or functionality behind obscure configuration settings.
  Just expose and enable them, otherwise nobody will use those features.
* `make` should be enough to build it with sane defaults.
  All (= most) of my projects can be built with just one `make` command.
  That's the very reason the `make` program exists.
  Just use it!

## Minimal Dependencies

Drew has written an [article](https://drewdevault.com/2020/02/06/Dependencies-and-maintainers.html) about dependencies and maintainers.
I think his article makes a good match.

## Choose the Right Tool

I love this one.
Chose the right tool for your task.
Think outside the box and use tools which are simple, easy to remember, and available.
Do not start writing a e.g. custom Python script for every small task.
A lot of problems are solved and there are a lot of good solutions available.
Know these solutions and use them wisely.
