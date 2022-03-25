--###################################################
--# CREATE USER: simple example
--# - supposed: logon user is test and test has access control on database
--###################################################

--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
COMMIT;

--# result: success
DROP USER IF EXISTS u1 CASCADE;
COMMIT;



--# result: success
CREATE USER u1 IDENTIFIED BY u1_password
       DEFAULT   TABLESPACE mem_data_tbs
       TEMPORARY TABLESPACE mem_temp_tbs;
COMMIT;



--# result: success
--# grant database privileges
GRANT CREATE SESSION ON DATABASE TO u1;
COMMIT;


--# result: success
--# grant schema privileges
GRANT CREATE TABLE, CREATE VIEW, CREATE INDEX, CREATE SEQUENCE, ADD CONSTRAINT ON SCHEMA u1 TO u1;
COMMIT;


--# result: success
--# grant tablespace privileges
GRANT CREATE OBJECT ON TABLESPACE mem_data_tbs TO u1;
GRANT CREATE OBJECT ON TABLESPACE mem_temp_tbs TO u1;
COMMIT;






--## needs CREATE SESSION ON DATABASE
\connect u1 u1_password

--# result: success
--## needs CREATE TABLE ON SCHEMA u1
--## needs CREATE OBJECT ON TABLESPACE mem_data_tbs
CREATE TABLE u1.t1 ( c1 INTEGER, c2 INTEGER ) TABLESPACE mem_data_tbs;

COMMIT;

--# result: success
--## needs CREATE INDEX ON SCHEMA u1 
--## needs CREATE OBJECT ON TABLESPACE mem_temp_tbs
CREATE INDEX u1.idx ON t1 (c2) TABLESPACE mem_temp_tbs;

COMMIT;

--# result: success
--## needs ADD CONSTRAINT ON SCHEMA u1
ALTER TABLE t1 ADD CONSTRAINT u1.t1_pk PRIMARY KEY (c1) ;

COMMIT;

--# result: success
--## needs CREATE SEQUENCE ON SCHEMA u1
CREATE SEQUENCE u1.seq;

COMMIT;

--# result: 1 row
INSERT INTO u1.t1 VALUES ( u1.seq.NEXTVAL, u1.seq.NEXTVAL );

COMMIT;



\connect test test

--# result: success
DROP SCHEMA u1 CASCADE;
COMMIT;

--# result: success
DROP USER u1 CASCADE;
COMMIT;




--###################################################
--# CREATE USER: with <DEFAULT TABLESPACE tablespace_name>
--###################################################

--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
COMMIT;

--# result: success
DROP USER IF EXISTS u1 CASCADE;
COMMIT;


--# result: success
CREATE USER u1 IDENTIFIED BY u1
       DEFAULT TABLESPACE mem_data_tbs;
COMMIT;



--# result: success
DROP SCHEMA u1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;


--###################################################
--# CREATE USER: with <TEMPORARY TABLESPACE tablespace_name>
--###################################################

--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
COMMIT;

--# result: success
DROP USER IF EXISTS u1 CASCADE;
COMMIT;


--# result: success
CREATE USER u1 IDENTIFIED BY u1
       TEMPORARY TABLESPACE mem_temp_tbs;
COMMIT;



--# result: success
DROP SCHEMA u1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;


--###################################################
--# CREATE USER: with <schema clause>
--###################################################

--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
COMMIT;

--# result: success
DROP USER IF EXISTS u1 CASCADE;
COMMIT;




--# result: success
CREATE USER u1 IDENTIFIED BY u1 WITH SCHEMA;
COMMIT;


--# result: success
DROP SCHEMA u1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;





--# result: success
CREATE USER u1 IDENTIFIED BY u1 WITH SCHEMA u1;
COMMIT;


--# result: success
DROP SCHEMA u1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;




--# result: success
CREATE USER u1 IDENTIFIED BY u1 WITHOUT SCHEMA;
COMMIT;


--# result: success
DROP USER u1;
COMMIT;



--###################################################
--# CREATE USER: with <PROFILE profile_name>
--###################################################

--#################
--# DEFAULT
--#################

--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
COMMIT;

--# result: success
DROP USER IF EXISTS u1 CASCADE;
COMMIT;


--# result: success
CREATE USER u1 IDENTIFIED BY u1
       PROFILE DEFAULT;
COMMIT;



--# result: success
DROP SCHEMA u1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;

--#################
--# PROFILE 
--#################

--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
COMMIT;

--# result: success
DROP USER IF EXISTS u1 CASCADE;
COMMIT;

--# result: success
DROP PROFILE IF EXISTS prof1 CASCADE;
COMMIT;

--# result: success
CREATE PROFILE prof1 LIMIT
    FAILED_LOGIN_ATTEMPTS 5 
    PASSWORD_LOCK_TIME 1
    PASSWORD_LIFE_TIME 60 
    PASSWORD_GRACE_TIME 3
    PASSWORD_REUSE_MAX  3
    PASSWORD_REUSE_TIME 30
    PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;


--# result: success
CREATE USER u1 IDENTIFIED BY u1
       PROFILE prof1;
COMMIT;


--# result: success
DROP SCHEMA u1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;

--# result: success
DROP PROFILE prof1;
COMMIT;


--#################
--# NULL
--#################

--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
COMMIT;

--# result: success
DROP USER IF EXISTS u1 CASCADE;
COMMIT;


--# result: success
CREATE USER u1 IDENTIFIED BY u1
       PROFILE NULL;
COMMIT;



--# result: success
DROP SCHEMA u1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;

--###################################################
--# CREATE USER: with <PASSWORD EXPIRE>
--###################################################

--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
COMMIT;

--# result: success
DROP USER IF EXISTS u1 CASCADE;
COMMIT;


--# result: success
CREATE USER u1 IDENTIFIED BY u1 
       PASSWORD EXPIRE;
COMMIT;

--# result: success
DROP SCHEMA u1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;


--###################################################
--# CREATE USER: with <ACCOUNT {LOCK|UNLOCK}>
--###################################################


--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
COMMIT;

--# result: success
DROP USER IF EXISTS u1 CASCADE;
COMMIT;


--# result: success
CREATE USER u1 IDENTIFIED BY u1 
       ACCOUNT LOCK;
COMMIT;

--# result: success
DROP SCHEMA u1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;



--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
COMMIT;

--# result: success
DROP USER IF EXISTS u1 CASCADE;
COMMIT;


--# result: success
CREATE USER u1 IDENTIFIED BY u1 
       ACCOUNT UNLOCK;
COMMIT;


--# result: success
DROP SCHEMA u1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;
