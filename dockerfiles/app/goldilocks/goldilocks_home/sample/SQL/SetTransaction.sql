--###################################################
--# SET TRANSACTION: with <transaction_access_mode>
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
INSERT INTO t1 VALUES ( 1, 'anonymous' );
COMMIT;



--# result: success
SET TRANSACTION READ ONLY;



--# result: error
INSERT INTO t1 VALUES ( 2, 'someone' );
COMMIT;


--# result: success
INSERT INTO t1 VALUES ( 3, 'anyone' );
COMMIT;


--# result: 2 rows
--#     1   anonymous
--#     3   anyone
SELECT * FROM t1;




--# result: success
SET TRANSACTION READ WRITE;



--# result: 1 row
INSERT INTO t1 VALUES ( 4, 'leekmo' );
COMMIT;


--# result: 1 row
INSERT INTO t1 VALUES ( 5, 'mkkim' );
COMMIT;


--# result: 4 rows
--#     1   anonymous
--#     3   anyone
--#     4   leekmo
--#     5   mkkim
SELECT * FROM t1;





--# result: success
DROP TABLE t1;
COMMIT;




--###################################################
--# SET TRANSACTION: with <isolation_level>
--###################################################


--# result: success
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


--# result: success
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
