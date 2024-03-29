---
title: "FreeBSD and Blacklists in Go (or: My First Steps in Golang)"
---

Some people might remember my [first attempt](@/blog/2016-08-03-use-ssh-blacklists.md)
to download and validate ip addresses from public abuser blacklists in order to
apply them onto the FreeBSD firewall `ipfw`. This first attempt worked well;
but it  was a bit buggt though. I might fix these bugs and publish the
script on gist.github.com; it is nice and worked well.

But why am I writing this? I wanted to learn Go for quite a long time. Since I
am member of the Syncthing team on Github it is a shame for me that I cannot
write any Go code. So this is my first try to fix this issue. I decided to
rewrite this little Python script in Go and deploy it on my servers!

So, what it does is the same as the Python script. It fetches the preconfigured
ip blacklists, it validates the ip addresses properly and after I have made
384224093284032142 percent sure that the program has not downloaded any malicous
code, the ip addresses are applied to `ipfw`.

I have read a lot about the Go programming language and I really like the
concurrency capabilities and the complete toolchain. Also, Golang compiles to
statically linked binaries, such that I do not have to deal with any deploying
issues as in Python any more. Additionally, it is very easy to cross-compile for
other operating system by just setting (at max) two environment variables.

## Go as Beginner
### Download a Webpage via HTTP

So, I began with reimplementing of the downloading part of my Python script.
Golang comes with a cool stdlib that seems to be comparably "battaries included"
as Python's stdlib is. There is a sophisticated implementation of http
available and it works like this:

``` go
import (
	"log"
    "io/ioutil"
	"net/http"  // <1>
)

func fetch(link string) string {
	resp, err := http.Get(link)  // <2>
	if err != nil {
		log.Fatalln("HTTP GET failed; Terminating worker.")
	}
	defer resp.Body.Close()  // <3>

	body, err := ioutil.ReadAll(resp.Body)  // <4>
	if err != nil {
		log.Fatalln("Reading body failed; Terminating worker.")
	}

	return string(body)  // <5>
}
```

1.	I regard this as the same as the Python `import` stuff. It imports some
	package which is then available as `pkgname.method()`. The compiler will
	yell at you when you import unused packages. It will educate you as much
    as possible. You will hate that!
2.	File a http GET request. If something fails, `err` is not `nil`. This style
	of error handling is pretty cool in Go. Almost every function returns some
	`error` interface that is indented to be used by the caller to detect errors.
3.	That one is pretty cool; I love `defers`. A defered function call is scheduled
	by the runtime to be executed right after the current function returns. It is
	pretty easy to do some `foo.open()` and `foo.close()` stuff, because it is
	not neccessary to issue the close call in every program (error) path. By
	using `defer foo.close()` immediately after the corresponding `foo.open()` call
	it is guaranteed that the `foo.close()` call happens always after the current
	function returns; in every code path!
4. Read out the content of the body and store it in the `body` variable, which is
	returned by the function after everything finished without errors.
5.	IIRC the `body` contains bytes now; in order to return a `string` datatype it
	must be casted to `string` by a call to `string()`.

### Parse and Validate IP Addresses

That one is really important. As my "script" is intended to be run under `root`,
and it issues shell commands in order to alter firewall rules, it is really
important to make sure that it _only_ extracts ip addresses from the relevant
webpages; this is called input sanitizing. In my Python script I wrote some
`map()` foo and used the standard library to validate the ip addresses. Since Go
has no `map()` and I am not yet that experienced, I decided to use some regex
magic to extract the relevant strings and use the Go standard library to
validate those strings as well. IMO I am on the safe side using this way.

Not sharing the code would be boring, so here as another code snippet; I have
omitted the IPv6 address handling, since I have not tested this yet (it is on
[codeberg](https://codeberg.org/rumpelsepp/openbl/tree/master/fetch.go), though):

``` go
import (
	"errors"
	"net"
	"regexp"
)

// Regular expressions stolen from: http://ruilapa.net/2016/08/04/golang-ipv4-ipv6-regexp/
// Regexes slightly modified to use non capturing groups.
var (
	ipv4RE     = regexp.MustCompile(`(?:(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])`)
	ipv4CIDRRE = regexp.MustCompile(`(?:(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\/(?:3[0-2]|[1-2][0-9]|[0-9])`)
)

func extractIPsAndNetworks(rawStr string) (string, error) {
	// We do some sort of duplicated work here, but it is sane to filter the ip
	// address strings out of the untrusted output first, and then afterwards
	// do some parsing, to validate that the ip is actually correct and makes
	// sense as well. Also, we may be able to do some further checks in the future...
	addrStr := ipv4CIDRRE.FindString(rawStr)

	// Let's try all the different, ugly regexes and hope that they actually match...
	if addrStr == "" {
		addrStr = ipv4RE.FindString(rawStr)
	}

	if addrStr == "" {
		return "", errors.New("Not a valid ip address.")
	}

	// Not really necessary, as we have done all that regex foo before,
	// but it introduces one more layer of sanity check and enables
	// further checks using the methods from the go stdlib.
	if addr := net.ParseIP(addrStr); addr != nil {
		return addr.String(), nil
	}

	if _, network, err := net.ParseCIDR(addrStr); err == nil {
		// We don't need the addr, so let's only return the network.
		return network.String(), nil
	}

	return "", errors.New("Not a valid ip address.")
}
```

NOTE: I do double checks here. The first check is done with the gigantic regular
expression, the second check is performed using the Golang standard library. IMO
this is safer, as first, the potential ip addresses are extracted from some
untrusted input data. Second, those extracted strings are validated again by the
Go standard library [`net`](https://golang.org/pkg/net/) package. Since I am going
to use this program as root (in order to alter my firewall rules), I feel more
comfortable with an additional layer of security.

This time I leave out the black bubbles in the code, since the code is already
commented sufficiently. To sum up, this method returns either a string with a
valid ip address or `nil` and an error, sich that the caller can check if
something bad happened.

### Spawning Processes

The next task of our small programm is to spawn a subprocess (to be concrete:
`ipfw list` and so on) in order to alter the firewall rules of the relevant
server. In recent Python versions I am used to something like this:

``` python
import subprocess

subprocess.run(['ls', '-l', '-a'])
```

That's pretty easy and I like the simplicity, especially when I want to
implement simple scripts, that spawn some other programs. In C it is usually I
bit more cumbersome (but manageable); to come to the point, I was a bit worried
about subprocess handling in Go. Maybe my ported programm looks really nice, but
the subprocess handling is so ugly that I do not want to ever finish porting...
I found out that Go does a good job here!
[Spawning subprocesses](https://golang.org/pkg/os/exec/) is rather easy.

The job of spawning subprocesses in Go envolves writing a bit more code as the
Python version does, but it is also really easy. The official documentation
gives a few examples and it works basically like this:

``` go
import (
	"log"
	"os/exec"
	"regexp"
)

func ipfwPrepare() {
	// Scan if there is already a firewall table.
	out, err := exec.Command("ipfw", "list").Output()
	if err != nil {
		log.Fatal("ipfw command failed!")
	}

	// ...
}
```

The `stdout` is captured in the `out` variable; the return code ("error" code)
is available in `err`. So, errors can be handled using the well known Go
snippet `if err != nil { ... }`. If you are not interested in the `stdout` of
the subprocess, the call to `.Output()` can be replaced with `.Run()`, like
this:

``` go
	err = exec.Command("ipfw", "-qf", "table", "5", "flush").Run()
	if err != nil {
		log.Fatal("Flushing table failed!")
	}
```

If more customization is needed, the command struct, created by
`exec.Command()`, can be used to gain even more control about the created
subprocess. Everything can be found in the
[documentation](https://golang.org/pkg/os/exec/#Cmd).

## Advanced Go Foo

How is that stuff connected to do something useful? Go is quite good at this
job. There is a common pattern to spawn workers as Go-Routines; the routines
can then be connected using a shared channel in the main program loop. It
basically looks like this:

``` go
func mainLoop() {
	log.Println("Starting mainLoop().")

	nWorker := 0  // <1>
	ipAddresses := make(chan string, 100000)
	done := make(chan bool)

	// Fetch, parse and validate blacklists
	for _, link := range defaultBlacklists {  // <2>
		if debug {
			log.Println("Starting fetch worker.")
		}
		nWorker += 1
		go fetchBlacklist(link, ipAddresses, done)
	}

	// Receive ip strings from channel; afterwards, add them to the
	// appropriate firewall tables.
	i := 0
	for nWorker > 0 {  // <3>
		select {
		case ipAddr := <-ipAddresses:
			BlockIP(ipAddr)
		case <-done:
			if debug {
				log.Println("A fetch worker is done.")
			}
			nWorker -= 1
		}

		i++
	}

	log.Printf("Added %d addresses to firewall using %s backend.", i, firewallBackend)
	log.Println("Finished.")
}
```

The trick is to pass two channels to the worker functions. One channel to
receive data and another channel to receive a bool, that the worker has
finished. Go provides a mechanism to evaluate channels easily in a nonblocking
way: `select`.

1. Declare variables. We need a counter for the currently executing goroutines
	and, as mentioned before, two channels to receive data.
2. In this loop the worker goroutines `fetchBlacklist` are started. The
	two channels are passed to these functions and the worker counter `nWorker`
	is incremented.
3. That's the main loop of the program. We run the mainloop as long as the
	`nWorker` variable is greater than `0`; in other words as long as workers
	are being executed. The mainloop contains a `selcet` block which is used
	to read from multiple channels in a nonblocking way. If he output channel
	`ipAddresses` contains data, it is assigned to a local variable and
	further processed. If a worker terminates, it writes `true` to the `done`
	channel which causes the `nWorker` counter to be decremented.

## What's next?

I seem to like Golang a lot and I think it might become my new day to day
programming language (as Python was). So, for practicing purposes, I started a
project called [`i3gostatus`](https://codeberg.org/rumpelsepp/i3gostatus). It aims
to be a complete implementation for a `i3status` bar. Basically, it is port of
[`i3pystatus`](https://github.com/enkore/i3pystatus) in Go.
