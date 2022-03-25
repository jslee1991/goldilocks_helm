--###################################################
--# ALTER SEQUENCE: simple example
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;



--# result: success
CREATE SEQUENCE seq1;
COMMIT;


--# result: 1
SELECT seq1.NEXTVAL FROM dual;

--# result: 2
SELECT seq1.NEXTVAL FROM dual;



--# result: success
ALTER SEQUENCE seq1 RESTART;
COMMIT;


--# result: 1
SELECT seq1.NEXTVAL FROM dual;

--# result: 2
SELECT seq1.NEXTVAL FROM dual;


--# result: success
DROP SEQUENCE seq1;
COMMIT;



--###################################################
--# ALTER SEQUENCE: with <sequence_name>
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;



--# result: success
CREATE SEQUENCE seq1;
COMMIT;



--# result: success
ALTER SEQUENCE public.seq1 RESTART;
COMMIT;




--# result: success
DROP SEQUENCE seq1;
COMMIT;


--###################################################
--# ALTER SEQUENCE: with <alter sequence generator restart option>
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;



--# result: success
CREATE SEQUENCE seq1;
COMMIT;



--# result: success
ALTER SEQUENCE seq1 RESTART WITH 1000;
COMMIT;




--# result: success
DROP SEQUENCE seq1;
COMMIT;




--###################################################
--# ALTER SEQUENCE: with <sequence generator increment by option>
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;



--# result: success
CREATE SEQUENCE seq1;
COMMIT;



--# result: success
ALTER SEQUENCE seq1 INCREMENT BY 2;
COMMIT;




--# result: success
DROP SEQUENCE seq1;
COMMIT;




--###################################################
--# ALTER SEQUENCE: with <sequence generator maxvalue option>
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;



--# result: success
CREATE SEQUENCE seq1;
COMMIT;



--# result: success
ALTER SEQUENCE seq1 MAXVALUE 1000;
COMMIT;




--# result: success
DROP SEQUENCE seq1;
COMMIT;



--###################################################
--# ALTER SEQUENCE: with <sequence generator minvalue option>
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;



--# result: success
CREATE SEQUENCE seq1;
COMMIT;



--# result: success
ALTER SEQUENCE seq1 MINVALUE -1000;
COMMIT;




--# result: success
DROP SEQUENCE seq1;
COMMIT;




--###################################################
--# ALTER SEQUENCE: with <sequence generator cycle option>
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;



--# result: success
CREATE SEQUENCE seq1;
COMMIT;



--# result: success
ALTER SEQUENCE seq1 CYCLE;
COMMIT;




--# result: success
DROP SEQUENCE seq1;
COMMIT;




--###################################################
--# ALTER SEQUENCE: with <sequence generator cache option>
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;



--# result: success
CREATE SEQUENCE seq1;
COMMIT;



--# result: success
ALTER SEQUENCE seq1 NO CACHE;
COMMIT;




--# result: success
DROP SEQUENCE seq1;
COMMIT;



