---
title: Ridiculously fast Heartbleed Subnet Scanner – nmap heartbleed howto and tutorial
author: Ventz
type: post
date: 2014-04-11T21:00:05+00:00
url: /2014/04/11/ridiculously-fast-heartbleed-subnet-scanner-nmap-heartbleed-howto-and-tutorial/
categories:
  - Uncategorized
tags:
  - cloud
  - hack
  - linux
  - network
  - security

---
**UPDATE: Insecure has released v6.46 which contains all of these patches. Just grab the latest and follow the usage info here**

If you don&#8217;t know what Heartbleed is, you can find out here: <a href="http://heartbleed.com" data-versionurl="http://blog.vpetkov.net/amber/cache/4a2ebb856eddd5097fb643f5e155be12/" data-versiondate="2020-04-05T07:48:59+00:00" data-amber-behavior="" target="_blank">http://heartbleed.com/</a>. If you don&#8217;t want to read the details above, XKCD put together a great short comic about it: <a href="http://xkcd.com/1354/" data-versionurl="http://blog.vpetkov.net/amber/cache/4cd8e26e5b76c653d0997bf9736093b2/" data-versiondate="2020-04-05T07:49:00+00:00" data-amber-behavior="" target="_blank">http://xkcd.com/1354/</a>

NOTE: I first put this together 3 days ago, but I am just now releasing after being asked by many people for the package and directions.

The problem: How do you scan a bit more than 5 class B&#8217;s (~328000 IP addresses) before any off the vendors (Tenable, Qualys, Rapid7) have released signatures? Easy &#8211; you build your own!  
The goal was to scan as many IPs as possible at work as quickly as possible.

After using the Heartbleed github project (https://github.com/FiloSottile/Heartbleed) and creating a Dancer web service around it, I realized that there still needed to be a faster way to scan for this. How much faster?

**How about a /24 (254 IP addresses) in less than 10 seconds.**

I have a patched version of NMAP already (6.40) that has Heartbleed checks.  
**Again, Insecure has released v.6.46 which has these patches. Grab that and follow these directions**

Then, you can scan like this:  
<code lang="bash">/usr/local/bin/nmap --open --script ssl-heartbleed -p 443 SUBNET-CIDR-HERE</code>

&nbsp;

If you want cleaner results, for a script, a good way to filter the output will be with something like this:  
<code lang="bash">/usr/local/bin/nmap --open --script ssl-heartbleed -p 443 SUBNET-CIDR-HERE | sed -e '/report for/,/ssl-heartbleed/!d' | grep -v 'Host is up' | grep -v 'SERVICE' | sed -r 's/Nmap scan report for //'</code>

This produced a clean 2 line result, where if it&#8217;s vulnerable, it will have &#8220;ssl-heartbleed&#8221; under each host/IP address entry.

&nbsp;

**How to build your own patched NMAP binary?**

But what if you don&#8217;t trust my binary? Good &#8211; let me show you how to build one yourself:

<!--more-->

  
Grab the NMAP source code, extract it, and get SSL-Heartbleed nmap script and TLS Lua script  
<code lang="bash">&lt;br />
cd /tmp; mkdir nmap; wget 'http://nmap.org/dist/nmap-6.46.tar.bz2'&lt;br />
tar -jxvf nmap-6.40.tar.bz2&lt;br />
cd /tmp/nmap/nmap-6.40&lt;br />
# Note: wget patches only needed for versions BEFORE v.6.46&lt;br />
cd nselib; wget 'https://svn.nmap.org/nmap/scripts/ssl-heartbleed.nse'; cd ..&lt;br />
cd liblua; wget 'https://svn.nmap.org/nmap/nselib/tls.lua'; cd ..&lt;br />
</code>

Grab the pre-reqs:  
<code lang="bash">&lt;br />
apt-get install liblua5.1-0-dev libssl-dev netcat checkinstall&lt;br />
</code>

Configure and Build NMAP:  
<code lang="bash">&lt;br />
cd /tmp/nmap/nmap-6.40&lt;br />
./configure&lt;br />
make "LUA_LIBS=../liblua/liblua.a -ldl -lm"&lt;br />
</code>

Create an NMAP package and install it:  
<code lang="bash">&lt;br />
sudo checkinstall&lt;br />
sudo dpkg -i nmap_6.40-1_amd64.deb&lt;br />
</code>