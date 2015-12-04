---
layout: post
status: publish
published: true
title: vmware(player) zu virtualbox
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
excerpt: Linuxsysteme in allen Ehren, aber hin und wieder kommt man um eine virtuelle
  Maschine nicht herum. Ich habe mir vor einiger Zeit in meinem Arch Linux eine vmware
  Windows 7 Maschine aufgesetzt. Immer wenn ich zwingend auf Windows angewiesen war,
  konnte ich "schnell mal" die VM starten. Propriet&auml;re Software bringt aber eigentlich
  fast immer mehr Probleme als sie l&ouml;sen.
wordpress_id: 118
wordpress_url: http://sevenbyte.org/?p=118
date: '2014-01-08 10:55:10 +0100'
date_gmt: '2014-01-08 09:55:10 +0100'
categories:
- General
tags:
- administrating
comments: []
---
<p>Linuxsysteme in allen Ehren, aber hin und wieder kommt man um eine virtuelle Maschine nicht herum. Ich habe mir vor einiger Zeit in meinem Arch Linux eine vmware Windows 7 Maschine aufgesetzt. Immer wenn ich zwingend auf Windows angewiesen war, konnte ich "schnell mal" die VM starten. Propriet&auml;re Software bringt aber eigentlich fast immer mehr Probleme als sie l&ouml;sen.<a id="more"></a><a id="more-118"></a></p>
<p>Ich hatte die Nase voll und wollte zu virtualbox wechseln, das bequem aus den offiziellen Paketen installieren kann. Eine Konvertierung zwischen den virtuellen Festplattenformaten muss man mittlerweile nicht mehr vornehmen, da virtualbox das von vmware verwendete vmdk Format nativ unterst&uuml;tzt. Prinzipiell muss man nur eine neue virtuelle Maschine in virtualbox erstellen und die Festplattendatei von vmware ausw&auml;hlen.</p>
<p>Beim Hochstarten kam es bei mir aber zu einem Problem: Windows begr&uuml;&szlig;t mich mit einem Bluescreen und versucht verzweifelt den Systemstart zu "reparieren". Nach einem kurzem Blick in der Konfiguration von virtualbox ist mir aufgefallen, dass die vmware Festplatte automatisch &uuml;ber einen SATA Controller im AHCI Modus an die vm angebunden wird. Bei Windows war es so, dass man -- wenn man AHCI nutzen m&ouml;chte -- Windows auch bereits im AHCI Modus installieren muss. Bei einer nachtr&auml;glichen &Auml;nderung (z.B. im BIOS) kam es zum Bluescreen.</p>
<p><a href="http:&#47;&#47;sevenbyte.org&#47;wp-content&#47;uploads&#47;2014&#47;01&#47;Bildschirmfoto-vom-2014-01-08-105347.png"><img class="alignnone size-medium wp-image-119" alt="Bildschirmfoto vom 2014-01-08 10:53:47" src="http:&#47;&#47;sevenbyte.org&#47;wp-content&#47;uploads&#47;2014&#47;01&#47;Bildschirmfoto-vom-2014-01-08-105347-300x170.png" width="300" height="170" &#47;><&#47;a></p>
<p>Zur L&ouml;sung des Problems muss man die vmware Festplattendatei &uuml;ber einen IDE Controller an die vm anbinden (siehe Screenshot) und die Kiste startet einwandfrei.</p>
