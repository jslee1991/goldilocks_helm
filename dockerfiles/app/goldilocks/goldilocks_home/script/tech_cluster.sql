--######################################################################################
-- View For Cluster
--
-- G_ID           : Group Identifier
-- M_ID           : Member Identifier
-- M_POS          : Member Position
-- NAME           : Member Name
-- STATUS         : Cluster Connection Status
-- G_COORD        : Global Coordinator
-- D_COORD        : Domain Coordinator
-- GLOBAL_SCN     : Global SCN
-- LOCAL_SCN      : Local SCN
-- AGABLE_SCN     : Local Ager SCN
-- AGABLE_SCN_GAP : Local Ager SCN Gap
-- IP             : Member IP
-- PORT           : Member PORT
--
--gSQL> SELECT * FROM TECH_CLUSTER;
--
--G_ID M_ID M_POS NAME STATUS G_COORD D_COORD GLOBAL_SCN LOCAL_SCN  AGABLE_SCN AGABLE_SCN_GAP IP            PORT
------ ---- ----- ---- ------ ------- ------- ---------- ---------- ---------- -------------- ------------ -----
--   1    1     0 G1N1 ACTIVE FALSE   TRUE    748.0.316  748.0.330  748.0.330  0.0.0          192.168.0.50 10000
--   2    2     1 G2N1 ACTIVE TRUE    TRUE    748.0.1253 748.0.1264 748.0.1264 0.0.0          192.168.0.50 20000
--######################################################################################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.TECH_CLUSTER;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.TECH_CLUSTER
(
  G_ID,
  M_ID,
  M_POS,
  NAME,
  STATUS,
  G_COORD,
  D_COORD,
  GLOBAL_SCN,
  LOCAL_SCN,
  AGABLE_SCN,
  AGABLE_SCN_GAP,
  IP,
  PORT
)
AS
SELECT
  CM.GROUP_ID G_ID,
  CM.MEMBER_ID M_ID,
  CM.MEMBER_POSITION M_POS,
  CM.MEMBER_NAME NAME,
  XCM.PHYSICAL_CONNECTION STATUS,
  XCM.IS_GLOBAL_COORD G_COORD,
  XCM.IS_DOMAIN_COORD D_COORD,
  XAI.GLOBAL_SCN GLOBAL_SCN,
  XAI.LOCAL_SCN LOCAL_SCN,
  XAI.AGABLE_SCN AGABLE_SCN,
  XAI.AGABLE_SCN_GAP AGABLE_SCN_GAP,
  XCL.HOST IP,
  XCL.PORT PORT
FROM
  CLUSTER_MEMBER@LOCAL[IGNORE_INACTIVE_MEMBER] CM,
  X$CLUSTER_MEMBER@LOCAL[IGNORE_INACTIVE_MEMBER] XCM,
  X$CLUSTER_LOCATION@LOCAL[IGNORE_INACTIVE_MEMBER] XCL,
  X$AGABLE_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] XAI
WHERE
  1 = 1 AND
  NVL(CM.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XCM.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(CM.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XCL.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(XCM.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XCL.CLUSTER_MEMBER_NAME, 'STANDALONE') AND    
  CM.MEMBER_ID = XCM.MEMBER_ID AND
  CM.MEMBER_POSITION = XCM.MEMBER_POSITION AND
  CM.MEMBER_NAME = XCL.MEMBER_NAME AND
  CM.MEMBER_NAME = NVL(XAI.CLUSTER_MEMBER_NAME, 'STANDALONE')
ORDER BY 1, 2;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.TECH_CLUSTER TO PUBLIC;