--###################################################
--# ALTER DATABASE {BEGIN | END} BACKUP : cannot backup at noarchivelog
--###################################################

--# result: success
\CONNECT AS SYSDBA
\SHUTDOWN
\STARTUP MOUNT

--# result: success
ALTER DATABASE NOARCHIVELOG;

--# result: success
ALTER SYSTEM OPEN DATABASE;

--# result: error
ALTER DATABASE BEGIN BACKUP;

--# result: error
ALTER DATABASE END BACKUP;

--###################################################
--# ALTER DATABASE {BEGIN | END} BACKUP
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
ALTER DATABASE BEGIN BACKUP;

--# result: success
ALTER DATABASE END BACKUP;

--###################################################
--# ALTER DATABASE BACKUP INCREMENTAL LEVEL # (0 ~ 4)
--###################################################

--# result: success
ALTER DATABASE BACKUP INCREMENTAL LEVEL 0;

--# result: success
ALTER DATABASE BACKUP INCREMENTAL LEVEL 1;

--# result: success
ALTER DATABASE BACKUP INCREMENTAL LEVEL 2;

--# result: success
ALTER DATABASE BACKUP INCREMENTAL LEVEL 3;

--# result: success
ALTER DATABASE BACKUP INCREMENTAL LEVEL 4;

--# result: success
ALTER DATABASE BACKUP INCREMENTAL LEVEL 1 CUMULATIVE;

--# result: success
ALTER DATABASE BACKUP INCREMENTAL LEVEL 1 DIFFERENTIAL;

--# result: success
ALTER DATABASE DELETE ALL BACKUP LIST INCLUDING BACKUP FILES;

--# result: success
ALTER DATABASE DELETE OBSOLETE BACKUP LIST INCLUDING BACKUP FILES;

--###################################################
--# ALTER DATABASE BACKUP CONTROLFILE
--###################################################

--# result: success
ALTER DATABASE BACKUP CONTROLFILE TO 'control.bak';

--###################################################
--# ALTER DATABASE NOARCHIVELOG
--###################################################

--# result: success
\CONNECT AS SYSDBA
\SHUTDOWN
\STARTUP MOUNT

--# result: success
ALTER DATABASE NOARCHIVELOG;

--# result: success
ALTER SYSTEM OPEN DATABASE;
