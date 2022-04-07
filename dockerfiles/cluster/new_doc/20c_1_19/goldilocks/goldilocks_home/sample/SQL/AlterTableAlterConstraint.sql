--###################################################
--# ALTER TABLE .. ALTER CONSTRAINT
--###################################################


--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
( 
    id     NUMBER  CONSTRAINT t1_uk UNIQUE
  , name   VARCHAR(128) 
  , addr   VARCHAR(1024)
);
COMMIT;


--# result: 1 rows
INSERT INTO t1 VALUES ( 1, 'leekmo', 'N/A' );
COMMIT;

--# result: error
INSERT INTO t1 VALUES ( 1, 'xcom73', 'Inchon' );

--# result: success
ALTER TABLE t1 ALTER CONSTRAINT t1_uk DEFERRABLE INITIALLY DEFERRED;
COMMIT;

--# result: success
INSERT INTO t1 VALUES ( 1, 'xcom73', 'Inchon' );


--# result: 2 rows
--#   1  leekmo  N/A
--#   1  xcom73  Inchon
SELECT * FROM t1 ORDER BY name;

--# result: error & rollback
COMMIT;


--# result: 1 rows
--#   1  leekmo  N/A
SELECT * FROM t1 ORDER BY name;


--# result: success
INSERT INTO t1 VALUES ( 1, 'xcom73', 'Inchon' );


--# result: 2 rows
--#   1  leekmo  N/A
--#   1  xcom73  Inchon
SELECT * FROM t1 ORDER BY name;

--# result: error
SET CONSTRAINTS ALL IMMEDIATE;

--# result: 1 rows
UPDATE t1 SET id = 2 WHERE name = 'xcom73';

--# result: 2 rows
--#   1  leekmo  N/A
--#   2  xcom73  Inchon
SELECT * FROM t1 ORDER BY id;

--# result: success
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;


