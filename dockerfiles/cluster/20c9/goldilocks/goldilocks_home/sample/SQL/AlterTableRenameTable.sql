--###################################################
--# ALTER TABLE .. RENAME TABLE : simple example
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t2;
DROP TABLE IF EXISTS t_temp;
COMMIT;


--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , name   VARCHAR(128) 
);
COMMIT;


--# result: success
CREATE TABLE t2 
( 
    id     NUMBER
  , addr   VARCHAR(1024)
);
COMMIT;


--# result: 1 row
INSERT INTO t1 VALUES ( 1, 'someone' );
COMMIT;

--# result: 1 row
INSERT INTO t2 VALUES ( 1, 'unknown addr' );
COMMIT;


--# result: 1 row
--#      1   someone
SELECT * FROM t1;

--# result: 1 row
--#      1   unknown addr
SELECT * FROM t2;



--# result: success
ALTER TABLE t1 RENAME TO t_temp;
COMMIT;

--# result: success
ALTER TABLE t2 RENAME TO t1;
COMMIT;


--# result: success
ALTER TABLE t_temp RENAME TO t2;
COMMIT;



--# result: 1 row
--#      1   unknown addr
SELECT * FROM t1;

--# result: 1 row
--#      1   someone
SELECT * FROM t2;



--# result: success
DROP TABLE t1;
DROP TABLE t2;
COMMIT;



--###################################################
--# ALTER TABLE .. RENAME TABLE : with <table_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t_new;
COMMIT;


--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , name   VARCHAR(128) 
  , addr   VARCHAR(1024)
);
COMMIT;



--# result: success
ALTER TABLE public.t1 RENAME TO t_new;
COMMIT;


--# result: success
DROP TABLE t_new;
COMMIT;



