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

c=`echo $HOSTNAME | awk -F'-' '{print $2}'`
MY_NAMESPACE=`echo $(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)`
MY_POD_NAME=${HOSTNAME}
lower_name=$MY_POD_NAME
MEMBER_NAME=${lower_name^^}
MY_MEMBER_NO=$((c+1))

#환경 설정 값이 있으면 ENV에 있는 값으로 없으면 아래 정의 되어 있는 값으로 한다.
TABLE_SPACE_SIZE=${TABLE_SPACE_SIZE:-100M}
TABLE_UNDO_SIZE=${TABLE_UNDO_SIZE:-128M}
TABLE_SPACE_NAME=${TABLE_SPACE_NAME:-MEM_DATA_TBS}
TABLE_UNDO_NAME=${TABLE_UNDO_NAME:-MEM_UNDO_TBS}
TABLE_SPACE_FILE_NAME=${TABLE_SPACE_FILE_NAME:-data_01.dbf}
TABLE_UNDO_FILE_NAME=${TABLE_UNDO_FILE_NAME:-undo_01.dbf}
TEMP_TABLESPACE_SIZE=${TEMP_TABLESPACE_SIZE:-100M}
TEMP_TABLESPACE_NAME=${TEMP_TABLESPACE_NAME:-MEM_TEMP_TBS}
TEMP_TABLESPACE_FILE_NAME=${TEMP_TABLESPACE_FILE_NAME:-temp_01}
SERVICE_ACCOUNT_NAME=${SERVICE_ACCOUNT_NAME:-SA}
SERVICE_ACCOUNT_PASSWD=${SERVICE_ACCOUNT_PASSWD:-passwd}
CLUSTER_PORT=${CLUSTER_PORT:-10101}
GOLDILOCKS_HOME=/home/sunje/goldilocks_home
export ODBCINI=/home/sunje/goldilocks_data/$MY_NAMESPACE/$MY_POD_NAME/conf/odbc.ini

echo $GOLDILOCKS_DATA
echo $SERVICE_ACCOUNT_NAME
echo $SERVICE_ACCOUNT_PASSWD
echo $TABLE_SPACE_SIZE
echo $TABLE_UNDO_SIZE
echo $TEMP_TABLESPACE_SIZE

# Kubernetes stop 없으므로 무조건 삭제 -shw-
rm -rf /home/sunje/goldilocks_data/$MY_NAMESPACE/$MY_POD_NAME
mkdir -p /home/sunje/goldilocks_data/$MY_NAMESPACE/$MY_POD_NAME
mkdir -p /home/sunje/nfs_volumn/$MY_NAMESPACE
export GOLDILOCKS_DATA=/home/sunje/goldilocks_data/$MY_NAMESPACE/$MY_POD_NAME
cp /home/sunje/goldilocks_data_create/init-data/* /home/sunje/goldilocks_data/$MY_NAMESPACE/$MY_POD_NAME -R


function init_cluster(){

    gcreatedb

gsql sys gliese --as sysdba <<EOF
STARTUP
\q
EOF

gsql sys gliese --as sysdba <<EOF
ALTER TABLESPACE $TABLE_SPACE_NAME ADD DATAFILE '$TABLE_SPACE_FILE_NAME' SIZE $TABLE_SPACE_SIZE;
ALTER TABLESPACE $TABLE_UNDO_NAME ADD DATAFILE '$TABLE_UNDO_FILE_NAME' SIZE $TABLE_UNDO_SIZE;
ALTER TABLESPACE $TEMP_TABLESPACE_NAME ADD MEMORY '$TEMP_TABLESPACE_FILE_NAME' SIZE $TEMP_TABLESPACE_SIZE;
CREATE USER $SERVICE_ACCOUNT_NAME IDENTIFIED BY $SERVICE_ACCOUNT_PASSWD DEFAULT TABLESPACE $TABLE_SPACE_NAME TEMPORARY TABLESPACE $TEMP_TABLESPACE_NAME;
GRANT ALL ON DATABASE TO $SERVICE_ACCOUNT_NAME;
CONNECT $SERVICE_ACCOUNT_NAME $SERVICE_ACCOUNT_PASSWD;
$CREATE_TABLE_QUERY;

\q
EOF

    gsql sys gliese --as sysdba -i $GOLDILOCKS_HOME/admin/standalone/DictionarySchema.sql --silent
    gsql sys gliese --as sysdba -i $GOLDILOCKS_HOME/admin/standalone/InformationSchema.sql --silent
    gsql sys gliese --as sysdba -i $GOLDILOCKS_HOME/admin/standalone/PerformanceViewSchema.sql --silent

glsnr --start
glsnr --status

}

# DB CREATE START

init_cluster

tail -f $GOLDILOCKS_DATA/trc/system.trc

