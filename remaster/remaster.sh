#!/bin/bash

# remaster.sh v 1.0.0
# Feel free to edit it!
# Tinycore remaster guide: http://wiki.tinycorelinux.net/wiki:remastering

# Author: luca fabbian <luca.fabbian.1999@gmail.com>
# License: MIT

# Usage message and error check
USAGE="Usage: remaster.sh <list-of-packages>
    It will create a 'output.iso' in this folder with those packages included
    ROOT USER REQUIRED!

Examples:
    # Install a minimal desktop environment and terminal
    sudo bash remaster.sh openbox aterm
"

if [[ $EUID -ne 0 ]]; then
   echo "$USAGE"
   echo -e "\033[0;31mERROR: this script must be run as root!\033[0m
    "
   exit 1
fi


ISO_MIRROR="http://www.tinycorelinux.net/12.x/x86/release/Core-current.iso"

# Retrieve script real path and store current path
DIR=`dirname $(readlink -f $0)`  # Script path
ISO_FILE="$DIR/core.iso"         # Iso file
CURRENTDIR=$PWD                  # Current path
cd "$DIR"



echo "Running script"
echo "1/4    -> Downloading iso...
"
rm -fr extract
rm -fr iso_src
wget "$ISO_MIRROR" -O core.iso


echo "
2/4    -> Extracting iso files...
"
mkdir /mnt/tmp-electron-iso
mount "$ISO_FILE" /mnt/tmp-electron-iso -o loop,ro

mkdir -p "iso_src"
cp -r /mnt/tmp-electron-iso/* ./iso_src/
rm -f ./iso_src/boot/core.gz

mkdir -p "extract"
cd "$DIR/extract"
zcat /mnt/tmp-electron-iso/boot/core.gz | sudo cpio -i -H newc -d
umount /mnt/tmp-electron-iso
rm -r /mnt/tmp-electron-iso


# Downloading extensions and compress
echo "
3/4    -> Downloading extensions...
"
mkdir -p "tmp/builtin/optional"
cd "tmp/builtin/optional"
for extension in "$@"
do
    bash "../../../../download.sh" "$extension"
    echo "$extension.tcz" >> "../onboot.lst"
done

cd "../../../"

find | cpio -o -H newc | gzip -2 > ../iso_src/boot/core.gz
cd ..
# Create iso file
echo "
4/4    -> Creating iso...
"
mkisofs -l -J -R -V "$APPNAME" -no-emul-boot -boot-load-size 4 \
 -boot-info-table -b boot/isolinux/isolinux.bin \
 -c boot/isolinux/boot.cat -o output.iso iso_src
# Clear again
rm -rf "$DIR/extract"
rm -rf "$DIR/iso_src"
# Move output to the folder where the script has been called

echo "
...done! Iso file saved as $DIR/output.iso"
