#!/bin/bash
RSYNC_REMOTE_DIR=rsync://mirrors.rit.edu/centos
RSYNC_LOCAL_DIR=/limbus/centos/centos
RSYNC_COMMAND="rsync --recursive --times --links --hard-links --delete -v --progress"

#This should grab the latest version
CURRENT_RELEASE=`rsync --no-motd $RSYNC_REMOTE_DIR 2> /dev/null | awk '{ print $5 }' | egrep -o "^[0-9]+" | sort -gr | head -n1`
NO_OF_RELEASES_TO_KEEP=2
INCLUDE_LIST="--include *x86_64*.iso --include *i386*.iso"
EXCLUDE_LIST="--exclude 6.2 --exclude debuginfo --exclude *.iso"

# Exclude all older versions of CentOS
LAST_RELEASE=`expr $CURRENT_RELEASE - $NO_OF_RELEASES_TO_KEEP`
for ver in `seq 1 $LAST_RELEASE`; do
   EXCLUDE_LIST="$EXCLUDE_LIST --exclude /${ver}* --exclude RPM-GPG-KEY-CentOS-${ver}"
done

$RSYNC_COMMAND $INCLUDE_LIST $EXCLUDE_LIST $RSYNC_REMOTE_DIR $RSYNC_LOCAL_DIR

find $RSYNC_LOCAL_DIR -type d -exec chmod 755 '{}' \;
