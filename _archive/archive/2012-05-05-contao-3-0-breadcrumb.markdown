---
layout: post
status: publish
published: true
title: Contao 3.0 Breadcrumb
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
wordpress_id: 48
wordpress_url: http://sevenbyte.org/?p=48
date: '2012-05-05 10:54:31 +0200'
date_gmt: '2012-05-05 08:54:31 +0200'
categories:
- General
tags:
- scripting
comments: []
---
<p>In Contao 3 haben sich ein paar Templates ge&auml;ndert. Das Breadcrumb Modul benutzt jetzt f&uuml;r die Ausgabe eine ungeordnete Liste. Die genaueren Details kann man im entsprechenden Ticket <a href="https:&#47;&#47;github.com&#47;contao&#47;core&#47;issues&#47;1258" target="_blank">#1258<&#47;a> auf Github nachlesen. Die Einf&uuml;gung eines Trennzeichens gestaltet sich nun aber etwas abenteuerlicher wie fr&uuml;her. Ich habe mich f&uuml;r die CSS L&ouml;sung entschieden, da meiner Meinung nach die Trennzeichen nicht zum Content, sondern zum Design gez&auml;hlt werden sollen.</p>
<pre>.mod_breadcrumb li {<br />
    float:left;<br />
}</p>
<p>.mod_breadcrumb li:after {<br />
    content: " > ";<br />
    padding-left: 1px;<br />
    padding-right: 3px;<br />
}</p>
<p>.mod_breadcrumb li.active:after {<br />
    display: none;<br />
}<&#47;pre></p>
