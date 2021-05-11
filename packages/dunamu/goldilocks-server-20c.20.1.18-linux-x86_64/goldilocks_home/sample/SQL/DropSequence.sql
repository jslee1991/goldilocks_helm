--###################################################
--# DROP SEQUENCE: simple example
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS seq1;
COMMIT;



--# result: success
CREATE SEQUENCE seq1;
COMMIT;



--# result: success
DROP SEQUENCE seq1;
COMMIT;



--###################################################
--# DROP TABLE: with <IF EXISTS>
--###################################################

--# result: success
DROP SEQUENCE IF EXISTS not_exist_sequence;
COMMIT;






--###################################################
--# DROP SEQUENCE: with ROLLBACK
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



--# success
DROP SEQUENCE seq1;

--# result: error
SELECT seq1.NEXTVAL FROM dual;




--# success
ROLLBACK;



--# result: 3
SELECT seq1.NEXTVAL FROM dual;

--# result: 4
SELECT seq1.NEXTVAL FROM dual;



--# result: success
DROP SEQUENCE seq1;
COMMIT;


