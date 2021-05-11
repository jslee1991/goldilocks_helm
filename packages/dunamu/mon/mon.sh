#!/bin/bash

unset LANG

#GSQL='gsqlnet test test --dsn=G1N1 --no-prompt';
GSQL='gsql test test --no-prompt';

doSystemInfo() {
START_DATE=`date +"%Y/%m/%d %H:%M:%S"`
HOST_NAME=`hostname --long`
HOST_ADDR=`hostname -I`
UP_DATE=`uptime -s`

CHECK_INTERVAL=1
CHECK_CNT=5
HEAD_CNT=10

echo "========================================================================="
echo "= CHECK DATE : " $START_DATE 
echo "= HOST       : " $HOST_NAME
echo "= ADDR       : " $HOST_ADDR
echo "= UPTIME     : " $UP_DATE
echo "========================================================================="
echo ""

echo "========================================================================="
echo "# total cpu usage"
echo "========================================================================="
echo ""
mpstat -u $CHECK_INTERVAL $CHECK_CNT | grep -v $HOST_NAME
echo ""
vmstat $CHECK_INTERVAL $CHECK_CNT
echo ""

echo "========================================================================="
echo "# cpu usage monitoring"
echo "========================================================================="
echo ""
top -c -b -n $CHECK_INTERVAL -u $USER | head -n $HEAD_CNT
echo ""
ps -eo "user,pcpu,vsz,rss,args,wchan=wide-wchan-column" --sort -pcpu | head -n $HEAD_CNT
echo ""
pidstat -u $CHECK_INTERVAL $CHECK_CNT | grep Average
echo ""

echo "========================================================================="
echo "# total memory usage"
echo "========================================================================="
echo ""
free -g -w
echo ""
cat /proc/meminfo | grep -v Huge
echo ""
vmstat -s -S M
echo ""

echo "========================================================================="
echo "# total hugepage memory usage"
echo "========================================================================="
echo ""
cat /proc/meminfo | grep Huge
echo ""

echo "========================================================================="
echo "# memory usage monitoring"
echo "========================================================================="
echo ""
ps -eo "user,pcpu,vsz,rss,args" --sort -rss | head -n $HEAD_CNT
echo ""

echo "========================================================================="
echo "# rss usage monitoring"
echo "========================================================================="
echo ""
ps -ef | grep $USER | grep -v grep | grep -v rss | grep -v ps | grep -v awk | grep -v bash | grep -v sshd | awk '{print $2}' | while read pid
do
   ps=`ps -ho user,pid,vsz,rss,args -f $pid | tail -1`
   pmapmap=`pmap -x $pid | grep -v shmid | grep -v total | awk '{ sum+=$2 } END { print sum/1024 }'`
   pmaprss=`pmap -x $pid | grep -v shmid | grep -v total | awk '{ sum+=$3 } END { printf sum/1024 }'`

   if [ $(printf %0.f $pmaprss) -gt 50 ]; then
      echo $ps ]$(printf %.1f $pmapmap)]$(printf %.1f $pmaprss)]
   fi
done
echo ""

echo "========================================================================="
echo "# stack usage monitoring"
echo "========================================================================="
echo ""
pidstat -s $CHECK_INTERVAL $CHECK_CNT | grep Average
echo ""

echo "========================================================================="
echo "# total disk usage"
echo "========================================================================="
echo ""
df -h | grep -v "run"
echo ""
vmstat -D
echo ""

echo "========================================================================="
echo "# disk usage monitoring"
echo "========================================================================="
echo ""
iostat -d -m -x $CHECK_INTERVAL $CHECK_CNT | grep -v dm
echo ""
pidstat -d $CHECK_INTERVAL $CHECK_CNT | grep Average
echo ""

echo "========================================================================="
echo "# total network usage"
echo "========================================================================="
echo ""
netstat -i
echo ""

echo "========================================================================="
echo "# network usage monitoring"
echo "========================================================================="
echo ""
netstat -an | grep ESTABLISHED | wc -l | awk '{ print "Established Status Count : " $1}'
netstat -an | grep WAIT | wc -l | awk '{ print "Wait Status Count : " $1}'
echo ""
sar -n DEV $CHECK_INTERVAL $CHECK_CNT | grep Average
echo ""
}

doDatabaseOnceDay() {
$GSQL << EOF | egrep -v "[000-999] rows"
\set linesize 2048
\set pagesize 1000

\host printf "========================================================================="
\host printf "# tablespace usage size"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,ORIGIN_MEMBER_NAME
      ,TBS_NAME
      ,TO_CHAR(TRUNC(TOTAL_EXT_COUNT * EXTENT_SIZE / 1024 / 1024, 0), '999,999,999') "TOTAL(MB)"
      ,TO_CHAR(TRUNC(USED_DATA_EXT_COUNT * EXTENT_SIZE / 1024 / 1024, 0), '999,999,999') "USED(MB)"
      ,TO_CHAR(TRUNC(FREE_EXT_COUNT * EXTENT_SIZE / 1024 / 1024, 0), '999,999,999') "FREE(MB)"
FROM GV\$TABLESPACE_STAT 
ORDER BY ORIGIN_MEMBER_NAME
        ,TBS_ID
;

\host printf "========================================================================="
\host printf "# table usage size"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,TABLE_SCHEMA
      ,TABLE_NAME
      ,TO_CHAR(TRUNC(BLOCKS * 8192 / 1024 / 1024, 0), '999,999,999') AS "USED SIZE(MB)"
  FROM ALL_TABLES
 WHERE TABLE_SCHEMA NOT IN ('DEFINITION_SCHEMA', 'DICTIONARY_SCHEMA')
ORDER BY TABLE_SCHEMA
        ,TABLE_NAME
;

\host printf "========================================================================="
\host printf "# index usage size"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,INDEX_SCHEMA
      ,INDEX_NAME
      ,TO_CHAR(TRUNC(BLOCKS * 8192 / 1024 / 1024, 0), '999,999,999') AS "USED SIZE(MB)"
  FROM ALL_INDEXES
 WHERE INDEX_SCHEMA NOT IN ('DEFINITION_SCHEMA')
ORDER BY INDEX_SCHEMA
        ,INDEX_NAME
;

EOF
}


doDatabaseInfo() {
$GSQL << EOF | egrep -v "[000-999] rows"
\set linesize 2048
\set pagesize 1000

\host printf "========================================================================="
\host printf "# cluster node check"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE" 
      ,NVL(B.GROUP_NAME, 'NONE') GROUP_NAME
      ,NVL(B.MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,A.STATUS
      ,B.MEMBER_ID
      ,A.IS_GLOBAL_COORD
      ,A.IS_GROUP_COORD
      ,B.MEMBER_HOST
      ,B.MEMBER_PORT
  FROM V\$CLUSTER_MEMBER@LOCAL A, DBA_CLUSTER B
 WHERE A.MEMBER_ID = B.MEMBER_ID
;

\host printf "========================================================================="
\host printf "# ssa memory check"
\host printf "========================================================================="
SELECT  '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,NAME
      ,TO_CHAR(TRUNC(VALUE / 1024 / 1024, 0), '999,999,999') AS "SIZE(MB)"
  FROM X\$KN_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] 
 WHERE NAME IN ( 'FIXED_STATIC_ALLOC_SIZE', 'VARIABLE_STATIC_TOTAL_SIZE', 'VARIABLE_STATIC_ALLOC_SIZE' ) 
ORDER BY MEMBER_NAME
;

\host printf "========================================================================="
\host printf "# session total memory check (descending limit 10)"
\host printf "========================================================================="
SELECT   '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(ORIGIN_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,STAT_NAME
      ,TO_CHAR(TRUNC(SUM(STAT_VALUE) / 1024 / 1024, 0), '999,999,999') AS "TOTAL SUM SIZE(MB)"
  FROM GV\$SESSION_MEM_STAT
 GROUP BY ORIGIN_MEMBER_NAME
         ,STAT_NAME
ORDER BY 4 DESC, 2
LIMIT 10
;

\host printf "========================================================================="
\host printf "# cluster dispatcher check"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,TYPE
      ,TO_CHAR(TRUNC(RX_BYTES / 1024 / 1024, 0), '999,999,999') AS "RX_SIZE(MB)"
      ,TO_CHAR(TRUNC(TX_BYTES / 1024 / 1024, 0), '999,999,999') AS "TX_SIZE(MB)"
      ,RX_JOBS
      ,TX_JOBS
  FROM X\$CLUSTER_DISPATCHER@GLOBAL[IGNORE_INACTIVE_MEMBER]
ORDER BY CLUSTER_MEMBER_NAME;      


\host printf "========================================================================="
\host printf "# cluster queue check"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,NAME
      ,QUEUED
      ,WAIT_COUNT
  FROM X\$CLUSTER_QUEUE@GLOBAL[IGNORE_INACTIVE_MEMBER]
 WHERE FULL_COUNT != 0 
    OR WAIT_COUNT != 0
ORDER BY MEMBER_NAME
;

\host printf "========================================================================="
\host printf "# cluster cserver check"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,NAME
      ,STATUS
      ,COUNT(*) 
  FROM X\$CLUSTER_SERVER
GROUP BY CLUSTER_MEMBER_NAME, NAME, STATUS
 HAVING STATUS != 'WAIT'
ORDER BY CLUSTER_MEMBER_NAME;

SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,NAME
      ,SUM(PROCESSED_JOBS) 
  FROM X\$CLUSTER_SERVER@GLOBAL[IGNORE_INACTIVE_MEMBER]
GROUP BY CLUSTER_MEMBER_NAME
        ,NAME
ORDER BY CLUSTER_MEMBER_NAME
        ,NAME
;

\host printf "========================================================================="
\host printf "# global commit check"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,NAME
      ,TO_CHAR(VALUE, '999,999,999,999') EXECUTE_COUNT
  FROM X\$CL_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER]
 WHERE NAME = 'GLOBAL_COMMIT_COUNT'
ORDER BY MEMBER_NAME
;

\host printf "========================================================================="
\host printf "# retry count check"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,NAME
      ,VALUE
  FROM X\$SM_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER]
 WHERE NAME IN ( 'TRY_STEAL_UNDO_PAGE_COUNT', 'VERSION_CONFLICT_COUNT' )
ORDER BY CLUSTER_MEMBER_NAME
        ,NAME
;

\host printf "========================================================================="
\host printf "# cluster deadlock check"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(ORIGIN_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,STAT_NAME
      ,STAT_VALUE
  FROM GV\$SYSTEM_SQL_STAT 
 WHERE STAT_NAME LIKE '%DEADLOCK%' 
ORDER BY ORIGIN_MEMBER_NAME
;

\host printf "========================================================================="
\host printf "# total session count"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE" 
      ,NVL(CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,CONNECTION
      ,STATUS
      ,COUNT(*) 
  FROM X\$SESSION@GLOBAL[IGNORE_INACTIVE_MEMBER] 
 WHERE PROGRAM NOT LIKE '%gmaster%'
   AND PROGRAM NOT LIKE '%dispatcher%'
   AND PROGRAM NOT LIKE '%server%'
   AND PROGRAM NOT IN ( 'gmon', 'balancer' )
GROUP BY CLUSTER_MEMBER_NAME
        ,CONNECTION
        ,STATUS
ORDER BY MEMBER_NAME
        ,CONNECTION
        ,STATUS
;

\host printf "========================================================================="
\host printf "# processor session count"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,PROGRAM
      ,CONNECTION
      ,STATUS
      ,COUNT(*)
  FROM X\$SESSION@GLOBAL[IGNORE_INACTIVE_MEMBER]
 WHERE PROGRAM NOT LIKE '%gmaster%'
   AND PROGRAM NOT LIKE '%dispatcher%'
   AND PROGRAM NOT LIKE '%server%'
   AND PROGRAM NOT IN ( 'gmon', 'balancer' )
GROUP BY CLUSTER_MEMBER_NAME
        ,PROGRAM
        ,CONNECTION
        ,STATUS
ORDER BY MEMBER_NAME
        ,CONNECTION
        ,STATUS
;

\host printf "========================================================================="
\host printf "# ager status check"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(ORIGIN_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,to_number ( split_part ( agable_scn_gap, '.', 1 )) GLOBAL_GAP
      ,to_number ( split_part ( agable_scn_gap, '.', 2 )) DOMAIN_GAP
      ,to_number ( split_part ( agable_scn_gap, '.', 3 )) LOCAL_GAP
  FROM GV\$AGABLE_INFO
ORDER BY MEMBER_NAME
;

\host printf "========================================================================="
\host printf "# undo segemnt status check (descending limit 10)"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,SEGMENT_ID
      ,PHYSICAL_ID
      ,ALLOC_PAGE_COUNT
      ,AGABLE_PAGE_COUNT
  FROM X$UNDO_SEGMENT@GLOBAL[IGNORE_INACTIVE_MEMBER] 
 WHERE ALLOC_PAGE_COUNT > 1280 
GROUP BY CLUSTER_MEMBER_NAME
        ,SEGMENT_ID
        ,PHYSICAL_ID
        ,ALLOC_PAGE_COUNT
        ,AGABLE_PAGE_COUNT 
ORDER BY ALLOC_PAGE_COUNT DESC
LIMIT 10;

\host printf "========================================================================="
\host printf "# lock wait status check"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,XS.CLIENT_PROCESS "CLIENT PID"
      ,XS.SERVER_PROCESS "SERVER PID"
      ,XS.ID
      ,XLW.GRANTED_TRANSACTION_SLOT_ID
      ,XLW.REQUEST_TRANSACTION_SLOT_ID "REQUEST_TX_ID"
      ,XTT.BEGIN_TIME "BEGIN_TIME"
  FROM X\$LOCK_WAIT@GLOBAL[IGNORE_INACTIVE_MEMBER] XLW
      ,X\$TRANSACTION@GLOBAL[IGNORE_INACTIVE_MEMBER] XTT
      ,X\$SESSION@GLOBAL[IGNORE_INACTIVE_MEMBER] XS
 WHERE XLW.GRANTED_TRANSACTION_SLOT_ID = XTT.SLOT_ID
   AND XTT.LOGICAL_TRANS_ID = XS.TRANS_ID
   AND XLW.CLUSTER_MEMBER_ID = XTT.CLUSTER_MEMBER_ID
   AND XTT.CLUSTER_MEMBER_ID = XS.CLUSTER_MEMBER_ID
;

\host printf "========================================================================="
\host printf "# long run transaction status check"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,LOGICAL_TRANS_ID
      ,DRIVER_TRANS_ID
      ,STATE
      ,BEGIN_TIME
  FROM X\$TRANSACTION@GLOBAL[IGNORE_INACTIVE_MEMBER]
 WHERE DATEDIFF( SECOND, BEGIN_TIME, LOCALTIMESTAMP ) > 5
ORDER BY MEMBER_NAME
        ,BEGIN_TIME
;

\host printf "========================================================================="
\host printf "# long run statement status check (descending limit 10)"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(ORIGIN_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,SESSION_ID
      ,STMT_ID
      ,STMT_VIEW_SCN
      ,START_TIME
      ,SUBSTR(LTRIM(SQL_TEXT), 1, 100 )
  FROM GV\$STATEMENT
 WHERE STMT_VIEW_SCN != '-1.-1.-1'
   AND DATEDIFF( SECOND, START_TIME, LOCALTIMESTAMP ) > 5
ORDER BY START_TIME
LIMIT 10;

\host printf "========================================================================="
\host printf "# redo logfile status check"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,GROUP_ID
      ,STATE
  FROM X\$LOG_GROUP@GLOBAL[IGNORE_INCTIVE_MEMBER]
 WHERE STATE NOT IN ( 'UNUSED', 'INACTIVE' )
ORDER BY MEMBER_NAME
;

\host printf "========================================================================="
\host printf "# redo log stream status check"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,WAIT_COUNT_BY_BUFFER_FULL
      ,BLOCKED_LOGGING_COUNT
  FROM X\$LOG_STREAM@GLOBAL[IGNORE_INACTIVE_MEMBER]
ORDER BY MEMBER_NAME
;

\host printf "========================================================================="
\host printf "# total statement count"
\host printf "========================================================================="
SELECT '['||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS' ) ||']' "DATE"
      ,NVL(CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME
      ,STMT_TYPE
      ,TO_CHAR(EXECUTE_COUNT, '999,999,999,999') EXECUTE_COUNT
  FROM X\$SQL_SYSTEM_STAT_EXEC_STMT@GLOBAL[IGNORE_INACTIVE_MEMBER]
 WHERE EXECUTE_COUNT > 1000
ORDER BY MEMBER_NAME
        ,EXECUTE_COUNT DESC
;

EOF
}

doSystemInfo
doDatabaseInfo
doDatabaseOnceDay

