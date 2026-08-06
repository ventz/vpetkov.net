---
title: Script to Upgrade Plugins on WordPress to the latest version fully automatically
author: Ventz
type: posts
date: 2011-08-03T18:20:41+00:00
url: /2011/08/03/script-to-upgrade-plugins-on-wordpress-to-the-latest-version-fully-automatically/
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
**[updated: Sep 30th, 2018 | New easy and fully automated system for updating plugins - this is the "perfect" solution to this problem]**

**[updated: Feb 11th, 2018 | Updated script to deal with new format, syntax, urls]**

LATEST UPDATE: Please checkout my "perfect" WordPress plugin update solution: <http://blog.vpetkov.net/2018/09/30/easy-fully-automated-wordpress-plugin-update-system>

~~Droidzone (Joel Mathew) has created a much more advanced fork of this with many improvements - check it out: <http://blog.droidzone.in/2013/03/31/automatically-update-all-wordpress-plugins-from-bash/>~~ (While I still very much support this, I believe my updated solution from Sept 30th, 2018 is incredibly easier and has a single dependency on "WWW::Mechanize". Leaving the link here to Joel's for anyone that is interested in taking a look at his. His original fork + extension supports good visual output and other options that someone may be interested in. I believe the last update was in 2014.)

I already created a script to upgrade wordpress installations automatically. You can find it here: [http://blog.vpetkov.net/2011/06/01/script-to-upgrade-wordpress-to-the-latest-version-fully-automatically](script-to-upgrade-wordpress-to-the-latest-version-fully-automatically) Recently, the same general problem came about when it came to plugins. The biggest problem I had is that I had to log-into wordpress, see a number of plugins that were outdated, and then go hunt each one down by generally just copying the name and pasting it into google . Even thought most of the time, the plugin was the first hit, I then had to download the latest version, extract it, and clean it up. Imagine doing this for 10+ plugins for 5+ blogs - constantly. It was just time consuming and frustrating.

Here is my solution in the form of a perl script:  
```perl
#!/usr/bin/perl
# By: Ventz Petkov
# Date: 06-15-2011
# Last: 02-11-2018
# Version: 3.5
# Comment on last update:
# * WP changed their plugins html format syntax quite a bit...
# * WP changed their plugins URL a tiny bit, and download URL newline/spacing
# * WP changed their description html a bit
# * WP changed their description again - changed to pulling it from the meta tag

# Usage:
# ./update-wp-plugins.pl
# 	or
# ./update-wp-plugins.pl registered-name-of-plugin
# (and this works to update an exiting plugin or download+install a new one)
chdir("/home/ventz/vpetkov.net/blog/wp-content/plugins");
use WWW::Mechanize;
my $mech = WWW::Mechanize->new();
$mech->agent_alias( 'Mac Safari' );
my $wp_base_url = "https://wordpress.org/plugins";

################################################
# Add New plugins Here:
# Format:
# 	'registered-name-of-plugin',
#
#my @plugins = (
#	'google-sitemap-generator',
#	'wptouch',
#	'wordpress-tweeter',
#);
################################################

if(defined($ARGV[0])) {
	my $name = $ARGV[0];
	&update_plugin($name);
}
else {
    exit;
}
#else {
#	for my $name (@plugins) {
#		&update_plugin($name);
#	}
#}

sub update_plugin {
	my $name = shift;
	my $url = "$wp_base_url/$name";
	$mech->get( $url );
	my $page = $mech->content;
	my ($url,$version,$description,$file) = "";
	if($page =~ /.*

<div class="plugin-actions">(.*)<\/div>.*/s) {
        my $subpage = $1;
        if($subpage =~ /.*<a class=".*" href="(.*)">Download<\/a>.*/) {
            $url = $1;
            if($url =~ /https:\/\/downloads\.wordpress\.org\/plugin\/(.*)/) {
                $file = $1;
            }
        }
        if($subpage =~ /.*

<li>Version: <strong>((\d+\.?)+(\d+))<\/strong><\/li>.*/s) {
            $version = $1;
        }
    }
	if($page =~ /<meta name="description" value="(.*?)" \/>/s) {
        $description = $1;
    }
	print "\nPlugin: $name | Version $version\n";
	print "\nDescription: $description\n\n";
	`/bin/rm -f $file`;
    print "Downloading: \t$url\n"; `/usr/bin/wget -q $url`;
    print "Unzipping: \t$file\n"; `/usr/bin/unzip -o $file`;
    print "Installed: \t$name\n"; `/bin/rm -f $file`;
}
```

This script can be used in one of two ways:

1.) You can simply run it, and it will update everything that you have listed in the @plugins array.

2.) You can give it a parameter of a registered plugin name. This does 2 jobs - upgrades an existing plugin, AND installs new ones.

You can definitely add an extension to this. For #1, you can go a step further by making it scan your plugin directory and populating the list from there. If you want to be even fancier, you can relatively easily keep version tracks of what you have installed and what's currently available, so that you don't just blindly download new plugins. For me this is sufficient. If anyone is interested in getting help implementing any of these extra additions, feel free to ask and I'll help as much as I can.