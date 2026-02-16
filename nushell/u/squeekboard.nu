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

def is_running_dbus []: nothing -> bool {
    try {
        ^busctl get-property --user sm.puri.OSK0 /sm/puri/OSK0 sm.puri.OSK0 Visible
        true
    } catch {
        false
    }
}

export def main [visible?: string] {

	print (is_running_dbus)
	if not (is_running_dbus) {
		print "Squeekboard DBus service not running, starting Squeekboard..."
		job spawn {squeekboard}
	}

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
        "kill" => {
			print "Killing Squeekboard"
            set_visible false
			^killall squeekboard
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
