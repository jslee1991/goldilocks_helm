--###################################################
--# SELECT: simple example
--###################################################

--# result: success
DROP TABLE IF EXISTS supplier;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS part;
DROP TABLE IF EXISTS partsupp;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS lineitem;
COMMIT;

DROP VIEW IF EXISTS revenue;
COMMIT;

--# result: success
CREATE TABLE supplier
(
    s_suppkey     INTEGER
  , s_name        CHAR(25)
  , s_nation      VARCHAR(15)
  , s_phone       CHAR(15)
  , CONSTRAINT supplier_pk PRIMARY KEY( s_suppkey ) INDEX supplier_pk_index
);

CREATE TABLE customer
(
    c_custkey     INTEGER
  , c_name        VARCHAR(25)
  , c_nation      VARCHAR(15)
  , c_phone       CHAR(15)
  , c_mktsegment  CHAR(10)
  , CONSTRAINT customer_pk PRIMARY KEY( c_custkey ) INDEX customer_pk_index
);

CREATE TABLE part
(   
    p_partkey     INTEGER
  , p_name        VARCHAR(55)
  , p_brand       CHAR(10)
  , p_type        VARCHAR(25)
  , p_size        INTEGER
  , p_retailprice NUMERIC(12,2)
  , CONSTRAINT part_pk PRIMARY KEY( p_partkey ) INDEX part_pk_index
);

CREATE TABLE partsupp
(
    ps_partkey    INTEGER
  , ps_suppkey    INTEGER
  , ps_availqty   INTEGER
  , ps_supplycost NUMERIC(12,2)
  , CONSTRAINT partsupp_pk PRIMARY KEY( ps_partkey, ps_suppkey ) INDEX partsupp_pk_index
);

CREATE INDEX partsupp_partkey_fk ON partsupp( ps_partkey );
CREATE INDEX partsupp_suppkey_fk ON partsupp( ps_suppkey );

CREATE TABLE orders
(
    o_orderkey      INTEGER
  , o_custkey       INTEGER
  , o_totalprice    NUMERIC(12,2)
  , o_orderdate     DATE
  , o_orderpriority CHAR(15)
  , CONSTRAINT orders_pk PRIMARY KEY( o_orderkey ) INDEX orders_pk_index
);

CREATE INDEX orders_custkey_fk ON orders( o_custkey );

CREATE TABLE lineitem
(   
    l_orderkey      INTEGER
  , l_partkey       INTEGER
  , l_suppkey       INTEGER
  , l_linenumber    INTEGER
  , l_quantity      NUMERIC(12,2)
  , l_extendedprice NUMERIC(12,2)
  , l_discount      NUMERIC(12,2)
  , l_tax           NUMERIC(12,2)
  , l_shipdate      DATE
  , l_receiptdate   DATE
  , l_shipmode      CHAR(10)
  , CONSTRAINT lineitem_pk PRIMARY KEY( l_orderkey, l_linenumber ) INDEX lineitem_pk_index
);

CREATE INDEX lineitem_partkey_suppkey_fk ON lineitem( l_partkey, l_suppkey );

COMMIT;

CREATE VIEW revenue (supplier_no, total_revenue) AS
SELECT
    l_suppkey,
    ROUND( sum(l_extendedprice * (1 - l_discount)), 2)
FROM
    lineitem
WHERE
      l_shipdate >= date '1996-01-01'
  AND l_shipdate < date '1996-01-01' + interval '3' month
GROUP BY
    l_suppkey;
COMMIT;


--# result: success
INSERT INTO supplier VALUES(1, 'Supplier#1', 'FRANCE',        '27-918-335-1736');
INSERT INTO supplier VALUES(2, 'Supplier#2', 'KOREA',         '15-679-861-2259');
INSERT INTO supplier VALUES(3, 'Supplier#3', 'GERMANY',       '11-383-516-1199');
INSERT INTO supplier VALUES(4, 'Supplier#4', 'UNITED STATES', '25-843-787-7479');
INSERT INTO supplier VALUES(5, 'Supplier#5', 'CANADA',        '21-151-690-3663');

INSERT INTO customer VALUES(1, 'Customer#1', 'KOREA',         '25-989-741-2988', 'BUILDING');
INSERT INTO customer VALUES(2, 'Customer#2', 'CANADA',        '23-768-687-3665', 'AUTOMOBILE');
INSERT INTO customer VALUES(3, 'Customer#3', 'KOREA',         '11-719-748-3364', 'AUTOMOBILE');
INSERT INTO customer VALUES(4, 'Customer#4', 'GERMANY',       '14-128-190-5944', 'MACHINERY');
INSERT INTO customer VALUES(5, 'Customer#5', 'UNITED STATES', '13-750-942-6364', 'HOUSEHOLD');

INSERT INTO part VALUES(1, 'Part#1', 'Brand#1', 'COPPER',  7, 901);
INSERT INTO part VALUES(2, 'Part#2', 'Brand#1', 'NICKEL',  1, 902);
INSERT INTO part VALUES(3, 'Part#3', 'Brand#2', 'STEEL',  21, 903);
INSERT INTO part VALUES(4, 'Part#4', 'Brand#3', 'NICKEL', 14, 904);
INSERT INTO part VALUES(5, 'Part#5', 'Brand#3', 'STEEL',  15, 905);

INSERT INTO partsupp VALUES(1, 3, 3325, 771.64);
INSERT INTO partsupp VALUES(1, 2, 8076, 993.49);
INSERT INTO partsupp VALUES(2, 5, 3956, 337.09);
INSERT INTO partsupp VALUES(2, 2, 4069, 357.84);
INSERT INTO partsupp VALUES(3, 1, 8895, 378.49);
INSERT INTO partsupp VALUES(3, 4, 4969, 915.27);
INSERT INTO partsupp VALUES(4, 3, 8539, 438.37);
INSERT INTO partsupp VALUES(4, 5, 3025, 306.39);
INSERT INTO partsupp VALUES(5, 1, 4651, 920.92);
INSERT INTO partsupp VALUES(5, 4, 4093, 498.13);

INSERT INTO orders VALUES(1, 1, 173665.47, '1996-01-02', '4-NOT SPECIFIED');
INSERT INTO orders VALUES(2, 2, 46929.18,  '1996-12-01', '1-URGENT');
INSERT INTO orders VALUES(3, 4, 193846.25, '1993-10-14', '2-HIGH');
INSERT INTO orders VALUES(4, 3, 32151.78,  '1995-10-11', '3-MEDIUM');
INSERT INTO orders VALUES(5, 5, 144659.2,  '1994-07-30', '5-LOW');

INSERT INTO lineitem VALUES(1, 1, 2, 1, 17, 21168.23, .04, .02, '1996-02-13', '1996-02-22', 'TRUCK');
INSERT INTO lineitem VALUES(1, 4, 3, 3, 36, 45983.16, .09, .06, '1996-01-12', '1996-01-20', 'MAIL');
INSERT INTO lineitem VALUES(1, 5, 1, 2,  8, 13309.60, .10, .02, '1996-01-29', '1996-01-31', 'REG AIR');
INSERT INTO lineitem VALUES(2, 2, 5, 3, 28, 28955.64, .09, .06, '1996-12-21', '1997-01-16', 'AIR');
INSERT INTO lineitem VALUES(2, 3, 4, 2, 24, 22824.48, .10, .04, '1996-12-30', '1997-01-01', 'FOB');
INSERT INTO lineitem VALUES(3, 5, 4, 3, 32, 49620.16, .07, .02, '1993-10-30', '1993-11-03', 'MAIL');
INSERT INTO lineitem VALUES(4, 1, 3, 1, 38, 44694.46, .00, .05, '1995-10-28', '1995-11-02', 'RAIL');
INSERT INTO lineitem VALUES(4, 4, 5, 2, 45, 54058.05, .06, .00, '1995-10-12', '1995-10-23', 'AIR');
INSERT INTO lineitem VALUES(5, 3, 1, 2, 49, 46796.47, .10, .00, '1994-08-09', '1994-08-24', 'RAIL');
INSERT INTO lineitem VALUES(5, 2, 2, 3, 27, 39890.88, .06, .07, '1994-08-16', '1994-08-23', 'SHIP');

COMMIT;



--# result: 5 rows
--#     Supplier#1                FRANCE       
--#     Supplier#2                KOREA        
--#     Supplier#3                GERMANY      
--#     Supplier#4                UNITED STATES
--#     Supplier#5                CANADA       
SELECT s_name, s_nation FROM supplier;


--# result: 5 rows
--#     Supplier#5                CANADA       
--#     Supplier#4                UNITED STATES
--#     Supplier#3                GERMANY      
--#     Supplier#2                KOREA        
--#     Supplier#1                FRANCE       
SELECT s_name, s_nation FROM supplier ORDER BY s_name DESC;


--# result: 4 rows
--#     Supplier#2                KOREA        
--#     Supplier#3                GERMANY      
--#     Supplier#4                UNITED STATES
--#     Supplier#5                CANADA       
SELECT s_name, s_nation FROM supplier OFFSET 1;


--# result: 1 row
--#     Supplier#1                FRANCE       
SELECT s_name, s_nation FROM supplier LIMIT 1;


--# result: 1 row
--#     Supplier#2                KOREA        
SELECT s_name, s_nation FROM supplier ORDER BY s_name DESC OFFSET 3 LIMIT 1;


--# result: 5 rows
--#     Supplier#5                CANADA       
--#     Supplier#4                UNITED STATES
--#     Supplier#3                GERMANY      
--#     Supplier#2                KOREA        
--#     Supplier#1                FRANCE       
SELECT /*+ INDEX_DESC(supplier, supplier_pk_index) */ s_name, s_nation FROM supplier;


--# result: 5 rows
--#     COPPER
--#     NICKEL
--#     STEEL 
--#     NICKEL
--#     STEEL 
SELECT ALL p_type FROM part;


--# result: 3 rows
--#     COPPER
--#     NICKEL
--#     STEEL 
SELECT DISTINCT p_type FROM part ORDER BY 1;


--# result: 2 rows
--#     Part#1 Brand#1    COPPER      7
--#     Part#2 Brand#1    NICKEL      1
SELECT p_name, p_brand, p_type, p_size FROM part where p_size < 10;


--# result: 5 rows
--#             1            11401
--#             2             8025
--#             3            13864
--#             4            11564
--#             5             8744
SELECT ps_partkey, SUM(ps_availqty) FROM partsupp GROUP BY ps_partkey;


--# result: 3 rows
--#             1            11401
--#             3            13864
--#             4            11564
SELECT ps_partkey, SUM(ps_availqty) FROM partsupp GROUP BY ps_partkey having SUM(ps_availqty) > 10000;


--# result: 5 rows
--#             1 Supplier#1                FRANCE        27-918-335-1736
--#             2 Supplier#2                KOREA         15-679-861-2259
--#             3 Supplier#3                GERMANY       11-383-516-1199
--#             4 Supplier#4                UNITED STATES 25-843-787-7479
--#             5 Supplier#5                CANADA        21-151-690-3663
SELECT * FROM supplier;


--# result: 3 rows
--#             1      11978.64
--#             2       20321.5
--#             3      41844.68
SELECT revenue.* FROM revenue;


--# result: 3 rows
--#             1 11978.64
--#             2  20321.5
--#             3 41844.68
SELECT supplier_no suppno, total_revenue AS TOTAL FROM revenue;


--# result: 3 rows
--#             1           1      11978.64 11979
--#             1           2       20321.5 20322
--#             1           3      41844.68 41845
SELECT 1, revenue.*, CAST( total_revenue AS NATIVE_INTEGER ) TOTAL FROM revenue;


--# result: 5 rows
--#             Customer#1 KOREA        
--#             Customer#2 CANADA       
--#             Customer#3 KOREA        
--#             Customer#4 GERMANY      
--#             Customer#5 UNITED STATES
SELECT c_name, c_nation FROM customer;


--# result: 5 rows
--#             Customer#1 KOREA        
--#             Customer#2 CANADA       
--#             Customer#3 KOREA        
--#             Customer#4 GERMANY      
--#             Customer#5 UNITED STATES
SELECT * FROM (SELECT c_name, c_nation FROM customer);


--# result: 5 rows
--#             Customer#1 KOREA        
--#             Customer#2 CANADA       
--#             Customer#3 KOREA        
--#             Customer#4 GERMANY      
--#             Customer#5 UNITED STATES
SELECT * FROM (SELECT c_name, c_nation FROM customer) AS CUST ("CUSTOMER_NAME", "CUSTOMER_NATION");


--# result: 5 rows
--#             Customer#1    173665.47
--#             Customer#2     46929.18
--#             Customer#3     32151.78
--#             Customer#4    193846.25
--#             Customer#5    144659.2
SELECT customer.c_name, o_totalprice FROM (customer INNER JOIN orders ON customer.c_custkey = orders.o_custkey) ORDER BY 1;


--# result: 25 rows
--#             Customer#1     32151.78
--#             Customer#1     46929.18
--#             Customer#1    144659.2
--#             Customer#1    173665.47
--#             Customer#1    193846.25
--#             Customer#2     32151.78
--#             Customer#2    173665.47
--#             Customer#2     46929.18
--#             Customer#2    144659.2
--#             Customer#2    193846.25
--#             Customer#3     46929.18
--#             Customer#3    193846.25
--#             Customer#3    173665.47
--#             Customer#3     32151.78
--#             Customer#3    144659.2
--#             Customer#4     32151.78
--#             Customer#4     46929.18
--#             Customer#4    144659.2
--#             Customer#4    173665.47
--#             Customer#4    193846.25
--#             Customer#5     32151.78
--#             Customer#5     46929.18
--#             Customer#5    144659.2
--#             Customer#5    173665.47
--#             Customer#5    193846.25
SELECT c_name, o_totalprice FROM customer, orders ORDER BY 1, 2;


--# result: 25 rows
--#             Customer#1     32151.78
--#             Customer#1     46929.18
--#             Customer#1    144659.2
--#             Customer#1    173665.47
--#             Customer#1    193846.25
--#             Customer#2     32151.78
--#             Customer#2    173665.47
--#             Customer#2     46929.18
--#             Customer#2    144659.2
--#             Customer#2    193846.25
--#             Customer#3     46929.18
--#             Customer#3    193846.25
--#             Customer#3    173665.47
--#             Customer#3     32151.78
--#             Customer#3    144659.2
--#             Customer#4     32151.78
--#             Customer#4     46929.18
--#             Customer#4    144659.2
--#             Customer#4    173665.47
--#             Customer#4    193846.25
--#             Customer#5     32151.78
--#             Customer#5     46929.18
--#             Customer#5    144659.2
--#             Customer#5    173665.47
--#             Customer#5    193846.25
SELECT c_name, o_totalprice FROM customer CROSS JOIN orders ORDER BY 1, 2;


--# result: 5 rows
--#             Customer#1    173665.47
--#             Customer#2     46929.18
--#             Customer#3     32151.78
--#             Customer#4    193846.25
--#             Customer#5    144659.2
SELECT c_name, o_totalprice FROM customer INNER JOIN orders ON c_custkey = o_custkey ORDER BY 1;


--# result: 5 rows
--#             Customer#1         null
--#             Customer#2         null
--#             Customer#3     32151.78
--#             Customer#4    193846.25
--#             Customer#5    144659.2
SELECT c_name, o_totalprice FROM customer LEFT OUTER JOIN orders ON c_custkey = o_custkey AND o_orderdate < '1996-01-01' ORDER BY 1;


--# result: 5 rows
--#             Customer#1    173665.47
--#             Customer#3     32151.78
--#             null           46929.18
--#             null          144659.2
--#             null          193846.25
SELECT c_name, o_totalprice FROM customer RIGHT OUTER JOIN orders ON c_custkey = o_custkey AND c_nation = 'KOREA' ORDER BY 1, 2;


--# result: 9 rows
--#             Customer#1         null
--#             Customer#2         null
--#             Customer#3     32151.78
--#             Customer#4         null
--#             Customer#5         null
--#             null           46929.18
--#             null          144659.2
--#             null          173665.47
--#             null          193846.25
SELECT c_name, o_totalprice FROM customer FULL OUTER JOIN orders ON c_custkey = o_custkey AND c_nation = 'KOREA' AND o_orderdate < '1996-01-01' ORDER BY 1, 2;


--# result: 5 rows
--#             Customer#1    173665.47
--#             Customer#2     46929.18
--#             Customer#3     32151.78
--#             Customer#4    193846.25
--#             Customer#5    144659.2
SELECT c_name, o_totalprice FROM (SELECT c_custkey custkey, c_name FROM customer) NATURAL JOIN (SELECT o_custkey custkey, o_totalprice FROM orders) ORDER BY 1;


--# result: 1 row
--#         Supplier#2                KOREA
SELECT s_name, s_nation FROM supplier WHERE s_nation = 'KOREA';


--# result: 2 rows
--#         Supplier#2                       4069        357.84
--#         Supplier#2                       8076        993.49
SELECT s_name, ps_availqty, ps_supplycost FROM supplier, partsupp WHERE s_nation = 'KOREA' AND s_suppkey = ps_suppkey ORDER BY 1, 2;


--# result: 4 rows
--#             Customer#2 CANADA       
--#             Customer#3 KOREA        
--#             Customer#4 GERMANY      
--#             Customer#5 UNITED STATES
SELECT c_name, c_nation FROM customer OFFSET 1;


--# result: 1 row
--#             Customer#1 KOREA
SELECT c_name, c_nation FROM customer FETCH FIRST ROW ONLY;


--# result: 2 rows
--#             Customer#1 KOREA   
--#             Customer#2 CANADA
SELECT c_name, c_nation FROM customer FETCH FIRST 2 ROW ONLY;


--# result: 1 row
--#             Customer#1 KOREA
SELECT c_name, c_nation FROM customer LIMIT 1;


--# result: 2 rows
--#             Customer#2 CANADA  
--#             Customer#3 KOREA   
SELECT c_name, c_nation FROM customer LIMIT 1, 2;


--# result: 5 rows
--#             Customer#1 KOREA        
--#             Customer#2 CANADA       
--#             Customer#3 KOREA        
--#             Customer#4 GERMANY      
--#             Customer#5 UNITED STATES
SELECT c_name, c_nation FROM customer LIMIT ALL;


--# result: 2 rows
--#             Customer#2 CANADA  
--#             Customer#3 KOREA   
SELECT c_name, c_nation FROM customer OFFSET 1 FETCH 2;


--# result: 2 rows
--#             Customer#2 CANADA  
--#             Customer#3 KOREA   
SELECT c_name, c_nation FROM customer OFFSET 1 LIMIT 2;


--# result: 10 rows
--#             FRANCE
--#             KOREA
--#             GERMANY
--#             UNITED STATES
--#             CANADA
--#             KOREA
--#             CANADA
--#             KOREA
--#             GERMANY
--#             UNITED STATES
SELECT s_nation nation FROM supplier UNION ALL SELECT c_nation FROM customer;


--# result: 5 rows
--#             CANADA
--#             FRANCE
--#             GERMANY
--#             KOREA
--#             UNITED STATES
SELECT s_nation nation FROM supplier UNION DISTINCT SELECT c_nation FROM customer ORDER BY 1;


--# result: 1 row
--#             KOREA
SELECT c_nation nation FROM customer EXCEPT ALL SELECT s_nation FROM supplier;


--# result: no rows
SELECT c_nation nation FROM customer EXCEPT DISTINCT SELECT s_nation FROM supplier;


--# result: 4 rows
--#             CANADA
--#             GERMANY
--#             KOREA
--#             UNITED STATES
SELECT c_nation nation FROM customer INTERSECT ALL SELECT s_nation FROM supplier ORDER BY 1;


--# result: 4 rows
--#             CANADA
--#             GERMANY
--#             KOREA
--#             UNITED STATES
SELECT c_nation nation FROM customer INTERSECT DISTINCT SELECT s_nation FROM supplier ORDER BY 1;


--# result: 5 rows
--#             Customer#2 CANADA
--#             Customer#4 GERMANY
--#             Customer#1 KOREA
--#             Customer#3 KOREA
--#             Customer#5 UNITED STATES
SELECT c_name, c_nation FROM customer ORDER BY c_nation;


--# result: 5 rows
--#             Customer#5 UNITED STATES
--#             Customer#1 KOREA        
--#             Customer#3 KOREA        
--#             Customer#4 GERMANY      
--#             Customer#2 CANADA       
SELECT c_name, c_nation FROM customer ORDER BY c_nation DESC;

--# result: 5 rows
--#             Customer#5 UNITED STATES
--#             Customer#1 KOREA        
--#             Customer#3 KOREA        
--#             Customer#4 GERMANY      
--#             Customer#2 CANADA       
SELECT c_name, c_nation FROM customer ORDER BY 2 DESC;


--# result: 4 rows
--#             CANADA                    1
--#             GERMANY                   1
--#             KOREA                     2
--#             UNITED STATES             1
SELECT c_nation, COUNT(c_name) FROM customer GROUP BY c_nation ORDER BY 1;


--# result: 1 row
--#             5
SELECT COUNT(c_name) FROM customer GROUP BY NULL;


--# result: 1 row
--#             5
SELECT COUNT(c_name) FROM customer GROUP BY ();


--# result: 1 row
--#            KOREA                2 
SELECT c_nation, COUNT(c_name) FROM customer GROUP BY c_nation HAVING COUNT(c_name) > 1;


--# result: 1 row
--#             5
SELECT COUNT(c_name) FROM customer HAVING COUNT(c_name) > 1;


--# result: 5 rows
--#             Customer#1
--#             Customer#2
--#             Customer#3
--#             Customer#4
--#             Customer#5
SELECT (SELECT c_name FROM dual)  FROM customer;


--# result: 1 row
--#             Customer#2 CANADA
SELECT c_name, c_nation FROM customer WHERE c_nation = (SELECT 'CANADA' FROM dual);


--# result: 4 rows
--#             Supplier#2                KOREA
--#             Supplier#3                GERMANY
--#             Supplier#4                UNITED STATES
--#             Supplier#5                CANADA
SELECT s_name, s_nation FROM supplier WHERE s_nation IN (SELECT c_nation FROM customer);


--# result: 5 rows
--#             Supplier#1                FRANCE
--#             Supplier#2                KOREA
--#             Supplier#3                GERMANY
--#             Supplier#4                UNITED STATES
--#             Supplier#5                CANADA
SELECT * FROM (SELECT s_name, s_nation FROM supplier);



--# result: success
DROP TABLE supplier;
DROP TABLE customer;
DROP TABLE part;
DROP TABLE partsupp;
DROP TABLE orders;
DROP TABLE lineitem;
COMMIT;

DROP VIEW revenue;
COMMIT;

