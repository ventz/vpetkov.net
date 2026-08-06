---
title: Docker Swarm Tutorial with Consul (Service Discovery) and Examples
author: Ventz
type: posts
date: 2016-06-07T18:59:43+00:00
url: /2016/06/07/docker-swarm-tutorial-with-consul-service-discovery-and-examples/
categories:
  - Old-WordPress-Blog
tags:
  - old-wordpress-blog
  - automation
  - cloud
  - docker
  - linux
  - network

---
If you have not used Swarm, skim the non-service-discovery tutorial to get a feel for how it works:  
[vpetkov.net/2015/12/07/docker-swarm-tutorial-and-examples](/2015/12/07/docker-swarm-tutorial-and-examples). It's very easy, and it should give you an idea of how it works within a couple of minutes.

Using Swarm with pre-generated static tokens is useful, but there are many benefits to using a service discovery backend. For example, you can utilize network overlays and have common "bridges" that span multiple hosts (<https://docs.docker.com/engine/userguide/networking/get-started-overlay/>). It also provides service registration and discovery for the Docker containers launched into the Swarm. Now lets get into how to use it with service discovery - which is what you would use in a scaled out environment/production.

Again, assuming you have a bunch of servers running docker:  
vm01 (10.0.0.101), vm02 (10.0.0.102), vm03 (10.0.0.103), vm04 (10.0.0.104)

Normally, you can do "docker ps" on each host for example:  
ssh vm01 'docker ps'  
ssh vm04 'docker ps'

If you enable the API for remote bind on each host you can manage them from a central place:  
docker -H tcp://vm01:2375 ps  
docker -H tcp://vm04:2375 ps  
(note: port is optional for default)

But if you want to use all of these docker engines as a cluster, you need Swarm.  
Here we will go one step further and use a common service discovery backend (Consul).

## Docker Swarm Tutorial with Consul and How-To/Examples

<!--more-->

A swarm contains only two components: agents (the workers in the cluster) and manager(s).  
We are also going to add consul (the service discovery backend).

First, grab the swarm and the consul images on each docker host:  
```
docker pull swarm
docker pull progrium/consul
```

Then, make sure the API is enabled for remote bind on each host (NOTE: see bellow if using Systemd OS):  
```
# (on Ubuntu) cat /etc/default/docker:

DOCKER_OPTS="-H tcp://0.0.0.0:2375 \
--cluster-store=consul://consulServer:8500 \
--cluster-advertise=managerIp:2376 \
-H unix:///var/run/docker.sock --dns 8.8.8.8 --dns 8.8.4.4 ..."

# And then restart:
/etc/init.d/docker restart

# -- OR --

# IF USING a Systemd OS -- Ubuntu 16.04/CentOS7 and up, use this instead:

# (on Ubuntu) cat /etc/systemd/system/docker.service

[Service]
ExecStart=/usr/bin/docker daemon -H tcp://0.0.0.0:2375 \
--cluster-store=consul://consulIp:8500 \
--cluster-advertise=managerIp:2376 \
-H unix:///var/run/docker.sock --dns 8.8.8.8 --dns 8.8.4.4

# And then reload/restart
systemctl daemon-reload
systemctl restart docker
```

Don't panic here! It looks complicated, but it's actually incredibly easy.

The **consulIp** in "_--cluster-store=consul://consulIp:8500_" is the docker host that will run the consul service (much like the swarm manager). Since you will map the port to the docker host itself, that's simply the IP of the docker host (in our case - vm01)

The **managerIp** in "_--cluster-advertise=managerIp:2376_" is the docker host that will run the swarm manager service. Since you will map the port to the docker host itself, that's simply the IP of the docker host (in our case - vm01). 

To get everything started, go to whatever docker host you pick as the manager (in our case vm01), and create the consul server:  
`docker run -d -p "8500:8500" -h "consul" progrium/consul -server -bootstrap`

Now, on \*each\* AGENT (including the manager if you want to use it as a worker) run:  
docker run -d swarm join --addr 107.170.73.43:2375 consul://consulIp/swarm:8500/swarm

```
docker run -d swarm join --advertise 10.0.0.101:2375 consul://10.0.0.101:8500/swarm
docker run -d swarm join --advertise 10.0.0.102:2375 consul://10.0.0.101:8500/swarm
docker run -d swarm join --advertise 10.0.0.103:2375 consul://10.0.0.101:8500/swarm
docker run -d swarm join --advertise 10.0.0.104:2375 consul://10.0.0.101:8500/swarm
```
You would do this for \*each\* agent and in our case vm01 is also an agent.

At last, you need to run a manager service on your chosen manager host (in our case, vm01) to manage the swarm:  
docker run -d -p 2376:2375 swarm manage consul://consulIp:8500/swarm  
`docker run -d -p 2376:2375 swarm manage consul://10.0.0.101:8500/swarm`

The idea is that the manager wants to provide an API on port 2375. We are binding that to the local host on 2376. If your manager is NOT an agent, you can simply bind it on 2375 by doing a "run -d -P swarm manage consul://...". In that case, you would NOT run the "swarm join" command on your manager. However, in our case we want all of the hosts to be agents, including the manager.

The last step is to query the cluster:  
docker -H tcp://managerIP:2376 info

In our case, we use vm01:  
```
docker -H tcp://vm01:2376 info
or
docker -H tcp://vm01:2376 ps
```

Again, if your manager is NOT an agent, you would simply run:  
"docker -H tcp://managerIP:2375 info" or even "docker -H tcp://managerip"

Don't forget to start the manager on reboot, and each join on the agents on reboot.