---
layout: post
status: publish
published: true
title: Webkit Problem mit HTML5 search Input
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
wordpress_id: 64
wordpress_url: http://sevenbyte.org/?p=64
date: '2012-11-05 11:14:18 +0100'
date_gmt: '2012-11-05 09:14:18 +0100'
categories:
- General
tags:
- scripting
comments: []
---
<p>Mit der Verwendung von Goolge Chrome habe ich auf meinem Blog ein komisches Problem festgestellt. Das Suchfeld auf der "Suchen" Seite hatte ein etwas komisches Design. Kurioserweise hatte ich keine Chance per CSS auf dieses Suchfeld zuzugreifen und es zu gestalten.</p>
<p>Das input-Element wurde in HTML5 um verschiedene Typen erweitert, z. B. zur Eingabe von Suchbegriffen, Telefonnummern, URL- und E-Mail-Adressen, Datums- und Zeitangaben, Zahlen sowie Farbangaben. Ich vermute jetzt einfach mal, dass unter Webkit (die Rendering Engine von u.a. Chrome) die Implementierung einfach noch unvollst&auml;ndig ist.</p>
<p>Mit einem CSS Hack, den ich im Netz gefunden habe, l&auml;sst sich das Input Feld wieder wie gewohnt gestalten. Es wird auch der komisch anmutende "l&ouml;schen Button" aus dem Input Feld entfernt.</p>
<pre class="lang:css decode:true " >input[type="search"]::-webkit-search-decoration,<br />
input[type="search"]::-webkit-search-cancel-button,<br />
input[type="search"]::-webkit-search-results-button,<br />
input[type="search"]::-webkit-search-results-decoration<br />
{<br />
    display: none;<br />
}</p>
<p>input[type="search"]<br />
{<br />
    -webkit-appearance: textfield;<br />
}<&#47;pre> </p>
