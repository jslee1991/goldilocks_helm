--###################################################
--# ALTER TABLESPACE .. RENAME TO: simple example
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
DROP TABLESPACE IF EXISTS space2 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;

--# result: success
CREATE TABLESPACE space1 DATAFILE 'test_file_1.dbf' SIZE 10M REUSE;
COMMIT;



--# result: success
ALTER TABLESPACE space1 RENAME TO space2;
COMMIT;



--# result: success
DROP TABLESPACE space2 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;



--###################################################
--# ALTER TABLESPACE .. RENAME TO: with <tablespace_name>
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
DROP TABLESPACE IF EXISTS space2 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;


--# result: success
CREATE TABLESPACE space1 DATAFILE 'test_file_2.dbf' SIZE 10M REUSE;
COMMIT;



--# result: success
ALTER TABLESPACE space1 OFFLINE;
COMMIT;

--# result: error
ALTER TABLESPACE space1 RENAME TO space2;
COMMIT;



--# result: success
ALTER TABLESPACE space1 ONLINE;
COMMIT;

--# result: success
ALTER TABLESPACE space1 RENAME TO space2;
COMMIT;




--# result: success
DROP TABLESPACE space2 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;
