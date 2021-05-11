--###################################################
--# DROP INDEX: simple example
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
  , dept_id  INTEGER
  , addr     VARCHAR(1024)
);

INSERT INTO t1 VALUES ( 1,    'leekmo', 101, 'somewhere' );
INSERT INTO t1 VALUES ( 2,     'mkkim', 101, 'anywhere' );
INSERT INTO t1 VALUES ( 3, 'egonspace', 101, 'unknwon' );
INSERT INTO t1 VALUES ( 4,      'bada', 202, 'N/A' );
INSERT INTO t1 VALUES ( 5,    'caddie', 303, 'somewhere' );
COMMIT;


--# result: success
CREATE INDEX idx_t1_id ON t1( id );
COMMIT;


--# result: 1 row
--#         leekmo
SELECT /*+ INDEX( t1, idx_t1_id ) */ name FROM t1 WHERE id = 1;




--# result: success
DROP INDEX idx_t1_id;
COMMIT;



--# result: success
ALTER SESSION SET HINT_ERROR = ON;

--# result: error
SELECT /*+ INDEX( t1, idx_t1_id ) */ name FROM t1 WHERE id = 1;



--# result: success
ALTER SESSION SET HINT_ERROR = OFF;

--# result: 1 row
--#         leekmo
SELECT /*+ INDEX( t1, idx_t1_id ) */ name FROM t1 WHERE id = 1;


--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# DROP INDEX: with <IF EXISTS>
--###################################################

--# result: success
DROP INDEX IF EXISTS not_exist_index;
COMMIT;


--###################################################
--# DROP INDEX: with <index_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
  , dept_id  INTEGER
  , addr     VARCHAR(1024)
);

--# result: success
CREATE INDEX idx_t1_id ON t1( id );
COMMIT;



--# result: success
DROP INDEX public.idx_t1_id;
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;
