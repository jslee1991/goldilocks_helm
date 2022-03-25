--###################################################
--# ALTER TABLE .. STORAGE : simple example
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
ALTER TABLE t1 PCTFREE 10 PCTUSED 40 STORAGE ( NEXT 10M  MAXSIZE  100M );
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# ALTER TABLE .. STORAGE : with <table_name>
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
ALTER TABLE public.t1 PCTFREE 10 PCTUSED 40;
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# ALTER TABLE .. STORAGE : with <physical attribute clause>
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
ALTER TABLE t1 PCTFREE 10 PCTUSED 40 INITRANS 4 MAXTRANS 8;
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# ALTER TABLE .. STORAGE : with <segment attribute>
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
ALTER TABLE t1 STORAGE ( NEXT 1M MINSIZE 10M MAXSIZE 100M );
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;





