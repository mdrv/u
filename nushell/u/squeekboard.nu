#!/usr/bin/env -S nu
# ANNOTATION: Toggle Squeekboard on-screen keyboard visibility via DBus

const DBUS_SERVICE = "sm.puri.OSK0"
const DBUS_OBJECT = "/sm/puri/OSK0"
const DBUS_INTERFACE = "sm.puri.OSK0"

def is_visible []: nothing -> bool {
   let result = (busctl get-property --user $DBUS_SERVICE $DBUS_OBJECT $DBUS_INTERFACE Visible)
   # Output format: "b true" or "b false"
   # Extract the boolean value
   ($result | str replace 'b ' '' | into bool)
}

def set_visible [visible: bool] {
    # Call DBus method
    busctl call --user $DBUS_SERVICE $DBUS_OBJECT $DBUS_INTERFACE SetVisible b $visible
}

export def main [visible?: string] {
    match $visible {
        "true" => {
            print "Showing Squeekboard"
            set_visible true
        }
        "false" => {
            print "Hiding Squeekboard"
            set_visible false
        }
        "show" => {
            print "Showing Squeekboard"
            set_visible true
        }
        "hide" => {
            print "Hiding Squeekboard"
            set_visible false
        }
        _ => {
            # Default: toggle
            let $current = (is_visible)
            if $current {
                print "Hiding Squeekboard (was visible)"
                set_visible false
            } else {
                print "Showing Squeekboard (was hidden)"
                set_visible true
            }
        }
    }
}
