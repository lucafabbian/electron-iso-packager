#!/bin/bash

# Create default rom used as the base system of electron-iso-packager


DIR=`dirname $(readlink -f $0)`  # Script path

bash "$DIR/remaster.sh" Xorg-7.7 openbox aterm nss gdk-pixbuf2 gtk3 libasound libcups libxkbcommon