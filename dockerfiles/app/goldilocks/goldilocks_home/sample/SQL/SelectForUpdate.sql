--###################################################
--# SELECT.. FOR UPDATE: simple example
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



--# result: 1 row
--#     3  data_3
SELECT id, data FROM t1 WHERE id = 3 FOR UPDATE;

COMMIT;





--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# SELECT.. FOR UPDATE: with <updatable query>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t2;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , name   VARCHAR(128) 
);
COMMIT;

--# result: 5 rows
INSERT INTO t1 VALUES ( 1, 'someone' ),
                      ( 2, 'anyone' ),
                      ( 3, 'unknown' ),
                      ( 4, 'leekmo' ),
                      ( 5, 'mkkim' );
COMMIT;


--# result: success
CREATE TABLE t2
( 
    id     NUMBER
  , addr   VARCHAR(128) 
);
COMMIT;

--# result: 5 rows
INSERT INTO t2 VALUES ( 1, 'somewhere' ),
                      ( 2, 'anywhere' ),
                      ( 3, 'N/A' ),
                      ( 4, 'leekmo''s home' ),
                      ( 5, 'seoul' );
COMMIT;




--# result: 5 rows
--#     1  someone  somewhere  
--#     2  anyone   anywhere  
--#     3  unknown  N/A
--#     4  leekmo   leekmo's home
--#     5  mkkim    seoul
SELECT t1.id, t1.name, t2.addr 
  FROM t1, t2
 WHERE t1.id = t2.id
 ORDER BY 1
   FOR UPDATE;

COMMIT;


--# result: error
SELECT DISTINCT id, name 
  FROM t1
   FOR UPDATE;


--# result: error
SELECT id, COUNT(*)
  FROM t1
 GROUP BY id
   FOR UPDATE;


--# result: error
SELECT id
  FROM t1
 UNION 
SELECT id
  FROM t2
   FOR UPDATE;




--# result: success
DROP TABLE t1;
DROP TABLE t2;
COMMIT;




--###################################################
--# SELECT.. FOR UPDATE: with <uptability clause>
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

--# result: 5 rows
INSERT INTO t1 VALUES ( 1, 'someone' ),
                      ( 2, 'anyone' ),
                      ( 3, 'unknown' ),
                      ( 4, 'leekmo' ),
                      ( 5, 'mkkim' );
COMMIT;



--# result: 3 rows
--#     2  anyone 
--#     3  unknown
--#     4  leekmo 
SELECT id, name
  FROM t1
 WHERE id BETWEEN 2 AND 4
   FOR READ ONLY;

COMMIT;



--# result: 2 rows
--#     1  someone  somewhere  
--#     5  mkkim    seoul
SELECT id, name
  FROM t1
 WHERE id NOT BETWEEN 2 AND 4
   FOR UPDATE;

COMMIT;




--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# SELECT.. FOR UPDATE: with <FOR UPDATE OF ..>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t2;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , name   VARCHAR(128) 
);
COMMIT;

--# result: 5 rows
INSERT INTO t1 VALUES ( 1, 'someone' ),
                      ( 2, 'anyone' ),
                      ( 3, 'unknown' ),
                      ( 4, 'leekmo' ),
                      ( 5, 'mkkim' );
COMMIT;


--# result: success
CREATE TABLE t2
( 
    id     NUMBER
  , addr   VARCHAR(128) 
);
COMMIT;

--# result: 5 rows
INSERT INTO t2 VALUES ( 1, 'somewhere' ),
                      ( 2, 'anywhere' ),
                      ( 3, 'N/A' ),
                      ( 4, 'leekmo''s home' ),
                      ( 5, 'seoul' );
COMMIT;




--# result: 2 rows
--# locked on rows of t1 table
--#     4  leekmo   leekmo's home
--#     5  mkkim    seoul
SELECT t1.id, t1.name, t2.addr 
  FROM t1, t2
 WHERE t1.id > 3
   AND t1.id = t2.id
 ORDER BY 1
   FOR UPDATE OF t1.id;

COMMIT;



--# result: 2 rows
--# locked on both rows of t1 and t2 table
--#     4  leekmo   leekmo's home
--#     5  mkkim    seoul
SELECT t1.id, t1.name, t2.addr 
  FROM t1, t2
 WHERE t1.id > 3
   AND t1.id = t2.id
 ORDER BY 1
   FOR UPDATE;

COMMIT;




--# result: success
DROP TABLE t1;
DROP TABLE t2;
COMMIT;



--###################################################
--# SELECT.. FOR UPDATE: with <lock wait mode>
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

--# result: 5 rows
INSERT INTO t1 VALUES ( 1, 'someone' ),
                      ( 2, 'anyone' ),
                      ( 3, 'unknown' ),
                      ( 4, 'leekmo' ),
                      ( 5, 'mkkim' );
COMMIT;




--# result: 2 rows
--#   4  leekmo
--#   5  mkkim 
SELECT id, name
  FROM t1
 WHERE t1.id > 3
   FOR UPDATE 
  WAIT;

COMMIT;



--# result: 2 rows
--#   4  leekmo
--#   5  mkkim 
SELECT id, name
  FROM t1
 WHERE t1.id > 3
   FOR UPDATE 
  WAIT 10;

COMMIT;



--# result: 2 rows
--#   4  leekmo
--#   5  mkkim 
SELECT id, name
  FROM t1
 WHERE t1.id > 3
   FOR UPDATE 
   NOWAIT;

COMMIT;





--# result: success
DROP TABLE t1;
COMMIT;



