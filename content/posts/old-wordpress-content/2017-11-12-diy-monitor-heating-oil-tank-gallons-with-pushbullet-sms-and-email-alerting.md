---
title: DIY – Monitor Heating Oil Tank Gallons with Pushbullet, SMS, and Email Alerting
author: Ventz
type: post
date: 2017-11-12T08:01:14+00:00
url: /2017/11/12/diy-monitor-heating-oil-tank-gallons-with-pushbullet-sms-and-email-alerting/
categories:
  - Uncategorized
tags:
  - automation
  - cloud
  - data
  - hack
  - iot
  - photon

---
**NOTE: Updated code 10-27-2018**

In this day and age where everything is measured, recorded, and available remotely (via a REST API most of the time!), it really bothered me that our heating oil tank measured the remaining gallons of oil by a crude plastic dip stick. It&#8217;s not accurate, there is no historical data, and there is no way to audit (for honesty, accuracy, or problems/errors).

So the problem is simple enough: Find a quick and easy way to remotely monitor the number of gallons of heating oil in a home, and alert at pre-set intervals (let&#8217;s say 75%, 50%, and 25%) of remaining oil in the tank.

After looking for commercial solutions, the cheapest one I found is $120 with a $10/year fee. In my view, that&#8217;s simply ridiculous. I decided that I could build something better for 1/3rd of the price ($40), without an yearly fee.

## Hardware How-To

Start with this Instructable I created with the exact parts/steps, and with lots of pictures:  
<https://www.instructables.com/id/Monitor-Heating-Oil-Tank-Gallons-With-Email-SMS-an/>

This should take care of the hardware side.  
<!--more-->

## Firmware code and How-To Access Data

Once you have it built &#8211; flash your Photon with the code here (see bellow &#8211; large code paste).

After that, you should be able to do this from the particle CLI (replace $device-id-here$ with actual device #):  
`<br />
# This will tell you how many inches away from the sensor the oil is. It is the only "100% accurate" (non-calculated, but actually measured that is)<br />
particle get $device-id-here$ distance</p>
<p># This is calculated based on the first one and assuming a 275 gallon tank:<br />
particle get $device-id-here$ oil-inches</p>
<p># And using well known charts (like this: http://www.adamspetro.com/residential-heating-tank-chart), gallons are calculated:<br />
particle get $device-id-here$ oil-gallons</p>
<p># You can also get a real time stream (every 10 seconds with current firmware code):<br />
particle subscribe oil-gallons mine<br />
` 

If you have not used the Particle Photon, I am going to provide some additional information on the bottom of this post that will walk you through building/flashing the code, and how to setup the web hook. I have also added a lot of pictures of this on the Instructables page to go with the steps.

Particle Photon web IDE code:

<pre class="lang:c decode:true " title="Photon - Oil Tank Measurement">// By: Ventz Petkov
// LAST UPDATED: 10-27-2018
// This #include statement was automatically added by the Particle IDE.
#include &lt;HC_SR04.h>

double inches = 0.0;
double inches_of_oil = 0.0;
double gallons_of_oil = 0.0;

int trigPin = D0;
int echoPin = D1;


int alert1 = 1;
int alert2 = 1;
int alert3 = 1;
int alert4 = 1;
int alert5 = 1;
int alert6 = 1;
int refill_alert = 1;
/*
Connect an HC-SR04 Range finder as follows:
Spark   HC-SR04
GND     GND
5V      VCC
D0     Trig
D1      Echo

The default usable rangefinder is 10cm to 250cm. Outside of that range -1 is returned as the distance.

You can change this range by supplying two extra parameters to the constructor of minCM and maxCM, like this:

HC_SR04 rangefinder = HC_SR04(trigPin, echoPin, 5.0, 300.0);

Inches of oil to gallons:
http://www.adamspetro.com/residential-heating-tank-chart

*/

HC_SR04 rangefinder = HC_SR04(trigPin, echoPin);

void setup() 
{
    // NOTE: distance is the only TRUE/"non-calculated" measurement away from the sensor
    Particle.variable("distance", inches);
    Particle.variable("oil-inches", inches_of_oil);
    // NOTE: When comparing with physical oil gauges, always read it at the TOP of the "wedge" if it's not a thin "line" type of gague.
    Particle.variable("oil-gallons", gallons_of_oil);
}

void loop() 
{
    /*
    NOTE: This assumes a 275 Gallon Vertical Oil tank - the most popular residential ("home") tank.
          If you have something else, please modify the inches to gallons bellow per the provided URL chart.
          The max capacity on a 275 gallon tank is 266 gallons, and most companies fill it up to 250-255 gallons.
    */

    inches = rangefinder.getDistanceInch(); inches = rangefinder.getDistanceInch();
    inches_of_oil = round((45.89 - inches)*10)/10;
    
    if(inches_of_oil == 44) { gallons_of_oil = 275; }
    else if(inches_of_oil == 43.9) { gallons_of_oil = 274.7; }
    else if(inches_of_oil == 43.8) { gallons_of_oil = 274.4; }
    else if(inches_of_oil == 43.7) { gallons_of_oil = 274.1; }
    else if(inches_of_oil == 43.6) { gallons_of_oil = 273.8; }
    else if(inches_of_oil == 43.5) { gallons_of_oil = 273.5; }
    else if(inches_of_oil == 43.4) { gallons_of_oil = 273.2; }
    else if(inches_of_oil == 43.3) { gallons_of_oil = 272.9; }
    else if(inches_of_oil == 43.2) { gallons_of_oil = 272.6; }
    else if(inches_of_oil == 43.1) { gallons_of_oil = 272.3; }
    else if(inches_of_oil == 43) { gallons_of_oil = 272; }
    else if(inches_of_oil == 42.9) { gallons_of_oil = 271.6; }
    else if(inches_of_oil == 42.8) { gallons_of_oil = 271.2; }
    else if(inches_of_oil == 42.7) { gallons_of_oil = 270.8; }
    else if(inches_of_oil == 42.6) { gallons_of_oil = 270.4; }
    else if(inches_of_oil == 42.5) { gallons_of_oil = 270; }
    else if(inches_of_oil == 42.4) { gallons_of_oil = 269.6; }
    else if(inches_of_oil == 42.3) { gallons_of_oil = 269.2; }
    else if(inches_of_oil == 42.2) { gallons_of_oil = 268.8; }
    else if(inches_of_oil == 42.1) { gallons_of_oil = 268.4; }
    else if(inches_of_oil == 42) { gallons_of_oil = 268; }
    else if(inches_of_oil == 41.9) { gallons_of_oil = 267.6; }
    else if(inches_of_oil == 41.8) { gallons_of_oil = 267.2; }
    else if(inches_of_oil == 41.7) { gallons_of_oil = 266.8; }
    else if(inches_of_oil == 41.6) { gallons_of_oil = 266.4; }
    else if(inches_of_oil == 41.5) { gallons_of_oil = 266; }
    else if(inches_of_oil == 41.4) { gallons_of_oil = 265.6; }
    else if(inches_of_oil == 41.3) { gallons_of_oil = 265.2; }
    else if(inches_of_oil == 41.2) { gallons_of_oil = 264.8; }
    else if(inches_of_oil == 41.1) { gallons_of_oil = 264.4; }
    else if(inches_of_oil == 41) { gallons_of_oil = 264; }
    else if(inches_of_oil == 40.9) { gallons_of_oil = 263.5; }
    else if(inches_of_oil == 40.8) { gallons_of_oil = 263; }
    else if(inches_of_oil == 40.7) { gallons_of_oil = 262.5; }
    else if(inches_of_oil == 40.6) { gallons_of_oil = 262; }
    else if(inches_of_oil == 40.5) { gallons_of_oil = 261.5; }
    else if(inches_of_oil == 40.4) { gallons_of_oil = 261; }
    else if(inches_of_oil == 40.3) { gallons_of_oil = 260.5; }
    else if(inches_of_oil == 40.2) { gallons_of_oil = 260; }
    else if(inches_of_oil == 40.1) { gallons_of_oil = 259.5; }
    else if(inches_of_oil == 40) { gallons_of_oil = 259; }
    else if(inches_of_oil == 39.9) { gallons_of_oil = 258.5; }
    else if(inches_of_oil == 39.8) { gallons_of_oil = 258; }
    else if(inches_of_oil == 39.7) { gallons_of_oil = 257.5; }
    else if(inches_of_oil == 39.6) { gallons_of_oil = 257; }
    else if(inches_of_oil == 39.5) { gallons_of_oil = 256.5; }
    else if(inches_of_oil == 39.4) { gallons_of_oil = 256; }
    else if(inches_of_oil == 39.3) { gallons_of_oil = 255.5; }
    else if(inches_of_oil == 39.2) { gallons_of_oil = 255; }
    else if(inches_of_oil == 39.1) { gallons_of_oil = 254.5; }
    else if(inches_of_oil == 39) { gallons_of_oil = 254; }
    else if(inches_of_oil == 38.9) { gallons_of_oil = 253.4; }
    else if(inches_of_oil == 38.8) { gallons_of_oil = 252.8; }
    else if(inches_of_oil == 38.7) { gallons_of_oil = 252.2; }
    else if(inches_of_oil == 38.6) { gallons_of_oil = 251.6; }
    else if(inches_of_oil == 38.5) { gallons_of_oil = 251; }
    else if(inches_of_oil == 38.4) { gallons_of_oil = 250.4; }
    else if(inches_of_oil == 38.3) { gallons_of_oil = 249.8; }
    else if(inches_of_oil == 38.2) { gallons_of_oil = 249.2; }
    else if(inches_of_oil == 38.1) { gallons_of_oil = 248.6; }
    else if(inches_of_oil == 38) { gallons_of_oil = 248; }
    else if(inches_of_oil == 37.9) { gallons_of_oil = 247.4; }
    else if(inches_of_oil == 37.8) { gallons_of_oil = 246.8; }
    else if(inches_of_oil == 37.7) { gallons_of_oil = 246.2; }
    else if(inches_of_oil == 37.6) { gallons_of_oil = 245.6; }
    else if(inches_of_oil == 37.5) { gallons_of_oil = 245.0; }
    else if(inches_of_oil == 37.4) { gallons_of_oil = 244.4; }
    else if(inches_of_oil == 37.3) { gallons_of_oil = 243.8; }
    else if(inches_of_oil == 37.2) { gallons_of_oil = 243.2; }
    else if(inches_of_oil == 37.1) { gallons_of_oil = 242.6; }
    else if(inches_of_oil == 37) { gallons_of_oil = 242; }
    else if(inches_of_oil == 36.9) { gallons_of_oil = 241.3; }
    else if(inches_of_oil == 36.8) { gallons_of_oil = 240.6; }
    else if(inches_of_oil == 36.7) { gallons_of_oil = 239.9; }
    else if(inches_of_oil == 36.6) { gallons_of_oil = 239.2; }
    else if(inches_of_oil == 36.5) { gallons_of_oil = 238.5; }
    else if(inches_of_oil == 36.4) { gallons_of_oil = 237.8; }
    else if(inches_of_oil == 36.3) { gallons_of_oil = 237.1; }
    else if(inches_of_oil == 36.2) { gallons_of_oil = 236.4; }
    else if(inches_of_oil == 36.1) { gallons_of_oil = 235.7; }
    else if(inches_of_oil == 36) { gallons_of_oil = 235; }
    else if(inches_of_oil == 35.9) { gallons_of_oil = 234.3; }
    else if(inches_of_oil == 35.8) { gallons_of_oil = 233.6; }
    else if(inches_of_oil == 35.7) { gallons_of_oil = 232.9; }
    else if(inches_of_oil == 35.6) { gallons_of_oil = 232.2; }
    else if(inches_of_oil == 35.5) { gallons_of_oil = 231.5; }
    else if(inches_of_oil == 35.4) { gallons_of_oil = 230.8; }
    else if(inches_of_oil == 35.3) { gallons_of_oil = 230.1; }
    else if(inches_of_oil == 35.2) { gallons_of_oil = 229.4; }
    else if(inches_of_oil == 35.1) { gallons_of_oil = 228.7; }
    else if(inches_of_oil == 35) { gallons_of_oil = 228; }
    else if(inches_of_oil == 34.9) { gallons_of_oil = 227.3; }
    else if(inches_of_oil == 34.8) { gallons_of_oil = 226.6; }
    else if(inches_of_oil == 34.7) { gallons_of_oil = 225.9; }
    else if(inches_of_oil == 34.6) { gallons_of_oil = 225.2; }
    else if(inches_of_oil == 34.5) { gallons_of_oil = 224.5; }
    else if(inches_of_oil == 34.4) { gallons_of_oil = 223.8; }
    else if(inches_of_oil == 34.3) { gallons_of_oil = 223.1; }
    else if(inches_of_oil == 34.2) { gallons_of_oil = 222.4; }
    else if(inches_of_oil == 34.1) { gallons_of_oil = 221.7; }
    else if(inches_of_oil == 34) { gallons_of_oil = 221; }
    else if(inches_of_oil == 33.9) { gallons_of_oil = 220.3; }
    else if(inches_of_oil == 33.8) { gallons_of_oil = 219.6; }
    else if(inches_of_oil == 33.7) { gallons_of_oil = 218.9; }
    else if(inches_of_oil == 33.6) { gallons_of_oil = 218.2; }
    else if(inches_of_oil == 33.5) { gallons_of_oil = 217.5; }
    else if(inches_of_oil == 33.4) { gallons_of_oil = 216.8; }
    else if(inches_of_oil == 33.3) { gallons_of_oil = 216.1; }
    else if(inches_of_oil == 33.2) { gallons_of_oil = 215.4; }
    else if(inches_of_oil == 33.1) { gallons_of_oil = 214.7; }
    else if(inches_of_oil == 33) { gallons_of_oil = 214; }
    else if(inches_of_oil == 32.9) { gallons_of_oil = 213.3; }
    else if(inches_of_oil == 32.8) { gallons_of_oil = 212.6; }
    else if(inches_of_oil == 32.7) { gallons_of_oil = 211.9; }
    else if(inches_of_oil == 32.6) { gallons_of_oil = 211.2; }
    else if(inches_of_oil == 32.5) { gallons_of_oil = 210.5; }
    else if(inches_of_oil == 32.4) { gallons_of_oil = 209.8; }
    else if(inches_of_oil == 32.3) { gallons_of_oil = 209.1; }
    else if(inches_of_oil == 32.2) { gallons_of_oil = 208.4; }
    else if(inches_of_oil == 32.1) { gallons_of_oil = 207.7; }
    else if(inches_of_oil == 32) { gallons_of_oil = 207; }
    else if(inches_of_oil == 31.9) { gallons_of_oil = 206.3; }
    else if(inches_of_oil == 31.8) { gallons_of_oil = 205.6; }
    else if(inches_of_oil == 31.7) { gallons_of_oil = 204.9; }
    else if(inches_of_oil == 31.6) { gallons_of_oil = 204.2; }
    else if(inches_of_oil == 31.5) { gallons_of_oil = 203.5; }
    else if(inches_of_oil == 31.4) { gallons_of_oil = 202.8; }
    else if(inches_of_oil == 31.3) { gallons_of_oil = 202.1; }
    else if(inches_of_oil == 31.2) { gallons_of_oil = 201.4; }
    else if(inches_of_oil == 31.1) { gallons_of_oil = 200.7; }
    else if(inches_of_oil == 31) { gallons_of_oil = 200; }
    else if(inches_of_oil == 30.9) { gallons_of_oil = 199.3; }
    else if(inches_of_oil == 30.8) { gallons_of_oil = 198.6; }
    else if(inches_of_oil == 30.7) { gallons_of_oil = 197.9; }
    else if(inches_of_oil == 30.6) { gallons_of_oil = 197.2; }
    else if(inches_of_oil == 30.5) { gallons_of_oil = 196.5; }
    else if(inches_of_oil == 30.4) { gallons_of_oil = 195.8; }
    else if(inches_of_oil == 30.3) { gallons_of_oil = 195.1; }
    else if(inches_of_oil == 30.2) { gallons_of_oil = 194.4; }
    else if(inches_of_oil == 30.1) { gallons_of_oil = 193.7; }
    else if(inches_of_oil == 30) { gallons_of_oil = 193; }
    else if(inches_of_oil == 29.9) { gallons_of_oil = 192.3; }
    else if(inches_of_oil == 29.8) { gallons_of_oil = 191.6; }
    else if(inches_of_oil == 29.7) { gallons_of_oil = 190.9; }
    else if(inches_of_oil == 29.6) { gallons_of_oil = 190.2; }
    else if(inches_of_oil == 29.5) { gallons_of_oil = 189.5; }
    else if(inches_of_oil == 29.4) { gallons_of_oil = 188.8; }
    else if(inches_of_oil == 29.3) { gallons_of_oil = 188.1; }
    else if(inches_of_oil == 29.2) { gallons_of_oil = 187.4; }
    else if(inches_of_oil == 29.1) { gallons_of_oil = 186.7; }
    else if(inches_of_oil == 29) { gallons_of_oil = 186; }
    else if(inches_of_oil == 28.9) { gallons_of_oil = 185.3; }
    else if(inches_of_oil == 28.8) { gallons_of_oil = 184.6; }
    else if(inches_of_oil == 28.7) { gallons_of_oil = 183.9; }
    else if(inches_of_oil == 28.6) { gallons_of_oil = 183.2; }
    else if(inches_of_oil == 28.5) { gallons_of_oil = 182.5; }
    else if(inches_of_oil == 28.4) { gallons_of_oil = 181.8; }
    else if(inches_of_oil == 28.3) { gallons_of_oil = 181.1; }
    else if(inches_of_oil == 28.2) { gallons_of_oil = 180.4; }
    else if(inches_of_oil == 28.1) { gallons_of_oil = 179.7; }
    else if(inches_of_oil == 28) { gallons_of_oil = 179; }
    else if(inches_of_oil == 27.9) { gallons_of_oil = 178.3; }
    else if(inches_of_oil == 27.8) { gallons_of_oil = 177.6; }
    else if(inches_of_oil == 27.7) { gallons_of_oil = 176.9; }
    else if(inches_of_oil == 27.6) { gallons_of_oil = 176.2; }
    else if(inches_of_oil == 27.5) { gallons_of_oil = 175.5; }
    else if(inches_of_oil == 27.4) { gallons_of_oil = 174.8; }
    else if(inches_of_oil == 27.3) { gallons_of_oil = 174.1; }
    else if(inches_of_oil == 27.2) { gallons_of_oil = 173.4; }
    else if(inches_of_oil == 27.1) { gallons_of_oil = 172.7; }
    else if(inches_of_oil == 27) { gallons_of_oil = 172; }
    else if(inches_of_oil == 26.9) { gallons_of_oil = 171.3; }
    else if(inches_of_oil == 26.8) { gallons_of_oil = 170.6; }
    else if(inches_of_oil == 26.7) { gallons_of_oil = 169.9; }
    else if(inches_of_oil == 26.6) { gallons_of_oil = 169.2; }
    else if(inches_of_oil == 26.5) { gallons_of_oil = 168.5; }
    else if(inches_of_oil == 26.4) { gallons_of_oil = 167.8; }
    else if(inches_of_oil == 26.3) { gallons_of_oil = 167.1; }
    else if(inches_of_oil == 26.2) { gallons_of_oil = 166.4; }
    else if(inches_of_oil == 26.1) { gallons_of_oil = 165.7; }
    else if(inches_of_oil == 26) { gallons_of_oil = 165; }
    else if(inches_of_oil == 25.9) { gallons_of_oil = 164.3; }
    else if(inches_of_oil == 25.8) { gallons_of_oil = 163.6; }
    else if(inches_of_oil == 25.7) { gallons_of_oil = 162.9; }
    else if(inches_of_oil == 25.6) { gallons_of_oil = 162.2; }
    else if(inches_of_oil == 25.5) { gallons_of_oil = 161.5; }
    else if(inches_of_oil == 25.4) { gallons_of_oil = 160.8; }
    else if(inches_of_oil == 25.3) { gallons_of_oil = 160.1; }
    else if(inches_of_oil == 25.2) { gallons_of_oil = 159.4; }
    else if(inches_of_oil == 25.1) { gallons_of_oil = 158.7; }
    else if(inches_of_oil == 25) { gallons_of_oil = 158; }
    else if(inches_of_oil == 24.9) { gallons_of_oil = 157.3; }
    else if(inches_of_oil == 24.8) { gallons_of_oil = 156.6; }
    else if(inches_of_oil == 24.7) { gallons_of_oil = 155.9; }
    else if(inches_of_oil == 24.6) { gallons_of_oil = 155.2; }
    else if(inches_of_oil == 24.5) { gallons_of_oil = 154.5; }
    else if(inches_of_oil == 24.4) { gallons_of_oil = 153.8; }
    else if(inches_of_oil == 24.3) { gallons_of_oil = 153.1; }
    else if(inches_of_oil == 24.2) { gallons_of_oil = 152.4; }
    else if(inches_of_oil == 24.1) { gallons_of_oil = 151.7; }
    else if(inches_of_oil == 24) { gallons_of_oil = 151; }
    else if(inches_of_oil == 23.9) { gallons_of_oil = 150.2; }
    else if(inches_of_oil == 23.8) { gallons_of_oil = 149.4; }
    else if(inches_of_oil == 23.7) { gallons_of_oil = 148.6; }
    else if(inches_of_oil == 23.6) { gallons_of_oil = 147.8; }
    else if(inches_of_oil == 23.5) { gallons_of_oil = 147; }
    else if(inches_of_oil == 23.4) { gallons_of_oil = 146.2; }
    else if(inches_of_oil == 23.3) { gallons_of_oil = 145.4; }
    else if(inches_of_oil == 23.2) { gallons_of_oil = 144.6; }
    else if(inches_of_oil == 23.1) { gallons_of_oil = 143.8; }
    else if(inches_of_oil == 23) { gallons_of_oil = 143; }
    else if(inches_of_oil == 22.9) { gallons_of_oil = 142.3; }
    else if(inches_of_oil == 22.8) { gallons_of_oil = 141.6; }
    else if(inches_of_oil == 22.7) { gallons_of_oil = 140.9; }
    else if(inches_of_oil == 22.6) { gallons_of_oil = 140.2; }
    else if(inches_of_oil == 22.5) { gallons_of_oil = 139.5; }
    else if(inches_of_oil == 22.4) { gallons_of_oil = 138.8; }
    else if(inches_of_oil == 22.3) { gallons_of_oil = 138.1; }
    else if(inches_of_oil == 22.2) { gallons_of_oil = 137.4; }
    else if(inches_of_oil == 22.1) { gallons_of_oil = 136.7; }
    else if(inches_of_oil == 22) { gallons_of_oil = 136; }
    else if(inches_of_oil == 21.9) { gallons_of_oil = 135.3; }
    else if(inches_of_oil == 21.8) { gallons_of_oil = 134.6; }
    else if(inches_of_oil == 21.7) { gallons_of_oil = 133.9; }
    else if(inches_of_oil == 21.6) { gallons_of_oil = 133.2; }
    else if(inches_of_oil == 21.5) { gallons_of_oil = 132.5; }
    else if(inches_of_oil == 21.4) { gallons_of_oil = 131.8; }
    else if(inches_of_oil == 21.3) { gallons_of_oil = 131.1; }
    else if(inches_of_oil == 21.2) { gallons_of_oil = 130.4; }
    else if(inches_of_oil == 21.1) { gallons_of_oil = 129.7; }
    else if(inches_of_oil == 21) { gallons_of_oil = 129; }
    else if(inches_of_oil == 20.9) { gallons_of_oil = 128.3; }
    else if(inches_of_oil == 20.8) { gallons_of_oil = 127.6; }
    else if(inches_of_oil == 20.7) { gallons_of_oil = 126.9; }
    else if(inches_of_oil == 20.6) { gallons_of_oil = 126.2; }
    else if(inches_of_oil == 20.5) { gallons_of_oil = 125.5; }
    else if(inches_of_oil == 20.4) { gallons_of_oil = 124.8; }
    else if(inches_of_oil == 20.3) { gallons_of_oil = 124.1; }
    else if(inches_of_oil == 20.2) { gallons_of_oil = 123.4; }
    else if(inches_of_oil == 20.1) { gallons_of_oil = 122.7; }
    else if(inches_of_oil == 20) { gallons_of_oil = 122; }
    else if(inches_of_oil == 19.9) { gallons_of_oil = 121.3; }
    else if(inches_of_oil == 19.8) { gallons_of_oil = 120.6; }
    else if(inches_of_oil == 19.7) { gallons_of_oil = 119.9; }
    else if(inches_of_oil == 19.6) { gallons_of_oil = 119.2; }
    else if(inches_of_oil == 19.5) { gallons_of_oil = 118.5; }
    else if(inches_of_oil == 19.4) { gallons_of_oil = 117.8; }
    else if(inches_of_oil == 19.3) { gallons_of_oil = 117.1; }
    else if(inches_of_oil == 19.2) { gallons_of_oil = 116.4; }
    else if(inches_of_oil == 19.1) { gallons_of_oil = 115.7; }
    else if(inches_of_oil == 19) { gallons_of_oil = 115; }
    else if(inches_of_oil == 18.9) { gallons_of_oil = 114.3; }
    else if(inches_of_oil == 18.8) { gallons_of_oil = 113.6; }
    else if(inches_of_oil == 18.7) { gallons_of_oil = 112.9; }
    else if(inches_of_oil == 18.6) { gallons_of_oil = 112.2; }
    else if(inches_of_oil == 18.5) { gallons_of_oil = 111.5; }
    else if(inches_of_oil == 18.4) { gallons_of_oil = 110.8; }
    else if(inches_of_oil == 18.3) { gallons_of_oil = 110.1; }
    else if(inches_of_oil == 18.2) { gallons_of_oil = 109.4; }
    else if(inches_of_oil == 18.1) { gallons_of_oil = 108.7; }
    else if(inches_of_oil == 18) { gallons_of_oil = 108; }
    else if(inches_of_oil == 17.9) { gallons_of_oil = 107.3; }
    else if(inches_of_oil == 17.8) { gallons_of_oil = 106.6; }
    else if(inches_of_oil == 17.7) { gallons_of_oil = 105.9; }
    else if(inches_of_oil == 17.6) { gallons_of_oil = 105.2; }
    else if(inches_of_oil == 17.5) { gallons_of_oil = 104.5; }
    else if(inches_of_oil == 17.4) { gallons_of_oil = 103.8; }
    else if(inches_of_oil == 17.3) { gallons_of_oil = 103.1; }
    else if(inches_of_oil == 17.2) { gallons_of_oil = 102.4; }
    else if(inches_of_oil == 17.1) { gallons_of_oil = 101.7; }
    else if(inches_of_oil == 17) { gallons_of_oil = 101; }
    else if(inches_of_oil == 16.9) { gallons_of_oil = 100.3; }
    else if(inches_of_oil == 16.8) { gallons_of_oil = 99.6; }
    else if(inches_of_oil == 16.7) { gallons_of_oil = 98.9; }
    else if(inches_of_oil == 16.6) { gallons_of_oil = 98.2; }
    else if(inches_of_oil == 16.5) { gallons_of_oil = 97.5; }
    else if(inches_of_oil == 16.4) { gallons_of_oil = 96.8; }
    else if(inches_of_oil == 16.3) { gallons_of_oil = 96.1; }
    else if(inches_of_oil == 16.2) { gallons_of_oil = 95.4; }
    else if(inches_of_oil == 16.1) { gallons_of_oil = 94.7; }
    else if(inches_of_oil == 16.0) { gallons_of_oil = 94; }
    else if(inches_of_oil == 15.9) { gallons_of_oil = 93.2; }
    else if(inches_of_oil == 15.8) { gallons_of_oil = 92.4; }
    else if(inches_of_oil == 15.7) { gallons_of_oil = 91.6; }
    else if(inches_of_oil == 15.6) { gallons_of_oil = 90.8; }
    else if(inches_of_oil == 15.5) { gallons_of_oil = 90; }
    else if(inches_of_oil == 15.4) { gallons_of_oil = 89.2; }
    else if(inches_of_oil == 15.3) { gallons_of_oil = 88.4; }
    else if(inches_of_oil == 15.2) { gallons_of_oil = 87.6; }
    else if(inches_of_oil == 15.1) { gallons_of_oil = 86.8; }
    else if(inches_of_oil == 15) { gallons_of_oil = 86; }
    else if(inches_of_oil == 14.9) { gallons_of_oil = 85.3; }
    else if(inches_of_oil == 14.8) { gallons_of_oil = 84.6; }
    else if(inches_of_oil == 14.7) { gallons_of_oil = 83.9; }
    else if(inches_of_oil == 14.6) { gallons_of_oil = 83.2; }
    else if(inches_of_oil == 14.5) { gallons_of_oil = 82.5; }
    else if(inches_of_oil == 14.4) { gallons_of_oil = 81.8; }
    else if(inches_of_oil == 14.3) { gallons_of_oil = 81.1; }
    else if(inches_of_oil == 14.2) { gallons_of_oil = 80.4; }
    else if(inches_of_oil == 14.1) { gallons_of_oil = 79.7; }
    else if(inches_of_oil == 14) { gallons_of_oil = 79; }
    else if(inches_of_oil == 13.9) { gallons_of_oil = 78.3; }
    else if(inches_of_oil == 13.8) { gallons_of_oil = 77.6; }
    else if(inches_of_oil == 13.7) { gallons_of_oil = 76.9; }
    else if(inches_of_oil == 13.6) { gallons_of_oil = 76.2; }
    else if(inches_of_oil == 13.5) { gallons_of_oil = 75.5; }
    else if(inches_of_oil == 13.4) { gallons_of_oil = 74.8; }
    else if(inches_of_oil == 13.3) { gallons_of_oil = 74.1; }
    else if(inches_of_oil == 13.2) { gallons_of_oil = 73.4; }
    else if(inches_of_oil == 13.1) { gallons_of_oil = 72.7; }
    else if(inches_of_oil == 13) { gallons_of_oil = 72; }
    else if(inches_of_oil == 12.9) { gallons_of_oil = 71.3; }
    else if(inches_of_oil == 12.8) { gallons_of_oil = 70.6; }
    else if(inches_of_oil == 12.7) { gallons_of_oil = 69.9; }
    else if(inches_of_oil == 12.6) { gallons_of_oil = 69.2; }
    else if(inches_of_oil == 12.5) { gallons_of_oil = 68.5; }
    else if(inches_of_oil == 12.4) { gallons_of_oil = 67.8; }
    else if(inches_of_oil == 12.3) { gallons_of_oil = 67.1; }
    else if(inches_of_oil == 12.2) { gallons_of_oil = 66.4; }
    else if(inches_of_oil == 12.1) { gallons_of_oil = 65.7; }
    else if(inches_of_oil == 12) { gallons_of_oil = 65; }
    else if(inches_of_oil == 11.9) { gallons_of_oil = 64.3; }
    else if(inches_of_oil == 11.8) { gallons_of_oil = 63.6; }
    else if(inches_of_oil == 11.7) { gallons_of_oil = 62.9; }
    else if(inches_of_oil == 11.6) { gallons_of_oil = 62.2; }
    else if(inches_of_oil == 11.5) { gallons_of_oil = 61.5; }
    else if(inches_of_oil == 11.4) { gallons_of_oil = 60.8; }
    else if(inches_of_oil == 11.3) { gallons_of_oil = 60.1; }
    else if(inches_of_oil == 11.2) { gallons_of_oil = 59.4; }
    else if(inches_of_oil == 11.1) { gallons_of_oil = 58.7; }
    else if(inches_of_oil == 11) { gallons_of_oil = 58; }
    else if(inches_of_oil == 10.9) { gallons_of_oil = 57.3; }
    else if(inches_of_oil == 10.8) { gallons_of_oil = 56.6; }
    else if(inches_of_oil == 10.7) { gallons_of_oil = 55.9; }
    else if(inches_of_oil == 10.6) { gallons_of_oil = 55.2; }
    else if(inches_of_oil == 10.5) { gallons_of_oil = 54.5; }
    else if(inches_of_oil == 10.4) { gallons_of_oil = 53.8; }
    else if(inches_of_oil == 10.3) { gallons_of_oil = 53.1; }
    else if(inches_of_oil == 10.2) { gallons_of_oil = 52.4; }
    else if(inches_of_oil == 10.1) { gallons_of_oil = 51.7; }
    else if(inches_of_oil == 10) { gallons_of_oil = 51; }
    else if(inches_of_oil == 9.9) { gallons_of_oil = 50.3; }
    else if(inches_of_oil == 9.8) { gallons_of_oil = 49.6; }
    else if(inches_of_oil == 9.7) { gallons_of_oil = 48.9; }
    else if(inches_of_oil == 9.6) { gallons_of_oil = 48.2; }
    else if(inches_of_oil == 9.5) { gallons_of_oil = 47.5; }
    else if(inches_of_oil == 9.4) { gallons_of_oil = 46.8; }
    else if(inches_of_oil == 9.3) { gallons_of_oil = 46.1; }
    else if(inches_of_oil == 9.2) { gallons_of_oil = 45.4; }
    else if(inches_of_oil == 9.1) { gallons_of_oil = 44.7; }
    else if(inches_of_oil == 9) { gallons_of_oil = 44; }
    else if(inches_of_oil == 8.9) { gallons_of_oil = 43.4; }
    else if(inches_of_oil == 8.8) { gallons_of_oil = 42.8; }
    else if(inches_of_oil == 8.7) { gallons_of_oil = 42.2; }
    else if(inches_of_oil == 8.6) { gallons_of_oil = 41.6; }
    else if(inches_of_oil == 8.5) { gallons_of_oil = 41; }
    else if(inches_of_oil == 8.4) { gallons_of_oil = 40.4; }
    else if(inches_of_oil == 8.3) { gallons_of_oil = 39.8; }
    else if(inches_of_oil == 8.2) { gallons_of_oil = 39.2; }
    else if(inches_of_oil == 8.1) { gallons_of_oil = 38.6; }
    else if(inches_of_oil == 8) { gallons_of_oil = 38; }
    else if(inches_of_oil == 7.9) { gallons_of_oil = 37.3; }
    else if(inches_of_oil == 7.8) { gallons_of_oil = 36.6; }
    else if(inches_of_oil == 7.7) { gallons_of_oil = 35.9; }
    else if(inches_of_oil == 7.6) { gallons_of_oil = 35.2; }
    else if(inches_of_oil == 7.5) { gallons_of_oil = 34.5; }
    else if(inches_of_oil == 7.4) { gallons_of_oil = 33.8; }
    else if(inches_of_oil == 7.3) { gallons_of_oil = 33.1; }
    else if(inches_of_oil == 7.2) { gallons_of_oil = 32.4; }
    else if(inches_of_oil == 7.1) { gallons_of_oil = 31.7; }
    else if(inches_of_oil == 7) { gallons_of_oil = 31; }
    else if(inches_of_oil == 6.9) { gallons_of_oil = 30.4; }
    else if(inches_of_oil == 6.8) { gallons_of_oil = 29.8; }
    else if(inches_of_oil == 6.7) { gallons_of_oil = 29.2; }
    else if(inches_of_oil == 6.6) { gallons_of_oil = 28.6; }
    else if(inches_of_oil == 6.5) { gallons_of_oil = 28; }
    else if(inches_of_oil == 6.4) { gallons_of_oil = 27.4; }
    else if(inches_of_oil == 6.3) { gallons_of_oil = 26.8; }
    else if(inches_of_oil == 6.2) { gallons_of_oil = 26.2; }
    else if(inches_of_oil == 6.1) { gallons_of_oil = 25.6; }
    else if(inches_of_oil == 6) { gallons_of_oil = 25; }
    else if(inches_of_oil == 5.9) { gallons_of_oil = 24.4; }
    else if(inches_of_oil == 5.8) { gallons_of_oil = 23.8; }
    else if(inches_of_oil == 5.7) { gallons_of_oil = 23.2; }
    else if(inches_of_oil == 5.6) { gallons_of_oil = 22.6; }
    else if(inches_of_oil == 5.5) { gallons_of_oil = 22; }
    else if(inches_of_oil == 5.4) { gallons_of_oil = 21.4; }
    else if(inches_of_oil == 5.3) { gallons_of_oil = 20.8; }
    else if(inches_of_oil == 5.2) { gallons_of_oil = 20.2; }
    else if(inches_of_oil == 5.1) { gallons_of_oil = 19.06; }
    else if(inches_of_oil == 5) { gallons_of_oil = 19; }
    else if(inches_of_oil == 4.9) { gallons_of_oil = 18.5; }
    else if(inches_of_oil == 4.8) { gallons_of_oil = 18; }
    else if(inches_of_oil == 4.7) { gallons_of_oil = 17.5; }
    else if(inches_of_oil == 4.6) { gallons_of_oil = 17; }
    else if(inches_of_oil == 4.5) { gallons_of_oil = 16.5; }
    else if(inches_of_oil == 4.4) { gallons_of_oil = 16; }
    else if(inches_of_oil == 4.3) { gallons_of_oil = 15.5; }
    else if(inches_of_oil == 4.2) { gallons_of_oil = 15; }
    else if(inches_of_oil == 4.1) { gallons_of_oil = 14.5; }
    else if(inches_of_oil == 4) { gallons_of_oil = 14; }
    else if(inches_of_oil == 3.9) { gallons_of_oil = 13.5; }
    else if(inches_of_oil == 3.8) { gallons_of_oil = 13; }
    else if(inches_of_oil == 3.7) { gallons_of_oil = 12.5; }
    else if(inches_of_oil == 3.6) { gallons_of_oil = 12; }
    else if(inches_of_oil == 3.5) { gallons_of_oil = 11.5; }
    else if(inches_of_oil == 3.4) { gallons_of_oil = 11; }
    else if(inches_of_oil == 3.3) { gallons_of_oil = 10.5; }
    else if(inches_of_oil == 3.2) { gallons_of_oil = 10; }
    else if(inches_of_oil == 3.1) { gallons_of_oil = 9.5; }
    else if(inches_of_oil == 3) { gallons_of_oil = 9; }
    else if(inches_of_oil == 2.9) { gallons_of_oil = 8.6; }
    else if(inches_of_oil == 2.8) { gallons_of_oil = 8.2; }
    else if(inches_of_oil == 2.7) { gallons_of_oil = 7.8; }
    else if(inches_of_oil == 2.6) { gallons_of_oil = 7.4; }
    else if(inches_of_oil == 2.5) { gallons_of_oil = 7; }
    else if(inches_of_oil == 2.4) { gallons_of_oil = 6.6; }
    else if(inches_of_oil == 2.3) { gallons_of_oil = 6.2; }
    else if(inches_of_oil == 2.2) { gallons_of_oil = 5.8; }
    else if(inches_of_oil == 2.1) { gallons_of_oil = 5.4; }
    else if(inches_of_oil == 2) { gallons_of_oil = 5; }
    else if(inches_of_oil == 1.9) { gallons_of_oil = 4.7; }
    else if(inches_of_oil == 1.8) { gallons_of_oil = 4.4; }
    else if(inches_of_oil == 1.7) { gallons_of_oil = 4.1; }
    else if(inches_of_oil == 1.6) { gallons_of_oil = 3.8; }
    else if(inches_of_oil == 1.5) { gallons_of_oil = 3.5; }
    else if(inches_of_oil == 1.4) { gallons_of_oil = 3.2; }
    else if(inches_of_oil == 1.3) { gallons_of_oil = 2.9; }
    else if(inches_of_oil == 1.2) { gallons_of_oil = 2.6; }
    else if(inches_of_oil == 1.1) { gallons_of_oil = 2.3; }
    else if(inches_of_oil == 1) { gallons_of_oil = 2; }
    else if(inches_of_oil == 0.9) { gallons_of_oil = 1.8; }
    else if(inches_of_oil == 0.8) { gallons_of_oil = 1.6; }
    else if(inches_of_oil == 0.7) { gallons_of_oil = 1.4; }
    else if(inches_of_oil == 0.6) { gallons_of_oil = 1.2; }
    else if(inches_of_oil == 0.5) { gallons_of_oil = 1; }
    else if(inches_of_oil == 0.4) { gallons_of_oil = 0.8; }
    else if(inches_of_oil == 0.3) { gallons_of_oil = 0.6; }
    else if(inches_of_oil == 0.2) { gallons_of_oil = 0.4; }
    else if(inches_of_oil == 0.1) { gallons_of_oil = 0.2; }
    else if(inches_of_oil == 0) { gallons_of_oil = 0; }
    
    Particle.publish("oil-gallons", String(gallons_of_oil,1), PRIVATE);
    delay(10000);
    
    // Reset all of the alert flags!
    /*
    if(gallons_of_oil > 240 && refill_alert) {
        Particle.publish("Alert", "Oil REFILLED!", PRIVATE);
        alert1 = 1; alert2 = 1; alert3 = 1; alert4 = 1; alert5 = 1; alert6 = 1;
        refill_alert = 0;
    }
    
    else if(gallons_of_oil > 125 && gallons_of_oil &lt; 187.5 &#038;&#038; alert1) {
    */
    if(gallons_of_oil > 125 && gallons_of_oil &lt; 187.5 &#038;&#038; alert1) {
        Particle.publish("Alert", "Oil Level bellow 75%", PRIVATE);
        alert1 = 0;
        refill_alert = 1;
    }
    else if(gallons_of_oil > 65 &&  gallons_of_oil &lt; 125 &#038;&#038; alert2) {
        Particle.publish("Alert", "NOTICE: Oil Level bellow 50%", PRIVATE);
        alert2 = 0; alert1 = 1;
        refill_alert = 1;
    }
    else if(gallons_of_oil > 75 &&  gallons_of_oil &lt; 87.5 &#038;&#038; alert3) {
        Particle.publish("Alert", "NOTICE: Oil Level bellow 35%", PRIVATE);
        alert3 = 0; alert1 = 0; alert2 = 0;
        refill_alert = 1;
    }
    else if(gallons_of_oil > 62.5 &&  gallons_of_oil &lt; 75 &#038;&#038; alert4) {
        Particle.publish("Alert", "WARNING: Oil Level bellow 30% - Refill Soon", PRIVATE);
        alert4 = 0; alert1 = 0; alert2 = 0; alert3 = 0;
        refill_alert = 1;
    }
    else if(gallons_of_oil > 50 &&  gallons_of_oil &lt; 62.5 &#038;&#038; alert5) {
        Particle.publish("Alert", "CRITIAL: Oil Level bellow 25% - Call to Refill", PRIVATE);
        alert5 = 0; alert1 = 0; alert2 = 0; alert3 = 0; alert4 = 0;
        refill_alert = 1;
    }
    else if(gallons_of_oil &lt; 50 &#038;&#038; alert6) {
        Particle.publish("Alert", "EMERGENCY: Oil Level bellow 20%  - Get Delivery ASAP!", PRIVATE);
        alert6 = 0; alert1 = 0; alert2 = 0; alert3 = 0; alert4 = 0; alert5 = 0;
        refill_alert = 1;
        
    }
}
</pre>

Now that you have everything you need, the last part is to web hook the "Alert" publish call into something that actually alerts you. The easiest way to do this is to create a JSON "custom" webhook, which allows you to "hook" a publish event. In this case, I will hook the "Alert" published event, and redirect it to Pushbullet. You can just as easily call a 3rd party SMS service (Twilio), Email (Sendgrid, Mailgun, etc), or some other custom notification/hook.

Here is the Pushbullet config (please replace "Access-Token" with your token):

## Web Hook for Notifications (free with Pushbullet)

`<br />
{<br />
"eventName": "Alert",<br />
"url": "https://api.pushbullet.com/v2/pushes",<br />
"requestType": "POST",<br />
"headers": {<br />
"Access-Token": "#REPLACE-WITH-YOUR-PUSHBULLET-ACCESS-TOKEN",<br />
"Content-Type": "application/json"<br />
},<br />
"json": {<br />
"type": "note",<br />
"title": "Particle Alert - {{PARTICLE_PUBLISHED_AT}}",<br />
"body": "{{PARTICLE_EVENT_VALUE}}"<br />
},<br />
"deviceID": "",<br />
"mydevices": true,<br />
"source": "{{PARTICLE_DEVICE_ID}}",<br />
"published_at": "{{PARTICLE_PUBLISHED_AT}}"<br />
}<br />
` 

Or, if you are using Pushover  
`<br />
{<br />
  "event": "Alert",<br />
  "url": "https://api.pushover.net/1/messages.json",<br />
  "requestType": "POST",<br />
  "rejectUnauthorized": true,<br />
  "noDefaults": false,<br />
  "headers": {<br />
    "Content-Type": "application/json"<br />
  },<br />
  "json": {<br />
      "token": "#APP-API-TOKEN-KEY-HERE#",<br />
      "user": "#USER-KEY-HERE#",<br />
      "title": "Particle Alert - {{PARTICLE_PUBLISHED_AT}}",<br />
      "message": "{{PARTICLE_EVENT_VALUE}}"<br />
  },<br />
  "deviceID": "",<br />
  "mydevices": true,<br />
  "source": "{{PARTICLE_DEVICE_ID}}",<br />
  "published_at": "{{PARTICLE_PUBLISHED_AT}}"<br />
}<br />
` 

You will note that I have added a whole lot of pictures showing the steps around the Photon code build/flash and the Webhooks on the Instructables page. Here is some more informations/detials:

## What if you have never used a Particle Photon? Detailed Help on setup/code/flashing!

I made the assumption that a most people who would be interested in a hardware project like this one would be very familiar with Particle's photons/arduino, and I think this is a bad assumption. If you have not used these before, here is a step by step walk thru what to do from the software side in order to get this to work.

1.) Start by following this: <a href="https://docs.particle.io/guide/getting-started/start/photon/#step-1-power-on-your-device" rel="noopener" target="_blank">https://docs.particle.io/guide/getting-started/start/photon/#step-1-power-on-your-device</a>  
2.) After you have initialized/"set up" your photon, go to: <a href="https://build.particle.io" rel="noopener" target="_blank">https://build.particle.io</a>  
3.) On the left side, under "Current Apps" (where it says "Title") create an app called "oil-tank".  
Paste the large code from "Particle Photon web IDE code:" above, and click on the top-left "Save" (folder icon)  
4.) On the left, click on "Libraries" (bookmark icon) and under "Community Libraries" search in the box for "HC_SR04".  
5.) Click on the found "HC_SR04" and click the blue "INCLUDE IN PROJECT" button. Then select from the list "oil-tank" (what you called your app in step #3), and click the blue "CONFIRM" button.  
6.) At this point, make sure there is only ONE line that looks like this:  
`<br />
// This #include statement was automatically added by the Particle IDE.<br />
#include <HC_SR04.h><br />
`  
at the top of the file.  
7.) Now clic on "Devices" and click on the star icon next to the device you setup in step #1 -- this selects it for flashing the firmware.  
8.) Go back to your "Code" for "oil-tank" and click "Verify" (check icon above "Save") and then "Flash" (lightning bolt icon above "Verify")  
9.) That's it -- you have now flashed the firmware on your Photon.

## What are these Web Hooks/Notifications - step by step instructions

1.) Go to: <a href="https://console.particle.io/devices" rel="noopener" target="_blank">https://console.particle.io/devices</a>  
2.) Click on "Integrations" (star-looking icon above the Billing icon) and click on "New Integration", and click on "Webhook".  
3.) There are TWO differentways to do this - using the "WEBHOOK BUILDER" step by step, OR pasting the whole JSON in the "CUSTOM TEMPLATE" section. No matter which you do, the only thing to really pay attention to is the "Event Name". It always needs to be "Alert" (unless you change the Particle.publish in your firmware. This is what hooks that notifications into some "real world" notifcation - alert, SMS, Email, etc.)  
4.) If you use the "CUSTOM TEMPLATE", you can paste the "Web Hook for Notifications (free with Pushbullet)" code.  
Alternative, and let's say if you want SMS for example, you can go to the "WEBHOOK BUILDER" section, and follow something like this: <a href="https://www.twilio.com/docs/guides/sms-mms-messages-particle-photon#sign-into-or-sign-up-for-a-twilio-account" rel="noopener" target="_blank">https://www.twilio.com/docs/guides/sms-mms-messages-particle-photon#sign-into-or-sign-up-for-a-twilio-account</a>, specifically following this sub-section: <a href="https://www.twilio.com/docs/guides/sms-mms-messages-particle-photon#example-1-a-simple-example-of-sending-smses-with-a-particle-photon" rel="noopener" target="_blank">https://www.twilio.com/docs/guides/sms-mms-messages-particle-photon#example-1-a-simple-example-of-sending-smses-with-a-particle-photon</a> (the "Set Up a Particle Webhook" part, and noting that the "Event Name" should be "Alert").  
5.) That's it -- you now have a method to "Alert" to external services. Generally, look for the REST POST URL, and either place it in your "WEBHOOK BUILDER" section, or into the JSON template I provided above.