--###################################################
--# ALTER INDEX: with <index_name>
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

--# result: success
CREATE INDEX idx_t1_id ON t1( id );
COMMIT;



--# result: success
ALTER INDEX public.idx_t1_id PCTFREE 10;
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# ALTER INDEX: with <physical attribute clause>
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

--# result: success
CREATE INDEX idx_t1_id ON t1( id );
COMMIT;



--# result: success
ALTER INDEX idx_t1_id PCTFREE 10 INITRANS 4 MAXTRANS 8;
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# ALTER INDEX: with <segment attr clause>
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

--# result: success
CREATE INDEX idx_t1_id ON t1( id );
COMMIT;



--# result: success
ALTER INDEX idx_t1_id STORAGE ( INITIAL 10M NEXT 1M MINSIZE 10M MAXSIZE 100M );
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;
