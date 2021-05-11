--###################################################
--# CREATE MEMORY DATA TABLESPACE: simple example
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;




--# result: success
CREATE TABLESPACE space1 DATAFILE 'test_file_1.dbf' SIZE 10M REUSE;
COMMIT;


--# result: success
DROP TABLESPACE space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;



--###################################################
--# CREATE MEMORY DATA TABLESPACE: with <[MEMORY] [DATA]>
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;





--# result: success
CREATE MEMORY DATA TABLESPACE space1 DATAFILE 'test_file_2.dbf' SIZE 10M REUSE;
COMMIT;

--# result: success
DROP TABLESPACE space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;



--###################################################
--# CREATE MEMORY DATA TABLESPACE: with <memory datafile clause>
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;





--# result: success
CREATE TABLESPACE space1 
       DATAFILE 'test_file_3_1.dbf' SIZE 10M REUSE,
                'test_file_3_2.dbf' SIZE 10M REUSE;
COMMIT;


--# result: success
DROP TABLESPACE space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;



--###################################################
--# CREATE MEMORY DATA TABLESPACE: with < ONLINE | OFFLINE >
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;





--# result: success
CREATE TABLESPACE space1 DATAFILE 'test_file_4.dbf' SIZE 10M REUSE ONLINE;
COMMIT;


--# result: success
DROP TABLESPACE space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;



--###################################################
--# CREATE MEMORY DATA TABLESPACE: with < EXTSIZE <size clause> >
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;





--# result: success
CREATE TABLESPACE space1 DATAFILE 'test_file_6.dbf' SIZE 10M REUSE EXTSIZE 64K;
COMMIT;


--# result: success
DROP TABLESPACE space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;


