---
title: My Tasker program – BlackBerry Sound Profiles for Android
author: Ventz
type: post
date: 2011-05-10T18:13:24+00:00
url: /2011/05/10/my-tasker-program-blackberry-sound-profiles-for-android/
categories:
  - Uncategorized
tags:
  - android
  - automation
  - blackberry
  - google
  - tasker

---
If you just started reading this directly and didn&#8217;t read my &#8220;what is Tasker&#8221;, please read my short post: (<a href="http://blog.vpetkov.net/2011/05/10/androids-best-app-tasker-visual-programming-and-automation/" target="_blank">http://blog.vpetkov.net/2011/05/10/androids-best-app-tasker-visual-programming-and-automation/</a>)

If you are running ICS 4.0, please read: ([http://blog.vpetkov.net/2011/12/27/tasker-ics-android-4-0-blackberry-sound-profiles][1])

**Don&#8217;t let the length of this post scare you &#8212; I just wanted to provide the technical/developer details. You can get this to work in less than a couple of minutes by downloading the zip file and ONLY reading the &#8220;GETTING STARTED&#8221; section.**

&nbsp;

**GETTING STARTED:**

0.) Please download the zip file bellow if you haven&#8217;t done so already &#8211; [Blackberry\_Sound\_Profiles\_for\_Android.zip][2]

1.) First, if you haven&#8217;t already, install Tasker (you can use the Android Market, or the guys&#8217; website). You can play with it for 7 days for free.  
2.) It will create a &#8220;Tasker&#8221; folder on your SD card. Under that you will find &#8220;tasks&#8221; and &#8220;profiles&#8221; folders (if they don&#8217;t exist yet, create them).  
3.) Download the zip to your computer, mount your phone&#8217;s SD card and go into the main &#8220;Tasker&#8221; folder under the sdcard. If the file ends in .prf, put it in the &#8220;profiles&#8221; folder. If it ends in &#8220;.tsk&#8221;, place it in the &#8220;tasks&#8221; folder. Unmount, disconnect your phone.  
4.) Now that you have them, you need to load what you want/need into the program. Open up Tasker (program), <del>hit Menu, and go to &#8220;Profile Data&#8221;. Do a &#8220;Import One Profile&#8221; or &#8220;Import One Task&#8221; </del>select one of the &#8220;tabs&#8221; (Profiles, Tasks, Scenes), and hold it &#8212; an &#8220;Import&#8221; option will present itself, which will let you import a Profile or Task (or not relevant here &#8211; a Scene). This is because Tasker changed the way profiles and tasks (and Scenes) are imported . As soon as you select that, you will see all the files in the directory that you copied. Now you can import whatever you want.

You should import the &#8220;Volume Buttons&#8221; Profiles (note: this is a profile), at least the &#8220;Normal&#8221; and &#8220;Sleep&#8221; tasks (note: these are tasks). The volume buttons profile is honestly a life saver since any time you tap a volume button, it will actually restore to the sound-profile task you have selected.

Now to use them,

5.) Hold down on the home screen, select Widget (for ICS 4, Widgets are created by going to Applications, and shifting over to widgets), select Task. It will show you a list of your tasks. Select &#8220;Normal&#8221; for example. It will show it to you (in case you have to make any changes last minute &#8212; don&#8217;t do it this way, always make them in editor), now select the green check and you are Done! You can now use it as a &#8220;program&#8221; on your home screen. Add at least 2 this way, and select them. Wait 1-2 seconds. You will see how it select/enables each, and then after it enables it, hit the volume keys on purpose, and then wait 1-2 seconds again to see how it restores it.

**END OF GETTING STARTED &#8211; THAT&#8217;S IT! You have it working!**

&nbsp;

&nbsp;

Ahh, you&#8217;ve continued reading and you haven&#8217;t skipped this&#8230;Clearly you care about some of the theory&#8230;

One of the biggest problems with Android is the sound profiles. **I will start off with the main sound profile BUG**:

Try setting your Settings -> Sound -> Vibrate to &#8220;Only when in Silent&#8221;, and then hold the power key, change the &#8220;Silent mode&#8221; to ON. Now hold the power key again, and change the &#8220;Silent mode&#8221; to OFF. Check your Settings -> Sounds -> Vibrate mode &#8212; it is changed incorrectly to &#8220;Always&#8221;. This renders the built-in &#8220;sound profiles&#8221; completely useless.

Here are bug reports that are all for the same thing: <a title="Issue 20463" href="http://code.google.com/p/android/issues/detail?id=20463" data-versionurl="http://blog.vpetkov.net/amber/cache/db61cc767988f0d826769ebd9731d59a/" data-versiondate="2020-04-05T07:49:55+00:00" data-amber-behavior="" target="_blank">Issue 20463</a> and <a title="Issue 13732" href="http://code.google.com/p/android/issues/detail?id=13732" data-versionurl="http://blog.vpetkov.net/amber/cache/6bc2e48b477f100759f55fe0899ceef1/" data-versiondate="2020-04-05T07:49:11+00:00" data-amber-behavior="" target="_blank">Issue 13732</a>

UPDATE: Please note that Google &#8220;sort of&#8221; fixed this, to a point, where we can now correctly implement the functionality using Tasker at least. It&#8217;s not there by default, but the &#8220;Silent Mode&#8221; now works for on (sleep), off, and vibrate, and there&#8217;s a separate toggle-able Ring+Vibrate feature.

Pretty much, half of <a title="Android Vibrate Problems" href="http://code.google.com/p/android/issues/list?can=2&q=vibrate&colspec=ID+Type+Status+Owner+Summary+Stars&cells=tiles" data-versionurl="http://blog.vpetkov.net/amber/cache/e8fc0237221ff64e83d5ce42e26e7b04/" data-versiondate="2020-04-05T07:50:11+00:00" data-amber-behavior="" target="_blank">these</a> are the same issue. The main problem is that the Silent _and_ Vibrate options for android, are really one single &#8220;Silent Mode&#8221;. The problem arises because Sound -> Vibrate settings only apply for &#8220;Silent Mode&#8221;. This means that you cannot have a completely silent profile and a vibrate only profile, and a &#8220;normal&#8221; profile. This is the most evident to anyone coming from a blackberry, where the sound profiles are flawless. I&#8217;ve read thousands and thousands of questions asking &#8220;how do I get sound profiles like on the blackberry&#8221;. Personally, this was the first thing that drove me crazy when I moved away from the blackberry.

Most people default to using a program which creates &#8220;Profiles&#8221; &#8212; setting bundles which simply toggle each Sound option (In-Call volume, Media, Ring Tone, Notification, Alarm, and System). The best one I&#8217;ve seen is AudioGuru, which is great, but it does lack some customization. The one additional step that most programs lack also is some sort of a guard for the volume buttons which toggle the ringtone.

My goal when thinking about all of this was to create a solution that was simple, extendable, and complete. The main points I was going after was to have profiles that are completely stand-alone, extendable/fully customizable, and completely scriptable. The end result was what I call &#8220;Blackberry Sound Profiles for Android&#8221;.

&nbsp;

First off, here&#8217;s the download:

> [Blackberry\_Sound\_Profiles\_for\_Android.zip][2]  
> (md5: 71d0701ce63a6953a997145c758753c8)
> 
> (don&#8217;t forget to go to Settings -> Sound -> and UNCHECK &#8220;Use incoming call volume for notifications&#8221;. Also, Settings -> Language & keyboard -> Android keyboard -> and CHECK &#8220;Sound on keypress&#8221;)

The logic becomes part of 3 sections. The **FIRST SECTION** is the Tasker sound profile tasks. These are &#8220;stand alone&#8221; tasks, which simply encompass every aspect of a sound profile. Let me walk through one of them:

&#8220;Normal.tsk.xml&#8221;

0.) Set a default icon (used grey star in this case)  
1.) Wait &#8211; 2 seconds  
[note &#8211; for ICS 4, there is an extra step in here turning off the Ring+Vibrate fixed feature]  
2.) Silent  Mode &#8211; off  
3.) In-Call Volume &#8211; 5  
4.) Media Volume &#8211; 9  
5.) Ringer Volume &#8211; 5  
6.) Notification Volume &#8211; 5  
7.) System Volume &#8211; 6  
8.) Alarm Volume &#8211; 7  
9.) Set Widget Icon (to %PROFILE &#8211; used default grey star)  
10.) Variable Set (%PROFILE to &#8220;Normal&#8221;)  
11.) Set Widget Icon (to %PROFILE &#8211; used the grey sound icon)  
12.) Notify &#8211; %PROFILE  
13.) Wait &#8211; 1 second  
14.) Notify Cancel &#8211; %PROFILE

Let me clarify some key things:  
step #9 is needed in order to clear the old Icon back to a star.  
step #10 sets the global variable to the name of this profile  
step #11 activates the pressed/toggled widget

I&#8217;ve also included a &#8220;Sleep&#8221; sound-profile task (toggles all down except alarm and media), a &#8220;Work&#8221; sound-profile task (same as &#8220;Normal&#8221; sound-profile task, but the notification is less and the system sound is less so the keyboard is not obnoxious), a &#8220;Loud&#8221; sound-profile task (makes everything as loud as possible basically), a &#8220;Vibrate&#8221; sound-profile task (like sleep, but has vibrate on), and a &#8220;On-Call&#8221; sound-profile task (like sleep, but ring tone is low).

I am not sure if you are already picking up what&#8217;s going on, but basically, the idea is that you have a few of these sound-profile tasks, and you create widgets on the home screen. They all show up as grey stars. When you press &#8220;Normal&#8221; or &#8220;Sleep&#8221; for example, it changes the star to the correct icon (Sound Icon, or Muted Icon), and shows it on your home screen and notify&#8217;s in your notification bar (after which, a second later, it clears the notification bar). Now, go through the other profiles to see what they do. They are all pretty much the same, except the Vibrate profile, which uses step #2 to select the official Android &#8220;Silent&#8221; mode, with a Vibrate outlet.

Now, the **SECOND SECTION** is a single Tasker task called &#8220;Sound Profile&#8221; which has one step:

1.) Perform Task &#8211; %PROFILE

And now you see why step #10 from section one is needed. When this task is called, it will change the current Sound profile to the global variable (%PROFILE). Please import this task too. Why is this needed you ask? Because of my clever hack in the **THIRD SECTION**:

Here is where you have a Tasker Profile. It is called &#8220;Volume Buttons&#8221;. The basic logic is as follows:

1.) If Variable Set %VOLR (ringer volume), then call the &#8220;Sound Profile&#8221;

This essentially achieves a volume-reset every time you accidentally hit the volume up or down keys. Now you can see why the &#8220;Wait &#8211; 2 seconds&#8221; was needed. The key part about this is that it uses your global variable, and it resets your volume to the last Sound profile that you selected. Great huh? Please make sure you import the &#8220;Volume Buttons&#8221; profile into Tasker.

At last you are Done! You now have individual Tasker tasks which you can make widgets out of. I have the 3 that I use the most &#8211; Normal, Silent, and Work (work being a bit quieter on the notification and system sound for the keyboard noise) on my main home screen. Then I have the Loud, Vibrate, and On-Call on another screen since I use them less often.

**OPTIONAL FOURTH SECTION FOR EVERYONE WHO NEEDS AN ON-CALL PROFILE**

For the people interested, the &#8216;On-Call&#8217; task works in a super elegant way: it silences everything except the ring tone (which it lowers), the alarm, and the media volume. The media volume is the key here. Let&#8217;s say you want SMS notifications but not emails while you are on-call. They both use the &#8220;notification&#8221; system, so there&#8217;s no way to do this by default (yet another ex-blackbery annoyance). What you can do is write a Tasker profile which interprets a &#8220;Notification Messaging, *&#8221; notify, (you can check the time if you are only on-call during the night or day) and then have the action for the task for the profile call the &#8220;Music Play&#8221; action which simply plays your SMS sound as an MP3. This essentially lets you isolate one application from another, by using the fact that you can play the selected notification through the media outlet. Beautiful Eh?

I hope all of this helps people out.

**UPDATE &#8211; Added &#8220;One Ring&#8221; Task and Profile Monitor**

I&#8217;ve updated the zip pack with two additions: a task which will provide you with a &#8220;One-Ring&#8221; sound-profile task &#8212; it&#8217;s basically the normal profile, but it brings the Ringer Volume to 0, and it increases the Media Volume up to 11. Also, I&#8217;ve added a &#8220;One\_Ring\_Monitor&#8221; profile, which intercepts calls, and plays a music file (mp3, wav, ogg, others&#8230;) &#8212; giving you the ability to play a notification &#8212; thus a single beep/sound.

**  
**

 [1]: http://blog.vpetkov.net/2011/12/27/tasker-ics-android-4-0-blackberry-sound-profiles "http://blog.vpetkov.net/2011/12/27/tasker-ics-android-4-0-blackberry-sound-profiles"
 [2]: http://blog.vpetkov.net/wp-content/uploads/2011/09/Blackberry_Sound_Profiles_for_Android.zip "Blackberry_Sound_Profiles_for_Android.zip"