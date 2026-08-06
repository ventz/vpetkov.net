---
title: Speak SMS over the Head Phones only when they are plugged in
author: Ventz
type: posts
date: 2012-02-20T23:31:30+00:00
url: /2012/02/20/speak-sms-over-the-head-phones-only-when-they-are-plugged-in/
categories:
  - Old-WordPress-Blog
tags:
  - old-wordpress-blog
  - android
  - automation
  - google
  - tasker

---
**[updated: March 29th, 2015 | Aman Surana created a great youtube video on how to do this. The main difference is that he is using a plugin (comes as an app which extends Tasker) called AutoNotification. The biggest benefit is that it abstracts the application notification layer into a standard set of variables. This allows you to utilize apps other than the main SMS app (ex: now you can use things like WhatsApp, Google Hangouts, etc). It also works with the latest version of Android, which I am starting to get the feeling that my profiles bellow do NOT work with anymore. Anyway, you can find the video here: <https://www.youtube.com/watch?t=37&v=c-Kp9KynlV4>, and read the post here since the idea behind how to do this still holds. That and it's an interesting way to accomplish this task - no pun ;)]**

I walk outside listening to Pandora quite a lot, and today I realized that I miss about half the SMS' that I get. Either because it's too noisy, or maybe because the SMS' are not loud enough and I use a single beep, or because the sound trigger gets interrupted by Pandora, but either way, it's a bit annoying. I have been considering some sort of a solution that will play incoming SMS messages when my headphones are plugged in for quite some time, but I couldn't think of an efficient way to do it - that is, efficient on the battery. I think I came up with one today.

The idea behind this Tasker program is the following:

There are two Profiles: '_Detect Headphones_' and '_Play Text Over Headphones_'. Only one Profile has to be actually active at all times - the Detect Headphones one. When you plug in your headset (with microphone, or just regular headphones), the profile sets a variable %HEADPHONES to 'yes'. It then turns on the second Profile - the one that monitors incoming SMS messages and plays them over the headset if your %HEADPHONES variable is set to 'yes'.

<!--more-->

The interesting discovery I made was about pausing/muting Pandora. My solution was to set the Media volume to 0, and to set the In-Call volume to 4 (since 5 is too loud over headphones), then play the SMS using the In-Call audio channel, and then set the Media volume to 9 (roughly 'normal') and the In-Call volume to 5 (max). When you unplug your headphones, the Detect Headphones profile clears the variable, and de-activates the Play Text Over Headphones profile. I truly don't think there is a more efficient way to write this, both in terms of simplicity and in terms of battery usage - which is currently <1-2% throughout the day.

So, to recap, the only side effect after you are done with all of this is that your Media volume will be set to 9, and your In-Call volume will be set to 5. Both of these can be customized to values that you find appropriate. Also, instead of setting each individually, you may just re-call one of my sound-profile tasks (like 'Work', or 'Normal', or 'Sleep')

Here are the Profiles:

> [Headphones.zip][1] [updated: 02-22-2012][  
>][2] (md5: abd66180b4f5c75125ef48e9c5e95f80)

BUGS: There aren't any really, but I've noticed that If you receive multiple SMS' quickly (ex: someone sending "1", "2", "3" within a second or two, it will only pick up the first - this is a limitation on the Android notification detection framework. Also, I am sure that even if that wasn't a limitation, the sound synthesizer would not be able to keep up.

Hope you enjoy, and as always, leave comments - both about things that work and things that don't.

 [1]: https://media.vpetkov.net/wp-content/uploads/2012/02/Headphones.zip "Headphones.zip"
 [2]: https://media.vpetkov.net/wp-content/uploads/2012/02/Headphones.zip "Headphones"