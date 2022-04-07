--###################################################
--# SET SESSION AUTHORIZATION: simple example
--# - supposed: logon user is test and test has access control on database
--###################################################

--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
DROP USER IF EXISTS u1 CASCADE;
COMMIT;



--# result: success
CREATE USER u1 IDENTIFIED BY u1;
COMMIT;


--# result: 1 rows
--#     TEST    TEST    TEST
SELECT LOGON_USER(), SESSION_USER(), CURRENT_USER FROM dual;



--# result: success
SET SESSION AUTHORIZATION u1;


--# result: 1 rows
--#     TEST    U1    U1
SELECT LOGON_USER(), SESSION_USER(), CURRENT_USER FROM dual;



--# result: success
SET SESSION AUTHORIZATION test;


--# result: 1 rows
--#     TEST    TEST    TEST
SELECT LOGON_USER(), SESSION_USER(), CURRENT_USER FROM dual;


--# result: success
DROP SCHEMA u1;
DROP USER u1;
COMMIT;


