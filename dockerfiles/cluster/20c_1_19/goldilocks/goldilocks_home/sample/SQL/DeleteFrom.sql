--###################################################
--# DELETE: simple example
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


--# result: 5 rows
INSERT INTO t1 VALUES ( 1, 'data_1' ),
                      ( 2, 'data_2' ),
                      ( 3, 'data_3' ),
                      ( 4, 'data_4' ),
                      ( 5, 'data_5' );
COMMIT;



--# result: 2 rows
DELETE FROM t1 WHERE id > 3;
COMMIT;


--# result: 3 rows
--#     1   data_1
--#     2   data_2
--#     3   data_3
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# DELETE: with < [FROM] >
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


--# result: 5 rows
INSERT INTO t1 VALUES ( 1, 'data_1' ),
                      ( 2, 'data_2' ),
                      ( 3, 'data_3' ),
                      ( 4, 'data_4' ),
                      ( 5, 'data_5' );
COMMIT;



--# result: 2 rows
DELETE t1 WHERE id > 3;
COMMIT;


--# result: 3 rows
--#     1   data_1
--#     2   data_2
--#     3   data_3
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# DELETE: with <table_name>
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


--# result: 5 rows
INSERT INTO t1 VALUES ( 1, 'data_1' ),
                      ( 2, 'data_2' ),
                      ( 3, 'data_3' ),
                      ( 4, 'data_4' ),
                      ( 5, 'data_5' );
COMMIT;



--# result: 2 rows
DELETE FROM public.t1 WHERE id > 3;
COMMIT;


--# result: 3 rows
--#     1   data_1
--#     2   data_2
--#     3   data_3
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# DELETE: with <AS alias_name>
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


--# result: 5 rows
INSERT INTO t1 VALUES ( 1, 'data_1' ),
                      ( 2, 'data_2' ),
                      ( 3, 'data_3' ),
                      ( 4, 'data_4' ),
                      ( 5, 'data_5' );
COMMIT;



--# result: 2 rows
DELETE FROM t1 AS a1 
       WHERE a1.id > ( SELECT AVG(id) FROM t1 );
COMMIT;


--# result: 3 rows
--#     1   data_1
--#     2   data_2
--#     3   data_3
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# DELETE: with < WHERE <search condition> >
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


--# result: 5 rows
INSERT INTO t1 VALUES ( 1, 'data_1' ),
                      ( 2, 'data_2' ),
                      ( 3, 'data_3' ),
                      ( 4, 'data_4' ),
                      ( 5, 'data_5' );
COMMIT;



--# result: 2 rows
DELETE FROM t1
       WHERE MOD( id, 2 ) = 0;
COMMIT;


--# result: 3 rows
--#     1   data_1
--#     3   data_3
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# DELETE: with <result offset clause>
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


--# result: 5 rows
INSERT INTO t1 VALUES ( 1, 'data_1' ),
                      ( 2, 'data_2' ),
                      ( 3, 'data_3' ),
                      ( 4, 'data_4' ),
                      ( 5, 'data_5' );
COMMIT;



--# result: 2 rows
DELETE FROM t1 OFFSET 3 ROWS;
COMMIT;


--# result: 3 rows
--#     1   data_1
--#     3   data_3
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# DELETE: with <fetch first clause>
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


--# result: 5 rows
INSERT INTO t1 VALUES ( 1, 'data_1' ),
                      ( 2, 'data_2' ),
                      ( 3, 'data_3' ),
                      ( 4, 'data_4' ),
                      ( 5, 'data_5' );
COMMIT;



--# result: 2 rows
DELETE FROM t1 FETCH FIRST 2 ROWS ONLY;
COMMIT;


--# result: 3 rows
--#     3   data_3
--#     4   data_4
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# DELETE: with <limit clause>
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


--# result: 5 rows
INSERT INTO t1 VALUES ( 1, 'data_1' ),
                      ( 2, 'data_2' ),
                      ( 3, 'data_3' ),
                      ( 4, 'data_4' ),
                      ( 5, 'data_5' );
COMMIT;



--# result: 2 rows
DELETE FROM t1 OFFSET 2 FETCH 2;


--# result: 3 rows
--#     1   data_1
--#     2   data_2
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;


--# result: success
ROLLBACK;


--# result: 2 rows
DELETE FROM t1 LIMIT 2, 2;


--# result: 3 rows
--#     1   data_1
--#     2   data_2
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;


--# result: success
DROP TABLE t1;
COMMIT;



