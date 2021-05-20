#!/bin/bash
MEMBER=""
HOST="" 
# 자기 이름과 멤버이름 입력 소문자

#############PROFILE#####################=
GOLDILOCKS_DATA=/home/sunje/goldilocks_data
GOLDILOCKS_HOME=/home/sunje/goldilocks_home
PATH=$PATH:$GOLDILOCKS_HOME/bin

GROUP_NAME=`echo ${MEMBER:0:2}`
MEMBER_NAME=`echo ${MEMBER:2:2}`
#########################################


#############CREATE_DB && START LOCATOR#####################

gcreatedb --cluster --member $MEMBER --host $HOST --port 10101

gsql sys gliese --as sysdba <<EOF
startup
alter system open global database;
\q
EOF

glsnr --start

if [ "$GROUP_NAME" == "g1" ]; then 

    if [ "$MEMBER_NAME" == "n1" ]; then
    
        gsql sys gliese --as sysdba <<EOF
        CREATE CLUSTER GROUP G1 CLUSTER MEMBER $MEMBER HOST '$HOST' PORT 10101;
        \q
EOF
        gsql sys gliese -i $GOLDILOCKS_HOME/admin/cluster/DictionarySchema.sql
        gsql sys gliese -i $GOLDILOCKS_HOME/admin/cluster/InformationSchema.sql
        gsql sys gliese -i $GOLDILOCKS_HOME/admin/cluster/PerformanceViewSchema.sql

        cd $GOLDILOCKS_HOME/script &&  ls -l |grep sql|awk '{print "gsql sys gliese -i "$9}' | sh -i

    else 
        gsqlnet sys gliese --as sysdba --dsn=G1N1<<EOF
        ALTER CLUSTER GROUP G1 ADD CLUSTER MEMBER $MEMBER HOST '$HOST' PORT 10101;
        ALTER DATABASE REBALANCE;
        \q
EOF

fi

else   
    if [ "$MEMBER_NAME" == "n1" ]; then
        gsqlnet sys gliese --as sysdba --dsn=G1N1<<EOF
        CREATE CLUSTER GROUP $GROUP_NAME CLUSTER MEMBER $MEMBER HOST '$HOST' PORT 10101;
        ALTER DATABASE REBALANCE;
        \q
EOF
        gsql sys gliese --as sysdba <<EOF
        ALTER SYSTEM RECONNECT GLOBAL CONNECTION;
        QUIT;
EOF
    else 
        gsqlnet sys gliese --as sysdba --dsn=G1N1<<EOF
        ALTER CLUSTER GROUP $GROUP_NAME ADD CLUSTER MEMBER $MEMBER HOST '$HOST' PORT 10101;
        ALTER DATABASE REBALANCE;
        \q
EOF

fi

fi