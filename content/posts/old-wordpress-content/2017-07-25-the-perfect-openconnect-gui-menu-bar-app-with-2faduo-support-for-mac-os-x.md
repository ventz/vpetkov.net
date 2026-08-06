---
title: The perfect OpenConnect GUI Menu Bar App with 2FA/Duo support - for Mac OS X
author: Ventz
type: posts
date: 2017-07-26T03:07:45+00:00
url: /2017/07/25/the-perfect-openconnect-gui-menu-bar-app-with-2faduo-support-for-mac-os-x/
categories:
  - Old-WordPress-Blog
tags:
  - old-wordpress-blog
  - apple
  - automation
  - security
  - vpn

---
You need to connect to a Cisco AnyConnect (or Juniper Pulse Connect) VPN, and you cannot stand the default client for a variety of reasons (slow connects, crashes, unable to start, pointless pop-up notifications, crashes, pid-loss, etc), and so, you look for alternatives.

You find OpenConnect - the perfect solution, only to realize that the 3rd-party GUI is basically broken and actually doesn't work (last checked on 8-14-17) with 2-Factor authentication (ex: Duo).

At this point, you can run OpenConnect from a terminal, which works, but you have to keep the terminal open and you have to wrap the long command in a shell script.

Or, you can use my little solution which seems to work perfectly.

![OpenConnect GUI - Connected](https://media.vpetkov.net/images/openconnect/vpn-connected.png) 

![OpenConnect GUI - Disconnected](https://media.vpetkov.net/images/openconnect/vpn-disconnected.png) 

Everything you need to get started is on GitHub:  
 <https://github.com/ventz/openconnect-gui-menu-bar>

<!--more-->