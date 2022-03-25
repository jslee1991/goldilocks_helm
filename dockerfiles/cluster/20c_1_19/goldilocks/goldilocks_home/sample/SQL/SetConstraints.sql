--#####################################################################
--# SET CONSTRAINTS : constraint_name DEFERRED
--#####################################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id    INTEGER,
    value INTEGER CONSTRAINT t1_uk UNIQUE DEFERRABLE
);
COMMIT;


--# result: 1 rows
INSERT INTO t1 VALUES ( 1, 1 );
COMMIT;

--# result: success
SET CONSTRAINTS t1_uk DEFERRED;

--# result: 1 rows
INSERT INTO t1 VALUES ( 2, 1 );

--# result: 2 rows
--#     1   1
--#     2   1
SELECT * FROM t1 ORDER BY id;

--# result: error
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


--#####################################################################
--# SET CONSTRAINTS : constraint_name IMMEDIATE
--#####################################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id    INTEGER,
    value INTEGER CONSTRAINT t1_uk UNIQUE DEFERRABLE INITIALLY DEFERRED
);
COMMIT;


--# result: 1 rows
INSERT INTO t1 VALUES ( 1, 1 );
COMMIT;

--# result: 1 rows
INSERT INTO t1 VALUES ( 2, 1 );


--# result: 2 rows
--#     1   1
--#     2   1
SELECT * FROM t1 ORDER BY id;

--# result: error
SET CONSTRAINTS t1_uk IMMEDIATE;

--# result: success
UPDATE t1 SET value = 2 WHERE id = 2;

--# result: 2 rows
--#     1   1
--#     2   2
SELECT * FROM t1 ORDER BY id;

--# result: success
SET CONSTRAINTS t1_uk IMMEDIATE;

--# result: success
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


--#####################################################################
--# SET CONSTRAINTS : ALL DEFERRED
--#####################################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id    INTEGER,
    value INTEGER CONSTRAINT t1_uk UNIQUE DEFERRABLE
);
COMMIT;


--# result: 1 rows
INSERT INTO t1 VALUES ( 1, 1 );
COMMIT;

--# result: success
SET CONSTRAINTS ALL DEFERRED;

--# result: 1 rows
INSERT INTO t1 VALUES ( 2, 1 );

--# result: 2 rows
--#     1   1
--#     2   1
SELECT * FROM t1 ORDER BY id;

--# result: error
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


--#####################################################################
--# SET CONSTRAINTS : ALL IMMEDIATE
--#####################################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id    INTEGER,
    value INTEGER CONSTRAINT t1_uk UNIQUE DEFERRABLE INITIALLY DEFERRED
);
COMMIT;


--# result: 1 rows
INSERT INTO t1 VALUES ( 1, 1 );
COMMIT;

--# result: 1 rows
INSERT INTO t1 VALUES ( 2, 1 );


--# result: 2 rows
--#     1   1
--#     2   1
SELECT * FROM t1 ORDER BY id;

--# result: error
SET CONSTRAINTS ALL IMMEDIATE;

--# result: success
UPDATE t1 SET value = 2 WHERE id = 2;

--# result: 2 rows
--#     1   1
--#     2   2
SELECT * FROM t1 ORDER BY id;

--# result: success
SET CONSTRAINTS ALL IMMEDIATE;

--# result: success
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


--#####################################################################
--# SET CONSTRAINTS & Savepoint
--#####################################################################


--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


CREATE TABLE t1
(
   id1 INTEGER CONSTRAINT t1_uk1 UNIQUE DEFERRABLE INITIALLY IMMEDIATE,
   id2 INTEGER CONSTRAINT t1_uk2 UNIQUE DEFERRABLE INITIALLY IMMEDIATE,
   id3 INTEGER CONSTRAINT t1_uk3 UNIQUE DEFERRABLE INITIALLY IMMEDIATE
);


--# result: success
INSERT INTO t1 VALUES ( 1, 1, 1 );
COMMIT;

--# result: success
SAVEPOINT sp1;

--# result: success
--# t1_uk1 constraint is DEFERRED
SET CONSTRAINTS t1_uk1 DEFERRED;

--# result: success
SAVEPOINT sp2;

--# result: success
--# t1_uk1, t1_uk2 constraints are DEFERRED
SET CONSTRAINTS t1_uk2 DEFERRED;

--# result: success
SAVEPOINT sp3;

--# result: success
--# ALL constraints are DEFERRED
SET CONSTRAINTS ALL DEFERRED;

--# result: success
SAVEPOINT sp4;

--# result: success
--# ALL constraints are IMMEDIATE
SET CONSTRAINTS ALL IMMEDIATE;



--# result: error
INSERT INTO t1 VALUES ( 1, 2, 2 );

--# result: error
INSERT INTO t1 VALUES ( 3, 1, 3 );

--# result: error
INSERT INTO t1 VALUES ( 4, 4, 1 );




--# result: success
--# ALL constraints are DEFERRED
ROLLBACK TO SAVEPOINT sp4;

--# result: success
INSERT INTO t1 VALUES ( 1, 2, 2 );

--# result: success
INSERT INTO t1 VALUES ( 3, 1, 3 );

--# result: success
INSERT INTO t1 VALUES ( 4, 4, 1 );




--# result: success
--# t1_uk1, t1_uk2 constraints are DEFERRED
ROLLBACK TO SAVEPOINT sp3;

--# result: success
INSERT INTO t1 VALUES ( 1, 2, 2 );

--# result: success
INSERT INTO t1 VALUES ( 3, 1, 3 );

--# result: error
INSERT INTO t1 VALUES ( 4, 4, 1 );



--# result: success
--# t1_uk1 constraint is DEFERRED
ROLLBACK TO SAVEPOINT sp2;

--# result: success
INSERT INTO t1 VALUES ( 1, 2, 2 );

--# result: error
INSERT INTO t1 VALUES ( 3, 1, 3 );

--# result: error
INSERT INTO t1 VALUES ( 4, 4, 1 );



--# result: success
--# all constraint are IMMEDIATE
ROLLBACK TO SAVEPOINT sp1;

--# result: error
INSERT INTO t1 VALUES ( 1, 2, 2 );

--# result: error
INSERT INTO t1 VALUES ( 3, 1, 3 );

--# result: error
INSERT INTO t1 VALUES ( 4, 4, 1 );


--# result: 1 row
--#    1   1   1
SELECT * FROM t1;

--# result: success
DROP TABLE t1;
COMMIT;


