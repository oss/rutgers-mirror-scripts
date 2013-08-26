#!/bin/bash

# Mirror Synchronization Script /army/rpmprivate/centos/config/scripts/cron
# Version 1.01 Updated 13 Feb 2007 by Peter Noble
# Updated for Rutgers, based on the old mirror script on Mon Aug 5 2013,
#   with some other small fixes and improvements for clarity's sake
#
# Troubleshooting (in case omachi dies again):
# - Make sure limbus is properly mounted.
# - Ensure that the crontab includes all of the mirror scripts.
# - Make sure a symbolic link at / exists and points properly to the mirrors
#   with `cd /; ln -s limbus/centos/ mirror`

# The place we want to keep our files
SYNC_HOME="/limbus/centos/ubuntu"
LOG="limbus/centos/logs/ubuntu_sync.log"
UPDATE_FILE="/limbus/centos/status/UBUNTU.LAST_UPDATE"

# Some email settings
EMAIL="oss@oss.rutgers.edu"
EMAIL_SUBJECT="UBUNTU MIRROR: 24 Hours Out-of-Date"
EMAIL_BODY="Check logs at http://centos.rutgers.edu/mirror/status"

# Set up the server to mirror
#REMOTE="rsync://archive.ubuntu.com/ubuntu"
#REMOTE="rsync://mirror.anl.gov/ubuntu/"
REMOTE="rsync://rsync.gtlib.gatech.edu/ubuntu/"

# Set up the local directory / Our mirror
LOCAL="$SYNC_HOME"

# For the rsync command
RSYNC_FLAGS="--recursive --times --links --hard-links --stats --verbose"
EXCLUDE_LIST='--exclude "Packages*" --exclude "Sources*" --exclude "Release*" --exclude .*~tmp~*'

# Initialize some other variables
STATUS=1
PID=$$

# Begin logging.
echo "`date +%x-%R` - $PID - Started Ubuntu Mirror Sync" >> $LOG
if [[ $1 == "debug" ]]; then
        echo "ubuntu-mirror.sh: [DEBUG] Beginning the sync."
fi

# Do the actual syncing.
# There used to be a loop here, but we only want to attempt the sync once.
rsync $RSYNC_FLAGS $EXCLUDE_LIST $REMOTE $LOCAL 2>&1 >> $LOG && \
rsync $RSYNC_FLAGS --delete --delete-after $REMOTE $LOCAL 2>&1 >> $LOG
STATUS=$?

# Now check to see how our sync worked.
if [[ $STATUS -ne "0" ]]; then
        # Write to the syslog.
        logger -p cron.err -t $0 `tail -n 5 $log`

        # If the rsync fails, email us.
        OUTOFDATE=`find /mirror/status -mtime -1 -name 'UBUNTU*' | wc -l`                                                                                                                                                        
        if [[ "$OUTOFDATE" -eq 0 ]]; then
                echo "ubuntu-mirror.sh: [FAIL] Sync failed. Ubuntu mirror out of date."
                echo $EMAIL_BODY | mail -s $EMAIL_SUBJECT $EMAIL
        fi
        exit 1
else
        # First, gather some data
        DATENICE=`date \`\`+%a\ -\ %b\ %d,\ %Y\ -\ %H:%M''`
        LATEST_REPO_FILE=`ls -t $(find $SYNC_HOME/dists/ -name Packages.gz -print0 | xargs -0 echo) | head -1`
        REPODATA_DIR_DATE=`date -r $LATEST_REPO_FILE \`\`+%a\ -\ %b\ %d,\ %Y\ -\ %H:%M''`

        # Update the mirror status
        echo "`date +%x-%R` - $PID - Finished Ubuntu Mirror Sync" >> $LOG
        echo $DATENICE > $UPDATE_FILE
        echo $REPODATA_DIR_DATE >> $UPDATE_FILE
        exit 0
fi
