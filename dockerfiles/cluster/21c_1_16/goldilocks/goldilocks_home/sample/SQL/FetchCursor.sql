--###################################################
--# FETCH cursor: simple example
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
--# FETCH cursor: with < [FROM] cursor_name >
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
DECLARE cur2 CURSOR FOR SELECT id, data FROM t1;

--# result: success
OPEN cur2;

\var v_id   INTEGER
\var v_data VARCHAR(128)



--# result:  1   data_1
FETCH FROM cur2 INTO :v_id, :v_data;


--# result: success
CLOSE cur2;

--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# FETCH cursor: with <fetch orientation>
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




--# result:  1   data_1
FETCH NEXT cur_scroll INTO :v_id, :v_data;

--# result:  2   data_2
FETCH NEXT cur_scroll INTO :v_id, :v_data;



--# result:  1   data_1
FETCH PRIOR cur_scroll INTO :v_id, :v_data;

--# result:  no data
FETCH PRIOR cur_scroll INTO :v_id, :v_data;




--# result:  1   data_1
FETCH FIRST cur_scroll INTO :v_id, :v_data;

--# result:  1   data_1
FETCH FIRST cur_scroll INTO :v_id, :v_data;




--# result:  5   data_5
FETCH LAST cur_scroll INTO :v_id, :v_data;

--# result:  5   data_5
FETCH LAST cur_scroll INTO :v_id, :v_data;



--# result:  1   data_1
FETCH FIRST cur_scroll INTO :v_id, :v_data;

--# result:  1   data_1
FETCH CURRENT cur_scroll INTO :v_id, :v_data;

--# result:  5   data_5
FETCH LAST cur_scroll INTO :v_id, :v_data;

--# result:  5   data_5
FETCH CURRENT cur_scroll INTO :v_id, :v_data;

--# result:  3   data_3
FETCH ABSOLUTE 3 cur_scroll INTO :v_id, :v_data;

--# result:  3   data_3
FETCH CURRENT cur_scroll INTO :v_id, :v_data;



--# result:  1   data_1
FETCH ABSOLUTE 1 cur_scroll INTO :v_id, :v_data;

--# result:  5   data_5
FETCH ABSOLUTE -1 cur_scroll INTO :v_id, :v_data;

--# result:  no data
FETCH ABSOLUTE 6 cur_scroll INTO :v_id, :v_data;

--# result:  no data
FETCH ABSOLUTE -6 cur_scroll INTO :v_id, :v_data;

--# result:  3   data_3
FETCH ABSOLUTE 3 cur_scroll INTO :v_id, :v_data;

--# result:  3   data_3
FETCH ABSOLUTE -3 cur_scroll INTO :v_id, :v_data;




--# result:  4   data_4
FETCH RELATIVE 1 cur_scroll INTO :v_id, :v_data;

--# result:  3   data_3
FETCH RELATIVE -1 cur_scroll INTO :v_id, :v_data;

--# result:  no data
FETCH RELATIVE 5 cur_scroll INTO :v_id, :v_data;

--# result:  1   data_1
FETCH RELATIVE -5 cur_scroll INTO :v_id, :v_data;




--# result: success
CLOSE cur_scroll;

--# result: success
DROP TABLE t1;
COMMIT;



--###################################################
--# FETCH cursor: with <into result arguments>
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
DECLARE cur3 CURSOR FOR SELECT id, data, id, data FROM t1;

--# result: success
OPEN cur3;

\var v_id_1   INTEGER
\var v_id_2   INTEGER
\var v_data_1 VARCHAR(128)
\var v_data_2 VARCHAR(128)



--# result:  1   data_1    1   data_1  
FETCH cur3 INTO :v_id_1, :v_data_1, :v_id_2, :v_data_2;




--# result: success
CLOSE cur3;

--# result: success
DROP TABLE t1;
COMMIT;

