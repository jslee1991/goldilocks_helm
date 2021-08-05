--###################################################
--# CREATE MEMORY TEMPORARY TABLESPACE: simple example
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS temp_space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;




--# result: success
CREATE TEMPORARY TABLESPACE temp_space1 MEMORY 'test_memory_1' SIZE 10M;
COMMIT;


--# result: success
DROP TABLESPACE temp_space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;


--###################################################
--# CREATE MEMORY TEMPORARY TABLESPACE: with < [MEMORY] TEMPORARY >
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS temp_space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;




--# result: success
CREATE MEMORY TEMPORARY TABLESPACE temp_space1 MEMORY 'test_memory_2' SIZE 10M;
COMMIT;


--# result: success
DROP TABLESPACE temp_space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;


--###################################################
--# CREATE MEMORY TEMPORARY TABLESPACE: with <memory clause>
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS temp_space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;




--# result: success
CREATE TEMPORARY TABLESPACE temp_space1 
       MEMORY 'test_memory_3_1' SIZE 10M,
              'test_memory_3_2' SIZE 10M;
COMMIT;


--# result: success
DROP TABLESPACE temp_space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;


--###################################################
--# CREATE MEMORY TEMPORARY TABLESPACE: with < EXTSIZE <size clause> >
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS temp_space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;




--# result: success
CREATE TEMPORARY TABLESPACE temp_space1 MEMORY 'test_memory_4' SIZE 10M EXTSIZE 64K;
COMMIT;


--# result: success
DROP TABLESPACE temp_space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;


