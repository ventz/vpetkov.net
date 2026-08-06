---
title: Tasker - ICS (Android 4.0) - BlackBerry Sound Profiles
author: Ventz
type: posts
date: 2011-12-28T03:40:45+00:00
url: /2011/12/27/tasker-ics-android-4-0-blackberry-sound-profiles/
categories:
  - Old-WordPress-Blog
tags:
  - old-wordpress-blog
  - android
  - automation
  - blackberry
  - google
  - tasker

---
This is an update to the article "My Tasker  program - BlackBerry Sound Profiles for Android" ([http://blog.vpetkov.net/2011/05/10/my-tasker-program-blackberry-sound-profiles-for-android][1]). Download the new file here, read through "what has changed", and "what I have updated", and then definitely read the original post (url above) as it contains all the details and how-to information.

 

## What Has Changed

There are a couple of things that Google has drastically changed in ICS 4.0 when it comes to Sound, Vibrate, and Volume.

First of all, they have greatly simplified the Sound Settings. The Volume menu now contains: "Music,Video, Games, and other media" as one volume toggle, then "Ringtone and notifications" as another, and Alarms as a third. Something to note here is that the keyboard "clicking" sound can now be found under the keyboard settings -> under Advanced.

The Second change is the way "Vibrate" has been re-implemented. The new "Silent Mode" controls three things currently: Sound, Mute, and Vibrate. This is important as this was completely broken on 2.3. The next thing to note is the "Vibrate and Ring" option, as this has a negative effect when toggled on via Vibrate (it's still sticky for some reason, but due to Silent Mode being fixed, we can now un-toggle it via Tasker).

<!--more-->

 

## What I Have Updated

There are two fundamental things that I've changed in every single task:

1.) I am now toggling on and off the Silent Mode. This makes a difference since it actually works correctly in 4.0.

2.) I am now also setting and un-setting the "Vibrate and Ring" mode. It is being un-set in every sound-profile task, except the "Vibrate" one, where it is set, but the volume is 0, so no ringing actually happens - however it ends up vibrating. The reason for this is because if I un-toggle this, it will not vibrate, and this is where google, IMO, simply has implemented this very poorly.

Here is the download:

> [Blackberry\_Sound\_Profiles\_for\_Android][2][  
>][3] (md5: e57e9bc69209e1a95e8967e11488fd95)

Note: I updated the zip archive on 1-09-2012. If you downloaded before then, please re-download. What I changed is the Vibrate sound-profile task. It turns out that in ICS, if you set everything to Vibrate, but then set the volume/notification sound to something else, it overrides the "Vibrate" setting. While this seems logical, this was not the case in pre-ICS. It is now fixed.

 [1]: http://blog.vpetkov.net/2011/05/10/my-tasker-program-blackberry-sound-profiles-for-android "http://blog.vpetkov.net/2011/05/10/my-tasker-program-blackberry-sound-profiles-for-android"
 [2]: /wp-content/uploads/2012/01/Blackberry_Sound_Profiles_for_Android.zip
 [3]: /wp-content/uploads/2012/01/Blackberry_Sound_Profiles_for_Android.zip "/wp-content/uploads/2012/01/Blackberry_Sound_Profiles_for_Android.zip"