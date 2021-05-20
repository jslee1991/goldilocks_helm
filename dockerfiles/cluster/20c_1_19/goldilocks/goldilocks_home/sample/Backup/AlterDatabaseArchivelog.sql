--###################################################
--# ALTER DATABASE ARCHIVELOG
--###################################################

--# result: success
\CONNECT AS SYSDBA
\SHUTDOWN
\STARTUP MOUNT

--# result: success
ALTER DATABASE ARCHIVELOG;

--# result: success
ALTER SYSTEM OPEN DATABASE;

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
