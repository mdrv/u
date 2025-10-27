#!/bin/nu

def main [] {
	if $env.HOSTNAME == "x86sp7-alx" {
		hyprctl keyword monitor eDP-1,1368x912,auto,1
	}
}
