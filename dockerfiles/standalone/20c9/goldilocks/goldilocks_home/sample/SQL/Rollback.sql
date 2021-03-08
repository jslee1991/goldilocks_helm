--###################################################
--# ROLLBACK: simple example
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
DROP TABLE t1;
COMMIT;




--###################################################
--# ROLLBACK: with < [WORK] >
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
ROLLBACK WORK;

--# result: no rows
SELECT * FROM t1;




--# result: success
DROP TABLE t1;
COMMIT;




--###################################################
--# ROLLBACK: with <savepoint clause>
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
SAVEPOINT sp1;

--# result: success
INSERT INTO t1 VALUES ( 1, 'anonymous' );



--# result: success
SAVEPOINT sp2;

--# result: success
INSERT INTO t1 VALUES ( 2, 'someone' );




--# result: success
SAVEPOINT sp3;

--# result: success
INSERT INTO t1 VALUES ( 3, 'anyone' );



--# result: 3 rows
--#        1   anonymous
--#        2   someone
--#        3   anyone
SELECT * FROM t1;



--# result: success
ROLLBACK TO SAVEPOINT sp3;


--# result: 2 rows
--#        1   anonymous
--#        2   someone
SELECT * FROM t1;




--# result: success
ROLLBACK TO SAVEPOINT sp2;


--# result: 1 rows
--#        1   anonymous
SELECT * FROM t1;




--# result: success
ROLLBACK TO SAVEPOINT sp1;


--# result: no rows
SELECT * FROM t1;





--# result: success
DROP TABLE t1;
COMMIT;




--###################################################
--# ROLLBACK: with <DDL(Data Definition Language>
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



--# result: no rows
SELECT * FROM t1;



--# result: success
ROLLBACK;

--# result: error
SELECT * FROM t1;




--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , data   VARCHAR(128) 
);

--# result: success
COMMIT;



--# result: no rows
SELECT * FROM t1;




--# result: success
INSERT INTO t1 VALUES ( 1, 'anonymous' );
COMMIT;


--# result: 1 row
--#     1   anonymous
SELECT * FROM t1;





--# result: success
DROP TABLE t1;

--# result: error
SELECT * FROM t1;



--# result: success
ROLLBACK;

--# result: 1 row
--#     1   anonymous
SELECT * FROM t1;




--# result: success
DROP TABLE t1;
COMMIT;

