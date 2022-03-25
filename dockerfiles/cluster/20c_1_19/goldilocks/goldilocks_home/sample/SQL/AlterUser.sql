--###################################################
--# ALTER USER: with <alter password>
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
ALTER USER u1 IDENTIFIED BY new_password;
COMMIT;



--# result: success
DROP SCHEMA u1 CASCADE;
COMMIT;

--# result: success
DROP USER u1 CASCADE;
COMMIT;



--###################################################
--# ALTER USER: with <alter default tablespace>
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
ALTER USER u1 DEFAULT TABLESPACE mem_data_tbs;
COMMIT;



--# result: success
DROP SCHEMA u1 CASCADE;
COMMIT;

--# result: success
DROP USER u1 CASCADE;
COMMIT;



--###################################################
--# ALTER USER: with <alter temporary tablespace>
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
ALTER USER u1 TEMPORARY TABLESPACE mem_temp_tbs;
COMMIT;



--# result: success
DROP SCHEMA u1 CASCADE;
COMMIT;

--# result: success
DROP USER u1 CASCADE;
COMMIT;


--###################################################
--# ALTER USER: with <alter schema path>
--###################################################

--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
DROP SCHEMA IF EXISTS s1 CASCADE;
COMMIT;

--# result: success
DROP USER IF EXISTS u1 CASCADE;
COMMIT;



--# result: success
CREATE USER u1 IDENTIFIED BY u1;
COMMIT;


--# result: success
CREATE SCHEMA s1 AUTHORIZATION u1;
COMMIT;


--# result: success
ALTER USER u1 SCHEMA PATH ( s1, u1, PUBLIC );
COMMIT;



--# result: success
DROP SCHEMA s1 CASCADE;
COMMIT;

--# result: success
DROP SCHEMA u1 CASCADE;
COMMIT;

--# result: success
DROP USER u1 CASCADE;
COMMIT;


--###################################################
--# ALTER USER: with < CURRENT PATH >
--###################################################

--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
DROP SCHEMA IF EXISTS s1 CASCADE;
COMMIT;

--# result: success
DROP USER IF EXISTS u1 CASCADE;
COMMIT;



--# result: success
CREATE USER u1 IDENTIFIED BY u1;
COMMIT;


--# result: success
CREATE SCHEMA s1 AUTHORIZATION u1;
COMMIT;


--# result: success
ALTER USER u1 SCHEMA PATH ( s1, CURRENT PATH );
COMMIT;



--# result: success
DROP SCHEMA s1 CASCADE;
COMMIT;

--# result: success
DROP SCHEMA u1 CASCADE;
COMMIT;

--# result: success
DROP USER u1 CASCADE;
COMMIT;


--###################################################
--# ALTER USER PUBLIC <alter schema path>
--###################################################

--# result: success
ALTER USER PUBLIC SCHEMA PATH ( PUBLIC, CURRENT PATH );

--# result: success
ROLLBACK;


--###################################################
--# ALTER USER: with <PROFILE profile_name>
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


--#################
--# DEFAULT
--#################

--# result: success
ALTER USER u1 PROFILE DEFAULT;
COMMIT;


--#################
--# PROFILE 
--#################

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
    PASSWORD_VERIFY_FUNCTION KISA_VERIFY_FUNCTION;
COMMIT;


--# result: success
ALTER USER u1 PROFILE prof1;
COMMIT;

--#################
--# NULL
--#################

--# result: success
ALTER USER u1 PROFILE NULL;
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

--###################################################
--# ALTER USER: with <PASSWORD EXPIRE>
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
ALTER USER u1 PASSWORD EXPIRE;
COMMIT;

--# result: success
DROP SCHEMA u1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;

--###################################################
--# ALTER USER: with <ACCOUNT {LOCK|UNLOCK}>
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
ALTER USER u1 ACCOUNT LOCK;
COMMIT;

--# result: success
ALTER USER u1 ACCOUNT UNLOCK;
COMMIT;

--# result: success
DROP SCHEMA u1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;
