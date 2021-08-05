--###################################################
--# ALTER TABLE .. ADD CONSTRAINT : simple example
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
ALTER TABLE t1 ADD PRIMARY KEY ( id );
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# ALTER TABLE .. ADD CONSTRAINT : with <table_name>
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
ALTER TABLE public.t1 ADD PRIMARY KEY ( id );
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# ALTER TABLE .. ADD CONSTRAINT : with <CONSTRAINT constraint_name>
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
ALTER TABLE t1 ADD CONSTRAINT t1_pk PRIMARY KEY ( id );
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# ALTER TABLE .. ADD CONSTRAINT : with <constraint_name>
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
ALTER TABLE t1 ADD CONSTRAINT public.t1_pk PRIMARY KEY ( id );
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# ALTER TABLE .. ADD CONSTRAINT : w/o <CONSTRAINT constraint_name>
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
ALTER TABLE t1 ADD UNIQUE ( id );
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# ALTER TABLE .. ADD CONSTRAINT : with <( column_name [,...] )>
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
ALTER TABLE t1 ADD UNIQUE ( id, name );
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# ALTER TABLE .. ADD CONSTRAINT : with <index_name_clause>
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
ALTER TABLE t1 ADD CONSTRAINT t1_pk PRIMARY KEY ( id ) INDEX idx_t1_pk TABLESPACE mem_temp_tbs;
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# ALTER TABLE .. ADD CONSTRAINT : with <constraint characteristics>
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
ALTER TABLE t1 ADD CONSTRAINT t1_uk UNIQUE ( id ) DEFERRABLE INITIALLY DEFERRED;
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;
