#!/bin/bash
RSYNC_REMOTE_DIR=rsync://carroll.cac.psu.edu/fedora-linux-updates/
#RSYNC_REMOTE_DIR=rsync://mirrors.yocum.org/fedora/updates/
#RSYNC_REMOTE_DIR=rsync://mirrors.kernel.org/fedora/updates/
RSYNC_LOCAL_DIR=/limbus/centos/fedora/updates
RSYNC_COMMAND="rsync --recursive --times --links --hard-links --delete --delete-excluded -v --progress"

#This should find the most recent version
CURRENT_RELEASE=`rsync --list-only --no-motd $RSYNC_REMOTE_DIR | awk '{ print $5 }' | egrep -o "[0-9]+" | sort -gr | head -n1`
NO_OF_RELEASES_TO_KEEP=2
EXCLUDE_LIST=""

# Exclude all older versions of Fedora
LAST_RELEASE=`expr $CURRENT_RELEASE - $NO_OF_RELEASES_TO_KEEP`
for ver in `seq 1 $LAST_RELEASE`; do
   EXCLUDE_LIST="$EXCLUDE_LIST --exclude $ver"
done

$RSYNC_COMMAND $EXCLUDE_LIST $RSYNC_REMOTE_DIR $RSYNC_LOCAL_DIR

find $RSYNC_LOCAL_DIR -type d -exec chmod 755 '{}' \;
