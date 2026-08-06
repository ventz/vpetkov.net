---
title: Timed Blackberry Sound Profiles for Android
author: Ventz
type: posts
date: 2012-02-01T05:06:04+00:00
url: /2012/02/01/timed-blackberry-sound-profiles-for-android/
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
The general idea behind this is that it utilizes my original Blackberry Sound Profiles for Android and it adds a "timer" element which can be set. Upon setting the timer, it will set a temporary task until the timer runs out. The idea came from one of my visitors who asked me how to do this. At first, I had no idea how to do it. About 30 minutes later I had a semi-working prototype. Another 3 hours later (had to figure out how Scenes worked and interacted with variables and the rest of the system) I had the final version with a working GUI.

The first thing that you need are my Tasker Blackberry Sound Profiles found here: (<http://blog.vpetkov.net/2011/05/10/my-tasker-program-blackberry-sound-profiles-for-android>). If you don't have them yet, follow the super quick "Getting Started" section. Once you have the tasks and you have them working (if you want this to work out of the box, grab at least the "Work" task and the "Sleep" task), download the Timed extension:

Note: You need the current BETA to import this profile: http://tasker.dinglisch.net/beta.html (1.2.1b4m)

> [Timed.zip][1]  
> (md5: 5709a9ed0b139a027900d9f8f1e2e92a)

Now unzip it and follow the same steps from the original post - grab the "Timed.tsk.xml" file and import it into the the Tasks tab, and then grab the "TimedScene.scn.xml" file and import it into the Scenes tab. Go to your home screen and create a Tasker widget of your "Timed" task. Every time you select this task, it will pop a box which will let you use a slider or directly type in a number. After this, when you hit "Set Profile", the temporary task (by default "Sleep") will get activated for the number of minutes you set. After that time period it will go back to the other (by default "Work") task.

<!--more-->

 

## Usage

1.) Make sure that you have at least my "Work" and "Sleep" sound-profile tasks. If you don't, at least have any 2 sound-profiles, and edit the "Tap" action for the "Set Profile" button to have the two tasks.

2.) Create a widget on your home screen from the "Timed" task. Then launch the GUI from it, and set a minute count using the input box (top right), the slider, or the plus and minus keys. HINT: if you hit and hold the plus/minus buttons, they increase and decrease the minute count by 10. Use one or all. Whatever works the best

3.) Click "Set Profile". What this will do is create a permanent notification with the time you started and for how long, and then set the "Sleep" profile (or whatever you chose instead) for the given time period. When the time expires, it will revert to the "Work" profile (or whatever you chose instead). If you want to cancel it early, select the "Timed" task widget from the home screen, and click "Cancel Profile".

 

## Technical Details

1.) The "Timed" task simply acts as a launcher. I use it so that I can launch my Timed Scene as a Dialog box. Being a task, you can also create a widget out of it for the home screen. This acts as the entry point to the program/GUI. I also use it to set some defaults - specifically: the default minute count in the %TMINUTE variable, and then I reflect the variable in the input box and the slider.

2.) The Timed Scene is the work horse here. One way you can set things is by entering a value in the input box at the top right. As soon as you do that, the %TMINUTE variable is set and the slider is changed accordingly. The second way to set things is via the Plus and Minus buttons. If you tap them, they will increase and decrease the %TMINUTE variable by 1. If you tap and hold them, they will increase and decrease the variable by 10. Taping them will also change the slider and set the count in the input box accordingly. The third way is to slide the slider. This will once again set the %TMINUTE variable, and it will change the input box to reflect accordingly. The "Set Profile" button destroys the GUI, sets a permanent notify with the start time and the number of minutes you have selected,  and it performs the task. It then waits the number of minutes that you have chosen and it basically undoes everything when the timer goes off. The "Cancel Profile" button destroys the GUI, expires the timer and removes the permanent notification. This in turn activates the "undo" section in the "Set Profile" section, which sets the "Work" profile and removes the permanent notification.

 

"Set Profile" button action in the Timed Scene is the work horse. It holds all the glue and magic to make this work. The main idea here is to pull the current time in seconds, add the value of seconds you want to wait (the input of minutes multiplied by 60) into a variable called %TALERT, and then poll every minute for the condition of the current time being greater than the value of %TALERT. Simple and beautiful huh? A few other things are having the sticky Notify and then removing it, and performing the Tasks obviously.

Good luck, and as always, feel free to ask questions. I'll try my best to help out.

 [1]: https://media.vpetkov.net/wp-content/uploads/2012/02/Timed1.zip "Timed.zip"