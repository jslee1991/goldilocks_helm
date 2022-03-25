--###################################################
--# ALTER TABLESPACE tablespace_name {BEGIN | END} BACKUP : cannot backup at noarchivelog
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

--# result: success
ALTER SYSTEM OPEN DATABASE;

--# result: error
ALTER TABLESPACE TEST_TBS BEGIN BACKUP;

--# result: error
ALTER TABLESPACE TEST_TBS END BACKUP;

--###################################################
--# ALTER TABLESPACE {BEGIN | END} BACKUP
--###################################################

--# result: success
\CONNECT AS SYSDBA
\SHUTDOWN
\STARTUP MOUNT

--# result: success
ALTER DATABASE ARCHIVELOG;

--# result: success
ALTER SYSTEM OPEN DATABASE;

--# result: success
ALTER TABLESPACE TEST_TBS BEGIN BACKUP;

--# result: success
ALTER TABLESPACE TEST_TBS END BACKUP;

--###################################################
--# ALTER TABLESPACE tablespace_name BACKUP INCREMENTAL LEVEL # (0 ~ 4)
--###################################################

--# result: success
ALTER TABLESPACE TEST_TBS BACKUP INCREMENTAL LEVEL 0;

--# result: success
ALTER TABLESPACE TEST_TBS BACKUP INCREMENTAL LEVEL 1;

--# result: success
ALTER TABLESPACE TEST_TBS BACKUP INCREMENTAL LEVEL 2;

--# result: success
ALTER TABLESPACE TEST_TBS BACKUP INCREMENTAL LEVEL 3;

--# result: success
ALTER TABLESPACE TEST_TBS BACKUP INCREMENTAL LEVEL 4;

--# result: success
ALTER TABLESPACE TEST_TBS BACKUP INCREMENTAL LEVEL 1 CUMULATIVE;

--# result: success
ALTER TABLESPACE TEST_TBS BACKUP INCREMENTAL LEVEL 1 DIFFERENTIAL;

--# result: success
ALTER DATABASE DELETE ALL BACKUP LIST INCLUDING BACKUP FILES;

--# result: success
ALTER DATABASE DELETE OBSOLETE BACKUP LIST INCLUDING BACKUP FILES;

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
