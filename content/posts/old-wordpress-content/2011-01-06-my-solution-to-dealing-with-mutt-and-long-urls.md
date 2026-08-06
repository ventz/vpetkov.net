---
title: My Solution to Dealing with Mutt and Long URLs
author: Ventz
type: posts
date: 2011-01-06T21:43:28+00:00
url: /2011/01/06/my-solution-to-dealing-with-mutt-and-long-urls/
categories:
  - Old-WordPress-Blog
tags:
  - old-wordpress-blog
  - hack
  - linux
  - mutt
  - perl

---

---

**[updated: Jan 2nd, 2013 | Updated 'tiny.pl' to skip "mailto:" references ... it polluted emails with replies]**

**[updated: Nov 28th, 2012 | Updated 'tiny.pl' to be much more efficient which resulted in a crazy speedup]**

---

Yesterday I received one too many emails with a long URL that I actually needed to click on. Why is this a problem you wonder? - I use Mutt. Yes, I've heard it all, and yes, I don't think it's the best email client, but when you spend all day in a terminal, it's simply a pain launching the browser to send a single email. It's a "ctrl+a, #, m, type...type, y...sent", vs "open browser, go to url, log-in, compose, type...type, hit send". Anyway, given that I am using the Apple Terminal.app ~~which for some reason has not been upgraded in the last 8 years to include hot linking URLs everywhere~~ (correction: It does, but it does not always handle right clicking multi-line links which contain "strange characters and symbols"), I have to suffer. I've been toying with the idea of parsing my mutt emails for a while now, and yesterday I finally decided to sit down and write something. My starting point was my .mailcap entry  
```
text/html;                      lynx -dump %s ; copiousoutput ;  nametemplate=%s.html
```

My first thought was, why not hook a custom perl script to parse the text from the email, extract the urls, and shorten them? After a little bit of work, I realized that I care about the rest of the text too and not just the URLs. The final solution can be found here:

<http://perl.vpetkov.net/tiny.pl> **[updated: Jan 2nd, 2013]**

In order to use it, you need to put this some where (.mutt is a good place), and then modify your .mailcap:

```
text/html;                      ~/.mutt/tiny.pl %s ; copiousoutput ;  nametemplate=%s.html
text/plain;                      ~/.mutt/tiny.pl %s 't' ; copiousoutput ; nametemplate=%s.html
```

The script starts by NOT reinventing the wheel, and utilizing lynx to parse out the HTML. Please note that this is done only for the 'text/plain' type. The way the same script is overloaded is by supplying a second argument for non-html based emails. As you will see, I actually use elinks to parse for html instead of lynx, and the reason for that is because lynx introduces a new character on long URLs for some reason, when used with -dump. This created problems with shortening the URLs. Then the script splits the resulting output into lines, and then it splits each line into "words". Each "word" is checked for being an URL. If it is, and it's less than the "trigger" number of characters, it's shortened and printed, along with the original (nice to keep track). Otherwise, the word is just printed and the process repeats until the end.

While this is EXTREMELY simple concept wise, it is very useful. Is there a down side? - Yes - some potentially private URLs are now public. Solution? - Yes - sign up for bit.ly Pro (free) and use your own domain name. At last, I just want to tack on that while searching for an existing solution to this, I did find a program called "urlview". I haven't tried it, but it seems like a much better solution. Here's some more information on it: <http://linuxcommand.org/man_pages/urlview1.html>

UPDATE: As it turns out, Terminal.app actually picks up some/most/(all?) long urls. I think it was 'lynx' that was wrapping the line at 65-72 characters, which ended up being the cause for the '+' in front of long URLs and the break onto two lines. Anyway, so basically, this means that if you don't use 'lynx' for the HTML parsing, you can potentially click on the links. Either way, I still prefer having tinyurls. Also, I did find a bug in the 't' (non-html emails) version of the script, where in some cases, it will rip out the URL but now show it at all (original or shortened). I noticed this 2 times (out of 1000+ emails), but I just haven't had time to look into it. I have a feeling that it's not really my script. The email comes in not containing any html other than an html a href tag. I think that messes with the detection.
