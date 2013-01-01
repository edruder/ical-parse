## ical-parse ##
ical-parse is a simple Ruby script I wrote to parse an .ics calendar exported from iCal.

I had an iCal calendar that was orphaned (since Apple terminated MobileMe) and I wanted to import
it into Google Calendar. When I tried to export/import it, Google's standard import mechanism had
trouble creating most/all of my events (I only cared about the birthday/annually recurring events).

This code sucks up an .ics file into a Ruby hash, making it easy to examine/manipulate. As-is, it's
just a tool to help you analyze an .ics file--it doesn't do anything with it. However, there is a
way to pass an output filename to the script--by default, this code writes every line to the
output file.

I found out that Google's importer had trouble with the "EXDATE;VALUE" rows in the .ics file, so
the code throws out all but the most-recent row before returning the calendar hash. I also noticed
a bunch of annual events in my calendar that had termination dates that I didn't want, so this
script removes all of them

### Usage ###

    ./ical-parse.rb cal.ics newcal.ics

### License ###
Copyright (c) 2012 Edward G. Ruder
https://twitter.com/ed_ruder
%w(ed ruders.org) * "@" || %w(ed squareup.com) * "@"

Released under the MIT/X11 license license. See LICENSE file for details.
