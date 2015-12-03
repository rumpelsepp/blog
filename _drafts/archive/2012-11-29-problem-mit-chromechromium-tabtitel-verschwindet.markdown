---
layout: post
status: publish
published: true
title: 'Problem mit Chrome&#47;Chromium :: Tabtitel verschwindet'
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
excerpt: "Folgendes Problem hatte ich auf https:&#47;&#47;bbs.archlinux.de&#47; gemeldet,
  wo mir aber keiner weiterhelfen konnte.\r\n<blockquote>Serwus,\r\nseit gestern habe
  ich mit Chrome und Chromium ein komisches Problem. Bei mir verschwindet bei manchen
  Webseiten (Gmail, Django Projekt, Youtube...) immer der Titeltext auf den Tabs.
  Konkret handelt es sich also um den Inhalt des title-HTML Tags. Seit gestern erscheint
  auf manchen Seiten bei mir nur noch das Favicon und der Rest der Fl&auml;che eines
  Tabs ist leer.<&#47;blockquote>\r\nIch bin momentan etwas ratlos und weis nicht
  genau wo ich anfangen soll zu suchen. Hat jemand das gleiche Problem?\r\n\r\nLink
  zum Forumpost: <a href=\"https:&#47;&#47;bbs.archlinux.de&#47;viewtopic.php?id=22810\">https:&#47;&#47;bbs.archlinux.de&#47;viewtopic.php?id=22810<&#47;a>\r\n\r\n"
wordpress_id: 70
wordpress_url: http://sevenbyte.org/?p=70
date: '2012-11-29 11:28:01 +0100'
date_gmt: '2012-11-29 10:28:01 +0100'
categories:
- General
tags:
- administrating
comments: []
---
<p>Folgendes Problem hatte ich auf https:&#47;&#47;bbs.archlinux.de&#47; gemeldet, wo mir aber keiner weiterhelfen konnte.</p>
<blockquote><p>Serwus,<br />
seit gestern habe ich mit Chrome und Chromium ein komisches Problem. Bei mir verschwindet bei manchen Webseiten (Gmail, Django Projekt, Youtube...) immer der Titeltext auf den Tabs. Konkret handelt es sich also um den Inhalt des title-HTML Tags. Seit gestern erscheint auf manchen Seiten bei mir nur noch das Favicon und der Rest der Fl&auml;che eines Tabs ist leer.<&#47;blockquote><br />
Ich bin momentan etwas ratlos und weis nicht genau wo ich anfangen soll zu suchen. Hat jemand das gleiche Problem?</p>
<p>Link zum Forumpost: <a href="https:&#47;&#47;bbs.archlinux.de&#47;viewtopic.php?id=22810">https:&#47;&#47;bbs.archlinux.de&#47;viewtopic.php?id=22810<&#47;a></p>
<p><a id="more"></a><a id="more-70"></a></p>
<p>Da mir bei meinem Problem keiner weiterhelfen konnte, habe ich nun nach l&auml;ngerer Recherche das Problem selbst gefunden. Es liegt an einem Update der Pakete xorg-server und pixman (gegebenenfalls auch noch cairo). Ein Downgrade der betroffenen Pakete hat das Problem gel&ouml;st.</p>
<pre class="lang:default highlight:0 decode:true">pixman (0.28.0-1 => 0.26.2-1)<br />
xorg-server (1.13.0-4 => 1.13.0-3)<br />
(cairo 1.12.8-2 => 1.12.8-1)<&#47;pre><br />
<strong>Workaround f&uuml;r die L&ouml;sung :: Pakete downgraden<&#47;strong></p>
<p>Bis das Problem seitens der Paketmaintainer gefixt wird, bleibt dem Arch Linux User nichts anderes &uuml;brig als selbst ein bisschen an Pacman Hand anzulegen. Als erstes muss man sich die "veralteten" Paketdateien beschaffen. Dabei gibt es mehrere M&ouml;glichkeiten.</p>
<ul>
<li>Der g&uuml;nstigste Fall ist es, wenn die alte Paketdatei (auf Versionsnummer achten) noch im Pacman Cache liegt. Dazu einfach den Inhalt des Verzeichnisses ``&#47;var&#47;cache&#47;pacman&#47;pkg`` mit dem Lieblingsdateimanager checken.<&#47;li>
<li>Wenn die Dateien nicht mehr vorhanden sind, z.B. wenn man regelm&auml;&szlig;ig ein ``pacman -Scc`` ausf&uuml;hrt, dann kann man sich der Arch Rollback Machine bedienen und dort die Pakete herunterladen.<&#47;li><br />
<&#47;ul><br />
Der Befehl f&uuml;r das Downgraden der Pakete lautet nun folgenderma&szlig;en: `pacman -U &#47;pfad&#47;zum&#47;paket`</p>
<p>Zum Beispiel so:</p>
<pre class="lang:default highlight:0 decode:true">pacman -U &#47;home&#47;user&#47;Downloads&#47;cairo-1.12.8-1-i686.pkg.tar.xz<&#47;pre><br />
<strong>Pakete f&uuml;r weiteres Update sperren<&#47;strong></p>
<p>Wenn das Downgrade funktioniert hat, dann ist es klug die betroffenen Pakete f&uuml;r ein weiteres Update zu sperren. Ansonsten w&uuml;rden beim n&auml;chsten ``pacman -Syu`` die Pakete erneut auf die fehlerhafte Version geupdated werden. Dazu &ouml;ffnet man in einem Terminal mit nano die Datei ``&#47;etc&#47;pacman.conf``.</p>
<pre class="lang:default highlight:0 decode:true">nano &#47;etc&#47;pacman.conf<&#47;pre><br />
Mit IgnorePkg kann man beliebige Pakete f&uuml;r ein Update sperren. Man muss hier jetzt also nur `cairo`, `pixman` und `xorg-server eintragen`. Mit `strg + o` und `strg + x` speichert man die Datei und beendet `nano`. Der entsprechende Abschnitt der `pacman.conf` sollte jetzt folgenderma&szlig;en aussehen.</p>
<pre class="lang:default highlight:0 decode:true"># Pacman won't upgrade packages listed in IgnorePkg and members of IgnoreGroup<br />
IgnorePkg = cairo pixman xorg-server<br />
#IgnoreGroup =<&#47;pre><br />
Wenn alles richtig funktioniert hat, sollte beim n&auml;chsten `pacman -Syu` folgende Warnung im Terminal ausgegeben werden.</p>
<pre class="lang:default highlight:0 decode:true">:: Starte komplette Systemaktualisierung...<br />
Warnung: pixman: Ignoriere Paket-Aktualisierung (0.26.2-1 => 0.28.0-1)<br />
Warnung: xorg-server: Ignoriere Paket-Aktualisierung (1.13.0-3 => 1.13.0-4)<&#47;pre><br />
Wenn das Problem seitens der Paketmaintainer gefixt wurde, kann man die Sperrung wieder r&uuml;ckg&auml;ngig machen, indem man die Paketnamen wieder aus der pacman.conf entfernt und eine Raute f&uuml;r die Zeile IgnorePkg setzt. Momentan ist es aber n&ouml;tig, wenn man funktionierende Tabs in Chrome&#47;Chromium haben m&ouml;chte.</p>
<p><strong>Quellen<&#47;strong></p>
<p>Ich m&ouml;chte euch nat&uuml;rlich meine Quellen f&uuml;r diese L&ouml;sung nicht vorenthalten. Sollte mein L&ouml;sungsvorschlag bei dem einen oder anderen nicht funktionieren bieten sich hier noch weitere Lesetipps.</p>
<ul>
<li><a href="https:&#47;&#47;bbs.archlinux.org&#47;viewtopic.php?id=152753">https:&#47;&#47;bbs.archlinux.org&#47;viewtopic.php?id=152753<&#47;a><&#47;li>
<li><a href="https:&#47;&#47;bbs.archlinux.org&#47;viewtopic.php?id=153148">https:&#47;&#47;bbs.archlinux.org&#47;viewtopic.php?id=153148<&#47;a><&#47;li>
<li><a href="http:&#47;&#47;code.google.com&#47;p&#47;chromium&#47;issues&#47;detail?id=160505">http:&#47;&#47;code.google.com&#47;p&#47;chromium&#47;issues&#47;detail?id=160505<&#47;a><&#47;li>
<li><a href="https:&#47;&#47;wiki.archlinux.org&#47;index.php&#47;Downgrading_Packages">https:&#47;&#47;wiki.archlinux.org&#47;index.php&#47;Downgrading_Packages<&#47;a><&#47;li><br />
<&#47;ul></p>
