---
title: OpenStack – Quantum – Open vSwitch – datapath for tunnels or patch ports
author: Ventz
type: post
date: 2013-08-31T05:37:09+00:00
url: /2013/08/31/openstack-quantum-open-vswitch-datapath-for-tunnels-or-patch-ports/
categories:
  - Uncategorized
tags:
  - cloud
  - documentation
  - hack
  - linux

---
Recently, while setting up my the network controller for OpenStack, I saw this message:

> \# tail -f /var/log/quantum/openvswitch-agent.log
> 
> ERROR [quantum.plugins.openvswitch.agent.ovs\_quantum\_agent] Failed to create OVS patch port. Cannot have tunneling enabled on this agent, since this version of OVS does not support tunnels or patch ports. Agent terminated! 

What this means is that the versio of the datapath (shipped by Ubuntu) does not have the support needed to create tunnels or patch ports. This happened on Ubuntu 13.04.

Fortunately, it is VERY easy to solve this. You need to simply build your own datapath for your kernel. For this, you OpenvSwitch&#8217;s datapath source, and you need module-assistant:

`apt-get install -y openvswitch-datapath-source module-assistant`

You can then grab your kernel headers and any other dependencies:

`module-assistant prepare`

I noticed that either the kernel headers do not have the version.h in the right place, or the module-assistant looks in the wrong place. You can solve this by doing:

``cd /lib/modules/`uname -r`/build/include/linux<br />
ln -s ../generated/uapi/linux/version.h .``

And finally, to download, build, and install the modulle:

`module-assistant auto-install openvswitch-datapath`

Now, reboot your system so that the new module is loaded, and you are ready to go. You will notice that &#8220;/var/log/quantum/openvswitch-agent.log&#8221; no longer has this issue.