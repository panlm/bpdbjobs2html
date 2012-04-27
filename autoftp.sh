
DATE=`date +%Y%m%d`
DATE1=`date +%Y%m`
HOSTLIST="zjbbak zjsnbak1"
BASEDIR=/app/dnt/dntadm2/ftp
OUTPUT=$BASEDIR/backup_daily_report.$DATE.html

print "<html><head><title>Netbackup Daily Report</title>
</head><body>" > $OUTPUT

for i in $HOSTLIST ; do
rcp $i:/home/dntadm2/backup/half.$DATE.html $BASEDIR/
cat $BASEDIR/half.$DATE.html >> $OUTPUT
rm -f $BASEDIR/half.$DATE.html
done

print "</body></html>" >> $OUTPUT

ftp -vin << EOF
open 10.70.49.18
user dnt dnt12345
cd "/【3】维护记录/【1】作业记录/【6】主机"
cd "【3】备份作业情况检查"
cd $DATE1
lcd $BASEDIR
put ${OUTPUT##*/}
bye
EOF

date

