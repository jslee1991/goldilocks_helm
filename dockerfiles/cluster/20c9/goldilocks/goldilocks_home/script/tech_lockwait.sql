--######################################################################################
-- View For LockWait
--
-- MEMBER_NAME      : Cluster Member Name
-- SESS_ID          : Session Identifier
-- SESS_SERIAL      : Session Serial
-- TRANS_ID         : Transaction Identifier
-- PROGRAM          : Program Name
-- LOGIN_TIME       : Session Login Time
-- DISCONNECT_SQL   : Session Disconnect SQL
--
--gSQL> SELECT * FROM TECH_LOCKWAIT;
--
--MEMBER_NAME SESSION_ID SESSION_SERIAL TRANS_ID PROGRAM LOGIN_TIME                 DISCONNECT_SQL                                
------------- ---------- -------------- -------- ------- -------------------------- ----------------------------------------------
--G2N1                45              4 90701869 gsql    2018-09-28 13:44:46.137219 ALTER SYSTEM DISCONNECT SESSION 45, 4 AT G2N1;
--######################################################################################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.TECH_LOCKWAIT;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.TECH_LOCKWAIT
(
  MEMBER_NAME,
  SESS_ID,
  SESS_SERIAL,
  CONN_TYPE,
  PROGRAM,
  LOGIN_TIME,
  TRANS_ID,
  DISCONNECT_SQL
)
AS
SELECT
  XS.CLUSTER_MEMBER_NAME,
  XS.ID,
  XS.SERIAL,
  XS.CONNECTION,
  XS.PROGRAM,
  XS.LOGON_TIME,
  XS.TRANS_ID,
  'ALTER SYSTEM DISCONNECT SESSION ' || XS.ID || ', ' || XS.SERIAL || CASE NVL(XS.CLUSTER_MEMBER_NAME, 'STANDALONE') 
                                                                           WHEN 'STANDALONE' THEN ';'
                                                                           ELSE CONCAT(CONCAT(' AT ', XS.CLUSTER_MEMBER_NAME), ';')
                                                                      END AS DISCONNECT_SQL
FROM
  X$SESSION@GLOBAL[IGNORE_INACTIVE_MEMBER] XS,
  CATALOG_NAME@LOCAL[IGNORE_INACTIVE_MEMBER] CN
WHERE
  1 = 1 AND
  CN.IS_CLUSTER = TRUE AND
  (XS.CLUSTER_MEMBER_NAME, XS.TRANS_ID) IN (SELECT
                                              CM.MEMBER_NAME,
                                              XT.DRIVER_TRANS_ID
                                            FROM
                                              CLUSTER_MEMBER@LOCAL[IGNORE_INACTIVE_MEMBER] CM,
                                              (SELECT
                                                 XT.DRIVER_MEMBER_POS DRIVER_MEMBER_POS,
                                                 XT.DRIVER_TRANS_ID DRIVER_TRANS_ID
                                               FROM
                                                 X$TRANSACTION@GLOBAL[IGNORE_INACTIVE_MEMBER] XT
                                               WHERE
                                                 (NVL(XT.CLUSTER_MEMBER_NAME, 'STANDALONE'), XT.SLOT_ID) IN (SELECT
                                                                                                               NVL(XLW.CLUSTER_MEMBER_NAME, 'STANDALONE'),
                                                                                                               XLW.GRANTED_TRANSACTION_SLOT_ID
                                                                                                             FROM
                                                                                                               X$LOCK_WAIT@GLOBAL[IGNORE_INACTIVE_MEMBER] XLW )) XT
                                            WHERE
                                              CM.MEMBER_POSITION = XT.DRIVER_MEMBER_POS)
UNION ALL
SELECT
  NVL(XS.CLUSTER_MEMBER_NAME, 'STANDALONE'),
  XS.ID,
  XS.SERIAL,
  XS.CONNECTION,
  XS.PROGRAM,
  XS.LOGON_TIME,
  XS.TRANS_ID,
  'ALTER SYSTEM DISCONNECT SESSION ' || XS.ID || ', ' || XS.SERIAL || CASE NVL(XS.CLUSTER_MEMBER_NAME, 'STANDALONE') 
                                                                           WHEN 'STANDALONE' THEN ';'
                                                                           ELSE CONCAT(CONCAT(' AT ', XS.CLUSTER_MEMBER_NAME), ';')
                                                                      END AS DISCONNECT_SQL
FROM
  X$SESSION@GLOBAL[IGNORE_INACTIVE_MEMBER] XS,
  X$LOCK_WAIT@GLOBAL[IGNORE_INACTIVE_MEMBER] XLW,
  CATALOG_NAME@LOCAL[IGNORE_INACTIVE_MEMBER] CN
WHERE
  1 = 1 AND
  CN.IS_CLUSTER = FALSE AND
  XLW.GRANTED_TRANSACTION_SLOT_ID = XS.ID;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.TECH_LOCKWAIT TO PUBLIC;