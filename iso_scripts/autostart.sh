#!/bin/sh

# Autostart electron-app
/home/tc/app/electron-iso-app --no-sandbox --use-gl=swiftshader &

# Default tinycore desktop .xsession
"$DESKTOP" 2>/tmp/wm_errors &
export WM_PID=$!
hsetroot -add "#0E5CA8" -add "#87C6C9" -gradient 0 -center /usr/local/share/pixmaps/logo.png # Change to set custom background
[ -x $HOME/.mouse_config ] && $HOME/.mouse_config &
[ $(which "$ICONS".sh) ] && ${ICONS}.sh &
[ -d "/usr/local/etc/X.d" ] && find "/usr/local/etc/X.d" -type f -o -type l -print | while read F; do . "$F"; done
[ -d "$HOME/.X.d" ] && find "$HOME/.X.d" -type f -print | while read F; do . "$F"; done
