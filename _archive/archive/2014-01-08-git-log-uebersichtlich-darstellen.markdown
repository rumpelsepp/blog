---
layout: post
status: publish
published: true
title: Git-Log &uuml;bersichtlich darstellen
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
excerpt: "Ich benutze fast ausschlie&szlig;lich Git um meine Programmierprojekte ordentlich
  zu versionieren. Mit der Zeit st&ouml;&szlig;t man aber auch immer auf bestimmte
  Sachen, die extrem nervig sind. Die &Uuml;bersicht, die git log ausgiebt, finde
  ich f&uuml;r meinen Teil eher suboptimal. Man erkennt zwar auf einen Blick die restlichen
  drei Commits, aber eine &Uuml;bersicht &uuml;ber die neusten &Auml;nderungen bekommt
  man eher nicht; ganz zu schweigen von einer &Uuml;bersicht &uuml;ber die aktuellen
  Branches! Zum Gl&uuml;ck l&auml;sst sich Git so konfigurieren, dass man sich ordentliche
  log Befehle selber bauen kann.\r\n\r\nMeine Log Befehle, die ich regelm&auml;&szlig;ig
  nutze, lauten wie folgt:\r\n<ul>\r\n\t<li>short log -> <span class=\"lang:default
  highlight:0 decode:true crayon-inline\">git slog<&#47;span><&#47;li>\r\n\t<li>short
  graphic log -> <span class=\"lang:default highlight:0 decode:true crayon-inline\">git
  sglog<&#47;span><&#47;li>\r\n\t<li>graphic log -> <span class=\"lang:default highlight:0
  decode:true  crayon-inline \">git glog<&#47;span><&#47;li>\r\n\t<li>normaler log
  -> <span class=\"lang:default highlight:0 decode:true  crayon-inline\">git log<&#47;span><&#47;li>\r\n<&#47;ul>\r\n"
wordpress_id: 122
wordpress_url: http://sevenbyte.org/?p=122
date: '2014-01-08 11:33:16 +0100'
date_gmt: '2014-01-08 10:33:16 +0100'
categories:
- General
tags:
- scripting
comments: []
---
<p>Ich benutze fast ausschlie&szlig;lich Git um meine Programmierprojekte ordentlich zu versionieren. Mit der Zeit st&ouml;&szlig;t man aber auch immer auf bestimmte Sachen, die extrem nervig sind. Die &Uuml;bersicht, die git log ausgiebt, finde ich f&uuml;r meinen Teil eher suboptimal. Man erkennt zwar auf einen Blick die restlichen drei Commits, aber eine &Uuml;bersicht &uuml;ber die neusten &Auml;nderungen bekommt man eher nicht; ganz zu schweigen von einer &Uuml;bersicht &uuml;ber die aktuellen Branches! Zum Gl&uuml;ck l&auml;sst sich Git so konfigurieren, dass man sich ordentliche log Befehle selber bauen kann.</p>
<p>Meine Log Befehle, die ich regelm&auml;&szlig;ig nutze, lauten wie folgt:</p>
<ul>
<li>short log -> <span class="lang:default highlight:0 decode:true crayon-inline">git slog<&#47;span><&#47;li>
<li>short graphic log -> <span class="lang:default highlight:0 decode:true crayon-inline">git sglog<&#47;span><&#47;li>
<li>graphic log -> <span class="lang:default highlight:0 decode:true  crayon-inline ">git glog<&#47;span><&#47;li>
<li>normaler log -> <span class="lang:default highlight:0 decode:true  crayon-inline">git log<&#47;span><&#47;li><br />
<&#47;ul><br />
<a id="more"></a><a id="more-122"></a></p>
<p><strong>git slog<&#47;strong></p>
<p><a href="http:&#47;&#47;sevenbyte.org&#47;wp-content&#47;uploads&#47;2014&#47;01&#47;Bildschirmfoto-vom-2014-01-08-111925.png"><img class="alignnone size-medium wp-image-125" alt="Bildschirmfoto vom 2014-01-08 11:19:25" src="http:&#47;&#47;sevenbyte.org&#47;wp-content&#47;uploads&#47;2014&#47;01&#47;Bildschirmfoto-vom-2014-01-08-111925-300x265.png" width="300" height="265" &#47;><&#47;a></p>
<p><strong>git sglog<&#47;strong></p>
<p><a href="http:&#47;&#47;sevenbyte.org&#47;wp-content&#47;uploads&#47;2014&#47;01&#47;Bildschirmfoto-vom-2014-01-08-112204.png"><img class="alignnone size-medium wp-image-128" alt="Bildschirmfoto vom 2014-01-08 11:22:04" src="http:&#47;&#47;sevenbyte.org&#47;wp-content&#47;uploads&#47;2014&#47;01&#47;Bildschirmfoto-vom-2014-01-08-112204-300x254.png" width="300" height="254" &#47;><&#47;a></p>
<p><strong>git glog<&#47;strong></p>
<p><a href="http:&#47;&#47;sevenbyte.org&#47;wp-content&#47;uploads&#47;2014&#47;01&#47;Bildschirmfoto-vom-2014-01-08-112311.png"><img class="alignnone size-medium wp-image-129" alt="Bildschirmfoto vom 2014-01-08 11:23:11" src="http:&#47;&#47;sevenbyte.org&#47;wp-content&#47;uploads&#47;2014&#47;01&#47;Bildschirmfoto-vom-2014-01-08-112311-300x237.png" width="300" height="237" &#47;><&#47;a></p>
<p><strong>git log<&#47;strong></p>
<p><a href="http:&#47;&#47;sevenbyte.org&#47;wp-content&#47;uploads&#47;2014&#47;01&#47;Bildschirmfoto-vom-2014-01-08-112354.png"><img class="alignnone size-medium wp-image-130" alt="Bildschirmfoto vom 2014-01-08 11:23:54" src="http:&#47;&#47;sevenbyte.org&#47;wp-content&#47;uploads&#47;2014&#47;01&#47;Bildschirmfoto-vom-2014-01-08-112354-221x300.png" width="221" height="300" &#47;><&#47;a></p>
<p>Um diese Befehle nutzen zu k&ouml;nnen, muss man nur die gitconfig entsprechend anpassen. Dazu &ouml;ffnet man mit einem beliebigen Texteditor die Datei ~&#47;.gitconfig.</p>
<pre class="lang:default highlight:0 decode:true">vim ~&#47;.gitconfig<&#47;pre><br />
Man f&uuml;gt jetzt folgende Sections hinzu:</p>
<pre class="lang:default highlight:0 decode:true" title="gitconfig">[color]<br />
    ui = true<br />
[alias]<br />
    glog = log --graph --decorate<br />
    slog = log --decorate --oneline<br />
    sglog = log --graph --decorate --oneline<&#47;pre><br />
Nun sollten die vorgestellten Befehle in Git verf&uuml;gbar sein. Falls man meine Alias-K&uuml;rzel nicht mag, kann man diese nat&uuml;rlich auch ab&auml;ndern.</p>
