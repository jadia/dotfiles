#!/bin/bash
#
# wifi_toggle.sh
#
# This script monitors the Ethernet connection and enables or disables Wi-Fi
# accordingly. It is designed to be run as a cron job.
#

# --- Configuration ---
ETH_DEVICE="enx089204c53ee3"
WIFI_DEVICE="wlp43s0"
LOG_FILE="/tmp/wifi_toggle.log"

# This is required for notify-send to work from cron.
# To find the correct value, run this in your terminal: echo $DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"

log() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ${message}" >> "$LOG_FILE"
}

device_exists() {
    local device="$1"
    nmcli -t -f DEVICE device status | grep -Fxq "$device"
}

# --- Pre-flight Check ---
# Ensure nmcli is available
if ! command -v nmcli &> /dev/null; then
    log "Error: nmcli command not found. Please install NetworkManager."
    exit 1
fi

# Ensure expected devices are present before proceeding.
if ! device_exists "$ETH_DEVICE"; then
    log "Ethernet adapter ($ETH_DEVICE) not found. Likely undocked. Exiting without changes."
    exit 0
fi

if ! device_exists "$WIFI_DEVICE"; then
    log "Wi-Fi adapter ($WIFI_DEVICE) not found. Exiting without changes."
    exit 1
fi

# --- Main Logic ---

# Check if the Ethernet device is connected.
# We use a more robust check that is not sensitive to whitespace.
if nmcli device show "$ETH_DEVICE" | grep "GENERAL.STATE" | grep -q "(connected)"; then
    # --- Ethernet is CONNECTED ---
    # If the Wi-Fi device is connected, disconnect it.
    if nmcli device show "$WIFI_DEVICE" | grep "GENERAL.STATE" | grep -q "(connected)"; then
        log "Ethernet connected. Disconnecting Wi-Fi device ($WIFI_DEVICE)."
        sudo nmcli device disconnect "$WIFI_DEVICE"
        notify-send "Wi-Fi Disconnected" "Ethernet is connected." -t 10000 -u low
    else
        log "Ethernet connected. Wi-Fi device ($WIFI_DEVICE) already disconnected."
    fi
else
    # --- Ethernet is DISCONNECTED ---
    # If the Wi-Fi device is not connected, connect it.
    # We use `!` to negate the result of the grep command.
    if ! nmcli device show "$WIFI_DEVICE" | grep "GENERAL.STATE" | grep -q "(connected)"; then
        log "Ethernet disconnected. Connecting Wi-Fi device ($WIFI_DEVICE)."
        sudo nmcli device connect "$WIFI_DEVICE"
        notify-send "Wi-Fi Connected" "Ethernet is disconnected." -t 10000 -u low
    else
        log "Ethernet disconnected. Wi-Fi device ($WIFI_DEVICE) already connected."
    fi
fi

exit 0
