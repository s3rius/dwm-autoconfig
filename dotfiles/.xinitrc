while true; do
 xsetroot -name "$( date +"%F %R")"
 sleep 2s
done &

nitrogen --restore
picom --config ~/.picom.conf -b

while true; do
    dwm >/dev/null 2>&1
done
