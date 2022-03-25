--###################################################
--# GRANT privilege: simple example
--###################################################

--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
COMMIT;

--# result: success
DROP USER IF EXISTS u1 CASCADE;
COMMIT;



--# result: success
CREATE USER u1 IDENTIFIED BY u1;
COMMIT;



--# result: success
--# grant database privileges
GRANT CREATE SESSION ON DATABASE TO u1;
COMMIT;


--# result: success
--# grant schema privileges
GRANT CREATE TABLE    ON SCHEMA u1 TO u1;
GRANT CREATE VIEW     ON SCHEMA u1 TO u1;
GRANT CREATE INDEX    ON SCHEMA u1 TO u1;
GRANT CREATE SEQUENCE ON SCHEMA u1 TO u1;
GRANT ADD CONSTRAINT  ON SCHEMA u1 TO u1;
COMMIT;


--# result: success
--# grant tablespace privileges
GRANT CREATE OBJECT ON TABLESPACE mem_data_tbs TO u1;
GRANT CREATE OBJECT ON TABLESPACE mem_temp_tbs TO u1;
COMMIT;




--# result: success
DROP SCHEMA u1 CASCADE;
COMMIT;

--# result: success
DROP USER u1 CASCADE;
COMMIT;



--###################################################
--# GRANT privilege: with <grantee>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP SCHEMA IF EXISTS u1 CASCADE;
DROP USER IF EXISTS u1 CASCADE;
COMMIT;


--# result: success
CREATE TABLE t1 ( id INTEGER );
COMMIT;

--# result: success
CREATE USER u1 IDENTIFIED BY u1 WITHOUT SCHEMA;
COMMIT;




--# result: success
GRANT SELECT ON t1 TO u1;
COMMIT;

--# result: success
GRANT SELECT ON t1 TO PUBLIC;
COMMIT;




--# result: success
DROP TABLE t1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;


--###################################################
--# GRANT privilege: with <WITH GRANT OPTION>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP SCHEMA IF EXISTS u1 CASCADE;
DROP USER IF EXISTS u1 CASCADE;
COMMIT;


--# result: success
CREATE TABLE t1 ( id INTEGER );
COMMIT;

--# result: success
CREATE USER u1 IDENTIFIED BY u1 WITHOUT SCHEMA;
COMMIT;




--# result: success
GRANT SELECT ON t1 TO u1 WITH GRANT OPTION;
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;


--###################################################
--# GRANT privilege: with <database privilege>
--###################################################

--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
DROP USER IF EXISTS u1 CASCADE;
COMMIT;


--# result: success
CREATE USER u1 IDENTIFIED BY u1 WITHOUT SCHEMA;
COMMIT;




--# result: success
GRANT CREATE SESSION ON DATABASE TO u1;
COMMIT;


--# result: success
GRANT SELECT ANY TABLE, LOCK ANY TABLE ON DATABASE TO u1;
COMMIT;


--# result: success
GRANT ALL PRIVILEGES ON DATABASE TO u1;
COMMIT;



--# result: success
DROP USER u1;
COMMIT;



--###################################################
--# GRANT privilege: with <tablespace privilege>
--###################################################

--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
DROP USER IF EXISTS u1 CASCADE;
COMMIT;


--# result: success
CREATE USER u1 IDENTIFIED BY u1 WITHOUT SCHEMA;
COMMIT;




--# result: success
GRANT CREATE OBJECT ON TABLESPACE mem_data_tbs TO u1;
COMMIT;



--# result: success
DROP USER u1;
COMMIT;



--###################################################
--# GRANT privilege: with <schema privilege>
--###################################################

--# result: success
DROP SCHEMA IF EXISTS s1 CASCADE;
DROP SCHEMA IF EXISTS u1 CASCADE;
DROP USER IF EXISTS u1 CASCADE;
COMMIT;


--# result: success
CREATE SCHEMA s1;
COMMIT;


--# result: success
CREATE USER u1 IDENTIFIED BY u1 WITHOUT SCHEMA;
COMMIT;



--# result: success
GRANT CREATE TABLE ON SCHEMA s1 TO u1;
COMMIT;


--# result: success
GRANT CREATE TABLE, CREATE VIEW, CREATE INDEX, CREATE SEQUENCE, ADD CONSTRAINT ON SCHEMA s1 TO u1;
COMMIT;




--# result: success
DROP SCHEMA s1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;



--###################################################
--# GRANT privilege: with <table privilege>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP SCHEMA IF EXISTS u1 CASCADE;
DROP USER IF EXISTS u1 CASCADE;
COMMIT;


--# result: success
CREATE TABLE t1 ( id INTEGER, name VARCHAR(128) );
COMMIT;


--# result: success
CREATE USER u1 IDENTIFIED BY u1 WITHOUT SCHEMA;
COMMIT;



--# result: success
GRANT SELECT ON TABLE t1 TO u1;
COMMIT;


--# result: success
GRANT INSERT, UPDATE, DELETE ON TABLE public.t1 TO u1;
COMMIT;


--# result: success
GRANT ALL PRIVILEGES ON TABLE t1 TO u1;
COMMIT;




--# result: success
DROP TABLE t1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;



--###################################################
--# GRANT privilege: with <column privilege>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP SCHEMA IF EXISTS u1 CASCADE;
DROP USER IF EXISTS u1 CASCADE;
COMMIT;


--# result: success
CREATE TABLE t1 ( id INTEGER, name VARCHAR(128) );
COMMIT;


--# result: success
CREATE USER u1 IDENTIFIED BY u1 WITHOUT SCHEMA;
COMMIT;



--# result: success
GRANT SELECT( id, name ) ON TABLE t1 TO u1;
COMMIT;


--# result: success
GRANT INSERT( name ), UPDATE( name ) ON TABLE t1 TO u1;
COMMIT;




--# result: success
DROP TABLE t1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;





--###################################################
--# GRANT privilege: with <sequence privilege>
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
DROP SCHEMA IF EXISTS u1 CASCADE;
DROP USER IF EXISTS u1 CASCADE;
COMMIT;


--# result: success
CREATE SEQUENCE seq1;
COMMIT;


--# result: success
CREATE USER u1 IDENTIFIED BY u1 WITHOUT SCHEMA;
COMMIT;



--# result: success
GRANT USAGE ON SEQUENCE seq1 TO u1;
COMMIT;




--# result: success
DROP SEQUENCE seq1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;









