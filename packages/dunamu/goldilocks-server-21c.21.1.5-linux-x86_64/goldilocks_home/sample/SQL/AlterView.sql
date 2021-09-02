--###################################################
--# ALTER VIEW: simple example
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP VIEW IF EXISTS v1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
);
COMMIT;


--# result: success
CREATE VIEW v1 AS SELECT * FROM t1;
COMMIT;


--# result: 2 columns
--#    ID
--#    NAME
\desc v1

--# result: 2 rows
--#    ID
--#    NAME
SELECT COLUMN_NAME 
  FROM DICTIONARY_SCHEMA.USER_TAB_COLS 
 WHERE TABLE_SCHEMA = 'PUBLIC'
   AND TABLE_NAME = 'V1';

--# result: 1 rows
--#   V1    FALSE
SELECT TABLE_NAME, IS_AFFECTED 
  FROM INFORMATION_SCHEMA.VIEWS 
 WHERE TABLE_SCHEMA = 'PUBLIC'
   AND TABLE_NAME = 'V1';



--# result: success
ALTER TABLE t1 ADD COLUMN ( dept_id  INTEGER,  addr  VARCHAR(1024) );
COMMIT;



--# result: 4 columns
--#    ID
--#    NAME
--#    DEPT_ID
--#    ADDR
\desc v1

--# need: ALTER VIEW .. COMPILE
--# result: 2 rows
--#    ID
--#    NAME
SELECT COLUMN_NAME 
  FROM DICTIONARY_SCHEMA.USER_TAB_COLS 
 WHERE TABLE_SCHEMA = 'PUBLIC'
   AND TABLE_NAME = 'V1';


--# need: ALTER VIEW .. COMPILE
--# result: 1 rows
--#   V1    TRUE
SELECT TABLE_NAME, IS_AFFECTED 
  FROM INFORMATION_SCHEMA.VIEWS 
 WHERE TABLE_SCHEMA = 'PUBLIC'
   AND TABLE_NAME = 'V1';



--# result: success
ALTER VIEW v1 COMPILE;
COMMIT;


--# result: 4 columns
--#    ID
--#    NAME
--#    DEPT_ID
--#    ADDR
\desc v1

--# result: 4 rows
--#    ID
--#    NAME
--#    DEPT_ID
--#    ADDR
SELECT COLUMN_NAME 
  FROM DICTIONARY_SCHEMA.USER_TAB_COLS 
 WHERE TABLE_SCHEMA = 'PUBLIC'
   AND TABLE_NAME = 'V1';


--# result: 1 rows
--#   V1    FALSE
SELECT TABLE_NAME, IS_AFFECTED 
  FROM INFORMATION_SCHEMA.VIEWS 
 WHERE TABLE_SCHEMA = 'PUBLIC'
   AND TABLE_NAME = 'V1';




--# result: success
DROP VIEW v1;
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# ALTER VIEW: with <view_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP VIEW IF EXISTS v1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
);
COMMIT;


--# result: success
CREATE VIEW v1 AS SELECT * FROM t1;
COMMIT;




--# result: success
ALTER VIEW public.v1 COMPILE;
COMMIT;




--# result: success
DROP VIEW v1;
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;




--###################################################
--# ALTER VIEW: with < COMPILE >
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP VIEW IF EXISTS v1;
COMMIT;


--# result: success
CREATE TABLE t1 
(
    id       INTEGER
  , name     VARCHAR(128)
);
COMMIT;


--# result: success
CREATE VIEW v1 AS SELECT * FROM t1;
COMMIT;




--# result: success
ALTER VIEW v1 COMPILE;
COMMIT;




--# result: success
DROP VIEW v1;
COMMIT;


--# result: success
DROP TABLE t1;
COMMIT;
