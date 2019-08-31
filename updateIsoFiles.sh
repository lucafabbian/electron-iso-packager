#!/bin/bash

# update-iso-files v 1.0.0
# Feel free to edit it!
# Tinycore remaster guide: http://wiki.tinycorelinux.net/wiki:remastering

# Usage message and error check
USAGE="Usage: ./updateIsoFiles.sh <isofile>
    isofile      the remastered iso you want to use
    ROOT USER REQUIRED!
"
if test "$#" -ne 1; then
    echo "$USAGE"
    echo "ERROR: illegal number of parameters (1 expected, $# passed)"
    exit 1
fi
if [[ $EUID -ne 0 ]]; then
   echo "$USAGE"
   echo "ERROR: this script must be run as root!"
   exit 1
fi


# Params parsing
ISOFILE=$1        # Electron app dir

# Retrieve script real path and store current path
DIR=`dirname $(readlink -f $0)`  # Script path
KIOSKDIR="$DIR/extract/home/tc"  # Subdir
CURRENTDIR=$PWD                  # Current path

"Extracting files from iso..."
# Clear (if something has gone wrong previously)
rm -rf "$DIR/extract"

mkdir /mnt/tmp-electron-iso
mount "$1" /mnt/tmp-electron-iso -o loop,ro
mkdir -p "$KIOSKDIR"
cd "$DIR/extract"

zcat /mnt/tmp-electron-iso/boot/core.gz | sudo cpio -i -H newc -d
cp ../xsession ./home/tc/.xsession
umount /mnt/tmp-electron-iso
rm -r /mnt/tmp-electron-iso

echo "
...done! Files have been replaced"
