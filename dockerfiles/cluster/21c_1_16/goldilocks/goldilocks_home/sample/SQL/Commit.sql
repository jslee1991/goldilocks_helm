--###################################################
--# COMMIT: simple example
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
INSERT INTO t1 VALUES ( 1, 'anonymous' );

--# result: 1 rows
--#        1   anonymous
SELECT * FROM t1;



--# result: success
ROLLBACK;

--# result: no rows
SELECT * FROM t1;



--# result: success
INSERT INTO t1 VALUES ( 1, 'anonymous' );

--# result: 1 rows
--#        1   anonymous
SELECT * FROM t1;



--# result: success
COMMIT;



--# result: 1 rows
--#        1   anonymous
SELECT * FROM t1;




--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# COMMIT: with < [WORK] >
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
INSERT INTO t1 VALUES ( 1, 'anonymous' );




--# result: success
COMMIT WORK;




--# result: 1 rows
--#        1   anonymous
SELECT * FROM t1;

--# result: success
DROP TABLE t1;
COMMIT;
