--###################################################
--# DROP SCHEMA: simple example
--###################################################

--# result: success
DROP SCHEMA IF EXISTS s1 CASCADE;
COMMIT;


--# result: success
CREATE SCHEMA s1;
COMMIT;


--# result: success
CREATE TABLE s1.t1
(
    id     INTEGER
  , name   VARCHAR(128)
);
COMMIT;

--# result: 1 row
INSERT INTO s1.t1 VALUES ( 1, 'leekmo' );
COMMIT;


--# result: success
DROP SCHEMA s1 CASCADE;
COMMIT;



--###################################################
--# DROP SCHEMA: with <IF EXISTS>
--###################################################

--# result: success
DROP SCHEMA IF EXISTS not_exist_schema;
COMMIT;


--###################################################
--# DROP SCHEMA: with <drop behavior>
--###################################################


--# result: success
DROP SCHEMA IF EXISTS s1 CASCADE;
COMMIT;


--# result: success
CREATE SCHEMA s1;
COMMIT;


--# result: success
CREATE TABLE s1.t1
(
    id     INTEGER
  , name   VARCHAR(128)
);
COMMIT;




--# result: error
DROP SCHEMA s1 RESTRICT;


--# result: success
DROP SCHEMA s1 CASCADE;
COMMIT;


