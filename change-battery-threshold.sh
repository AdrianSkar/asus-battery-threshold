#!/bin/bash

# Check if the charge threshold value is provided as an argument
if [ -z "\$1" ]; then
    echo "Usage: \$0 <charge_threshold>"
    exit 1
fi

# Store the charge threshold value in a variable
charge_threshold=$1

# Update the charge threshold value in the battery-charge-threshold.service file
sudo sed -i "s|ExecStart=.*|ExecStart=/bin/bash -c 'echo $charge_threshold > /sys/class/power_supply/BATT/charge_control_end_threshold'|" /etc/systemd/system/battery-charge-threshold.service

# Reload the systemd daemon
sudo systemctl daemon-reload

# Restart the service
sudo systemctl restart battery-charge-threshold.service

echo "Charge threshold updated to $charge_threshold"
