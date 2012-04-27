#!/usr/bin/ksh

set -u
HOSTNAME=`hostname`
PATH=$PATH:/usr/openv/netbackup//bin/admincmd
BASEDIR=/home/dntadm2/backup
UNAME=`uname -a`
TZ=EAT+4
YESTERDAY=`date +%D`
TZ=EAT-8
USER=`whoami`
#YESTERDAY=10/17/04

INPUT_FILE=${BASEDIR}/inputfile
TMP_FILE=${BASEDIR}/tmpfile
OUTPUT_FILE=${BASEDIR}/output.`date +%Y%m%d`.html
HALF_FILE=${BASEDIR}/half.`date +%Y%m%d`.html
                
if [ ${USER} != "root" ] ; then
   echo
   echo "Using root to execute this script."
   echo
   exit 100
fi

true > $INPUT_FILE
true > $TMP_FILE
true > $HALF_FILE

# display all backup on today
#bpdbjobs  |grep -v -e Active -e Restore -e Queued |grep $TODAY > ${INPUT_FILE}

# display all backup after 9:00 on yesterday
bpdbjobs  |grep -v -e Active -e Queued |awk -v yesterday=$YESTERDAY '{
if ( substr($0,162,8) >= yesterday ) print $0 }' | awk '{
if (( $4 == 0 ) && $0 ~ /Default-Application-Backup/ ) next; else print $0 }' > ${INPUT_FILE}

cat ${INPUT_FILE} | awk '{

JobID=substr($0,1,10);
Type=substr($0,12,20);
State=substr($0,33,10);
Status=substr($0,44,10) + 0;
Policy=substr($0,55,30);
Schedule=substr($0,86,30);
Client=substr($0,117,20);
DstMedia_Server=substr($0,138,20);
STARTED=substr($0,159,20);
ENDED=substr($0,180,20);
ELAPSED=substr($0,201,10);
COMPRESSION=substr($0,212,15)

if (Status == 0 || Status == 1)
    Status="<td bgcolor=green><B><center>" Status "</center></B></td>"
else 
    Status="<td bgcolor=red><B><center>" Status "</center></B></td>" 

printf("<tr><td nowrap>%s</td><td nowrap>%s</td><td nowrap>%s</td>%s<td nowrap>%s</td><td nowrap>%s</td><td nowrap>%s</td><td nowrap>%s</td><td nowrap>%s</td><td nowrap>%s</td><td nowrap>%s</td><td nowrap>%s</td></tr>\n",
JobID, Type, State, Status, Policy, Schedule, Client, DstMedia_Server, 
STARTED, ENDED, ELAPSED, COMPRESSION); 
}' > ${TMP_FILE} 

# print html header
print "<html><head><title>Netbackup Daily Report</title>
</head>
<body>" > ${OUTPUT_FILE}

print "<h2>HOSTNAME: "$HOSTNAME"</h2>
<table border=2 width=\"100%\">
<tr bgcolor=gray>
<td nowrap><B>JobID</B></td>
<td nowrap><B>Type</B></td>
<td nowrap><B>State</B></td>
<td nowrap><B><center>Status</center></B></td>
<td nowrap><B><center>Policy</center></B></td>
<td nowrap><B><center>Schedule</center></B></td>
<td nowrap><B>Client</B></td>
<td><B>Dest Media Server</B></td>
<td nowrap><B>Started</B></td>
<td nowrap><B>Ended</B></td>
<td nowrap><B>Elapsed</B></td>
<td nowrap><B>Compression</B></td></tr>
" |tee -a ${OUTPUT_FILE} ${HALF_FILE} 1> /dev/null
cat ${TMP_FILE} |tee -a ${OUTPUT_FILE} ${HALF_FILE} 1> /dev/null
print "</table>" |tee -a ${OUTPUT_FILE} ${HALF_FILE} 1> /dev/null

# print html tailer
print "</body></html>" >> ${OUTPUT_FILE}

