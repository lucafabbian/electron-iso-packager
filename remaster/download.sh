#!/bin/bash
# Script to download an extension and its dependencies written by Richard A. Rost July 7,2019
# The script downloads to the directory you are in when you start the script.
# There are no Tinycore specific commands, variables, or directories required so it should work
# on any Linux box.
# Some error checking is done, though it might not be as thorough as it should be.
# The script downloads the  .tcz,  .tcz.dep,  and  .tcz.md5.txt  files for each extension.
# MD5 is verified.
# File ownership is changed to tc:staff.
# A running timestamped log is kept in  ./Log.txt
# ./Extension.list  is a sorted  .tree  file with duplicates removed of the last extension downloaded.
#
# Usage:
#
#	FetchExt.sh ExtensionName	Fetches the extension and its dependencies. ExtensionName is
#					case sensitive and should NOT include the  .tcz  extension.
#
#	FetchExt.sh info		Fetches the list of available extensions in the listed repository.
#

# Repository to download from
ADDR="http://repo.tinycorelinux.net"

# Tinycore version
TC="11.x"

# Processor architecture, current options are  x86  x86_64  armv6  armv7
ARCH="x86"

# This is where the extensions get downloaded from.
URL="$ADDR/$TC/$ARCH/tcz/"

EXT="$1"
TYPE=".tcz.tree"
if [ "$EXT" == "info" ]
then
	TYPE=".lst"
fi

FILE=""

# This is a running log of all downloads
LOG="Log.txt"

# Remove previous copy of file if it exists so that  wget  doesn't create numbered backups.
rm -rf "$EXT$TYPE"

TREE="$URL$EXT$TYPE"
wget -q "$TREE" > /dev/null 2>&1
if [ "$?" != "0" ]
then
	wget -q --spider "$URL$EXT.tcz" > /dev/null 2>&1	# No .tcz.tree found, check for .tcz
	if [ "$?" == "0" ]
	then	# Extension exists but has no dependencies so create a tree file.
	echo -e "$EXT.tcz\n" > "$EXT.tcz.tree"
	else
		echo "$TREE  not found."
		exit 1
	fi
fi

if [ "$EXT$TYPE" == "info.lst" ]
then	# Dispaly the  info.lst  file in a terminal using the  less  command.
	xterm +tr +sb -T "info.lst" -e less info.lst &
	exit 0
fi

# awk '$1=$1' removes all whitespaces, sort -u sorts alphabetically and removes duplicate entries.
awk '$1=$1' "$EXT$TYPE" | sort -u > Extension.list
rm -rf "$EXT$TYPE"

# Update the log file with a newline, timestamp, a newline, and the name of the extension being processed.
echo -e "\n`date`\nProcessing $TREE" >> $LOG

for FILE in `cat Extension.list`
do
	if [ -f "$FILE" ]
	then
		echo "$FILE already downloaded." >> $LOG
		continue
	fi

	# Fetch extension
	wget -q "$URL$FILE" > /dev/null 2>&1
	if [ "$?" != "0" ]
	then
		echo "$FILE download failed." >> $LOG
	else
		echo "$FILE downloaded." >> $LOG
		# Change ownership. Numeric values used because foreign Linux box won't have tc:staff.
		chown 1001:50 "$FILE"
	fi

	# Fetch MD5
	wget -q "$URL$FILE.md5.txt" > /dev/null 2>&1
	if [ "$?" != "0" ]
	then
		echo "$FILE.md5.txt download failed." >> $LOG
	else
		echo "$FILE.md5.txt downloaded." >> $LOG
		# Change ownership. Numeric values used because foreign Linux box won't have tc:staff.
		chown 1001:50 "$FILE.md5.txt"
	fi

	# Fetch dependency file
	wget -q "$URL$FILE.dep" > /dev/null 2>&1
	if [ "$?" == "0" ]
	then
		echo "$FILE.dep downloaded." >> $LOG
		# Change ownership. Numeric values used because foreign Linux box won't have tc:staff.
		chown 1001:50 "$FILE.dep"
	fi

	# Verify MD%
	md5sum -c "$FILE.md5.txt"
	if [ "$?" != "0" ]
	then
		echo "$FILE md5 checksum failed." >> $LOG
	fi

done

exit 0
