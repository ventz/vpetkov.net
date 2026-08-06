---
title: OpenStack - Network Controller - Open vSwitch - Network Interfaces Config
author: Ventz
type: posts
date: 2013-08-31T06:25:00+00:00
url: /2013/08/31/openstack-network-controller-open-vswitch-network-interfaces-config/
categories:
  - Old-WordPress-Blog
tags:
  - old-wordpress-blog
  - documentation
  - hack
  - linux
  - network

---
Setting up the network interfaces is something that seems to give people a hard time (clearly visible here: http://docs.openstack.org/grizzly/basic-install/apt/content/basic-install_network.html). If you follow that guide, one of the most confusing points is how the Open vSwitch fits into the existing architecture.

Assuming you are following the guide, you have 2 networks:  
10.10.10.0/24 -> private  
10.0.0.0/24 -> public

Your Network Controller, again per the guide, will have an internal-network interface of "10.10.10.9" and an external-network interface of "10.0.0.9"

Your starting network config (/etc/network/interfaces) file will look like this:

```
########################################
# Internal Network
auto eth0
iface eth0 inet static
    address 10.10.10.9
    netmask 255.255.255.0

# External Network
auto eth1
iface eth1 inet static
    address 10.0.0.9
    netmask 255.255.255.0
    gateway 10.0.0.1
    dns-nameservers 8.8.8.8
########################################
```

Now, you will first install the packages needed:

```
# apt-get install quantum-plugin-openvswitch-agent \
quantum-dhcp-agent quantum-l3-agent
```

Then you will start the Open vSwitch:

```
# service openvswitch-switch start
```

<!--more-->

At this point, you will create the Open vSwitch bridges and ports:

```
# ovs-vsctl add-br br-ex
# ovs-vsctl add-port br-ex eth1
# ovs-vsctl add-br br-int
```

and finally, the part that gives everyone the hardest time, the resulting network config (/etc/network/interfaces) file should look like this after you are done:

```
# /etc/network/interfaces
########################################
# Internal Network - PRIV
auto eth0
iface eth0 inet static
address 10.10.10.9
netmask 255.255.255.0

auto eth1
iface eth1 inet manual
up ip address add 0/0 dev $IFACE
up ip link set $IFACE up
down ip link set $IFACE down

# Open vSwitch
auto br-ex
iface br-ex inet static
# Need this otherwise 'auto br-ex' hangs during bootup until failsafe kicks in to kill it.
pre-up service openvswitch-switch start
address 10.0.0.9
netmask 255.255.255.0
gateway 10.0.0.1
# Note: if you will use the internet, you will need add DNS:
dns-nameservers 8.8.8.8 8.8.4.4
dns-search local-domain-name
########################################
```

The last piece is the firewall. Essentially, you are turning your 10.10.10.9 IP (interface) into a gateway for all of the other systems on the 10.10.10.0/24 network (specifically, the compute nodes which are only on that network). They will tunnel though the 10.10.10.9 interface out the br-ex (vSwitch bridge) to your "public" (in this case, again, 10.0.0.9 is public) network.

The firewall should look like this:

```
# iptables -A FORWARD -i eth0 -o br-ex -s 10.10.10.0/24 -m conntrack --ctstate NEW -j ACCEPT
# iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# iptables -A POSTROUTING -s 10.10.10.0/24 -t nat -j MASQUERADE
```

and one of the best ways to hook this into Ubuntu so that it auto loads on start up is to run the above to "create" the firewall. Then, save the existing rules to a file:

```
iptables-save > /etc/iptables.rules
```

and then, create a small bash script (iptablesload) that loads it from: /etc/network/if-pre-up.d, which looks like this:

```
#!/bin/sh
iptables-restore < /etc/iptables.rules
exit 0
```

That's it. You are done!