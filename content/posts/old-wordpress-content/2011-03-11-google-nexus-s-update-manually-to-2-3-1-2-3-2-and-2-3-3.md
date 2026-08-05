---
title: Google Nexus S – update manually to 2.3.1, 2.3.2, and 2.3.3
author: Ventz
type: posts
date: 2011-03-11T23:41:11+00:00
url: /2011/03/11/google-nexus-s-update-manually-to-2-3-1-2-3-2-and-2-3-3/
categories:
  - Old-WordPress-Blog
tags:
  - files
  - old-wordpress-blog
  - android
  - google
  - hack
  - nexus
  - security

---
&nbsp;

**NOTE: _Look at the new post above if your phone is \*at\* 2.3.3 and you want to go up to 2.3.4_**

**If you just want the LATEST update: grab the FULL 2.3.3 image (<a href="http://android.clients.google.com/packages/ota/google_crespo/f182cf141e6a.signed-soju-ota-102588.f182cf14.zip" target="_blank">f182cf141e6a.signed-soju-ota-102588.f182cf14.zip</a>)**

I decided to contribute back, mention a few vital steps, and provide a few important files now that I solved this - in order for someone to go from 2.3(.0) to 2.3.3  
This assumes that you have not rooted your phone. If you have, you need to un-root it and go back to either 2.3.0, 2.3.1, or 2.3.2,

First of all, if you use the built-in "update" method, the updates need to be consecutive. For this, they are very small.

Let's assume you just bought your Google Nexus S. It came with 2.3 (or 2.3.0 in reality). The first step is to apply the 2.3.1 update. I've called this:

> <a href="http://blog.vpetkov.net/wp-content/uploads/2011/03/update1.zip" target="_blank">update1.zip</a> (md5: a35798d84104c7cb1d26d7946ce843fc)

The general instructions are:

```
0.) Put the file into the /sdcard directory.  
1.) Turn off your phone  
2.) Hold Power and Volume-Up until you see the recovery menu (lots of colors and 4 options).  
3.) Use the Volume-Down key to scroll down and  select "Recovery" by pushing the Power key.  
4.) Wait for the triangle with the exclamation point. Push the Power key and while holding it, tap the Volume-Up key.  
5.) Now you can use the  the Volume keys to go to "apply update from /sdcard" and then the Power key to select it.  
6.) Select the appropriate ZIP file, and then use the Power key to apply it.  
7.) When everything is done, go to the Reboot option with the Volume keys and then use the Power Key to select it.
```

Now, that said, after you apply the first update, you go from 2.3.0 to 2.3.1. Now, apply the 2.3.2 update. I've called this:

> <a href="http://blog.vpetkov.net/wp-content/uploads/2011/03/update2.zip" target="_blank">update2.zip</a> (md5: 714e1e1126f1a222c10ffce6c83dc6ad)

Same as before. After you go through the steps and reboot, you will be at 2.3.2. Here is where things get interesting. It seems that you need another update. Its for people who get the "Status 7" error.  
This is mostly due to a firmware (those who have: GRH78C or GRH78). Here you will need to apply the LAST UPDATE, the same way you applied update1 and update2:

> For [GRH78C](http://android.clients.google.com/packages/ota/google_crespo/98f3836cef9e.signed-soju-GRI40-from-GRH78C.98f3836c.zip) (md5: 3923f98754f756a83b3ecc44e42a2902)
> 
> or
> 
> Only for [GRH78](http://android.clients.google.com/packages/ota/google_crespo/e0b546c442bf.signed-soju-GRI40-from-GRH78.e0b546c4.zip) (md5: 919d7f2c9e06bb03a2ff74081028bf0a)

At last, reboot, and you are on 2.3.3

Please note that \*ALL\* of these files have been taken from google and are official. For that exact reason, I have provided the md5 checksums, so that you can verify them before you use them.  
Hope this helps.


ADDITIONAL INFORMATION AND FILES (If above did not work - very rare):

Some people (very very rare) might still get an error. This is if you have a different radio version. Check: "Settings -> About Phone -> Baseband Version". You should have either something that ends in "XXKB1" or something that ends in "XXKB3". Here are the two radios. Apply this the same way as the items above. You might need this BEFORE the GRH78C (or  GRH78) updates.

> [XXKB1-GRI40-radio-nexuss-unsigned.zip](http://blog.vpetkov.net/wp-content/uploads/2011/03/XXKB1-GRI40-radio-nexuss-unsigned.zip) (md5: 4805c255f10eef8b1bd54aa2d27bc30e)
> 
> or
> 
> [XXKB3-GRI54-radio-nexuss-unsigned.zip](http://blog.vpetkov.net/wp-content/uploads/2011/03/XXKB3-GRI54-radio-nexuss-unsigned.zip) (md5: 4e9c9cf4d6470be800e00f8508b9c175)


LAST RESORT (if nothing above worked - extremely rare):

If nothing worked, try the FULL 2.3.3 OS.

[f182cf141e6a.signed-soju-ota-102588.f182cf14.zip](http://android.clients.google.com/packages/ota/google_crespo/f182cf141e6a.signed-soju-ota-102588.f182cf14.zip) (md5: 3e8908941043951da5a34bb2043dd1a0)
