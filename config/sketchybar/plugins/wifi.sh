#!/bin/zsh

NETWORKNAME="$(ipconfig getsummary "$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $NF}')" | grep ' SSID : ' | awk -F ': ' '{print $2}')"

sketchybar --set "$NAME" icon="" label="$NETWORKNAME"
