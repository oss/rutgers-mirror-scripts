#!/bin/bash
RSYNC_REMOTE_DIR=rsync://download1.rpmfusion.org/rpmfusion/nonfree/fedora/
RSYNC_LOCAL_DIR=/limbus/centos/fedora/rpmfusion/nonfree/
RSYNC_COMMAND="rsync --recursive --times --links --hard-links --delete --delete-excluded -v --progress"

# This should grab the latest version
CURRENT_RELEASE=`rsync --list-only --no-motd $RSYNC_REMOTE_DIR/releases/ 2> /dev/null | awk '{ print $5 }' | egrep -o "[0-9]+" | sort -gr | head -n1`
NO_OF_RELEASES_TO_KEEP=2
EXCLUDE_LIST="--exclude development"

# Exclude all older versions of Fedora
LAST_RELEASE=`expr $CURRENT_RELEASE - $NO_OF_RELEASES_TO_KEEP`
for ver in `seq 1 $LAST_RELEASE`; do
   EXCLUDE_LIST="$EXCLUDE_LIST --exclude $ver"
done

$RSYNC_COMMAND $EXCLUDE_LIST $RSYNC_REMOTE_DIR $RSYNC_LOCAL_DIR

find $RSYNC_LOCAL_DIR -type d -exec chmod 755 '{}' \;
