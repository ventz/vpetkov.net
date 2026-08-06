---
title: My Tasker program - Keyguard
author: Ventz
type: posts
date: 2011-05-10T15:17:45+00:00
url: /2011/05/10/my-tasker-program-keyguard/
categories:
  - Old-WordPress-Blog
tags:
  - old-wordpress-blog
  - android
  - automation
  - google
  - security
  - tasker

---
If you just started reading this directly and didn't read my "what is Tasker", please read my short post (<http://blog.vpetkov.net/2011/05/10/androids-best-app-tasker-visual-programming-and-automation/>)

Let's start with the problem - I can't stand unlocking my phone every 10-15 minutes when I decide to look at the screen either because I heard a beep, or because I want to check for a work email/SMS. The obvious solution: get rid of the lock screen. The new problem: now my phone is not secure. I need something to toggle this functionality on a "need basis". Solution: use Tasker to create a task which will be created into a widget.

Here's the logic:

0.) Set a default icon (used key in this case)  
1.) Keyguard - toggle  
2.) Notify - KEYGUARD IS OFF, if %KEYG is off  
3.) Notify - KEYGUARD IS ON, if %KEYG is on  
4.) Wait - 1 second  
5.) Notify Cancel - KEYGUARD IS OFF, if %KEYG is off  
6.) Notify Cancel - KEYGUARD IS ON, if %KEYG is on  
7.) Set Widget Icon - Unlocked Lock, if %KEYG is off  
8.) Set Widget Icon - Locked Lock, if %KEYG is on

> Download Takser task: [Keyguard.tsk.xml.zip](/wp-content/uploads/2011/05/Keyguard.tsk_.xml_.zip) (md5: 0e2f2fd8cdaa5ff71a1fd5b0329bdfe6)  
> Please unzip it, copy it to your device, and then import it into Tasker.

Make it into a widget, press it, the icon will change to an unlocked keylock, and your lock screen goes away. Hit power, check to see that when you hit power again, your lock screen is not there. The volume keys will turn on the screen too. If you press the widget again, the icon will change to a locked keylock, and now you will have your lock screen. What I personally do is use the pin lock screen, and then toggle it this way while I am at work. As soon as I step out or anything like this, I toggle my lock back on.