---
title: Spoofing Caller ID on the fly from any phone for legal and legitimate purposes
author: Ventz
type: posts
date: 2011-07-10T07:27:54+00:00
url: /2011/07/10/spoofing-caller-id-on-the-fly-from-any-phone-for-legal-and-legitimate-purposes/
categories:
  - Old-WordPress-Blog
tags:
  - old-wordpress-blog
  - documentation
  - hack
  - linux
  - privacy
  - security
  - sip

---
This post is a bit different, but I think some people will find it very interesting. What got me to write this was an interesting article posted by Kevin Mitnick via his twitter account: <http://news.cnet.com/8301-27080_3-20077732-245/kevin-mitnick-shows-how-easy-it-is-to-hack-a-phone/?part=rss&tag=feed&subj=News-Security>. Kevin's claim is that "Any 15-year-old that knows how to write a simple script can find a VoIP provider that spoofs caller ID and set this up in about 30 minutes", and my only question is: what will you do with the other 25 minutes?

**START OF NOTE AND WARNING!  
** Spoofing your Caller ID is legal in the US only if done via VOIP services for legal and legitimate uses, or to block sending your caller ID, but again, only if it is used for legal purposes. An example of a legitimate use is spoofing your own home/cell phone number when making outbound calls via VOIP/SIP. Another example would be spoofing an outgoing number (a bit like NATing) when sitting at a private (let's say for example 2,3,4, or 5 digit) extension. There are many scenarios where this is absolutely needed - like offices, enterprises, remote employees/road warriors, and phone support.  
Spoofing your Caller ID is **_not_** legal for false identity, threatening/harassing someone, pranking, lying, or other such negative and immoral actions. If you are interested in some more information, you can find some here: <http://www.gordostuff.com/2011/06/fcc-ups-caller-id-spoofing-penalties.html>, and here: <http://www.gordostuff.com/2011/02/is-faking-caller-id-legal-in-united.html>. This said, I am providing this information for anyone who wants to learn about how this is done, or/and is interested in setting it up for their business or personal use, but **ONLY** for legal and legitimate uses. I am in no way responsible if you do something stupid or illegal. Here is a good background/history and more information on Caller ID Spoofing: <http://www.calleridspoofing.info/>  
**END OF NOTE AND WARNING!**

The assumption here is that you have some things already setup and working. The article is titled "Spoofing Caller ID on the fly from any phone" and not "how to spoof your Caller ID". I am assuming that you have: a sip trunk provider with an outgoing plan, a DID, a SIP server with some advanced features (Asterisk and OpenPBX, or something like TrixBox), and most of all - a working setup. The first step is getting DISA (Direct Inward System Access - <http://www.voip-info.org/wiki/view/Asterisk+cmd+DISA>). The idea is that you will dial your DID phone number, and the sip trunk provider will route it to your IP address. From there, your server will handle the call and connect you inside your system. I absolutely suggest setting up a DISA password/passcode, otherwise, you leave yourself open to abuse and other people will be able to potentially make calls and use your sip account. It is also important to note that generally, you can simply set a from name and number right here in the DISA outbound options. But again, the idea is to make this dynamic. Ones you dial into your system, the next step is to setup an extension that will handle the rest of this. Leave your context "from-internal" if you want to be able to make external calls by default - necessary in order to bridge the active call to your destination. If you are using Asterisk or TrixBox, go to /etc/asterisk/extensions_custom.conf, and enter something like this:  
```
[from-internal-custom]
include => proof-of-concept-custom

[proof-of-concept-custom]
exten => 12345,1,Answer
exten => 12345,n,Wait(2)
exten => 12345,n,SayDigits(${CALLERID(number)})
exten => 12345,n,Answer
exten => 12345,n,Wait(2)
exten => 12345,n,Playback(privacy-prompt)
exten => 12345,n(collect),Read(digito,,10)
exten => 12345,n,SayDigits(${digito})
exten => 12345,n,Set(CALLERID(number)=1${digito})
exten => 12345,n,Answer
exten => 12345,n,Wait(2)
exten => 12345,n,Playback(custom/would-you-like-to-connect,skip)
exten => 12345,n(collect),Read(digito,,5)
exten => 12345,n,GotoIf($[${digito}==98765]?call:hangup)=
exten => 12345,n(end),Hangup()
exten => 12345,n(call),Answer
exten => 12345,n,Wait(2)
exten => 12345,n,Playback(activated,skip)
exten => 12345,n,Dial(SIP/Provider/${CALLERID(number)},300)
``` 

Now here's what's happening: When you get your DID, you get the DISA context. From there, after you authenticate yourself with a pin and now you are in your system. At this point, you would hook in your custom context, in this case called "proof-of-concept-custom". Make sure that the word "custom" is present somewhere. At this point, your recipe will be executed. The first thing you want to do is answer. You can look up each of these commands at the voip-info.org website. For example, Answer: <http://www.voip-info.org/wiki/view/Asterisk+cmd+Answer>. The next step is to wait 2 seconds. Then you will speak out the current caller ID. This is really just so you know where you are coming from - it is not neccessary. The play (mp3/wav/etc...) play is not really necessary either, but it can be used to queue up different actions. If you will play something, the suggestion is to Answer the channel before hand, and pause/wait for a bit. The next step is to read 10 digits into the "digito" variable. For good measure, and to prevent a mistake, you can speak out the digits again, and then set them as the current Caller ID (the spoofing part). At this point, you can play another sound to queue up the next action. As an extra precaution/security-by-obscurity step, you can prompt for another pin. In this case, it's "98765". After the pin has been successfully entered, you can signal via a sound, and then dial and bridge the call to the same number that you set as your Caller ID (impractical, but just for the purpose of a proof of concept). You can very easily modify this to ask for a destination number and call that destination number instead. Please note that this will charge you a twice from the point that you dial the call and bridge it - once for the current/already active call, and once for the new call that you are making to your destination.

Again, there are many legitimate and absolutely necessary cases for this. If you work in any company, most of the time they will not disclose private numbers. If the company is very large, they might simply not have/want to buy individual "routable" phone numbers. Your desk extension of "1234" can be masked behind a general number which routes to "directory/support" when called back. Another great case is someone who works from remote. Say that you work from home and are part of a support group. A customer calls you and reports a problem. Now you want to call the customer back, but you don't want him to have your personal home number/cellphone - you can spoof your support number and call the customer back.

Something interesting to note is that VOIP/SIP system can choose to not respect Caller ID (cid) blocking/spoofing, and and 1-800/other TOLL-FREE numbers simply do not respect it.

The only point of this article is to demonstrate how easy it is to achieve this dynamically. Again, this is something that you can very easily set statically in the extension or DISA settings. This is not something new or mind blowing. You could have done this over 10 years ago. The point is that you can have a setup which can be activated from any phone and within 30 seconds or less, you can have a dynamically spoofed Caller ID number.