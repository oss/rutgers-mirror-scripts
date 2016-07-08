#!/bin/bash
#RSYNC_REMOTE_DIR=rsync://carroll.cac.psu.edu/fedora-linux-releases/
#RSYNC_REMOTE_DIR=rsync://mirrors.yocum.org/fedora/releases/
RSYNC_REMOTE_DIR=rsync://mirrors.kernel.org/fedora/releases/
RSYNC_LOCAL_DIR=/limbus/centos/fedora/releases
RSYNC_COMMAND="rsync --recursive --times --links --hard-links --delete --delete-excluded -v --progress"

# this should grab the most recent version
CURRENT_RELEASE=`rsync --list-only --no-motd $RSYNC_REMOTE_DIR 2> /dev/null | awk '{ print $5 }' | egrep -o "[0-9]+" | sort -gr | head -n1`
NO_OF_RELEASES_TO_KEEP=2
# What do we not want in our mirror
# test: alpha beta pre-releases of Fedora
# *disc*.iso: CD full installation images
EXCLUDE_LIST="--exclude test --exclude *disc*.iso"

# Exclude all older versions of Fedora
LAST_RELEASE=`expr $CURRENT_RELEASE - $NO_OF_RELEASES_TO_KEEP`
for ver in `seq 1 $LAST_RELEASE`; do
   EXCLUDE_LIST="$EXCLUDE_LIST --exclude $ver"
done

$RSYNC_COMMAND $EXCLUDE_LIST $RSYNC_REMOTE_DIR $RSYNC_LOCAL_DIR

find $RSYNC_LOCAL_DIR -type d -exec chmod 755 '{}' \;
