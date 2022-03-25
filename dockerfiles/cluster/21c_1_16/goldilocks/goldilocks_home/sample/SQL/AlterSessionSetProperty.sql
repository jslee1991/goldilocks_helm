--###################################################
--# ALTER SESSION SET property: simple example
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
);

INSERT INTO t1 VALUES ( 1,    'leekmo' );
INSERT INTO t1 VALUES ( 2,     'mkkim' );
INSERT INTO t1 VALUES ( 3, 'egonspace' );
INSERT INTO t1 VALUES ( 4,      'bada' );
INSERT INTO t1 VALUES ( 5,    'caddie' );
COMMIT;


--# result: success
CREATE INDEX idx_t1_id ON t1( id );
COMMIT;




--# result: success
ALTER SESSION SET HINT_ERROR = ON;


--# result: 1 row
--#         leekmo
SELECT /*+ INDEX( t1, idx_t1_id ) */ name FROM t1 WHERE id = 1;

--# result: error
SELECT /*+ INDEX( t1, invalid_index ) */ name FROM t1 WHERE id = 1;




--# result: success
ALTER SESSION SET HINT_ERROR = OFF;


--# result: 1 row
--#         leekmo
SELECT /*+ INDEX( t1, idx_t1_id ) */ name FROM t1 WHERE id = 1;

--# result: 1 row
--#         leekmo
SELECT /*+ INDEX( t1, invalid_index ) */ name FROM t1 WHERE id = 1;



--# result: success
ALTER SESSION SET HINT_ERROR TO DEFAULT;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# ALTER SESSION SET property: with <property value>
--# ALTER SESSION SET property: with <TO DEFAULT>
--###################################################



--# result: success
ALTER SESSION SET QUERY_TIMEOUT = 60;

--# result: success
ALTER SESSION SET QUERY_TIMEOUT TO DEFAULT;



--# result: success
ALTER SESSION SET MEMORY_SORT_RUN_SIZE = 32K;

--# result: success
ALTER SESSION SET MEMORY_SORT_RUN_SIZE TO DEFAULT;


