---
title: "Use `tee` to Stream to a Process and Handle Ctrl+c"
date: 2021-10-24T10:42:16+02:00
---

Using the `tee` utility is often a nice method to save and view the output of a certain command at the same time.
I use `tee` for creating logfiles of long running commands.
The problem with this approach is that these files might grow to a gigantic size.
Since logfiles are usually just plain text they often compress very well.

The naive approch to accomplish compressed files with `tee` is something like this:

```
$ command | tee logfile.log
$ zstd logfile.log
```

The problem with this approach is: `logfile.log` occupies disk space and the subsequent compression command might takes a lot of time.
We can do better by using the `bash` process [substitution feature](https://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html).
With this feature it is possible to instruct `tee` to write to a command instead of a file.
Therefore, it is possible to easily implement a streaming compression and write compressed data to `logfile.log` directly.
Internally, `bash` creates a named pipe (= FIFO) and calls `tee` with the path to the temporary FIFO instead.
This FIFO is connected to the command which is specified in the process substitution invocation.
The two lines from above condense to this one liner:

```
$ command | tee >(zstd - -o logfile.log)
```

There is a problem!
When the pipeline is terminated via `ctrl+c` the created `logfile.log` will be truncated.
As far as I understand the problem, the SIGINT signal is sent to all members of the process group at the same time.
Thus, there might be unread data in the pipeline while `zstd` terminates the compressed `logfile.log` correctly according to the `zst` file format.

To solve this problem and ensure that no data is lost on `ctrl+c` the SIGINT signal must be blocked on all processes in the pipeline but the first one.
This can be done via a subshell where SIGINT is trapped.

```
$ command | (trap '' SIGINT; tee >(zstd - -o logfile.json))
```

Or when multiple commands are involved:

```
$ mask_sigint() (trap '' SIGINT; "$@")
$ command | mask_sigint tee >(zstd - -o logfile.json) | mask_sigint next_command | mask_sigint further_command
```

Using this pipeline `command` receives SIGINT, terminates properly, and the remaining pipeline is flushed.
No data is truncated any more.
