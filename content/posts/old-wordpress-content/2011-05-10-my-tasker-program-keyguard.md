---
title: My Tasker program – Keyguard
author: Ventz
type: post
date: 2011-05-10T15:17:45+00:00
url: /2011/05/10/my-tasker-program-keyguard/
categories:
  - Uncategorized
tags:
  - android
  - automation
  - google
  - security
  - tasker

---
If you just started reading this directly and didn&#8217;t read my &#8220;what is Tasker&#8221;, please read my short post (<a href="http://blog.vpetkov.net/2011/05/10/androids-best-app-tasker-visual-programming-and-automation/" target="_blank">http://blog.vpetkov.net/2011/05/10/androids-best-app-tasker-visual-programming-and-automation/</a>)

Let&#8217;s start with the problem &#8211; I can&#8217;t stand unlocking my phone every 10-15 minutes when I decide to look at the screen either because I heard a beep, or because I want to check for a work email/SMS. The obvious solution: get rid of the lock screen. The new problem: now my phone is not secure. I need something to toggle this functionality on a &#8220;need basis&#8221;. Solution: use Tasker to create a task which will be created into a widget.

Here&#8217;s the logic:

0.) Set a default icon (used key in this case)  
1.) Keyguard &#8211; toggle  
2.) Notify &#8211; KEYGUARD IS OFF, if %KEYG is off  
3.) Notify &#8211; KEYGUARD IS ON, if %KEYG is on  
4.) Wait &#8211; 1 second  
5.) Notify Cancel &#8211; KEYGUARD IS OFF, if %KEYG is off  
6.) Notify Cancel &#8211; KEYGUARD IS ON, if %KEYG is on  
7.) Set Widget Icon &#8211; Unlocked Lock, if %KEYG is off  
8.) Set Widget Icon &#8211; Locked Lock, if %KEYG is on

> Download Takser task: <a href="http://blog.vpetkov.net/wp-content/uploads/2011/05/Keyguard.tsk_.xml_.zip" target="_blank">Keyguard.tsk.xml.zip</a> (md5: 0e2f2fd8cdaa5ff71a1fd5b0329bdfe6)  
> Please unzip it, copy it to your device, and then import it into Tasker.

Make it into a widget, press it, the icon will change to an unlocked keylock, and your lock screen goes away. Hit power, check to see that when you hit power again, your lock screen is not there. The volume keys will turn on the screen too. If you press the widget again, the icon will change to a locked keylock, and now you will have your lock screen. What I personally do is use the pin lock screen, and then toggle it this way while I am at work. As soon as I step out or anything like this, I toggle my lock back on.