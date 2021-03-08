--###################################################
--# CREATE INDEX: simple example
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
  , dept_id  INTEGER
  , addr     VARCHAR(1024)
);

INSERT INTO t1 VALUES ( 1,    'leekmo', 101, 'somewhere' );
INSERT INTO t1 VALUES ( 2,     'mkkim', 101, 'anywhere' );
INSERT INTO t1 VALUES ( 3, 'egonspace', 101, 'unknwon' );
INSERT INTO t1 VALUES ( 4,      'bada', 202, 'N/A' );
INSERT INTO t1 VALUES ( 5,    'caddie', 303, 'somewhere' );
COMMIT;


--# result: success
CREATE INDEX idx_t1_id ON t1( id );
COMMIT;


--# result: 1 row
--#         leekmo
SELECT /*+ INDEX( t1, idx_t1_id ) */ name FROM t1 WHERE id = 1;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# CREATE INDEX: with <UNIQUE>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
  , dept_id  INTEGER
  , addr     VARCHAR(1024)
);
COMMIT;


--# result: success
CREATE UNIQUE INDEX idx_t1_id ON t1( id );
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# CREATE INDEX: with <index_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
  , dept_id  INTEGER
  , addr     VARCHAR(1024)
);
COMMIT;


--# result: success
CREATE INDEX public.idx_t1_id ON t1( id );
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# CREATE INDEX: with <table_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
  , dept_id  INTEGER
  , addr     VARCHAR(1024)
);
COMMIT;


--# result: success
CREATE INDEX idx_t1_id ON public.t1( id );
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# CREATE INDEX: with <column_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
  , dept_id  INTEGER
  , addr     VARCHAR(1024)
);
COMMIT;


--# result: success
CREATE INDEX idx_t1_id_name ON t1( id, name );
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;




--###################################################
--# CREATE INDEX: with <ASC | DESC>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
  , dept_id  INTEGER
  , addr     VARCHAR(1024)
);
COMMIT;


--# result: success
CREATE INDEX idx_t1_id ON t1( id ASC );
COMMIT;


--# result: success
CREATE INDEX idx_t1_dept_id ON t1( dept_id DESC );
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# CREATE INDEX: with <NULLS FIRST | NULLS LAST>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
  , dept_id  INTEGER
  , addr     VARCHAR(1024)
);
COMMIT;


--# result: success
CREATE INDEX idx_t1_id ON t1( id NULLS LAST );
COMMIT;


--# result: success
CREATE INDEX idx_t1_name ON t1( name NULLS FIRST );
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# CREATE INDEX: with <physical attribute clause>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
  , dept_id  INTEGER
  , addr     VARCHAR(1024)
);
COMMIT;


--# result: success
CREATE INDEX idx_t1_id ON t1( id )
       PCTFREE 10 INITRANS 4 MAXTRANS 8;

COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# CREATE INDEX: with <segment attr clause>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
  , dept_id  INTEGER
  , addr     VARCHAR(1024)
);
COMMIT;


--# result: success
CREATE INDEX idx_t1_id ON t1( id )
       STORAGE ( INITIAL 10M NEXT 1M MINSIZE 10M MAXSIZE 100M );

COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# CREATE INDEX: with <NOPARALLEL | PARALLEL [integer]>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
  , dept_id  INTEGER
  , addr     VARCHAR(1024)
);
COMMIT;


--# result: success
CREATE INDEX idx_t1_id ON t1( id ) NOPARALLEL;
COMMIT;


--# result: success
CREATE INDEX idx_t1_name ON t1( name ) PARALLEL;
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# CREATE INDEX: with <TABLESPACE tablespace_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
  , dept_id  INTEGER
  , addr     VARCHAR(1024)
);
COMMIT;


--# result: success
CREATE INDEX idx_t1_id ON t1( id ) TABLESPACE mem_data_tbs;
COMMIT;


--# result: success
CREATE INDEX idx_t1_name ON t1( name ) TABLESPACE mem_temp_tbs;
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;


