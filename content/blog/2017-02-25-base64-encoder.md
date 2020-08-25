---
title: Base64 Encoder
markup:
  goldmark:
    renderer:
      unsafe = true
---

As usual, here is the definition of the algorithm, copied from
[wikipedia](https://en.wikipedia.org/wiki/Base64), because I am so lazy.

> Base64 is a group of similar binary-to-text encoding schemes that represent
> binary data in an ASCII string format. The particular set of 64 characters
> chosen to represent the 64 place-values for the base varies between
> implementations. The general strategy is to choose 64 characters that are both
> members of a subset common to most encodings, and also printable. This
> combination leaves the data unlikely to be modified in transit through
> information systems, such as email, that were traditionally not 8-bit clean.
> For example, MIME's Base64 implementation uses A–Z, a–z, and 0–9 for the first
> 62 values. Other variations share this property but differ in the symbols
> chosen for the last two values; an example is UTF-7.

The algorithm is pretty simple. You take three input bytes and combine them
to to a `uint32_t`; let's call this `value`. Then you devide this `value`
in four sextets. Let's make an example.

| # | ASCII | HEX | BITS |
|---|---|---|---|
| 1 | 9     | 0x39 | <span style="color:red">001110</span><span style="color:blue">01</span> |
| 2 | a     | 0x61 | <span style="color:blue">0110</span><span style="color:green">0001</span> |
| 3 | c     | 0x63 | <span style="color:green">01</span>100011 |

This encodes to four sextets. Just concatenate the three bit patterns together
and make groupes of six (instead of eight). One sextet represents the index for
the base64 lookup table:

``` c
char *codes = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
```

| # | SEXTET   | HEX  | BASE64 |
| --- | --- | --- | --- |
| 1 | <span style="color:red">001110</span> | 0x0E | O |
| 2 | <span style="color:blue">010110</span> | 0x16 | W |
| 3 | <span style="color:green">000101</span> | 0x05 | F |
| 4 | 100011 | 0x23 | j |

## Padding

When the input is not dividable by three, there is the need of padding, since
the sextets---which are used to calculate the index of the encoded
char---cannot be calculated. [RFC4648](https://tools.ietf.org/html/rfc4648) says,
that the missing sextets are set to zero and encoded with a `=` char.

Our tables for the input `9a` would look like this:

| # | ASCII | HEX | BITS|
|---|---|---|---|
| 1 | 9     | 0x39 | 00111001|
| 2 | a     | 0x61 | 01100001|
| 3 |       | 0x00 | **00000000**|

| # | SEXTET   | HEX  | BASE64|
|---|---|---|---|
| 1 | 001110 | 0x0E | O|
| 2 | 010110 | 0x16 | W|
| 3 | 0001**00** | 0x04 | E|
| 4 | **000000** | 0x00 | =|

There are two sextets that changed, thus two encoding chars changed.
The padding was the part which took the most time to get right in the
C implementation...

One final hint, which is important. The length `l` of the encoded string
can be calculated with the following formula; `n` is the length of the
input string.

{{< figure alt="Rendeder LaTex formula: `l = \left \lceil{4 \cdot \frac{n}{3}}\right \rceil`" src="/ceil.png" width=100 >}}

I have implemented the `ceil` function in C with a macro:

``` c
#define CEIL(x) ((x) - (int) (x) > 0 ? (int) ((x) + 1) : (int) (x))
```

Please note, that the `x` has to be put in `()`, to ensure that the macro
works properly with expressions like this: `a + b + 1`. Otherwise the
operator priority might change your expected result to some crap...

*edit*: I forgot to add some notes about the padding length. Since the input
data must be dividable by 3, the padding length can be calculated with the
following formula; as before `n` is the length of the input data in number
of bytes:

{{< figure alt="Rendeder LaTex formula: `l_{\mathrm{pad}} = 3 - (n \mod 3)`" src="/base64_padding.png" width=200 >}}

## Implementation in C

Here is my implementation in C. I have verified it with Python's `base64`
module. It produces sane output. Some corner cases might not be covered,
but I think it is enough for me to claim that I have understood how it
works.

``` c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define CEIL(x) ((x) - (int) (x) > 0 ? (int) ((x) + 1) : (int) (x)) // <1>

void base64_encode(char *s, size_t len) {
	char *codes = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	size_t pad = 3 - (len % 3);  // <2>
	size_t enclen = CEIL(4.0 * (len / 3.0));  // <3>
	size_t k = 0;

	for (size_t i = 0; i < len; i += 3) {  // <4>
		uint32_t val = 0;

		int j = 0;  // <5>
		while (j < 3 && i + j < len) {
			val |= s[i+j] << ((2 - j) * 8);
			j++;
		}

		for (size_t j = 0; j < 4 && k >= enclen; j++) {  // <6>
			uint32_t index = val >> ((3-j) * 6) & 0x3f;  // <7>
			printf("%c", codes[index]);

			k++;
		}
	}

	for (size_t i = 0; i < pad; i++) {  // <8>
		printf("=");
	}
}

int main(int argc, char *argv[]) {
	char *input = "Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.";

	base64_encode(input, strlen(input));

	return EXIT_SUCCESS;
}
```

1. See previous section.
2. Calculate the padding length. When i.e. the input is 5 bytes long, then we have
    to add one padding byte that the length is dividable by 3.
3. See formula above.
4. Iterate over the input array. We take three bytes in one iteration step.
5. That one was tricky... We have to combine three bytes to a `uint32_t` in order
    to be able to generate the sextets. So, we shift the input bytes by `(2 - j) * 8`
    and then use the bitwise `OR` to combine the values. That's pretty straight forward.
    The reason for the `while` loop is, that one needs to be careful with the indexes.
    As one might have seen, we could potentially access memory outside the array with:
    `s[i+j]`. If padding is needed, we could be in trouble with this line of code.
    This problem is solved in the second condition of the `while` loop: `i + j < len`.
    If this is true, we must add padding. Since we shift the bytes to the left, we
    add the zero bytes automatically, so there is nothing left todo for adding padding.
6. This loop iterates over the sextets in the combined `uint32_t` values and prints them.
    In case of padding we must stop earlier. In my solution, i count the generated encoding
    chars in the variable `k` and stop when I reached `enclen` (remember the formula!).
7. Nice shit to extract the sextets. :)
8. Finally, add the padding `=` char.

This one took 30 minutes for me to implement the basic algorithm and 1,5 days to fix
the padding thing... I feel so stupid. :/
