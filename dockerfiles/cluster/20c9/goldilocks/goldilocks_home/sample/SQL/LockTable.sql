--###################################################
--# LOCK TABLE: simple example
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
LOCK TABLE t1 IN EXCLUSIVE MODE;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# LOCK TABLE: with <lock target>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t2;
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



--# result: success
LOCK TABLE public.t1 IN EXCLUSIVE MODE;



--# result: success
LOCK TABLE t1, t2 IN EXCLUSIVE MODE;




--# result: success
DROP TABLE t1;
DROP TABLE t2;
COMMIT;




--###################################################
--# LOCK TABLE: with <lock mode>
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
LOCK TABLE t1 IN SHARE MODE;


--# result: success
LOCK TABLE t1 IN EXCLUSIVE MODE;



--# result: success
LOCK TABLE t1 IN ROW SHARE MODE;


--# result: success
LOCK TABLE t1 IN ROW EXCLUSIVE MODE;


--# result: success
LOCK TABLE t1 IN SHARE ROW EXCLUSIVE MODE;



--# result: success
DROP TABLE t1;
COMMIT;




--###################################################
--# LOCK TABLE: with <wait clause>
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
LOCK TABLE t1 IN EXCLUSIVE MODE;



--# result: success
LOCK TABLE t1 IN EXCLUSIVE MODE NOWAIT;



--# result: success
LOCK TABLE t1 IN EXCLUSIVE MODE WAIT 10;



--# result: success
DROP TABLE t1;
COMMIT;








