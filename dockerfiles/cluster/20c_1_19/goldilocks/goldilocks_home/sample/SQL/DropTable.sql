--###################################################
--# DROP TABLE: simple example
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;



--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , name   VARCHAR(128) 
);
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# DROP TABLE: with <IF EXISTS>
--###################################################

--# result: success
DROP TABLE IF EXISTS not_exist_table;
COMMIT;



--###################################################
--# DROP TABLE: with <table_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;



--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , name   VARCHAR(128) 
);
COMMIT;



--# result: success
DROP TABLE public.t1;
COMMIT;



--###################################################
--# DROP TABLE: with <drop behavior>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;



--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , name   VARCHAR(128) 
);
COMMIT;



--# result: success
DROP TABLE t1 RESTRICT;
COMMIT;


--###################################################
--# DROP TABLE: with ROLLBACK
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;



--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , name   VARCHAR(128) 
);
COMMIT;


--# result: 1 row
INSERT INTO t1 VALUES ( 1, 'leekmo' );
COMMIT;


--# result: 1 row
--#    1   leekmo
SELECT * FROM t1;


--# result: success
DROP TABLE t1;


--# result: error
SELECT * FROM t1;


--# result: success
ROLLBACK;


--# result: 1 row
--#    1   leekmo
SELECT * FROM t1;


--# result: success
DROP TABLE t1;
COMMIT;


