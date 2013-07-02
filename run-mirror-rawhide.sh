#!/bin/bash
# psu is much faster but it is outdated sometimes
#RSYNC_REMOTE_DIR=rsync://carroll.cac.psu.edu/fedora-linux-development/
RSYNC_REMOTE_DIR=rsync://mirrors.kernel.org/fedora/development/
RSYNC_LOCAL_DIR=/limbus/centos/rawhide
RSYNC_COMMAND="rsync --recursive --times --links --hard-links --delete -v --progress"
EXCLUDE_LIST=""

$RSYNC_COMMAND $EXCLUDE_LIST $RSYNC_REMOTE_DIR $RSYNC_LOCAL_DIR

find $RSYNC_LOCAL_DIR -type d -exec chmod 755 '{}' \;
