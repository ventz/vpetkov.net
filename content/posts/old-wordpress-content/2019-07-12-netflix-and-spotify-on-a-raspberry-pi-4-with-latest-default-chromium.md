---
title: Netflix and Spotify on a Raspberry Pi 4 with Latest Default Chromium
author: Ventz
type: post
date: 2019-07-13T02:03:28+00:00
url: /2019/07/12/netflix-and-spotify-on-a-raspberry-pi-4-with-latest-default-chromium/
categories:
  - Uncategorized
tags:
  - hack
  - linux
  - raspberry-pi
  - security

---
> As of 3-30-2020, if you want the &#8220;paste-one-line-it-just-works&#8221; go to:
> 
> <a href="http://blog.vpetkov.net/2020/03/30/raspberry-pi-netflix-one-line-easy-install-along-with-hulu-amazon-prime-disney-plus-hbo-spotify-pandora-and-many-others/" rel="noopener noreferrer" target="_blank">http://blog.vpetkov.net/2020/03/30/raspberry-pi-netflix-one-line-easy-install-along-with-hulu-amazon-prime-disney-plus-hbo-spotify-pandora-and-many-others/</a>

**^^^ PLEASE USE POST USING ABOVE LINK FOR MY “ONE-LINE IT JUST WORKS” ^^^**  
(IGNORE EVERYTHING BELLOW THIS AS IT’S THE ORIGINAL DEVELOPMENT WORK)  
===================================================================

**Everything from this point down is out of date as of: 3-30-2020**

This was my initial &#8220;netflix on the raspberry pi 4 development&#8221; blog post. Leaving it on here due to the comments, initial work, info for those interested, but I highly recommend using the easy method above (linked).

Last libwidevine extract: 3-29-2020 &#8211; v.4.10.1610.6 of libwidevine &#8211; EVERYTHING CONFIRMED WORKING

_  
Chromium has made substantial changes the way libwidevine (and a few major things around DRM) are loaded/used/etc. They have also made changes to the setting and reading of the user-agent propagation. For some time (~2 months or so) &#8212; the combination of this badly broke Netflix. It seems they have undone the lib loading in the last couple of versions, and user @Spartacuss discovered the user-agent fix.</p> 

The instructions here (as of 3-29-2020) work for: Netflix, Hulu, HBO, Disney+, Amazon Prime, Spotify, Pandora, and many others.</em>

The Raspberry Pi 4 model with 4GB of RAM is the first cheap hardware that can provide a real &#8220;desktop-like&#8221; experience when browsing the web/watching Netflix/etc. However, if you have tried to run Netflix on the Pi, you have quickly entered the disgusting mess that exists around DRM, WideVine (Netflix being one example of something that needs it), and Chromium.

After hours and hours of effort, I finally discovered a quick and elegant solution that lets you use the **latest default provided Chromium browser**, without having to recompile anything in order to watch any WideVine/DRM (Netflix, Spotify, etc) content.

## Background and the DRM Problem

If you are not familiar with this, the short version is that Netflix (and many others, ex: Spotify) use the WideVine &#8220;Content Protection System&#8221; &#8211; aka DRM, and if you want to watch Netflix or something else that uses it, you need to have a WideVine plugin+browse supported integration. Chrome, Firefox, and Safari make it available for x86/amd64 systems, but not for ARM since technically they don&#8217;t have ARM builds.

Chromium, the project Chrome is based on, does have an ARM build, but it does not include any DRM support, and technically it does not include widevine support by default (*caveat here, which helps us later)  
So long story short, the question becomes &#8220;how do you enable DRM/WideVine support in Chromium?&#8221;.

It seems there are two main solutions out there: use an old (v51, 55, 56, 60) version of Chromium which has been &#8220;patched&#8221; with widevine support (kusti8&#8217;s version seems to be the most popular one &#8211; except since the new Netflix changes, that also does not work), which requires uninstalling the latest Chromium available, installing the old/patched one, and dropping in older widevine plugins; the second option is to use Vivaldi &#8211; a proprietary fork of Opera which also has been &#8220;sort of patched&#8221;, but it still needs a valid libwidevinecdm plugin (see bellow) and it has it&#8217;s own issues (and also&#8230;it&#8217;s Opera&#8230;in 2019&#8230;who uses Opera?)

After a lot of research and trial and error, I discovered a much more elegant solution &#8211; use the extracted ChromeOS (armv7l &#8211; yay) binaries and insert them into Chromium + make everything think it&#8217;s ChromeOS (user agent)

## Netflix/Hulu/Spotify with the Default Raspberry Pi Chromium Browser

<!--more-->

**Enough theory &#8211; let&#8217;s do this in 2 quick steps!**  
0.) If you have tried Netflix/etc already, open Chromium and clear your browser history + cookies. Otherwise it will cache the &#8220;failed&#8221; DRM components.

**1.) Download the latest extracted ChromeOS <a href="/wp-content/uploads/2020/03/libwidevinecdm.so_.zip" target="_blank" rel="noopener noreferrer">libwidevine</a> binary and extract it:**  
`<br />
$ sudo su<br />
# cd /usr/lib/chromium-browser<br />
# wget /wp-content/uploads/2020/03/libwidevinecdm.so_.zip<br />
# unzip libwidevinecdm.so_.zip && chmod 755 libwidevinecdm.so<br />
# wget /wp-content/uploads/2020/03/chromium-media-browser.desktop.zip<br />
# unzip chromium-media-browser.desktop.zip && mv chromium-media-browser.desktop /usr/share/applications<br />
` 

NOTE: Credit and thanks to @Spartacuss for discovering user-agent method with .desktop file!

NOTE: You can verify that these are the ***official*** versions from ChromeOS:  
_https://dl.google.com/dl/edgedl/chromeos/recovery/chromeos\_12739.105.0\_elm\_recovery\_stable-channel_mp-v2.bin.zip_  
</i>

NOTE: UPDATED (Last re-extracted from ChromeOS on: 3-23-20)  
version: 4.10.1610.6 (see optional script below how to check version)  
filename: _libwidevinecdm.so_  
md5sum: _6857e5f102651bfa977eb739b86bf75e_  
sha256sum: _678c21b5ebf459919f9dcde100af8f59e580b6bed56b1cae1ae5eb43a7029e17_

**2.) Completely QUIT all Chromium windows.**  
Start Chromium with the new Application Menu under &#8220;Internet&#8221;: **Chromium (Media Edition)**  
<del datetime="2020-03-30T00:52:10+00:00">Open a new tab, and go to: https://bitmovin.com/demos/drm You should be able to see the movie on the left. </del>(While this still works, it will show &#8220;No DRM&#8221; unless you set the Chromium user-agent from within the app &#8211; which breaks Netflix. BitMoving unfortunately looks for that first. Just go to Netflix/Your media source directly.)  
You can now play Netflix, Hulu, HBO, Spotify, Pandora, Disney+, Amazon Prime, and many others!

Please note that If you can see the video on the left, this means the DRM plugin has worked! From this point on, anything that does not work (ex: Netflix sometimes breaks after a browser update) is due to the site specifically filtering User Agents/doing other &#8220;tricks&#8221;. So for example, if Netflix does not work, Spotify, Pandora, Hulu, Amazon Prime, HBO, etc will still work. <del datetime="2020-03-30T00:52:10+00:00">The BitMovin website is the &#8220;real&#8221; test on wether the DRM plugin has worked.</del>(While still technically true, if your Chromium user-agent is not set from within the app itself, which breaks Netflix, BitMovin will show &#8220;No DRM&#8221; even though the DRM decryption works)

**Solution for the occasional &#8220;screen tearing&#8221;**

Updated: 4-7-2020  
`<br />
$ sudo rm /etc/xdg/autostart/xcompmgr.desktop<br />
$ sudo reboot<br />
` 

It seems the Pi&#8217;s raw CPU frequency is still not powerful enough for decoding 100% of the time. While 97-98% of the time is good enough, you will get the occasional &#8220;screen tearing&#8221; (https://en.wikipedia.org/wiki/Screen_tearing), especially in scenes with fast motion.

<del datetime="2020-04-07T04:18:34+00:00">Users Otaku, DM (and thanks to Luca for testing/extra info!) have found a solution which was mentioned on https://lb.raspberrypi.org/forums/viewtopic.php?t=246179 by user Greysvandir.<br /> I had to add a few more things and I created a compressed and slightly automated 😉 version:<br /> # sudo apt install -f compton<br /> $ mkdir -p ~/.config/lxsession/LXDE-pi<br /> $ cd ~/.config && wget https://raw.githubusercontent.com/dastorm/Compton-xfce-config/master/compton.conf<br /> $ cp -f /etc/xdg/lxsession/LXDE-pi/autostart ~/.config/lxsession/LXDE-pi/autostart<br /> $ echo &#8220;@usr/bin/compton &#8211;backend glx&#8221; >> ~/.config/lxsession/LXDE-pi/autostart<br /> $ echo &#8220;xrandr &#8211;output HDMI-1 &#8211;mode 1280&#215;720&#8221; >> ~/.config/lxsession/LXDE-pi/autostart<br /> The result is no tearing with 1080p@60fps video.<br /> </del>

**(OPTIONAL) Get libwidevinecdm version**  
If you want to check your \*actual\* libwidevinecdm version, the easiest and quickest way is using user VMX&#8217;s elegant python solution:

`<br />
# cd /usr/lib/chromium-browser<br />
# python -c 'import ctypes;<br />
> lib = ctypes.cdll.LoadLibrary("./libwidevinecdm.so");<br />
> lib.GetCdmVersion.restype = ctypes.c_char_p;<br />
> print(lib.GetCdmVersion())'<br />
` 

This will give you the version:  
4.10.1610.6

Alternatively, if for some reason you want to, you can compile a binary (C) checker by:

a.) Create a file called &#8220;**get\_cdm\_version.c** with:

`<br />
#include <stdio.h><br />
#include <stdlib.h><br />
#include <dlfcn.h>
<p>int main(int argc, char *argv[]) {<br />
  void *handle;<br />
  const char *(*get_cdm_version)();</p>
<p>  handle = dlopen("./libwidevinecdm.so", RTLD_LAZY);<br />
  if (!handle) {<br />
    fprintf(stderr, "%s\n", dlerror());<br />
    exit(EXIT_FAILURE);<br />
  }</p>
<p>  get_cdm_version = dlsym(handle, "GetCdmVersion");<br />
  if (!get_cdm_version) {<br />
    fprintf(stderr, "%s\n", dlerror());<br />
    exit(EXIT_FAILURE);<br />
  }</p>
<p>  printf("%s\n", get_cdm_version());<br />
  dlclose(handle);<br />
  exit(EXIT_SUCCESS);<br />
}<br />
` 

b.) Compile the binary with: **gcc get\_cdm\_version.c -o get\_cdm\_version -ldl**

If you want a binary version for some reason (I don&#8217;t know why you would given python method), and you can&#8217;t compile it yourself, and you trust me (why?!), feel free to grab my already compiled version:  
`<br />
$ wget /wp-content/uploads/2020/03/get_cdm_version.zip<br />
$ unzip -f get_cdm_version.zip<br />
$ chmod 755 get_cdm_version<br />
` 

c.) Place a copy of the libwidevinecdm.so in the same directory as your binary  
d.) Run it  
`./get_cdm_version<br />
4.10.1610.6`  
^^ Here the Version is: 4.10.1610.6

**(OPTIONAL: Older Versions)**  
Here are the last few OLDER versions in case you need them (note the unique date in the url):  
[libwidevinecdm.so (2019/09)](/wp-content/uploads/2019/09/libwidevinecdm.so_.zip)  
[libwidevinecdm.so (2019/08)](/wp-content/uploads/2019/08/libwidevinecdm.so_.zip)  
[libwidevinecdm.so (2019/07)](/wp-content/uploads/2019/07/libwidevinecdm.so_.zip)