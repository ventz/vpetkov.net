---
title: How to Tunnel SMTP (Postfix) server to Google (Gmail/Google Apps)
author: Ventz
type: posts
date: 2010-11-15T16:42:48+00:00
url: /2010/11/15/how-to-tunnel-smtp-postfix-server-to-google-gmailgoogle-apps/
categories:
  - Old-WordPress-Blog
tags:
  - old-wordpress-blog
  - documentation
  - gmail
  - google
  - hack
  - linux
  - postfix
  - smtp

---
If you just want the good stuff (configs, how-to's about this), check out:

[vpetkov.net/legacy/documentation/network-services/smtps-and-imaps/how-to-tunnel-smtp-postfix-server-to-google-gmailgoogle-apps/](/legacy/documentation/network-services/smtps-and-imaps/how-to-tunnel-smtp-postfix-server-to-google-gmailgoogle-apps/)

If you want to read my full story behind why I even went this route, please continue bellow:

Recently I started looking at getting rid of as much physical infrastructure as possible. My reasons, among it being a pain to maintain, everything surrounding having your own infrastructure is a downfall. Let's face it - you can't afford what is really needed to have 99.99%-100% uptime. There are tricks that you can use to join multiple sites, but again, when you really get into it, it costs money and it takes time. Other than having an ESX server as a personal "lab", I've realized that I spend just as much time dealing with physical infrastructure, as I do creating services, hosting stuff, automating things, and programming. This is just wrong! Also, hosting your own infrastructure means dealing with power, bandwidth, static IPs, etc... Anyway, so with that in mind, I started looking at getting rid of my biggest service which had the fewest users - Email.

I hosted a Zimbra server (which I absolutely love) for almost a year, and before that I hosted for 7+ years (and still do at different locations) mail servers running Postfix+Dovecot+SpamAssassin with Some webmail client (Squirrelmail or RoundCube). The problem with hosting your own email server (i'll use Postfix synonymous with email server) is that everything is a hassle and a half. At the end of the day, if you have one Postfix server, this is fine. If you have 50+ Postfix servers, not so much. And yes, you can ease it by using puppet and common config management like svn+rsync, but it's still a hassle. The other problem is that common needs like push email, exchange, blackberry BES, calendars, notes, and others simply do not exist as a "one in all" solution that attaches to Postfix. I realized that while being extremely efficient, and while procmail being simply priceless, it is not economical at the end of the day. Users want ease of use, convenience, pretty UIs, and no spam without any effort on their behalf.

This led me into looking at Google Apps (I'll use Gmail synonymous). It seemed like the perfect solution - off site, fully managed, relatively cheap (or free), common UI which almost everyone is familiar with, and virtually no spam. It provided smtp(s), imap(s), pop(s), and other common services. The few problems that should be brought up front are: privacy, security, space, and limitations. With "GMail", (free google app), you are limited to 7-7.5GB per user, 25 users, and "some" advanced SMTP features. You can always pay $50/year/account in order to 25GB with unlimited users and some more programmable/API features. The thing that really attracted me was the ability to get an "all-in-one" solution that was extremely easy to deploy for multiple users. The reality is that most users just want their own email at their own domain, with some storage, some web UI, and no spam or viruses. This was something that I was doing with my "Postfix setup", and I had scripted quite well infact, but with Google Apps, it was a matter of 15 minutes per account.

Now, the main two problems were: how do my users who use mutt (myself being one of them) get to their email, and how to existing services AND "dumb services" (storage devices, vCenter, etc...) communicate to the "Gmail" servers. The first - mutt - turned out to be much easier than I thought. If you are already using mutt with any authenticated IMAP/SMTP server, you have probably already stumbled onto: msmtp. With a little more work, and you can get this piece of software to work perfectly with Gmail. If you need some help, check out: [vpetkov.net/legacy/documentation/network-services/smtps-and-imaps/mutt-with-google-gmailgoogle-apps-or-any-imap-server/](/legacy/documentation/network-services/smtps-and-imaps/mutt-with-google-gmailgoogle-apps-or-any-imap-server/) The second problem turned out to be relatively easy, after doing some research and a bit of trial and error. The main idea is that you create a simple "relay" server in a way. A lightweight Postfix installation which only auths and forwards/relays all the emails to Gmail/Google Apps/any IMAP server for that matter. I went the extra step and configured it to be able to use different SMTP servers with different auth based on different user/email accounts. You can get all the technically details at the top of this post. Good luck, and I hope this saves you some time.
