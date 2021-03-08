#!/bin/bash

rm ~/.bashrc
cp /home/sunje/goldilocks_home/bashrc-init ~/.bashrc 
source ~/.bashrc

set -euxo pipefail
#test

# process 
## check datafile 
## if exists start cluster 
## if non exists init cluster 

# init process 
### cluster mode 
#### 1. init_cluster
#### 2. if current cluster is master : init_master_cluster
#### 2. if current cluster is slave : join_slave_cluster
#### 3. start_listener
#### 4. init_tablespace

# env
# table space size            : TABLE_SPACE_SIZE          : default 100M, unit G,M
# table space name            : TABLE_SPACE_NAME          : default DATA_TBS
# table space file name       : TABLE_SPACE_FILE_NAME     : default data_01.dbf
# temp table space size       : TEMP_TABLESPACE_SIZE      : default 100M, unit G,M
# temp table space name       : TEMP_TABLESPACE_NAME      : default TEMP_TBS
# temp table space file name  : TEMP_TABLESPACE_FILE_NAME : default temp_01
# service account name        : SERVICE_ACCOUNT_NAME      : SA
# service account passwd      : SERVICE_ACCOUNT_PASSWD    : passwd
# cluster group name          : GROUP_NAME                : G1
# cluster member name         : MEMBER_NAME               : default G1N1
# cluster ip address          : CLUSTER_IP_ADDR           : default 127.0.0.1
# cluster port                : CLUSTER_PORT              : default 10101
# master ip address           : CLUSTER_MASTER_IP_ADDR    : 
# master port                 : CLUSTER_MASTER_PORT       :

TABLE_SPACE_SIZE=${TABLE_SPACE_SIZE:-100M}
TABLE_SPACE_NAME=${TABLE_SPACE_NAME:-DATA_TBS}
TABLE_SPACE_FILE_NAME=${TABLE_SPACE_FILE_NAME:-data_01.dbf}
TEMP_TABLESPACE_SIZE=${TEMP_TABLESPACE_SIZE:-100M}
TEMP_TABLESPACE_NAME=${TEMP_TABLESPACE_NAME:-TEMP_TBS}
TEMP_TABLESPACE_FILE_NAME=${TEMP_TABLESPACE_FILE_NAME:-temp_01}
SERVICE_ACCOUNT_NAME=${SERVICE_ACCOUNT_NAME:-SA}
SERVICE_ACCOUNT_PASSWD=${SERVICE_ACCOUNT_PASSWD:-passwd}
#GROUP_NAME=${GROUP_NAME:-G1}
#MEMBER_NAME=${MEMBER_NAME:-goldilocks-0}
#MEMBER_NAME_S=${MEMBER_NAME_S:-G1N2}
#MEMBER_NAME2=${MEMBER_NAME2:-GOLDILOCKS-2-0}
CLUSTER_IP_ADDR=${CLUSTER_IP_ADDR:-127.0.0.1}
CLUSTER_IP_ADDR_S=${CLUSTER_IP_ADDR_S:-172.17.0.3}
CLUSTER_PORT=${CLUSTER_PORT:-10101}
CLUSTER_MASTER_IP_ADDR=${CLUSTER_MASTER_IP_ADDR:-127.0.0.1}
CLUSTER_MASTER_PORT=${CLUSTER_MASTER_PORT:-10101}
#CLUSTER_CREATE_CHECK=2 # 0:G1N1 , 1:G1N2, 2:G2N1, 3:G2N2
GOLDILOCKS_HOME=/home/sunje/goldilocks_home
export ODBCINI=/home/sunje/goldilocks_data/$MY_POD_NAME/conf/odbc.ini

## Make goldilocks_data directory  - bskim
if [ ! -d "/home/sunje/goldilocks_data/$MY_POD_NAME" ];
then
    mkdir -p /home/sunje/goldilocks_data/$MY_POD_NAME
    export GOLDILOCKS_DATA=/home/sunje/goldilocks_data/$MY_POD_NAME
    cp /home/sunje/goldilocks_data/init-data/* /home/sunje/goldilocks_data/$MY_POD_NAME -R
    echo $GOLDILOCKS_DATA
else
    export GOLDILOCKS_DATA=/home/sunje/goldilocks_data/$MY_POD_NAME
fi


## Set Group name - bskim
## MY_POD_NAME : goldilocks-0
c=`echo $MY_POD_NAME | awk -F'-' '{print $2}'`
CLUSTER_CREATE_CHECK=$c 

## Set Master name(toUpper membername) - bskim
## MEMBER_NAME : GOLDILOCKS-0
lower_name=$MY_POD_NAME
MEMBER_NAME=${lower_name^^}

if [ $c -gt 2 ]; 
then
    GROUP_NAME=G2
    MASTER=$APP_NAME'-3'
    MASTER_OG=$APP_NAME'-0'
else
    ## GROUP_NAME : G1
    ## MASTER : GOLDILOCKS-0
    GROUP_NAME=G1
    MASTER=$APP_NAME'-0'
fi

## 공유 goldilocks_home/tmp/IP지정
## [root@tech10 tmp]# ls
## GOLDILOCKS-0  GOLDILOCKS-1  GOLDILOCKS-2  GOLDILOCKS-3  GOLDILOCKS-4
cat > /home/sunje/goldilocks_home/tmp/$MEMBER_NAME <<EOF
$MY_POD_IP
EOF



function init_cluster(){

## eq Master name - bskim 
if [ $MEMBER_NAME == $MASTER ];
then
    echo "-------------------------start master-------------------"
    ## lower_name=goldilocks-0
    ## GOLDILOCKS-0
    lower_name=$MY_POD_NAME
    MASTER_NAME=${lower_name^^}

    ## GROUP_NAME = G1 // DB만 Create 처리.
    if [ $GROUP_NAME == "G1" ]; 
    then
        gcreatedb --cluster --member "$MASTER_NAME" --host $MY_POD_IP --port $CLUSTER_PORT
        gsql sys gliese --as sysdba <<EOF
        STARTUP
        ALTER SYSTEM OPEN GLOBAL DATABASE;
        \q
        EOF

        ## Cluster Group 생성. : CREATE CLUSTER GROUP ....
        gsql sys gliese --as sysdba <<EOF
        CREATE CLUSTER GROUP $GROUP_NAME CLUSTER MEMBER "$MASTER_NAME" HOST '$MY_POD_IP' PORT $CLUSTER_PORT;
        CREATE TABLESPACE $TABLE_SPACE_NAME DATAFILE '$TABLE_SPACE_FILE_NAME' SIZE $TABLE_SPACE_SIZE;
        CREATE TEMPORARY TABLESPACE $TEMP_TABLESPACE_NAME MEMORY '$TEMP_TABLESPACE_FILE_NAME' SIZE $TEMP_TABLESPACE_SIZE;
        CREATE USER $SERVICE_ACCOUNT_NAME IDENTIFIED BY $SERVICE_ACCOUNT_PASSWD DEFAULT TABLESPACE $TABLE_SPACE_NAME TEMPORARY TABLESPACE $TEMP_TABLESPACE_NAME;
        GRANT ALL ON DATABASE TO $SERVICE_ACCOUNT_NAME;
        \q
        EOF

        gsql sys gliese --as sysdba -i $GOLDILOCKS_HOME/admin/cluster/DictionarySchema.sql --silent
        gsql sys gliese --as sysdba -i $GOLDILOCKS_HOME/admin/cluster/InformationSchema.sql --silent
        gsql sys gliese --as sysdba -i $GOLDILOCKS_HOME/admin/cluster/PerformanceViewSchema.sql --silent
    else
        ## G2 Group Member Create
        gcreatedb --cluster --member "$MASTER_NAME" --host $MY_POD_IP --port $CLUSTER_PORT
        gsql sys gliese --as sysdba <<EOF
        STARTUP
        ALTER SYSTEM OPEN GLOBAL DATABASE;
        CREATE TABLESPACE $TABLE_SPACE_NAME DATAFILE '$TABLE_SPACE_FILE_NAME' SIZE $TABLE_SPACE_SIZE;
        CREATE TEMPORARY TABLESPACE $TEMP_TABLESPACE_NAME MEMORY '$TEMP_TABLESPACE_FILE_NAME' SIZE $TEMP_TABLESPACE_SIZE;
        COMMIT;
        \q
        EOF

        MASTER_DNS=`cat /home/sunje/goldilocks_home/tmp/$MASTER_OG`
        cat > /home/sunje/goldilocks_data/$MY_POD_NAME/conf/odbc.ini <<EOF
        [$MASTER_OG]
        HOST=$MASTER_DNS
        PORT=22581
        EOF

        gsqlnet sys gliese --as sysdba --dsn=$MASTER_OG <<EOF
        CREATE CLUSTER GROUP $GROUP_NAME CLUSTER MEMBER "$MEMBER_NAME" HOST '$MY_POD_IP' PORT $CLUSTER_PORT;
        ALTER DATABASE REBALANCE;
        COMMIT;
        EOF

    fi

    echo "-------------------------end master-------------------"
else
    echo "-------------------------start slave-------------------"
    echo " MASTER_DNS=172.32.24.219(MASTER IP)"
    MASTER_DNS=`cat /home/sunje/goldilocks_home/tmp/$MASTER`

    cat > /home/sunje/goldilocks_data/$MY_POD_NAME/conf/odbc.ini <<EOF
    [$MASTER]
    HOST=$MASTER_DNS
    PORT=22581
    EOF

    ## MEMBER_NAME : GOLDILOCKS-1
    ## SLAVE Member DB Create
    gcreatedb --cluster --member $MEMBER_NAME --host $MY_POD_IP --port $CLUSTER_PORT
    gsql sys gliese --as sysdba <<EOF
    STARTUP
    ALTER SYSTEM OPEN GLOBAL DATABASE;
    CREATE TABLESPACE $TABLE_SPACE_NAME DATAFILE '$TABLE_SPACE_FILE_NAME' SIZE $TABLE_SPACE_SIZE;
    CREATE TEMPORARY TABLESPACE $TEMP_TABLESPACE_NAME MEMORY '$TEMP_TABLESPACE_FILE_NAME' SIZE $TEMP_TABLESPACE_SIZE;
    COMMIT;
    \q
    EOF

    
    echo "### CLUSTER_LOCAL_IP_ADDR[$MY_POD_IP]"
    echo "### --dsn=$MASTER 접속하여 해당 Group에 Member Slave Member 추가
    gsqlnet sys gliese --as sysdba  --dsn=$MASTER <<EOF
    ALTER CLUSTER GROUP $GROUP_NAME ADD CLUSTER MEMBER "$MEMBER_NAME" HOST '$MY_POD_IP' PORT $CLUSTER_PORT;
    ALTER DATABASE REBALANCE;
    COMMIT;
    EOF

    echo "-------------------------end slave-------------------"
fi

glsnr --start
glsnr --status

}


function start_cluster(){
    gsql sys gliese --as sysdba <<EOF
STARTUP
\q
EOF

  glsnr --start
  glsnr --status

}


DB=$GOLDILOCKS_DATA/db/system_data.dbf

if [ -f "$DB" ]; then
  start_cluster
else
  init_cluster
fi


tail -f $GOLDILOCKS_DATA/trc/system.trc
