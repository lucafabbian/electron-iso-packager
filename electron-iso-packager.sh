#!/bin/bash

# electron-iso-packager v 1.0.0
# Feel free to edit it!
# Tinycore remaster guide: http://wiki.tinycorelinux.net/wiki:remastering

# Author: luca fabbian <luca.fabbian.1999@gmail.com>
# License: MIT


# Usage message and error check
USAGE="Usage: electron-iso-packager <sourcedir> <appname> [postscript]
    sourcedir      the base directory of the application source
    appname        the name of the app

Examples:
    electron-iso-packager ./ MyApp
    electron-iso-packager ./ MyApp \"read -n 1\" # Wait keypress before packaging iso
"
if test "$#" -lt 2; then
    echo "$USAGE"
    echo -e "\033[0;31mERROR: illegal number of parameters (2 required, $# passed)\033[0m
    "
    exit 1
fi



# Params parsing
APPDIR=`realpath $(readlink -f $1)`   # Electron app dir
APPNAME=$2                            # Iso name and label
POSTSCRIPT=$3                         # Script called before building


# Retrieve script real path and store current path
DIR=`dirname $(readlink -f $0)`  # Script path
ISO_FILE="$DIR/core.iso"         # Iso file
CURRENTDIR="$PWD"                # Current path
MAINDIR="$APPDIR/electron-iso"
FILESDIR="$MAINDIR/files/home/tc/"

echo "Running electron-iso-packager"
echo "1/5    -> Preparing build...
"
# Clear (if something has gone wrong previously)
rm -rf "$MAINDIR"
rm -rf "$CURRENTDIR/$APPNAME.iso"
mkdir -p "$FILESDIR"
mkdir -p "$MAINDIR/iso"


# Package app thanks to electron-packager
electron-packager "$APPDIR" --platform=linux --arch=ia32 electron-iso-app
mv "$APPDIR/electron-iso-app-linux-ia32" "$FILESDIR/app"
cp "$DIR/iso_scripts/autostart.sh" "$FILESDIR/app"
cp "$DIR/iso_scripts/xsession" "$FILESDIR/.xsession"

# Unpackage iso file
echo "
2/5    -> Extracting iso files...
"
cd "$MAINDIR/iso"
7z -y x "$ISO_FILE"


echo "
3/5    -> Executing postscript (if specified)...
"
eval "$POSTSCRIPT"

# Move packaged app inside iso rootfs and compress
echo "
4/5    -> Compressing files...
"

cd "$MAINDIR/files"
chmod -R 777 *
find ./  | cpio -H newc -o | gzip >> ../iso/boot/core.gz

cd ..
# Create iso file
echo "
5/5    -> Creating iso...
"
genisoimage -l -J -R -V "$APPNAME" -no-emul-boot -boot-load-size 4 \
 -boot-info-table -b boot/isolinux/isolinux.bin \
 -c boot/isolinux/boot.cat -o output.iso iso

# Move output to the folder where the script has been called
mv output.iso "$CURRENTDIR/$APPNAME.iso"

# Clear again
rm -rf "$MAINDIR"

echo "
...done! Iso file saved as $CURRENTDIR/$APPNAME.iso"
