---
title: Plex server on a VPS Docker setup without port forwarding
author: Ventz
type: post
date: 2015-12-17T13:06:22+00:00
url: /2015/12/17/plex-server-on-a-vps-docker-setup-without-port-forwarding/
categories:
  - Uncategorized
tags:
  - automation
  - cloud
  - docker
  - hack
  - linux

---
**[ updated 10-30-2016 | Upgraded Plex to plexmediaserver-1.1.4.2757-24ffd60.x86_64.rpm and CentOS ]**

Recently I tried setting up a Plex server in a docker container. The first problem was the 127.0.0.1:32400 bind which required logging in locally or port forwarding. After doing this once, I realized that you could use the Preferences.xml file, but that meant that you couldn&#8217;t truly automate this/deploy it elegantly in a docker container. And what if you wanted to run other servers &#8212; for friends? I finally figured out how to do this in the most elegant way possible.

## First &#8211; Grab your Unique Plex Access Token

Login at <a href="https://app.plex.tv/web/app" target="_blank">https://app.plex.tv/web/app</a> with your username and password  
Open your javascript console (in Chrome: View -> Developer -> JavaScript Console)  
and type:  
</code>console.log(window.PLEXWEB.myPlexAccessToken);</code>

Note the token, which will look like this: &#8220;PZwoXix8vxhQJyrdqAbY&#8221;

At this stage DO NOT click log out of your account until you register the new server. Otherwise your token will regenerate.  
Once you register the server, it won&#8217;t matter after that if the token changes.

## Grab my Docker Image

Check out: <a href="https://hub.docker.com/r/ventz/plex/" data-versionurl="http://blog.vpetkov.net/amber/cache/ba5ee45db689934f37d2d0cc838cd891/" data-versiondate="2019-01-29T03:35:28+00:00" data-amber-behavior="down hover:2" target="_blank">https://hub.docker.com/r/ventz/plex/</a>  
You can pull it down by doing:  
`docker pull ventz/plex`  
<!--more-->

## Setup a DATA directory

Create a DATA directory (let&#8217;s assume it&#8217;s &#8220;/plex&#8221;) which contains:  
1.) a folder called &#8220;Plug-ins&#8221; &#8211;> this has all your plugins from: <a href="https://github.com/plexinc-plugins" target="_blank">https://github.com/plexinc-plugins</a> or any other source.  
2.) a file called &#8220;Preferences.xml&#8221;

The &#8220;Preferences.xml&#8221; file should contain:  
`<br />
<?xml version="1.0" encoding="utf-8"?><br />
<Preferences MachineIdentifier="12f0e861-5876-498e-bec6-111b030118aa" ProcessedMachineIdentifier="f12a1d8fdc32ae0cf273ec699a3ddbd37a4a94e4" AnonymousMachineIdentifier="ae674c91-42ff-4be5-88e9-f6b2a1751146" MetricsEpoch="1" GracenoteUser="WEcxA9TX1GEpdlIDlmmKmq70OVYLCgKZ+qh/lJkydwKH29UjfnDGWq/M8Okr//E88wSk9A7UXVxjlZgVpu1px7GVA2GEOAAAk8AJ4KOXodtdzLj+HPNhYZIl/lzMY8P32sF2rq9yb4RwhtOE/mKejkvw/2Ak5mm0VNQjt3ifNEXpyfuo+oH519qFQ5XAk+7Y3cwtEff2" AcceptedEULA="1" ManualPortMappingMode="1" PublishServerOnPlexOnlineKey="1" collectUsageData="0" logDebug="0" PlexOnlineToken="PZwoXix8vxhQJyrdqAbY" CertificateVersion="2"/><br />
` 

  
**note: Edit out &#8220;PZwoXix8vxhQJyrdqAbY&#8221; with the AccessToken for the account you want to use!**

This will end up being mounted over:  
1.) /var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins  
2.) /var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Preferences.xml

## Run Plex in a Docker Container on a VPS without backend setup/port forwarding

`<br />
docker run --name=plex -d --privileged=true -p 32400:32400 -v /plex:/p ventz/plex<br />
` 

This will mount your /plex/{Plug-ins, Preferences.xml} into /p on the container, and then the default CMD on the container is &#8220;/start-plex.sh&#8221; which will chmod them, move them into the right places, and then start the server.

At this point, go to the Docker HOSTS&#8217; IP address (or the Public IP that NATs to the internal IP) at: &#8220;http://dockerhostIP:32400/web&#8221;, and log-in with your Plex account. You will now see a NEW server registered, and you will be able to browse the channels that you have pushed + watch content 🙂

## OPTIONAL &#8211; How to Build your own Docker image

Let&#8217;s say you don&#8217;t trust some random image by some random person (me). No problem &#8211; here&#8217;s how to build your own &#8220;ventz/plex&#8221; Docker image.

`<br />
Create a /plex-container directory that has 3 files:<br />
1.) Dockerfile<br />
2.) The CentOS RPM (64bit - as of now, latest: plexmediaserver-0.9.12.19.1537-f38ac80.x86_64.rpm)<br />
3.) start-plex.sh<br />
` 

**[ updated 10-30-2016 | Upgraded Plex to plexmediaserver-1.1.4.2757-24ffd60.x86_64.rpm and CentOS ]**

Make sure your Dockerfile has:  
`<br />
FROM centos:6.8</p>
<p>VOLUME ["/p"]</p>
<p>COPY start-plex.sh /<br />
COPY plexmediaserver-1.1.4.2757-24ffd60.x86_64.rpm  /root<br />
RUN rpm -i /root/plexmediaserver-1.1.4.2757-24ffd60.x86_64.rpm<br />
RUN rm -f /root/plexmediaserver-1.1.4.2757-24ffd60.x86_64.rpm</p>
<p>EXPOSE 32400</p>
<p># Run actual Plex server<br />
CMD ["/start-plex.sh"]<br />
` 

and Finally, make sure your &#8220;start-plex.sh&#8221; has:  
`<br />
#!/bin/bash<br />
# Needed to create Library and other dirs under "/var/lib/plexmediaserver"<br />
/etc/init.d/plexmediaserver start<br />
/etc/init.d/plexmediaserver stop</p>
<p># Make sure permissions are correct.<br />
chown -R plex:plex /p/*</p>
<p># Move Files<br />
cp -Rf /p/Plug-ins/* /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/Plug-ins/.<br />
cp -f /p/Preferences.xml /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/.</p>
<p># Start Real Plex server<br />
su -s /bin/sh plex -c ". /etc/sysconfig/PlexMediaServer; cd /usr/lib/plexmediaserver; ./Plex\ Media\ Server"<br />
` 

Now, BUILD it:  
`<br />
docker build --rm=true --force-rm=true -t ventz/plex .<br />
` 

Enjoy! 🙂