---
title: Firewall the Inside of your OpenVPN or L2TP/IPSec Tunnel on Android
author: Ventz
type: posts
date: 2013-02-22T21:17:28+00:00
url: /2013/02/22/firewall-the-inside-of-your-openvpn-or-l2tpipsec-tunnel-on-android/
categories:
  - Old-WordPress-Blog
tags:
  - old-wordpress-blog
  - android
  - censorship
  - google
  - hack
  - linux
  - network
  - nexus
  - privacy
  - security

---
## The Scenario

Let's say you are at a coffee shop with public internet access, and you don't want someone snooping on your traffic, so you VPN to your work. However, you also don't want to tunnel personal stuff out of your work VPN (chat, facebook, youtube, your personal email maybe?), so the question becomes, how do you create 2 different firewalls - one that ONLY allows you to VPN and does not allow any other applications access, and one that then controls the traffic within the VPN channel so that you can utilize the connection for some apps but not others?

At this point, there are only 2 "methods" of running a Firewall on Android: having root and managing/accessing IPTables, or, the only alternative - creating a sub-VPN channel that you pipe the traffic over and filter (which does not require root). Unfortunately, the second type (without root) will not work for this, since we will need to utilize the VPN channel ourselves for our VPN, and to my knowledge, Android let's you setup only 1 active VPN channel. So, you need 1.) a way to root and 2.) a good Firewall

<!--more-->

 

## Need root? - Yes! Quickest way

So, now that we know that we need root, without going into any rooting explanations here, really the easiest way to achieve this is to 1.) unlock the boot loader so that you can flash a temporary recovery image, and then use that + adb 2.) to sideload SuperSU. Done. This will let you preserve your ROM, and preserve your recovery image (if you want to, which you should in order to get OTA updates).

 

## Let's get started

Now that you have root, install this firewall: [Android Firewall](https://play.google.com/store/apps/details?id=com.jtschohl.androidfirewall)

Here is where my contribution comes in - until last night, this firewall could only filter Wifi/3G/Roaming connections. That means, I could open the rules, check all 3 boxes next to OpenVPN for example, and enable it. This would ONLY allow OpenVPN to connect out. However, as soon as I VPN'ed in, everything was tunneled over the VPN channel, and that essentially bypassed the firewall.

My solution was to utilize the droidwall engine (which is what this firewall took over) and plug-in an extra "VPN" chain.

This can be achieved in the following way:

```
# firewall-up
iptables -N droidwall-vpn;
iptables -A droidwall -o tun+ -j droidwall-vpn;
iptables -A droidwall-vpn -m owner --uid-owner 10### -j RETURN;
iptables -A droidwall-vpn -j droidwall-reject

# firewall-down
iptables -F droidwall-vpn;
iptables -D droidwall -o tun+ -j droidwall-vpn;
iptables -X droidwall-vpn
```

I personally created a /data/vpn and dropped in there 'firewall-up' and 'firewall-down'. The One note is the 'uid-owner' part. This is to allow that specific application. One way to get this automatically is by including this:  
`` APP_NAME=`ls -al /data/user/0/ | grep app-name-unique-name | /data/vpn/busybox awk {'print $2'} | /data/vpn/busybox sed 's/u0_a/10/'` ``  
This would provide you with $APP_NAME that you can use instead of the '10###'

This two scripts can be run as a pre- and post- in the firewall setup and teardown. It seems to work perfectly. However, this is a pain for the average user.

 

## Conclusion

I sent this to Android Firewall developer (Jason), and he seemed excited. Within hours, he added it into the firewall and created the appropriate UI element. As of right now, this works perfectly via the UI. You can enable OpenVPN (or another VPN) to have access over Wifi/3G - establish the VPN connection, and then select 'VPN' next to each app that you want to be allowed over the VPN. With a Default deny policy, this will allow those apps to connect to the VPN. Perfect.