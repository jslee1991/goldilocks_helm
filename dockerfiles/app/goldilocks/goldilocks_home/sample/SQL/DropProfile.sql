--###################################################
--# DROP PROFILE: simple example
--###################################################

--# result: success
DROP PROFILE IF EXISTS prof CASCADE;
COMMIT;

--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
COMMIT;

--# result: success
DROP USER IF EXISTS u1 CASCADE;
COMMIT;

--###################################################
--# DROP PROFILE: with <IF EXISTS>
--###################################################

--# result: success
DROP PROFILE IF EXISTS not_exist_profile;


--###################################################
--# DROP PROFILE: with <drop behavior>
--###################################################

--# result: success
CREATE PROFILE prof LIMIT
    FAILED_LOGIN_ATTEMPTS 5 
    PASSWORD_LOCK_TIME 1
    PASSWORD_LIFE_TIME 60 
    PASSWORD_GRACE_TIME 3
    PASSWORD_REUSE_MAX  3
    PASSWORD_REUSE_TIME 30
    PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;

--# result: success
CREATE USER u1 IDENTIFIED BY u1 PROFILE prof WITHOUT SCHEMA;
COMMIT;

--# result: success
DROP PROFILE prof CASCADE;
COMMIT;


--###################################################
--# DROP PROFILE: without <drop behavior>
--###################################################

--# result: success
CREATE PROFILE prof LIMIT
    FAILED_LOGIN_ATTEMPTS 5 
    PASSWORD_LOCK_TIME 1
    PASSWORD_LIFE_TIME 60 
    PASSWORD_GRACE_TIME 3
    PASSWORD_REUSE_MAX  3
    PASSWORD_REUSE_TIME 30
    PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;

--# result: success
DROP PROFILE prof;
COMMIT;




