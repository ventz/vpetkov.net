---
title: Sniffing SSH Password from the Server Side
author: Ventz
type: post
date: 2013-01-30T00:36:16+00:00
url: /2013/01/29/sniffing-ssh-password-from-the-server-side/
categories:
  - Uncategorized
tags:
  - linux
  - network
  - privacy
  - security

---
I read an interesting article last night which highlited some problems with the way SSH process communication happens. I am writing a post about it because it is so simple and yet so effective.

**Here is the scenario:**  
Let&#8217;s say that you have a linux system running the latest set of patches/OpenSSH. You have multiple users on the system, and one or more of them have sudo/su/escalated privileges. The idea is that when user &#8216;A&#8217; connects to the system, user &#8216;C&#8217; will be able to sniff out their password.

**The details:**  
The idea is that almost all ssh daemons by default are configured to use &#8220;Privilege Separation&#8221;. This means that sshd spawns a process (child) that is unprivileged to listen for incoming network requests. After the user authenticates, another process gets created running as the authenticated user. The magic happens in between these two processes.

**A simple example:  
** User &#8216;C&#8217; ssh-es into the system, escalates their privledges (either by legitimate or non-legitimate means) and starts listening for newly created ssh &#8216;net&#8217; processes. As soon as user &#8216;C&#8217; sees a process being crated, they immediately attach strace to it.

A simple way to do it is by:  
```
ps aux | grep ssh | grep net | awk {' print $2'} | xargs -L1 strace -e write -p
```

or even better:  

```
while [ 1 ]; do ps aux | grep ssh | grep net | awk {' print $2'} | xargs -L1 strace -e write -p; done
```

&nbsp;

<!--more-->

Now, when user &#8216;A&#8217; ssh-es in, as soon as they type their password and hit enter, user &#8216;C&#8217; will see something like this:

Process 17681 attached &#8211; interrupt to quit  
write(4, &#8220;\0\0\0 \v&#8221;, 5) = 5  
write(4, &#8220;\0\0\0\33_**thisismysupersecretpassword**_&#8220;, 31) = 31  
write(3, &#8220;\345+\275\373q:J\254\343\300\30I\216$\260y\276\302\353&#8243;&#8230;, 64) = 64  
Process 17681 detached

&nbsp;

This could easily be fixed by simply setting &#8216;UsePrivilegeSeparation&#8217; to &#8216;no&#8217; in your sshd config. This is <span style="text-decoration: underline;">NOT</span> recommended.  
The result will be far worse if you do this. Imagine a 0-day exploit or some other remote buffer overflow gaining an attacker root to your system.

The correct solution, in my opinion, would be to hash the password.

&nbsp;

What makes this scary is not that someone who is root can do something like attaching strace &#8212; it&#8217;s the fact that they can get your password, without modifying a single binary on the system. An attacker could always swap out sshd or another binary with something that logs your password, but this is almost untraceable.
