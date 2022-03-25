--###################################################
--# Sub-query Sample
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



--###################################################
--# Scalar Sub-query
--###################################################

--# result: 5 rows
--#         data_1
--#         data_1
--#         data_1
--#         data_1
--#         data_1
SELECT ( SELECT data FROM t1 WHERE id = 1 ) FROM t1;


--# result: 4 rows
--#         2    data_2
--#         3    data_3
--#         4    data_4
--#         5    data_5
SELECT * FROM t1 WHERE id > ( SELECT id FROM t1 WHERE id = 1 );


--# result: 5 rows
--#         1 data_1
--#         2 data_2
--#         3 data_3
--#         4 data_4
--#         5 data_5
SELECT * FROM t1 WHERE ( SELECT id FROM t1 WHERE id = 1 ) IN ( 0, 1 );



--###################################################
--# Row Sub-query
--###################################################

--# result: 5 rows
--#         1    data_1
--#         2    data_2
--#         3    data_3
--#         4    data_4
--#         5    data_5
SELECT * FROM t1 WHERE ( 2, 'data_2' ) > ( SELECT id, data FROM t1 WHERE id = 1 );


--# result: 5 rows
--#         1    data_1
--#         2    data_2
--#         3    data_3
--#         4    data_4
--#         5    data_5
SELECT * FROM t1 WHERE ( SELECT id, data FROM t1 WHERE id = 1 ) IN ( ( 0, 'data_0' ), ( 1, 'data_1' ) );



--###################################################
--# Relation Sub-query : Single Target
--###################################################

--# result: 5 rows
--#         1
--#         2
--#         3
--#         4
--#         5
SELECT * FROM ( SELECT id FROM t1 );


--# result: 5 rows
--#         1    data_1
--#         2    data_2
--#         3    data_3
--#         4    data_4
--#         5    data_5
SELECT * FROM t1 WHERE id IN ( SELECT id FROM t1 );


--# result: 5 rows
--#         1    data_1
--#         2    data_2
--#         3    data_3
--#         4    data_4
--#         5    data_5
SELECT * FROM t1 WHERE id <= ANY ( SELECT id FROM t1 );


--# result: 1 rows
--#         5    data_5
SELECT * FROM t1 WHERE id >= ALL ( SELECT id FROM t1 );



--###################################################
--# Relation Sub-query : Multiple Targets
--###################################################

--# result: 5 rows
--#         1    data_1
--#         2    data_2
--#         3    data_3
--#         4    data_4
--#         5    data_5
SELECT * FROM ( SELECT id, data FROM t1 );


--# result: 5 rows
--#         1    data_1
--#         2    data_2
--#         3    data_3
--#         4    data_4
--#         5    data_5
SELECT * FROM t1 WHERE ( id, data ) IN ( SELECT id, data FROM t1 );


--# result: 5 rows
--#         1    data_1
--#         2    data_2
--#         3    data_3
--#         4    data_4
--#         5    data_5
SELECT * FROM t1 WHERE ( id, data ) <= ANY ( SELECT id, data FROM t1 );


--# result: 1 rows
--#         5    data_5
SELECT * FROM t1 WHERE ( id, data ) >= ALL ( SELECT id, data FROM t1 );



--###################################################
--# Exists
--###################################################

--# result: 1 rows
--#         true
SELECT EXISTS( SELECT data FROM t1 ) FROM dual;

--# result: 1 rows
--#         true
SELECT EXISTS( SELECT id, data FROM t1 ) FROM dual;

--# result: 1 rows
--#         false
SELECT EXISTS( SELECT data FROM t1 WHERE false ) FROM dual;

--# result: 1 rows
--#         false
SELECT EXISTS( SELECT id, data FROM t1 WHERE false ) FROM dual;


--# result: 5 rows
--#         1    data_1
--#         2    data_2
--#         3    data_3
--#         4    data_4
--#         5    data_5
SELECT * FROM t1 WHERE EXISTS( SELECT id, data FROM t1 );


--# result: 5 rows
--#         5    data_5
--#         1    data_1
--#         2    data_2
--#         3    data_3
--#         4    data_4
SELECT * FROM t1 a ORDER BY EXISTS( SELECT id FROM t1 b WHERE a.id < b.id );



--###################################################
--# Not Exists
--###################################################

--# result: 1 rows
--#         false
SELECT NOT EXISTS( SELECT data FROM t1 ) FROM dual;

--# result: 1 rows
--#         false
SELECT NOT EXISTS( SELECT id, data FROM t1 ) FROM dual;

--# result: 1 rows
--#         true
SELECT NOT EXISTS( SELECT data FROM t1 WHERE false ) FROM dual;

--# result: 1 rows
--#         true
SELECT NOT EXISTS( SELECT id, data FROM t1 WHERE false ) FROM dual;


--# result: no rows
SELECT * FROM t1 WHERE NOT EXISTS( SELECT id, data FROM t1 );


--# result: 5 rows
--#         1    data_1
--#         2    data_2
--#         3    data_3
--#         4    data_4
--#         5    data_5
SELECT * FROM t1 a ORDER BY NOT EXISTS( SELECT id FROM t1 b WHERE a.id < b.id );
