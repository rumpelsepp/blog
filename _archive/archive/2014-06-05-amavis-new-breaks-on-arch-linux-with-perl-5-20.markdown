---
layout: post
status: publish
published: true
title: Amavis-new breaks on arch linux with perl 5.20
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
wordpress_id: 164
wordpress_url: http://sevenbyte.org/?p=164
date: '2014-06-05 11:14:04 +0200'
date_gmt: '2014-06-05 09:14:04 +0200'
categories:
- General
tags:
- administrating
comments: []
---
<p>The most recent <a href="https:&#47;&#47;www.archlinux.org&#47;news&#47;perl-updated-to-520&#47;">perl update<&#47;a> in arch linux has broken my email server. I use amavis-new from AUR with postfix to be able to use spamassassin. After the perl update I had these messages in my journal:</p>
<pre class="nums:false lang:default highlight:0 decode:true " >Jun 04 17:50:56 archvm amavisd[348]: $ = eval {...} called from file '&#47;usr&#47;lib&#47;perl5&#47;vendor_perl&#47;Unix&#47;Syslog.pm' line 0<br />
Jun 04 17:50:56 archvm amavisd[348]: $ = Amavis::Boot::BEGIN() called from file '&#47;usr&#47;lib&#47;perl5&#47;vendor_perl&#47;Unix&#47;Syslog.pm' line 0<br />
Jun 04 17:50:56 archvm amavisd[348]: $ = Amavis::Boot::fetch_modules('REQUIRED BASIC MODULES', 1, 'Exporter', 'POSIX', 'Fcntl', 'Socket', 'Errno', 'Carp', 'Time::HiRes', 'IO::Handle', 'IO::File', 'IO::Socket', 'IO::Socket::UNIX', 'IO::Str<br />
Jun 04 17:50:56 archvm amavisd[348]: $ = eval {...} called from file '&#47;usr&#47;bin&#47;amavisd' line 211<br />
Jun 04 17:50:56 archvm amavisd[348]: $ = require 'Unix&#47;Syslog.pm' called from file '&#47;usr&#47;bin&#47;amavisd' line 209<br />
Jun 04 17:50:56 archvm amavisd[348]: $ = DynaLoader::bootstrap('Unix::Syslog', 1.1) called from file '&#47;usr&#47;lib&#47;perl5&#47;vendor_perl&#47;Unix&#47;Syslog.pm' line 49<br />
Jun 04 17:50:56 archvm amavisd[348]: $ = eval {...} called from file '&#47;usr&#47;lib&#47;perl5&#47;core_perl&#47;DynaLoader.pm' line 216<br />
Jun 04 17:50:56 archvm amavisd[348]: Caught a SIGSEGV at &#47;usr&#47;lib&#47;perl5&#47;core_perl&#47;DynaLoader.pm line 216<&#47;pre> </p>
<p>With this <a href="https:&#47;&#47;git.server-speed.net&#47;users&#47;flo&#47;bin&#47;plain&#47;find-broken-perl-packages.sh">script<&#47;a> I realized that only a few perl packages needed to be rebuild (perl-convert-uulib perl-ipc-sharelite perl-unix-syslog). After rebuilding my mail server worked again.</p>
