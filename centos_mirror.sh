#!/bin/sh
# centos_mirror.sh

# set VARS
    DATE=`date \`\`+%a_%b_%d_%y_%H_%M''`
    DATENICE=`date \`\`+%a\ -\ %b\ %d,\ %Y\ -\ %H:%M''`
    YEST_DATE=`date -d yesterday \`\`+%a_%b_%d_%y''`
    EMAIL="oss@oss.rutgers.edu"
    P_DIR=/limbus/centos/status				#P is for PATCH - ; )
    R_DIR=/limbus/centos/centos
    P_DATEFILE=CENTOS.LAST_UPDATE
    P_LOG=$P_DIR/CENTOS_LAST_MIRRORED.$DATE
    O_LOG=$P_DIR/CENTOS_LAST_MIRRORED.$YEST_DATE	#O is for OLD
    T_LOG=$P_DIR/CENTOS_MIRROR_IN_PROGRESS.$DATE
    E_LOG=$P_DIR/CENTOS_BROKE_ON.$DATE			#E is for ERROR
    RSYNC_COMMAND=/usr/local/share/rutgers-mirror-scripts/run-mirror-centos.sh

cd $P_DIR

# use rsync to get the patches. execute command in $RSYNC_COMMAND
# and writes to $T_LOG
$RSYNC_COMMAND > $T_LOG 2>&1
exitcode=$?

if [ "$exitcode" -eq 0 ] 	# exit status OK
then
    echo $DATENICE > $P_DIR/$P_DATEFILE
    REPODATA_DIR=$(ls -td $(find $R_DIR -maxdepth 4 -name repodata -type d) |awk "NR==1")
    REPODATA_DIR_DATE=`date -r $REPODATA_DIR \`\`+%a\ -\ %b\ %d,\ %Y\ -\ %H:%M''`
    echo $REPODATA_DIR_DATE >> $P_DIR/$P_DATEFILE
    mv $T_LOG $P_LOG
    logger -p cron.notice -t $0 `tail -n 2  $P_LOG`        # log it

    tail -n 30 $P_LOG > $P_LOG.short
#    echo "$P_LOG : rsync successful see attachment for details" | mutt -a $P_LOG.short -s "$0: Completed" $ME
    rm -f $P_LOG.short
    rm -f $O_LOG*                                                # remove previous days logs
    chmod -R 755 $P_DIR
    chown -R root:root $P_DIR
else
    mv $T_LOG $E_LOG
    tail -n 30 $E_LOG > $E_LOG.short
    logger -p cron.err -t $0 `tail -n 5  $E_LOG`   # write to syslog on failure
    chmod -R 755 $P_DIR
    chown -R root:root $P_DIR
    #check if rsync has failed for more than 24 hours
    OUTOFDATE=`find /limbus/centos/status -mtime -1 -name 'CENTOS_LAST_MIRROR*' | wc -l`
    if [ "$OUTOFDATE" -eq 0 ]
    then
       echo "Warning: Centos mirror out of date by 24 hours, see attachment for latest error message, additional logs available at http://centos.rutgers.edu/mirror/status" | mutt -a $E_LOG.short -s "Centos MIRROR 24 Hours out of date" $EMAIL
    fi
    rm -f $E_LOG.short
fi
