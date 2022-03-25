--###################################################
--# DROP TABLESPACE: simple example
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;





--# result: success
CREATE TABLESPACE space1 DATAFILE 'test_data_1.dbf' SIZE 10M REUSE;
COMMIT;


--# result: success
DROP TABLESPACE space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;



--###################################################
--# DROP TABLESPACE: with <IF EXISTS>
--###################################################


--# result: success
DROP TABLESPACE IF EXISTS not_exist_tablespace;
COMMIT;



--###################################################
--# DROP TABLESPACE: with <INCLUDING CONTENTS>
--###################################################



--# result: success
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;





--# result: success
CREATE TABLESPACE space1 DATAFILE 'test_data_2.dbf' SIZE 10M REUSE;
COMMIT;


--# result: success
CREATE TABLE t1 ( id INTEGER ) TABLESPACE space1;
COMMIT;


--# result: error
DROP TABLESPACE space1;
COMMIT;


--# result: success
DROP TABLESPACE space1 INCLUDING CONTENTS AND DATAFILES;
COMMIT;


--###################################################
--# DROP TABLESPACE: with < {AND | KEEP} DATAFILES >
--###################################################



--# result: success
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;





--# result: success
CREATE TABLESPACE space1 DATAFILE 'test_data_3.dbf' SIZE 10M REUSE;
COMMIT;

--# result: success
DROP TABLESPACE space1 INCLUDING CONTENTS AND DATAFILES;
COMMIT;



--###################################################
--# DROP TABLESPACE: with <drop behavior>
--###################################################



--# result: success
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;





--# result: success
CREATE TABLESPACE space1 DATAFILE 'test_data_4.dbf' SIZE 10M REUSE;
COMMIT;

--# result: success
DROP TABLESPACE space1 INCLUDING CONTENTS AND DATAFILES RESTRICT;
COMMIT;




