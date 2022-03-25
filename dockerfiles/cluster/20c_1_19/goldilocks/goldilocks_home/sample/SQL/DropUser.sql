--###################################################
--# DROP USER: simple example
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



--# result: error
DROP USER u1 CASCADE;
COMMIT;



--# result: success
DROP SCHEMA u1 CASCADE;
COMMIT;

--# result: success
DROP USER u1 CASCADE;
COMMIT;



--###################################################
--# DROP USER: with <IF EXISTS>
--###################################################

--# result: success
DROP USER IF EXISTS not_exist_user;


--###################################################
--# DROP USER: with <drop behavior>
--###################################################


--# result: success
DROP SCHEMA IF EXISTS u1 CASCADE;
COMMIT;

--# result: success
DROP USER IF EXISTS u1 CASCADE;
COMMIT;



--# result: success
CREATE USER u1 IDENTIFIED BY u1 WITHOUT SCHEMA;
COMMIT;


--# result: success
DROP USER u1 RESTRICT;
COMMIT;


