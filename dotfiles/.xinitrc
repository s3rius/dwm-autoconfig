#!/bin/bash

[ -f ~/.xprofile ] && . ~/.xprofile

eval "$(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)"
export SSH_AUTH_SOCK

while true; do
 battery_percent="$(acpi -b | cut -d '%' -f1 | tr ' ' '\n' | tail -n1)"
 xsetroot -name "| $(date +"%d-%m-%Y | %A %R") |   ${battery_percent}% |"
 sleep 2s
done &

while true; do
    wmname LG3D
    dwm >/dev/null 2>&1
done
