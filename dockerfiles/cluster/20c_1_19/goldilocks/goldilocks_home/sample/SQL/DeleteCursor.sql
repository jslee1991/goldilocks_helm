--###################################################
--# DELETE cursor: simple example
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


--# result: success
DECLARE cur1 CURSOR FOR SELECT id, data FROM t1 FOR UPDATE;

--# result: success
OPEN cur1;



\var v_id   INTEGER
\var v_data VARCHAR(128)

--# result:  1   data_1
FETCH cur1 INTO :v_id, :v_data;

--# result:  2   data_2
FETCH cur1 INTO :v_id, :v_data;



--# result:  1 row
DELETE FROM t1 WHERE CURRENT OF cur1;



--# result:  3   data_3
FETCH cur1 INTO :v_id, :v_data;

--# result:  4   data_4
FETCH cur1 INTO :v_id, :v_data;



--# result:  1 row
DELETE FROM t1 WHERE CURRENT OF cur1;


--# result:  5   data_5
FETCH cur1 INTO :v_id, :v_data;

--# result:  no data
FETCH cur1 INTO :v_id, :v_data;


--# result: success
CLOSE cur1;



--# result: 3 rows
--#    1   data_1
--#    3   data_3
--#    5   data_5
SELECT id, data FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;


