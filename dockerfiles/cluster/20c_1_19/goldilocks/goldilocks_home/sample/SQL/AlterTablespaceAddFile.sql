--###################################################
--# ALTER TABLESPACE .. ADD: with <DATAFILE>
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;

--# result: success
CREATE TABLESPACE space1 DATAFILE 'test_file_a1.dbf' SIZE 10M REUSE;
COMMIT;



--# result: success
ALTER TABLESPACE space1 ADD DATAFILE 'test_file_a2.dbf' SIZE 10M REUSE;
COMMIT;



--# result: success
DROP TABLESPACE space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;


--###################################################
--# ALTER TABLESPACE .. ADD: with <MEMORY>
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS temp_space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;

--# result: success
CREATE MEMORY TEMPORARY TABLESPACE temp_space1 MEMORY 'test_memory_a1' SIZE 10M;
COMMIT;



--# result: success
ALTER TABLESPACE temp_space1 ADD MEMORY 'test_memory_a2' SIZE 10M;
COMMIT;



--# result: success
DROP TABLESPACE temp_space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;


