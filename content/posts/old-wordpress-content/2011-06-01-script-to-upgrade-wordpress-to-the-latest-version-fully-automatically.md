---
title: Script to Upgrade WordPress to the latest version fully automatically
author: Ventz
type: post
date: 2011-06-01T15:28:37+00:00
url: /2011/06/01/script-to-upgrade-wordpress-to-the-latest-version-fully-automatically/
categories:
  - Uncategorized
tags:
  - automation
  - blog
  - hack
  - linux
  - perl

---
**[updated: Sep 30th, 2018 | Cleaned up script, and references &#8220;perfect&#8221; plugin update system]**

NOTE: Please checkout my &#8220;perfect&#8221; WordPress plugin update solution: <a href="http://blog.vpetkov.net/2018/09/30/easy-fully-automated-wordpress-plugin-update-system" rel="noopener" target="_blank">http://blog.vpetkov.net/2018/09/30/easy-fully-automated-wordpress-plugin-update-system</a>

When you host your own WordPress installation, and there is some sort of an update about every month or so, it can quickly get very annoying doing all the upgrade steps manually (for the people who do not have a CPANEL or FTP account). Now imagine hosting 5-6 WordPress installations. Now imagine 100+. Welcome to my nightmare. Eventually I caved in and wrote this:

<code lang="bash"># http://codex.wordpress.org/Updating_WordPress#Step_1:_Replace_WordPress_files&lt;br />
# This strictly follow the directions mentioned above.&lt;br />
# Utilizes: "rm", "cp", "mv", "wget", "unzip"&lt;/p>
&lt;p>umask 0022&lt;br />
FQDN=your-url-without-http.com&lt;br />
WEBROOT=/var/www/domain&lt;br />
CURRENT_BLOG=$WEBROOT/blog&lt;br />
TEMP_NEW=$WEBROOT/wordpress&lt;/p>
&lt;p>cd $WEBROOT&lt;br />
/bin/rm -Rf latest.zip&lt;br />
/usr/bin/wget http://wordpress.org/latest.zip&lt;br />
/usr/bin/unzip -q latest.zip&lt;/p>
&lt;p># Remove outdated CURRENT_BLOG files per instructions&lt;br />
cd $CURRENT_BLOG&lt;br />
/bin/rm -Rf wp-includes wp-admin&lt;/p>
&lt;p># Copy TEMP_NEW files per instructions&lt;br />
cd $TEMP_NEW&lt;br />
/bin/cp -Rf wp-includes $CURRENT_BLOG/.&lt;br />
/bin/cp -Rf wp-admin $CURRENT_BLOG/.&lt;/p>
&lt;p>cd wp-content&lt;br />
/bin/cp -Rf * $CURRENT_BLOG/wp-content/.&lt;br />
cd ..&lt;br />
/bin/mv *.php $CURRENT_BLOG/.&lt;br />
/bin/mv readme.html $CURRENT_BLOG/.&lt;br />
/bin/mv license.txt $CURRENT_BLOG/.&lt;/p>
&lt;p># Cleanup TEMP_NEW - remove extraction and download.&lt;br />
cd $WEBROOT&lt;br />
/bin/rm -Rf wordpress latest.zip&lt;/p>
&lt;p># CUSTOM&lt;br />
echo "go to: http://$FQDN/wp-admin/upgrade.php"</code>

So, to summarize, this will download the latest version of wordpress, unzip it, and move the new files accordingly.  
At the end, it will remind you to &#8220;upgrade&#8221; your DB, just in case there is an upgrade. I highly suggest backing up your primary blog before you begin this, just because it&#8217;s the &#8220;safe thing&#8221; to do.  
That said, in the 10+ years I&#8217;ve used this (started long before I posted something here) &#8211; I&#8217;ve never had anything go wrong!