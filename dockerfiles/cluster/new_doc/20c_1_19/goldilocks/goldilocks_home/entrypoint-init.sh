rm ~/.bashrc
cp /home/sunje/goldilocks_home/bashrc-init ~/.bashrc
cp /home/sunje/goldilocks_home/gsql.ini ~/.gsql.ini
#cp /home/sunje/goldilocks_home/goldilocks_cluster_standard_v1.0.tar.gz ~/
source ~/.bashrc

set -euxo pipefail


MY_POD_NAME=${HOSTNAME}
MY_NAMESPACE=`echo $(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)`
lower_name=$MY_POD_NAME
MEMBER_NAME=${lower_name^^}
c=`echo $HOSTNAME | awk -F'-' '{print $2}'`
MASTER=G1N1
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
MEMBER_COUNT=${MEMBER_COUNT:-2}
GOLDILOCKS_HOME=/home/sunje/goldilocks_home
GROUP=G$(($c/$MEMBER_COUNT+1))
MEMBER=N$(($c%MEMBER_COUNT+1))
MEMBER_NAME=$GROUP$MEMBER

if [ ! -d "/home/sunje/goldilocks_data/$MY_POD_NAME" ];
then
    mkdir -p /home/sunje/goldilocks_data/$MY_NAMESPACE/$MY_POD_NAME
    export GOLDILOCKS_DATA=/home/sunje/goldilocks_data/$MY_NAMESPACE/$MY_POD_NAME
    cp /home/sunje/goldilocks_data/init-data/* /home/sunje/goldilocks_data/$MY_NAMESPACE/$MY_POD_NAME -R
    echo $GOLDILOCKS_DATA
else
    export GOLDILOCKS_DATA=/home/sunje/goldilocks_data/$MY_NAMESPACE/$MY_POD_NAME
fi



MASTER_DNS=$(env | grep MASTER | grep 22581 | grep ADDR | cut -d '=' -f2)
cat > /home/sunje/goldilocks_data/$MY_NAMESPACE/$MY_POD_NAME/conf/odbc.ini <<EOF
[G1N1]
HOST=$MASTER_DNS
PORT=22581
EOF

export ODBCINI=/home/sunje/goldilocks_data/$MY_NAMESPACE/$MY_POD_NAME/conf/odbc.ini

if [ `echo "$(($c%$MEMBER_COUNT))"` -eq 0 ];
then

    if [ $MEMBER_NAME == 'G1N1' ];
    then
        echo "-------------------------start G1N1-------------------"
        gcreatedb --cluster --member "$MEMBER_NAME" --host $MY_POD_IP --port $CLUSTER_PORT

        gsql sys gliese --as sysdba <<EOF
        STARTUP
        ALTER SYSTEM OPEN GLOBAL DATABASE;
        \q
EOF

        gsql sys gliese --as sysdba <<EOF
        CREATE CLUSTER GROUP $GROUP CLUSTER MEMBER "$MEMBER_NAME" HOST '$MY_POD_IP' PORT $CLUSTER_PORT;
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

        # glocator create & start
        glocator --create
        glocator --start

        gloctl <<EOF
        ADD MEMBER '$MEMBER_NAME' 'HOST=$MY_POD_IP;PORT=22581';
        QUIT;
EOF

    else 
        echo "-------------------------start MASTER(NOT G1N1)-------------------"
        gcreatedb --cluster --member "$MEMBER_NAME" --host $MY_POD_IP --port $CLUSTER_PORT
        gsql sys gliese --as sysdba <<EOF
        STARTUP
        ALTER SYSTEM OPEN GLOBAL DATABASE;
        ALTER TABLESPACE $TABLE_SPACE_NAME ADD DATAFILE '$TABLE_SPACE_FILE_NAME' SIZE $TABLE_SPACE_SIZE;
        ALTER TABLESPACE $TABLE_UNDO_NAME ADD DATAFILE '$TABLE_UNDO_FILE_NAME' SIZE $TABLE_UNDO_SIZE;
        ALTER TABLESPACE $TEMP_TABLESPACE_NAME ADD MEMORY '$TEMP_TABLESPACE_FILE_NAME' SIZE $TEMP_TABLESPACE_SIZE;

        COMMIT;
        \q
EOF

        gsqlnet sys gliese --as sysdba --dsn=G1N1 <<EOF
        CREATE CLUSTER GROUP $GROUP CLUSTER MEMBER "$MEMBER_NAME" HOST '$MY_POD_IP' PORT $CLUSTER_PORT;
        ALTER DATABASE REBALANCE;
        COMMIT;
EOF

        gloctl -i $MASTER_DNS -p 42581 <<EOF
        ADD MEMBER '$MEMBER_NAME' 'HOST=$MY_POD_IP;PORT=22581';
        QUIT;
EOF

fi

else
    echo "-------------------------start slave-------------------"

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

    gsqlnet sys gliese --as sysdba --dsn=G1N1 <<EOF
    ALTER CLUSTER GROUP $GROUP ADD CLUSTER MEMBER "$MEMBER_NAME" HOST '$MY_POD_IP' PORT $CLUSTER_PORT;
    ALTER DATABASE REBALANCE;
    COMMIT;
EOF

    gloctl -i $MASTER_DNS -p 42581 <<EOF
    ADD MEMBER '$MEMBER_NAME' 'HOST=$MY_POD_IP;PORT=22581';
    QUIT;
EOF

fi

tail -f $GOLDILOCKS_DATA/trc/system.trc

