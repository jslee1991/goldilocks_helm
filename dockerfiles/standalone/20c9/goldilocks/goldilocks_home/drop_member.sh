#!/bin/bash

### accordion input value change ###
### c : member id                ###
### MY_POD_NAME -> MEMBER_NAME   ###
c=`echo $HOSTNAME | awk -F'-' '{print $2}'`
MY_POD_NAME=${HOSTNAME}
lower_name=$MY_POD_NAME
MEMBER_NAME=${lower_name^^}

### configure setup ####
source ~/.bashrc
set -euxo pipefail
GOLDILOCKS_HOME=/home/sunje/goldilocks_home
export ODBCINI=/home/sunje/goldilocks_data/$MY_POD_NAME/conf/odbc.ini
MASTER_NAME=$APP_NAME'-0'
MASTER_DNS=`cat /home/sunje/nfs_volumn/$MASTER_NAME`

### GROUP ID and Master Member ID set ###

### GSQL shutdown abort ###
gsql sys gliese --as sysdba <<EOF
alter system checkpoint;
alter system checkpoint;
alter system checkpoint;
shutdown abort;
\q
EOF

