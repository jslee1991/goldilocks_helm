#!/bin/bash

rm ~/.bashrc
cp /home/sunje/goldilocks_home/bashrc-init ~/.bashrc
cp /home/sunje/goldilocks_home/gsql.ini ~/.gsql.ini
#cp /home/sunje/goldilocks_home/goldilocks_cluster_standard_v1.0.tar.gz ~/
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
# cluster port                : CLUSTER_PORT              : default 10101

#MY_POD_NAME=goldilocks-0
#APP_NAME=GOLDILOCKS
#MY_POD_IP=127.0.0.1

TABLE_SPACE_SIZE=${TABLE_SPACE_SIZE:-3G}
TABLE_UNDO_SIZE=${TABLE_UNDO_SIZE:-128M}
TABLE_SPACE_NAME=${TABLE_SPACE_NAME:-MEM_DATA_TBS}
TABLE_UNDO_NAME=${TABLE_UNDO_NAME:-MEM_UNDO_TBS}
TABLE_SPACE_FILE_NAME=${TABLE_SPACE_FILE_NAME:-data_01.dbf}
TABLE_UNDO_FILE_NAME=${TABLE_UNDO_FILE_NAME:-undo_01.dbf}
TEMP_TABLESPACE_SIZE=${TEMP_TABLESPACE_SIZE:-1G}
TEMP_TABLESPACE_NAME=${TEMP_TABLESPACE_NAME:-MEM_TEMP_TBS}
TEMP_TABLESPACE_FILE_NAME=${TEMP_TABLESPACE_FILE_NAME:-temp_01}
SERVICE_ACCOUNT_NAME=${SERVICE_ACCOUNT_NAME:-SA}
SERVICE_ACCOUNT_PASSWD=${SERVICE_ACCOUNT_PASSWD:-passwd}
CLUSTER_PORT=${CLUSTER_PORT:-10101}
GOLDILOCKS_HOME=/home/sunje/goldilocks_home
export ODBCINI=/home/sunje/goldilocks_data/$MY_POD_NAME/conf/odbc.ini


# Kubernetes stop 없으므로 무조건 삭제 -shw-
rm -rf /home/sunje/goldilocks_data/$MY_POD_NAME
mkdir -p /home/sunje/goldilocks_data/$MY_POD_NAME
export GOLDILOCKS_DATA=/home/sunje/goldilocks_data/$MY_POD_NAME
cp /home/sunje/goldilocks_data/init-data/* /home/sunje/goldilocks_data/$MY_POD_NAME -R
echo $GOLDILOCKS_DATA

c=`echo $MY_POD_NAME | awk -F'-' '{print $2}'`

lower_name=$MY_POD_NAME
MEMBER_NAME=${lower_name^^}

if [ $c -gt 1 ];
then
    GROUP_NAME=G2
    MASTER=$APP_NAME'-2'
    MASTER_OG=$APP_NAME'-0'
else
    GROUP_NAME=G1
    MASTER=$APP_NAME'-0'
fi

cat > /home/sunje/nfs_volumn/$MEMBER_NAME <<EOF
$MY_POD_IP
EOF


function init_cluster(){
if [ $MEMBER_NAME == $MASTER ];
then
    echo "-------------------------start master-------------------"
    lower_name=$MY_POD_NAME
    MASTER_NAME=${lower_name^^}

    if [ $GROUP_NAME == "G1" ];
    then
    gcreatedb --cluster --member "$MASTER_NAME" --host $MY_POD_IP --port $CLUSTER_PORT

gsql sys gliese --as sysdba <<EOF
STARTUP
ALTER SYSTEM OPEN GLOBAL DATABASE;
\q
EOF

gsql sys gliese --as sysdba <<EOF
CREATE CLUSTER GROUP $GROUP_NAME CLUSTER MEMBER "$MASTER_NAME" HOST '$MY_POD_IP' PORT $CLUSTER_PORT;
ALTER TABLESPACE $TABLE_SPACE_NAME ADD DATAFILE '$TABLE_SPACE_FILE_NAME' SIZE $TABLE_SPACE_SIZE;
ALTER TABLESPACE $TABLE_UNDO_NAME ADD DATAFILE '$TABLE_UNDO_FILE_NAME' SIZE $TABLE_UNDO_SIZE;
ALTER TABLESPACE $TEMP_TABLESPACE_NAME ADD MEMORY '$TEMP_TABLESPACE_FILE_NAME' SIZE $TEMP_TABLESPACE_SIZE;
CREATE USER $SERVICE_ACCOUNT_NAME IDENTIFIED BY $SERVICE_ACCOUNT_PASSWD DEFAULT TABLESPACE $TABLE_SPACE_NAME TEMPORARY TABLESPACE $TEMP_TABLESPACE_NAME;
GRANT ALL ON DATABASE TO $SERVICE_ACCOUNT_NAME;
ALTER DATABASE REBALANCE;
\q
EOF

    gsql sys gliese --as sysdba -i $GOLDILOCKS_HOME/admin/cluster/DictionarySchema.sql --silent
    gsql sys gliese --as sysdba -i $GOLDILOCKS_HOME/admin/cluster/InformationSchema.sql --silent
    gsql sys gliese --as sysdba -i $GOLDILOCKS_HOME/admin/cluster/PerformanceViewSchema.sql --silent

else

gcreatedb --cluster --member "$MASTER_NAME" --host $MY_POD_IP --port $CLUSTER_PORT
gsql sys gliese --as sysdba <<EOF
STARTUP
ALTER SYSTEM OPEN GLOBAL DATABASE;
ALTER TABLESPACE $TABLE_SPACE_NAME ADD DATAFILE '$TABLE_SPACE_FILE_NAME' SIZE $TABLE_SPACE_SIZE;
ALTER TABLESPACE $TABLE_UNDO_NAME ADD DATAFILE '$TABLE_UNDO_FILE_NAME' SIZE $TABLE_UNDO_SIZE;
ALTER TABLESPACE $TEMP_TABLESPACE_NAME ADD MEMORY '$TEMP_TABLESPACE_FILE_NAME' SIZE $TEMP_TABLESPACE_SIZE;
COMMIT;
\q
EOF

MASTER_DNS=`cat /home/sunje/nfs_volumn/$MASTER_OG`
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
    MASTER_DNS=`cat /home/sunje/nfs_volumn/$MASTER`

cat > /home/sunje/goldilocks_data/$MY_POD_NAME/conf/odbc.ini <<EOF
[$MASTER]
HOST=$MASTER_DNS
PORT=22581
EOF

gcreatedb --cluster --member $MEMBER_NAME --host $MY_POD_IP --port $CLUSTER_PORT
gsql sys gliese --as sysdba <<EOF
STARTUP
ALTER SYSTEM OPEN GLOBAL DATABASE;
ALTER TABLESPACE $TABLE_SPACE_NAME ADD DATAFILE '$TABLE_SPACE_FILE_NAME' SIZE $TABLE_SPACE_SIZE;
ALTER TABLESPACE $TABLE_UNDO_NAME ADD DATAFILE '$TABLE_UNDO_FILE_NAME' SIZE $TABLE_UNDO_SIZE;
ALTER TABLESPACE $TEMP_TABLESPACE_NAME ADD MEMORY '$TEMP_TABLESPACE_FILE_NAME' SIZE $TEMP_TABLESPACE_SIZE;
COMMIT;
\q
EOF


echo "### CLUSTER_LOCAL_IP_ADDR[$MY_POD_IP]"
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

# DB CREATE START
init_cluster

tail -f $GOLDILOCKS_DATA/trc/system.trc
