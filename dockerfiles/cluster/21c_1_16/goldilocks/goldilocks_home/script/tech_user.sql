--######################################################################################
-- View For User
--
-- MEMBER_NAME      : Cluster Member Name
-- USER_NAME        : User Name
-- LOCK_STATUS      : Lock Status
-- TABLESPACE_TYPE  : Tablespace Type
-- TABLESPACE_NAME  : Tablespace Name
--
--gSQL> SELECT * FROM TECH_USER;
--
--MEMBER_NAME USER_NAME LOCK_STATUS TABLESPACE_TYPE TABLESPACE_NAME
------------- --------- ----------- --------------- ---------------
--STANDALONE  SYS       OPEN        DATA            MEM_DATA_TBS   
--STANDALONE  SYS       OPEN        TEMPORARY       MEM_TEMP_TBS   
--STANDALONE  TEST      OPEN        DATA            MEM_DATA_TBS   
--STANDALONE  TEST      OPEN        TEMPORARY       MEM_TEMP_TBS   
--######################################################################################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.TECH_USER;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.TECH_USER
(
  MEMBER_NAME,
  USER_NAME,
  LOCK_STATUS,
  TABLESPACE_TYPE,
  TABLESPACE_NAME
)
AS
SELECT
  NVL(AU.CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME,
  AU.AUTHORIZATION_NAME USER_NAME,
  US.LOCKED_STATUS LOCK_STATUS,
  TA.USAGE_TYPE TABLESPACE_TYPE,
  TA.TABLESPACE_NAME TABLESPACE_NAME
FROM
  AUTHORIZATIONS@GLOBAL[IGNORE_INACTIVE_MEMBER] AU,
  USERS@GLOBAL[IGNORE_INACTIVE_MEMBER] US,
  TABLESPACES@GLOBAL[IGNORE_INACTIVE_MEMBER] TA
WHERE
  1 = 1 AND
  NVL(AU.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(US.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(AU.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(TA.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(US.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(TA.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  AU.AUTH_ID = US.AUTH_ID AND
  US.DEFAULT_DATA_TABLESPACE_ID = TA.TABLESPACE_ID
UNION
SELECT
  NVL(AU.CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME,
  AU.AUTHORIZATION_NAME USER_NAME,
  US.LOCKED_STATUS LOCK_STATUS,
  TA.USAGE_TYPE TABLESPACE_TYPE,
  TA.TABLESPACE_NAME TABLESPACE_NAME
FROM
  AUTHORIZATIONS@GLOBAL[IGNORE_INACTIVE_MEMBER] AU,
  USERS@GLOBAL[IGNORE_INACTIVE_MEMBER] US,
  TABLESPACES@GLOBAL[IGNORE_INACTIVE_MEMBER] TA
WHERE
  1 = 1 AND
  NVL(AU.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(US.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(AU.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(TA.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(US.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(TA.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  AU.AUTH_ID = US.AUTH_ID AND
  US.DEFAULT_TEMP_TABLESPACE_ID = TA.TABLESPACE_ID 
ORDER BY 2, 3, 1, 4;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.TECH_USER TO PUBLIC;