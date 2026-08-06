---
title: Raspberry Pi Netflix One Line Easy Install – along with Hulu, Amazon Prime, Disney Plus, HBO, Spotify, Pandora, and many others
author: Ventz
type: posts
date: 2020-03-30T17:36:29+00:00
url: /2020/03/30/raspberry-pi-netflix-one-line-easy-install-along-with-hulu-amazon-prime-disney-plus-hbo-spotify-pandora-and-many-others/
categories:
  - Old-WordPress-Blog
tags:
  - google
  - hack
  - linux
  - raspberry-pi
  - security

---

---

**Last Update: 3-13-21 | Official Raspberry Pi Package now available &#8211; see bellow**  

**Last Update: 11-9-20 | Updated ventz-media-pi for new Chromium version (v.84+) and new WideVine setup: v.4.10.1679.0+ NOTE: You MUST re-download and re-run it from this date to fix &#8211; lots of changes!**  

**Last Update: 11-2-20 | Updated libwidevinecdm.so_.zip to v.4.10.1679.0 within ventz-media-pi**  

**Last Update: 7-22-20 | Updated .desktop with Chrome User Agent string for CrOS Chrome/77.0.3865.120**  

**Last Update: 7-20-20 | ~redacted~ company reached out about creating an official package, also there are conversations happening with ~redacted~ company about official support of the Pi**  

**Last Update: 5-6-20 | Specify that &#8220;Raspbian with desktop&#8221; is assumed and tested**  

**Last Update: 4-7-20 | Fixed screen tearing**

---

Great News &#8211; This can finally be announced:) &#8211; There is now an official Raspberry Package with this work!!

Setup everything here with:  
```
sudo apt update
sudo apt full-upgrade
sudo apt install libwidevinecdm0
```

Everything from here down is the “pre-official-raspberry-package” info:

If you just want to take a Raspberry Pi 4 (as of today!) and turn it into a fully functional &#8220;Media&#8221; center by just pasting one line, here it is:

SSH to your Pi (don&#8217;t run from the Pi console if you want pretty graphics :)) and run:  
```
curl -fsSL https://pi.vpetkov.net -o ventz-media-pi
sh ventz-media-pi
```

This will produce the following (click to see larger image):  
[![Media Pi launcher showing Netflix, Hulu, Amazon Prime, and other streaming apps](https://blog.vpetkov.net/wp-content/uploads/2020/04/ventz-media-pi-300x157.png)][1]

Reboot, and then from the **Application Menu** (top left) -> go to “**Internet**” -> open “**Chromium (Media Edition)**”

You are now ready to use your Raspberry Pi on Netflix, Hulu, Amazon Prime, Disney Plus, HBO, Spotify, Pandora, and many others.

If you need to change any browser _**Settings**_, do so via the &#8220;Chromium&#8221; browser and **not** the &#8220;Chromium (Media Edition) &#8211; both are the same browser, so the settings are the same. The &#8220;Media Edition&#8221; (just a custom launcher with the user-agent) cannot load the settings since Chromium thinks you are launching it on &#8220;Chrome OS&#8221;, and when it checks for the Chrome OS language settings it crashes since they don&#8217;t exist.

At last, all this assumes the latest version of Raspbian with desktop (not Debian/Ubuntu! &#8211;  
<a href="https://downloads.raspberrypi.org/raspbian_latest" rel="noopener noreferrer" target="_blank">https://downloads.raspberrypi.org/raspbian_latest</a>), and you can re-run the **curl and sh** as many times as you want without any harm.

If you are curious about some of the background and details on why you can&#8217;t easily run Netflix (and others) on your Pi and how to solve it, you are welcome to go look at my &#8220;development&#8221; blog post article: <a href="http://blog.vpetkov.net/2019/07/12/netflix-and-spotify-on-a-raspberry-pi-4-with-latest-default-chromium/" rel="noopener noreferrer" target="_blank">http://blog.vpetkov.net/2019/07/12/netflix-and-spotify-on-a-raspberry-pi-4-with-latest-default-chromium/</a>

Enjoy!

 [1]: https://blog.vpetkov.net/wp-content/uploads/2020/04/ventz-media-pi.png
