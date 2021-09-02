--###################################################
--# DELETE .. RETURNING query: simple example
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
--#     4   data_4
--#     5   data_5
DELETE FROM t1 WHERE id > 3 RETURNING *;
COMMIT;




--# result: 3 rows
--#     1   data_1
--#     2   data_2
--#     3   data_3
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# DELETE .. RETURNING query: with <value expression>
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
--#     ID: 4, DATA: data_4
--#     ID: 5, DATA: data_5
DELETE FROM t1 
       WHERE id > 3 
       RETURNING 'ID: ' || id || ', DATA: ' || data AS id_data;
COMMIT;




--# result: 3 rows
--#     1   data_1
--#     2   data_2
--#     3   data_3
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;

