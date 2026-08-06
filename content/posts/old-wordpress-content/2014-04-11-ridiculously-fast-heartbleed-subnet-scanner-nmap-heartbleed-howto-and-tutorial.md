---
title: Ridiculously fast Heartbleed Subnet Scanner - nmap heartbleed howto and tutorial
author: Ventz
type: posts
date: 2014-04-11T21:00:05+00:00
url: /2014/04/11/ridiculously-fast-heartbleed-subnet-scanner-nmap-heartbleed-howto-and-tutorial/
categories:
  - Old-WordPress-Blog
tags:
  - old-wordpress-blog
  - cloud
  - hack
  - linux
  - network
  - security

---
**UPDATE: Insecure has released v6.46 which contains all of these patches. Just grab the latest and follow the usage info here**

If you don't know what Heartbleed is, you can find out here: [http://heartbleed.com/](http://heartbleed.com). If you don't want to read the details above, XKCD put together a great short comic about it: <http://xkcd.com/1354/>

NOTE: I first put this together 3 days ago, but I am just now releasing after being asked by many people for the package and directions.

The problem: How do you scan a bit more than 5 class B's (~328000 IP addresses) before any off the vendors (Tenable, Qualys, Rapid7) have released signatures? Easy - you build your own!  
The goal was to scan as many IPs as possible at work as quickly as possible.

After using the Heartbleed github project (https://github.com/FiloSottile/Heartbleed) and creating a Dancer web service around it, I realized that there still needed to be a faster way to scan for this. How much faster?

**How about a /24 (254 IP addresses) in less than 10 seconds.**

I have a patched version of NMAP already (6.40) that has Heartbleed checks.  
**Again, Insecure has released v.6.46 which has these patches. Grab that and follow these directions**

Then, you can scan like this:  
```bash
/usr/local/bin/nmap --open --script ssl-heartbleed -p 443 SUBNET-CIDR-HERE
```

 

If you want cleaner results, for a script, a good way to filter the output will be with something like this:  
```bash
/usr/local/bin/nmap --open --script ssl-heartbleed -p 443 SUBNET-CIDR-HERE | sed -e '/report for/,/ssl-heartbleed/!d' | grep -v 'Host is up' | grep -v 'SERVICE' | sed -r 's/Nmap scan report for //'
```

This produced a clean 2 line result, where if it's vulnerable, it will have "ssl-heartbleed" under each host/IP address entry.

 

## How to build your own patched NMAP binary

But what if you don't trust my binary? Good - let me show you how to build one yourself:

<!--more-->

  
Grab the NMAP source code, extract it, and get SSL-Heartbleed nmap script and TLS Lua script  
```bash
cd /tmp; mkdir nmap; wget 'http://nmap.org/dist/nmap-6.46.tar.bz2'
tar -jxvf nmap-6.40.tar.bz2
cd /tmp/nmap/nmap-6.40
# Note: wget patches only needed for versions BEFORE v.6.46
cd nselib; wget 'https://svn.nmap.org/nmap/scripts/ssl-heartbleed.nse'; cd ..
cd liblua; wget 'https://svn.nmap.org/nmap/nselib/tls.lua'; cd ..
```

Grab the pre-reqs:  
```bash
apt-get install liblua5.1-0-dev libssl-dev netcat checkinstall
```

Configure and Build NMAP:  
```bash
cd /tmp/nmap/nmap-6.40
./configure
make "LUA_LIBS=../liblua/liblua.a -ldl -lm"
```

Create an NMAP package and install it:  
```bash
sudo checkinstall
sudo dpkg -i nmap_6.40-1_amd64.deb
```