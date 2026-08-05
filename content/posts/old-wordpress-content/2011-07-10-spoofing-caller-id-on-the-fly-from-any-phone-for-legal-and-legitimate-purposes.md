---
title: Spoofing Caller ID on the fly from any phone for legal and legitimate purposes
author: Ventz
type: post
date: 2011-07-10T07:27:54+00:00
url: /2011/07/10/spoofing-caller-id-on-the-fly-from-any-phone-for-legal-and-legitimate-purposes/
categories:
  - Uncategorized
tags:
  - documentation
  - hack
  - linux
  - privacy
  - security
  - sip

---
This post is a bit different, but I think some people will find it very interesting. What got me to write this was an interesting article posted by Kevin Mitnick via his twitter account: <a href="http://news.cnet.com/8301-27080_3-20077732-245/kevin-mitnick-shows-how-easy-it-is-to-hack-a-phone/?part=rss&tag=feed&subj=News-Security" data-versionurl="http://blog.vpetkov.net/amber/cache/f8901c0a87334c2da6198e1f29666c1f/" data-versiondate="2020-04-05T07:50:25+00:00" data-amber-behavior="" target="_blank">http://news.cnet.com/8301-27080_3-20077732-245/kevin-mitnick-shows-how-easy-it-is-to-hack-a-phone/?part=rss&tag=feed&subj=News-Security</a>. Kevin&#8217;s claim is that &#8220;Any 15-year-old that knows how to write a simple script can find a VoIP provider that spoofs caller ID and set this up in about 30 minutes&#8221;, and my only question is: what will you do with the other 25 minutes?

**START OF NOTE AND WARNING!  
** Spoofing your Caller ID is legal in the US only if done via VOIP services for legal and legitimate uses, or to block sending your caller ID, but again, only if it is used for legal purposes. An example of a legitimate use is spoofing your own home/cell phone number when making outbound calls via VOIP/SIP. Another example would be spoofing an outgoing number (a bit like NATing) when sitting at a private (let&#8217;s say for example 2,3,4, or 5 digit) extension. There are many scenarios where this is absolutely needed &#8212; like offices, enterprises, remote employees/road warriors, and phone support.  
Spoofing your Caller ID is **_not_** legal for false identity, threatening/harassing someone, pranking, lying, or other such negative and immoral actions. If you are interested in some more information, you can find some here: <a href="http://www.gordostuff.com/2011/06/fcc-ups-caller-id-spoofing-penalties.html" data-versionurl="http://blog.vpetkov.net/amber/cache/ba69a086a925274ba46095050eb76d81/" data-versiondate="2020-04-05T07:49:48+00:00" data-amber-behavior="" target="_blank">http://www.gordostuff.com/2011/06/fcc-ups-caller-id-spoofing-penalties.html</a>, and here: <a href="http://www.gordostuff.com/2011/02/is-faking-caller-id-legal-in-united.html" data-versionurl="http://blog.vpetkov.net/amber/cache/43e95dd89c59386a0cd3587267306ad7/" data-versiondate="2020-04-05T07:48:57+00:00" data-amber-behavior="" target="_blank">http://www.gordostuff.com/2011/02/is-faking-caller-id-legal-in-united.html</a>. This said, I am providing this information for anyone who wants to learn about how this is done, or/and is interested in setting it up for their business or personal use, but **ONLY** for legal and legitimate uses. I am in no way responsible if you do something stupid or illegal. Here is a good background/history and more information on Caller ID Spoofing: <a href="http://www.calleridspoofing.info/" data-versionurl="http://blog.vpetkov.net/amber/cache/6e58975447723ee3848b3d01d0b44896/" data-versiondate="2020-04-05T07:49:18+00:00" data-amber-behavior="" target="_blank">http://www.calleridspoofing.info/</a>  
**END OF NOTE AND WARNING!**

The assumption here is that you have some things already setup and working. The article is titled &#8220;Spoofing Caller ID on the fly from any phone&#8221; and not &#8220;how to spoof your Caller ID&#8221;. I am assuming that you have: a sip trunk provider with an outgoing plan, a DID, a SIP server with some advanced features (Asterisk and OpenPBX, or something like TrixBox), and most of all &#8212; a working setup. The first step is getting DISA (Direct Inward System Access &#8211; <a href="http://www.voip-info.org/wiki/view/Asterisk+cmd+DISA" data-versionurl="http://blog.vpetkov.net/amber/cache/dd7da66bd9f25ca5df5d95c5cf2387fa/" data-versiondate="2019-01-29T03:35:10+00:00" data-amber-behavior="down hover:2" target="_blank">http://www.voip-info.org/wiki/view/Asterisk+cmd+DISA</a>). The idea is that you will dial your DID phone number, and the sip trunk provider will route it to your IP address. From there, your server will handle the call and connect you inside your system. I absolutely suggest setting up a DISA password/passcode, otherwise, you leave yourself open to abuse and other people will be able to potentially make calls and use your sip account. It is also important to note that generally, you can simply set a from name and number right here in the DISA outbound options. But again, the idea is to make this dynamic. Ones you dial into your system, the next step is to setup an extension that will handle the rest of this. Leave your context &#8220;from-internal&#8221; if you want to be able to make external calls by default &#8212; necessary in order to bridge the active call to your destination. If you are using Asterisk or TrixBox, go to /etc/asterisk/extensions_custom.conf, and enter something like this:  
`[from-internal-custom]<br />
include => proof-of-concept-custom</p>
<p>[proof-of-concept-custom]<br />
exten => 12345,1,Answer<br />
exten => 12345,n,Wait(2)<br />
exten => 12345,n,SayDigits(${CALLERID(number)})<br />
exten => 12345,n,Answer<br />
exten => 12345,n,Wait(2)<br />
exten => 12345,n,Playback(privacy-prompt)<br />
exten => 12345,n(collect),Read(digito,,10)<br />
exten => 12345,n,SayDigits(${digito})<br />
exten => 12345,n,Set(CALLERID(number)=1${digito})<br />
exten => 12345,n,Answer<br />
exten => 12345,n,Wait(2)<br />
exten => 12345,n,Playback(custom/would-you-like-to-connect,skip)<br />
exten => 12345,n(collect),Read(digito,,5)<br />
exten => 12345,n,GotoIf($[${digito}==98765]?call:hangup)=<br />
exten => 12345,n(end),Hangup()<br />
exten => 12345,n(call),Answer<br />
exten => 12345,n,Wait(2)<br />
exten => 12345,n,Playback(activated,skip)<br />
exten => 12345,n,Dial(SIP/Provider/${CALLERID(number)},300)<br />
` 

Now here&#8217;s what&#8217;s happening: When you get your DID, you get the DISA context. From there, after you authenticate yourself with a pin and now you are in your system. At this point, you would hook in your custom context, in this case called &#8220;proof-of-concept-custom&#8221;. Make sure that the word &#8220;custom&#8221; is present somewhere. At this point, your recipe will be executed. The first thing you want to do is answer. You can look up each of these commands at the voip-info.org website. For example, Answer: <a href="http://www.voip-info.org/wiki/view/Asterisk+cmd+Answer" data-versionurl="http://blog.vpetkov.net/amber/cache/dd14664aceab064e94ff6b38a9eb6abd/" data-versiondate="2019-01-29T03:35:05+00:00" data-amber-behavior="down hover:2" target="_blank">http://www.voip-info.org/wiki/view/Asterisk+cmd+Answer</a>. The next step is to wait 2 seconds. Then you will speak out the current caller ID. This is really just so you know where you are coming from &#8211; it is not neccessary. The play (mp3/wav/etc&#8230;) play is not really necessary either, but it can be used to queue up different actions. If you will play something, the suggestion is to Answer the channel before hand, and pause/wait for a bit. The next step is to read 10 digits into the &#8220;digito&#8221; variable. For good measure, and to prevent a mistake, you can speak out the digits again, and then set them as the current Caller ID (the spoofing part). At this point, you can play another sound to queue up the next action. As an extra precaution/security-by-obscurity step, you can prompt for another pin. In this case, it&#8217;s &#8220;98765&#8221;. After the pin has been successfully entered, you can signal via a sound, and then dial and bridge the call to the same number that you set as your Caller ID (impractical, but just for the purpose of a proof of concept). You can very easily modify this to ask for a destination number and call that destination number instead. Please note that this will charge you a twice from the point that you dial the call and bridge it &#8212; once for the current/already active call, and once for the new call that you are making to your destination.

Again, there are many legitimate and absolutely necessary cases for this. If you work in any company, most of the time they will not disclose private numbers. If the company is very large, they might simply not have/want to buy individual &#8220;routable&#8221; phone numbers. Your desk extension of &#8220;1234&#8221; can be masked behind a general number which routes to &#8220;directory/support&#8221; when called back. Another great case is someone who works from remote. Say that you work from home and are part of a support group. A customer calls you and reports a problem. Now you want to call the customer back, but you don&#8217;t want him to have your personal home number/cellphone &#8211; you can spoof your support number and call the customer back.

Something interesting to note is that VOIP/SIP system can choose to not respect Caller ID (cid) blocking/spoofing, and and 1-800/other TOLL-FREE numbers simply do not respect it.

The only point of this article is to demonstrate how easy it is to achieve this dynamically. Again, this is something that you can very easily set statically in the extension or DISA settings. This is not something new or mind blowing. You could have done this over 10 years ago. The point is that you can have a setup which can be activated from any phone and within 30 seconds or less, you can have a dynamically spoofed Caller ID number.