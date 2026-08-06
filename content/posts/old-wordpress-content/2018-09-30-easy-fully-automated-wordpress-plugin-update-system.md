---
title: Easy fully automated WordPress plugin update system
author: Ventz
type: posts
date: 2018-09-30T08:07:05+00:00
url: /2018/09/30/easy-fully-automated-wordpress-plugin-update-system/
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
A long time ago I became frustrated with having to update my WordPress plugins manually, so I created a Perl script and a blog post ([vpetkov.net/2011/08/03/script-to-upgrade-plugins-on-wordpress-to-the-latest-version-fully-automatically/](/2011/08/03/script-to-upgrade-plugins-on-wordpress-to-the-latest-version-fully-automatically/)) that explained how to automate this. The idea was quite simple: feed a plugin name, have the script check the WordPress plugins page for the latest versioned download, grab it, and extract it over the specified blog plugins directory and thus update the plugin.

The script was simple and it worked very well. It made dealing with plugins many times easier. However, there was one big down side as some users pointed out - it did not actually check if a plugin needed to be updated. It blindly replaced the current plugin with the latest version. This meant that there was no way to "efficiently" automate it. If you cron-ed it directly, it would simply pull and update all your plugins at whatever period you specified. For the longest time this really irritated me, but I didn't have time to dig through WordPress to understand how the engined checked and signaled for local plugins. One particular user ([Joel](http://blog.droidzone.in/2013/03/31/automatically-update-all-wordpress-plugins-from-bash/)) forked a copy and made many improvements to deal with this specific issue.

As time went on, I decided to look at this problem again. A couple of years ago I solved it in a really elegant way, but I didn't have time to update the blog post. A few days ago, after looking at the blog statistics, I realized that the WordPress article was one of the top 10 most popular ones. So, with that said, here is:

## A new simple and elegant solution

The idea is to use the WordPress CLI in order to "query" the local plugins database for plugin names, version number, and "activated" status, and then compare the "local" plugin version with the "remote" plugin version. If the plugin is active and in need of an update, fall back to my original Perl script to update it. Aha! And now we have something that can be cron-ed 🙂

To get started, first grab the WP CLI utility. We are going to rename it, move it to an accessible place, and take care of permissions so that we can use it:

```bash
curl -O  https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp && chmod +x /usr/local/bin/wp
```

<!--more-->

Now, grab the Perl script ([vpetkov.net/2011/08/03/script-to-upgrade-plugins-on-wordpress-to-the-latest-version-fully-automatically/](/2011/08/03/script-to-upgrade-plugins-on-wordpress-to-the-latest-version-fully-automatically/)) and save it as:  
```bash
/usr/local/bin/update-wp-plugins.pl
```

Finally, you can simply run:

```bash
# create a file: /usr/local/bin/check-wp-plugins.sh

/usr/local/bin/wp plugin list --format=csv \
--status=active --update=available \
--path=/var/www/wordpress-blog \
--fields=name \
| egrep -v '^name$' | xargs -L1 /usr/local/bin/update-wp-plugins.pl
```

This will check the plugins for activate ones that have an update available (local version doesn't match remote) and extract them + feed them to my perl script to have them update.

If you save the final script as let's say "check-wp-plugins.sh" in /usr/local/bin, you can simply run a cron job with:

```bash
0 0 * * 0 /usr/local/bin/check-wp-plugins.sh
```

You have to admit - this is just beautiful!