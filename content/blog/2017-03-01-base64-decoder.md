---
title: Base64 Decoder
---

This is the continuation of the last post; now the decoder for the base64
format is presented. It is pretty much straight forward, since the decoder
generally reverses the encoding algorithm.

I will just show the code, since I have explained how base64 works in the last
post. Please forgive me for not having formatted the long strings properly, I
am just to lazy and I am sitting in the Munich subway after spending a working
day in neovim terminal windows.

``` c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

void base64_decode(char *s, size_t len) {
    // <1>
	static const char decoding[] = {62,0,0,0,63,52,53,54,55,56,57,58,59,60,61,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,0,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51};

	for (size_t i = 0; i < len; i += 4) {
		uint32_t val = 0;

		for (size_t j = 0; j < 4; j++) {  // <2>
			val |= (decoding[s[i+j]-'+'] & 0x3f) << ((3-j) * 6);
		}

		for (size_t j = 0; j < 3; j++) {  // <3>
			char dec_byte = (val >> ((2-j) * 8)) & 0xff;
			printf("%c", dec_byte);
		}
	}
}

int main(int argc, char *argv[]) {
	char *input = "TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlz\
IHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2Yg\
dGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGlu\
dWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRo\
ZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=";

	base64_decode(input, strlen(input));

	return EXIT_SUCCESS;
}
```

1. Again we have some lookup table. This somehow the lookup table from the encoder but ...
    the other way round. To be honest it is a bit more. It works like the following:
    We map base64 chars `[a-zA-Z\/=+]` to the relevant sextet. The key for the table lookup
    is the ascii value of the base64 char minus the offset of the character '+'. The indexes are
    just extracted from the ascii table. All  characters below `+` have been omitted because
    of being not relevant for the base64 alphabet. A call like `decoding['a'-'+']` means,
    please give the sextet that maps to the base64 character `a`. Since not all characters from
    the ascii table are relevant, there are some `0` in the lookup table.
2. Lookup the sextes from the lookup table and combine 4 of them to a 3 byte value. That
    is the reverse of the last step in the encoder.
3. Extract three single bytes and print them. The `=` char gets decoded to a zero byte and
    is thus not printed visibly.

In order to decode binary data which has been base64 encoded correctly, this
code has to be extended. I am aware of that problem, but since I do this series
to learn as much as possible and the main focus is understanding the principle
of algorithms, I am fine with this. :)
