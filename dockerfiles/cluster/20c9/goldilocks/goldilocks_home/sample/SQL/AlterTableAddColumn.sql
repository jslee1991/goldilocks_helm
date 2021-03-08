--###################################################
--# ALTER TABLE .. ADD COLUMN : simple example
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

--# result: 1 row
INSERT INTO t1 VALUES ( 2, 'someone' );
COMMIT;



--# result: 2 rows
--#        1   anonymous
--#        2   someone
SELECT * FROM t1 ORDER BY id;



--# result: success
ALTER TABLE t1 ADD COLUMN ( addr VARCHAR(1024) );
COMMIT;



--# result: 2 rows
--#        1   anonymous   null
--#        2   someone     null
SELECT * FROM t1 ORDER BY id;


--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# ALTER TABLE .. ADD COLUMN : with <table_name>
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


--# result: success
ALTER TABLE public.t1 ADD COLUMN ( addr VARCHAR(1024) );
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# ALTER TABLE .. ADD COLUMN : with <column definition>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
( 
    name   VARCHAR(128) 
);
COMMIT;


--# result: success
ALTER TABLE t1 ADD id INTEGER PRIMARY KEY;
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# ALTER TABLE .. ADD COLUMN : with ( <column definition> [, ...] )
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
);
COMMIT;


--# result: success
ALTER TABLE t1 ADD COLUMN ( name VARCHAR(128), addr VARCHAR(1024) );
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# ALTER TABLE .. ADD COLUMN : with <constraint characteristics>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
( 
    name   VARCHAR(128) 
);
COMMIT;


--# result: success
ALTER TABLE t1 ADD COLUMN ( id INTEGER CONSTRAINT t1_uk UNIQUE DEFERRABLE );
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;




