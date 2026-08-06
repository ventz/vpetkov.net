---
title: Docker Swarm Tutorial and Examples
author: Ventz
type: posts
date: 2015-12-07T05:57:52+00:00
url: /2015/12/07/docker-swarm-tutorial-and-examples/
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
## A bit of background and the "old/normal way"

If you use Docker, you very quickly run into a common question: how do you make Docker work across multiple hosts, datacenters, and different clouds. One of the simplest solutions is Docker Swarm. Docker summarizes it best as "a native clustering for Docker...[which] allows you create and access to a pool of Docker hosts using the full suite of Docker tools."

One of the biggest benefits to using Docker Swarm is that it provides the standard Docker API, which means that all of the existing Docker management tools (and 3rd party products) just work out of the box as they do with a single host. The only difference is that they now scale transparently over multiple hosts.

After reading up on it in the [Docker Swarm overview](https://docs.docker.com/swarm/) and the [Swarm install guide](https://docs.docker.com/swarm/install-w-machine/), it was evident that this is a pretty simple service, but it wasn't 100% clear what went where. After searching around the web, I realized that almost all of the tutorials and examples on Docker Swarm involved either docker-machine or very convoluted examples which did not explain what was happening on which component. With that said, here is a very simple Docker Swarm Tutorial with some practical examples.

Assuming you have a bunch of servers running docker:  
vm01 (10.0.0.101), vm02 (10.0.0.102), vm03 (10.0.0.103), vm04 (10.0.0.104)

<!--more-->

Normally, you can do "docker ps" on each host for example:  
ssh vm01 'docker ps'  
ssh vm04 'docker ps'

If you enable the API for remote bind on each host you can manage them from a central place:  
docker -H tcp://vm01:2375 ps  
docker -H tcp://vm04:2375 ps  
(note: port is optional for default)

But if you want to use all of these docker engines as a cluster, you need Swarm.

## Docker Swarm Tutorial and How-To/Examples

A swarm contains only two components: agents (the workers in the cluster) and manager(s).

First, grab the swarm image on each docker host:  
`docker pull swarm`

Then, make sure the API is enabled for remote bind on each host (NOTE: see bellow if using Systemd OS):  
```
# (on Ubuntu) cat /etc/default/docker:

DOCKER_OPTS="-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock ..."

# And then restart:
/etc/init.d/docker restart

# -- OR --

# IF USING a Systemd OS -- Ubuntu 16.04/CentOS7 and up, use this instead:

# (on Ubuntu) cat /etc/systemd/system/docker.service

[Service]
ExecStart=/usr/bin/docker daemon -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --dns 8.8.8.8 --dns 8.8.4.4

# And then reload/restart
systemctl daemon-reload
systemctl restart docker
```

To get everything started, go to whatever docker host you pick as the manager (in our case vm01), and create the swarm:  
`docker run --rm swarm create`

This will generate an unique token like:  
c05c3ef4c4b15821a8e8e2ef6bdf192d

Now, on \*each\* AGENT (including the manager if you want to use it as a worker) run:  
docker run -d swarm join --advertise agentIP:2375 token://c05c3ef4c4b15821a8e8e2ef6bdf192d

```
docker run -d swarm join --advertise 10.0.0.101:2375 token://c05c3ef4c4b15821a8e8e2ef6bdf192d
docker run -d swarm join --advertise 10.0.0.102:2375 token://c05c3ef4c4b15821a8e8e2ef6bdf192d
docker run -d swarm join --advertise 10.0.0.103:2375 token://c05c3ef4c4b15821a8e8e2ef6bdf192d
docker run -d swarm join --advertise 10.0.0.104:2375 token://c05c3ef4c4b15821a8e8e2ef6bdf192d
```
You would do this for \*each\* agent and in our case vm01 is also an agent)

At last, you need to run a manager service on your chosen manager host (in our case, vm01) to manage the swarm:  
`docker run -d -p 2376:2375 swarm manage token://c05c3ef4c4b15821a8e8e2ef6bdf192d`

The idea is that the manager wants to provide an API on port 2375. We are binding that to the local host on 2376. If your manager is NOT an agent, you can simply bind it on 2375 by doing a "run -d -P swarm manage token://...". In that case, you would NOT run the "swarm join" command on your manager. However, in our case we want all of the hosts to be agents, including the manager.

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