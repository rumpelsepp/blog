---
layout: post
status: publish
published: true
title: How to download rtmp streams?
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
wordpress_id: 181
wordpress_url: http://sevenbyte.org/?p=181
date: '2014-09-22 19:43:55 +0200'
date_gmt: '2014-09-22 17:43:55 +0200'
categories:
- General
tags:
- python
- scripting
comments:
- id: 4104
  author: Stefan Tatschner
  author_email: stefan@sevenbyte.org
  author_url: ''
  date: '2015-01-15 21:03:31 +0100'
  date_gmt: '2015-01-15 20:03:31 +0100'
  content: Latest theme update messed up this post. I will fix it some day...
---
<p>From wikipedia:</p>
<blockquote><p><b>Real Time Messaging Protocol<&#47;b> (<b>RTMP<&#47;b>) was initially a <a title="Proprietary protocol" href="http:&#47;&#47;en.wikipedia.org&#47;wiki&#47;Proprietary_protocol">proprietary protocol<&#47;a> developed by <a title="Macromedia" href="http:&#47;&#47;en.wikipedia.org&#47;wiki&#47;Macromedia">Macromedia<&#47;a> for <a title="Streaming media" href="http:&#47;&#47;en.wikipedia.org&#47;wiki&#47;Streaming_media">streaming<&#47;a> audio, video and data over the Internet, between a <a title="Adobe Flash" href="http:&#47;&#47;en.wikipedia.org&#47;wiki&#47;Adobe_Flash">Flash<&#47;a> player and a server. Macromedia is now owned by <a title="Adobe Systems" href="http:&#47;&#47;en.wikipedia.org&#47;wiki&#47;Adobe_Systems">Adobe<&#47;a>, which has released an incomplete version of the specification of the protocol for public use.<&#47;blockquote><br />
Many media sites (N24, zdf, ard, ...) use rtmp streams to prevent people&nbsp;from downloading the videos. Well, there is a little command line tool which allows downloading rtmp streams. It is called <a href="https:&#47;&#47;www.archlinux.org&#47;packages&#47;?name=rtmpdump">rtmpdump<&#47;a> and is available in the arch linux repositories.</p>
<p>To use rtmpdump you have to extract the required parameters from the html source code. For N24 it looks like this (<strong>it is really ugly!<&#47;strong>):<br />
<a href="http:&#47;&#47;pastebin.com&#47;raw.php?i=brF5DvUL">http:&#47;&#47;pastebin.com&#47;raw.php?i=brF5DvUL<&#47;a></p>
<p>To use rtmpdump we need to set the <strong>-r<&#47;strong>, <strong>-W<&#47;strong> and <strong>-y<&#47;strong> parameters; with <strong>-o<&#47;strong> we can specify a filename. An explanation of these parameters could be found with <strong>"<span class="lang:default highlight:0 decode:true  crayon-inline ">rtmpdump -h"<&#47;span><&#47;strong>.&nbsp;An appropriate rtmpdump call for the html code above would look like the following:</p>
<pre>rtmpdump \<br />
  -r "rtmp:&#47;&#47;pssimn24livefs.fplive.net:1935&#47;pssimn24&#47;" \<br />
  -W "http:&#47;&#47;www.n24.de&#47;_swf&#47;HomePlayer.swf?cachingVersion=2.66" \<br />
  -y "mp4:cm2013&#47;cmp&#47;e214&#47;89ed&#47;ac91&#47;30c0&#47;0a1db4af7089b0c05161ea2dcca58546_1000.mp4" \<br />
  -o "myvideo.mp4"<&#47;pre><br />
As you can see I have extracted these values from the <a href="http:&#47;&#47;pastebin.com&#47;raw.php?i=brF5DvUL">source code<&#47;a> of the website. For n24 it is:</p>
<ul>
<li><strong>-r<&#47;strong>: <code>_n24VideoCfg.flash.videoFlashconnectionUrl<&#47;code><&#47;li>
<li><strong>-W<&#47;strong>: <code>_n24VideoCfg.flash.SWFUrl<&#47;code>&nbsp;(you have to prepend the baseurl)<&#47;li>
<li><strong>-y<&#47;strong>: <code>_n24VideoCfg.flash.videoFlashSource<&#47;code><&#47;li><br />
<&#47;ul><br />
For simplification I have written a little python wrapper which extracts these parameters from a given URL and builds the rtmpdump command line string. I have puplished it as a <a href="https:&#47;&#47;gist.github.com&#47;rumpelsepp&#47;edd9bdfa4a8703a65f52">Gist on Github<&#47;a>.</p>
<p><strong>Does anybody know how I could fix this table below?<&#47;strong></p>
<p><script src="https:&#47;&#47;gist.github.com&#47;rumpelsepp&#47;edd9bdfa4a8703a65f52.js"><&#47;script></p>
