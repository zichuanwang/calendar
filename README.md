Calendar App for Accompli Interview
====================

Brief Introduction
--------------------

This system is constituted by two major components. A standard Ruby on Rails app handles requests, and a daemon server that syncs google calendars for users. Client side app uses WebSocket to keep connection with the server.

![alt tag](https://raw.github.com/zichuanwang/calendar/master/showcase.png)


Deployment Guidelines
--------------------

* Start Server
    Run <code>rails server</code>. You can also use Nginx + Phusion Passenger or Unicorn if you want, but it's enough to test it in a standard development server.
* Start Deamon
    Run <code>rails server -e daemon -p 4000 -P ./tmp/pids/daemon.pid</code>. This is for 
* Start WebSocket Server
    Run <code>rake websocket_rails:start_server</code> to start a standalone WebSocket server. Run <code>rake websocket_rails:stop_server</code> it. **Note that this standalone server requires an active Redis server to enable publishing channel events to the WebSocket server from anywhere in your application.**

FINISHED REQUIREMENTS
--------------------

* Read your primary calendar from Google Calendar and render it on FullCalendar

* Read multiple calendars from Google Calendar, and render all of them on FullCalendar with the corresponding calendar color used in Google Calendar

* Support toggling any of these calendars on or off in FullCalendar

* Add real-time support to your FullCalendar app, so that events created on Google Calendar appear in FullCalendar in real-time, without requiring a page reload

TO DO
--------------------

* Support creating events via FullCalendar and persisting them to Google Calendar

* Handle 401 Gone Google API Response

* Handle Timezone

Composed by Zichuan Wang (zichuanw@usc.edu)

Last Updated: 01/11/2015