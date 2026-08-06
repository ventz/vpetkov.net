---
title: My Tasker program - BlackBerry Sound Profiles for Android
author: Ventz
type: posts
date: 2011-05-10T18:13:24+00:00
url: /2011/05/10/my-tasker-program-blackberry-sound-profiles-for-android/
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
If you just started reading this directly and didn't read my "what is Tasker", please read my short post: ([vpetkov.net/2011/05/10/androids-best-app-tasker-visual-programming-and-automation/](/2011/05/10/androids-best-app-tasker-visual-programming-and-automation/))

If you are running ICS 4.0, please read: ([/2011/12/27/tasker-ics-android-4-0-blackberry-sound-profiles][1])

**Don't let the length of this post scare you - I just wanted to provide the technical/developer details. You can get this to work in less than a couple of minutes by downloading the zip file and ONLY reading the "GETTING STARTED" section.**

 

## Getting Started

0.) Please download the zip file bellow if you haven't done so already - [Blackberry\_Sound\_Profiles\_for\_Android.zip][2]

1.) First, if you haven't already, install Tasker (you can use the Android Market, or the guys' website). You can play with it for 7 days for free.  
2.) It will create a "Tasker" folder on your SD card. Under that you will find "tasks" and "profiles" folders (if they don't exist yet, create them).  
3.) Download the zip to your computer, mount your phone's SD card and go into the main "Tasker" folder under the sdcard. If the file ends in .prf, put it in the "profiles" folder. If it ends in ".tsk", place it in the "tasks" folder. Unmount, disconnect your phone.  
4.) Now that you have them, you need to load what you want/need into the program. Open up Tasker (program), ~~hit Menu, and go to "Profile Data". Do a "Import One Profile" or "Import One Task"~~select one of the "tabs" (Profiles, Tasks, Scenes), and hold it - an "Import" option will present itself, which will let you import a Profile or Task (or not relevant here - a Scene). This is because Tasker changed the way profiles and tasks (and Scenes) are imported . As soon as you select that, you will see all the files in the directory that you copied. Now you can import whatever you want.

You should import the "Volume Buttons" Profiles (note: this is a profile), at least the "Normal" and "Sleep" tasks (note: these are tasks). The volume buttons profile is honestly a life saver since any time you tap a volume button, it will actually restore to the sound-profile task you have selected.

Now to use them,

5.) Hold down on the home screen, select Widget (for ICS 4, Widgets are created by going to Applications, and shifting over to widgets), select Task. It will show you a list of your tasks. Select "Normal" for example. It will show it to you (in case you have to make any changes last minute - don't do it this way, always make them in editor), now select the green check and you are Done! You can now use it as a "program" on your home screen. Add at least 2 this way, and select them. Wait 1-2 seconds. You will see how it select/enables each, and then after it enables it, hit the volume keys on purpose, and then wait 1-2 seconds again to see how it restores it.

**END OF GETTING STARTED - THAT'S IT! You have it working!**

 

 

Ahh, you've continued reading and you haven't skipped this...Clearly you care about some of the theory...

One of the biggest problems with Android is the sound profiles. **I will start off with the main sound profile BUG**:

Try setting your Settings -> Sound -> Vibrate to "Only when in Silent", and then hold the power key, change the "Silent mode" to ON. Now hold the power key again, and change the "Silent mode" to OFF. Check your Settings -> Sounds -> Vibrate mode - it is changed incorrectly to "Always". This renders the built-in "sound profiles" completely useless.

Here are bug reports that are all for the same thing: [Issue 20463](http://code.google.com/p/android/issues/detail?id=20463) and [Issue 13732](http://code.google.com/p/android/issues/detail?id=13732)

UPDATE: Please note that Google "sort of" fixed this, to a point, where we can now correctly implement the functionality using Tasker at least. It's not there by default, but the "Silent Mode" now works for on (sleep), off, and vibrate, and there's a separate toggle-able Ring+Vibrate feature.

Pretty much, half of [these](http://code.google.com/p/android/issues/list?can=2&q=vibrate&colspec=ID+Type+Status+Owner+Summary+Stars&cells=tiles) are the same issue. The main problem is that the Silent _and_ Vibrate options for android, are really one single "Silent Mode". The problem arises because Sound -> Vibrate settings only apply for "Silent Mode". This means that you cannot have a completely silent profile and a vibrate only profile, and a "normal" profile. This is the most evident to anyone coming from a blackberry, where the sound profiles are flawless. I've read thousands and thousands of questions asking "how do I get sound profiles like on the blackberry". Personally, this was the first thing that drove me crazy when I moved away from the blackberry.

Most people default to using a program which creates "Profiles" - setting bundles which simply toggle each Sound option (In-Call volume, Media, Ring Tone, Notification, Alarm, and System). The best one I've seen is AudioGuru, which is great, but it does lack some customization. The one additional step that most programs lack also is some sort of a guard for the volume buttons which toggle the ringtone.

My goal when thinking about all of this was to create a solution that was simple, extendable, and complete. The main points I was going after was to have profiles that are completely stand-alone, extendable/fully customizable, and completely scriptable. The end result was what I call "Blackberry Sound Profiles for Android".

 

First off, here's the download:

> [Blackberry\_Sound\_Profiles\_for\_Android.zip][2]  
> (md5: 71d0701ce63a6953a997145c758753c8)
> 
> (don't forget to go to Settings -> Sound -> and UNCHECK "Use incoming call volume for notifications". Also, Settings -> Language & keyboard -> Android keyboard -> and CHECK "Sound on keypress")

The logic becomes part of 3 sections. The **FIRST SECTION** is the Tasker sound profile tasks. These are "stand alone" tasks, which simply encompass every aspect of a sound profile. Let me walk through one of them:

"Normal.tsk.xml"

0.) Set a default icon (used grey star in this case)  
1.) Wait - 2 seconds  
[note - for ICS 4, there is an extra step in here turning off the Ring+Vibrate fixed feature]  
2.) Silent  Mode - off  
3.) In-Call Volume - 5  
4.) Media Volume - 9  
5.) Ringer Volume - 5  
6.) Notification Volume - 5  
7.) System Volume - 6  
8.) Alarm Volume - 7  
9.) Set Widget Icon (to %PROFILE - used default grey star)  
10.) Variable Set (%PROFILE to "Normal")  
11.) Set Widget Icon (to %PROFILE - used the grey sound icon)  
12.) Notify - %PROFILE  
13.) Wait - 1 second  
14.) Notify Cancel - %PROFILE

Let me clarify some key things:  
step #9 is needed in order to clear the old Icon back to a star.  
step #10 sets the global variable to the name of this profile  
step #11 activates the pressed/toggled widget

I've also included a "Sleep" sound-profile task (toggles all down except alarm and media), a "Work" sound-profile task (same as "Normal" sound-profile task, but the notification is less and the system sound is less so the keyboard is not obnoxious), a "Loud" sound-profile task (makes everything as loud as possible basically), a "Vibrate" sound-profile task (like sleep, but has vibrate on), and a "On-Call" sound-profile task (like sleep, but ring tone is low).

I am not sure if you are already picking up what's going on, but basically, the idea is that you have a few of these sound-profile tasks, and you create widgets on the home screen. They all show up as grey stars. When you press "Normal" or "Sleep" for example, it changes the star to the correct icon (Sound Icon, or Muted Icon), and shows it on your home screen and notify's in your notification bar (after which, a second later, it clears the notification bar). Now, go through the other profiles to see what they do. They are all pretty much the same, except the Vibrate profile, which uses step #2 to select the official Android "Silent" mode, with a Vibrate outlet.

Now, the **SECOND SECTION** is a single Tasker task called "Sound Profile" which has one step:

1.) Perform Task - %PROFILE

And now you see why step #10 from section one is needed. When this task is called, it will change the current Sound profile to the global variable (%PROFILE). Please import this task too. Why is this needed you ask? Because of my clever hack in the **THIRD SECTION**:

Here is where you have a Tasker Profile. It is called "Volume Buttons". The basic logic is as follows:

1.) If Variable Set %VOLR (ringer volume), then call the "Sound Profile"

This essentially achieves a volume-reset every time you accidentally hit the volume up or down keys. Now you can see why the "Wait - 2 seconds" was needed. The key part about this is that it uses your global variable, and it resets your volume to the last Sound profile that you selected. Great huh? Please make sure you import the "Volume Buttons" profile into Tasker.

At last you are Done! You now have individual Tasker tasks which you can make widgets out of. I have the 3 that I use the most - Normal, Silent, and Work (work being a bit quieter on the notification and system sound for the keyboard noise) on my main home screen. Then I have the Loud, Vibrate, and On-Call on another screen since I use them less often.

## Optional Fourth Section: On-Call Profile

For the people interested, the 'On-Call' task works in a super elegant way: it silences everything except the ring tone (which it lowers), the alarm, and the media volume. The media volume is the key here. Let's say you want SMS notifications but not emails while you are on-call. They both use the "notification" system, so there's no way to do this by default (yet another ex-blackbery annoyance). What you can do is write a Tasker profile which interprets a "Notification Messaging, *" notify, (you can check the time if you are only on-call during the night or day) and then have the action for the task for the profile call the "Music Play" action which simply plays your SMS sound as an MP3. This essentially lets you isolate one application from another, by using the fact that you can play the selected notification through the media outlet. Beautiful Eh?

I hope all of this helps people out.

## Update - Added "One Ring" Task and Profile Monitor

I've updated the zip pack with two additions: a task which will provide you with a "One-Ring" sound-profile task - it's basically the normal profile, but it brings the Ringer Volume to 0, and it increases the Media Volume up to 11. Also, I've added a "One\_Ring\_Monitor" profile, which intercepts calls, and plays a music file (mp3, wav, ogg, others...) - giving you the ability to play a notification - thus a single beep/sound.

**  
**

 [1]: /2011/12/27/tasker-ics-android-4-0-blackberry-sound-profiles "/2011/12/27/tasker-ics-android-4-0-blackberry-sound-profiles"
 [2]: https://media.vpetkov.net/wp-content/uploads/2011/09/Blackberry_Sound_Profiles_for_Android.zip "Blackberry_Sound_Profiles_for_Android.zip"