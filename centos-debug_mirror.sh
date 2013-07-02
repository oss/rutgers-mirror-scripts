#!/bin/sh
# centos-debug_mirror.sh

# set VARS
    ME="jarek@nbcs.rutgers.edu"
    DATE=`date \`\`+%a_%b_%d_%y_%H_%M''`
    DATENICE=`date \`\`+%a\ -\ %b\ %d,\ %Y\ -\ %H:%M''`
    YEST_DATE=`date -d yesterday \`\`+%a_%b_%d_%y''`
    EMAIL="oss@oss.rutgers.edu"
    P_DIR=/limbus/centos/status				#P is for PATCH - ; )
    R_DIR=/limbus/centos/centos-debuginfo
    P_DATEFILE=CENTOS_DEBUG.LAST_UPDATE
    P_LOG=$P_DIR/CENTOS_DEBUG_LAST_MIRRORED.$DATE
    O_LOG=$P_DIR/CENTOS_DEBUG_LAST_MIRRORED.$YEST_DATE	#O is for OLD
    T_LOG=$P_DIR/CENTOS_DEBUG_MIRROR_IN_PROGRESS.$DATE
    E_LOG=$P_DIR/CENTOS_DEBUG_BROKE_ON.$DATE			#E is for ERROR
    RSYNC_COMMAND=/usr/local/share/rutgers-mirror-scripts/run-mirror-centos-debuginfo.sh

cd $P_DIR

# use rsync to get the patches. execute command in $RSYNC_COMMAND
# and writes to $T_LOG
$RSYNC_COMMAND > $T_LOG 2>&1
exitcode=$?

if [ "$exitcode" -eq 0 ] 	# exit status OK
then
    echo $DATENICE > $P_DIR/$P_DATEFILE
    REPODATA_DIR=$(ls -td $(find $R_DIR -maxdepth 3 -name repodata -type d) |awk "NR==1")
    REPODATA_DIR_DATE=`date -r $REPODATA_DIR \`\`+%a\ -\ %b\ %d,\ %Y\ -\ %H:%M''`
    echo $REPODATA_DIR_DATE >> $P_DIR/$P_DATEFILE
    mv $T_LOG $P_LOG
    logger -p cron.notice -t $0 `tail -n 2  $P_LOG`        # log it

    tail -n 30 $P_LOG > $P_LOG.short
    #echo "$P_LOG : rsync successful see attachment for details" | mutt -a $P_LOG.short -s "$0: Completed" $ME
    rm -f $P_LOG.short
    rm -f $O_LOG*                                                # remove previous days logs
    chmod -R 755 $P_DIR
    chown -R root:root $P_DIR
else
    mv $T_LOG $E_LOG
    tail -n 30 $E_LOG > $E_LOG.short
    #echo "$E_LOG : rsync failed with exit code $exitcode see attachment for details" | mutt -a $E_LOG.short -s "$0: ERROR" $ME
    logger -p cron.err -t $0 `tail -n 5  $E_LOG`   # write to syslog on failure
    chmod -R 755 $P_DIR
    chown -R root:root $P_DIR
    #check if rsync has failed for more than 24 hours
    OUTOFDATE=`find /limbus/centos/status -mtime -7 -name 'CENTOS_DEBUG_LAST_MIRROR*' | wc -l`
    if [ "$OUTOFDATE" -eq 0 ]
    then
       echo "Warning: CentOS-debuginfo mirror out of date by 7 days, see attachment for latest error message, additional logs available at http://centos.rutgers.edu/mirror/status" | mutt -a $E_LOG.short -s "CentOS-debuginfo MIRROR 7 days out of date" $EMAIL
    fi
    rm -f $E_LOG.short
fi
