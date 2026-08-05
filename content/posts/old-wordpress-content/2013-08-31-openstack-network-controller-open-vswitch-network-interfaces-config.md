---
title: OpenStack – Network Controller – Open vSwitch – Network Interfaces Config
author: Ventz
type: post
date: 2013-08-31T06:25:00+00:00
url: /2013/08/31/openstack-network-controller-open-vswitch-network-interfaces-config/
categories:
  - Uncategorized
tags:
  - documentation
  - hack
  - linux
  - network

---
Setting up the network interfaces is something that seems to give people a hard time (clearly visible here: http://docs.openstack.org/grizzly/basic-install/apt/content/basic-install_network.html). If you follow that guide, one of the most confusing points is how the Open vSwitch fits into the existing architecture.

Assuming you are following the guide, you have 2 networks:  
10.10.10.0/24 -> private  
10.0.0.0/24 -> public

Your Network Controller, again per the guide, will have an internal-network interface of &#8220;10.10.10.9&#8221; and an external-network interface of &#8220;10.0.0.9&#8221;

Your starting network config (/etc/network/interfaces) file will look like this:

`<br />
########################################<br />
# Internal Network<br />
auto eth0<br />
iface eth0 inet static<br />
    address 10.10.10.9<br />
    netmask 255.255.255.0</p>
<p># External Network<br />
auto eth1<br />
iface eth1 inet static<br />
    address 10.0.0.9<br />
    netmask 255.255.255.0<br />
    gateway 10.0.0.1<br />
    dns-nameservers 8.8.8.8<br />
########################################<br />
` 

Now, you will first install the packages needed:

`<br />
# apt-get install quantum-plugin-openvswitch-agent \<br />
quantum-dhcp-agent quantum-l3-agent<br />
` 

Then you will start the Open vSwitch:

`<br />
# service openvswitch-switch start<br />
` 

<!--more-->

At this point, you will create the Open vSwitch bridges and ports:

`<br />
# ovs-vsctl add-br br-ex<br />
# ovs-vsctl add-port br-ex eth1<br />
# ovs-vsctl add-br br-int<br />
` 

and finally, the part that gives everyone the hardest time, the resulting network config (/etc/network/interfaces) file should look like this after you are done:

`<br />
# /etc/network/interfaces<br />
########################################<br />
# Internal Network - PRIV<br />
auto eth0<br />
iface eth0 inet static<br />
address 10.10.10.9<br />
netmask 255.255.255.0</p>
<p>auto eth1<br />
iface eth1 inet manual<br />
up ip address add 0/0 dev $IFACE<br />
up ip link set $IFACE up<br />
down ip link set $IFACE down</p>
<p># Open vSwitch<br />
auto br-ex<br />
iface br-ex inet static<br />
# Need this otherwise 'auto br-ex' hangs during bootup until failsafe kicks in to kill it.<br />
pre-up service openvswitch-switch start<br />
address 10.0.0.9<br />
netmask 255.255.255.0<br />
gateway 10.0.0.1<br />
# Note: if you will use the internet, you will need add DNS:<br />
dns-nameservers 8.8.8.8 8.8.4.4<br />
dns-search local-domain-name<br />
########################################<br />
` 

The last piece is the firewall. Essentially, you are turning your 10.10.10.9 IP (interface) into a gateway for all of the other systems on the 10.10.10.0/24 network (specifically, the compute nodes which are only on that network). They will tunnel though the 10.10.10.9 interface out the br-ex (vSwitch bridge) to your &#8220;public&#8221; (in this case, again, 10.0.0.9 is public) network.

The firewall should look like this:

`<br />
# iptables -A FORWARD -i eth0 -o br-ex -s 10.10.10.0/24 -m conntrack --ctstate NEW -j ACCEPT<br />
# iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT<br />
# iptables -A POSTROUTING -s 10.10.10.0/24 -t nat -j MASQUERADE<br />
` 

and one of the best ways to hook this into Ubuntu so that it auto loads on start up is to run the above to &#8220;create&#8221; the firewall. Then, save the existing rules to a file:

`<br />
iptables-save > /etc/iptables.rules<br />
` 

and then, create a small bash script (iptablesload) that loads it from: /etc/network/if-pre-up.d, which looks like this:

`<br />
#!/bin/sh<br />
iptables-restore < /etc/iptables.rules
exit 0
` 

That's it. You are done!