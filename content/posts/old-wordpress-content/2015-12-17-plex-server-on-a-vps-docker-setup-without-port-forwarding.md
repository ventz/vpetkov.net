---
title: Plex server on a VPS Docker setup without port forwarding
author: Ventz
type: posts
date: 2015-12-17T13:06:22+00:00
url: /2015/12/17/plex-server-on-a-vps-docker-setup-without-port-forwarding/
categories:
  - Old-WordPress-Blog
tags:
  - old-wordpress-blog
  - automation
  - cloud
  - docker
  - hack
  - linux

---
**[ updated 10-30-2016 | Upgraded Plex to plexmediaserver-1.1.4.2757-24ffd60.x86_64.rpm and CentOS ]**

Recently I tried setting up a Plex server in a docker container. The first problem was the 127.0.0.1:32400 bind which required logging in locally or port forwarding. After doing this once, I realized that you could use the Preferences.xml file, but that meant that you couldn't truly automate this/deploy it elegantly in a docker container. And what if you wanted to run other servers - for friends? I finally figured out how to do this in the most elegant way possible.

## First - Grab your Unique Plex Access Token

Login at <https://app.plex.tv/web/app> with your username and password  
Open your javascript console (in Chrome: View -> Developer -> JavaScript Console)  
and type:  
`console.log(window.PLEXWEB.myPlexAccessToken);`

Note the token, which will look like this: "PZwoXix8vxhQJyrdqAbY"

At this stage DO NOT click log out of your account until you register the new server. Otherwise your token will regenerate.  
Once you register the server, it won't matter after that if the token changes.

## Grab my Docker Image

Check out: <https://hub.docker.com/r/ventz/plex/>  
You can pull it down by doing:  
`docker pull ventz/plex`  
<!--more-->

## Setup a DATA directory

Create a DATA directory (let's assume it's "/plex") which contains:  
1.) a folder called "Plug-ins" -> this has all your plugins from: <https://github.com/plexinc-plugins> or any other source.  
2.) a file called "Preferences.xml"

The "Preferences.xml" file should contain:  
```
<?xml version="1.0" encoding="utf-8"?>
<Preferences MachineIdentifier="12f0e861-5876-498e-bec6-111b030118aa" ProcessedMachineIdentifier="f12a1d8fdc32ae0cf273ec699a3ddbd37a4a94e4" AnonymousMachineIdentifier="ae674c91-42ff-4be5-88e9-f6b2a1751146" MetricsEpoch="1" GracenoteUser="WEcxA9TX1GEpdlIDlmmKmq70OVYLCgKZ+qh/lJkydwKH29UjfnDGWq/M8Okr//E88wSk9A7UXVxjlZgVpu1px7GVA2GEOAAAk8AJ4KOXodtdzLj+HPNhYZIl/lzMY8P32sF2rq9yb4RwhtOE/mKejkvw/2Ak5mm0VNQjt3ifNEXpyfuo+oH519qFQ5XAk+7Y3cwtEff2" AcceptedEULA="1" ManualPortMappingMode="1" PublishServerOnPlexOnlineKey="1" collectUsageData="0" logDebug="0" PlexOnlineToken="PZwoXix8vxhQJyrdqAbY" CertificateVersion="2"/>
```

  
**note: Edit out "PZwoXix8vxhQJyrdqAbY" with the AccessToken for the account you want to use!**

This will end up being mounted over:  
1.) /var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins  
2.) /var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Preferences.xml

## Run Plex in a Docker Container on a VPS without backend setup/port forwarding

```
docker run --name=plex -d --privileged=true -p 32400:32400 -v /plex:/p ventz/plex
```

This will mount your /plex/{Plug-ins, Preferences.xml} into /p on the container, and then the default CMD on the container is "/start-plex.sh" which will chmod them, move them into the right places, and then start the server.

At this point, go to the Docker HOSTS' IP address (or the Public IP that NATs to the internal IP) at: "http://dockerhostIP:32400/web", and log-in with your Plex account. You will now see a NEW server registered, and you will be able to browse the channels that you have pushed + watch content 🙂

## OPTIONAL - How to Build your own Docker image

Let's say you don't trust some random image by some random person (me). No problem - here's how to build your own "ventz/plex" Docker image.

```
Create a /plex-container directory that has 3 files:
1.) Dockerfile
2.) The CentOS RPM (64bit - as of now, latest: plexmediaserver-0.9.12.19.1537-f38ac80.x86_64.rpm)
3.) start-plex.sh
```

**[ updated 10-30-2016 | Upgraded Plex to plexmediaserver-1.1.4.2757-24ffd60.x86_64.rpm and CentOS ]**

Make sure your Dockerfile has:  
```
FROM centos:6.8

VOLUME ["/p"]

COPY start-plex.sh /
COPY plexmediaserver-1.1.4.2757-24ffd60.x86_64.rpm  /root
RUN rpm -i /root/plexmediaserver-1.1.4.2757-24ffd60.x86_64.rpm
RUN rm -f /root/plexmediaserver-1.1.4.2757-24ffd60.x86_64.rpm

EXPOSE 32400

# Run actual Plex server
CMD ["/start-plex.sh"]
```

and Finally, make sure your "start-plex.sh" has:  
```
#!/bin/bash
# Needed to create Library and other dirs under "/var/lib/plexmediaserver"
/etc/init.d/plexmediaserver start
/etc/init.d/plexmediaserver stop

# Make sure permissions are correct.
chown -R plex:plex /p/*

# Move Files
cp -Rf /p/Plug-ins/* /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/Plug-ins/.
cp -f /p/Preferences.xml /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/.

# Start Real Plex server
su -s /bin/sh plex -c ". /etc/sysconfig/PlexMediaServer; cd /usr/lib/plexmediaserver; ./Plex\ Media\ Server"
```

Now, BUILD it:  
```
docker build --rm=true --force-rm=true -t ventz/plex .
```

Enjoy! 🙂