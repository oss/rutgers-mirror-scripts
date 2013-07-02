#!/bin/bash
## Mirror Synchronization Script /usr/local/bin/ubuntu-mirror-sync.sh
## Version 1.01 Updated 13 Feb 2007 by Peter Noble

## Where do we want to have our files
SYNC_HOME="/limbus/centos/ubuntu"
log=$SYNC_HOME/logs/sync.log
UPDATE_FILE=/limbus/centos/status/UBUNTU.LAST_UPDATE


#email to report on out of date
EMAIL="oss@oss.rutgers.edu"
## Setup the server to mirror
remote=rsync://mirrors.rit.edu/ubuntu/
#remote=rsync://mirrors.rit.edu/ubuntu/


## Setup the local directory / Our mirror
local=$SYNC_HOME

## Initialize some other variables
complete="false"
failures=0
status=1
pid=$$

echo "`date +%x-%R` - $pid - Started Ubuntu Mirror Sync" > $log
while [[ "$complete" != "true" ]]; do

        if [[ $1 == "debug" ]]; then
                echo "Working on attempt number $failures"
		rsync --progress --recursive --times --links --hard-links --stats --exclude "Packages*" --exclude "Sources*" --exclude "Release*" $remote $local 2>&1 >> $log && \
		rsync --progress --recursive --times --links --hard-links --stats --delete --delete-after $remote $local 2>&1 >> $log
                status=$?
        else
		rsync --progress --recursive --times --links --hard-links --stats --exclude "Packages*" --exclude "Sources*" --exclude "Release*" $remote $local  2>&1 >> $log && \
		rsync --progress --recursive --times --links --hard-links --stats --delete --delete-after $remote $local 2>&1 >> $log
                status=$?
        fi

        if [[ $status -ne "0" ]]; then
                complete="true"
                (( failures += 1 ))
	        #if our rsync failed, log it and email us

		logger -p cron.err -t $0 `tail -n 5 $log` #write log to syslog on failure
		OUTOFDATE=`find /mirror/status -mtime -1 -name 'ARCHLINUX*' | wc -l`
		if [ "$OUTOFDATE" -eq 0 ]
		then
			echo "sync out of date\n";
		#	echo "Warning: Ubuntu mirror out of date by 24 hours, please check logs at http://centos.rutgers.edu/mirror/status " | mail -s "UBUNTU MIRROR 24 Hours out of date" $EMAIL
		fi

        else
                echo "`date +%x-%R` - $pid - Finished Ubuntu Mirror Sync" >> $log
		DATENICE=`date \`\`+%a\ -\ %b\ %d,\ %Y\ -\ %H:%M''`
		 echo $DATENICE > $UPDATE_FILE
		#LATEST_REPO_FILE=`find $SYNC_HOME/dists/ -name Packages.gz -print0 | xargs -r -0 ls -t | head -1`
		LATEST_REPO_FILE=`ls -t $(find $SYNC_HOME/dists/ -name Packages.gz -print0 | xargs -0 echo) | head -1`
		REPODATA_DIR_DATE=`date -r $LATEST_REPO_FILE \`\`+%a\ -\ %b\ %d,\ %Y\ -\ %H:%M''`
		echo $REPODATA_DIR_DATE >> $UPDATE_FILE
        complete="true"
        fi
done

exit 0
