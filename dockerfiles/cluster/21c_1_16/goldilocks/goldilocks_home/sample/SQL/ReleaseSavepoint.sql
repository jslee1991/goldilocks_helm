--###################################################
--# RELEASE SAVEPOINT: simple example
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




--# result: success
RELEASE SAVEPOINT sp2;




--# result: error
ROLLBACK TO SAVEPOINT sp3;


--# result: error
ROLLBACK TO SAVEPOINT sp2;


--# result: success
ROLLBACK TO SAVEPOINT sp1;



--# result: no rows
SELECT * FROM t1;





--# result: success
DROP TABLE t1;
COMMIT;


