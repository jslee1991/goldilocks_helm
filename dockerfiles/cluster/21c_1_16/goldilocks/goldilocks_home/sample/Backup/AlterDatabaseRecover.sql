--###################################################
--# ALTER DATABASE RECOVER : cannot recover at noarchivelog
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS TEST_TBS INCLUDING CONTENTS AND DATAFILES;
COMMIT;

--# result: success
ALTER SYSTEM LOOPBACK AGER;

--# result: success
CREATE TABLESPACE TEST_TBS DATAFILE 'test_file_1.dbf' SIZE 10M REUSE;
COMMIT;

--# result: success
\CONNECT AS SYSDBA
\SHUTDOWN
\STARTUP MOUNT

--# result: success
ALTER DATABASE NOARCHIVELOG;

--# result: error
ALTER DATABASE RECOVER;

--###################################################
--# ALTER DATABASE RECOVER
--###################################################

--# result: success
ALTER DATABASE ARCHIVELOG;

--# result: success
ALTER DATABASE RECOVER;

--###################################################
--# ALTER DATABASE RECOVER TABLESPACE
--###################################################

--# result: success
ALTER DATABASE RECOVER TABLESPACE TEST_TBS;

--###################################################
--# ALTER DATABASE RECOVER TABLESPACE during SERVICE : cannot RECOVER ONLINE TABLESPACE
--###################################################

--# result: success
ALTER SYSTEM OPEN DATABASE;

--# result: error
ALTER DATABASE RECOVER TABLESPACE TEST_TBS;

--###################################################
--# ALTER DATABASE RECOVER TABLESPACE during SERVICE
--###################################################

--# result: success
ALTER TABLESPACE TEST_TBS OFFLINE;

--# result: success
ALTER DATABASE RECOVER TABLESPACE TEST_TBS;

--# result: success
ALTER TABLESPACE TEST_TBS ONLINE;

--###################################################
--# ALTER DATABASE RECOVER DATAFILE during SERVICE : cannot RECOVER ONLINE TABLESPACE
--###################################################

--# result: success
ALTER DATABASE BACKUP INCREMENTAL LEVEL 0;

--# result: error
ALTER DATABASE RECOVER DATAFILE 'test_file_1.dbf';

--###################################################
--# ALTER DATABASE RECOVER DATAFILE during SERVICE
--###################################################

--# result: success
ALTER TABLESPACE TEST_TBS OFFLINE;

--# result: success
ALTER DATABASE RECOVER DATAFILE 'test_file_1.dbf';

--# result: success
ALTER TABLESPACE TEST_TBS ONLINE;

--###################################################
--# ALTER DATABASE NOARCHIVELOG
--###################################################

--# result: success
DROP TABLESPACE TEST_TBS INCLUDING CONTENTS AND DATAFILES;
COMMIT;

--# result: success
ALTER SYSTEM LOOPBACK AGER;

--# result: success
\CONNECT AS SYSDBA
\SHUTDOWN
\STARTUP MOUNT

--# result: success
ALTER DATABASE NOARCHIVELOG;

--# result: success
ALTER SYSTEM OPEN DATABASE;
