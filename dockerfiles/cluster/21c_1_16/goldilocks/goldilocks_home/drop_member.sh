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
gloctl -i $MASTER_DNS -p 42581 <<EOF
drop member '$MEMBER_NAME'
quit;
EOF

case $c in
0)
    GROUP_NAME=G1
    MASTER=$APP_NAME'-0'
echo " Member ID [$MEMBER_NAME][$c]"
echo ""

### GSQL shutdown abort ###
gsql sys gliese --as sysdba <<EOF
shutdown abort;
\q
EOF
;;
1)
    GROUP_NAME=G1
    MASTER=$APP_NAME'-0'
echo " Member ID [$MEMBER_NAME][$c]"
echo ""
### GSQL shutdown abort ###
gsql sys gliese --as sysdba <<EOF
shutdown abort;
\q
EOF

# fail-over delay time
sleep 5;

### Cluster Member drop ###
gsqlnet sys gliese --as sysdba --dsn=$MASTER << EOF
alter database drop inactive cluster members;
select member_id, member_position, logical_connection from x\$cluster_member@local;
\q
EOF
echo "[$MEMBER_NAME][$c] [END] : member shutdown & inactive member drop";

echo " Group Processor Error"
echo " Member ID [$MEMBER_NAME][$c]";;
2)
    GROUP_NAME=G2
    MASTER=$APP_NAME'-2'
    MASTER_OG=$APP_NAME'-0'
echo " Member ID [$MEMBER_NAME][$c]"
echo ""

### Cluster Group drop ###
gsqlnet sys gliese --as sysdba --dsn=$MASTER_OG << EOF
ALTER DATABASE REBALANCE EXCLUDE CLUSTER GROUP $GROUP_NAME;
DROP CLUSTER GROUP G2;
\q
EOF

# fail-over delay time
sleep 5;

gsql sys gliese --as sysdba <<EOF
shutdown abort;
\q
EOF

echo "[$MEMBER_NAME][$c] [END] : member shutdown & group drop";;
3)
    GROUP_NAME=G2
    MASTER=$APP_NAME'-2'
    MASTER_OG=$APP_NAME'-0'
echo " Member ID [$MEMBER_NAME][$c]"
echo ""
### GSQL shutdown abort ###
gsql sys gliese --as sysdba <<EOF
shutdown abort;
\q
EOF

# fail-over delay time
sleep 5;

### Cluster Member drop ###
gsqlnet sys gliese --as sysdba --dsn=$MASTER << EOF
alter database drop inactive cluster members;
select member_id, member_position, logical_connection from x\$cluster_member@local;
\q
EOF
echo "[$MEMBER_NAME][$c] [END] : member shutdown & inactive member drop";

echo " Group Processor Error"
echo " Member ID [$MEMBER_NAME][$c]";;
4)
    GROUP_NAME=G3
    MASTER=$APP_NAME'-4'
    MASTER_OG=$APP_NAME'-0'
echo " Member ID [$MEMBER_NAME][$c]"
echo ""

### Cluster Group drop ###
gsqlnet sys gliese --as sysdba --dsn=$MASTER_OG << EOF
ALTER DATABASE REBALANCE EXCLUDE CLUSTER GROUP $GROUP_NAME;
DROP CLUSTER GROUP G3;
\q
EOF

# fail-over delay time
sleep 5;

gsql sys gliese --as sysdba <<EOF
shutdown abort;
\q
EOF

echo "[$MEMBER_NAME][$c] [END] : member shutdown & group drop";;
5)
    GROUP_NAME=G3
    MASTER=$APP_NAME'-4'
    MASTER_OG=$APP_NAME'-0'
echo " Member ID [$MEMBER_NAME][$c]"
echo ""
### GSQL shutdown abort ###
gsql sys gliese --as sysdba <<EOF
shutdown abort;
\q
EOF

# fail-over delay time
sleep 5;

### Cluster Member drop ###
gsqlnet sys gliese --as sysdba --dsn=$MASTER << EOF
alter database drop inactive cluster members;
select member_id, member_position, logical_connection from x\$cluster_member@local;
\q
EOF
echo "[$MEMBER_NAME][$c] [END] : member shutdown & inactive member drop";

echo " Group Processor Error"
echo " Member ID [$MEMBER_NAME][$c]";;
6)
    GROUP_NAME=G4
    MASTER=$APP_NAME'-6'
    MASTER_OG=$APP_NAME'-0'
echo " Member ID [$MEMBER_NAME][$c]"
echo ""

### Cluster Group drop ###
gsqlnet sys gliese --as sysdba --dsn=$MASTER_OG << EOF
ALTER DATABASE REBALANCE EXCLUDE CLUSTER GROUP $GROUP_NAME;
DROP CLUSTER GROUP G4;
\q
EOF

# fail-over delay time
sleep 5;

gsql sys gliese --as sysdba <<EOF
shutdown abort;
\q
EOF

echo "[$MEMBER_NAME][$c] [END] : member shutdown & group drop";;
7)
    GROUP_NAME=G4
    MASTER=$APP_NAME'-6'
    MASTER_OG=$APP_NAME'-0'
echo " Member ID [$MEMBER_NAME][$c]"
echo ""
### GSQL shutdown abort ###
gsql sys gliese --as sysdba <<EOF
shutdown abort;
\q
EOF

# fail-over delay time
sleep 5;

### Cluster Member drop ###
gsqlnet sys gliese --as sysdba --dsn=$MASTER << EOF
alter database drop inactive cluster members;
select member_id, member_position, logical_connection from x\$cluster_member@local;
\q
EOF
echo "[$MEMBER_NAME][$c] [END] : member shutdown & inactive member drop";

echo " Group Processor Error"
echo " Member ID [$MEMBER_NAME][$c]";;

8)
    GROUP_NAME=G5
    MASTER=$APP_NAME'-8'
    MASTER_OG=$APP_NAME'-0'
echo " Member ID [$MEMBER_NAME][$c]"
echo ""

### Cluster Group drop ###
gsqlnet sys gliese --as sysdba --dsn=$MASTER_OG << EOF
ALTER DATABASE REBALANCE EXCLUDE CLUSTER GROUP $GROUP_NAME;
DROP CLUSTER GROUP G5;
\q
EOF

# fail-over delay time
sleep 5;

gsql sys gliese --as sysdba <<EOF
shutdown abort;
\q
EOF

echo "[$MEMBER_NAME][$c] [END] : member shutdown & group drop";;
9)
    GROUP_NAME=G5
    MASTER=$APP_NAME'-8'
    MASTER_OG=$APP_NAME'-0'
echo " Member ID [$MEMBER_NAME][$c]"
echo ""
### GSQL shutdown abort ###
gsql sys gliese --as sysdba <<EOF
shutdown abort;
\q
EOF

# fail-over delay time
sleep 5;

### Cluster Member drop ###
gsqlnet sys gliese --as sysdba --dsn=$MASTER << EOF
alter database drop inactive cluster members;
select member_id, member_position, logical_connection from x\$cluster_member@local;
\q
EOF
echo "[$MEMBER_NAME][$c] [END] : member shutdown & inactive member drop";

echo " Group Processor Error"
echo " Member ID [$MEMBER_NAME][$c]";;
10)
    GROUP_NAME=G6
    MASTER=$APP_NAME'-10'
    MASTER_OG=$APP_NAME'-0'
echo " Member ID [$MEMBER_NAME][$c]"
echo ""

### Cluster Group drop ###
gsqlnet sys gliese --as sysdba --dsn=$MASTER_OG << EOF
ALTER DATABASE REBALANCE EXCLUDE CLUSTER GROUP $GROUP_NAME;
DROP CLUSTER GROUP G6;
\q
EOF

# fail-over delay time
sleep 5;

gsql sys gliese --as sysdba <<EOF
shutdown abort;
\q
EOF

echo "[$MEMBER_NAME][$c] [END] : member shutdown & group drop";;
11)
    GROUP_NAME=G6
    MASTER=$APP_NAME'-10'
    MASTER_OG=$APP_NAME'-0'
echo " Member ID [$MEMBER_NAME][$c]"
echo ""
### GSQL shutdown abort ###
gsql sys gliese --as sysdba <<EOF
shutdown abort;
\q
EOF

# fail-over delay time
sleep 5;

### Cluster Member drop ###
gsqlnet sys gliese --as sysdba --dsn=$MASTER << EOF
alter database drop inactive cluster members;
select member_id, member_position, logical_connection from x\$cluster_member@local;
\q
EOF
echo "[$MEMBER_NAME][$c] [END] : member shutdown & inactive member drop";

echo " Group Processor Error"
echo " Member ID [$MEMBER_NAME][$c]";;
esac


