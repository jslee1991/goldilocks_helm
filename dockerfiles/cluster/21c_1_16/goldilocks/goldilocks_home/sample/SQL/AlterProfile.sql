--###################################################
--# ALTER PROFILE: simple example
--###################################################

--# result: success
DROP PROFILE IF EXISTS prof1;
COMMIT;

CREATE PROFILE prof1 LIMIT
    FAILED_LOGIN_ATTEMPTS 5 
    PASSWORD_LOCK_TIME 1
    PASSWORD_LIFE_TIME 60 
    PASSWORD_GRACE_TIME 3
    PASSWORD_REUSE_MAX  3
    PASSWORD_REUSE_TIME 30
    PASSWORD_VERIFY_FUNCTION KISA_VERIFY_FUNCTION;
COMMIT;


--###################################################
--# ACCOUNTING LOCKING
--###################################################

--# result: success
ALTER PROFILE prof1 LIMIT
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LOCK_TIME 3;
COMMIT;


--###################################################
--# PASSWORD EXPIRATION
--###################################################

--# result: success
ALTER PROFILE prof1 LIMIT
    PASSWORD_LIFE_TIME 90 
    PASSWORD_GRACE_TIME 7;
COMMIT;

--###################################################
--# PASSWORD REUSE
--###################################################

--# result: success
ALTER PROFILE prof1 LIMIT
    PASSWORD_REUSE_MAX  DEFAULT
    PASSWORD_REUSE_TIME DEFAULT;
COMMIT;

--###################################################
--# PASSWORD VERIFY FUNCTION
--###################################################

--# result: success
ALTER PROFILE prof1 LIMIT
    PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;

--###################################################
--# ALL PASSWORD PARAMETERS 
--###################################################

--# result: success
ALTER PROFILE prof1 LIMIT
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LOCK_TIME 3
    PASSWORD_LIFE_TIME 90 
    PASSWORD_GRACE_TIME 7
    PASSWORD_REUSE_MAX  DEFAULT
    PASSWORD_REUSE_TIME DEFAULT
    PASSWORD_VERIFY_FUNCTION NULL;
COMMIT;

--# result: success
DROP PROFILE prof1;
COMMIT;
