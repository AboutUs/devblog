---
layout: default
author: sam
synopsis: How a hardware hacked Teensy microcontroller and vacation light timer makes our continuous integration awesome.
---

Continuous Integration is a pretty important part of any agile workflow.  Having
your ci server run your test suite whenever anyone pushes code means never
having to argue about who broke the build.

A couple months ago we took it a step further.  Instead of just having the CI
server send an email when the build breaks, we have a big red light in our
office which starts flashing.

The ingredients:
--

1. A big red flashing light I found a Goodwill
1. A [Teensy 2.0 microcontroller](http://www.pjrc.com/teensy/) donated by Ward Cunningham
1. A vacation light timer, hacked by Matt Youell
1. A mac mini, running bash and curl


How we made it work:
--

On my way back into Portland one weekend I stopped at the Goodwill and spotted a
red light on a shelf with wires hanging out of it.  I ponied up the $6.99 to buy
it, having no idea if it actually functioned.  I took it home and proceeded to
test it.

<iframe title="YouTube video player" width="480" height="390" src="http://www.youtube.com/embed/hwKzYv9IekI" frameborder="0" >
</iframe>
<br/>
<br/>

Realizing this would be the perfect addition to our CI setup, I enlisted to help
of active [DorkBotPDXer](http://dorkbotpdx.org/) Ward Cunningham.  He gave me a
Teensy 2.0 that he'd gotten from Teensy creator Paul Stoffregen.  He also
talked me into going to the next DorkBot meetup, to get some help using it.

![teensy 2.0](/images/IMG_0537.jpg)

I went to the meetup and sat down with Paul to get some help with the Teensy.  I
flashed his [USB Serial](http://www.pjrc.com/teensy/usb_serial.html) shell onto
the microcontroller. With this code installed on the Teensy I could plug it into
a USB, and toggle the built in LED on or off with shell commands like this:

{% highlight bash %}
echo "d6=1" > /dev/cu.usbmodem12341
echo "d6=0" > /dev/cu.usbmodem12341
{% endhighlight %}

Progress.

Now that I could control the Teensy's LED programmatically, the next challenge
was hooking it up to the big red light.  Matt Youell had done electrical work in
the past.  Apparently powering a tiny LED is dramatically different from running
a 120V light, which opens the risk of frying your equipment, fires, and fire
marshals.  Despite this Matt offered to help.  He knew we'd need some type of
relay.  He took the setup home, and came back a few days later with it wired to
vacation light timer he had lying around.

![Vacation Light Timer](/images/IMG_0523.jpg)

For a while after he wired it we were nervous we would come in Monday morning to
a burned down office but it's been working great for months now.

The last step was getting the whole rig hooked up to our CI server.  We use
[CruiseControl.rb](https://github.com/thoughtworks/cruisecontrol.rb) to run our
builds. I wrote a simple bash script that hits the server and toggles the pin 6
(the light) on the Teensy based on the response.  It looks something like this:

{% highlight bash %}
#!/bin/sh
# Monitor cruisecontrol and trigger red light when there's a broken build.
# Also turn the light on when we don't get a 200 response from the server.

bad_requests=0
while [ true ]; do
 ci_url=http://ci.aboutus.com/XmlStatusReport.aspx
 response=`curl -i --max-time 5 -s -u user:pw $ci_url`

 # count how many times we've gotten a non-200 response from ci
 if [ `echo $response | grep 'HTTP/1.1 200 OK' | wc -l` -ne 1 ] ; then
   bad_requests=`expr $bad_requests + 1`
 else
   bad_requests=0
 fi

 # turn the light on when there's a build failure or we've had 3 consecutive
 # non-200 responses from the ci server.
 if [ `echo $response | grep 'lastBuildStatus="Failure"' | wc -l` -gt 0 ] \
      || [ $bad_requests -gt 2 ]; then
   (sleep 1; echo "d6=1") > /dev/cu.usbmodem12341
 else
   (sleep 1; echo "d6=0") > /dev/cu.usbmodem12341
 fi
done
{% endhighlight %}

I set this up as a startup item on our reception computer and bam!, we were
done.

The complete setup looks a little like this:

![Build Indicator Setup](/images/IMG_0536.jpg)

Why It's Awesome
--

Having this set up has been a big win for our team.  It makes it even more
obvious when someone has broken the build, and decrease the amount of focus we
need to devote to monitoring the CI server. It's an in-your-face "don't deploy
now" indicator which is great for a team that typically pushes code to
production several times per day.

It's also had the interesting effect of making the non-developers we work with
aware of how continuous integration works and why it's important.  Now they know
when the build is broken as soon as we do. They know we're running tests, and
that the test failures control the light; a big flashing red light never
means good.  Tests are important. They protect us and they help us developers,
and the whole company be more agile.

<iframe title="YouTube video player" width="640" height="390" src="http://www.youtube.com/embed/Sdsd2HwsfHs" frameborder="0" >
</iframe>


