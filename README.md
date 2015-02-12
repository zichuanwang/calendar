Calendar App for Accompli Interview
====================

Brief Introduction
--------------------

This system is constituted by two major components. A standard Ruby on Rails app handling requests, and a daemon server syncing google calendars for users. Client side app uses WebSocket to keep connection with the server.

*In the original design, the daemon server runs in background so the standard Ruby on Rails app can run on top of Non-eventmachine based frameworks like Phusion Passenger or Unicorn. However, this requires the WebSocket server to be in standalone mode. When trying this approach, some thread related bug related to websocket-rails gem popped up. I will create an issue for this. To make a hot fix, I decided to run the calendar syncing code within the standard RoR app.*

Visit <code>http://localhost:3000</code> to test.

![alt tag](https://raw.github.com/zichuanwang/calendar/master/showcase.png)

Deployment Guidelines
--------------------

* Start Server
    Simply <code>rails server</code>.

FINISHED REQUIREMENTS
--------------------

* Read your primary calendar from Google Calendar and render it on FullCalendar

* Read multiple calendars from Google Calendar, and render all of them on FullCalendar with the corresponding calendar color used in Google Calendar

* Support toggling any of these calendars on or off in FullCalendar

* Add real-time support to your FullCalendar app, so that events created on Google Calendar appear in FullCalendar in real-time, without requiring a page reload

TO DO
--------------------

* Support creating events via FullCalendar and persisting them to Google Calendar

* Handle 401 Gone Google API response

* Handle timezone

* Handle access token expire

* Support events removal

Composed by Zichuan Wang (zichuanw@usc.edu)

Last Updated: 01/11/2015