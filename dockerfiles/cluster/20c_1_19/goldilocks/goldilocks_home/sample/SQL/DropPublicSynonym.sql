--###################################################
--# CREATE SYNONYM: simple example
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
GRANT CREATE TABLE ON SCHEMA branch TO branch;
COMMIT;

--# result: success
GRANT CREATE PUBLIC SYNONYM, DROP PUBLIC SYNONYM ON DATABASE TO branch;
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


--# CREATE PUBLIC SYNONYM 

--# result: success
CREATE PUBLIC SYNONYM B_Emp FOR branch.Employee;
COMMIT;

--# result: 1 someone
SELECT * FROM B_Emp;

--# DROP PUBLIC SYNONYM 

--# result: success
DROP PUBLIC SYNONYM B_Emp;
COMMIT;

\connect test test

--# DROP PUBLIC SYNONYM IF EXISTS 

--# result: success
DROP PUBLIC SYNONYM IF EXISTS B_Emp;
COMMIT;

--# result: success
DROP TABLE branch.Employee;
COMMIT;

--# result: success
DROP SCHEMA branch;
COMMIT;

--# result: success
DROP USER branch;
COMMIT;
