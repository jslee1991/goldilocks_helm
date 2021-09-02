--###################################################
--# SET SESSION CHARACTERISTICS: with <transaction_access_mode>
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
SET SESSION CHARACTERISTICS AS TRANSACTION READ ONLY;



--# result: error
INSERT INTO t1 VALUES ( 2, 'someone' );
COMMIT;


--# result: error
INSERT INTO t1 VALUES ( 3, 'anyone' );
COMMIT;


--# result: 1 row
--#     1   anonymous
SELECT * FROM t1;




--# result: success
SET SESSION CHARACTERISTICS AS TRANSACTION READ WRITE;



--# result: 1 row
INSERT INTO t1 VALUES ( 2, 'someone' );
COMMIT;


--# result: 1 row
INSERT INTO t1 VALUES ( 3, 'anyone' );
COMMIT;


--# result: 3 rows
--#     1   anonymous
--#     2   someone
--#     3   anyone
SELECT * FROM t1;





--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# SET SESSION CHARACTERISTICS: with <isolation_level>
--###################################################


--# result: success
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ COMMITTED;



--# result: success
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL SERIALIZABLE;


