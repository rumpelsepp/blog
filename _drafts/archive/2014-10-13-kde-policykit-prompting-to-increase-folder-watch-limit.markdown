---
layout: post
status: publish
published: true
title: KDE Policykit prompting to increase Folder Watch Limit
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
wordpress_id: 233
wordpress_url: http://sevenbyte.org/?p=233
date: '2014-10-13 09:26:13 +0200'
date_gmt: '2014-10-13 07:26:13 +0200'
categories:
- General
tags:
- kde
- administrating
comments: []
---
<p>As mentioned <a href="https:&#47;&#47;bbs.archlinux.org&#47;viewtopic.php?id=180466#p1407397">here<&#47;a>&nbsp;the solution is to cleanup&nbsp;kde-nepomuk entries in&nbsp;<strong>&#47;etc&#47;sysctl.d<&#47;strong>. These entries are created on successful kauth authentication. The obsolete nepomuk entries overwrite the baloo entries.</p>
