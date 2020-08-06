#!/bin/bash

[ -f ~/.xprofile ] && . ~/.xprofile

eval "$(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)"
export SSH_AUTH_SOCK

while true; do
 xsetroot -name "$( date +"%e %B (%d-%m-%Y) %A %R")"
 sleep 2s
done &

while true; do
    wmname LG3D
    dwm >/dev/null 2>&1
done
