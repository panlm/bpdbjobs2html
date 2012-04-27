#!/usr/bin/ksh
# this script used to convert bpdbjobs output to html format.
# create : Nov 10 2004
# modify : May 14 2007
# author : steven_pan@dnt.net.cn

set -u

HOSTLIST="jn_set4"
PATH=$PATH:/usr/openv/netbackup/bin/admincmd
BASEDIR=/home/dnt
TZ=EAT+8
YESTERDAY=`date +%D`
TZ=EAT-8
TODAY=`date +%D`

INPUTFILE=${BASEDIR}/inputfile
OUTPUTFILE=${BASEDIR}/backup_daily_report.`date +%Y%m%d`.html
TMPFILE=${BASEDIR}/tmpfile
TMPFILE1=/var/tmp/bptmpfile1
TMPFILE2=/var/tmp/bptmpfile2
TMPFILE3=/var/tmp/bptmpfile3

true > $INPUTFILE
true > $TMPFILE

# print html header
print "<html><head><title>Netbackup Daily Report</title>
</head>
<body>" > ${OUTPUTFILE}

# display all backup on today
bpdbjobs |grep -v -e Active -e Restore -e Queued |grep $YESTERDAY > ${INPUTFILE}
bpdbjobs |grep -v -e Active -e Restore -e Queued |grep $TODAY >> ${INPUTFILE}

for i in $HOSTLIST ; do

cat ${INPUTFILE} | awk '{
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
COMPRESSION=substr($0,212,15);
Tmp=Status

if (Status == 0 || Status == 1)
    Status="<td bgcolor=green><B><center>" Status "</center></B></td>"
else
    Status="<td bgcolor=red><B><center>" Status "</center></B></td>"

printf("<tr><td nowrap>%s</td><td nowrap>%s</td><td nowrap>%s</td>%s<td nowrap>%
s</td><td nowrap>%s</td><td nowrap>%s</td><td nowrap>%s</td><td nowrap>%s</td><t
d nowrap>%s</td><td nowrap>%s</td><td nowrap>%s</td><td>\n",
JobID,
Type,
State,
Status,
Policy,
Schedule,
Client,
DstMedia_Server,
STARTED,
ENDED,
ELAPSED,
COMPRESSION);
system(" remsh '$i' -n \"/usr/openv/netbackup/bin/admincmd/bperror -S "Tmp" \" |
tr -s \\'\'' \\. |tr -s \\\" \\. |xargs |grep -v \"the requested operation was s
uccessfully completed\" |xargs >> '$TMPFILE2'");
system("echo \"</td></tr>\" >> '$TMPFILE3'")
}' > $TMPFILE1

paste -d "" $TMPFILE1 $TMPFILE2 $TMPFILE3 > $TMPFILE
cp /dev/null $TMPFILE1
cp /dev/null $TMPFILE2
cp /dev/null $TMPFILE3

print "<h2>HOSTNAME: "$i" ("`date`")</h2>
<table border=2 width=\"200%\">
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
<td nowrap><B>Compression</B></td>
<td width=750><B>Reason</B></td></tr>
" >> ${OUTPUTFILE}
cat ${TMPFILE} >> ${OUTPUTFILE}
print "</table>" >> ${OUTPUTFILE}

done

# print html tailer
print "</body></html>" >> ${OUTPUTFILE}

#



















