---
title: Change the Exchange Calendar Color on the iPhone
author: Ventz
type: posts
date: 2011-02-20T03:39:48+00:00
url: /2011/02/19/change-the-exchange-calendar-color-on-the-iphone/
categories:
  - Old-WordPress-Blog
tags:
  - old-wordpress-blog
  - apple
  - exchange
  - hack
  - iphone
  - sql

---
Let me preface this with the fact that, you just can't do this unless your iphone is jailbroken. For the non-curious, stop reading here.
 
This one came about as I was recently forced at work to switch from using the Unix email system to the hosted Exchange solution, in order for our calendars to be centrally accessible by everyone. Details aside, after adding my exchange to my iPhone (since I am trying to keep my blackberry off BES), I realized that the color schemes absolutely suck. From somewhere, it decided that purple was the best color, and I couldn't change it. After aimlessly searching through the Calendar.app on the iPhone for a color changing option, I came to the realization that there was no way to do it. Luckily, my iphone was jailbroken, and there are plenty of ways to do this with a little background work. I found this amazing article: <http://chriscarey.com/wordpress/2009/02/10/how-to-modify-iphone-calendar-colors-with-sqlite3/>
  
To summarize it, in case the article disappears:
  
Start by ssh-ing into your phone
  
```
$ cd /var/mobile/Library/Calenda
$ sqlite3 Calendar.sqlitedb
sqlite> select title,color_r,color_g,color_b from Calendar; -- List calendars and current colors
Default|-1|-1|-1
Michael Ansel|181|0|13
School-Important|47|141|0
School-Studying|15|77|140
School-Class|229|98|0
sqlite> update Calendar set color_r=181, color_g=0, color_b=13 where title = 'School-Important'; -- Red
sqlite> update Calendar set color_r=229, color_g=98, color_b=0 where title = 'School-Studying'; -- Orange
sqlite> update Calendar set color_r=103, color_g=10, color_b=108 where title = 'School-Class'; -- Purple
sqlite> update Calendar set color_r=15, color_g=77, color_b=140 where title = 'Michael Ansel'; -- Blue
sqlite> select title,color_r,color_g,color_b from Calendar; -- List calendars and current colors
Default|-1|-1|-1
Michael Ansel|15|77|140
School-Important|181|0|13
School-Studying|229|98|0
School-Class|103|10|108
sqlite> .quit
$ exit
```
    

One tip that I can give, if you don't have sqlite3 on your iphone (which you wouldn't by default), is to scp the file to your computer, apply the changes, and scp it back to the iPhone.

Here are the RGB Values for the Standard Colors:
```
Red = (181,0,13)
Orange = (229,98,0)
Green = (47,141,0)
Blue = (15,77,140)
Purple = (103,10,108)
```


So, with the line:
    
```
update Calendar set color_r=181, color_g=0, color_b=13 where title = 'Calendar';
```
  I was able to make my default calendar (the Exchange one) RED - which portrayes the "important" notion and it's easily visible.
    
  Hope this helps everyone who is trying to accomplish this. Don't forget to close and re-start your Calendar.app. If you don't have a jailbroken iPhone, you can change your non-exchange calendars by syncing them to the iCal app, and changing the color back, and syncing them.
