---
layout: default
author: sam
synopsis: How a hardware hacked Teensy microcontroller and vacation light timer makes our continuous integration awesome.
published: false
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
a USB, and toggle built in LED on or off with shell commands like this:

    echo "d6=1" > /dev/cu.usbmodem12341
    echo "d6=0" > /dev/cu.usbmodem12341

Progress.

Now that I could control the Teensy's LED programmatically, the next challenge
was hooking it up to the big red light.  Matt Youell had done electrical work in
the past.  Apparently powering a tiny LED is dramatically different from running
a 120V light, which opens the risk of frying your equipment, fires, and fire
marshals.  Despite this Matt offered to help.  He knew we'd need some type of
relay.  He took the setup home, and came back a few days later with it wired to
vacation light timer he had running around.

![Vacation Light Timer](/images/IMG_0523.jpg)

For a while we were nervous we would break the build over the weekend and come
in Monday to a burned down office but it's been working great.

The last step was getting the whole rig hooked up to our CI server.  We use
[CruiseControl.rb](https://github.com/thoughtworks/cruisecontrol.rb) to run our
builds. I wrote a simple bash script that hits the server and toggles the pin 6
(the light) on the Teensy based on the response.  It looks something like this:

    #!/bin/sh

    # Insert current script here

The complete setup looks a little like this:

![Build Indicator Setup](/images/IMG_0536.jpg)

Why It's Awesome
--

Having this set up has been a big win for our team.  It makes it even more
obvious when someone has broken the build, and decrease the amount of focus we
need to devote to monitoring the CI server. It's an in-your-face "don't deploy
now" indicator which is great for a team that typically pushes code to
production several times per day.

More importantly though, it's created a sense of awareness for non-developers of
how continuous integration works and why it's important.  Now they know when the
build is broken as soon as we do. They know we're running tests, and that the
tests control the light.  They're important, and they help us developers, and
the whole company be more agile.

<iframe title="YouTube video player" width="640" height="390" src="http://www.youtube.com/embed/Sdsd2HwsfHs" frameborder="0" >
</iframe>


