#!/bin/nu

def main [] {
	if $env.HOSTNAME == "x86sp7-alx" {
		hyprctl keyword monitor eDP-1,1368x912,0x0,1
		# hyprctl keyword monitor eDP-1,auto,auto,1
		# hyprctl keyword monitor eDP-1,800x600,0x0,1
		hyprctl keyword monitor DP-1,1366x768,auto,1,mirror,eDP-1 # Surface Pro 7 specific
	}
}
