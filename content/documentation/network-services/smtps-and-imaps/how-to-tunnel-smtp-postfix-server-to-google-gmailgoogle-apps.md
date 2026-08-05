---
title: How to Tunnel SMTP (Postfix) server to Google (Gmail/Google Apps)
author: Ventz
#layout: "posts"
layout: "pages"
date: 2011-08-26T07:42:04+00:00
categories:
  - Old-WordPress-Blog
comments: false
---
In /etc/postfix/main.cf:

```
# http://www.postfix.org/SASL_README.html#client_sasl_enable
#####################################################################
relayhost= [smtp.gmail.com]:587
smtp_connection_cache_destinations= [smtp.gmail.com]:587
smtp_use_tls = yes
smtp_tls_security_level=encrypt
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/gmail
smtp_sasl_security_options = noanonymous
smtp_sender_dependent_authentication = yes
sender_dependent_relayhost_maps = hash:/etc/postfix/sender_relay
smtp_generic_maps = hash:/etc/postfix/generic
#smtp_tls_cert_file = /etc/ssl/certs/smtpd.crt
#smtp_tls_key_file = /etc/ssl/private/smtpd.key
# cat /etc/ssl/certs/Equifax_Secure_CA.pem >> /etc/postfix/cacert.pem
smtp_tls_CAfile = /etc/postfix/cacert.pem
soft_bounce = yes
default_destination_concurrency_limit = 1
#####################################################################
```


In the same file – /etc/postfix/main.cf, please comment out:

```
# TLS parameters
#smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
#smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
#smtpd_use_tls=yes
#smtpd_tls_session_cache_database = btree:${data_directory}/smtpd_scache
#smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache
```


In /etc/postfix/gmail:


```
user1@postfix-server-custom-domain.com               user1@google-app-domain.com:user-password
# Login information for the default relayhost.
[smtp.gmail.com]:587               default-user@google-app-domain.com:default-password
```


In /etc/postfix/sender_relay:
```
user1@postfix-server-custom-domain.com  [smtp.gmail.com]:587
```


In /etc/postfix/generic:
```
www-data               noreply@google-app-domain.com
```


Now, the important notes, in /etc/postfix:
```
1.) postmap gmail
2.) postmap sender_relay
3.) postmap generic
4.) /etc/init.d/postfix restart (or ‘reload’ instead of ‘restart’ if you want to keep your server running)
```


Now, let me explain what this whole thing does:

From the config section, you are saying that the default relay host is “smtp.gmail.com”, on port 587, and the “[“, “]” specify that you do not want to do MX/DNS lookups every time. The next part says that you want to use TLS. This is something that google requires/enforces. I will temporarily skip down to the CA file. This is needed in order to verify Google’s CERT. Now, the next part (back up) is to look at the “gmail” map. Normally, if you wanted to default everyone’s email, this would be sufficient, with the section of the “default relay host”. This basically tells the server that anything and everything should be sent to Google (Gmail/Google App), and it lists the default user, domain, and password (where ‘google-app-domain’ is either your own custom domain under Google Apps, or Gmail). Now the extra step that I go through is the “sender_relay”. What that simply does is it acts like a “source” trigger. You list destinations for EACH email user. That simply says that if ‘user1@postfix-server-custom-domain.com’ sends an email, it should really go to the gmail server, and from there that trigger is matched up in the ‘gmail’ file for authentication. This allows you to have a “server” domain, which is actually hosted by Google (or NOT — you can host it ON the postfix server, in terms of where mail lives), and you can make it so that each user when sending email, actually sends as their own external IMAP account. One extra step that I’ve added is the “smtp_generic_maps”. The reason for this is to translate email that comes in from services like Apache (which generates from www-data@). This is not necessary, but it’s useful.

Why do this? If you have not figured out a good scenario for this, here is one:

You host a web-hosting service called ‘abc.com’. Every single user who signs up gets a ‘someusername@abc.com’. Your email is hosted on Gmail/Google Apps. Now the problem is that each user needs to be able to see their email locally (easy with imap — see my other article about mutt+msmtp) and the bigger problem is that each user needs to be able to send email “FROM” their own account, which again, is hosted on Gmail/Google Apps. Now let’s take it a step farther — each user has their own domain.tld, and they want to send email as themselves, when they send from the system. This is where the sender_relay file comes in. It just acts as an intercept filter/trigger, which looks for a certain username@abc.com, hooks it, and translates it into a mail server, and then hooks the user+pass for that email server. The end result is an extremely robust and powerful solution. The whole reason I started even looking at this is because I didn’t want to keep maintaining a full blown Zimbra server only for a 2-3 users, and it wasn’t reliable at home (even with some hacky distributed solutions), and it was not worth the cost to run it as a VM with Amazon. This brought me to Google Apps. The main problem was what I described above, and the second problem was having an “IP auth only”  SMTP server for dumb devices like the EMC Iomega Storage Brick, vCenter, and other things like that. The above solution solves all of these problems in an extremely elegant way.

Concerns?:

Yea — the user/password is stored in plain text. I really need to look for an encryption method. One solution I was thinking of was PGP/GPG-ing the plain text file, and then unlocking it only when I needed to make a change. This way I could decrypt, make a change, postmap it, and then re-encrypt the file. If anyone has a more elegant solution, please contact me. Hope this helped anyone looking for a good solution.
