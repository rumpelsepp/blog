+++
title = "Generating pdfs with Django and Latex"
+++

Generating pdfs in a webapplication often is tricky. The
[django docs](https://docs.djangoproject.com/en/1.7/howto/outputting-pdf/)
provide a chapter about generating pdfs with third party libraries. I don't
think I would like the result of these libraries, because I always use latex to
write scientific documents. So is it possible to use latex in a django
application? It is.

## Template

First of all we have to create our django latex template. Using latex code
instead of html code in django templates does not really matter. You only have
to take care of the curly brackets. So here is a minimal latex template for
django:

```
\documentclass{article}
\begin{document}
  {{ content }}
\end{document}
```

As you see I have created a latex document and I insert the django variable
content as usual with curly brackets. As we do not need automatic html-escaping
in our latex template we could switch this off by adding the appropriate
template tags:

`my_latex_template.tex`:

```
{% autoescape on %}
\documentclass{article}
\begin{document}
  {{ content }}
\end{document}
{% endautoescape %}
```

Be careful with adding variables in a latex clauses. You'll have to put spaces
around the square brackets like the following; otherwise django does not realize
that there is a variable.

```
\setkomavar{subject}{ {{ title }} }
```

## Function based view

Now we have to create our view which creates the pdf file for us. It is not that
difficult. I use a function based view for this porpose.

`views.py`:

``` python
from django.http import HttpResponse
from django.template import Context
from django.template.loader import get_template
from subprocess import Popen, PIPE
import tempfile
from .models import Entry

def entry_as_pdf(request, pk):
    entry = Entry.objects.get(pk=pk)  # <1>
    context = Context({  # <2>
            'content': entry.content,
        })
    template = get_template('my_latex_template.tex')
    rendered_tpl = template.render(context).encode('utf-8')  # <3>
    # Python3 only. For python2 check out the docs!
    with tempfile.TemporaryDirectory() as tempdir:  # <4>
        # Create subprocess, supress output with PIPE and
        # run latex twice to generate the TOC properly.
        # Finally read the generated pdf.
        for i in range(2):
            process = Popen(
                ['pdflatex', '-output-directory', tempdir],
                stdin=PIPE,
                stdout=PIPE,
            )
            process.communicate(rendered_tpl)
        with open(os.path.join(tempdir, 'texput.pdf'), 'rb') as f:
            pdf = f.read()
    r = HttpResponse(content_type='application/pdf')  # <5>
    # r['Content-Disposition'] = 'attachment; filename=texput.pdf'
    r.write(pdf)
    return r
```

1.  At first we have to do our database queries to be able to fill up the template
    with content.
2.  After that we create a Context object which will be sent to the template.
3.  We load our latex template and render it. We get the latex code with its
    content from the database; this code is available in the `rendered_tpl`
    variable.
4.  To generate the pdf we call pdflatex twice within a 
    [temporary directory](https://docs.python.org/3.4/library/tempfile.html?highlight=tempdir#tempfile.TemporaryDirectory)
    using [Popen](https://docs.python.org/3.4/library/subprocess.html#popen-constructor).
    The tempdir is removed automatically because we're using a
    [context manager](https://docs.python.org/3.4/reference/datamodel.html#context-managers).
5.  We read the generated pdf and write its content into the HttpResponse. If we
    uncomment the Content-Disposition line the pdf is downloaded automatically.
    Otherwise it could be displayed in the browser by browser plugins.

## URL Routing

To ensure that the pdf view works as expected we finally have to specify the
routing in our `urls.py` file:

``` python
from django.conf.urls import patterns, url
from . import views

urlpatterns = patterns(
    '',
    url(r'^entry/(?P<pk>\d+)\.pdf$',
    views.entry_as_pdf,
    name='entry_pdf'
)
```
