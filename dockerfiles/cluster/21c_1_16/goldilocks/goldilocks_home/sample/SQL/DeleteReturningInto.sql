--###################################################
--# DELETE .. RETURNING INTO: simple example
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


\var v_id    INTEGER
\var v_data  VARCHAR(128)

--# result: 1 rows
--#     3   data_3
DELETE FROM t1 WHERE id = 3 RETURNING * INTO :v_id, :v_data;
COMMIT;




--# result: 4 rows
--#     1   data_1
--#     2   data_2
--#     4   data_4
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# DELETE .. RETURNING INTO: with <value expression>
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


\var v_new_data  VARCHAR(256)


--# result: 1 rows
--#     ID: 3, DATA: data_3
DELETE FROM t1 WHERE id = 3 RETURN 'ID: ' || id || ', DATA: ' || data AS new_data INTO :v_new_data;
COMMIT;





--# result: 4 rows
--#     1   data_1
--#     2   data_2
--#     4   data_4
--#     5   data_5
SELECT * FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;

