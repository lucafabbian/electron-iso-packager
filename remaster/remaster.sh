#!/bin/bash

# remaster.sh v 1.0.0
# Feel free to edit it!
# Tinycore remaster guide: http://wiki.tinycorelinux.net/wiki:remastering

# Author: luca fabbian <luca.fabbian.1999@gmail.com>
# License: MIT

# Usage message and error check
USAGE="Usage: remaster.sh <list-of-packages>
    It will create a 'output.iso' in this folder with those packages included

Examples:
    # Install a minimal desktop environment and terminal
    bash remaster.sh openbox aterm
"


ISO_MIRROR="http://www.tinycorelinux.net/13.x/x86/release/Core-current.iso"

# Retrieve script real path and store current path
DIR=`dirname $(readlink -f $0)`  # Script path
CURRENTDIR="$PWD"                # Current path
MAINDIR="$CURRENTDIR/electron-iso-remaster"
FILESDIR="$MAINDIR/files/tmp/builtin/optional"
ISO_FILE="$MAINDIR/core.iso"     # Iso file




echo "Running script"
echo "1/4    -> Downloading iso...
"
rm -fr "$MAINDIR"
rm -fr "$CURRENTDIR/output.iso"

mkdir -p "$FILESDIR"
mkdir -p "$MAINDIR/iso"


cd "$MAINDIR"

wget "$ISO_MIRROR" -O core.iso



echo "
2/4    -> Extracting iso files...
"
cd "$MAINDIR/iso"
7z -y x "$ISO_FILE"


# Downloading extensions and compress
echo "
3/4    -> Downloading extensions...
"

cd "$FILESDIR"
for extension in "$@"
do
    bash "$DIR/download.sh" "$extension"
    echo "$extension.tcz" >> "../onboot.lst"
done


cd "$MAINDIR/files"
chmod -R 777 *
find ./  | cpio -H newc -o | gzip >> ../iso/boot/core.gz


cd ..
# Create iso file
echo "
4/4    -> Creating iso...
"
mkisofs -l -J -R -V "Remastered Core" -no-emul-boot -boot-load-size 4 \
 -boot-info-table -b boot/isolinux/isolinux.bin \
 -c boot/isolinux/boot.cat -o output.iso iso

# Move output to the folder where the script has been called
mv output.iso "$CURRENTDIR/output.iso"

# Clear again
rm -rf "$MAINDIR"

echo "
...done! Iso file saved as $CURRENTDIR/output.iso"
