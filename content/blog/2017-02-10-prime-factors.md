---
title: Prime Factorization
---

This post might become rather short, but I just want to publish this right now.
I have done some experiments in the public transport with prime factorization.
First, what is prime factorization? [Wikipedia](https://en.wikipedia.org/wiki/Integer_factorization) says:

> In number theory, integer factorization is the decomposition of a composite
> number into a product of smaller integers. If these integers are further
> restricted to prime numbers, the process is called prime factorization.

In maths it would look somehow like this:

<img alt="Rendered LaTex Formula: `n=p_{1}^{{\;\;e_{1}}}\cdot p_{2}^{{\;\;e_{2}}}\dotsm p_{M}^{{\ \ e_{M}}}=\prod _{{k=1}}^{{M}}p_{k}^{{\;\;e_{k}}}`" src="/prime-formula.png" width=300>

There are a lot of methods to accomplish the given task of compositing a number
into a product of primes. I just want to present the IMO most naive and straight
forward one. Actually it was the first algorithm that came in my mind while
sitting in the public transport next to strange people...

``` python
import math

def fac(n):
    res = []
    while n > 1:
        until = int(math.sqrt(n)) + 1
        for i in range(2, until):
            if n % i == 0:
                res.append(i)
                n /= i
                break
        else:
            res.append(int(n))
            return res
    return res
```

This should be straight forward to understand, as it is some kind of brute force
method. There is basically a loop which counts from `2` to `sqrt(n)`.
The reason for is: if I divide a number `x` into its factors, the greatest
possible factor is `sqrt(x)`. It is somehow the "half" in the domain of
multiplication. I am too lazy to search a formal correct proof. If somebody has
one that I can include in this blogpost please let me know.

Yeah, the rest is trivial. The algorithm checks if the current counter `i` divides
`n`. When that's possible, we have found a prime factor. If the inner loop
runs until its end, then `n` must be a prime itself.

Bonus points: For the next prime number we divide `n` by `i` and start again!

Bonus points 2: Why are the found numbers primes? Because we count from `0` to
`sqrt(n)` and not the other way round. The first numbers we find are the primes.
