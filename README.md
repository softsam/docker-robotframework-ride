# RIDE in docker
Run RIDE and write your tests for Robot Framework without ever installing anything.

## Built with
- latest ubuntu
- python-wxgtk2.8

## Embedded robotframework libraries
- robotframework 3.0
- robotframework-request 0.4.5
- robotframework-ride 1.5.2.1

## Running on Linux
Run the following command:

> docker run --rm -e DISPLAY=$DISPLAY -v /home/myuser/robot:/robot softsam/robotframework-ride

Your tests will be mounted on the /robot directory, and you can load them in RIDE then.

## Running on Windows
Run a Linux VM with an X client, and see how to run in Linux

## Running on Mac OS

Since Mac OS no longer has an X client, you will need to install some tools first:
- Install [XQuartz](https://www.xquartz.org)
- Also install socat:
> brew install socat

Then, start socat:
> socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\\"$DISPLAY\\"

And XQuartz:
> open -a XQuartz

Make sure network connections are allowed in the security section of XQuartz preferences.

Then get your IP address. You may use the following command:
> ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}'

And finally, run the image (using your IP):
> docker run --rm -e DISPLAY=$MY_IP:0 -v /home/myuser/robot:/robot softsam/robotframework-ride
