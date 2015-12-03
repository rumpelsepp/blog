---
layout: post
status: publish
published: true
title: Nautilus verliert FTP Verbindung
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
wordpress_id: 77
wordpress_url: http://sevenbyte.org/?p=77
date: '2012-08-31 10:42:46 +0200'
date_gmt: '2012-08-31 09:42:46 +0200'
categories:
- General
tags:
- scripting
- administrating
comments: []
---
<p>Wenn man in Linux den Nautilus als Dateimanager verwendet, gibt es die M&ouml;glichkeit FTP Verzeichnisse direkt zu mounten (Datei&#47;Mit Server verbinden). Leider hat der Nautilus ein Problem mit Timeouts. Wenn der Server die Verbindung trennt, ist der Nautilus nicht in der Lage diese erneut aufzubauen und quittiert mit einem Fehler.</p>
<p>Als Workaround bietet es sich an, den Server regelm&auml;&szlig;ig mit Requests zu versorgen, damit die Verbindung nicht getrennt wird. Auf meine Frage hat ein User in ubuntuusers.de ein nettes Skript gepostet.</p>
<pre class="lang:sh decode:true ">#!&#47;bin&#47;bash</p>
<p>while true; do<br />
  # Liste die Inhalte aller Unterordner des Verzeichnisses auf.<br />
  ls &#47;Pfad&#47;zum&#47;FTP&#47;Ordner > &#47;dev&#47;null</p>
<p>  # 4 Minuten schlafen.<br />
  sleep 240;<br />
done<&#47;pre><br />
Dieses Skript fragt alle 4 Minuten nach dem Inhalt des FTP Ordners. Die Ausgabe wird durch die Umleitung nach `&#47;dev&#47;null` unterdr&uuml;ckt. Funktionstest positiv, nun hat Nautilus keine Probleme mehr.</p>
