--###################################################
--# CREATE PROFILE: simple example
--###################################################

--# result: success
DROP PROFILE IF EXISTS prof1;
COMMIT;

--###################################################
--# ACCOUNTING LOCKING
--###################################################

--# result: success
CREATE PROFILE prof1 LIMIT
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LOCK_TIME 3;
COMMIT;

--# result: success
DROP PROFILE prof1;
COMMIT;


--###################################################
--# PASSWORD EXPIRATION
--###################################################

--# result: success
CREATE PROFILE prof1 LIMIT
    PASSWORD_LIFE_TIME 90 
    PASSWORD_GRACE_TIME 7;
COMMIT;

--# result: success
DROP PROFILE prof1;
COMMIT;

--###################################################
--# PASSWORD REUSE
--###################################################

--# result: success
CREATE PROFILE prof1 LIMIT
    PASSWORD_REUSE_MAX  DEFAULT
    PASSWORD_REUSE_TIME DEFAULT;
COMMIT;

--# result: success
DROP PROFILE prof1;
COMMIT;

--###################################################
--# PASSWORD VERIFY FUNCTION
--###################################################

--# result: success
CREATE PROFILE prof1 LIMIT
    PASSWORD_VERIFY_FUNCTION KISA_VERIFY_FUNCTION;
COMMIT;

--# result: success
DROP PROFILE prof1;
COMMIT;

--###################################################
--# ALL PASSWORD PARAMETERS 
--###################################################

--# result: success
CREATE PROFILE prof1 LIMIT
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LOCK_TIME 3
    PASSWORD_LIFE_TIME 90 
    PASSWORD_GRACE_TIME 7
    PASSWORD_REUSE_MAX  DEFAULT
    PASSWORD_REUSE_TIME DEFAULT
    PASSWORD_VERIFY_FUNCTION KISA_VERIFY_FUNCTION;
COMMIT;

--# result: success
DROP PROFILE prof1;
COMMIT;
