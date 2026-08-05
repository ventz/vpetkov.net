---
title: Google Nexus S – update manually to 4.1.2 Jelly Bean
author: Ventz
type: post
date: 2012-12-12T07:36:27+00:00
url: /2012/12/12/google-nexus-s-update-manually-to-4-1-2-jelly-bean/
categories:
  - Uncategorized
tags:
  - android
  - google
  - hack
  - nexus
  - security

---
This will be my last post about the Google Nexus S since I just purchased (and received) my Nexus 4. That said, I really wanted to give one last update on the Nexus S since it looks like things have changed quite a bit with the update process. While it looks more complicated at first, it&#8217;s actually a lot more flexible now. Here is how to upgrade your Nexus S manually to a full 4.1.2 Jelly Bean, even if you have not received it yet/are in a country where the updates are not coming in, or are on a carrier which is not pushing OTA updates.

The first step is to go to Google&#8217;s Official <a title="Factory Images for Nexus Devices" href="https://developers.google.com/android/nexus/images" data-versionurl="http://blog.vpetkov.net/amber/cache/6c725a86f1232749d4badedcff0dcc8b/" data-versiondate="2020-04-05T07:49:15+00:00" data-amber-behavior="" target="_blank">Factory Images for Nexus Devices</a>

Now, you have one of four choices for sections, based on your phone:

  * If you have the (MOST POPULAR) T-Mobile or ATT (GSM) version of the Nexus S, go to: &#8220;Factory Images &#8220;soju&#8221; for Nexus S (worldwide version, i9020t and i9023)&#8221;
  * If you have the Sprint (4G) version, go to: &#8220;Factory Images &#8220;sojus&#8221; for Nexus S 4G (d720)&#8221;
  * If you have the Korean version (VERY RARE), go to: &#8220;Factory Images &#8220;sojuk&#8221; for Nexus S (Korea version, m200)&#8221;
  * If you have the NON-1Ghz (STILL RARE) version, go to: &#8220;Factory Images &#8220;sojua&#8221; for Nexus S (850MHz version, i9020a)&#8221;

Let&#8217;s assume you have the T-Mobile/ATT one since most people have that.  
You will want the &#8220;4.1.2 (JZO54K)&#8221; image, which you can download from their official link:

> <a title="soju-jzo54k-factory-36602333.tgz" href="https://dl.google.com/dl/android/aosp/soju-jzo54k-factory-36602333.tgz" target="_blank">soju-jzo54k-factory-36602333.tgz<br /> </a>(md5: 788233dca5954532acda63039f814b4d)

<!--more-->

Now, here is where things get different. Instead of putting this on the SDCARD and just flashing it, you need fastboot. You can download it form the latest Android SDK, or just grab an older version which works perfectly fine from here: <a title="fastboot" href="http://koushikdutta.blurryfox.com/G1/" target="_blank">http://koushikdutta.blurryfox.com/G1/</a>

From here, extract the &#8220;soju-jzo54k-factory-36602333.tgz&#8221; file, and you will find two interesting scripts inside the dir:  
flash-all.sh and flash-base.sh

If you look more carefully at them, you will realize what&#8217;s happening. You have a bootloader (bootloader-crespo-i9020xxlc2.img) a radio (radio-crespo-i9020xxki1.img) and a system image (image-soju-jzo54k.zip). What you need to do is flash each one. Go to the directory where you extracted the 4.1.2 zip and move the &#8216;fastboot&#8217; binary there. Then:

  1. fasboot oem unlock (NOTE: this WILL format your phone)
  2. fastboot reboot-bootloader
  3. fastboot flash bootloader bootloader-crespo-i9020xxlc2.img
  4. fastboot reboot-bootloader
  5. fastboot flash radio radio-crespo-i9020xxki1.img
  6. fastboot reboot-bootloader
  7. fastboot -w update image-soju-jzo54k.zip
  8. flashboot reboot-bootloader
  9. flashboot oem lock (NOTE: this will NOT format your phone)

Now, steps #1+2 are needed ONLY if your bootloader is already locked. Steps #8+9 are ONLY needed if you need to have your phone look like you just bought it. There is no real reason (some security ones) to lock your boot loader &#8230; especially if you are doing stuff like this. The one downside of locking it is that the next time you unlock it, it will wipe your phone.

One other thing that you an do is flash the bootloader and the radio, but keep the image at your old one. This is not really recommended to my best knowledge, even though it&#8217;s fully supported. Another option is to keep the custom bootloader that you have, and just flash the radio and base image.

Either way, now you are running the LATEST possible OS for your Nexus S!