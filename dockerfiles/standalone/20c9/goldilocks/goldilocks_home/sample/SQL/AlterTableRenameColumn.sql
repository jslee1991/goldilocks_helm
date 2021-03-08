--###################################################
--# ALTER TABLE .. RENAME COLUMN : simple example
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    col_1   NUMBER
  , col_2   NUMBER
);
COMMIT;

--# result: 1 row
INSERT INTO t1 VALUES ( 1, 100 );
COMMIT;


--# result: 1 row
--#      1    100
SELECT col_1, col_2 FROM t1;



--# result: success
ALTER TABLE t1 RENAME COLUMN col_1 TO col_temp;
COMMIT;


--# result: success
ALTER TABLE t1 RENAME COLUMN col_2 TO col_1;
COMMIT;


--# result: success
ALTER TABLE t1 RENAME COLUMN col_temp TO col_2;
COMMIT;




--# result: 1 row
--#      100    1
SELECT col_1, col_2 FROM t1;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# ALTER TABLE .. RENAME COLUMN : with <table_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    col_1   NUMBER
  , col_2   NUMBER
);
COMMIT;



--# result: success
ALTER TABLE public.t1 RENAME COLUMN col_1 TO col_new;
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;
