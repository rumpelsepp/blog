---
layout: post
status: publish
published: true
title: Verlauf und Einstellungen per Dropbox abgleichen
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
wordpress_id: 66
wordpress_url: http://sevenbyte.org/?p=66
date: '2012-08-23 11:15:56 +0200'
date_gmt: '2012-08-23 09:15:56 +0200'
categories:
- General
tags:
- scripting
- administrating
comments: []
---
<p>Wenn man mehrere Rechner benutzt, taucht unter Umst&auml;nden das Problem auf dass der Verlauf auf jeden einzelnen PC verteilt ist. Gerade so, dass man nie das findet was man sucht... F&uuml;r Dropboxuser gibt es eine einfache M&ouml;glichkeit den Verlauf global abzugleichen.</p>
<p><strong>F&uuml;r Linuxuser<&#47;strong></p>
<p>Das Verzeichnis `~&#47;.purple` in die Dropbox kopieren und an der alten Stelle einen symbolischen Link mit dem Namen `.purple` erstellen.</p>
<pre class="lang:sh decode:true " >ln -s &#47;Pfad&#47;zur&#47;Dropbox&#47;.purple ~&#47;.purple<&#47;pre> </p>
<p><strong>F&uuml;r Windowsuser<&#47;strong></p>
<p>Im Prinzip ist das Vorgehen das gleiche. Die Verkn&uuml;pfung kann hier aber "einfacher" &uuml;ber den grafischen Weg erstellt werden. Das Profilverzeichnis von Pidgin befindet sich in: ``%APPDATA%&#47;Roaming&#47;.purple``</p>
<p>Vorsicht ist geboten, wenn man sich gerne gleichzeitig in mehreren Rechnern, z.B. am Desktoprechner und am Laptop einloggt. Dadurch kommt Dropbox leider durcheinander und legt lauter Konfliktdateien an. Wenn man seine Einstellungen und Verl&auml;ufe also korrekt abgleichen will, dann sollte man sich nur immer an einem Rechner einloggen.</p>
