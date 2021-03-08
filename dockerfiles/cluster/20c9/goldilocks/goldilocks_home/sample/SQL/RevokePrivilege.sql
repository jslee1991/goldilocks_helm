--###################################################
--# REVOKE privilege: simple example
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
GRANT ALL PRIVILEGES ON t1 TO u1;
COMMIT;


--# result: success
REVOKE INSERT, UPDATE, DELETE, LOCK, ALTER, INDEX ON t1 FROM u1;
COMMIT;




--# result: success
DROP TABLE t1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;


--###################################################
--# REVOKE privilege: with <grantee>
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
REVOKE SELECT ON t1 FROM u1;
COMMIT;

--# result: success
REVOKE SELECT ON t1 FROM PUBLIC;
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;


--###################################################
--# REVOKE privilege: with <GRANT OPTION FOR>
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
REVOKE GRANT OPTION FOR SELECT ON t1 FROM u1;
COMMIT;





--# result: success
DROP TABLE t1;
COMMIT;

--# result: success
DROP USER u1;
COMMIT;


--###################################################
--# REVOKE privilege: with <revoke behavior>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
DROP SCHEMA IF EXISTS u1 CASCADE;
DROP USER IF EXISTS u1 CASCADE;
DROP SCHEMA IF EXISTS u2 CASCADE;
DROP USER IF EXISTS u2 CASCADE;
COMMIT;


--# result: success
CREATE TABLE t1 ( id INTEGER );
COMMIT;

--# result: success
CREATE USER u1 IDENTIFIED BY u1 WITHOUT SCHEMA;
CREATE USER u2 IDENTIFIED BY u2 WITHOUT SCHEMA;
COMMIT;




--# result: success
GRANT SELECT ON t1 TO u1 WITH GRANT OPTION;
COMMIT;


--# result: success
--# supposed logon user is test (who has access control on database)
SET SESSION AUTHORIZATION u1;

--# result: success
GRANT SELECT ON public.t1 TO u2;
COMMIT;





--# result: success
--# supposed logon user is test
SET SESSION AUTHORIZATION test;


--# result: error
REVOKE SELECT ON t1 FROM u1 RESTRICT;
COMMIT;


--# result: success
REVOKE SELECT ON t1 FROM u1 CASCADE;
COMMIT;



--# result: success
DROP TABLE t1;
COMMIT;

--# result: success
DROP USER u1;
DROP USER u2;
COMMIT;


