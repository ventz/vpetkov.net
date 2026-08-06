---
title: "Mutt with Google (Gmail/Google Apps) or any IMAP server"
author: Ventz
date: 2010-11-15T16:38:33+00:00
layout: "pages"
comments: false
disableShare: true
aliases: ["/documentation/network-services/smtps-and-imaps/mutt-with-google-gmailgoogle-apps-or-any-imap-server/"]
---
The key part is using a piece of software called: msmtp (sendmail replacement). It's a very light weight sendmail-like client, which lets you do Authenticated SMTP.

> account default
> 
> from user@domain.tld
> 
> host smtp.gmail.com
> 
> port 587
> 
> auth on
> 
> user user@domain.tld
> 
> password your-password-here
> 
> tls on
> 
> tls_starttls on
> 
> tls_nocertcheck
> 
> #logfile ~/.msmtp.log
> 
> syslog on

Yes - you can already see the issue here - your password is in plain text. Sadly, this is a requirement. You can chmod the file, but if you share the system with "root" users, there is no way of getting around this - at least I have not seen anything about storing the password encrypted. You will notice, Postfix with SASL passwords for IMAP relay auth suffers from the same problem.
