--###################################################
--# DROP VIEW: simple example
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP VIEW IF EXISTS v1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
  , dept_id  INTEGER
  , addr     VARCHAR(1024)
);
COMMIT;

--# result: success
CREATE VIEW v1 AS SELECT * FROM t1 WHERE dept_id = 101;
COMMIT;


--# result: success
DROP VIEW v1;
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;

--###################################################
--# DROP VIEW: with < IF EXISTS >
--###################################################

--# result: success
DROP VIEW IF EXISTS not_exist_view;
COMMIT;

--###################################################
--# DROP VIEW: with <view_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP VIEW IF EXISTS v1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
  , dept_id  INTEGER
  , addr     VARCHAR(1024)
);
COMMIT;

--# result: success
CREATE VIEW v1 AS SELECT * FROM t1 WHERE dept_id = 101;
COMMIT;


--# result: success
DROP VIEW public.v1;
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# DROP VIEW: with ROLLBACK
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP VIEW IF EXISTS v1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
  , dept_id  INTEGER
  , addr     VARCHAR(1024)
);
COMMIT;

--# result: success
CREATE VIEW v1 AS SELECT * FROM t1 WHERE dept_id = 101;
COMMIT;

INSERT INTO t1 VALUES ( 1,    'leekmo', 101, 'somewhere' );
INSERT INTO t1 VALUES ( 2,     'mkkim', 101, 'anywhere' );
INSERT INTO t1 VALUES ( 3, 'egonspace', 101, 'unknwon' );
INSERT INTO t1 VALUES ( 4,      'bada', 202, 'N/A' );
INSERT INTO t1 VALUES ( 5,    'caddie', 303, 'somewhere' );
COMMIT;




--# result: success
DROP VIEW v1;

--# result: error
SELECT id, name FROM v1;

ROLLBACK;

--# result: 3 rows
--#    1  leekmo
--#    2  mkkim
--#    3  egonspace 
SELECT id, name FROM v1;




--# result: success
DROP VIEW v1;

--# result: error
SELECT id, name FROM v1;

COMMIT;

--# result: error
SELECT id, name FROM v1;


--# result: success
DROP TABLE t1;
COMMIT;


