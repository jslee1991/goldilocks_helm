--###################################################
--# ALTER TABLE .. DROP CONSTRAINT : simple example
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER   PRIMARY KEY
  , name   VARCHAR(128) 
  , addr   VARCHAR(1024)
);
COMMIT;


--# result: success
ALTER TABLE t1 DROP PRIMARY KEY;
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# ALTER TABLE .. DROP CONSTRAINT : with <table_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER   PRIMARY KEY
  , name   VARCHAR(128) 
  , addr   VARCHAR(1024)
);
COMMIT;


--# result: success
ALTER TABLE public.t1 DROP PRIMARY KEY;
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# ALTER TABLE .. DROP CONSTRAINT : with <CONSTRAINT constraint_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER         CONSTRAINT t1_pk PRIMARY KEY
  , name   VARCHAR(128)   CONSTRAINT t1_uk UNIQUE
  , addr   VARCHAR(1024)
);
COMMIT;


--# result: success
ALTER TABLE t1 DROP CONSTRAINT t1_pk;
COMMIT;


--# result: success
ALTER TABLE t1 DROP CONSTRAINT t1_uk;
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;




--###################################################
--# ALTER TABLE .. DROP CONSTRAINT : with <constraint_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER         CONSTRAINT t1_uk UNIQUE
  , name   VARCHAR(128)   
  , addr   VARCHAR(1024)
);
COMMIT;



--# result: success
ALTER TABLE t1 DROP CONSTRAINT public.t1_uk;
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# ALTER TABLE .. DROP CONSTRAINT : with <PRIMARY KEY>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER     CONSTRAINT t1_pk PRIMARY KEY
  , name   VARCHAR(128) 
  , addr   VARCHAR(1024)
);
COMMIT;


--# result: success
ALTER TABLE t1 DROP PRIMARY KEY;
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;




--###################################################
--# ALTER TABLE .. DROP CONSTRAINT : with <UNIQUE ( column_name [, ...] )>
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
  , CONSTRAINT t1_uk UNIQUE ( id, name )
);
COMMIT;


--# result: success
ALTER TABLE t1 DROP UNIQUE( id, name );
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# ALTER TABLE .. DROP CONSTRAINT : with <drop behavior>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER          UNIQUE
  , name   VARCHAR(128) 
  , addr   VARCHAR(1024)
);
COMMIT;


--# result: success
ALTER TABLE t1 DROP UNIQUE( id ) RESTRICT;
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


