--###################################################
--# CREATE TABLE AS SELECT : simple example
--###################################################

--# result: success
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS recent_orders;
COMMIT;

--# result: success
CREATE TABLE orders 
( 
    order_id   NUMBER        
  , order_item VARCHAR(128)  
  , order_date DATE
);
COMMIT;

--# result: 1 row
INSERT INTO orders VALUES ( 1, 'Pen', '2010-01-01' );

--# result: 1 row
INSERT INTO orders VALUES ( 2, 'Book', '2015-03-03' );
COMMIT;

CREATE TABLE recent_orders 
    AS SELECT order_id, order_item, order_date FROM orders WHERE order_date >= '2015-03-03';
COMMIT;

--# result: 2 rows
--#         1   Pen  2010-01-01
--#         2   Book 2015-03-03
SELECT * FROM orders ORDER BY order_id;

--# result: 1 row
--#         2   Book 2015-03-03
SELECT * FROM recent_orders ORDER BY order_id;

--# result: success
DROP TABLE orders;
--# result: success
DROP TABLE recent_orders;
COMMIT;

--###################################################
--# CREATE VIEW: with <table_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS orders;
--# result: success
DROP TABLE IF EXISTS recenet_orders;
COMMIT;

--# result: success
CREATE TABLE public.orders 
( 
    order_id   NUMBER        
  , order_item VARCHAR(128)  
  , order_date DATE
);
COMMIT;

--# result: success
CREATE TABLE public.recent_orders 
    AS SELECT order_id, order_item, order_date FROM orders;
COMMIT;


--# result: success
DROP TABLE public.orders;
DROP TABLE public.recent_orders;
COMMIT;

--###################################################
--# CREATE TABLE AS SELECT : with < (column_name [,...])>
--###################################################

--# result: success
DROP TABLE IF EXISTS orders;
--# result: success
DROP TABLE IF EXISTS recent_orders;
COMMIT;

--# result: success
CREATE TABLE orders 
( 
    order_id   NUMBER        
  , order_item VARCHAR(128)  
  , order_date DATE
);
COMMIT;

--# result: success
CREATE TABLE recent_orders ( order_id, order_item, order_date ) 
    AS SELECT order_id, order_item, order_date FROM orders;
COMMIT;

--# result: success
DROP TABLE orders;
--# result: success
DROP TABLE recent_orders;
COMMIT;

--###################################################
--# CREATE TABLE AS SELECT : with <table physical attribute clause>
--###################################################

--# result: success
DROP TABLE IF EXISTS orders;
--# result: success
DROP TABLE IF EXISTS recent_orders;
COMMIT;

--# result: success
CREATE TABLE orders 
( 
    order_id   NUMBER        
  , order_item VARCHAR(128)  
  , order_date DATE
);
COMMIT;

--# result: success
CREATE TABLE recent_orders PCTFREE 10 PCTUSED 40 INITRANS 4 MAXTRANS 8 
    AS SELECT order_id, order_item, order_date FROM orders;
COMMIT;

--# result: success
DROP TABLE orders;
--# result: success
DROP TABLE recent_orders;
COMMIT;

--###################################################
--# CREATE TABLE AS SELECT : with <segment attr clause>
--###################################################

--# result: success
DROP TABLE IF EXISTS orders;
--# result: success
DROP TABLE IF EXISTS recent_orders;
COMMIT;

--# result: success
CREATE TABLE orders 
( 
    order_id   NUMBER        
  , order_item VARCHAR(128)  
  , order_date DATE
);
COMMIT;

--# result: success
CREATE TABLE recent_orders STORAGE ( INITIAL 10M NEXT 1M MINSIZE 10M MAXSIZE 100M )
    AS SELECT order_id, order_item, order_date FROM orders;
COMMIT;

--# result: success
DROP TABLE orders;
--# result: success
DROP TABLE recent_orders;
COMMIT;

--###################################################
--# CREATE TABLE AS SELECT : with <TABLESPACE tablespace_name>
--###################################################

--# result: success
DROP TABLE IF EXISTS orders;
--# result: success
DROP TABLE IF EXISTS recent_orders;
COMMIT;

--# result: success
CREATE TABLE orders
( 
    order_id   NUMBER        
  , order_item VARCHAR(128)  
  , order_date DATE
);
COMMIT;

--# result: success
CREATE TABLE recent_orders TABLESPACE mem_data_tbs
    AS SELECT order_id, order_item, order_date FROM orders;
COMMIT;

--# result: success
DROP TABLE orders;
--# result: success
DROP TABLE recent_orders;
COMMIT;

--###################################################
--# CREATE TABLE AS SELECT : with < AS <query expression> >
--###################################################

--# result: success
DROP TABLE IF EXISTS orders;
--# result: success
DROP TABLE IF EXISTS recent_orders;
COMMIT;

--# result: success
CREATE TABLE orders 
( 
    order_id   NUMBER        
  , order_item VARCHAR(128)  
  , order_date DATE
);
COMMIT;

--# result: success
CREATE TABLE recent_orders TABLESPACE mem_data_tbs
    AS SELECT order_date, COUNT(*) as cntPerDate
       FROM orders
       GROUP BY order_date
       ORDER BY order_date;
COMMIT;

--# result: success
DROP TABLE orders;
--# result: success
DROP TABLE recent_orders;
COMMIT;


--###################################################
--# CREATE TABLE AS SELECT : with <with data clause>
--###################################################

--# result: success
DROP TABLE IF EXISTS orders;
--# result: success
DROP TABLE IF EXISTS recent_orders;
COMMIT;

--# result: success
CREATE TABLE orders 
( 
    order_id   NUMBER        
  , order_item VARCHAR(128)  
  , order_date DATE
);
COMMIT;

--# result: 1 row
INSERT INTO orders VALUES ( 1, 'Pen', '2010-01-01' );

--# result: 1 row
INSERT INTO orders VALUES ( 2, 'Book', '2015-03-03' );
COMMIT;

--# result: success
CREATE TABLE recent_orders TABLESPACE mem_data_tbs
    AS SELECT order_id, order_item, order_date FROM orders WHERE order_date >= '2015-03-03'
    WITH DATA;
COMMIT;

--# result: 1
SELECT COUNT(*) FROM recent_orders;

--# result: success
DROP TABLE recent_orders;

--# result: success
CREATE TABLE recent_orders 
    AS SELECT order_id, order_item, order_date FROM orders WHERE order_date >= '2015-03-03'
    WITH NO DATA;
COMMIT;

--# result: 0
SELECT COUNT(*) FROM recent_orders;

--# result: success
DROP TABLE orders;
--# result: success
DROP TABLE recent_orders;
COMMIT;


