---
title: Script to Upgrade WordPress to the latest version fully automatically
author: Ventz
type: posts
date: 2011-06-01T15:28:37+00:00
url: /2011/06/01/script-to-upgrade-wordpress-to-the-latest-version-fully-automatically/
categories:
  - Old-WordPress-Blog
tags:
  - old-wordpress-blog
  - automation
  - blog
  - hack
  - linux
  - perl

---
**[updated: Sep 30th, 2018 | Cleaned up script, and references "perfect" plugin update system]**

NOTE: Please checkout my "perfect" WordPress plugin update solution: <http://blog.vpetkov.net/2018/09/30/easy-fully-automated-wordpress-plugin-update-system>

When you host your own WordPress installation, and there is some sort of an update about every month or so, it can quickly get very annoying doing all the upgrade steps manually (for the people who do not have a CPANEL or FTP account). Now imagine hosting 5-6 WordPress installations. Now imagine 100+. Welcome to my nightmare. Eventually I caved in and wrote this:

```bash
# http://codex.wordpress.org/Updating_WordPress#Step_1:_Replace_WordPress_files
# This strictly follow the directions mentioned above.
# Utilizes: "rm", "cp", "mv", "wget", "unzip"

umask 0022
FQDN=your-url-without-http.com
WEBROOT=/var/www/domain
CURRENT_BLOG=$WEBROOT/blog
TEMP_NEW=$WEBROOT/wordpress

cd $WEBROOT
/bin/rm -Rf latest.zip
/usr/bin/wget http://wordpress.org/latest.zip
/usr/bin/unzip -q latest.zip

# Remove outdated CURRENT_BLOG files per instructions
cd $CURRENT_BLOG
/bin/rm -Rf wp-includes wp-admin

# Copy TEMP_NEW files per instructions
cd $TEMP_NEW
/bin/cp -Rf wp-includes $CURRENT_BLOG/.
/bin/cp -Rf wp-admin $CURRENT_BLOG/.

cd wp-content
/bin/cp -Rf * $CURRENT_BLOG/wp-content/.
cd ..
/bin/mv *.php $CURRENT_BLOG/.
/bin/mv readme.html $CURRENT_BLOG/.
/bin/mv license.txt $CURRENT_BLOG/.

# Cleanup TEMP_NEW - remove extraction and download.
cd $WEBROOT
/bin/rm -Rf wordpress latest.zip

# CUSTOM
echo "go to: http://$FQDN/wp-admin/upgrade.php"
```

So, to summarize, this will download the latest version of wordpress, unzip it, and move the new files accordingly.  
At the end, it will remind you to "upgrade" your DB, just in case there is an upgrade. I highly suggest backing up your primary blog before you begin this, just because it's the "safe thing" to do.  
That said, in the 10+ years I've used this (started long before I posted something here) - I've never had anything go wrong!