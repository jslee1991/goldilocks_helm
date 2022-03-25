--###################################################
--# ALTER TABLE .. DROP SUPPLEMENTAL LOG : simple example
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER         PRIMARY KEY
  , name   VARCHAR(128) 
  , addr   VARCHAR(1024)
);
COMMIT;



--# result: success
ALTER TABLE t1 ADD SUPPLEMENTAL LOG DATA ( PRIMARY KEY ) COLUMNS;
COMMIT;


--# result: success
ALTER TABLE t1 DROP SUPPLEMENTAL LOG DATA ( PRIMARY KEY ) COLUMNS;
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;

