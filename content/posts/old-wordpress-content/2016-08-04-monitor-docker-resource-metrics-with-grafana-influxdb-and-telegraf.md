---
title: Monitor Docker resource metrics with Grafana, InfluxDB, and Telegraf
author: Ventz
type: posts
date: 2016-08-05T03:17:10+00:00
url: /2016/08/04/monitor-docker-resource-metrics-with-grafana-influxdb-and-telegraf/
categories:
  - Old-WordPress-Blog
tags:
  - old-wordpress-blog
  - cloud
  - data
  - docker
  - documentation
  - network

---
I needed a way to monitor Docker resource usage and metrics (CPU, Memory, Network, Disk). I also wanted historical data, and ideally, pretty graphs that I could navigate and drill into.

Whatever the solution was going to be, it had to be very open and customizable, easy to setup and scale for a production-like environment (stability, size), and ideally cheap/free. But most of all - it had to make sense and really be straight forward.

## 3 Containers and 10 minutes is all you need

To get this:  
[![Grafana dashboard showing Docker CPU, memory, and network metrics](https://media.vpetkov.net/wp-content/uploads/2016/08/docker_metrics01.png)][1]

[![Grafana Docker metrics dashboard thumbnail](https://media.vpetkov.net/wp-content/uploads/2016/08/docker_metrics02.png)][2]  
There are 3 components that are started via containers:

Grafana (dashboard/visual metrics and analytics)  
InfluxDB (time-series DB)  
Telegraf (time-series collector) - 1 per Docker host

The idea is that you first launch Grafana, and then launch InfluxDB. You configure Grafana (via the web) to point to InfluxDB's IP, and then you setup a Telegraf container on each Docker host that you want to monitor. Telegraf collects all the metrics and feeds them into a central InfluxDB, and Grafana displays them.

## Setup Tutorial/Examples

<!--more-->

In our example, we have a bunch of servers running Docker:  
vm01, vm02, vm03 [VM IPs do not matter in this case]

A "data" folder (/data) on each vm for the data mounts.  
And we create an empty folder for each container: "/data/grafana", "/data/influxdb", "/data/telegraf"

A common network overlay or macvlan network (docker 1.12+) - we use the name "someNetworkName"

Static IPs (either via "--ip" directly, or something like pipework)

We will launch Grafana and InfluxDB on vm01, and a Telegraf container on vm01, vm02, and vm03.

Grafana (10.0.0.10)  
InfluxDB (10.0.0.20)  
Telegraf (10.0.0.101 on vm01, 10.0.0.102 on vm02, and 10.0.0.103 on vm03)

## Grafana

Beautiful metric and analytics dashboard. Ideal for visualization and querying of time series data.

This is the first container you will launch on vm01:  
(note: you are mounting the dirs so that you can access/change the configs, and data that is generated. Dirs can be empty)

NOTE: For Grafana, using ALL defaults works. That means you can either specify the "-v" for the /etc/grafana, /var/lib/grafana, and /var/log/grafana - or skip it. It would make sense to specify the logs to have them, and it would make sense to specify the rest if you want to 1.) override something and/or 2.) add plugins. Otherwise, you are fine with defaults. I will provide the "default" config in the comments bellow.

```
docker run --restart=always -d --net=someNetworkName --ip=10.0.0.10 \
	--name grafana \
	--hostname grafana \
	-v /data/grafana/var/lib/grafana:/var/lib/grafana \
	-v /data/grafana/etc/grafana:/etc/grafana \
	-v /data/grafana/var/log/grafana:/var/log/grafana \
	-p 3000:3000 \
	-e "GF_SERVER_ROOT_URL=http://10.0.0.10"  \
	-e "GF_SECURITY_ADMIN_PASSWORD=somepasswordhere"  \
	grafana/grafana
```

## InfluxDB

Time-series data storage. A database designed for time-series data. Very easy to use, and feeds data into Grafana. It can accept data from many tools, specifically collectors like Telegraf.

First generate a config file:  
```
docker run --rm influxdb influxd config > /data/influxdb/influxdb.conf
```

Then run the container as your second container on vm01:  
```
docker run --restart=always -d --net=someNetworkName --ip=10.0.0.20 \
	--name=influxdb \
	--hostname=influxdb \
	-p 8083:8083 -p 8086:8086 \
	-v /data/influxdb:/var/lib/influxdb \
	-v /data/influxdb/influxdb.conf:/etc/influxdb/influxdb.conf:ro \
	influxdb -config /etc/influxdb/influxdb.conf
```

## Telegraf

Time-series data collection. This uses a config to know what data to collect and where to feed it.

First generate a config file:  
```
docker run --rm telegraf -sample-config > /data/telegraf/telegraf.conf
```

Edit the config and just enable the Docker portion (uncomment the "[[inputs.docker]]" section until the timeout)

The only other config line you need is this:  
```
[[outputs.influxdb]]
  #urls = ["http://IP-or-NAME-of-INFLUXDB:8086"] # required
  urls = ["http://10.10.10.20:8086"] # required
  database = "telegraf" # required
```

Then run the container as your third container on vm01 (and later on vm02, and vm03, with changes bellow code):  
```
docker run -d --restart=always --net=admin01 --ip=10.0.0.101 \
	--add-host="influxdb:10.0.0.20"\
	--name=stats-s01 \
	--hostname=vm01 \
	-e "HOST_PROC=/rootfs/proc" \
	-e "HOST_SYS=/rootfs/sys" \
	-e "HOST_ETC=/rootfs/etc" \
	-v /data/telegraf/telegraf.conf:/etc/telegraf/telegraf.conf:ro \
	-v /var/run/docker.sock:/var/run/docker.sock:ro \
	-v /sys:/rootfs/sys:ro -v /proc:/rootfs/proc:ro \
	-v /etc:/rootfs/etc:ro telegraf
```

NOTE: You will launch the almost the same thing on vm02 and vm03, but you would change the --hostname (vm02, and vm03) and --ip (10.0.0.102, and 10.0.0.103)

## Last Step - Connect via Web and Start Using

Log into http://10.0.0.10:3000 (admin, and password from docker "GF\_SECURITY\_ADMIN_PASSWORD"), and go to:  
1.) The top left Menu (icon of Spiral)  
2.) Data Sources  
3.) + Add data source  
4.) Fill out:  
a.) Name: InfluxDB  
b.) Type: InfluxDB  
c.) (HTTP Settings) Url: http://10.0.0.20:8086  
d.) (InfluxDB Settings) Database: telegraf  
5.) Click "Save & Test" - it will save and work (ignore the "Please fill out this field - this is for production environments - setting up DB users, and eventually SSL)

It should look like this:

[![Grafana data source configuration screen for InfluxDB](https://media.vpetkov.net/wp-content/uploads/2016/08/grafana_data_source.png)][3]

## That's it! You are Done!

Now you can go to the top left menu -> Add a new Dashboard -> Add a panel, and start adding Graph (or other) data.  
For Graph for example, under the Metrics tab, you can access all of the variables in a point and click method.

Here's a example to add a new graph on a new Row (after you create a Panel):  
[![Grafana panel menu showing the Add Graph option](https://media.vpetkov.net/wp-content/uploads/2016/08/add_graph.png)][4]

And here's an example of how you would modify the "search" by point and click:  
[![Grafana graph configuration with the metrics query builder](https://media.vpetkov.net/wp-content/uploads/2016/08/grafana_configure.png)][5]

## How I came to this solution (skip if you are not interested)

After some research, I realized just how bad of a state the currently available solutions and tutorials/example/documentation were. They were either too simple and not useful (CAdvisor), not fully implemented (Stats, Scout), extremely complicated in design and difficult to setup or lacking documentation (Sensu, Prometheus, etc.), or just expensive (DataDog, SysDigCloud).

And the tutorials on docker and metrics were basically non existent. Rancher's guide is the most "current and complete" doc on this as of today, in terms of what's available, and you can find it [HERE](http://rancher.com/comparing-monitoring-options-for-docker-deployments/).

 [1]: https://media.vpetkov.net/wp-content/uploads/2016/08/docker_metrics01.png
 [2]: https://media.vpetkov.net/wp-content/uploads/2016/08/docker_metrics02.png
 [3]: https://media.vpetkov.net/wp-content/uploads/2016/08/grafana_data_source.png
 [4]: https://media.vpetkov.net/wp-content/uploads/2016/08/add_graph.png
 [5]: https://media.vpetkov.net/wp-content/uploads/2016/08/grafana_configure.png