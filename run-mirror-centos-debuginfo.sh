#!/bin/bash
#RSYNC_REMOTE_DIR=mirror.nsc.liu.se::centos-debuginfo
RSYNC_REMOTE_DIR=debuginfo.centos.org::centos-debuginfo
RSYNC_LOCAL_DIR=/limbus/centos/centos-debuginfo/
RSYNC_COMMAND="rsync --recursive --times --links --hard-links --delete -v --progress"

# This should grab the latest version
# TODO: this is broken
CURRENT_RELEASE=`rsync --list-only --no-motd $RSYNC_REMOTE_DIR | awk '{ print $5 }' | egrep -o "^[0-9]+" | sort -gr | head -n1`
NO_OF_RELEASES_TO_KEEP=1
EXCLUDE_LIST="--exclude sync_debug --exclude index* --exclude icons --exclude FOOTER.html"

# Exclude all older versions of CentOS
LAST_RELEASE=`expr $CURRENT_RELEASE - $NO_OF_RELEASES_TO_KEEP`
for ver in `seq 1 $LAST_RELEASE`; do
   EXCLUDE_LIST="$EXCLUDE_LIST --exclude ${ver}*"
done

$RSYNC_COMMAND $EXCLUDE_LIST $RSYNC_REMOTE_DIR $RSYNC_LOCAL_DIR

find $RSYNC_LOCAL_DIR -type d -exec chmod 755 '{}' \;


#From the old script:
#rsync --recursive --times --links --hard-links --delete -v --progress --exclude ppc --exclude 4 --exclude sync_debug --exclude index* --exclude icons --exclude FOOTER.html mirror.nsc.liu.se::centos-debuginfo /mirror/centos/debuginfo

# The official rsync repo is sometimes too slow:
#rsync --recursive --times --links --hard-links --delete -v --progress --exclude ppc --exclude 4 --exclude sync_debug --exclude index* --exclude icons --exclude FOOTER.html debuginfo.centos.org::centos-debuginfo /mirror/centos/debuginfo

#find /mirror/centos/debuginfo/ -type d -exec chmod 755 '{}' \;
