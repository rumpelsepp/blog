---
title: "An Answer to Rewritten in Rust"
---

This post is some kind of an answer to [Rewritten in Rust: Modern Alternatives of Command-Line Tools][1].

[1]: https://zaiste.net/posts/shell-commands-rust/

The creation of the Rust programming language has created a lot of momentum in the free software community.
They praise Rust with the slogan:

> A language empowering everyone to build reliable and efficient software.[^1]

The focus of Rust is on "Performance", "Reliability", and "Productivity"[^1].

A few years ago, I started my engineering "career" with digging through horrible, proprietary, and ugly embedded C code.
Once I discovered Rust, I was quite hyped by its goals.
Finally we have a tool to fix enterprise guys writing bad C code and we can eventually improve all tooling…
Not a bit of it!
In the following I want to give an overview where "Modern Alternatives" of well known programs in Rust miss the point or are actually improvements.

First let's clarify my workflow.
I have two usage profiles on my computer:

* automated (= scripting)
* interactive

## Automated

For the "automated" profile I accept nothing but tools which are almost always **available** on my machines[^2].
Further, I rely on **stable** and **documented** interfaces.

Examples for such tools are:

* bash (might be controversial, but I like it)
* git
* awk
* grep
* find
* sed
* cat, dd, du, ls, … aka coreutils
* openssh

All these tools have in common that they have a stable interface for *scripting*[^3].
These interfaces might or might not be optimized for modern usage, such as the availability of structured data, for instance JSON.
But they are well known and consequently there is tons of high quality documentation and resources available.

If I ever accept a new tool for my automated profile, it MUST meet my requirements of availability and stability.
I consider a tool as stable if it hadn't broken my scripts in the past; preferably the behaviour of the tool is standardized by e.g. POSIX.
I consider a program available when it is present in the standard installation of a Linux distribution (best), or when it is available in the standard package repositories (ok).
I consider a program not available if I need to use a tool like `pip` or `cargo` to install it (bad), or if I even need to compile it from source from scratch (worst).
I maintain a lot of machines and I will get lost otherwise.
Bonus points: The Linux distros' package maintainers do a wonderful job and I can totally rely on them for specifying dependencies and everything correctly.


## Interactive

My "interactive" profile is quite different.
Since I am used to do almost everything in the terminal, tools must be **efficient** and **easy to remember**.
I am a bit more relaxed about the stability requirement here.
Since I have the tools under my fingers every day, I can adapt to changes or new features rather quickly with learning by doing.
What's more important for me is: features that differ from the automated profile must be minimal and easy to remember.
Otherwise I forget about them and won't use them.
Examples for good tools for my interactive profile are:

* fish
* fzf
* tmux
* htop
* git
* coreutils
* tree

Now it starts to get interesting.
There is an overlap in my very subjective list of tools: `git` and `coreutils`.
Excellent software for me: scriptable and usable interactively.
That should be the default for all software we write!

## Now to Rust

The Rust community has created a lot of software the last years, this [blog post][1] shows a few of them.
Most of them address only my interactive profile, since I won't consider them available and stable.
That's simply caused by their age which is understandable.
Let's examine what these tools improve for me.

### exa

The [exa](https://github.com/ogham/exa) tool is:

> a replacement for ls written in Rust.

Ok.
That's what the title of this blog post is all about.
Further the rational is:

> exa is a modern replacement for the command-line program ls that ships with Unix and Linux operating systems, with more features and better defaults. It uses colours to distinguish file types and metadata. It knows about symlinks, extended attributes, and Git. And it's small, fast, and just one single binary.

Let's do a quick check in my current working dir:

```
$ exa -la --color=always | head
thread '<unnamed>' panicked at 'called `Result::unwrap()` on an `Err` value: SystemTimeError(6795364578.871345152s)', src/fs/file.rs:331:9
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
fish: Process 139566, “exa” “exa -la --color=always | head” terminated by signal SIGABRT (Abort)
```

Okay… Then let's do a quick check in the Linux kernel tree:

```
$ command time -p ls -R > /dev/null
real 0.09
user 0.05
sys 0.03
```

```
$ command time -p exa -R > /dev/null
real 0.30
user 0.15
sys 0.14
```

`exa` is fast, but `ls` is faster.
`exa` extensively uses colors claiming that it improves the situation for the user:

<img alt="screenshot of ls and exa" src="/screenshot-2020-09-03-10:52:43.png" width=500>

The sorting is different, there are column headers, the group is abscent, and there are a lot of colors…
I know this is a question of taste, but for me these colors add no value at all.
They are even confusing for me, since I can't parse what kind of information they actually encode.

<img alt="second screenshot of ls and exa" src="/screenshot-2020-09-03-11:05:58.png" width=700>

Why are README and Makefile underlined and yellow?
Rewritten in Rust, but I don't see the real reason why this is important.
For learning Rust it is a nice project.
For actually improving the ecosystem, I am not sure.

### fd

[This tool](https://github.com/sharkdp/fd) sounds interesting:

> fd is a fast and user-friendly alternative to find, the built-in command-line program in Unix/Linux for walking a file hierarchy. fd provides opinionated defaults for the most common use cases. To find a specific file by name, you write `fd PATTERN` instead of `find -iname "*PATTERN*"`. fd is also extremely fast and it comes with a ton of options like ignoring hidden directories, files and patterns from .gitignore by default.

Let's try it in the kernel tree:

```
$ fd vcan.c
drivers/net/can/vcan.c
```

`find` is a little more complex:

```
$ find . -name vcan.c
./drivers/net/can/vcan.c
```

Nice!
I compared the performance of them with `time`, the result are quite the same.
Since I always forget the `find` flags and I always have to look them up in the manpage, I like this tool.
It is reasonably fast and it respects `.gitignore` files which is nice, too.
Regular expressions and globs are supported as well and most importantly it has a manpage.
Added to my interactive profile, `fd` is simple and in contrast to `find` easy to remember.

### dust

[This one](https://github.com/bootandy/dust) is really cool and actually an improvement over `du -sh`.

> dust is a more intuitive version of du, the built-in command-line program in Unix/Linux for displaying disk usage statistics. By default dust sorts the directories by size.

The delta to `du -sh` really is the graphical respresentation of the file and directory sizes.
Also the tool name ist well chosen, since it begins with the same letters plus the `-st` flags of `du`.
A picture shows it best:

<img alt="screenshot of ls and exa" src="/screenshot-2020-09-03-13:56:36.png" width=600>

I am not sure if I often need such a tool.
There is [`ncdu`](https://dev.yorhel.nl/ncdu) which is more powerful in the interactive profile.

### procs

[This tool](https://github.com/dalance/procs) claims to:

> procs is a modern replacement for ps, the default command-line program in Unix/Linux for getting information about processes. It provides convenient, human-readable (and colored) output format by default.

Let's check it out!
For comparison with the next picture I addet the `-t` flag for the tree view.

<img alt="screenshot of ls and exa" src="/screenshot-2020-09-03-15:25:00.png" width=600>

Okay.
Once again I am not sure which information is actually encoded by the colors.
For the automated profile it is not a replacement for `ps`.
In the interactive profile, there is `htop` for getting information about processes.
In contrast to `procs`, `htop` uses colors sparingly and the interface is well thought.
For example, colors are used to outline *differences*.
`root` is shown in a different color than my user.
The resource utilization columns use colors to highlight bytes, megabytes, and gigabytes differently.
The `procs` tool just colorizes everything in the same color which carries no information at all.

<img alt="screenshot of ls and exa" src="/screenshot-2020-09-03-15:27:27.png" width=600>

Further, in `htop` the tree view is designed that the user can follow the branches easily.
I leave comparing the visualization with the `procs` tool as an excercise to the reader.
These are the little differences where I prefer an old tool over a "modern" one.

### bat

A long time ago while learning Python I wrote [`c.py`](https://codeberg.org/rumpelsepp/c.py).
As a novice, I thought it might be a good idea to actually have this kind of functionality the [bat](https://github.com/sharkdp/bat) tool claims to have:

> bat is a cat clone with syntax highlighting and Git integration that works on Windows, MacOS and Linux. It provides syntax highlighting for many file extensions by default.

I can stop here.
Usually I fire up `nvim` and I have even more power.
I realized this very fact with my own tool and I abandoned it.
Syntax highlighting is a nice feature but the problem here is the scope of the tool.
It is not a text editor which has syntax highlighting builtin anyway.
So for me there is no added value.

### sd

Tho [sd](https://github.com/chmln/sd) tool (s[earch] & d[isplace]) claims:

> sd is an intuitive find & replace CLI.

I got tired of trying out each and every tool on my list.
The authors provide a really good example list, why this tool shines (and it is not about colors!).
I took the liberty to copy these examples from the README on Github:

- Simpler syntax for replacing all occurrences:
  - sd: `sd before after`
  - sed: `sed s/before/after/g`
- Replace newlines with commas:
  - sd: `sd '\n' ','`
  - sed: `sed ':a;N;$!ba;s/\n/,/g'`
- Extracting stuff out of strings containing slashes:
  - sd: `echo "sample with /path/" | sd '.*(/.*/)' '$1'`
  - sed: use different delimiters every time depending on expression so that the command is not completely unreadable
    - `echo "sample with /path/" | sed -E 's/.*(\\/.*\\/)/\1/g'`
    - `echo "sample with /path/" | sed -E 's|.*(/.*/)|\1|g'`
- In place modification of files:
  - sd: `sd before after file.txt`
  - sed: you need to remember to use `-e` or else some platforms will consider the next argument to be a backup suffix
    - `sed -i -e 's/before/after/g' file.txt`

I am not sure if I would actually use this tool, since it took me a long time to somehow master `sed`.
But it seems the authors designed the tool well and they thought about what needs to be done designing a user friendly search and replace tool.

### ripgrep

Coming from the [silver searcher](https://github.com/ggreer/the_silver_searcher), [ripgrep](https://github.com/BurntSushi/ripgrep) was my first Rust tool I used.

> ripgrep is an extremely fast alternative to grep, the built-in command-line program in Unix/Linux for searching files by pattern. ripgrep is a line-oriented search tool that recursively searches your current directory for a regex pattern. By default, ripgrep respects .gitignore and automatically skips hidden files, directories and binary files.

I use it every day and it just works.
The author himself provides a [comprehensive explanation](https://blog.burntsushi.net/ripgrep/).
I better refer to him in this case.

Features why I use it over `grep -r` are: speed and the fact that `.gitignore` files are respected.
Features why I use it over the silver searcher: It is written in Rust… :D
To be honest, the author's blog post convinced me a few years ago and I started using it.
I might be happy if im would still be using the silver searcher though…

## Final Thoughts

The Rust community is really productive and nice ideas are emerging.
Personally, I don't care if a tool is written in Rust, Perl, or Brainfuck as long as it solves a task and meets my requirements.
That should be the message of this blogpost: "(Re)Written in Rust" is not a feature or a reason to use a tool.
It is an implementation detail.
Please, dear Rust community, write software which actually improves the status quo.
There are great examples that actually do improve my workflow, like `ripgrep` (vs `grep`) and `fd` (vs `find`).
These examples improve my workflow because they are well designed for me as a *user*.
They do not improve my workflow because they are written in Rust.

---

[^1]: Taken from the homepage https://www.rust-lang.org/

[^2]: I mostly use Arch Linux, a bit Debian, and from time to time FreeBSD.
      I might even enforce POSIX variants of these tools, but it was not neccessary in the past.
      Here is a good reference about how to **not** publish software: https://drewdevault.com/2019/12/09/Developers-shouldnt-distribute.html

[^3]: git is a good example, since they provide `--porcelain` flags for some commands to ensure their output will never change its structure.

