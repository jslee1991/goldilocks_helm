--###################################################
--# UPDATE .. RETURNING query: simple example
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , data   VARCHAR(128) 
);
COMMIT;


--# result: 5 rows
INSERT INTO t1 VALUES ( 1, 'data_1' ),
                      ( 2, 'data_2' ),
                      ( 3, 'data_3' ),
                      ( 4, 'data_4' ),
                      ( 5, 'data_5' );
COMMIT;



--# result: 2 rows
--#      4  new_data_4
--#      5  new_data_5
UPDATE t1 
   SET data = 'new_' || data
 WHERE id > 3
 RETURN id, data;
COMMIT;



--# result: 5 rows
--#     1   data_1
--#     2   data_2
--#     3   data_3
--#     4   new_data_4
--#     5   new_data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# UPDATE .. RETURNING query: with < NEW | OLD >
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , data   VARCHAR(128) 
);
COMMIT;


--# result: 5 rows
INSERT INTO t1 VALUES ( 1, 'data_1' ),
                      ( 2, 'data_2' ),
                      ( 3, 'data_3' ),
                      ( 4, 'data_4' ),
                      ( 5, 'data_5' );
COMMIT;



--# result: 2 rows
--#      4  new_data_4
--#      5  new_data_5
UPDATE t1 
   SET data = 'new_' || data
 WHERE id > 3
 RETURN NEW id, data;
COMMIT;




--# result: 2 rows
--#      1  data_1
--#      2  data_2
UPDATE t1 
   SET data = 'new_' || data
 WHERE id < 3
 RETURNING OLD id, data;
COMMIT;



--# result: 5 rows
--#     1   new_data_1
--#     2   new_data_2
--#     3   data_3
--#     4   new_data_4
--#     5   new_data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# UPDATE .. RETURNING query: with <value expression>
--###################################################

--# result: success
DROP TABLE IF EXISTS t1;
COMMIT;

--# result: success
CREATE TABLE t1 
( 
    id     NUMBER
  , data   VARCHAR(128) 
);
COMMIT;


--# result: 5 rows
INSERT INTO t1 VALUES ( 1, 'data_1' ),
                      ( 2, 'data_2' ),
                      ( 3, 'data_3' ),
                      ( 4, 'data_4' ),
                      ( 5, 'data_5' );
COMMIT;



--# result: 2 rows
--#      ID: 4, NEW_DATA: new_data_4
--#      ID: 5, NEW_DATA: new_data_5
UPDATE t1 
   SET data = 'new_' || data
 WHERE id > 3
 RETURN 'ID: ' || id || ', NEW_DATA: ' || data AS data_string;
COMMIT;



--# result: 5 rows
--#     1   data_1
--#     2   data_2
--#     3   data_3
--#     4   new_data_4
--#     5   new_data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;

