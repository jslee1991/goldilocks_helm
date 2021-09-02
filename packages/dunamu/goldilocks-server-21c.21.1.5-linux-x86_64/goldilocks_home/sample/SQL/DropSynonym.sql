--###################################################
--# DROP SYNONYM: simple example
--###################################################

--# result: success
DROP SCHEMA IF EXISTS branch CASCADE;
COMMIT;

--# result: success
DROP USER IF EXISTS branch CASCADE;
COMMIT;


--# CREATE USER & SCHEMA

CREATE USER branch IDENTIFIED BY branch WITH SCHEMA;
COMMIT;

--# result: success
GRANT CREATE SESSION ON DATABASE TO branch;
COMMIT;

--# result: success
GRANT CREATE OBJECT ON TABLESPACE mem_data_tbs TO branch;
GRANT CREATE OBJECT ON TABLESPACE mem_temp_tbs TO branch;
COMMIT;

--# result: success
GRANT CREATE TABLE, CREATE SYNONYM ON SCHEMA branch TO branch;
COMMIT;

\connect branch branch

--# CREATE TABLE

--# result: success
CREATE TABLE branch.Employee 
( 
    id     NUMBER
  , name   VARCHAR(128) 
);
COMMIT;

INSERT INTO Employee VALUES ( 1, 'someone' );
COMMIT;


--# CREATE SYNONYM 

--# result: success
CREATE SYNONYM MyEmp FOR branch.Employee;
COMMIT;

--# result: 1 someone
SELECT * FROM MyEmp;


--# DROP SYNONYM 

--# result: success
DROP SYNONYM MyEmp;
COMMIT;


--# DROP SYNONYM IF EXISTS

--# result: success
DROP SYNONYM IF EXISTS MyEmp;
COMMIT;


--# result: success
DROP TABLE Employee;
COMMIT;

\connect test test

--# result: success
DROP SCHEMA branch;
COMMIT;

--# result: success
DROP USER branch;
COMMIT;
