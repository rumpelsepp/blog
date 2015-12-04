---
layout: post
status: publish
published: true
title: Seltsame Festplattenaktivit&auml;t bei neuer ext4 Festplatte
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
excerpt: "Neulich habe ich mich &uuml;ber eine ungew&ouml;hnliche Aktivit&auml;t meiner
  neuen Festplatte in Ubuntu gewundert. Regelm&auml;&szlig;ig wird ein Zugriff auf
  die Platte gestartet, wobei die Platte selber noch komplett leer ist. Wenn ich die
  entsprechende Platte per umount aush&auml;nge, sind die Zugriffe weg.\r\n\r\n"
wordpress_id: 53
wordpress_url: http://sevenbyte.org/?p=53
date: '2012-08-07 11:03:05 +0200'
date_gmt: '2012-08-07 09:03:05 +0200'
categories:
- General
tags:
- administrating
comments: []
---
<p>Neulich habe ich mich &uuml;ber eine ungew&ouml;hnliche Aktivit&auml;t meiner neuen Festplatte in Ubuntu gewundert. Regelm&auml;&szlig;ig wird ein Zugriff auf die Platte gestartet, wobei die Platte selber noch komplett leer ist. Wenn ich die entsprechende Platte per umount aush&auml;nge, sind die Zugriffe weg.</p>
<p><a id="more"></a><a id="more-53"></a></p>
<p><strong>Vorgeschichte<&#47;strong></p>
<p>Ich habe es endlich durchgezogen und bin von Windows zu Ubuntu 12.04 umgezogen. Die angestaubte Creative X-Fi habe ich durch eine Asus Xonar ersetzt, der Rest meiner Hardware lief out of the box. Nachdem ich meine Datenstruktur entsprechend umsortiert habe, habe ich eine meiner zwei 2TB Festplatten mit dem Linuxdateisystem ext4 formatiert und per fstab statisch ins `&#47;mnt` Verzeichnis eingebunden.</p>
<pre class="lang:default highlight:0 decode:true">UUID="beaffd24-2f64-4883-96bf-7564702aa1f7" &#47;mnt&#47;TeraWD&#47; ext4 defaults 0 2<&#47;pre><br />
Der Aufbau der `&#47;etc&#47;fstab` ist im Ubuntuusers-Wiki sehr gut beschrieben. Die UUID steht f&uuml;r Universally Unique Identifier und bezeichnet nach einem bestimmten Standard formatierte Identifikationsnummern. Durch Verwendung der UUID** ist es egal wenn man sp&auml;ter die Festplatte am Controller anders anschlie&szlig;t und sich z.B. die Bezeichnung `&#47;dev&#47;sda` in `&#47;dev&#47;sdb` &auml;ndert.</p>
<p>Man findet seine UUID folgenderma&szlig;en heraus:</p>
<pre class="lang:sh decode:true">sudo blkid &#47;dev&#47;sda1<&#47;pre><br />
Funktionierte soweit einwandfrei, nur ich habe mich st&auml;ndig &uuml;ber regelm&auml;&szlig;ige I&#47;O Zugriffe auf die Festplatte gewundert, wie ich auch hier gefragt habe.</p>
<p><strong>L&ouml;sung des R&auml;tsels<&#47;strong></p>
<p>Nach einem block_dump habe ich herausgefunden, dass das Feature Lazy Initialization f&uuml;r die regelm&auml;&szlig;igen Zugriffe verantwortlich ist. Der aktivierte Block Dump schreibt Zugriffe der Festplatte ins Syslog. <strong>Aber Achtung: Die Logdatei kann sehr schnell sehr gro&szlig; werden!<&#47;strong></p>
<blockquote><p>Beim Erstellen eines ext4-Filesystems m&uuml;ssen die vorhandenen Bereiche der Inode-Tabellen bereinigt werden (mit Nullen &uuml;berschrieben - "zeroed"). Das Feature lazyinit" soll das Anlegen eines Filesystems deutliche beschleunigen, indem es beim Erstellen nicht sofort alle Inode-Tabellen initialisiert, sondern dies erst nach und nach beim erstem Mount im Hintergrund durchf&uuml;hrt (ab Kernel-Version 2.6.37).<&#47;blockquote><br />
Quelle: <a href="http:&#47;&#47;www.thomas-krenn.com&#47;de&#47;wiki&#47;Ext4_Dateisystem">http:&#47;&#47;www.thomas-krenn.com&#47;de&#47;wiki&#47;Ext4_Dateisystem<&#47;a></p>
<p>Die Zugriffe sind denkbar einfach behoben. Man muss einfach nur ein paar Stunden warten, dann erledigt sich das Problem von selbst. Ich hatte mich anfangs nur sehr gewundert und bin der Sache mal auf den Grund gegangen.</p>
