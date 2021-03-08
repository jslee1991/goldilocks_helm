#!/bin/bash
source ~/.bashrc
set -euxo pipefail

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
GROUP_NAME=${GROUP_NAME:-G1}
MEMBER_NAME=${MEMBER_NAME:-G1N1}
CLUSTER_IP_ADDR=${CLUSTER_IP_ADDR:-127.0.0.1}
CLUSTER_PORT=${CLUSTER_PORT:-10101}
CLUSTER_MASTER_IP_ADDR=${CLUSTER_MASTER_IP_ADDR:-127.0.0.1}
CLUSTER_MASTER_PORT=${CLUSTER_MASTER_PORT:-10101}

function init_cluster(){

  gcreatedb --cluster --member $MEMBER_NAME --host $MY_POD_IP

  gsql sys gliese --as sysdba <<EOF
STARTUP
ALTER SYSTEM OPEN GLOBAL DATABASE;
CREATE TABLESPACE $TABLE_SPACE_NAME DATAFILE '$TABLE_SPACE_FILE_NAME' SIZE $TABLE_SPACE_SIZE;
CREATE TEMPORARY TABLESPACE $TEMP_TABLESPACE_NAME MEMORY '$TEMP_TABLESPACE_FILE_NAME' SIZE $TEMP_TABLESPACE_SIZE;

\q
EOF

  if [[ $MEMBER_NAME == *"N1"* ]] || [[] $MEMBER_NAME == *"n1"* ]]; then

    if [ "$MEMBER_NAME" == "g1n1" ] || [ "$MEMBER_NAME" == "G1N1" ]; then
    gsql sys gliese --as sysdba <<EOF
CREATE CLUSTER GROUP $GROUP_NAME CLUSTER MEMBER $MEMBER_NAME HOST '$MY_POD_IP' PORT 10101;
CREATE USER $SERVICE_ACCOUNT_NAME IDENTIFIED BY $SERVICE_ACCOUNT_PASSWD DEFAULT TABLESPACE $TABLE_SPACE_NAME TEMPORARY TABLESPACE $TEMP_TABLESPACE_NAME;
GRANT ALL ON DATABASE TO $SERVICE_ACCOUNT_NAME;
\q
EOF

    else 

    echo "HOST=""$CLUSTER_MASTER_IP_ADDR" >> ~/.odbc.ini
     echo "PORT=22581" >> ~/.odbc.ini
     # join slave node 
     gsqlnet sys gliese --as sysdba --dsn=G1N1 <<EOF
     CREATE CLUSTER GROUP $GROUP_NAME CLUSTER MEMBER $MEMBER_NAME HOST '$MY_POD_IP' PORT 10101;
\q
EOF
    fi

  else
   echo "HOST=""$CLUSTER_MASTER_IP_ADDR" >> ~/.odbc.ini
     echo "PORT=22581" >> ~/.odbc.ini
     # join slave node 
     gsqlnet sys gliese --as sysdba --dsn=G1N1 <<EOF
ALTER CLUSTER GROUP $GROUP_NAME ADD CLUSTER MEMBER $MEMBER_NAME HOST '$MY_POD_IP' PORT 10101;
\q
EOF
  
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

DB=$GOLDILOCKS_DATA/db/$TABLE_SPACE_FILE_NAME

if [ -f "$DB" ]; then

  start_cluster

else

  init_cluster

fi
