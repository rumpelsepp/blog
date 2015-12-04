---
layout: post
status: publish
published: true
title: Cron Jobs with systemd.timer
author:
  display_name: Stefan Tatschner
  login: stefan
  email: stefan@sevenbyte.org
  url: ''
author_login: stefan
author_email: stefan@sevenbyte.org
wordpress_id: 231
wordpress_url: http://sevenbyte.org/?p=231
date: '2014-11-15 15:01:56 +0100'
date_gmt: '2014-11-15 14:01:56 +0100'
categories:
- General
tags:
- administrating
- systemd
comments: []
---
<p>From <a href="https:&#47;&#47;wiki.archlinux.org&#47;index.php&#47;Systemd&#47;Timers">Arch Wiki:<&#47;a></p>
<blockquote><p>Timers are systemd unit files whose name ends in .timer that control .service files or events. Timers have the ability to be an alternate to cron. Timers have built-in support for calendar time events, monotonic time events, and have the ability to run asynchronously.<&#47;blockquote><br />
As I started my experience with administrating Arch Linux after the systemd switch in 2012 I&nbsp;find crontabs or even sysvinit-scripts really ugly. There are lots of flamewars against systemd; mostly introduced by people who grew up with the stuff mentioned before. Besides these flamewars systemd provides a very well documented and very easy to use out of the box solution for many tasks of an administrator.</p>
<p>At first we have to clarify a few terms and definitions. Systemd grows from release to release and it has a lot of different concepts we have to deal with. The first concept I have to introduce for a cron replacement with systemd is <strong>systemd.service<&#47;strong>.</p>
<h2>systemd.service<&#47;h2><br />
Service files are commonly used to start and stop programs. The <strong>systemctl<&#47;strong> tool provides the necessary commands to control your services, such as start, stop, restart, reload, and so on.&nbsp;It is your job (or the job of the package maintainer) to write an appropriate service file so that <strong>systemctl<&#47;strong> is able to map e.g. the start command to the&nbsp;corresponding shell command.</p>
<p>Let's do a simple example. Somebody has written an awesome backupscript&nbsp;and he wants that program&nbsp;to be executed daily. The start&nbsp;command for that piece of software might be&nbsp;something like "<strong>awesome program start"<&#47;strong>. So we have to tell systemd that command first. Don't forget to put the <span style="text-decoration: underline;">full path<&#47;span> of your script into&nbsp;<strong>ExecStart<&#47;strong>. Otherwise systemd is not able to&nbsp;locate&nbsp;it!</p>
<pre>[Unit]<br />
Description=My awesome backup script<br />
After=network.target</p>
<p>[Service]<br />
Type=oneshot<br />
ExecStart=&#47;path&#47;to&#47;awesome_programm start<&#47;pre><br />
We call this file <strong>awesome.service<&#47;strong>. The structure of systemd service files is&nbsp;self-explanatory. The Unit section is used to define some metadata such as the description or dependencies. The Service section actually defines the start command of our service. As we are most likely&nbsp;using a script which runs and exists after finishing its tasks we have to set the Type to <strong>oneshot<&#47;strong>, see also <a href="http:&#47;&#47;www.freedesktop.org&#47;software&#47;systemd&#47;man&#47;systemd.service.html">systemd.service(5)<&#47;a>. Maybe I will give more information about&nbsp;that topic in another articles.</p>
<p>Now there is the question where we are supposed to put this file. This topic&nbsp;is covered in detail in <a href="http:&#47;&#47;www.freedesktop.org&#47;software&#47;systemd&#47;man&#47;systemd.unit.html">systemd.unit(5)<&#47;a>. At the moment we are just interested in the local configuration path when running in system mode: <strong>&#47;etc&#47;systemd&#47;system<&#47;strong>. So let's copy this service to it's intended location <strong>&#47;etc&#47;systemd&#47;system&#47;awesome.service<&#47;strong>.</p>
<h2>systemd.timer<&#47;h2><br />
In the previous section we have covered the required steps to design a simple systemd service which is used to start our script. Now we will add the <a href="http:&#47;&#47;www.freedesktop.org&#47;software&#47;systemd&#47;man&#47;systemd.timer.html">system.timer(5)<&#47;a> which is used to trigger the service. The timer has to be named according to the corresponding service <strong>awesome.timer<&#47;strong>; we put this file in the same directory.</p>
<pre class="lang:default highlight:0 decode:true">[Unit]<br />
Description=Weekly trigger for my awesome program</p>
<p>[Timer]<br />
OnCalendar=daily<br />
Persistent=true</p>
<p>[Install]<br />
WantedBy=multi-user.target<&#47;pre><br />
The timer file is self-explanatory as well. It has three required sections:&nbsp;Unit,&nbsp;Timer and&nbsp;Install.</p>
<p>I will now focus on the Timer section. It is used to define&nbsp;when the Timer should be activated. At first there is the OnCalender option. It understands a few keywords such as&nbsp;"minutely", "hourly", "daily", "monthly", "weekly", "yearly", "quarterly", "semiannually". &nbsp;If these keywords fit into your requirements everything is fine; more fine graned control is provided by <a href="http:&#47;&#47;www.freedesktop.org&#47;software&#47;systemd&#47;man&#47;systemd.time.html">systemd.time(7)<&#47;a>. Maybe you want to run your service every six hours. So you have to define the OnCalendar option like this:</p>
<pre class="lang:default highlight:0 decode:true ">OnCalendar=*-*-* 0&#47;6:42:42<&#47;pre><br />
This means in detail (according to&nbsp;<a href="http:&#47;&#47;www.freedesktop.org&#47;software&#47;systemd&#47;man&#47;systemd.time.html">systemd.time(7)<&#47;a>): Run on</p>
<ul>
<li>every year (first asterisk),<&#47;li>
<li>every month (second asterisk),<&#47;li>
<li>every day (third asterisk),<&#47;li>
<li>on 00:42:42 and repeat every 6 hours.<&#47;li><br />
<&#47;ul><br />
The repeating is defined with the slash. An OnCalender which runs every 6 minutes instead would look like this:</p>
<pre class="lang:default highlight:0 decode:true">OnCalendar=*-*-* 0:0&#47;6:42<&#47;pre><br />
Just for the sake of completeness, <strong>Persistent=true<&#47;strong> means that any missed timer will run after bootup. It is useful to catch up on missed runs of the service when the machine was off. It is compareable to anacron.</p>
<p>Last but not least there is the Install section left. This one is needed for the most important part: enabling&nbsp;the timer. We do this with <strong>systemctl enable awesome.timer<&#47;strong>. Installing the timer into the&nbsp;multi-user.target just means we want it to be started during&nbsp;bootup. If you want to dive into more detail check out the <a href="https:&#47;&#47;wiki.archlinux.org&#47;index.php&#47;Systemd#Targets">Arch Wiki<&#47;a>.&nbsp;As we do not want to reboot now we also have to start the timer using <strong><span class="lang:default highlight:0 decode:true  crayon-inline ">systemctl start&nbsp;awesome.timer<&#47;span><&#47;strong>.</p>
<h3>Listing timers<&#47;h3><br />
Let's check if everything works as expected. Systemctl has a built in command to list and inspect timers on your&nbsp;system.&nbsp;<strong><span class="lang:default highlight:0 decode:true  crayon-inline">systemctl list-timers<&#47;span><&#47;strong>&nbsp;will tell you which timers have been&nbsp;recognized by systemd.</p>
<h2>Where is the user crontab?<&#47;h2><br />
Maybe you have wondered why you have to copy every file into system directories. As mentioned before this is for systemd running in system mode. These services and timers are started and enabled system wide for all users on the machine. If you do not have sudo privileges or you just want to define your own timer you can use systemd's user mode.</p>
<blockquote><p><a title="Systemd" href="https:&#47;&#47;wiki.archlinux.org&#47;index.php&#47;Systemd">systemd<&#47;a> offers users the ability to manage services under the user's control with a per-user systemd instance, enabling users to start, stop, enable, and disable their own units. This is convenient for daemons and other services that are commonly run for a single user, such as <a class="mw-redirect" title="Mpd" href="https:&#47;&#47;wiki.archlinux.org&#47;index.php&#47;Mpd">mpd<&#47;a>, or to perform automated tasks like fetching mail. With some caveats it is even possible to run xorg and the entire window manager from user services.<&#47;blockquote><br />
You do not have to change that much for using systemd's user mode. Assuming you are using a recent version of systemd the user instance is started automatically per user session. You can use the <strong>~&#47;.config&#47;systemd&#47;user<&#47;strong>&nbsp;directory for your service and timer files. For enabling, starting and listing the timer&nbsp;you just have to append the <strong><span class="lang:default highlight:0 decode:true  crayon-inline ">userflag<&#47;span><&#47;strong>, e. g.:</p>
<pre>systemctl --user enable awesome.timer<&#47;pre></p>
<h3>Using user mode on a server<&#47;h3><br />
As the systemd user instance is running per user session it might become difficult to run certain tasks automatically without an open ssh session. If you want systemd to run your user tasks <strong>without being logged in<&#47;strong> then just linger yourself&nbsp;with:</p>
<pre>loginctl enable-linger username<&#47;pre><br />
Lingering a specific&nbsp;user keeps the&nbsp;systemd user instance running without an corresponding user session. This ensures that your tasks actually run as intended.</p>
