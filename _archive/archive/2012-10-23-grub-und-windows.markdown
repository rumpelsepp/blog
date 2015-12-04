---
layout: post
status: publish
published: true
title: Grub und Windows
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
wordpress_id: 68
wordpress_url: http://sevenbyte.org/?p=68
date: '2012-10-23 11:17:33 +0200'
date_gmt: '2012-10-23 09:17:33 +0200'
categories:
- General
tags:
- administrating
comments: []
---
<p>Ein Kurztipp zu (wieder mal) sp&auml;terer Stunde f&uuml;r Arch Linux und Grub. In der Standardkonfiguration erkennt der Grub kein Windows, das z.B. auf einer anderen Festplatte installiert ist. Es muss nur via Pacman das Paket `os-prober` installiert werden, und die Grub Config neu erstellt werden. Windows wird dann automatisch erkannt.</p>
<pre class="lang:sh decode:true ">pacman -S os-prober<br />
grub-mkconfig -o &#47;boot&#47;grub&#47;grub.cfg<&#47;pre></p>
