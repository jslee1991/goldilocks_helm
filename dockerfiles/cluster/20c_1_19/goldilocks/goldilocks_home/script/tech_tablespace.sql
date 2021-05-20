--######################################################################################
-- View For Tablespace
--
-- CLUSTER_NAME    : Cluster Member Name
-- TABLESPACE_NAME : Tablespace Name
-- TOTAL_MEGABYTE  : Total MegaByte Size
-- USED_MEGABYTE   : Used MegaByte Size
-- FREE_MEGABYTE   : Available MegaByte Size
-- FREE_PERCENTAGE : Available Percent
--
--GSQL> SELECT * FROM TECH_TABLESPACE;
--
--CLUSTER_NAME TABLESPACE_NAME TOTAL_MEGABYTE USED_MEGABYTE FREE_MEGABYTE FREE_PERCENTAGE
-------------- --------------- -------------- ------------- ------------- ---------------
--STANDALONE   DICTIONARY_TBS          256.00         80.31        175.68           68.62
--STANDALONE   MEM_DATA_TBS             32.00          8.25         23.75           74.21
--STANDALONE   MEM_TEMP_TBS             32.00          2.50         29.50           92.18
--STANDALONE   MEM_UNDO_TBS             32.00         16.00         16.00           50.00
--######################################################################################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.TECH_TABLESPACE;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.TECH_TABLESPACE
(
  CLUSTER_NAME,
  TABLESPACE_NAME,
  TOTAL_MEGABYTE,
  USED_MEGABYTE,
  FREE_MEGABYTE,
  FREE_PERCENTAGE
)
AS
SELECT
  NVL(TBS.CLUSTER_NAME, 'STANDALONE') MEMBER_NAME,
  TBS.NAME TABLESPACE_NAME,
  TO_CHAR(TRUNC( TBS.TOTAL / 1024 / 1024, 2 ), '9999999990.00') TOTAL_MB,
  TO_CHAR(TRUNC( DECODE( ( SEG.ALLOC * TBS.PAGE_SIZE / 1024 / 1024 ), NULL, 0, ( SEG.ALLOC * TBS.PAGE_SIZE / 1024 / 1024 ) ), 2 ), '999999990.00') USED_MB,
  TO_CHAR(TRUNC( DECODE( ( (TBS.TOTAL/8192 - SEG.ALLOC) * TBS.PAGE_SIZE / 1024 / 1024 ), NULL, TBS.TOTAL / 1024 / 1024, ( (TBS.TOTAL/8192 - SEG.ALLOC) * TBS.PAGE_SIZE / 1024 / 1024 ) ), 2 ), '999999990.00') FREE_MB,
  TO_CHAR(TRUNC( DECODE( ( (TBS.TOTAL/8192 - SEG.ALLOC) * TBS.PAGE_SIZE / 1024 / 1024 ), NULL, TBS.TOTAL / 1024 / 1024, ( (TBS.TOTAL/8192 - SEG.ALLOC) * TBS.PAGE_SIZE / 1024 / 1024 ) ) / ( TBS.TOTAL / 1024 / 1024 ) * 100, 2 ), '99999999990.00') FREE_PERCENTAGE
FROM
  ( SELECT
      NVL(XT.CLUSTER_MEMBER_NAME, 'STANDALONE') AS CLUSTER_NAME,
      XT.ID AS ID,
      XT.NAME AS NAME,
      XD2.TOTAL AS TOTAL,
      XT.PAGE_SIZE AS PAGE_SIZE
    FROM X$TABLESPACE@GLOBAL[IGNORE_INACTIVE_MEMBER] XT,
      ( SELECT
          NVL(XD.CLUSTER_MEMBER_NAME, 'STANDALONE') CLUSTER_NAME,
          XD.TABLESPACE_ID ID,
          SUM( XD.SIZE ) TOTAL
        FROM X$DATAFILE@GLOBAL[IGNORE_INACTIVE_MEMBER] XD
        WHERE XD.STATE != 'DROPPED'
        GROUP BY XD.CLUSTER_MEMBER_NAME, XD.TABLESPACE_ID
      ) XD2
    WHERE XT.ID = XD2.ID
      AND NVL(XT.CLUSTER_MEMBER_NAME, 'STANDALONE') = XD2.CLUSTER_NAME
      AND XT.NAME NOT IN ('MEM_UNDO_TBS')
  ) TBS
LEFT OUTER JOIN
  ( SELECT
      NVL(XS.CLUSTER_MEMBER_NAME, 'STANDALONE') AS CLUSTER_NAME,
      XS.TBS_ID AS TBS_ID,
      SUM( XS.ALLOC_PAGE_COUNT ) AS ALLOC
    FROM X$SEGMENT@GLOBAL[IGNORE_INACTIVE_MEMBER] XS
    WHERE XS.SEGMENT_TYPE = 'BITMAP'
    GROUP BY XS.CLUSTER_MEMBER_NAME, XS.TBS_ID
  ) SEG
ON TBS.ID = SEG.TBS_ID
  AND TBS.CLUSTER_NAME = SEG.CLUSTER_NAME
UNION ALL
SELECT
  NVL(TBS.CLUSTER_NAME, 'STANDALONE') MEMBER_NAME,
  TBS.NAME TABLESPACE_NAME,
  TO_CHAR(TRUNC( TBS.TOTAL / 1024 / 1024, 2 ), '9999999990.00') TOTAL_MB,
  TO_CHAR(TRUNC( DECODE( ( SEG.ALLOC * TBS.PAGE_SIZE / 1024 / 1024 ), NULL, 0, ( SEG.ALLOC * TBS.PAGE_SIZE / 1024 / 1024 ) ), 2 ), '999999990.00') USED_MB,
  TO_CHAR(TRUNC( DECODE( ( (TBS.TOTAL/8192 - SEG.ALLOC) * TBS.PAGE_SIZE / 1024 / 1024 ), NULL, TBS.TOTAL / 1024 / 1024, ( (TBS.TOTAL/8192 - SEG.ALLOC) * TBS.PAGE_SIZE / 1024 / 1024 ) ), 2 ), '999999990.00') FREE_MB,
  TO_CHAR(TRUNC( DECODE( ( (TBS.TOTAL/8192 - SEG.ALLOC) * TBS.PAGE_SIZE / 1024 / 1024 ), NULL, TBS.TOTAL / 1024 / 1024, ( (TBS.TOTAL/8192 - SEG.ALLOC) * TBS.PAGE_SIZE / 1024 / 1024 ) ) / ( TBS.TOTAL / 1024 / 1024 ) * 100, 2 ), '99999999990.00') FREE_PERCENTAGE
FROM
  ( SELECT
      NVL(XT.CLUSTER_MEMBER_NAME, 'STANDALONE') CLUSTER_NAME,
      XT.ID AS ID,
      XT.NAME AS NAME,
      XD2.TOTAL AS TOTAL,
      XT.PAGE_SIZE AS PAGE_SIZE
    FROM X$TABLESPACE@GLOBAL[IGNORE_INACTIVE_MEMBER] XT,
      ( SELECT
          NVL(XD.CLUSTER_MEMBER_NAME, 'STANDALONE') CLUSTER_NAME,
          XD.TABLESPACE_ID ID,
          SUM( XD.SIZE ) TOTAL
        FROM X$DATAFILE@GLOBAL[IGNORE_INACTIVE_MEMBER] XD
        WHERE XD.STATE != 'DROPPED'
        GROUP BY XD.CLUSTER_MEMBER_NAME, XD.TABLESPACE_ID
      ) XD2
    WHERE XT.ID = XD2.ID
      AND NVL(XT.CLUSTER_MEMBER_NAME, 'STANDALONE') = XD2.CLUSTER_NAME
      AND XT.NAME = 'MEM_UNDO_TBS'
  ) TBS
LEFT OUTER JOIN
  ( SELECT
      CLUSTER_NAME AS CLUSTER_NAME,
      SUM(ALLOC_REAL) AS ALLOC
    FROM 
      ( SELECT
	  NVL(XUS.CLUSTER_MEMBER_NAME, 'STANDALONE') CLUSTER_NAME,
	  XUS.SEGMENT_ID,
          CASE (XUS.ALLOC_PAGE_COUNT - XUS.AGABLE_PAGE_COUNT) < TO_NUMBER(XP.VALUE) WHEN TRUE THEN TO_NUMBER(XP.VALUE) ELSE (XUS.ALLOC_PAGE_COUNT - XUS.AGABLE_PAGE_COUNT) END AS ALLOC_REAL
        FROM X$UNDO_SEGMENT@GLOBAL[IGNORE_INACTIVE_MEMBER] XUS, X$PROPERTY@GLOBAL[IGNORE_INACTIVE_MEMBER] XP
        WHERE XP.PROPERTY_NAME='MINIMUM_UNDO_PAGE_COUNT'
          AND NVL(XUS.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XP.CLUSTER_MEMBER_NAME, 'STANDALONE')
      ) 
    GROUP BY CLUSTER_NAME
  ) SEG
ON TBS.NAME = 'MEM_UNDO_TBS'
  AND TBS.CLUSTER_NAME = SEG.CLUSTER_NAME
ORDER BY 1, 2
;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.TECH_TABLESPACE TO PUBLIC;