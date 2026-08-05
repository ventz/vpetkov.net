---
title: Tasker – ICS (Android 4.0) – BlackBerry Sound Profiles
author: Ventz
type: post
date: 2011-12-28T03:40:45+00:00
url: /2011/12/27/tasker-ics-android-4-0-blackberry-sound-profiles/
categories:
  - Uncategorized
tags:
  - android
  - automation
  - blackberry
  - google
  - tasker

---
This is an update to the article &#8220;My Tasker  program &#8211; BlackBerry Sound Profiles for Android&#8221; ([http://blog.vpetkov.net/2011/05/10/my-tasker-program-blackberry-sound-profiles-for-android][1]). Download the new file here, read through &#8220;what has changed&#8221;, and &#8220;what I have updated&#8221;, and then definitely read the original post (url above) as it contains all the details and how-to information.

&nbsp;

**What Has Changed:**

There are a couple of things that Google has drastically changed in ICS 4.0 when it comes to Sound, Vibrate, and Volume.

First of all, they have greatly simplified the Sound Settings. The Volume menu now contains: &#8220;Music,Video, Games, and other media&#8221; as one volume toggle, then &#8220;Ringtone and notifications&#8221; as another, and Alarms as a third. Something to note here is that the keyboard &#8220;clicking&#8221; sound can now be found under the keyboard settings -> under Advanced.

The Second change is the way &#8220;Vibrate&#8221; has been re-implemented. The new &#8220;Silent Mode&#8221; controls three things currently: Sound, Mute, and Vibrate. This is important as this was completely broken on 2.3. The next thing to note is the &#8220;Vibrate and Ring&#8221; option, as this has a negative effect when toggled on via Vibrate (it&#8217;s still sticky for some reason, but due to Silent Mode being fixed, we can now un-toggle it via Tasker).

<!--more-->

&nbsp;

**What I have Updated:**

There are two fundamental things that I&#8217;ve changed in every single task:

1.) I am now toggling on and off the Silent Mode. This makes a difference since it actually works correctly in 4.0.

2.) I am now also setting and un-setting the &#8220;Vibrate and Ring&#8221; mode. It is being un-set in every sound-profile task, except the &#8220;Vibrate&#8221; one, where it is set, but the volume is 0, so no ringing actually happens &#8212; however it ends up vibrating. The reason for this is because if I un-toggle this, it will not vibrate, and this is where google, IMO, simply has implemented this very poorly.

Here is the download:

> [Blackberry\_Sound\_Profiles\_for\_Android][2][  
>][3] (md5: e57e9bc69209e1a95e8967e11488fd95)

Note: I updated the zip archive on 1-09-2012. If you downloaded before then, please re-download. What I changed is the Vibrate sound-profile task. It turns out that in ICS, if you set everything to Vibrate, but then set the volume/notification sound to something else, it overrides the &#8220;Vibrate&#8221; setting. While this seems logical, this was not the case in pre-ICS. It is now fixed.

 [1]: http://blog.vpetkov.net/2011/05/10/my-tasker-program-blackberry-sound-profiles-for-android "http://blog.vpetkov.net/2011/05/10/my-tasker-program-blackberry-sound-profiles-for-android"
 [2]: http://blog.vpetkov.net/wp-content/uploads/2012/01/Blackberry_Sound_Profiles_for_Android.zip
 [3]: http://blog.vpetkov.net/wp-content/uploads/2011/12/Blackberry_Sound_Profiles_for_Android.zip "http://blog.vpetkov.net/wp-content/uploads/2011/12/Blackberry_Sound_Profiles_for_Android.zip"