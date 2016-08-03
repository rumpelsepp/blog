git-diff drivers and converters
===============================

Drop the respective wrapper script somewhere in your `$PATH`. An additional
converter has to be installed separately. The converter *must* convert the
file to plaintext. The diff driver is specified in `.gitconfig`.

To enable a filter/converter for a particular repo the respective glob
pattern have to be added to the `.gitattributes` file. To avoid cluttering
the project, or your personal `.gitconfig`, the repo wide files in
`$GIT_DIR/config` and `$GIT_DIR/info/attributes` can be used instead.

git-pdf2txt
-----------

Add to `.gitconfig`:

```
[diff "pdf"]
    textconv = git-pdf2txt
    cachetextconv = true
```

Add to `.gitattributes`:

```
*.pdf diff=pdf
```

Install this script:

```
pdftotext
```

On Arch Linux `pdftotext` is included in the `poppler` package.


git-docx2txt
------------

Add to `.gitconfig`:

```
[diff "docx"]
    textconv = git-docx2txt
    cachetextconv = true
```

Add to `.gitattributes`:

```
*.docx diff=docx
```

Install this script:

```
docx2txt.pl
```

`docx2txt.pl` can be obtained from:
http://sourceforge.net/projects/docx2txt/files/

On Arch Linux there is a package in AUR:
https://aur.archlinux.org/packages/docx2txt
