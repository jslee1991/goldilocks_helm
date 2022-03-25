--###################################################
--# COMMENT ON: simple example
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , data   VARCHAR(128) 
);
COMMIT;


--# result: success
COMMENT ON TABLE t1 IS 'test comment on table t1';
COMMIT;


--# result: 1 row
--#   PUBLIC  T1   TABLE   test comment on table t1
SELECT TABLE_SCHEMA
     , TABLE_NAME
     , TABLE_TYPE
     , COMMENTS
  FROM USER_TAB_COMMENTS
 WHERE TABLE_SCHEMA = 'PUBLIC'
   AND TABLE_NAME   = 'T1';




--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# COMMENT ON: with <'comment string'>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , data   VARCHAR(128) 
);
COMMIT;


--# result: success
COMMENT ON TABLE t1 IS 'test comment on table t1';
COMMIT;


--# result: 1 row
--#    T1     test comment on table t1
SELECT TABLE_NAME
     , COMMENTS
  FROM USER_TAB_COMMENTS
 WHERE TABLE_SCHEMA = 'PUBLIC'
   AND TABLE_NAME   = 'T1';


--# result: success
COMMENT ON TABLE t1 IS '';
COMMIT;


--# result: 1 row
--#    T1     null
SELECT TABLE_NAME
     , COMMENTS
  FROM USER_TAB_COMMENTS
 WHERE TABLE_SCHEMA = 'PUBLIC'
   AND TABLE_NAME   = 'T1';





--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# COMMENT ON: with <comment object: USER>
--###################################################

--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
DROP USER IF EXISTS u1 CASCADE;
COMMIT;



--# result: success
CREATE USER u1 IDENTIFIED BY u1;
COMMIT;



--# result: success
COMMENT ON AUTHORIZATION u1 IS 'test comment on authorization u1';
COMMIT;


--# result: 2 rows
--#    U1   AUTHORIZATION   test comment on authorization u1
--#    U1   SCHEMA          null
SELECT OBJECT_NAME
     , OBJECT_TYPE
     , COMMENTS
  FROM DBA_NONSCHEMA_COMMENTS
 WHERE OBJECT_NAME = 'U1';



--# result: success
DROP SCHEMA u1 CASCADE;
DROP USER u1 CASCADE;
COMMIT;


--###################################################
--# COMMENT ON: with <comment object: TABLESPACE>
--###################################################

--# result: success
DROP TABLESPACE IF EXISTS space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;

--# result: success
CREATE TABLESPACE space1 DATAFILE 'test_file_c1.dbf' SIZE 10M REUSE;
COMMIT;






--# result: success
COMMENT ON TABLESPACE space1 IS 'test comment on tablespace space1';
COMMIT;


--# result: 1 row
--#    SPACE1   TABLESPACE   test comment on tablespace space1
SELECT OBJECT_NAME
     , OBJECT_TYPE
     , COMMENTS
  FROM DBA_NONSCHEMA_COMMENTS
 WHERE OBJECT_NAME = 'SPACE1';




--# result: success
DROP TABLESPACE space1 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;
COMMIT;


--###################################################
--# COMMENT ON: with <comment object: SCHEMA>
--###################################################


--# result: success
DROP SCHEMA IF EXISTS s1 CASCADE;
COMMIT;


--# result: success
CREATE SCHEMA s1;
COMMIT;



--# result: success
COMMENT ON SCHEMA s1 IS 'test comment on schema s1';
COMMIT;


--# result: 1 row 
--#    S1   SCHEMA    test comment on schema s1
SELECT OBJECT_NAME
     , OBJECT_TYPE
     , COMMENTS
  FROM DBA_NONSCHEMA_COMMENTS
 WHERE OBJECT_NAME = 'S1';



--# result: success
DROP SCHEMA s1;
COMMIT;



--###################################################
--# COMMENT ON: with <comment object: TABLE>
--###################################################


--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , data   VARCHAR(128) 
);
COMMIT;


--# result: success
COMMENT ON TABLE public.t1 IS 'test comment on table public.t1';
COMMIT;


--# result: 1 row
--#   PUBLIC  T1   TABLE   test comment on table public.t1
SELECT TABLE_SCHEMA
     , TABLE_NAME
     , TABLE_TYPE
     , COMMENTS
  FROM USER_TAB_COMMENTS
 WHERE TABLE_SCHEMA = 'PUBLIC'
   AND TABLE_NAME   = 'T1';




--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# COMMENT ON: with <comment object: COLUMN>
--###################################################


--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , data   VARCHAR(128) 
);
COMMIT;


--# result: success
COMMENT ON COLUMN t1.id IS 'test comment on column t1.id';
COMMIT;


--# result: success
COMMENT ON COLUMN public.t1.data IS 'test comment on column public.t1.data';
COMMIT;


--# result: 2 rows
--#   PUBLIC  T1   ID      test comment on column t1.id
--#   PUBLIC  T1   DATA    test comment on column public.t1.data
SELECT TABLE_SCHEMA
     , TABLE_NAME
     , COLUMN_NAME
     , COMMENTS
  FROM USER_COL_COMMENTS
 WHERE TABLE_SCHEMA = 'PUBLIC'
   AND TABLE_NAME   = 'T1'
 ORDER BY 3 DESC;




--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# COMMENT ON: with <comment object: INDEX>
--###################################################


--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , data   VARCHAR(128) 
);
COMMIT;

--# result: success
CREATE INDEX idx_t1_id ON t1( id );
COMMIT;




--# result: success
COMMENT ON INDEX idx_t1_id IS 'test comment on index idx_t1_id';
COMMIT;



--# result: 1 row
--#   PUBLIC  IDX_T1_ID     test comment on index idx_t1_id
SELECT INDEX_SCHEMA
     , INDEX_NAME
     , COMMENTS
  FROM USER_INDEXES
 WHERE INDEX_SCHEMA = 'PUBLIC'
   AND INDEX_NAME   = 'IDX_T1_ID';



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# COMMENT ON: with <comment object: SEQUENCE>
--###################################################


--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;

--# result: success
CREATE SEQUENCE seq1;
COMMIT;



--# result: success
COMMENT ON SEQUENCE seq1 IS 'test comment on sequence seq1';
COMMIT;



--# result: 1 row
--#   PUBLIC  SEQ1     test comment on sequence seq1
SELECT SEQUENCE_SCHEMA
     , SEQUENCE_NAME
     , COMMENTS
  FROM USER_SEQUENCES
 WHERE SEQUENCE_SCHEMA = 'PUBLIC'
   AND SEQUENCE_NAME   = 'SEQ1';



--# result: success
DROP SEQUENCE seq1;
COMMIT;


--###################################################
--# COMMENT ON: with <comment object: CONSTRAINT>
--###################################################


--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER        CONSTRAINT t1_pk PRIMARY KEY
  , data   VARCHAR(128) 
);
COMMIT;




--# result: success
COMMENT ON CONSTRAINT t1_pk IS 'test comment on primary key on t1';
COMMIT;



--# result: 1 row
--#   PUBLIC  T1_PK     test comment on primary key on t1
SELECT CONSTRAINT_SCHEMA
     , CONSTRAINT_NAME
     , COMMENTS
  FROM USER_CONSTRAINTS
 WHERE TABLE_SCHEMA = 'PUBLIC'
   AND TABLE_NAME   = 'T1';



--# result: success
DROP TABLE t1;
COMMIT;

