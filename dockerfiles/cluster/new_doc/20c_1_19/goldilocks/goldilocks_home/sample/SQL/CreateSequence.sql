--###################################################
--# CREATE SEQUENCE: simple example
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;


--# result: success
CREATE SEQUENCE seq1;
COMMIT;


--# result:  1
SELECT seq1.NEXTVAL FROM dual;

--# result:  2
SELECT seq1.NEXTVAL FROM dual;

--# SQL standard: NEXT VALUE FOR sequence_name
--# result:  3
SELECT NEXT VALUE FOR seq1 FROM dual;

--# other method: NEXTVAL( sequence_name )
--# result:  4
SELECT NEXTVAL( seq1 ) FROM dual;



--# result:  4
SELECT seq1.CURRVAL FROM dual;

--# result:  4
SELECT CURRVAL( seq1 ) FROM dual;




--# result: success
DROP SEQUENCE seq1;
COMMIT;



--###################################################
--# CREATE SEQUENCE: with <sequence_name>
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;


--# result: success
CREATE SEQUENCE public.seq1;
COMMIT;



--# result: success
DROP SEQUENCE seq1;
COMMIT;



--###################################################
--# CREATE SEQUENCE: with <sequence generator start with option>
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;



--# result: success
CREATE SEQUENCE seq1 START WITH 1000;
COMMIT;


--# result:  1000
SELECT seq1.NEXTVAL FROM dual;



--# result: success
DROP SEQUENCE seq1;
COMMIT;



--###################################################
--# CREATE SEQUENCE: with <sequence generator increment by option>
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;



--# result: success
CREATE SEQUENCE seq1 INCREMENT BY 2;
COMMIT;


--# result:  1
SELECT seq1.NEXTVAL FROM dual;

--# result:  3
SELECT seq1.NEXTVAL FROM dual;



--# result: success
DROP SEQUENCE seq1;
COMMIT;



--###################################################
--# CREATE SEQUENCE: with <sequence generator maxvalue option>
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;



--# result: success
CREATE SEQUENCE seq1 NO MAXVALUE;
COMMIT;



--# result: success
DROP SEQUENCE seq1;
COMMIT;




--###################################################
--# CREATE SEQUENCE: with <sequence generator minvalue option>
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;



--# result: success
CREATE SEQUENCE seq1 MINVALUE 100;
COMMIT;



--# result: success
DROP SEQUENCE seq1;
COMMIT;



--###################################################
--# CREATE SEQUENCE: with <sequence generator cycle option>
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;



--# result: success
CREATE SEQUENCE seq1 NO CYCLE;
COMMIT;



--# result: success
DROP SEQUENCE seq1;
COMMIT;



--###################################################
--# CREATE SEQUENCE: with <sequence generator cache option>
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;



--# result: success
CREATE SEQUENCE seq1 CACHE 100;
COMMIT;



--# result: success
DROP SEQUENCE seq1;
COMMIT;

