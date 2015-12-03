---
layout: post
status: publish
published: true
title: Einen eigenen Firefox-Sync-Server aufsetzen
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
excerpt: "Ich habe lange Zeit Google Chrome verwendet, allerdings habe ich unter Linux
  immer wieder mit diversen Problemen zu k&auml;mpfen gehabt. Mittlerweile bin ich
  (wieder) gl&uuml;cklicher Firefox User. Als besonderes Schmankerl ist hier die integrierte
  Syncl&ouml;sung zu erw&auml;hnen. \"Klar die hat ja Chrome auch\" wird sich der
  eine oder andere denken. Aber Firefox bietet hier die Option einen eigenen Server
  zu verwenden.\r\n\r\nWenn man Besitzer eines kleinen vServers -- oder sogar eines
  Root Servers -- ist, kann mit einfachen Mitteln ein Sync Server installiert werden.
  Dazu kann man sich zuerst die (ziemlich schlechte) <a href=\"https:&#47;&#47;docs.services.mozilla.com&#47;howtos&#47;run-sync.html\"
  target=\"_blank\">offizielle Doku<&#47;a> anschaun. Ich betreibe meinen kleinen
  Sync Server mit einer PostgreSQL Datenbank und dem Apache Server mit mod_wsgi unter
  Arch Linux. Die nachfolgenden Befehle beziehen sich im speziellen auf Arch Linux,
  es sollte sich aber nicht allzu stark von anderen Distributionen unterscheiden."
wordpress_id: 4
wordpress_url: http://sevenbyte.org/?p=4
date: '2013-06-18 14:31:51 +0200'
date_gmt: '2013-06-18 12:31:51 +0200'
categories:
- General
tags:
- administrating
comments:
- id: 3303
  author: Stefan Tatschner
  author_email: stefan@sevenbyte.org
  author_url: ''
  date: '2014-10-23 12:20:47 +0200'
  date_gmt: '2014-10-23 10:20:47 +0200'
  content: Mittlerweile ist die Anleitung veraltet, da eine neue Version der Firefox
    Sync Engine ver&ouml;ffentlich wurde.
---
<p>Ich habe lange Zeit Google Chrome verwendet, allerdings habe ich unter Linux immer wieder mit diversen Problemen zu k&auml;mpfen gehabt. Mittlerweile bin ich (wieder) gl&uuml;cklicher Firefox User. Als besonderes Schmankerl ist hier die integrierte Syncl&ouml;sung zu erw&auml;hnen. "Klar die hat ja Chrome auch" wird sich der eine oder andere denken. Aber Firefox bietet hier die Option einen eigenen Server zu verwenden.</p>
<p>Wenn man Besitzer eines kleinen vServers -- oder sogar eines Root Servers -- ist, kann mit einfachen Mitteln ein Sync Server installiert werden. Dazu kann man sich zuerst die (ziemlich schlechte) <a href="https:&#47;&#47;docs.services.mozilla.com&#47;howtos&#47;run-sync.html" target="_blank">offizielle Doku<&#47;a> anschaun. Ich betreibe meinen kleinen Sync Server mit einer PostgreSQL Datenbank und dem Apache Server mit mod_wsgi unter Arch Linux. Die nachfolgenden Befehle beziehen sich im speziellen auf Arch Linux, es sollte sich aber nicht allzu stark von anderen Distributionen unterscheiden.<a id="more"></a><a id="more-4"></a></p>
<p>Es muss eine entsprechende PostgreSQL Datenbank und der Apache Webserver bereits eingerichtet sein. Nachfolgend muss man noch ein paar Abh&auml;ngigkeiten installieren.</p>
<pre class="lang:default highlight:0 decode:true">pacman -S python2 python2-virtualenv python2-psycopg2 mercurial mod_wsgi2<&#47;pre><br />
Der Sync Server ist in Python (Version 2) programmiert worden, dementsprechend m&uuml;ssen die n&ouml;tigen Python Bibliotheken im System vorhanden sein. Virtualenv dient dazu eine abgeschlossene Python Umgebung zu erstellen. Dabei werden zus&auml;tzliche Bibliothen ins Arbeitsverzeichnis geladen und dort relativ zueinander eingebunden. So k&ouml;nnen verschiedene Versionen gleichzeitig im System verwendet werden ohne Konflikte zu verursachen. Psycopg2 ist der PostgreSQL Datenbank Adapter f&uuml;r Python.</p>
<p>Das Versionsverwaltungssystem Mercurial wird anfangs nur dazu ben&ouml;tigt um den aktuellen Stand des Projektes vom Mozilla Projektserver herunterzuladen. Das Apache Modul mod_wsgi2 dient dazu, Python2 Anwendungen zu hosten. Nach dessen Installation muss man u.U. noch etwas in die Apache Config eintragen. Die Ausgabe von pacman hilft einem hier aber weiter.</p>
<p><strong>Installation<&#47;strong></p>
<p>Der Einfachkeit halber wird man erst einmal root, da man sich so das ewige `sudo` Ged&ouml;ns sparen kann. Hier ist aber Vorsicht geboten, dass man sein System nicht schrottet.</p>
<pre class="lang:default highlight:0 decode:true">sudo su<&#47;pre><br />
Anschlie&szlig;end wechselt man in das Verzeichnis wo die Serverapplikation hinein soll. Ich habe hierf&uuml;r das Standardverzeichnis `&#47;srv&#47;http&#47;` gew&auml;hlt. Mit dem anschlie&szlig;enden Befehl werden die Sourcen des Sync Servers in den Ordner `ffsync` geladen.</p>
<pre class="lang:default highlight:0 decode:true">hg clone "https:&#47;&#47;hg.mozilla.org&#47;services&#47;server-full ffsync"<&#47;pre><br />
In dem Ordner `&#47;srv&#47;http&#47;ffsync` muss jetzt der Server mit Hilfe von `virtualenv` gebaut werden. Dies bewerkstelligt man mittels.</p>
<pre class="lang:default highlight:0 decode:true"># cd falls noch nicht geschehen<br />
cd ffsync<br />
make build VIRTUALENV=virtualenv2<&#47;pre><br />
Nachdem alles erfolgreich gebaut worden ist, m&uuml;ssen noch ein paar Sachen konfiguriert werden. Die Configdatei `sync.conf` f&uuml;r den Sync Server befindet sich im Unterverzeichnis `etc`.</p>
<p>In der `storage` Section muss man seine Datenbankurl angeben. Zu beachten ist hier, dass der Name des PostgreSQL Adapters nicht `postgres` ist, wie in der original Dokumentation erw&auml;hnt ist, sonder `postgresql`.</p>
<pre class="lang:default highlight:0 decode:true">[storage]<br />
backend = syncstorage.storage.sql.SQLStorage<br />
sqluri = postgresql:&#47;&#47;user:passwort@localhost&#47;datenbank<br />
standard_collections = false<br />
use_quota = true<br />
quota_size = 5120<br />
pool_size = 100<br />
pool_recycle = 3600<br />
reset_on_return = true<br />
display_config = true<br />
create_tables = true<&#47;pre><br />
In der `auth` Section geht man analog vor.</p>
<pre class="lang:default highlight:0 decode:true">[auth]<br />
backend = services.user.sql.SQLUser<br />
sqluri = postgresql:&#47;&#47;user:passwort@localhost&#47;datenbank<br />
pool_size = 100<br />
pool_recycle = 3600<br />
create_tables = true<br />
# Uncomment the next line to disable creation of new user accounts.<br />
#allow_new_users = false<&#47;pre><br />
F&uuml;r die anderen Datenbankadapter, wie z.B. mysql, muss man in der Regel nur den Namen des Adapters in der URI anpassen. Sollte dann soweit auch funktionieren... F&uuml;r den Betrieb hinter einem Webserver muss man noch eine Fallback Node angeben (keine Ahnung was das ist). Man tr&auml;gt hier einfach die URL zum Server ein.</p>
<pre class="lang:default highlight:0 decode:true">[nodes]<br />
# You must set this to your client-visible server URL.<br />
fallback_node = http:&#47;&#47;yourhost<&#47;pre><br />
<strong>Apache einrichten<&#47;strong></p>
<p>Hurra, der Server ist installiert. Jetzt muss er nur noch per http erreichbar sein. Nichts leichter als das! Zuerst muss der entsprechende Virtual Host des Apaches angepasst werden, damit dieser mit `wsgi` zusammenarbeitet. Ich gehe mal davon aus, dass bekannt ist, was ein Virtual Host macht. Jedenfalls k&ouml;nnte eine passende Konfiguration so aussehn.</p>
<pre class="lang:apache highlight:0 decode:true"><VirtualHost *:80><br />
  ServerName MyHost<br />
  DocumentRoot "&#47;srv&#47;http&#47;ffsync&#47;"<br />
  WSGIProcessGroup ffsync<br />
  WSGIDaemonProcess ffsync user=ffsync group=ffsync processes=2 threads=25<br />
  WSGIPassAuthorization On<br />
  WSGIScriptAlias &#47; &#47;srv&#47;http&#47;ffsync&#47;sync.wsgi<br />
  ErrorLog &#47;var&#47;log&#47;httpd&#47;ffsync-error_log<br />
  CustomLog &#47;var&#47;log&#47;httpd&#47;ffsync-access_log common<br />
<&#47;VirtualHost><&#47;pre><br />
Dem aufmerksamen Leser wird nicht entgangen sein, dass ich etwas vergessen habe. Der virtuelle Host des Apache setzt einen User `ffsync` voraus. Dieser muss selbstverst&auml;ndlich im System vorhanden sein, damit alles funktioniert. Diesen und seine Gruppe legen wir mit `useradd` und `groupadd` an.</p>
<pre class="lang:default highlight:0 decode:true"># Gruppe erstellen<br />
groupadd ffsync</p>
<p># User erstellen mit der Gruppe ffync, Homeverzeichnis &#47;srv&#47;http&#47;ffsync<br />
# und der Shell &#47;bin&#47;false.<br />
useradd -g ffsync -d &#47;srv&#47;http&#47;ffsync -s &#47;bin&#47;false ffsync<&#47;pre><br />
Anschlie&szlig;end braucht der User die entsprechenden Besitzrechte auf den Ordner des Sync Servers. Dazu bedienen wir uns `chown`. Nicht vergessen, dass wir immer noch root sind.</p>
<p><strong>Anmerkung:<&#47;strong> Wenn er hier wegen `&#47;bin&#47;false` meckert, einfach in die Datei `&#47;etc&#47;shells` eintragen und nochmal probieren.</p>
<pre class="lang:default highlight:0 decode:true "># chown user:gruppe Ordner<br />
chown ffsync:ffsync -R ffsync<&#47;pre><br />
Abschlie&szlig;end muss noch der Apache mit `systemctl restart httpd` neu gestartet werden. Wenn kein Fehler beim Neustart auftaucht, schauts ganz gut aus. Zum Testen kann man jetzt die URL des VHost in der Firefox Sync unter "eigenen Server verwenden" eintragen und seine Lesezeichen auf den eigenen Server schieben.</p>
<p>Tipps zum Debuggen</p>
<ul>
<li>Firefox Sync Log: `about:sync-log`<&#47;li>
<li>Schaut immer zuerst in die `&#47;var&#47;log&#47;httpd&#47;ffsync-error_log` wenn etwas nicht funktioniert. Die Tracebacks k&ouml;nnen hilfreich sein, v.a. bei Tippfehlern.<&#47;li>
<li>Wenn der Apache nicht neu startet, probiert `journalctl -xn` aus.<&#47;li><br />
<&#47;ul><br />
Probleme bitte in die Kommentare, dann schaun wir mal ob wir sie l&ouml;sen k&ouml;nnen. Wenn ich etwas vergessen habe, bitte ich um Hinweise, dass ich den Artikel erg&auml;nzen kann. Danke :-)</p>
