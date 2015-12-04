---
layout: post
status: publish
published: true
title: Problems with systemd-timesyncd
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
wordpress_id: 161
wordpress_url: http://sevenbyte.org/?p=161
date: '2014-06-05 09:22:38 +0200'
date_gmt: '2014-06-05 07:22:38 +0200'
categories:
- General
tags:
- administrating
- systemd
comments: []
---
<p>Using the new <strong>systemd-timesyncd<&#47;strong> caused problems on my machine. The daemon started properly but it did not sync time. I got the answer on <a title="google plus" href="https:&#47;&#47;plus.google.com&#47;u&#47;0&#47;+CristianRodriguezR&#47;posts&#47;7XaqTDxYoak" target="_blank">google plus<&#47;a>. <strong>systemd-networkd<&#47;strong> has to be enabled for using <strong>systemd-timesyncd<&#47;strong>.</p>
<p><strong>Update:&nbsp;<&#47;strong>This issue is solved in recent systemd versions!</p>
