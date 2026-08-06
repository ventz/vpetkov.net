---
title: Monitor Docker resource metrics with Grafana, InfluxDB, and Telegraf
author: Ventz
type: post
date: 2016-08-05T03:17:10+00:00
url: /2016/08/04/monitor-docker-resource-metrics-with-grafana-influxdb-and-telegraf/
categories:
  - Uncategorized
tags:
  - cloud
  - data
  - docker
  - documentation
  - network

---
I needed a way to monitor Docker resource usage and metrics (CPU, Memory, Network, Disk). I also wanted historical data, and ideally, pretty graphs that I could navigate and drill into.

Whatever the solution was going to be, it had to be very open and customizable, easy to setup and scale for a production-like environment (stability, size), and ideally cheap/free. But most of all &#8212; it had to make sense and really be straight forward.

## 3 Containers and 10 minutes is all you need

To get this:  
[![Grafana dashboard showing Docker CPU, memory, and network metrics](/wp-content/uploads/2016/08/docker_metrics01.png)][1]

[![Grafana Docker metrics dashboard thumbnail](/wp-content/uploads/2016/08/docker_metrics02.png)][2]  
There are 3 components that are started via containers:

Grafana (dashboard/visual metrics and analytics)  
InfluxDB (time-series DB)  
Telegraf (time-series collector) &#8211; 1 per Docker host

The idea is that you first launch Grafana, and then launch InfluxDB. You configure Grafana (via the web) to point to InfluxDB&#8217;s IP, and then you setup a Telegraf container on each Docker host that you want to monitor. Telegraf collects all the metrics and feeds them into a central InfluxDB, and Grafana displays them.

## Setup Tutorial/Examples

<!--more-->

In our example, we have a bunch of servers running Docker:  
vm01, vm02, vm03 [VM IPs do not matter in this case]

A &#8220;data&#8221; folder (/data) on each vm for the data mounts.  
And we create an empty folder for each container: &#8220;/data/grafana&#8221;, &#8220;/data/influxdb&#8221;, &#8220;/data/telegraf&#8221;

A common network overlay or macvlan network (docker 1.12+) &#8212; we use the name &#8220;someNetworkName&#8221;

Static IPs (either via &#8220;&#8211;ip&#8221; directly, or something like pipework)

We will launch Grafana and InfluxDB on vm01, and a Telegraf container on vm01, vm02, and vm03.

Grafana (10.0.0.10)  
InfluxDB (10.0.0.20)  
Telegraf (10.0.0.101 on vm01, 10.0.0.102 on vm02, and 10.0.0.103 on vm03)

## Grafana</h3> 

Beautiful metric and analytics dashboard. Ideal for visualization and querying of time series data.

This is the first container you will launch on vm01:  
(note: you are mounting the dirs so that you can access/change the configs, and data that is generated. Dirs can be empty)

NOTE: For Grafana, using ALL defaults works. That means you can either specify the &#8220;-v&#8221; for the /etc/grafana, /var/lib/grafana, and /var/log/grafana &#8212; or skip it. It would make sense to specify the logs to have them, and it would make sense to specify the rest if you want to 1.) override something and/or 2.) add plugins. Otherwise, you are fine with defaults. I will provide the &#8220;default&#8221; config in the comments bellow.

`<br />
docker run --restart=always -d --net=someNetworkName --ip=10.0.0.10 \<br />
	--name grafana \<br />
	--hostname grafana \<br />
	-v /data/grafana/var/lib/grafana:/var/lib/grafana \<br />
	-v /data/grafana/etc/grafana:/etc/grafana \<br />
	-v /data/grafana/var/log/grafana:/var/log/grafana \<br />
	-p 3000:3000 \<br />
	-e "GF_SERVER_ROOT_URL=http://10.0.0.10"  \<br />
	-e "GF_SECURITY_ADMIN_PASSWORD=somepasswordhere"  \<br />
	grafana/grafana</p>
<p>`

## InfluxDB</h3> 

Time-series data storage. A database designed for time-series data. Very easy to use, and feeds data into Grafana. It can accept data from many tools, specifically collectors like Telegraf.

First generate a config file:  
`<br />
docker run --rm influxdb influxd config > /data/influxdb/influxdb.conf<br />
` 

Then run the container as your second container on vm01:  
`<br />
docker run --restart=always -d --net=someNetworkName --ip=10.0.0.20 \<br />
	--name=influxdb \<br />
	--hostname=influxdb \<br />
	-p 8083:8083 -p 8086:8086 \<br />
	-v /data/influxdb:/var/lib/influxdb \<br />
	-v /data/influxdb/influxdb.conf:/etc/influxdb/influxdb.conf:ro \<br />
	influxdb -config /etc/influxdb/influxdb.conf<br />
` 

## Telegraf</h3> 

Time-series data collection. This uses a config to know what data to collect and where to feed it.

First generate a config file:  
`<br />
docker run --rm telegraf -sample-config > /data/telegraf/telegraf.conf<br />
` 

Edit the config and just enable the Docker portion (uncomment the &#8220;[[inputs.docker]]&#8221; section until the timeout)

The only other config line you need is this:  
`<br />
[[outputs.influxdb]]<br />
  #urls = ["http://IP-or-NAME-of-INFLUXDB:8086"] # required<br />
  urls = ["http://10.10.10.20:8086"] # required<br />
  database = "telegraf" # required<br />
` 

Then run the container as your third container on vm01 (and later on vm02, and vm03, with changes bellow code):  
`<br />
docker run -d --restart=always --net=admin01 --ip=10.0.0.101 \<br />
	--add-host="influxdb:10.0.0.20"\<br />
	--name=stats-s01 \<br />
	--hostname=vm01 \<br />
	-e "HOST_PROC=/rootfs/proc" \<br />
	-e "HOST_SYS=/rootfs/sys" \<br />
	-e "HOST_ETC=/rootfs/etc" \<br />
	-v /data/telegraf/telegraf.conf:/etc/telegraf/telegraf.conf:ro \<br />
	-v /var/run/docker.sock:/var/run/docker.sock:ro \<br />
	-v /sys:/rootfs/sys:ro -v /proc:/rootfs/proc:ro \<br />
	-v /etc:/rootfs/etc:ro telegraf<br />
` 

NOTE: You will launch the almost the same thing on vm02 and vm03, but you would change the &#8211;hostname (vm02, and vm03) and &#8211;ip (10.0.0.102, and 10.0.0.103)

## Last Step &#8211; Connect via Web and Start Using

Log into http://10.0.0.10:3000 (admin, and password from docker &#8220;GF\_SECURITY\_ADMIN_PASSWORD&#8221;), and go to:  
1.) The top left Menu (icon of Spiral)  
2.) Data Sources  
3.) + Add data source  
4.) Fill out:  
a.) Name: InfluxDB  
b.) Type: InfluxDB  
c.) (HTTP Settings) Url: http://10.0.0.20:8086  
d.) (InfluxDB Settings) Database: telegraf  
5.) Click &#8220;Save & Test&#8221; &#8212; it will save and work (ignore the &#8220;Please fill out this field &#8212; this is for production environments &#8212; setting up DB users, and eventually SSL)

It should look like this:

[![Grafana data source configuration screen for InfluxDB](/wp-content/uploads/2016/08/grafana_data_source.png)][3]

## That&#8217;s it! You are Done!

Now you can go to the top left menu -> Add a new Dashboard -> Add a panel, and start adding Graph (or other) data.  
For Graph for example, under the Metrics tab, you can access all of the variables in a point and click method.

Here&#8217;s a example to add a new graph on a new Row (after you create a Panel):  
[![Grafana panel menu showing the Add Graph option](/wp-content/uploads/2016/08/add_graph.png)][4]

And here&#8217;s an example of how you would modify the &#8220;search&#8221; by point and click:  
[![Grafana graph configuration with the metrics query builder](/wp-content/uploads/2016/08/grafana_configure.png)][5]

## How I came to this solution (skip if you are not interested)

After some research, I realized just how bad of a state the currently available solutions and tutorials/example/documentation were. They were either too simple and not useful (CAdvisor), not fully implemented (Stats, Scout), extremely complicated in design and difficult to setup or lacking documentation (Sensu, Prometheus, etc.), or just expensive (DataDog, SysDigCloud).

And the tutorials on docker and metrics were basically non existent. Rancher&#8217;s guide is the most &#8220;current and complete&#8221; doc on this as of today, in terms of what&#8217;s available, and you can find it <a href="http://rancher.com/comparing-monitoring-options-for-docker-deployments/" target="_blank">HERE</a>.

 [1]: /wp-content/uploads/2016/08/docker_metrics01.png
 [2]: /wp-content/uploads/2016/08/docker_metrics02.png
 [3]: /wp-content/uploads/2016/08/grafana_data_source.png
 [4]: /wp-content/uploads/2016/08/add_graph.png
 [5]: /wp-content/uploads/2016/08/grafana_configure.png