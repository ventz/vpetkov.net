---
title: Easy fully automated WordPress plugin update system
author: Ventz
type: post
date: 2018-09-30T08:07:05+00:00
url: /2018/09/30/easy-fully-automated-wordpress-plugin-update-system/
categories:
  - Uncategorized
tags:
  - automation
  - blog
  - hack
  - linux
  - perl

---
A long time ago I became frustrated with having to update my WordPress plugins manually, so I created a Perl script and a blog post (<a href="https://blog.vpetkov.net/2011/08/03/script-to-upgrade-plugins-on-wordpress-to-the-latest-version-fully-automatically/" rel="noopener" target="_blank">https://blog.vpetkov.net/2011/08/03/script-to-upgrade-plugins-on-wordpress-to-the-latest-version-fully-automatically/</a>) that explained how to automate this. The idea was quite simple: feed a plugin name, have the script check the WordPress plugins page for the latest versioned download, grab it, and extract it over the specified blog plugins directory and thus update the plugin.

The script was simple and it worked very well. It made dealing with plugins many times easier. However, there was one big down side as some users pointed out &#8212; it did not actually check if a plugin needed to be updated. It blindly replaced the current plugin with the latest version. This meant that there was no way to &#8220;efficiently&#8221; automate it. If you cron-ed it directly, it would simply pull and update all your plugins at whatever period you specified. For the longest time this really irritated me, but I didn&#8217;t have time to dig through WordPress to understand how the engined checked and signaled for local plugins. One particular user (<a href="http://blog.droidzone.in/2013/03/31/automatically-update-all-wordpress-plugins-from-bash/" rel="noopener" target="_blank">Joel</a>) forked a copy and made many improvements to deal with this specific issue.

As time went on, I decided to look at this problem again. A couple of years ago I solved it in a really elegant way, but I didn&#8217;t have time to update the blog post. A few days ago, after looking at the blog statistics, I realized that the WordPress article was one of the top 10 most popular ones. So, with that said, here is:

## A new simple and elegant solution

The idea is to use the WordPress CLI in order to &#8220;query&#8221; the local plugins database for plugin names, version number, and &#8220;activated&#8221; status, and then compare the &#8220;local&#8221; plugin version with the &#8220;remote&#8221; plugin version. If the plugin is active and in need of an update, fall back to my original Perl script to update it. Aha! And now we have something that can be cron-ed 🙂

To get started, first grab the WP CLI utility. We are going to rename it, move it to an accessible place, and take care of permissions so that we can use it:

<code lang="bash">&lt;br />
curl -O  https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar&lt;br />
sudo mv wp-cli.phar /usr/local/bin/wp && chmod +x /usr/local/bin/wp&lt;br />
</code>

<!--more-->

Now, grab the Perl script (<a href="https://blog.vpetkov.net/2011/08/03/script-to-upgrade-plugins-on-wordpress-to-the-latest-version-fully-automatically/" rel="noopener" target="_blank">https://blog.vpetkov.net/2011/08/03/script-to-upgrade-plugins-on-wordpress-to-the-latest-version-fully-automatically/</a>) and save it as:  
<code lang="bash">&lt;br />
/usr/local/bin/update-wp-plugins.pl&lt;br />
</code>

Finally, you can simply run:

<code lang="bash">&lt;br />
# create a file: /usr/local/bin/check-wp-plugins.sh&lt;/p>
&lt;p>/usr/local/bin/wp plugin list --format=csv \&lt;br />
--status=active --update=available \&lt;br />
--path=/var/www/wordpress-blog \&lt;br />
--fields=name \&lt;br />
| egrep -v '^name$' | xargs -L1 /usr/local/bin/update-wp-plugins.pl&lt;br />
</code>

This will check the plugins for activate ones that have an update available (local version doesn&#8217;t match remote) and extract them + feed them to my perl script to have them update.

If you save the final script as let&#8217;s say &#8220;check-wp-plugins.sh&#8221; in /usr/local/bin, you can simply run a cron job with:

<code lang="bash">&lt;br />
0 0 * * 0 /usr/local/bin/check-wp-plugins.sh&lt;br />
</code>

You have to admit &#8212; this is just beautiful!