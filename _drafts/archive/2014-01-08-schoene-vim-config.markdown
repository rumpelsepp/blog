---
layout: post
status: publish
published: true
title: Sch&ouml;ne vim config
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
excerpt: "Wie schon heute im <a title=\"Git-Log &uuml;bersichtlich darstellen\" href=\"http:&#47;&#47;sevenbyte.org&#47;2014&#47;01&#47;08&#47;git-log-uebersichtlich-darstellen&#47;\">Git-Artikel<&#47;a>
  gezeigt, versuche ich mir meine Arbeitswerkzeuge m&ouml;glichst effektiv und &uuml;bersichtlich
  einzurichten. Als Serveradministrator ist man z.B. auch sehr oft auf terminalbasierende
  Texteditoren angewiesen. Die Rede ist von vim.\r\n\r\nEiner hasst ihn, der andere
  liebt ihn. Ich mag ihn eigentlich nicht, benutze ihn aber trotzdem die ganze Zeit.
  Einen gro&szlig;en Beitrag dazu leistet aber auch die richtige Konfiguration mit
  den richtigen Plugins. Das Teil selbst zu konfigurieren habe ich mir gar nicht erst
  angetan. Ich habe in Github ein <a href=\"https:&#47;&#47;github.com&#47;amix&#47;vimrc\">Projekt<&#47;a>
  gefunden, das genau diesen Job erledigt. :) Installiert wird die Konfiguration wie
  folgt:"
wordpress_id: 137
wordpress_url: http://sevenbyte.org/?p=137
date: '2014-01-08 16:16:44 +0100'
date_gmt: '2014-01-08 15:16:44 +0100'
categories:
- General
tags:
- scripting
comments: []
---
<p>Wie schon heute im <a title="Git-Log &uuml;bersichtlich darstellen" href="http:&#47;&#47;sevenbyte.org&#47;2014&#47;01&#47;08&#47;git-log-uebersichtlich-darstellen&#47;">Git-Artikel<&#47;a> gezeigt, versuche ich mir meine Arbeitswerkzeuge m&ouml;glichst effektiv und &uuml;bersichtlich einzurichten. Als Serveradministrator ist man z.B. auch sehr oft auf terminalbasierende Texteditoren angewiesen. Die Rede ist von vim.</p>
<p>Einer hasst ihn, der andere liebt ihn. Ich mag ihn eigentlich nicht, benutze ihn aber trotzdem die ganze Zeit. Einen gro&szlig;en Beitrag dazu leistet aber auch die richtige Konfiguration mit den richtigen Plugins. Das Teil selbst zu konfigurieren habe ich mir gar nicht erst angetan. Ich habe in Github ein <a href="https:&#47;&#47;github.com&#47;amix&#47;vimrc">Projekt<&#47;a> gefunden, das genau diesen Job erledigt. :) Installiert wird die Konfiguration wie folgt:<a id="more"></a><a id="more-137"></a></p>
<pre class="lang:sh highlight:0 decode:true">git clone git:&#47;&#47;github.com&#47;amix&#47;vimrc.git ~&#47;.vim_runtime<br />
sh ~&#47;.vim_runtime&#47;install_awesome_vimrc.sh<&#47;pre><br />
Eine genaue Anleitung zu der Konfigurationssammlung steht auf der Github Seite. Ich denke aber, das Ergebnis kann sich wirklich sehen lassen.</p>
<p><a href="http:&#47;&#47;sevenbyte.org&#47;wp-content&#47;uploads&#47;2014&#47;01&#47;Bildschirmfoto-vom-2014-01-08-161156.png"><img class="alignnone size-full wp-image-139" src="http:&#47;&#47;sevenbyte.org&#47;wp-content&#47;uploads&#47;2014&#47;01&#47;Bildschirmfoto-vom-2014-01-08-161156.png" alt="Bildschirmfoto vom 2014-01-08 16:11:56" width="831" height="521" &#47;><&#47;a></p>
<p><strong>Problem mit Farben<&#47;strong></p>
<p>Wenn nach der Installation die Farben irgendwie komisch aussehen dann liegt es vermutlich an der TERM Variable.</p>
<pre class="lang:sh highlight:0 decode:true">export TERM=xterm-256color<&#47;pre><br />
Dadurch wird die Anzahl der verf&uuml;gbaren Farben auf 256 gesetzt. Die Standardeinstellung (wenn die Variable nicht gesetzt ist) betr&auml;gt 8 Farben. Zur dauerhaften L&ouml;sung des Problems packt man den obenstehenden Code z.B. in die ~.&#47;bashrc oder ~&#47;.zshrc.</p>
<p><strong>Nachtrag 15.05.2014<&#47;strong></p>
<p>Das integrierte "multicursor"-Plugin funktioniert bei den meisten Terminals nicht. Abhilfe schafft es</p>
<pre class="lang:zsh decode:true ">stty ixany<br />
stty ixoff -ixon<&#47;pre><br />
in die .zshrc zu packen.</p>
