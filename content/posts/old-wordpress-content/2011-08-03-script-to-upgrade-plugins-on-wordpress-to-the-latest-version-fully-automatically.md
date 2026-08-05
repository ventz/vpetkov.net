---
title: Script to Upgrade Plugins on WordPress to the latest version fully automatically
author: Ventz
type: post
date: 2011-08-03T18:20:41+00:00
url: /2011/08/03/script-to-upgrade-plugins-on-wordpress-to-the-latest-version-fully-automatically/
categories:
  - Uncategorized
tags:
  - automation
  - blog
  - hack
  - linux
  - perl

---
**[updated: Sep 30th, 2018 | New easy and fully automated system for updating plugins &#8211; this is the &#8220;perfect&#8221; solution to this problem]**

**[updated: Feb 11th, 2018 | Updated script to deal with new format, syntax, urls]**

LATEST UPDATE: Please checkout my &#8220;perfect&#8221; WordPress plugin update solution: <a href="http://blog.vpetkov.net/2018/09/30/easy-fully-automated-wordpress-plugin-update-system" rel="noopener" target="_blank">http://blog.vpetkov.net/2018/09/30/easy-fully-automated-wordpress-plugin-update-system</a>

<del datetime="2018-09-30T08:07:34+00:00">Droidzone (Joel Mathew) has created a much more advanced fork of this with many improvements &#8211; check it out: <a href="http://blog.droidzone.in/2013/03/31/automatically-update-all-wordpress-plugins-from-bash/" rel="noopener" target="_blank">http://blog.droidzone.in/2013/03/31/automatically-update-all-wordpress-plugins-from-bash/</a></del> (While I still very much support this, I believe my updated solution from Sept 30th, 2018 is incredibly easier and has a single dependency on &#8220;WWW::Mechanize&#8221;. Leaving the link here to Joel&#8217;s for anyone that is interested in taking a look at his. His original fork + extension supports good visual output and other options that someone may be interested in. I believe the last update was in 2014.)

I already created a script to upgrade wordpress installations automatically. You can find it here: <a href="script-to-upgrade-wordpress-to-the-latest-version-fully-automatically" target="_blank">http://blog.vpetkov.net/2011/06/01/script-to-upgrade-wordpress-to-the-latest-version-fully-automatically</a> Recently, the same general problem came about when it came to plugins. The biggest problem I had is that I had to log-into wordpress, see a number of plugins that were outdated, and then go hunt each one down by generally just copying the name and pasting it into google . Even thought most of the time, the plugin was the first hit, I then had to download the latest version, extract it, and clean it up. Imagine doing this for 10+ plugins for 5+ blogs &#8212; constantly. It was just time consuming and frustrating.

Here is my solution in the form of a perl script:  
<code lang="perl">#!/usr/bin/perl&lt;br />
# By: Ventz Petkov&lt;br />
# Date: 06-15-2011&lt;br />
# Last: 02-11-2018&lt;br />
# Version: 3.5&lt;br />
# Comment on last update:&lt;br />
# * WP changed their plugins html format syntax quite a bit...&lt;br />
# * WP changed their plugins URL a tiny bit, and download URL newline/spacing&lt;br />
# * WP changed their description html a bit&lt;br />
# * WP changed their description again - changed to pulling it from the meta tag&lt;/p>
&lt;p># Usage:&lt;br />
# ./update-wp-plugins.pl&lt;br />
# 	or&lt;br />
# ./update-wp-plugins.pl registered-name-of-plugin&lt;br />
# (and this works to update an exiting plugin or download+install a new one)&lt;br />
chdir("/home/ventz/vpetkov.net/blog/wp-content/plugins");&lt;br />
use WWW::Mechanize;&lt;br />
my $mech = WWW::Mechanize->new();&lt;br />
$mech->agent_alias( 'Mac Safari' );&lt;br />
my $wp_base_url = "https://wordpress.org/plugins";&lt;/p>
&lt;p>################################################&lt;br />
# Add New plugins Here:&lt;br />
# Format:&lt;br />
# 	'registered-name-of-plugin',&lt;br />
#&lt;br />
#my @plugins = (&lt;br />
#	'google-sitemap-generator',&lt;br />
#	'wptouch',&lt;br />
#	'wordpress-tweeter',&lt;br />
#);&lt;br />
################################################&lt;/p>
&lt;p>if(defined($ARGV[0])) {&lt;br />
	my $name = $ARGV[0];&lt;br />
	&update_plugin($name);&lt;br />
}&lt;br />
else {&lt;br />
    exit;&lt;br />
}&lt;br />
#else {&lt;br />
#	for my $name (@plugins) {&lt;br />
#		&update_plugin($name);&lt;br />
#	}&lt;br />
#}&lt;/p>
&lt;p>sub update_plugin {&lt;br />
	my $name = shift;&lt;br />
	my $url = "$wp_base_url/$name";&lt;br />
	$mech->get( $url );&lt;br />
	my $page = $mech->content;&lt;br />
	my ($url,$version,$description,$file) = "";&lt;br />
	if($page =~ /.*&lt;/p>
&lt;div class="plugin-actions">(.*)&lt;\/div>.*/s) {&lt;br />
        my $subpage = $1;&lt;br />
        if($subpage =~ /.*&lt;a class=".*" href="(.*)">Download&lt;\/a>.*/) {&lt;br />
            $url = $1;&lt;br />
            if($url =~ /https:\/\/downloads\.wordpress\.org\/plugin\/(.*)/) {&lt;br />
                $file = $1;&lt;br />
            }&lt;br />
        }&lt;br />
        if($subpage =~ /.*&lt;/p>
&lt;li>Version: &lt;strong>((\d+\.?)+(\d+))&lt;\/strong>&lt;\/li>.*/s) {&lt;br />
            $version = $1;&lt;br />
        }&lt;br />
    }&lt;br />
	if($page =~ /&lt;meta name="description" value="(.*?)" \/>/s) {&lt;br />
        $description = $1;&lt;br />
    }&lt;br />
	print "\nPlugin: $name | Version $version\n";&lt;br />
	print "\nDescription: $description\n\n";&lt;br />
	`/bin/rm -f $file`;&lt;br />
    print "Downloading: \t$url\n"; `/usr/bin/wget -q $url`;&lt;br />
    print "Unzipping: \t$file\n"; `/usr/bin/unzip -o $file`;&lt;br />
    print "Installed: \t$name\n"; `/bin/rm -f $file`;&lt;br />
}&lt;br />
</code>

This script can be used in one of two ways:

1.) You can simply run it, and it will update everything that you have listed in the @plugins array.

2.) You can give it a parameter of a registered plugin name. This does 2 jobs &#8212; upgrades an existing plugin, AND installs new ones.

You can definitely add an extension to this. For #1, you can go a step further by making it scan your plugin directory and populating the list from there. If you want to be even fancier, you can relatively easily keep version tracks of what you have installed and what&#8217;s currently available, so that you don&#8217;t just blindly download new plugins. For me this is sufficient. If anyone is interested in getting help implementing any of these extra additions, feel free to ask and I&#8217;ll help as much as I can.