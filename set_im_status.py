#!/usr/local/bin/python

import sys
import dbus #gobject
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GObject as gobject

dbus_loop = DBusGMainLoop()

bus = dbus.SessionBus(mainloop=dbus_loop)
dbus_obj = bus.get_object("im.pidgin.purple.PurpleService", "/im/pidgin/purple/PurpleObject")
purple = dbus.Interface(dbus_obj, "im.pidgin.purple.PurpleInterface")

status = sys.argv[1]

# Available
if status == "a":
    status_id = dbus.String(u'available')

# Busy
elif status == "b":
    status_id = dbus.String(u'unavailable')

# Away
elif status == "w":    
    status_id = dbus.String(u'away')

# Invisible
elif status == "i":
    status_id = dbus.String(u'invisible')

# Offline
elif status == "f":
    status_id = dbus.String(u'offline')

else:
    status_id = dbus.String(u'available')

status_type = purple.PurplePrimitiveGetTypeFromId(status_id)
saved = purple.PurpleSavedstatusNew("", status_type)
purple.PurpleSavedstatusActivate(saved) 
