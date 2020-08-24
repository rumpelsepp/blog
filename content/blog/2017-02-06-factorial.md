---
title: Factorial
---

As I am an electrical engineer, who realized that he likes computer science much
better than the stuff he learned at university for the last few years, I am in
some kind of dilemma... But that is actually not that bad, as I can start to
learn new things! :)

I bought a book about algorithms, just because I was confused all the time what
is this `f(x) = O(g(x))` stuff all about. I quickly found out, that I
pretty much suck at implementing (not to say understanding) algorithms. So, I
decided to start some "An Algorithm a Day" series as some kind of documentation
for my nightly activities in front of `nvim` and `atom`.

Actually "An Algorithm a Day" is a lie, I can't manage to understand and
implement an algorithm _every_ day. First, my girlfriend might kill me. Second,
as I mentioned earlier, I currently suck at implementing algorithms; that's the
reason I require infinite time to implement something properly. Third, I have
some kind of real life; I love cooking hanging around with friends and so on.
So, dear reader, expect that "An Algorithm a Day" might become "An Algorithm a
Week" or so.

Let's start with some simple math stuff. I decided to do some computation in
Python to get the factorial of a given number. The factorial is defined as such:

{{< figure alt="Rendered LaTex Formula: `n! = \prod_{k=1}^{n} k`" src="/factorial.png" width=100 >}}

That's pretty easy to implement in Python! Let's just do it!

``` python
def factorial(n):
    res = 1
    for i in range(1, n+1):
        res *= i
    return res
```

I also found out that this way of solving this problem is the so called
_iterative_ way. There is almost always another approach called _recursion_.
We can define the factorial also in a recursive manner:

{{< figure alt="Rendered LaTex Formula" src="/factorial_recursive.png" width=300 >}}

This means that we devide the problem into several problems of the same type;
each distinct problem is simpler to solve as the whole problem. This is
continued until the end condition, which in this case is `n == 0`.

The Python code finally looks like this:

``` python
def factorial(n):
    if n == 0:
        return 1
    if i > 0:
        return n * factorial(n-1)
```

Despite recursive algorithms seem to be the most elegant thing in the world of
computing, they IMO suck. You can reach the max. recursion depth rather quickly:

```
In [1]: f(2134123131)
---------------------------------------------------------------------------
RecursionError                            Traceback (most recent call last)
<ipython-input-5-98a27640969b> in <module>()
----> 1 f(2134123131)

<ipython-input-4-ce7906f37218> in f(n)
      3         return 1
      4     if n > 0:
----> 5         return n * f(n-1)
      6
      7

... last 1 frames repeated, from the frame below ...

<ipython-input-4-ce7906f37218> in f(n)
      3         return 1
      4     if n > 0:
----> 5         return n * f(n-1)
      6
      7

RecursionError: maximum recursion depth exceeded in comparison
```
