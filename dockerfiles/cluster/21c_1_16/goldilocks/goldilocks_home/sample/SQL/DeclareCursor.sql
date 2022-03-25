--###################################################
--# DECLARE cursor: simple example
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
DECLARE cur1 CURSOR FOR SELECT id, data FROM t1;




--# result: success
OPEN cur1;

\var v_id   INTEGER
\var v_data VARCHAR(128)

--# result:  1   data_1
FETCH cur1 INTO :v_id, :v_data;

--# result:  2   data_2
FETCH cur1 INTO :v_id, :v_data;

--# result:  3   data_3
FETCH cur1 INTO :v_id, :v_data;

--# result:  4   data_4
FETCH cur1 INTO :v_id, :v_data;

--# result:  5   data_5
FETCH cur1 INTO :v_id, :v_data;

--# result:  no data
FETCH cur1 INTO :v_id, :v_data;

--# result: success
CLOSE cur1;


--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# DECLARE cursor: with <updatable query>
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



--# result: error
DECLARE cur2 SENSITIVE CURSOR FOR SELECT id, COUNT(*) FROM t1 GROUP BY id;

--# result: success
DECLARE cur2 SENSITIVE CURSOR FOR SELECT id, data FROM t1;


--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# DECLARE cursor: with <cursor sensitivity>
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
DECLARE cur_sense SENSITIVE CURSOR FOR SELECT id, data FROM t1;





--# result: success
OPEN cur_sense;

--# result: 1 row
UPDATE t1 SET data = 'new data_2' WHERE id = 2;

--# result: 1 row
DELETE FROM t1 WHERE id = 4;

--# result: success
COMMIT;


\var v_id   INTEGER
\var v_data VARCHAR(128)

--# result:  1   data_1
FETCH cur_sense INTO :v_id, :v_data;

--# result:  2   new data_2
FETCH cur_sense INTO :v_id, :v_data;

--# result:  3   data_3
FETCH cur_sense INTO :v_id, :v_data;

--# result:  no data
FETCH cur_sense INTO :v_id, :v_data;

--# result:  5   data_5
FETCH cur_sense INTO :v_id, :v_data;

--# result:  no data
FETCH cur_sense INTO :v_id, :v_data;

--# result: success
CLOSE cur_sense;




--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# DECLARE cursor: with <cursor scrollability>
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
DECLARE cur_scroll SCROLL CURSOR FOR SELECT id, data FROM t1;





--# result: success
OPEN cur_scroll;



\var v_id   INTEGER
\var v_data VARCHAR(128)

--# result:  5   data_5
FETCH LAST cur_scroll INTO :v_id, :v_data;

--# result:  4   data_4
FETCH PRIOR cur_scroll INTO :v_id, :v_data;

--# result:  1   data_1
FETCH FIRST cur_scroll INTO :v_id, :v_data;

--# result:  3   data_3
FETCH ABSOLUTE 3 cur_scroll INTO :v_id, :v_data;

--# result:  2   data_2
FETCH RELATIVE -1 cur_scroll INTO :v_id, :v_data;

--# result:  no data
FETCH ABSOLUTE 100 cur_scroll INTO :v_id, :v_data;

--# result:  3   data_3
FETCH ABSOLUTE 3 cur_scroll INTO :v_id, :v_data;


--# result: success
CLOSE cur_scroll;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# DECLARE cursor: with <cursor holdability>
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
DECLARE cur_no_hold CURSOR WITHOUT HOLD FOR SELECT id, data FROM t1;





--# result: success
OPEN cur_no_hold;



\var v_id   INTEGER
\var v_data VARCHAR(128)

--# result:  1   data_1
FETCH cur_no_hold INTO :v_id, :v_data;

--# result:  2   data_2
FETCH cur_no_hold INTO :v_id, :v_data;

--# result: success
COMMIT;

--# result:  error
FETCH cur_no_hold INTO :v_id, :v_data;




--# result: success
DROP TABLE t1;
COMMIT;





--###################################################
--# DECLARE cursor: with <odbc cursor type>
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
DECLARE cur_keyset KEYSET CURSOR FOR SELECT id, data FROM t1;





--# result: success
OPEN cur_keyset;



\var v_id   INTEGER
\var v_data VARCHAR(128)

--# result:  1   data_1
FETCH NEXT cur_keyset INTO :v_id, :v_data;

--# result:  2   data_2
FETCH NEXT cur_keyset INTO :v_id, :v_data;

--# result:  3   data_3
FETCH NEXT cur_keyset INTO :v_id, :v_data;

--# result:  4   data_4
FETCH NEXT cur_keyset INTO :v_id, :v_data;

--# result:  5   data_5
FETCH NEXT cur_keyset INTO :v_id, :v_data;

--# result:  no data
FETCH NEXT cur_keyset INTO :v_id, :v_data;




--# result: 1 row
UPDATE t1 SET data = 'new data_2' WHERE id = 2;
COMMIT;

--# result: 1 row
DELETE FROM t1 WHERE id = 4;
COMMIT;




--# result:  5   data_5
FETCH PRIOR cur_keyset INTO :v_id, :v_data;

--# result:  no data
FETCH PRIOR cur_keyset INTO :v_id, :v_data;

--# result:  3   data_3
FETCH PRIOR cur_keyset INTO :v_id, :v_data;

--# result:  2   new data_2
FETCH PRIOR cur_keyset INTO :v_id, :v_data;

--# result:  1   data_1
FETCH PRIOR cur_keyset INTO :v_id, :v_data;



--# result: success
CLOSE cur_keyset;



--# result: success
DROP TABLE t1;
COMMIT;


--###################################################
--# DECLARE cursor: with <updatability clause>
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
DECLARE cur_update CURSOR FOR SELECT id, data FROM t1 FOR UPDATE;





--# result: success
OPEN cur_update;



\var v_id   INTEGER
\var v_data VARCHAR(128)

--# result:  1   data_1
FETCH cur_update INTO :v_id, :v_data;

--# result:  2   data_2
FETCH cur_update INTO :v_id, :v_data;

--# result:  1 row
UPDATE t1 SET data = 'new data_2' WHERE CURRENT OF cur_update;

--# result:  3   data_3
FETCH cur_update INTO :v_id, :v_data;

--# result:  4   data_4
FETCH cur_update INTO :v_id, :v_data;

--# result:  1 row
DELETE FROM t1 WHERE CURRENT OF cur_update;

--# result:  5   data_5
FETCH cur_update INTO :v_id, :v_data;

--# result:  no data
FETCH cur_update INTO :v_id, :v_data;

--# result: success
CLOSE cur_update;



--# result: 4 rows
--#    1   data_1
--#    2   new data_2
--#    3   data_3
--#    5   data_5
SELECT id, data FROM t1 ORDER BY 1;



--# result: success
DROP TABLE t1;
COMMIT;


