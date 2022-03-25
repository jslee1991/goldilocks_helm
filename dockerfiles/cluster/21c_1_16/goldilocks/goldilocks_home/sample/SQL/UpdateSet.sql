--###################################################
--# UPDATE: simple example
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



--# result: 1 rows
UPDATE t1 SET data = 'new_data_3' WHERE id = 3;
COMMIT;


--# result: 5 rows
--#     1   data_1
--#     2   data_2
--#     3   new_data_3
--#     4   data_4
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# UPDATE: with <table_name>
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



--# result: 1 rows
UPDATE public.t1 SET data = 'new_data_3' WHERE id = 3;
COMMIT;


--# result: 5 rows
--#     1   data_1
--#     2   data_2
--#     3   new_data_3
--#     4   data_4
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# UPDATE: with <[AS] alias_name>
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



--# result: 1 rows
UPDATE t1 AS a1 
   SET data = 'new_data_3' 
 WHERE a1.id = ( SELECT AVG(id) FROM t1 );
COMMIT;


--# result: 5 rows
--#     1   data_1
--#     2   data_2
--#     3   new_data_3
--#     4   data_4
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# UPDATE: with <set clause>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , data   VARCHAR(128) DEFAULT 'N/A'
);
COMMIT;


--# result: 5 rows
INSERT INTO t1 VALUES ( 1, 'data_1' ),
                      ( 2, 'data_2' ),
                      ( 3, 'data_3' ),
                      ( 4, 'data_4' ),
                      ( 5, 'data_5' );
COMMIT;



--# result: 1 rows
UPDATE t1
   SET id   = id + 1000,
       data = 'new_data_2' 
 WHERE id = 2;
COMMIT;


--# result: 1 rows
UPDATE t1
   SET (id, data) = (id + 1000, 'new_data_3')
 WHERE id = 3;
COMMIT;


--# result: 1 rows
UPDATE t1
   SET id = ( SELECT avg(id) + 1001 FROM t1 )
 WHERE id = 4;
COMMIT;


--# result: 1 rows
UPDATE t1
   SET data = DEFAULT
 WHERE id = 5;
COMMIT;


--# result: 5 rows
--#     1   data_1
--#     5   N/A
--#  1002   new_data_2
--#  1003   new_data_3
--#  1004   data_4
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# UPDATE: with < WHERE <search condition> >
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



--# result: 1 rows
UPDATE t1 
   SET data = 'new_' || data 
 WHERE id BETWEEN 3 AND 4;
COMMIT;


--# result: 5 rows
--#     1   data_1
--#     2   data_2
--#     3   new_data_3
--#     4   new_data_4
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# UPDATE: with <result offset clause>
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



--# result: 1 rows
UPDATE t1 
   SET data = 'new_' || data 
 OFFSET 4 ROWS;
COMMIT;


--# result: 2 rows
UPDATE t1 
   SET data = 'new_' || data 
 OFFSET 3;
COMMIT;


--# result: 5 rows
--#     1   data_1
--#     2   data_2
--#     3   data_3
--#     4   new_data_4
--#     5   new_new_data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;




--###################################################
--# UPDATE: with <fetch first clause>
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



--# result: 1 rows
UPDATE t1 
   SET data = 'new_' || data 
 FETCH FIRST 1 ROW ONLY;
COMMIT;


--# result: 3 rows
UPDATE t1 
   SET data = 'new_' || data 
 FETCH 3;
COMMIT;


--# result: 5 rows
--#     1   new_new_data_1
--#     2   new_data_2
--#     3   new_data_3
--#     4   data_4
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# UPDATE: with <limit clause>
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
UPDATE t1 
   SET data = 'new_' || data 
 OFFSET 2 FETCH  2;
COMMIT;


--# result: 5 rows
--#     1   data_1
--#     2   data_2
--#     3   new_data_3
--#     4   new_data_4
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;



--# result: 2 rows
UPDATE t1 
   SET data = 'new_' || data 
 LIMIT 2, 2;
COMMIT;


--# result: 5 rows
--#     1   data_1
--#     2   data_2
--#     3   new_new_data_3
--#     4   new_new_data_4
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;


