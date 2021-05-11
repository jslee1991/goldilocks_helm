--###################################################
--# ALTER TABLESPACE .. ONLINE/OFFLINE: simple example
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;

--# result: success
CREATE TABLESPACE space1 DATAFILE 'test_file_01.dbf' SIZE 10M REUSE;
COMMIT;



--# result: success
ALTER TABLESPACE space1 OFFLINE;
COMMIT;


--# result: success
ALTER TABLESPACE space1 ONLINE;
COMMIT;



--# result: success
DROP TABLESPACE space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;




--###################################################
--# ALTER TABLESPACE .. ONLINE/OFFLINE: with <ONLINE>
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;

--# result: success
CREATE TABLESPACE space1 DATAFILE 'test_file_02.dbf' SIZE 10M REUSE;
COMMIT;




--# result: success
ALTER TABLESPACE space1 ONLINE;
COMMIT;


--# result: success
ALTER TABLESPACE space1 OFFLINE;
COMMIT;


--# result: success
ALTER TABLESPACE space1 ONLINE;
COMMIT;




--# result: success
DROP TABLESPACE space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;





--###################################################
--# ALTER TABLESPACE .. ONLINE/OFFLINE: with <OFFLINE [NORMAL|IMMEDIATE]>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;

--# result: success
CREATE TABLESPACE space1 DATAFILE 'test_file_03.dbf' SIZE 10M REUSE;
COMMIT;





--# result: success
ALTER TABLESPACE space1 OFFLINE NORMAL;
COMMIT;

--# result: error
CREATE TABLE t1 ( id INTEGER ) TABLESPACE space1;




--# result: success
DROP TABLESPACE space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;



