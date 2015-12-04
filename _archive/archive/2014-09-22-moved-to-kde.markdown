---
layout: post
status: publish
published: true
title: Moved to KDE
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
wordpress_id: 188
wordpress_url: http://sevenbyte.org/?p=188
date: '2014-09-22 18:32:00 +0200'
date_gmt: '2014-09-22 16:32:00 +0200'
categories:
- General
tags:
- gnome
- kde
comments: []
---
<p>I was a very happy Gnome user from version 3.4 until 3.8. &nbsp;The Gnome Community shares the opinion that everything should be as easy as possible without any compromise. This design approach may be great but I believe that Gnome turns&nbsp;more and more an android like interface. Gnome gains fancy&nbsp;new applications with every release (e.g. Gnome Music, Gnome Photo, Gnome Maps...) but these applications are hardly useful as they are nothing else as mockups.</p>
<p>Some new apps might duplicate things as well. There is Gnome Contacts which seems to provide evolution's addressbook. Furthermore I don't really know what I am supposed to do with Gnome Documents. I could use evince for reading pdfs, couldn't I? The other thing which drives me mad is evolution itself. I do like to have a full groupware application but evolution's workflow is just odd:</p>
<ul>
<li>No drag and drop support in the calender (except the working week view).<&#47;li>
<li>You have to click all over the place just for saving a new event.<&#47;li>
<li>Sometimes remote addressbooks&nbsp;get lost (gmail, davical, ...). I&nbsp;often have to reload these addressbooks because autocompletion in the email composer does not work any more.<&#47;li>
<li>Evolution syncs very slowly with calendars and caldav tak lists.<&#47;li>
<li>...<&#47;li><br />
<&#47;ul><br />
I have tested the new Gnome 3.14 pre-release with the gnome-unstable repository under arch linux and I have come to the conclusion that I have to try something new. I personally do not like what they did with nautilus, evince, gedit, totem and the dialoges. I did like totem for watching videos because of the really great integration into Gnome. But now it is unusable... It does not even support playlists any more!&nbsp;Finally I decided to try out KDE once again.</p>
<p>[gallery columns="2" ids="191,192,193,190"]</p>
<p>Recently I have read about the amazing rework called <a href="https:&#47;&#47;www.youtube.com&#47;watch?v=4n2dthDSGkc">Plasma 5<&#47;a>. The KDE guys want to keep the usual workflow so they only do enormous polishing work, code refactoring, design updates and so on. As KDE 5 is not yet in the official arch linux repositories I thought I should&nbsp;give KDE 4 a try.</p>
<p>I just installed KDE on arch linux with&nbsp;<span class="lang:default highlight:0 decode:true crayon-inline">sudo pacman -S kde<&#47;span>&nbsp;and removed Gnome with&nbsp;<span class="lang:default highlight:0 decode:true crayon-inline">sudo pacman -Rs gnome gnome-extra<&#47;span>. After that I enabled kdm to be able to login properly:&nbsp;<span class="lang:default highlight:0 decode:true  crayon-inline">sudo systemctl enable kdm<&#47;span>. Everything worked well!</p>
<p>I noticed that there are a few design issues. It seemed like especially the menu bars looked like gnome ones and I didn't know what's going on. After removing a few additional leftover gnome and gtk packages everything looked like&nbsp;as expected.</p>
<h2>Sound Problems<&#47;h2></p>
<p>After removing the leftover gnome packages my sound did not work anymore. I figured out that pulseaudio does not seem to be a dependency of kde. So I installed it again and the sound started to work&nbsp;again. But I was still not able to use the speaker test in the soundsettings (I own a 5.1 sound system). Installing <a href="https:&#47;&#47;www.archlinux.org&#47;packages&#47;extra&#47;x86_64&#47;libcanberra-pulse&#47;">libcanberra-pulse<&#47;a> fixed this last issue.</p>
<h2>User Experience<&#47;h2></p>
<p>The first user experience in KDE is configuring. You can configure everything... So I configured for a few hours and checked out everything. Just a few words about what I have discovered so far:</p>
<ul>
<li>I love dolphin! The filemanager is great! &nbsp;You can even paste an image to the filesystem from the clipboard!<&#47;li>
<li>KMail seems to be pretty much the same as evolution but it performs better. The calender and addressbook are&nbsp;seperated&nbsp;out into own&nbsp;applications but it works fine. I am excited about the sieve support!<&#47;li>
<li>ALT + F2 is better than in gnome. It behaves similar to a&nbsp;shell -> like<&#47;li>
<li>I though I will miss Gnome's overview feature. But when you push your mouse in the upper left corner of KDE it shows the active applications as Gnome does!<&#47;li>
<li>Kate is better as Gedit. More features and it looks like an editor.<&#47;li>
<li>Dropbox integrates into dolphin as it does into nautilus.<&#47;li><br />
<&#47;ul><br />
[caption id="attachment_198" align="alignnone" width="1920"]<a href="https:&#47;&#47;sevenbyte.org&#47;wp-content&#47;uploads&#47;2014&#47;09&#47;Bildschirmfoto1.png"><img class="wp-image-198 size-full" src="https:&#47;&#47;sevenbyte.org&#47;wp-content&#47;uploads&#47;2014&#47;09&#47;Bildschirmfoto1.png" alt="" width="1920" height="1080" &#47;><&#47;a> KDE Desktop[&#47;caption]</p>
<h2>Performance<&#47;h2></p>
<p>I thought that KDE might have a few performance issues in comparison to Gnome but it is the other way round! Since Gnome 3.10 I had to put these lines into&nbsp;&#47;etc&#47;X11&#47;xorg.conf.d&#47;20-nvidia.conf:</p>
<pre class="lang:default highlight:0 decode:true">Section "Device"<br />
    Identifier     "Device0"<br />
    Driver         "nvidia"<br />
    VendorName     "NVIDIA Corporation"<br />
    Option         "RegistryDwords" "PowerMizerEnable=0x1; PerfLevelSrc=0x2222; PowerMizerDefaultAC=0x1"<br />
    Option         "UseEvents" "True"<br />
    Option         "TripleBuffer" "True"<br />
    Option         "OnDemandVBlankInterrupts" "True"<br />
EndSection<&#47;pre><br />
These lines prevented my nvidia card from adaptive clock speed because Gnome was unuseable at the first performance level (50 MHz). KDE does not have any problems with adaptive clock speed. Everything is smooth and really fast! Gnome feels like a laggy windows 98 in comparison to KDE.</p>
<h2>Conlusion<&#47;h2></p>
<p>This is the first day of using KDE but I think I will keep it on my computer. It works, is really fast and I am looking forward to KDE 5. So bye bye Gnome...</p>
