--###################################################
--# ALTER TABLESPACE .. DROP: with <DATAFILE>
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;

--# result: success
CREATE TABLESPACE space1 
       DATAFILE 'test_file_f1.dbf' SIZE 10M REUSE,
                'test_file_f2.dbf' SIZE 10M REUSE;
COMMIT;



--# result: success
ALTER TABLESPACE space1 DROP DATAFILE 'test_file_f2.dbf';
COMMIT;



--# result: success
DROP TABLESPACE space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;



--###################################################
--# ALTER TABLESPACE .. DROP: with <MEMORY>
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS temp_space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;

--# result: success
CREATE TEMPORARY TABLESPACE temp_space1 
       MEMORY 'test_memory_m1' SIZE 10M,
              'test_memory_m2' SIZE 10M;
COMMIT;



--# result: success
ALTER TABLESPACE temp_space1 DROP MEMORY 'test_memory_m2';
COMMIT;



--# result: success
DROP TABLESPACE temp_space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;
