--###################################################
--# CREATE SCHEMA: simple example
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
DROP SCHEMA IF EXISTS s1 CASCADE;
COMMIT;


--# result: success
CREATE SCHEMA s1;
COMMIT;


--# result: success
CREATE TABLE s1.t1
(
    id     INTEGER
  , name   VARCHAR(128)
);
COMMIT;

--# result: 1 row
INSERT INTO s1.t1 VALUES ( 1, 'leekmo' );
COMMIT;


--# result: success
CREATE TABLE public.t1
(
    id     INTEGER
  , name   VARCHAR(128)
);
COMMIT;


--# result: 1 row
INSERT INTO public.t1 VALUES ( 101, 'public' );
COMMIT;



--# result: 1 row
--#    101   public
SELECT * FROM t1;


--# result: 1 row
--#      1   leekmo
SELECT * FROM s1.t1;


--# result: 1 row
--#    101   public
SELECT * FROM public.t1;




--# result: success
DROP TABLE s1.t1;
COMMIT;


--# result: success
DROP TABLE public.t1;
COMMIT;



--# result: success
DROP SCHEMA s1 CASCADE;
COMMIT;


--###################################################
--# CREATE SCHEMA: with <schema_name>
--###################################################


--# result: success
DROP SCHEMA IF EXISTS s1 CASCADE;
COMMIT;



--# result: success
CREATE SCHEMA s1;
COMMIT;



--# result: success
DROP SCHEMA s1;
COMMIT;



--###################################################
--# CREATE SCHEMA: with <AUTHORIZATION user_identifier>
--###################################################


--# result: success
DROP SCHEMA IF EXISTS test CASCADE;
COMMIT;



--# result: success
CREATE SCHEMA AUTHORIZATION test;
COMMIT;



--# result: success
DROP SCHEMA test;
COMMIT;


--###################################################
--# CREATE SCHEMA: with <schema_name AUTHORIZATION user_identifier>
--###################################################


--# result: success
DROP SCHEMA IF EXISTS s1 CASCADE;
COMMIT;



--# result: success
CREATE SCHEMA s1 AUTHORIZATION test;
COMMIT;



--# result: success
DROP SCHEMA s1;
COMMIT;



--###################################################
--# CREATE SCHEMA: with <schema element>
--###################################################


--# result: success
DROP SCHEMA IF EXISTS s1 CASCADE;
COMMIT;


--# result: success
CREATE SCHEMA s1 
       CREATE TABLE t1 ( id INTEGER, name VARCHAR(128) )
       CREATE INDEX idx_t1_id ON t1 ( id )
       COMMENT ON TABLE t1 IS 'comment on s1.t1'
;
COMMIT;


--# result: success
INSERT INTO s1.t1 VALUES ( 1, 'leekmo' );
COMMIT;


--# result: success
DROP SCHEMA s1 CASCADE;
COMMIT;


