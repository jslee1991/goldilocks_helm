--###################################################
--# SELECT.. INTO: simple example
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
--#     3  data_3
SELECT id, data INTO :v_id, :v_data FROM t1 WHERE id = 3;




\var v_count INTEGER

--# result: 1 row
--#     5
SELECT count(*) INTO :v_count FROM t1;



--# result: success
DROP TABLE t1;
COMMIT;

