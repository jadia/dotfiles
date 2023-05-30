#!/bin/bash

# Function to check the current DPMS status
check_dpms_status() {
  xset -q | grep "DPMS is" | awk '{print $3}'
}

# Toggle DPMS mode
toggle_dpms() {
  current_status=$(check_dpms_status)

  if [ "$current_status" == "Enabled" ]; then
    xset s off -dpms
    notify-send "Toggle: DPMS disabled now." -t 1500 -u critical
  else
    xset s on +dpms
    notify-send "Toggle: DPMS enabled now." -t 1500 -u critical
  fi
}

# Print DPMS status
print_dpms_status() {
  current_status=$(check_dpms_status)
  notify-send "Status: DPMS is $current_status." -t 3000 -u normal
}

# Check if --status parameter is provided
if [ "$1" == "--status" ]; then
  print_dpms_status
else
  toggle_dpms
fi

