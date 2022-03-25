--###################################################
--# UPDATE .. RETURNING INTO: simple example
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


\var v_id   INTEGER
\var v_data VARCHAR(128)

--# result: 1 row
--#      3  new_data_3
UPDATE t1 
   SET data = 'new_' || data
 WHERE id = 3
 RETURN id, data
 INTO :v_id, :v_data;
COMMIT;



--# result: 5 rows
--#     1   data_1
--#     2   data_2
--#     3   new_data_3
--#     4   data_4
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# UPDATE .. RETURNING INTO: with < NEW | OLD >
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



\var v_id   INTEGER
\var v_data VARCHAR(128)

--# result: 1 row
--#      3  new_data_3
UPDATE t1 
   SET data = 'new_' || data
 WHERE id = 3
 RETURN NEW id, data
 INTO :v_id, :v_data;
COMMIT;




--# result: 1 row
--#      2  data_2
UPDATE t1 
   SET data = 'new_' || data
 WHERE id = 2
 RETURNING OLD id, data
 INTO :v_id, :v_data;
COMMIT;



--# result: 5 rows
--#     1   data_1
--#     2   new_data_2
--#     3   new_data_3
--#     4   data_4
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# UPDATE .. RETURNING INTO: with <value expression>
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


\var v_new_string VARCHAR(256)

--# result: 1 rows
--#      ID: 3, NEW_DATA: new_data_3
UPDATE t1 
   SET data = 'new_' || data
 WHERE id = 3
 RETURN 'ID: ' || id || ', NEW_DATA: ' || data AS data_string
 INTO :v_new_string;
COMMIT;



--# result: 5 rows
--#     1   data_1
--#     2   data_2
--#     3   new_data_3
--#     4   data_4
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;

