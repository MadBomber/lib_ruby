
One of the simpliest ways to get an IseMessage into a web application
may be to use a POST event from inside a normal IseModel.  This is
something that can be easily tested using the rest_client GEM.

This directory contains a generic web application (web_app.rb) which
uses the sinatra framework.  Some of the things to be demonstrated are:

1) is it possible - preety sure it is
2) how fast can an IseModel push a web_app before the user interface response time degrades

Experiment results:  Works nicely!

Added some service stuff using the avahi command line tools.  Couldn't
the DNSSD gem to work as expected but the avahi CLI did just fine.

Having a problem with the WebApp.  Once the systemu has launched the
avahi-publish CLI into the background, the pid returned by systemu
is not the pid of the avahi-publish task.  It was the pid of the fork of
the main ruby process to invoke the command line.

===================================

Getting to complex to meet the current deadline for AADSE.

In the IseJob for the AadseSimulation we will have two command line parameters on the
IseMessage "pusher" mode.  The first parameter will be the name of the system environment
variable to use to get the URL for the web app.  The second parameter will be a
command seperated IseMessage name list for those messages to which the web app will be
subscribed.

