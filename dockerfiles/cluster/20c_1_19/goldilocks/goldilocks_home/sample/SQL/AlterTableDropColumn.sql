--###################################################
--# ALTER TABLE .. SET UNUSED COLUMN : simple example
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , name   VARCHAR(128) 
  , addr   VARCHAR(1024)
);
COMMIT;


--# result: 1 row
INSERT INTO t1 VALUES ( 1, 'anonymous', 'unknown' );

--# result: 1 row
INSERT INTO t1 VALUES ( 2, 'someone', 'seoul korea' );
COMMIT;



--# result: 2 rows
--#        1   anonymous   unknown
--#        2   someone     seoul korea
SELECT * FROM t1 ORDER BY id;



--# result: success
ALTER TABLE t1 SET UNUSED COLUMN ( addr );
COMMIT;



--# result: 2 rows
--#        1   anonymous
--#        2   someone  
SELECT * FROM t1 ORDER BY id;


--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# ALTER TABLE .. SET UNUSED COLUMN : with <table_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
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
ALTER TABLE public.t1 SET UNUSED COLUMN ( addr );
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# ALTER TABLE .. SET UNUSED [COLUMN]
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
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
ALTER TABLE public.t1 SET UNUSED addr;
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# ALTER TABLE .. SET UNUSED COLUMN : with <column_name_list>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
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
ALTER TABLE t1 SET UNUSED ( name, addr );
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# ALTER TABLE .. SET UNUSED COLUMN : with <column_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , name   VARCHAR(128) 
  , addr   VARCHAR(1024)
  , UNIQUE ( id, name )
);
COMMIT;


--# result: success
ALTER TABLE t1 SET UNUSED COLUMN name;
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


