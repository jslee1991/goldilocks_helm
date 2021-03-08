--###################################################################################
--# build performance views of PERFORMANCE_VIEW_SCHEMA
--###################################################################################

--##############################################################
--# SYS AUTHORIZATION
--##############################################################

SET SESSION AUTHORIZATION SYS;


--##############################################################
--# V$ARCHIVELOG
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$ARCHIVELOG;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$ARCHIVELOG;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$ARCHIVELOG
(  
       ORIGIN_MEMBER_NAME
     , ARCHIVELOG_MODE
     , LAST_ARCHIVED_LOG
     , ARCHIVELOG_DIR
     , ARCHIVELOG_FILE_PREFIX
)
AS 
SELECT 
       arclog.CLUSTER_MEMBER_NAME
     , CAST( arclog.ARCHIVELOG_MODE AS VARCHAR(32 OCTETS) )        -- ARCHIVELOG_MODE
     , CAST( arclog.LAST_INACTIVATED_LOGFILE_SEQ_NO AS NUMBER )    -- LAST_ARCHIVED_LOG
     , CAST( arclog.ARCHIVELOG_DIR_1 AS VARCHAR(1024 OCTETS) )     -- ARCHIVELOG_DIR
     , CAST( arclog.ARCHIVELOG_FILE AS VARCHAR(128 OCTETS) )       -- ARCHIVELOG_FILE_PREFIX
  FROM 
       FIXED_TABLE_SCHEMA.X$ARCHIVELOG@GLOBAL[IGNORE_INACTIVE_MEMBER] AS arclog
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$ARCHIVELOG
(  
       ARCHIVELOG_MODE
     , LAST_ARCHIVED_LOG
     , ARCHIVELOG_DIR
     , ARCHIVELOG_FILE_PREFIX
)
AS 
SELECT 
       ARCHIVELOG_MODE
     , LAST_ARCHIVED_LOG
     , ARCHIVELOG_DIR
     , ARCHIVELOG_FILE_PREFIX
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$ARCHIVELOG@LOCAL
;
             
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$ARCHIVELOG
        IS 'The V$ARCHIVELOG displays information of log archiving';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$ARCHIVELOG.ARCHIVELOG_MODE
        IS 'database log mode: the value in ( NOARCHIVELOG, ARCHIVELOG )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$ARCHIVELOG.LAST_ARCHIVED_LOG
        IS 'sequence number of last archived log file';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$ARCHIVELOG.ARCHIVELOG_DIR
        IS 'archive destination path';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$ARCHIVELOG.ARCHIVELOG_FILE_PREFIX
        IS 'file prefix name of the archived log';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$ARCHIVELOG TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$ARCHIVELOG TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$ARCHIVELOG;
CREATE PUBLIC SYNONYM GV$ARCHIVELOG FOR PERFORMANCE_VIEW_SCHEMA.GV$ARCHIVELOG;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$ARCHIVELOG;
CREATE PUBLIC SYNONYM V$ARCHIVELOG FOR PERFORMANCE_VIEW_SCHEMA.V$ARCHIVELOG;
COMMIT;

--##############################################################
--# V$BACKUP
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$BACKUP;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$BACKUP;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$BACKUP
(  
       ORIGIN_MEMBER_NAME
     , TBS_NAME
     , BACKUP_STATUS
     , BACKUP_LSN
)
AS 
SELECT 
       backup.CLUSTER_MEMBER_NAME
     , CAST( backup.NAME AS VARCHAR(128 OCTETS) ) AS TBS_NAME         -- TBS_NAME
     , CAST( backup.STATUS AS VARCHAR(16 OCTETS) ) AS BACKUP_STATUS   -- BACKUP_STATUS
     , CAST( datafile.BACKUP_LSN AS NUMBER )                          -- BACKUP_LSN
  FROM 
       FIXED_TABLE_SCHEMA.X$BACKUP@GLOBAL[IGNORE_INACTIVE_MEMBER] AS backup
       LEFT OUTER JOIN
       ( SELECT CLUSTER_MEMBER_ID, TABLESPACE_ID, MIN(CHECKPOINT_LSN) AS BACKUP_LSN
           FROM FIXED_TABLE_SCHEMA.X$DATAFILE@GLOBAL[IGNORE_INACTIVE_MEMBER]
          GROUP BY CLUSTER_MEMBER_ID
                 , TABLESPACE_ID ) AS datafile
       ON  backup.ID = datafile.TABLESPACE_ID
       AND backup.CLUSTER_MEMBER_ID = datafile.CLUSTER_MEMBER_ID
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$BACKUP
(  
       TBS_NAME
     , BACKUP_STATUS
     , BACKUP_LSN
)
AS 
SELECT 
       TBS_NAME
     , BACKUP_STATUS
     , BACKUP_LSN
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$BACKUP@LOCAL
;
             
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$BACKUP
        IS 'The V$BACKUP displays information of backup';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BACKUP.TBS_NAME
        IS 'tablespace name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BACKUP.BACKUP_STATUS
        IS 'indicates whether the tablespace begin backup ( ACTIVE ) or not ( INACTIVE )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BACKUP.BACKUP_LSN
        IS 'the last checkpoint lsn of tablespace when backup started';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$BACKUP TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$BACKUP TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$BACKUP;
CREATE PUBLIC SYNONYM GV$BACKUP FOR PERFORMANCE_VIEW_SCHEMA.GV$BACKUP;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$BACKUP;
CREATE PUBLIC SYNONYM V$BACKUP FOR PERFORMANCE_VIEW_SCHEMA.V$BACKUP;
COMMIT;

--##############################################################
--# V$COLUMNS
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$COLUMNS;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$COLUMNS;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$COLUMNS 
( 
       ORIGIN_MEMBER_NAME
     , TABLE_OWNER
     , TABLE_SCHEMA
     , TABLE_NAME
     , COLUMN_NAME
     , ORDINAL_POSITION
     , DATA_TYPE
     , DATA_PRECISION
     , DATA_SCALE
     , COMMENTS
)
AS 
SELECT
       col.CLUSTER_MEMBER_NAME
     , auth.AUTHORIZATION_NAME                          -- TABLE_OWNER
     , sch.SCHEMA_NAME                                  -- TABLE_SCHEMA
     , tab.TABLE_NAME                                   -- TABLE_NAME
     , col.COLUMN_NAME                                  -- COLUMN_NAME
     , CAST( col.LOGICAL_ORDINAL_POSITION AS NUMBER )   -- ORDINAL_POSITION
     , dtd.DECLARED_DATA_TYPE                           -- DATA_TYPE
     , CAST( dtd.DECLARED_NUMERIC_PRECISION AS NUMBER ) -- DATA_PRECISION
     , CAST( dtd.DECLARED_NUMERIC_SCALE AS NUMBER )     -- DATA_SCALE
     , col.COMMENTS                                     -- COMMENTS
  FROM 
       DEFINITION_SCHEMA.COLUMNS@GLOBAL[IGNORE_INACTIVE_MEMBER]               AS col 
     , DEFINITION_SCHEMA.DATA_TYPE_DESCRIPTOR@GLOBAL[IGNORE_INACTIVE_MEMBER]  AS dtd 
     , DEFINITION_SCHEMA.TABLES@GLOBAL[IGNORE_INACTIVE_MEMBER]                AS tab 
     , DEFINITION_SCHEMA.SCHEMATA@GLOBAL[IGNORE_INACTIVE_MEMBER]              AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS@GLOBAL[IGNORE_INACTIVE_MEMBER]        AS auth 
 WHERE  
       sch.SCHEMA_NAME = 'PERFORMANCE_VIEW_SCHEMA'
   AND col.DTD_IDENTIFIER    = dtd.DTD_IDENTIFIER 
   AND col.CLUSTER_MEMBER_ID = dtd.CLUSTER_MEMBER_ID
   AND col.TABLE_ID          = tab.TABLE_ID 
   AND col.CLUSTER_MEMBER_ID = tab.CLUSTER_MEMBER_ID
   AND col.SCHEMA_ID         = sch.SCHEMA_ID 
   AND col.CLUSTER_MEMBER_ID = sch.CLUSTER_MEMBER_ID
   AND col.OWNER_ID          = auth.AUTH_ID 
   AND col.CLUSTER_MEMBER_ID = auth.CLUSTER_MEMBER_ID
ORDER BY 
      1
    , 3
    , 4
    , 6
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$COLUMNS 
( 
       TABLE_OWNER
     , TABLE_SCHEMA
     , TABLE_NAME
     , COLUMN_NAME
     , ORDINAL_POSITION
     , DATA_TYPE
     , DATA_PRECISION
     , DATA_SCALE
     , COMMENTS
)
AS 
SELECT 
       TABLE_OWNER
     , TABLE_SCHEMA
     , TABLE_NAME
     , COLUMN_NAME
     , ORDINAL_POSITION
     , DATA_TYPE
     , DATA_PRECISION
     , DATA_SCALE
     , COMMENTS
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$COLUMNS@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$COLUMNS 
        IS 'The V$COLUMNS has one row for each column of all the performance views (views beginning with V$).';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$COLUMNS.TABLE_OWNER
        IS 'owner name who owns the performance view';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$COLUMNS.TABLE_SCHEMA
        IS 'schema name of the performance view';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$COLUMNS.TABLE_NAME
        IS 'name of the performance view';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$COLUMNS.COLUMN_NAME
        IS 'column name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$COLUMNS.ORDINAL_POSITION
        IS 'the ordinal position (> 0) of the column in the performance view';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$COLUMNS.DATA_TYPE
        IS 'the data type name that a user declared';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$COLUMNS.DATA_PRECISION
        IS 'the precision value that a user declared';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$COLUMNS.DATA_SCALE
        IS 'the scale value that a user declared';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$COLUMNS.COMMENTS
        IS 'comments of the column';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$COLUMNS TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$COLUMNS TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$COLUMNS;
CREATE PUBLIC SYNONYM GV$COLUMNS FOR PERFORMANCE_VIEW_SCHEMA.GV$COLUMNS;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$COLUMNS;
CREATE PUBLIC SYNONYM V$COLUMNS FOR PERFORMANCE_VIEW_SCHEMA.V$COLUMNS;
COMMIT;

--##############################################################
--# V$DATAFILE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$DATAFILE;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$DATAFILE;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$DATAFILE
(  
       ORIGIN_MEMBER_NAME
     , TBS_NAME
     , DATAFILE_NAME
     , CHECKPOINT_LSN
     , CREATION_TIME
     , FILE_SIZE
     , LOADED_CHECKPOINT_LSN
     , CORRUPT_PAGE_COUNT
)
AS 
SELECT 
       datafile.CLUSTER_MEMBER_NAME
     , ( SELECT CAST( NAME AS VARCHAR(128 OCTETS) )
           FROM FIXED_TABLE_SCHEMA.X$TABLESPACE@GLOBAL[IGNORE_INACTIVE_MEMBER] xspc
           WHERE xspc.CLUSTER_MEMBER_ID = datafile.CLUSTER_MEMBER_ID
             AND xspc.ID                = datafile.TABLESPACE_ID )            -- TBS_NAME
     , CAST( datafile.PATH AS VARCHAR(1024 OCTETS) )      -- DATAFILE_NAME
     , CAST( datafile.CHECKPOINT_LSN AS NUMBER )          -- CHECKPOINT_LSN
     , datafile.CREATION_TIME                             -- CREATION_TIME
     , CAST( datafile.SIZE AS NUMBER )                    -- FILE_SIZE
     , CAST( datafile.LOADED_CHECKPOINT_LSN AS NUMBER )   -- LOADED_CHECKPOINT_LSN
     , CAST( datafile.CORRUPT_PAGE_COUNT AS NUMBER )      -- CORRUPT_PAGE_COUNT
  FROM 
       FIXED_TABLE_SCHEMA.X$DATAFILE@GLOBAL[IGNORE_INACTIVE_MEMBER] AS datafile
  WHERE datafile.STATE = 'CREATED'
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$DATAFILE
(  
       TBS_NAME
     , DATAFILE_NAME
     , CHECKPOINT_LSN
     , CREATION_TIME
     , FILE_SIZE
     , LOADED_CHECKPOINT_LSN
     , CORRUPT_PAGE_COUNT
)
AS 
SELECT 
       TBS_NAME
     , DATAFILE_NAME
     , CHECKPOINT_LSN
     , CREATION_TIME
     , FILE_SIZE
     , LOADED_CHECKPOINT_LSN
     , CORRUPT_PAGE_COUNT
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$DATAFILE@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$DATAFILE
        IS 'The V$DATAFILE displays information of all datafiles.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DATAFILE.TBS_NAME
        IS 'tablepsace name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DATAFILE.DATAFILE_NAME
        IS 'datafile name ( absolute path )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DATAFILE.CHECKPOINT_LSN
        IS 'LSN at last checkpoint ( null if temporary tablespace )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DATAFILE.CREATION_TIME
        IS 'timestamp of the datafile creation';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DATAFILE.FILE_SIZE
        IS 'datafile size ( in bytes )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DATAFILE.LOADED_CHECKPOINT_LSN
        IS 'checkpoint LSN of the datafile loaded in memory ( null if temporary tablespace )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DATAFILE.CORRUPT_PAGE_COUNT
        IS 'number of corrupt pages in the datafile';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$DATAFILE TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$DATAFILE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$DATAFILE;
CREATE PUBLIC SYNONYM GV$DATAFILE FOR PERFORMANCE_VIEW_SCHEMA.GV$DATAFILE;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$DATAFILE;
CREATE PUBLIC SYNONYM V$DATAFILE FOR PERFORMANCE_VIEW_SCHEMA.V$DATAFILE;
COMMIT;

--##############################################################
--# V$ERROR_CODE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$ERROR_CODE;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$ERROR_CODE;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$ERROR_CODE 
(  
       ERROR_CODE
     , SQL_STATE
     , ERROR_MESSAGE
)
AS 
SELECT 
       CAST( xerr.ERROR_CODE AS NUMBER )             -- ERROR_CODE
     , CAST( xerr.SQL_STATE AS VARCHAR(32 OCTETS) )  -- SQL_STATE
     , CAST( xerr.MESSAGE AS VARCHAR(1024 OCTETS) )  -- ERROR_MESSAGE
  FROM 
       FIXED_TABLE_SCHEMA.X$ERROR_CODE@GLOBAL[RANDOM_MEMBER] AS xerr
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$ERROR_CODE 
(  
       ERROR_CODE
     , SQL_STATE
     , ERROR_MESSAGE
)
AS 
SELECT 
       ERROR_CODE
     , SQL_STATE
     , ERROR_MESSAGE
  FROM PERFORMANCE_VIEW_SCHEMA.GV$ERROR_CODE@LOCAL
;
             
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$ERROR_CODE 
        IS 'The V$ERROR_CODE displays a list of all DB error codes';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$ERROR_CODE.ERROR_CODE
        IS 'DB internal error code';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$ERROR_CODE.SQL_STATE
        IS 'standard SQLSTATE code';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$ERROR_CODE.ERROR_MESSAGE
        IS 'error message';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$ERROR_CODE TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$ERROR_CODE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$ERROR_CODE;
CREATE PUBLIC SYNONYM GV$ERROR_CODE FOR PERFORMANCE_VIEW_SCHEMA.GV$ERROR_CODE;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$ERROR_CODE;
CREATE PUBLIC SYNONYM V$ERROR_CODE FOR PERFORMANCE_VIEW_SCHEMA.V$ERROR_CODE;
COMMIT;

--##############################################################
--# V$XA_TRANSACTION
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$XA_TRANSACTION;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$XA_TRANSACTION;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$XA_TRANSACTION
(  
       ORIGIN_MEMBER_NAME
     , XA_TRANS_ID
     , LOCAL_TRANS_ID
     , XA_TRANS_STATE
     , ASSO_STATE
     , START_TIME
     , IS_REPREPARABLE
)
AS 
SELECT 
       gltrans.CLUSTER_MEMBER_NAME
     , CAST( gltrans.XA_TRANS_ID AS VARCHAR(1024 OCTETS) )         -- XA_TRANS_ID
     , CAST( gltrans.LOCAL_TRANS_ID AS NUMBER )                    -- LOCAL_TRANS_ID
     , CAST( gltrans.STATE AS VARCHAR(32 OCTETS) )                 -- XA_TRANS_STATE
     , CAST( gltrans.ASSO_STATE AS VARCHAR(32 OCTETS) )            -- ASSO_STATE
     , gltrans.START_TIME                                          -- START_TIME
     , gltrans.REPREPARABLE                                        -- IS_REPREPARABLE
  FROM 
       FIXED_TABLE_SCHEMA.X$XA_TRANSACTION@GLOBAL[IGNORE_INACTIVE_MEMBER] AS gltrans   
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$XA_TRANSACTION
(  
       XA_TRANS_ID
     , LOCAL_TRANS_ID
     , XA_TRANS_STATE
     , ASSO_STATE
     , START_TIME
     , IS_REPREPARABLE
)
AS 
SELECT 
       XA_TRANS_ID
     , LOCAL_TRANS_ID
     , XA_TRANS_STATE
     , ASSO_STATE
     , START_TIME
     , IS_REPREPARABLE
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$XA_TRANSACTION@LOCAL
; 
                    
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$XA_TRANSACTION
        IS 'The V$XA_TRANSACTION displays information on the currently active XA transactions.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$XA_TRANSACTION.XA_TRANS_ID
        IS 'XA transaction identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$XA_TRANSACTION.LOCAL_TRANS_ID
        IS 'local transaction identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$XA_TRANSACTION.XA_TRANS_STATE
        IS 'state of the XA transaction: the value in ( NOTR, ACTIVE, IDLE, PREPARED, ROLLBACK_ONLY, HEURISTIC_COMPLETED )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$XA_TRANSACTION.ASSO_STATE
        IS 'associate state of the XA transaction: the value in ( NOT_ASSOCIATED, ASSOCIATED, ASSOCIATION_SUSPENDED )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$XA_TRANSACTION.START_TIME
        IS 'XA transaction start time';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$XA_TRANSACTION.IS_REPREPARABLE
        IS 'indicates whether the XA transaction is repreparable';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$XA_TRANSACTION TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$XA_TRANSACTION TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$XA_TRANSACTION;
CREATE PUBLIC SYNONYM GV$XA_TRANSACTION FOR PERFORMANCE_VIEW_SCHEMA.GV$XA_TRANSACTION;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$XA_TRANSACTION;
CREATE PUBLIC SYNONYM V$XA_TRANSACTION FOR PERFORMANCE_VIEW_SCHEMA.V$XA_TRANSACTION;
COMMIT;

--##############################################################
--# V$INCREMENTAL_BACKUP
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$INCREMENTAL_BACKUP;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$INCREMENTAL_BACKUP;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$INCREMENTAL_BACKUP
(  
       ORIGIN_MEMBER_NAME
     , BACKUP_NAME
     , BACKUP_SCOPE
     , INCREMENTAL_LEVEL
     , INCREMENTAL_TYPE
     , LSN
     , BEGIN_TIME
     , COMPLETION_TIME
)
AS 
SELECT 
       backup.CLUSTER_MEMBER_NAME
     , CAST( backup.BACKUP_FILE AS VARCHAR(1024 OCTETS) )     -- BACKUP_NAME
     , CAST( backup.BACKUP_OBJECT AS VARCHAR(128 OCTETS) )    -- BACKUP_SCOPE
     , CAST( backup.BACKUP_LEVEL AS NUMBER )                  -- INCREMENTAL_LEVEL
     , CAST( backup.BACKUP_OPTION AS VARCHAR(32 OCTETS) )     -- INCREMENTAL_TYPE
     , CAST( backup.BACKUP_LSN AS NUMBER )                    -- LSN
     , BEGIN_TIME                                             -- BEGIN_TIME
     , COMPLETION_TIME                                        -- COMPLETION_TIME
  FROM 
       FIXED_TABLE_SCHEMA.X$CONTROLFILE_BACKUP_SECTION@GLOBAL[IGNORE_INACTIVE_MEMBER] AS backup
       LEFT OUTER JOIN
       FIXED_TABLE_SCHEMA.X$CONTROLFILE@GLOBAL[IGNORE_INACTIVE_MEMBER] AS ctrlfile
       ON  backup.CONTROLFILE_NAME = ctrlfile.CONTROLFILE_NAME
       AND backup.CLUSTER_MEMBER_ID = ctrlfile.CLUSTER_MEMBER_ID
 WHERE ctrlfile.IS_PRIMARY = TRUE
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$INCREMENTAL_BACKUP
(  
       BACKUP_NAME
     , BACKUP_SCOPE
     , INCREMENTAL_LEVEL
     , INCREMENTAL_TYPE
     , LSN
     , BEGIN_TIME
     , COMPLETION_TIME
)
AS 
SELECT 
       BACKUP_NAME
     , BACKUP_SCOPE
     , INCREMENTAL_LEVEL
     , INCREMENTAL_TYPE
     , LSN
     , BEGIN_TIME
     , COMPLETION_TIME
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$INCREMENTAL_BACKUP@LOCAL
;
      
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$INCREMENTAL_BACKUP
        IS 'The V$INCREMENTAL_BACKUP displays information about control files and datafiles in backup sets from the control file.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$INCREMENTAL_BACKUP.BACKUP_NAME
        IS 'backup file name ( absolute path )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$INCREMENTAL_BACKUP.BACKUP_SCOPE
        IS 'incremental backup scope: the value in ( database, tablespace, control )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$INCREMENTAL_BACKUP.INCREMENTAL_LEVEL
        IS 'incremental backup level: the value in ( 0, 1, 2, 3, 4 )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$INCREMENTAL_BACKUP.INCREMENTAL_TYPE
        IS 'incremental backup type: the value in ( DIFFERENTIAL, CUMULATIVE )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$INCREMENTAL_BACKUP.LSN
        IS 'all changes up to checkpoint LSN are included in this backup';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$INCREMENTAL_BACKUP.BEGIN_TIME
        IS 'backup beginning time';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$INCREMENTAL_BACKUP.COMPLETION_TIME
        IS 'backup completion time';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$INCREMENTAL_BACKUP TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$INCREMENTAL_BACKUP TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$INCREMENTAL_BACKUP;
CREATE PUBLIC SYNONYM GV$INCREMENTAL_BACKUP FOR PERFORMANCE_VIEW_SCHEMA.GV$INCREMENTAL_BACKUP;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$INCREMENTAL_BACKUP;
CREATE PUBLIC SYNONYM V$INCREMENTAL_BACKUP FOR PERFORMANCE_VIEW_SCHEMA.V$INCREMENTAL_BACKUP;
COMMIT;

--##############################################################
--# V$KEYWORDS
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$KEYWORDS;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$KEYWORDS;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$KEYWORDS 
(  
       KEYWORD_NAME
     , KEYWORD_LENGTH
     , IS_RESERVED
)
AS 
SELECT 
       CAST( key.NAME AS VARCHAR(128 OCTETS) )   -- KEYWORD_NAME
     , CAST( LENGTH(key.NAME) AS NUMBER )        -- KEYWORD_LENGTH
     , CASE key.CATEGORY 
            WHEN 0 THEN TRUE
                   ELSE FALSE
       END                                       -- IS_RESERVED
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_KEYWORDS@GLOBAL[RANDOM_MEMBER] key
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$KEYWORDS 
(  
       KEYWORD_NAME
     , KEYWORD_LENGTH
     , IS_RESERVED
)
AS 
SELECT 
       KEYWORD_NAME
     , KEYWORD_LENGTH
     , IS_RESERVED
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$KEYWORDS@LOCAL
;
      
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$KEYWORDS 
        IS 'The V$KEYWORDS displays a list of all SQL keywords';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$KEYWORDS.KEYWORD_NAME
        IS 'name of keyword';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$KEYWORDS.KEYWORD_LENGTH
        IS 'length of the keyword';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$KEYWORDS.IS_RESERVED
        IS 'indicates whether the keyword cannot be used as an identifier (TRUE) or whether the keyword is not reserved (FALSE)';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$KEYWORDS TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$KEYWORDS TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$KEYWORDS;
CREATE PUBLIC SYNONYM GV$KEYWORDS FOR PERFORMANCE_VIEW_SCHEMA.GV$KEYWORDS;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$KEYWORDS;
CREATE PUBLIC SYNONYM V$KEYWORDS FOR PERFORMANCE_VIEW_SCHEMA.V$KEYWORDS;
COMMIT;

--##############################################################
--# V$LATCH
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$LATCH;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$LATCH;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$LATCH
(  
       ORIGIN_MEMBER_NAME
     , LATCH_DESCRIPTION
     , REF_COUNT
     , SPIN_LOCK
     , WAIT_COUNT
     , CURRENT_MODE
)
AS 
SELECT
       latch.CLUSTER_MEMBER_NAME
     , CAST( latch.DESCRIPTION AS VARCHAR(64 OCTETS) )     -- LATCH_DESCRIPTION
     , CAST( latch.REF_COUNT AS NUMBER )                   -- REF_COUNT
     , CAST( CASE WHEN latch.SPIN_LOCK = 1
                       THEN 'YES'
                       ELSE 'NO'
                       END AS VARCHAR(3 OCTETS) )          -- SPIN_LOCK
     , CAST( latch.WAIT_COUNT AS NUMBER )                  -- WAIT_COUNT
     , CAST( latch.CURRENT_MODE AS VARCHAR(32 OCTETS) )    -- CURRENT_MODE
  FROM 
       FIXED_TABLE_SCHEMA.X$LATCH@GLOBAL[IGNORE_INACTIVE_MEMBER] AS latch
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$LATCH
(  
       LATCH_DESCRIPTION
     , REF_COUNT
     , SPIN_LOCK
     , WAIT_COUNT
     , CURRENT_MODE
)
AS 
SELECT 
       LATCH_DESCRIPTION
     , REF_COUNT
     , SPIN_LOCK
     , WAIT_COUNT
     , CURRENT_MODE
  FROM              
       PERFORMANCE_VIEW_SCHEMA.GV$LATCH@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$LATCH
        IS 'The V$LATCH shows latch information.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$LATCH.LATCH_DESCRIPTION
        IS 'latch description';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$LATCH.REF_COUNT
        IS 'reference count';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$LATCH.SPIN_LOCK
        IS 'indicates whether the spin lock is locked ( YES ) or not ( NO )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$LATCH.WAIT_COUNT
        IS 'wait count';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$LATCH.CURRENT_MODE
        IS 'current latch mode: the value in ( INITIAL, SHARED, EXCLUSIVE )';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$LATCH TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$LATCH TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$LATCH;
CREATE PUBLIC SYNONYM GV$LATCH FOR PERFORMANCE_VIEW_SCHEMA.GV$LATCH;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$LATCH;
CREATE PUBLIC SYNONYM V$LATCH FOR PERFORMANCE_VIEW_SCHEMA.V$LATCH;
COMMIT;

--##############################################################
--# V$LOGFILE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$LOGFILE;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$LOGFILE;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$LOGFILE
(  
       ORIGIN_MEMBER_NAME
     , GROUP_ID
     , FILE_NAME
     , GROUP_STATE
     , FILE_SEQ
     , FILE_SIZE
)
AS 
SELECT
       loggrp.CLUSTER_MEMBER_NAME
     , CAST( loggrp.GROUP_ID AS NUMBER )              -- GROUP_ID
     , CAST( logmem.NAME AS VARCHAR(1024 OCTETS) )    -- FILE_NAME
     , CAST( loggrp.STATE AS VARCHAR(32 OCTETS) )     -- GROUP_STATE
     , CAST( loggrp.FILE_SEQ_NO AS NUMBER )           -- FILE_SEQ
     , CAST( loggrp.FILE_SIZE AS NUMBER )             -- FILE_SIZE
  FROM 
       FIXED_TABLE_SCHEMA.X$LOG_GROUP@GLOBAL[IGNORE_INACTIVE_MEMBER] AS loggrp
       LEFT OUTER JOIN   
       FIXED_TABLE_SCHEMA.X$LOG_MEMBER@GLOBAL[IGNORE_INACTIVE_MEMBER] AS logmem
       ON  loggrp.GROUP_ID = logmem.GROUP_ID
       AND loggrp.CLUSTER_MEMBER_ID = logmem.CLUSTER_MEMBER_ID
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$LOGFILE
(  
       GROUP_ID
     , FILE_NAME
     , GROUP_STATE
     , FILE_SEQ
     , FILE_SIZE
)
AS 
SELECT 
       GROUP_ID
     , FILE_NAME
     , GROUP_STATE
     , FILE_SEQ
     , FILE_SIZE
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$LOGFILE@LOCAL
;
      
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$LOGFILE
        IS 'The V$LOGFILE displays information of all redo log members.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$LOGFILE.GROUP_ID
        IS 'redo log group identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$LOGFILE.FILE_NAME
        IS 'name of the log member';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$LOGFILE.GROUP_STATE
        IS 'state of the log group: the value in ( UNUSED, ACTIVE, CURRENT, INACTIVE )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$LOGFILE.FILE_SEQ
        IS 'file sequence number of the log member';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$LOGFILE.FILE_SIZE
        IS 'file size of the log member ( in bytes )';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$LOGFILE TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$LOGFILE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$LOGFILE;
CREATE PUBLIC SYNONYM GV$LOGFILE FOR PERFORMANCE_VIEW_SCHEMA.GV$LOGFILE;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$LOGFILE;
CREATE PUBLIC SYNONYM V$LOGFILE FOR PERFORMANCE_VIEW_SCHEMA.V$LOGFILE;
COMMIT;

--##############################################################
--# V$LOCK_WAIT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$LOCK_WAIT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$LOCK_WAIT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$LOCK_WAIT
(  
       ORIGIN_MEMBER_NAME
     , GRANT_TRANS_ID
     , REQUEST_TRANS_ID
)
AS 
SELECT 
       lckwait.CLUSTER_MEMBER_NAME
     , ( SELECT CAST( LOGICAL_TRANS_ID AS NUMBER )
           FROM FIXED_TABLE_SCHEMA.X$TRANSACTION@GLOBAL[IGNORE_INACTIVE_MEMBER] xtrans
          WHERE xtrans.SLOT_ID = lckwait.GRANTED_TRANSACTION_SLOT_ID 
            AND xtrans.CLUSTER_MEMBER_ID = lckwait.CLUSTER_MEMBER_ID
       )   -- GRANT_TRANS_ID
     , ( SELECT CAST( LOGICAL_TRANS_ID AS NUMBER )
           FROM FIXED_TABLE_SCHEMA.X$TRANSACTION@GLOBAL[IGNORE_INACTIVE_MEMBER] xtrans
          WHERE xtrans.SLOT_ID = lckwait.REQUEST_TRANSACTION_SLOT_ID 
            AND xtrans.CLUSTER_MEMBER_ID = lckwait.CLUSTER_MEMBER_ID
       )   -- REQUEST_TRANS_ID
  FROM 
       FIXED_TABLE_SCHEMA.X$LOCK_WAIT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS lckwait
  WHERE lckwait.EDGE_TYPE = 1
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$LOCK_WAIT
(  
       GRANT_TRANS_ID
     , REQUEST_TRANS_ID
)
AS 
SELECT 
       GRANT_TRANS_ID
     , REQUEST_TRANS_ID
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$LOCK_WAIT@LOCAL
;
             
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$LOCK_WAIT
        IS 'This view lists the locks currently held and outstanding requests for a lock.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$LOCK_WAIT.GRANT_TRANS_ID
        IS 'transaction identifier that holds the lock';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$LOCK_WAIT.REQUEST_TRANS_ID
        IS 'transaction identifier that requests the lock';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$LOCK_WAIT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$LOCK_WAIT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$LOCK_WAIT;
CREATE PUBLIC SYNONYM GV$LOCK_WAIT FOR PERFORMANCE_VIEW_SCHEMA.GV$LOCK_WAIT;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$LOCK_WAIT;
CREATE PUBLIC SYNONYM V$LOCK_WAIT FOR PERFORMANCE_VIEW_SCHEMA.V$LOCK_WAIT;
COMMIT;

--##############################################################
--# V$PROPERTY
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$PROPERTY;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$PROPERTY;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$PROPERTY 
( 
       ORIGIN_MEMBER_NAME
     , PROPERTY_NAME
     , DESCRIPTION
     , DATA_TYPE
     , STARTUP_PHASE
     , VALUE_UNIT
     , PROPERTY_VALUE
     , PROPERTY_SOURCE
     , INIT_VALUE
     , INIT_SOURCE
     , MIN_VALUE
     , MAX_VALUE
     , SES_MODIFIABLE
     , SYS_MODIFIABLE
     , IS_MODIFIABLE
     , IS_DEPRECATED
     , IS_GLOBAL
)
AS 
SELECT 
       CLUSTER_MEMBER_NAME
     , CAST( PROPERTY_NAME AS VARCHAR(128 OCTETS) )  -- PROPERTY_NAME
     , CAST( DESCRIPTION AS VARCHAR(2048 OCTETS) )   -- DESCRIPTION
     , CAST( DATA_TYPE AS VARCHAR(32 OCTETS) )       -- DATA_TYPE
     , CAST( STARTUP_PHASE AS VARCHAR(32 OCTETS) )   -- STARTUP_PHASE
     , CAST( UNIT AS VARCHAR(32 OCTETS) )            -- VALUE_UNIT
     , CAST( VALUE AS VARCHAR(2048 OCTETS) )         -- PROPERTY_VALUE
     , CAST( SOURCE AS VARCHAR(32 OCTETS) )          -- PROPERTY_SOURCE
     , CAST( INIT_VALUE AS VARCHAR(2048 OCTETS) )    -- INIT_VALUE
     , CAST( INIT_SOURCE AS VARCHAR(32 OCTETS) )     -- INIT_SOURCE
     , CAST( CASE WHEN DATA_TYPE = 'VARCHAR' THEN NULL
                                             ELSE MIN 
             END
             AS NUMBER )                             -- MIN_VALUE
     , CAST( CASE WHEN DATA_TYPE = 'VARCHAR' THEN NULL
                                             ELSE MAX 
             END
             AS NUMBER )                             -- MAX_VALUE
     , CAST( SES_MODIFIABLE AS VARCHAR(32 OCTETS) )  -- SES_MODIFIABLE
     , CAST( SYS_MODIFIABLE AS VARCHAR(32 OCTETS) )  -- SYS_MODIFIABLE
     , CAST( MODIFIABLE AS VARCHAR(32 OCTETS) )      -- IS_MODIFIABLE
     , CAST( CASE WHEN DOMAIN = 'DEPRECATED' THEN 'TRUE'
                                             ELSE 'FALSE'
             END
             AS VARCHAR(32 OCTETS) )                 -- IS_DEPRECATED
     , CAST( CASE WHEN CLUSTER_SCOPE = 'GLOBAL' THEN 'TRUE'
                                                ELSE 'FALSE' 
             END
             AS VARCHAR(32 OCTETS) )                 -- IS_GLOBAL
  FROM 
       FIXED_TABLE_SCHEMA.X$PROPERTY@GLOBAL[IGNORE_INACTIVE_MEMBER]
 WHERE 
       DOMAIN = 'EXTERNAL' OR DOMAIN = 'DEPRECATED'
 ORDER BY
       1, 
       PROPERTY_ID
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$PROPERTY 
( 
       PROPERTY_NAME
     , DESCRIPTION
     , DATA_TYPE
     , STARTUP_PHASE
     , VALUE_UNIT
     , PROPERTY_VALUE
     , PROPERTY_SOURCE
     , INIT_VALUE
     , INIT_SOURCE
     , MIN_VALUE
     , MAX_VALUE
     , SES_MODIFIABLE
     , SYS_MODIFIABLE
     , IS_MODIFIABLE
     , IS_DEPRECATED
     , IS_GLOBAL
)
AS 
SELECT 
       PROPERTY_NAME
     , DESCRIPTION
     , DATA_TYPE
     , STARTUP_PHASE
     , VALUE_UNIT
     , PROPERTY_VALUE
     , PROPERTY_SOURCE
     , INIT_VALUE
     , INIT_SOURCE
     , MIN_VALUE
     , MAX_VALUE
     , SES_MODIFIABLE
     , SYS_MODIFIABLE
     , IS_MODIFIABLE
     , IS_DEPRECATED
     , IS_GLOBAL
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$PROPERTY@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$PROPERTY  
        IS 'The V$PROPERTY displays a list of all Properties at current session. otherwise, the instance-wide value';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROPERTY.PROPERTY_NAME
        IS 'name of the property';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROPERTY.DESCRIPTION
        IS 'description of the property';        
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROPERTY.DATA_TYPE
        IS 'data type of the property';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROPERTY.STARTUP_PHASE
        IS 'modifiable startup-phase: the value IN ( NO MOUNT / MOUNT / OPEN & [BELOW|ABOVE] )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROPERTY.VALUE_UNIT
        IS 'unit of the property value: the value in ( NONE, BYTE, MS(milisec) )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROPERTY.PROPERTY_VALUE
        IS 'property value for the session. otherwise, the instance-wide value';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROPERTY.PROPERTY_SOURCE
        IS 'source of the current property value: the value IN ( USER, DEFAULT, ENV_VAR, BINARY_FILE, FILE, SYSTEM )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROPERTY.INIT_VALUE
        IS 'property init value for the session';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROPERTY.INIT_SOURCE
        IS 'source of the current property INIT_VALUE: the value IN ( USER, DEFAULT, ENV_VAR, BINARY_FILE, FILE, SYSTEM )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROPERTY.MIN_VALUE
        IS 'minimum value for property. null if type is varchar.';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROPERTY.MAX_VALUE
        IS 'maximum value for property. null if type is varchar.';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROPERTY.SES_MODIFIABLE
        IS 'property can be changed with ALTER SESSION or not: the value in ( TRUE, FALSE )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROPERTY.SYS_MODIFIABLE
        IS 'property can be changed with ALTER SYSTEM and when the change takes effect: the value in ( NONE, FALSE, IMMEDIATE, DEFERRED )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROPERTY.IS_MODIFIABLE
        IS 'property can be changed or not: the value in ( TRUE, FALSE )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROPERTY.IS_DEPRECATED
        IS 'property is deprecated: the value in ( TRUE, FALSE )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROPERTY.IS_GLOBAL
        IS 'property scope is global or not: the value in ( TRUE, FALSE )';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$PROPERTY TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$PROPERTY TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$PROPERTY;
CREATE PUBLIC SYNONYM GV$PROPERTY FOR PERFORMANCE_VIEW_SCHEMA.GV$PROPERTY;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$PROPERTY;
CREATE PUBLIC SYNONYM V$PROPERTY FOR PERFORMANCE_VIEW_SCHEMA.V$PROPERTY;
COMMIT;

--##############################################################
--# V$PROCESS_STAT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$PROCESS_STAT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$PROCESS_STAT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$PROCESS_STAT
(  
       ORIGIN_MEMBER_NAME
     , STAT_NAME
     , PROC_ID
     , STAT_VALUE
)
AS 
SELECT 
       knstat.CLUSTER_MEMBER_NAME
     , CAST( knstat.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( knstat.ID AS NUMBER )                      -- PROC_ID
     , CAST( knstat.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$KN_PROC_STAT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS knstat   
  WHERE knstat.CATEGORY = 0
UNION ALL
SELECT 
       smenv.CLUSTER_MEMBER_NAME
     , CAST( smenv.NAME AS VARCHAR(128 OCTETS) )        -- STAT_NAME
     , CAST( smenv.ID AS NUMBER )                       -- PROC_ID
     , CAST( smenv.VALUE AS NUMBER )                    -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SM_PROC_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS smenv   
  WHERE smenv.CATEGORY = 0
UNION ALL
SELECT 
       exeenv.CLUSTER_MEMBER_NAME
     , CAST( exeenv.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( exeenv.ID AS NUMBER )                      -- PROC_ID
     , CAST( exeenv.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$EXE_PROC_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS exeenv   
  WHERE exeenv.CATEGORY = 0
UNION ALL
SELECT 
       clenv.CLUSTER_MEMBER_NAME
     , CAST( clenv.NAME AS VARCHAR(128 OCTETS) )        -- STAT_NAME
     , CAST( clenv.ID AS NUMBER )                       -- PROC_ID
     , CAST( clenv.VALUE AS NUMBER )                    -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$CL_PROC_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS clenv   
  WHERE clenv.CATEGORY = 0
UNION ALL
SELECT 
       sqlenv.CLUSTER_MEMBER_NAME
     , CAST( sqlenv.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( sqlenv.ID AS NUMBER )                      -- PROC_ID
     , CAST( sqlenv.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_PROC_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sqlenv   
  WHERE sqlenv.CATEGORY = 0
UNION ALL
SELECT 
       ssenv.CLUSTER_MEMBER_NAME
     , CAST( ssenv.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( ssenv.ID AS NUMBER )                      -- PROC_ID
     , CAST( ssenv.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SS_PROC_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS ssenv   
  WHERE ssenv.CATEGORY = 0
UNION ALL
SELECT 
       slenv.CLUSTER_MEMBER_NAME
     , CAST( slenv.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( slenv.ID AS NUMBER )                      -- PROC_ID
     , CAST( slenv.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SL_PROC_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS slenv   
  WHERE slenv.CATEGORY = 0
ORDER BY 1, 3, 2
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$PROCESS_STAT
(  
       STAT_NAME
     , PROC_ID
     , STAT_VALUE
)
AS 
SELECT 
       STAT_NAME
     , PROC_ID
     , STAT_VALUE
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$PROCESS_STAT@LOCAL
;
             
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$PROCESS_STAT
        IS 'The V$PROCESS_STAT displays process statistics.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROCESS_STAT.STAT_NAME
        IS 'statistic name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROCESS_STAT.PROC_ID
        IS 'process identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROCESS_STAT.STAT_VALUE
        IS 'statistic value';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$PROCESS_STAT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$PROCESS_STAT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$PROCESS_STAT;
CREATE PUBLIC SYNONYM GV$PROCESS_STAT FOR PERFORMANCE_VIEW_SCHEMA.GV$PROCESS_STAT;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$PROCESS_STAT;
CREATE PUBLIC SYNONYM V$PROCESS_STAT FOR PERFORMANCE_VIEW_SCHEMA.V$PROCESS_STAT;
COMMIT;

--##############################################################
--# V$PROCESS_MEM_STAT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$PROCESS_MEM_STAT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$PROCESS_MEM_STAT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$PROCESS_MEM_STAT
(  
       ORIGIN_MEMBER_NAME
     , STAT_NAME
     , PROC_ID
     , STAT_VALUE
)
AS 
SELECT
       knstat.CLUSTER_MEMBER_NAME
     , CAST( knstat.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( knstat.ID AS NUMBER )                      -- PROC_ID
     , CAST( knstat.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$KN_PROC_STAT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS knstat   
  WHERE knstat.CATEGORY = 11
UNION ALL
SELECT 
       scenv.CLUSTER_MEMBER_NAME
     , CAST( scenv.NAME AS VARCHAR(128 OCTETS) )        -- STAT_NAME
     , CAST( scenv.ID AS NUMBER )                       -- PROC_ID
     , CAST( scenv.VALUE AS NUMBER )                    -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SC_PROC_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS scenv   
  WHERE scenv.CATEGORY = 11
UNION ALL
SELECT 
       smenv.CLUSTER_MEMBER_NAME
     , CAST( smenv.NAME AS VARCHAR(128 OCTETS) )        -- STAT_NAME
     , CAST( smenv.ID AS NUMBER )                       -- PROC_ID
     , CAST( smenv.VALUE AS NUMBER )                    -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SM_PROC_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS smenv   
  WHERE smenv.CATEGORY = 11
UNION ALL
SELECT 
       exeenv.CLUSTER_MEMBER_NAME
     , CAST( exeenv.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( exeenv.ID AS NUMBER )                      -- PROC_ID
     , CAST( exeenv.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$EXE_PROC_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS exeenv   
  WHERE exeenv.CATEGORY = 11
UNION ALL
SELECT 
       clenv.CLUSTER_MEMBER_NAME
     , CAST( clenv.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( clenv.ID AS NUMBER )                      -- PROC_ID
     , CAST( clenv.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$CL_PROC_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS clenv   
  WHERE clenv.CATEGORY = 11
UNION ALL
SELECT 
       sqlenv.CLUSTER_MEMBER_NAME
     , CAST( sqlenv.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( sqlenv.ID AS NUMBER )                      -- PROC_ID
     , CAST( sqlenv.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_PROC_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sqlenv   
  WHERE sqlenv.CATEGORY = 11
UNION ALL
SELECT 
       ssenv.CLUSTER_MEMBER_NAME
     , CAST( ssenv.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( ssenv.ID AS NUMBER )                      -- PROC_ID
     , CAST( ssenv.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SS_PROC_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS ssenv   
  WHERE ssenv.CATEGORY = 11
UNION ALL
SELECT 
       slenv.CLUSTER_MEMBER_NAME
     , CAST( slenv.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( slenv.ID AS NUMBER )                      -- PROC_ID
     , CAST( slenv.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SL_PROC_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS slenv   
  WHERE slenv.CATEGORY = 11
ORDER BY 1, 3, 2
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$PROCESS_MEM_STAT
(  
       STAT_NAME
     , PROC_ID
     , STAT_VALUE
)
AS 
SELECT
       STAT_NAME
     , PROC_ID
     , STAT_VALUE
  FROM             
       PERFORMANCE_VIEW_SCHEMA.GV$PROCESS_MEM_STAT@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$PROCESS_MEM_STAT
        IS 'The V$PROCESS_MEM_STAT displays process memory statistics.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROCESS_MEM_STAT.STAT_NAME
        IS 'statistic name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROCESS_MEM_STAT.PROC_ID
        IS 'process identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROCESS_MEM_STAT.STAT_VALUE
        IS 'statistic value';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$PROCESS_MEM_STAT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$PROCESS_MEM_STAT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$PROCESS_MEM_STAT;
CREATE PUBLIC SYNONYM GV$PROCESS_MEM_STAT FOR PERFORMANCE_VIEW_SCHEMA.GV$PROCESS_MEM_STAT;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$PROCESS_MEM_STAT;
CREATE PUBLIC SYNONYM V$PROCESS_MEM_STAT FOR PERFORMANCE_VIEW_SCHEMA.V$PROCESS_MEM_STAT;
COMMIT;

--##############################################################
--# V$PROCESS_SQL_STAT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$PROCESS_SQL_STAT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$PROCESS_SQL_STAT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$PROCESS_SQL_STAT
(  
       ORIGIN_MEMBER_NAME
     , STAT_NAME
     , PROC_ID
     , STAT_VALUE
)
AS 
SELECT 
       sqlprocenv.CLUSTER_MEMBER_NAME
     , CAST( sqlprocenv.NAME AS VARCHAR(128 OCTETS) )                        -- STAT_NAME
     , CAST( sqlprocenv.ID AS NUMBER )                                       -- PROC_ID
     , CAST( sqlprocenv.VALUE AS NUMBER )                                    -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_PROC_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sqlprocenv
  WHERE sqlprocenv.CATEGORY = 20
UNION ALL
SELECT 
       sqlprocexec.CLUSTER_MEMBER_NAME
     , CAST( 'COMMAND: ' || sqlprocexec.STMT_TYPE AS VARCHAR(128 OCTETS) )   -- STAT_NAME
     , CAST( sqlprocexec.ID AS NUMBER )                                      -- PROC_ID
     , CAST( sqlprocexec.EXECUTE_COUNT AS NUMBER )                           -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_PROC_STAT_EXEC_STMT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sqlprocexec
 WHERE sqlprocexec.STATE = 'USED'
ORDER BY 1, 3, 2
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$PROCESS_SQL_STAT
(  
       STAT_NAME
     , PROC_ID
     , STAT_VALUE
)
AS 
SELECT 
       STAT_NAME
     , PROC_ID
     , STAT_VALUE
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$PROCESS_SQL_STAT@LOCAL
;
      
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$PROCESS_SQL_STAT
        IS 'The V$PROCESS_SQL_STAT displays process SQL statistics.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROCESS_SQL_STAT.STAT_NAME
        IS 'statistic name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROCESS_SQL_STAT.PROC_ID
        IS 'process identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PROCESS_SQL_STAT.STAT_VALUE
        IS 'statistic value';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$PROCESS_SQL_STAT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$PROCESS_SQL_STAT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$PROCESS_SQL_STAT;
CREATE PUBLIC SYNONYM GV$PROCESS_SQL_STAT FOR PERFORMANCE_VIEW_SCHEMA.GV$PROCESS_SQL_STAT;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$PROCESS_SQL_STAT;
CREATE PUBLIC SYNONYM V$PROCESS_SQL_STAT FOR PERFORMANCE_VIEW_SCHEMA.V$PROCESS_SQL_STAT;
COMMIT;

--##############################################################
--# V$PSM_RESERVED_WORDS
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$PSM_RESERVED_WORDS;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$PSM_RESERVED_WORDS;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$PSM_RESERVED_WORDS 
(  
       KEYWORD_NAME
     , KEYWORD_LENGTH
)
AS 
SELECT
       CAST( key.NAME AS VARCHAR(128 OCTETS) )   -- KEYWORD_NAME
     , CAST( LENGTH(key.NAME) AS NUMBER )        -- KEYWORD_LENGTH
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_KEYWORDS@GLOBAL[RANDOM_MEMBER] key
 WHERE key.CATEGORY IN (0, 1, 2);
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$PSM_RESERVED_WORDS 
(  
       KEYWORD_NAME
     , KEYWORD_LENGTH
)
AS 
SELECT 
       KEYWORD_NAME
     , KEYWORD_LENGTH
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$PSM_RESERVED_WORDS@LOCAL
;
             
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$PSM_RESERVED_WORDS 
        IS 'The V$PSM_RESERVED_WORDS displays a list of all PSM reserved keywords.  Reserved words cannot be used in variable name or procedure name.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PSM_RESERVED_WORDS.KEYWORD_NAME
        IS 'name of keyword';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$PSM_RESERVED_WORDS.KEYWORD_LENGTH
        IS 'length of the keyword';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$PSM_RESERVED_WORDS TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$PSM_RESERVED_WORDS TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$PSM_RESERVED_WORDS;
CREATE PUBLIC SYNONYM GV$PSM_RESERVED_WORDS FOR PERFORMANCE_VIEW_SCHEMA.GV$PSM_RESERVED_WORDS;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$PSM_RESERVED_WORDS;
CREATE PUBLIC SYNONYM V$PSM_RESERVED_WORDS FOR PERFORMANCE_VIEW_SCHEMA.V$PSM_RESERVED_WORDS;
COMMIT;

--##############################################################
--# V$RESERVED_WORDS
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$RESERVED_WORDS;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$RESERVED_WORDS;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$RESERVED_WORDS 
(  
       KEYWORD_NAME
     , KEYWORD_LENGTH
)
AS 
SELECT
       CAST( key.NAME AS VARCHAR(128 OCTETS) )   -- KEYWORD_NAME
     , CAST( LENGTH(key.NAME) AS NUMBER )        -- KEYWORD_LENGTH
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_KEYWORDS@GLOBAL[RANDOM_MEMBER] key
 WHERE key.CATEGORY = 0;
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$RESERVED_WORDS 
(  
       KEYWORD_NAME
     , KEYWORD_LENGTH
)
AS 
SELECT 
       KEYWORD_NAME
     , KEYWORD_LENGTH
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$RESERVED_WORDS@LOCAL
;
             
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$RESERVED_WORDS 
        IS 'The V$RESERVED_WORDS displays a list of all SQL reserved keywords.  Reserved words cannot be used in table name or column name.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$RESERVED_WORDS.KEYWORD_NAME
        IS 'name of keyword';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$RESERVED_WORDS.KEYWORD_LENGTH
        IS 'length of the keyword';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$RESERVED_WORDS TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$RESERVED_WORDS TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$RESERVED_WORDS;
CREATE PUBLIC SYNONYM GV$RESERVED_WORDS FOR PERFORMANCE_VIEW_SCHEMA.GV$RESERVED_WORDS;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$RESERVED_WORDS;
CREATE PUBLIC SYNONYM V$RESERVED_WORDS FOR PERFORMANCE_VIEW_SCHEMA.V$RESERVED_WORDS;
COMMIT;

--##############################################################
--# V$SESSION
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SESSION;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SESSION;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SESSION
(  
       ORIGIN_MEMBER_NAME
     , SESSION_ID
     , SERIAL_NO
     , TRANS_ID
     , CONNECTION_TYPE
     , USER_NAME
     , SESSION_STATUS
     , SERVER_TYPE
     , OS_USER_NAME
     , PROCESS_ID
     , LOGON_TIME
     , TERMINAL
     , PROGRAM_NAME
     , CLIENT_ADDRESS
     , CLIENT_PORT
     , FAILOVER_TYPE
     , FAILED_OVER
     , IS_AUDITED
)
AS 
SELECT
       xsess.CLUSTER_MEMBER_NAME
     , CAST( xsess.ID AS NUMBER )                         -- SESSION_ID
     , CAST( xsess.SERIAL AS NUMBER )                     -- SERIAL_NO
     , CAST( xsess.TRANS_ID AS NUMBER )                   -- TRANS_ID
     , CAST( xsess.CONNECTION AS VARCHAR(32 OCTETS) )     -- CONNECTION_TYPE
     , auth.AUTHORIZATION_NAME                            -- USER_NAME
     , CAST( xsess.STATUS AS VARCHAR(32 OCTETS) )         -- SESSION_STATUS
     , CAST( xsess.SERVER AS VARCHAR(32 OCTETS) )         -- SERVER_TYPE
     , CAST( xsess.OSUSER AS VARCHAR(32 OCTETS) )         -- OS_USER_NAME
     , CAST( xsess.CLIENT_PROCESS AS NUMBER )             -- PROCESS_ID
     , xsess.LOGON_TIME                                   -- LOGON_TIME
     , CAST( xsess.TERMINAL AS VARCHAR(32 OCTETS) )       -- TERMINAL
     , CAST( xsess.PROGRAM AS VARCHAR(128 OCTETS) )       -- PROGRAM_NAME
     , CAST( xsess.ADDRESS AS VARCHAR(1024 OCTETS) )      -- CLIENT_ADDRESS
     , CAST( xsess.PORT AS NUMBER )                       -- CLIENT_PORT
     , CAST( xsess.FAILOVER_TYPE AS VARCHAR(13 OCTETS) )  -- FAILOVER_TYPE
     , CAST( xsess.FAILED_OVER AS VARCHAR(3 OCTETS) )     -- FAILED_OVER
     , CAST( CASE WHEN xsess.IS_AUDITED = TRUE
                  THEN 'YES'
                  ELSE 'NO'
              END AS VARCHAR(3 OCTETS) )                  -- IS_AUDITED
  FROM 
       FIXED_TABLE_SCHEMA.X$SESSION@GLOBAL[IGNORE_INACTIVE_MEMBER] AS xsess   
       LEFT OUTER JOIN   
       DEFINITION_SCHEMA.AUTHORIZATIONS@GLOBAL[IGNORE_INACTIVE_MEMBER] AS auth
       ON  xsess.USER_ID = auth.AUTH_ID
       AND xsess.CLUSTER_MEMBER_ID = auth.CLUSTER_MEMBER_ID 
 WHERE xsess.STATUS IN ( 'CONNECTED', 'SIGNALED', 'SNIPED', 'DEAD' ) 
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SESSION
(  
       SESSION_ID
     , SERIAL_NO
     , TRANS_ID
     , CONNECTION_TYPE
     , USER_NAME
     , SESSION_STATUS
     , SERVER_TYPE
     , OS_USER_NAME
     , PROCESS_ID
     , LOGON_TIME
     , TERMINAL
     , PROGRAM_NAME
     , CLIENT_ADDRESS
     , CLIENT_PORT
     , FAILOVER_TYPE
     , FAILED_OVER
     , IS_AUDITED
)
AS 
SELECT 
       SESSION_ID
     , SERIAL_NO
     , TRANS_ID
     , CONNECTION_TYPE
     , USER_NAME
     , SESSION_STATUS
     , SERVER_TYPE
     , OS_USER_NAME
     , PROCESS_ID
     , LOGON_TIME
     , TERMINAL
     , PROGRAM_NAME
     , CLIENT_ADDRESS
     , CLIENT_PORT
     , FAILOVER_TYPE
     , FAILED_OVER
     , IS_AUDITED
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$SESSION@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SESSION
        IS 'The V$SESSION displays session information for each current session.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.SESSION_ID
        IS 'session identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.SERIAL_NO
        IS 'session serial number';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.TRANS_ID
        IS 'transaction identifier ( -1 if inactive transaction )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.CONNECTION_TYPE
        IS 'connection type: the value in ( DA, TCP ) ';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.USER_NAME
        IS 'user name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.SESSION_STATUS
        IS 'status of the session: the value in ( CONNECTED, SIGNALED, SNIPED, DEAD )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.SERVER_TYPE
        IS 'server type: the value in ( DEDICATED, SHARED )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.OS_USER_NAME
        IS 'operating system client user name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.PROCESS_ID
        IS 'client process identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.LOGON_TIME
        IS 'logon time';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.TERMINAL
        IS 'operating system terminal name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.PROGRAM_NAME
        IS 'program name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.CLIENT_ADDRESS
        IS 'client address ( null if DA )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.CLIENT_PORT
        IS 'client port ( 0 if DA )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.FAILOVER_TYPE
        IS 'indicates whether and to what extent transparent application failover (TAF) is enabled for the session ( NONE, SESSION )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.FAILED_OVER
        IS 'indicates whether the session is running in failover mode and failover has occurred (YES) or not (NO)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION.IS_AUDITED
        IS 'indicates whether the session is audited (YES) or not (NO)';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SESSION TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SESSION TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SESSION;
CREATE PUBLIC SYNONYM GV$SESSION FOR PERFORMANCE_VIEW_SCHEMA.GV$SESSION;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SESSION;
CREATE PUBLIC SYNONYM V$SESSION FOR PERFORMANCE_VIEW_SCHEMA.V$SESSION;
COMMIT;

--##############################################################
--# V$SESSION_AUDIT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SESSION_AUDIT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SESSION_AUDIT;

COMMIT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SESSION_AUDIT
(  
       ORIGIN_MEMBER_NAME
     , SESSION_ID
     , SERIAL_NO
     , POLICY_NAME
     , WHEN_SUCCESS
     , WHEN_FAILURE
)
AS 
SELECT 
       xaud.CLUSTER_MEMBER_NAME
     , CAST( xaud.SESSION_ID AS NUMBER )           -- SESSION_ID
     , CAST( xaud.SESSION_SERIAL AS NUMBER )       -- SERIAL_NO
     , ( SELECT POLICY_NAME
           FROM DEFINITION_SCHEMA.AUDIT_POLICY@GLOBAL[IGNORE_INACTIVE_MEMBER] AS apo
          WHERE apo.POLICY_ID = xaud.POLICY_ID
            AND apo.CLUSTER_MEMBER_ID = xaud.CLUSTER_MEMBER_ID )   -- POLICY_NAME
     , CAST( CASE WHEN xaud.WHEN_SUCCESS = TRUE
                  THEN 'YES'
                  ELSE 'NO'
              END AS VARCHAR(3 OCTETS) )           -- WHEN_SUCCESS
     , CAST( CASE WHEN xaud.WHEN_FAILURE = TRUE
                  THEN 'YES'
                  ELSE 'NO'
              END AS VARCHAR(3 OCTETS) )           -- WHEN_FAILURE
  FROM
       X$SESSION_AUDIT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS xaud
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SESSION_AUDIT
(  
       SESSION_ID
     , SERIAL_NO
     , POLICY_NAME
     , WHEN_SUCCESS
     , WHEN_FAILURE
)
AS 
SELECT 
       SESSION_ID
     , SERIAL_NO
     , POLICY_NAME
     , WHEN_SUCCESS
     , WHEN_FAILURE
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$SESSION_AUDIT@LOCAL
;       

COMMIT;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SESSION_AUDIT
        IS 'The V$SESSION_AUDIT displays audited session information.';

COMMIT;

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_AUDIT.SESSION_ID
        IS 'session identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_AUDIT.SERIAL_NO
        IS 'session serial number';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_AUDIT.POLICY_NAME
        IS 'active audit policy name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_AUDIT.WHEN_SUCCESS
        IS 'indicates whether the audit policy is enable for auditing successful events or not';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_AUDIT.WHEN_FAILURE
        IS 'indicates whether the audit policy is enable for auditing unsuccessful events or not';

COMMIT;

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SESSION_AUDIT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SESSION_AUDIT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SESSION_AUDIT;
CREATE PUBLIC SYNONYM GV$SESSION_AUDIT FOR PERFORMANCE_VIEW_SCHEMA.GV$SESSION_AUDIT;

DROP PUBLIC SYNONYM IF EXISTS V$SESSION_AUDIT;
CREATE PUBLIC SYNONYM V$SESSION_AUDIT FOR PERFORMANCE_VIEW_SCHEMA.V$SESSION_AUDIT;

COMMIT;



--##############################################################
--# V$SESSION_CONNECT_INFO
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SESSION_CONNECT_INFO;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SESSION_CONNECT_INFO;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SESSION_CONNECT_INFO
(  
       ORIGIN_MEMBER_NAME
     , SESSION_ID
     , SERIAL_NO
     , OS_USER_NAME
     , CLIENT_CHARSET
     , CLIENT_VERSION
)
AS 
SELECT
       xsess.CLUSTER_MEMBER_NAME
     , CAST( xsess.ID AS NUMBER )                         -- SESSION_ID
     , CAST( xsess.SERIAL AS NUMBER )                     -- SERIAL_NO
     , CAST( xsess.OSUSER AS VARCHAR(32 OCTETS) )         -- OS_USER_NAME
     , CAST( xsess.CLIENT_CHARSET AS VARCHAR(40 OCTETS) ) -- CLIENT_CHARSET
     , CAST( xsess.VERSION AS VARCHAR(64 OCTETS) )        -- CLIENT_VERSION
  FROM 
       FIXED_TABLE_SCHEMA.X$SESSION@GLOBAL[IGNORE_INACTIVE_MEMBER] AS xsess   
       LEFT OUTER JOIN   
       DEFINITION_SCHEMA.AUTHORIZATIONS@GLOBAL[IGNORE_INACTIVE_MEMBER] AS auth
       ON  xsess.USER_ID = auth.AUTH_ID
       AND xsess.CLUSTER_MEMBER_ID = auth.CLUSTER_MEMBER_ID 
 WHERE
       xsess.STATUS IN ( 'CONNECTED', 'SIGNALED', 'SNIPED', 'DEAD' ) 
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SESSION_CONNECT_INFO
(  
       SESSION_ID
     , SERIAL_NO
     , OS_USER_NAME
     , CLIENT_CHARSET
     , CLIENT_VERSION
)
AS 
SELECT 
       SESSION_ID
     , SERIAL_NO
     , OS_USER_NAME
     , CLIENT_CHARSET
     , CLIENT_VERSION
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$SESSION_CONNECT_INFO@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SESSION_CONNECT_INFO
        IS 'The V$SESSION_CONNECT_INFO displays information about network connections for the current session.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_CONNECT_INFO.SESSION_ID
        IS 'session identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_CONNECT_INFO.SERIAL_NO
        IS 'session serial number';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_CONNECT_INFO.OS_USER_NAME
        IS 'operating system client user name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_CONNECT_INFO.CLIENT_CHARSET
        IS 'client character set';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_CONNECT_INFO.CLIENT_VERSION
        IS 'client library version number';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SESSION_CONNECT_INFO TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SESSION_CONNECT_INFO TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SESSION_CONNECT_INFO;
CREATE PUBLIC SYNONYM GV$SESSION_CONNECT_INFO FOR PERFORMANCE_VIEW_SCHEMA.GV$SESSION_CONNECT_INFO;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SESSION_CONNECT_INFO;
CREATE PUBLIC SYNONYM V$SESSION_CONNECT_INFO FOR PERFORMANCE_VIEW_SCHEMA.V$SESSION_CONNECT_INFO;
COMMIT;

--##############################################################
--# V$SESSION_STAT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SESSION_STAT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SESSION_STAT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SESSION_STAT
(  
       ORIGIN_MEMBER_NAME
     , STAT_NAME
     , SESS_ID
     , STAT_VALUE
)
AS 
SELECT 
       knstat.CLUSTER_MEMBER_NAME
     , CAST( knstat.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( knstat.ID AS NUMBER )                      -- SESS_ID
     , CAST( knstat.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$KN_SESS_STAT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS knstat   
  WHERE knstat.CATEGORY = 0
UNION ALL
SELECT 
       smenv.CLUSTER_MEMBER_NAME
     , CAST( smenv.NAME AS VARCHAR(128 OCTETS) )        -- STAT_NAME
     , CAST( smenv.ID AS NUMBER )                       -- SESS_ID
     , CAST( smenv.VALUE AS NUMBER )                    -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SM_SESS_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS smenv   
  WHERE smenv.CATEGORY = 0
UNION ALL
SELECT 
       smstat.CLUSTER_MEMBER_NAME
     , CAST( smstat.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( smstat.ID AS NUMBER )                      -- SESS_ID
     , CAST( smstat.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SM_SESS_STAT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS smstat   
  WHERE smstat.CATEGORY = 0
UNION ALL
SELECT 
       exeenv.CLUSTER_MEMBER_NAME
     , CAST( exeenv.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( exeenv.ID AS NUMBER )                      -- SESS_ID
     , CAST( exeenv.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$EXE_SESS_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS exeenv   
  WHERE exeenv.CATEGORY = 0
UNION ALL
SELECT 
       clenv.CLUSTER_MEMBER_NAME
     , CAST( clenv.NAME AS VARCHAR(128 OCTETS) )        -- STAT_NAME
     , CAST( clenv.ID AS NUMBER )                       -- SESS_ID
     , CAST( clenv.VALUE AS NUMBER )                    -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$CL_SESS_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS clenv   
  WHERE clenv.CATEGORY = 0
UNION ALL
SELECT 
       sqlenv.CLUSTER_MEMBER_NAME
     , CAST( sqlenv.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( sqlenv.ID AS NUMBER )                      -- SESS_ID
     , CAST( sqlenv.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_SESS_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sqlenv   
  WHERE sqlenv.CATEGORY = 0
UNION ALL
SELECT 
       ssstat.CLUSTER_MEMBER_NAME
     , CAST( ssstat.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( ssstat.ID AS NUMBER )                      -- SESS_ID
     , CAST( ssstat.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SS_SESS_STAT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS ssstat   
  WHERE ssstat.CATEGORY = 0
ORDER BY 1, 3, 2
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SESSION_STAT
(  
       STAT_NAME
     , SESS_ID
     , STAT_VALUE
)
AS 
SELECT 
       STAT_NAME
     , SESS_ID
     , STAT_VALUE
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$SESSION_STAT@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SESSION_STAT
        IS 'The V$SESSION_STAT displays session statistics.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_STAT.STAT_NAME
        IS 'statistic name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_STAT.SESS_ID
        IS 'session identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_STAT.STAT_VALUE
        IS 'statistic value';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SESSION_STAT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SESSION_STAT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SESSION_STAT;
CREATE PUBLIC SYNONYM GV$SESSION_STAT FOR PERFORMANCE_VIEW_SCHEMA.GV$SESSION_STAT;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SESSION_STAT;
CREATE PUBLIC SYNONYM V$SESSION_STAT FOR PERFORMANCE_VIEW_SCHEMA.V$SESSION_STAT;
COMMIT;

--##############################################################
--# V$SESSION_MEM_STAT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SESSION_MEM_STAT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SESSION_MEM_STAT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SESSION_MEM_STAT
(  
       ORIGIN_MEMBER_NAME
     , STAT_NAME
     , SESS_ID
     , STAT_VALUE
)
AS 
SELECT
       knstat.CLUSTER_MEMBER_NAME
     , CAST( knstat.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( knstat.ID AS NUMBER )                      -- SESS_ID
     , CAST( knstat.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$KN_SESS_STAT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS knstat   
  WHERE knstat.CATEGORY = 11
UNION ALL
SELECT 
       smenv.CLUSTER_MEMBER_NAME
     , CAST( smenv.NAME AS VARCHAR(128 OCTETS) )        -- STAT_NAME
     , CAST( smenv.ID AS NUMBER )                       -- SESS_ID
     , CAST( smenv.VALUE AS NUMBER )                    -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SM_SESS_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS smenv   
  WHERE smenv.CATEGORY = 11
UNION ALL
SELECT 
       smstat.CLUSTER_MEMBER_NAME
     , CAST( smstat.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( smstat.ID AS NUMBER )                      -- SESS_ID
     , CAST( smstat.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SM_SESS_STAT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS smstat   
  WHERE smstat.CATEGORY = 11
UNION ALL
SELECT 
       exeenv.CLUSTER_MEMBER_NAME
     , CAST( exeenv.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( exeenv.ID AS NUMBER )                      -- SESS_ID
     , CAST( exeenv.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$EXE_SESS_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS exeenv   
  WHERE exeenv.CATEGORY = 11
UNION ALL
SELECT 
       clenv.CLUSTER_MEMBER_NAME
     , CAST( clenv.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( clenv.ID AS NUMBER )                      -- SESS_ID
     , CAST( clenv.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$CL_SESS_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS clenv   
  WHERE clenv.CATEGORY = 11
UNION ALL
SELECT 
       sqlenv.CLUSTER_MEMBER_NAME
     , CAST( sqlenv.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( sqlenv.ID AS NUMBER )                      -- SESS_ID
     , CAST( sqlenv.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_SESS_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sqlenv   
  WHERE sqlenv.CATEGORY = 11
UNION ALL
SELECT 
       ssstat.CLUSTER_MEMBER_NAME
     , CAST( ssstat.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( ssstat.ID AS NUMBER )                      -- SESS_ID
     , CAST( ssstat.VALUE AS NUMBER )                   -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SS_SESS_STAT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS ssstat   
  WHERE ssstat.CATEGORY = 11
UNION ALL
SELECT 
       ssstmtstat.CLUSTER_MEMBER_NAME
     , CAST( ssstmtstat.NAME AS VARCHAR(128 OCTETS) )   -- STAT_NAME
     , CAST( ssstmtstat.SESSION_ID AS NUMBER )          -- SESS_ID
     , CAST( SUM( ssstmtstat.VALUE ) AS NUMBER )        -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SS_STMT_STAT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS ssstmtstat   
  WHERE ssstmtstat.CATEGORY = 11
  GROUP BY CLUSTER_MEMBER_NAME, NAME, SESSION_ID
ORDER BY 1, 3, 2
;


CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SESSION_MEM_STAT
(  
       STAT_NAME
     , SESS_ID
     , STAT_VALUE
)
AS 
SELECT 
       STAT_NAME
     , SESS_ID
     , STAT_VALUE
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$SESSION_MEM_STAT@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SESSION_MEM_STAT
        IS 'The V$SESSION_MEM_STAT displays session memory statistics.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_MEM_STAT.STAT_NAME
        IS 'statistic name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_MEM_STAT.SESS_ID
        IS 'session identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_MEM_STAT.STAT_VALUE
        IS 'statistic value';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SESSION_MEM_STAT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SESSION_MEM_STAT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SESSION_MEM_STAT;
CREATE PUBLIC SYNONYM GV$SESSION_MEM_STAT FOR PERFORMANCE_VIEW_SCHEMA.GV$SESSION_MEM_STAT;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SESSION_MEM_STAT;
CREATE PUBLIC SYNONYM V$SESSION_MEM_STAT FOR PERFORMANCE_VIEW_SCHEMA.V$SESSION_MEM_STAT;
COMMIT;

--##############################################################
--# V$SESSION_SQL_STAT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SESSION_SQL_STAT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SESSION_SQL_STAT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SESSION_SQL_STAT
(  
       ORIGIN_MEMBER_NAME
     , STAT_NAME
     , SESS_ID
     , STAT_VALUE
)
AS 
SELECT
       sqlsessenv.CLUSTER_MEMBER_NAME
     , CAST( sqlsessenv.NAME AS VARCHAR(128 OCTETS) )                        -- STAT_NAME
     , CAST( sqlsessenv.ID AS NUMBER )                                       -- SESS_ID
     , CAST( sqlsessenv.VALUE AS NUMBER )                                    -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_SESS_ENV@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sqlsessenv
  WHERE sqlsessenv.CATEGORY = 20
UNION ALL
SELECT 
       sqlprocexec.CLUSTER_MEMBER_NAME
     , CAST( 'COMMAND: ' || sqlprocexec.STMT_TYPE AS VARCHAR(128 OCTETS) )   -- STAT_NAME
     , CAST( sqlprocexec.ID AS NUMBER )                                      -- SESS_ID
     , CAST( sqlprocexec.EXECUTE_COUNT AS NUMBER )                           -- STAT_VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_SESS_STAT_EXEC_STMT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sqlprocexec
 WHERE sqlprocexec.STATE = 'USED | ALIVE'
ORDER BY 1, 3, 2
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SESSION_SQL_STAT
(  
       STAT_NAME
     , SESS_ID
     , STAT_VALUE
)
AS 
SELECT 
       STAT_NAME
     , SESS_ID
     , STAT_VALUE
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$SESSION_SQL_STAT@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SESSION_SQL_STAT
        IS 'The V$SESSION_SQL_STAT displays session SQL statistics.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_SQL_STAT.STAT_NAME
        IS 'statistic name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_SQL_STAT.SESS_ID
        IS 'session identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_SQL_STAT.STAT_VALUE
        IS 'statistic value';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SESSION_SQL_STAT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SESSION_SQL_STAT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SESSION_SQL_STAT;
CREATE PUBLIC SYNONYM GV$SESSION_SQL_STAT FOR PERFORMANCE_VIEW_SCHEMA.GV$SESSION_SQL_STAT;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SESSION_SQL_STAT;
CREATE PUBLIC SYNONYM V$SESSION_SQL_STAT FOR PERFORMANCE_VIEW_SCHEMA.V$SESSION_SQL_STAT;
COMMIT;

--##############################################################
--# V$SHM_SEGMENT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SHM_SEGMENT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SHM_SEGMENT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SHM_SEGMENT
(  
       ORIGIN_MEMBER_NAME
     , SHM_NAME
     , SHM_ID
     , SHM_SIZE
     , SHM_KEY
     , SHM_SEQ
     , SHM_ADDR
)
AS 
SELECT 
       shmseg.CLUSTER_MEMBER_ID
     , CAST( shmseg.NAME AS VARCHAR(32 OCTETS) )    -- SHM_NAME
     , CAST( shmseg.ID AS NUMBER )                  -- SHM_ID
     , CAST( shmseg.SIZE AS NUMBER )                -- SHM_SIZE
     , CAST( shmseg.KEY AS NUMBER )                 -- SHM_KEY
     , CAST( shmseg.SEQ AS NUMBER )                 -- SHM_SEQ
     , CAST( shmseg.ADDR AS VARCHAR(32 OCTETS) )    -- SHM_ADDR
  FROM 
       FIXED_TABLE_SCHEMA.X$SHM_SEGMENT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS shmseg
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SHM_SEGMENT
(  
       SHM_NAME
     , SHM_ID
     , SHM_SIZE
     , SHM_KEY
     , SHM_SEQ
     , SHM_ADDR
)
AS 
SELECT 
       SHM_NAME
     , SHM_ID
     , SHM_SIZE
     , SHM_KEY
     , SHM_SEQ
     , SHM_ADDR
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$SHM_SEGMENT@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SHM_SEGMENT
        IS 'The V$SHM_SEGMENT displays a list of all shared memory segments.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SHM_SEGMENT.SHM_NAME
        IS 'shared memory segment name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SHM_SEGMENT.SHM_ID
        IS 'shared memory segment identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SHM_SEGMENT.SHM_SIZE
        IS 'shared memory segment size ( in bytes )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SHM_SEGMENT.SHM_KEY
        IS 'shared memory segment key';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SHM_SEGMENT.SHM_SEQ
        IS 'shared memory segment sequence';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SHM_SEGMENT.SHM_ADDR
        IS 'start address of the shared memory segment';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SHM_SEGMENT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SHM_SEGMENT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SHM_SEGMENT;
CREATE PUBLIC SYNONYM GV$SHM_SEGMENT FOR PERFORMANCE_VIEW_SCHEMA.GV$SHM_SEGMENT;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SHM_SEGMENT;
CREATE PUBLIC SYNONYM V$SHM_SEGMENT FOR PERFORMANCE_VIEW_SCHEMA.V$SHM_SEGMENT;
COMMIT;

--##############################################################
--# V$SQLFN_METADATA
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SQLFN_METADATA;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SQLFN_METADATA;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SQLFN_METADATA
(  
       FUNC_NAME
     , MINARGS
     , MAXARGS
     , IS_AGGREGATE
)
AS 
SELECT
       CAST( func.FUNC_NAME AS VARCHAR(128 OCTETS) )   -- FUNC_NAME
     , CAST( func.MIN_ARG_COUNT AS NUMBER )            -- MINARGS
     , CAST( func.MAX_ARG_COUNT AS NUMBER )            -- MAXARGS
     , CAST( FALSE AS BOOLEAN )                        -- IS_AGGREGATE
  FROM 
       FIXED_TABLE_SCHEMA.X$BUILTIN_FUNCTION@GLOBAL[RANDOM_MEMBER] func
UNION ALL
SELECT 
       CAST( aggr.FUNC_NAME AS VARCHAR(128 OCTETS) )
     , CAST( aggr.MIN_ARG_COUNT AS NUMBER )
     , CAST( aggr.MAX_ARG_COUNT AS NUMBER )
     , TRUE
  FROM 
       FIXED_TABLE_SCHEMA.X$BUILTIN_AGGREGATION@GLOBAL[RANDOM_MEMBER] aggr
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SQLFN_METADATA
(  
       FUNC_NAME
     , MINARGS
     , MAXARGS
     , IS_AGGREGATE
)
AS 
SELECT 
       FUNC_NAME
     , MINARGS
     , MAXARGS
     , IS_AGGREGATE
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$SQLFN_METADATA@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SQLFN_METADATA
        IS 'The V$SQLFN_METADATA contains metadata about operators and built-in functions';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQLFN_METADATA.FUNC_NAME
        IS 'name of the built-in function';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQLFN_METADATA.MINARGS
        IS 'minimum number of arguments for the function';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQLFN_METADATA.MAXARGS
        IS 'maximum number of arguments for the function';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQLFN_METADATA.IS_AGGREGATE
        IS 'indicates whether the function is an aggregate function (TRUE) or not (FALSE)';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SQLFN_METADATA TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SQLFN_METADATA TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SQLFN_METADATA;
CREATE PUBLIC SYNONYM GV$SQLFN_METADATA FOR PERFORMANCE_VIEW_SCHEMA.GV$SQLFN_METADATA;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SQLFN_METADATA;
CREATE PUBLIC SYNONYM V$SQLFN_METADATA FOR PERFORMANCE_VIEW_SCHEMA.V$SQLFN_METADATA;
COMMIT;

--##############################################################
--# V$SQL_CACHE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SQL_CACHE;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SQL_CACHE
(  
       ORIGIN_MEMBER_NAME
     , SQL_HANDLE
     , HASH_VALUE
     , REF_COUNT
     , CLOCK_ID
     , PLAN_AGE
     , USER_NAME
     , BIND_PARAM_COUNT
     , SQL_TEXT
     , PLAN_COUNT
     , PLAN_ID
     , PLAN_SIZE
     , PLAN_IS_ATOMIC
     , PLAN_TEXT
)
AS 
SELECT 
       /*+ USE_HASH( sqlplan ) */
       sqlcache.CLUSTER_MEMBER_NAME
     , CAST( sqlcache.SQL_HANDLE AS NUMBER )            -- SQL_HANDLE
     , CAST( sqlcache.HASH_VALUE AS NUMBER )            -- HASH_VALUE
     , CAST( sqlplan.REF_COUNT AS NUMBER )              -- REF_COUNT
     , CAST( sqlcache.CLOCK_ID AS NUMBER )              -- CLOCK_ID
     , CAST( sqlcache.AGE AS NUMBER )                   -- PLAN_AGE
     , auth.AUTHORIZATION_NAME                          -- USER_NAME
     , CAST( sqlcache.BIND_COUNT AS NUMBER )            -- BIND_PARAM_COUNT
     , CAST( sqlcache.SQL_STRING AS LONG VARCHAR )      -- SQL_TEXT
     , CAST( sqlcache.PLAN_COUNT AS NUMBER )            -- PLAN_COUNT
     , CAST( sqlplan.PLAN_IDX AS NUMBER )               -- PLAN_ID
     , CAST( sqlplan.PLAN_SIZE AS NUMBER )              -- PLAN_SIZE
     , CAST( sqlplan.IS_ATOMIC AS BOOLEAN )             -- PLAN_IS_ATOMIC
     , CAST( sqlplan.PLAN_STRING AS LONG VARCHAR )      -- PLAN_TEXT
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_CACHE@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sqlcache
       INNER JOIN
       FIXED_TABLE_SCHEMA.X$SQL_CACHE_PLAN@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sqlplan
       ON  sqlcache.sql_handle = sqlplan.sql_handle
       AND sqlcache.CLUSTER_MEMBER_ID = sqlplan.CLUSTER_MEMBER_ID
       LEFT OUTER JOIN   
       DEFINITION_SCHEMA.AUTHORIZATIONS@GLOBAL[IGNORE_INACTIVE_MEMBER] AS auth
       ON  sqlcache.USER_ID = auth.AUTH_ID
       AND sqlcache.CLUSTER_MEMBER_ID = auth.CLUSTER_MEMBER_ID
 WHERE 
       sqlcache.DROPPED = FALSE
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE
(  
       SQL_HANDLE
     , HASH_VALUE
     , REF_COUNT
     , CLOCK_ID
     , PLAN_AGE
     , USER_NAME
     , BIND_PARAM_COUNT
     , SQL_TEXT
     , PLAN_COUNT
     , PLAN_ID
     , PLAN_SIZE
     , PLAN_IS_ATOMIC
     , PLAN_TEXT
)
AS 
SELECT 
       SQL_HANDLE
     , HASH_VALUE
     , REF_COUNT
     , CLOCK_ID
     , PLAN_AGE
     , USER_NAME
     , BIND_PARAM_COUNT
     , SQL_TEXT
     , PLAN_COUNT
     , PLAN_ID
     , PLAN_SIZE
     , PLAN_IS_ATOMIC
     , PLAN_TEXT
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$SQL_CACHE@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE
        IS 'The V$SQL_CACHE lists statistics of shared SQL plan.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE.SQL_HANDLE
        IS 'SQL handle';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE.HASH_VALUE
        IS 'hash value of the SQL statement';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE.REF_COUNT
        IS 'count of prepared statements referencing the statement';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE.CLOCK_ID
        IS 'clock identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE.PLAN_AGE
        IS 'plan age';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE.USER_NAME
        IS 'user name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE.BIND_PARAM_COUNT
        IS 'count of bind parameters';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE.SQL_TEXT
        IS 'SQL full text';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE.PLAN_COUNT
        IS 'physical plan count of the SQL statement';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE.PLAN_ID
        IS 'plan identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE.PLAN_SIZE
        IS 'the total plan size of the SQL statement ( in bytes )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE.PLAN_IS_ATOMIC
        IS 'plan is atomic array insert or not';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE.PLAN_TEXT
        IS 'plan text for SQL statement';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SQL_CACHE TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SQL_CACHE;
CREATE PUBLIC SYNONYM GV$SQL_CACHE FOR PERFORMANCE_VIEW_SCHEMA.GV$SQL_CACHE;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SQL_CACHE;
CREATE PUBLIC SYNONYM V$SQL_CACHE FOR PERFORMANCE_VIEW_SCHEMA.V$SQL_CACHE;
COMMIT;

--##############################################################
--# V$SQL_COMMAND
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SQL_COMMAND;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SQL_COMMAND;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SQL_COMMAND
(  
       ORIGIN_MEMBER_NAME
     , COMMAND
     , FROM_PHASE
     , UNTIL_PHASE
     , ACCESS_MODE
     , NEED_FETCH
     , IS_DDL
     , AUTO_COMMIT
     , IS_CACHEABLE
     , AUDIT_ACTION
)
AS 
SELECT 
       cmd.CLUSTER_MEMBER_NAME
     , CAST( cmd.SQL_COMMAND AS VARCHAR(128 OCTETS) )   -- COMMAND
     , CAST( cmd.FROM_PHASE AS VARCHAR(32 OCTETS) )     -- FROM_PHASE
     , CAST( cmd.UNTIL_PHASE AS VARCHAR(32 OCTETS) )    -- UNTIL_PHASE
     , CAST( cmd.ACCESS_MODE AS VARCHAR(32 OCTETS) )    -- ACCESS_MODE
     , CAST( CASE WHEN cmd.NEED_FETCH = TRUE 
                  THEN 'YES' ELSE 'NO' 
              END AS VARCHAR(3 OCTETS) )                -- NEED_FETCH
     , CAST( CASE WHEN cmd.IS_DDL = TRUE 
                  THEN 'YES' ELSE 'NO' 
              END AS VARCHAR(3 OCTETS) )                -- IS_DDL
     , CAST( CASE WHEN cmd.AUTO_COMMIT = TRUE 
                  THEN 'YES' ELSE 'NO' 
              END AS VARCHAR(3 OCTETS) )                -- AUTO_COMMIT
     , CAST( CASE WHEN cmd.PLAN_CACHE = 'NONE'
                  THEN 'NO' ELSE 'YES' 
              END AS VARCHAR(3 OCTETS) )                -- IS_CACHEABLE
     , CAST( CASE WHEN cmd.AUDIT_ACTION_NAME = 'N/A'
                  THEN NULL ELSE cmd.AUDIT_ACTION_NAME
              END AS VARCHAR(128 OCTETS) )              -- AUDIT_ACTION
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_COMMANDS@GLOBAL[IGNORE_INACTIVE_MEMBER] AS cmd
  WHERE cmd.IS_EXTERNAL = TRUE
;


CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SQL_COMMAND
(  
       COMMAND
     , FROM_PHASE
     , UNTIL_PHASE
     , ACCESS_MODE
     , NEED_FETCH
     , IS_DDL
     , AUTO_COMMIT
     , IS_CACHEABLE
     , AUDIT_ACTION
)
AS 
SELECT 
       COMMAND
     , FROM_PHASE
     , UNTIL_PHASE
     , ACCESS_MODE
     , NEED_FETCH
     , IS_DDL
     , AUTO_COMMIT
     , IS_CACHEABLE
     , AUDIT_ACTION
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$SQL_COMMAND@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SQL_COMMAND
        IS 'The V$SQL_COMMAND lists attribute information of each SQL command.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_COMMAND.COMMAND
        IS 'SQL command';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_COMMAND.FROM_PHASE
        IS 'executable from start-up phase';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_COMMAND.UNTIL_PHASE
        IS 'executable until start-up phase';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_COMMAND.ACCESS_MODE
        IS 'database access mode: values in (NONE, READ & WRITE, READ, READ & LOCK)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_COMMAND.NEED_FETCH
        IS 'the command is a query which has result set and need fetch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_COMMAND.IS_DDL
        IS 'the command is a DDL(Data Defintion Language) or not';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_COMMAND.AUTO_COMMIT
        IS 'the command is auto-commit or not';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_COMMAND.IS_CACHEABLE
        IS 'the command is plan-cacheable or not';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_COMMAND.AUDIT_ACTION
        IS 'auditiable action name for the SQL command';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SQL_COMMAND TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SQL_COMMAND TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SQL_COMMAND;
CREATE PUBLIC SYNONYM GV$SQL_COMMAND FOR PERFORMANCE_VIEW_SCHEMA.GV$SQL_COMMAND;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SQL_COMMAND;
CREATE PUBLIC SYNONYM V$SQL_COMMAND FOR PERFORMANCE_VIEW_SCHEMA.V$SQL_COMMAND;
COMMIT;


--##############################################################
--# V$STATEMENT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$STATEMENT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$STATEMENT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$STATEMENT 
( 
       ORIGIN_MEMBER_NAME
     , SESSION_ID
     , STMT_ID
     , STMT_VIEW_SCN
     , SQL_TEXT
     , START_TIME
     , TOTAL_EXEC_TIME
     , LAST_EXEC_TIME
     , EXECUTIONS
)
AS 
SELECT
       xstmt.CLUSTER_MEMBER_NAME
     , CAST( xstmt.SESSION_ID AS NUMBER )                -- SESSION_ID
     , CAST( xstmt.ID AS NUMBER )                        -- STMT_ID
     , CAST( xstmt.VIEW_SCN AS VARCHAR(32 OCTETS) )      -- STMT_VIEW_SCN
     , CAST( xstmt.SQL_TEXT AS VARCHAR(1024 OCTETS) )    -- SQL_TEXT
     , CASE WHEN xstmt.START_EXEC = TRUE THEN xstmt.START_TIME   
                                         ELSE NULL
       END                                               -- START_TIME
     , xstmt.TOTAL_EXEC_TIME                             -- TOTAL_EXEC_TIME
     , xstmt.LAST_EXEC_TIME                              -- LAST_EXEC_TIME
     , xstmt.EXECUTIONS                                  -- EXECUTIONS
  FROM  
       FIXED_TABLE_SCHEMA.X$STATEMENT@GLOBAL[IGNORE_INACTIVE_MEMBER]    AS xstmt
 UNION ALL
SELECT
       xcur.CLUSTER_MEMBER_NAME
     , CAST( xcur.SESSION_ID AS NUMBER )                 -- SESSION_ID
     , CAST( NULL AS NUMBER )                            -- STMT_ID
     , CAST( xcur.VIEW_SCN AS VARCHAR(32 OCTETS) )       -- STMT_VIEW_SCN
     , CAST( xcur.CURSOR_QUERY AS VARCHAR(1024 OCTETS) ) -- SQL_TEXT
     , CASE WHEN xcur.IS_OPEN = TRUE THEN xcur.OPEN_TIME   
                                     ELSE NULL
       END                                               -- START_TIME
     , xcur.TOTAL_EXEC_TIME                              -- TOTAL_EXEC_TIME
     , xcur.LAST_EXEC_TIME                               -- LAST_EXEC_TIME
     , xcur.EXECUTIONS                                   -- EXECUTIONS
  FROM  
       FIXED_TABLE_SCHEMA.X$NAMED_CURSOR@GLOBAL[IGNORE_INACTIVE_MEMBER] AS xcur
ORDER BY 1, 2, 3
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$STATEMENT 
( 
       SESSION_ID
     , STMT_ID
     , STMT_VIEW_SCN
     , SQL_TEXT
     , START_TIME
     , TOTAL_EXEC_TIME
     , LAST_EXEC_TIME
     , EXECUTIONS
)
AS 
SELECT 
       SESSION_ID
     , STMT_ID
     , STMT_VIEW_SCN
     , SQL_TEXT
     , START_TIME
     , TOTAL_EXEC_TIME
     , LAST_EXEC_TIME
     , EXECUTIONS
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$STATEMENT@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$STATEMENT 
        IS 'The V$STATEMENT lists all statements.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$STATEMENT.SESSION_ID
        IS 'session identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$STATEMENT.STMT_ID
        IS 'statement identifier in a session, null if named cursor query';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$STATEMENT.STMT_VIEW_SCN
        IS 'statement view scn';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$STATEMENT.SQL_TEXT
        IS 'first 1024 bytes of the SQL text for the statement';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$STATEMENT.START_TIME
        IS 'statement start time';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$STATEMENT.TOTAL_EXEC_TIME
        IS 'total execution time(us)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$STATEMENT.LAST_EXEC_TIME
        IS 'last execution time(us)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$STATEMENT.EXECUTIONS
        IS 'number of executions';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$STATEMENT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$STATEMENT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$STATEMENT;
CREATE PUBLIC SYNONYM GV$STATEMENT FOR PERFORMANCE_VIEW_SCHEMA.GV$STATEMENT;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$STATEMENT;
CREATE PUBLIC SYNONYM V$STATEMENT FOR PERFORMANCE_VIEW_SCHEMA.V$STATEMENT;
COMMIT;

--##############################################################
--# V$SPROPERTY
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SPROPERTY;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SPROPERTY 
( 
       ORIGIN_MEMBER_NAME
     , PROPERTY_NAME
     , DESCRIPTION
     , DATA_TYPE
     , STARTUP_PHASE
     , VALUE_UNIT
     , PROPERTY_VALUE
     , PROPERTY_SOURCE
     , INIT_VALUE
     , INIT_SOURCE
     , MIN_VALUE
     , MAX_VALUE
     , SES_MODIFIABLE
     , SYS_MODIFIABLE
     , IS_MODIFIABLE
     , IS_DEPRECATED
     , IS_GLOBAL
)
AS 
SELECT 
       CLUSTER_MEMBER_NAME
     , CAST( PROPERTY_NAME AS VARCHAR(128 OCTETS) )  -- PROPERTY_NAME
     , CAST( DESCRIPTION AS VARCHAR(2048 OCTETS) )   -- DESCRIPTION
     , CAST( DATA_TYPE AS VARCHAR(32 OCTETS) )       -- DATA_TYPE
     , CAST( STARTUP_PHASE AS VARCHAR(32 OCTETS) )   -- STARTUP_PHASE
     , CAST( UNIT AS VARCHAR(32 OCTETS) )            -- VALUE_UNIT
     , CAST( VALUE AS VARCHAR(2048 OCTETS) )         -- PROPERTY_VALUE
     , CAST( SOURCE AS VARCHAR(32 OCTETS) )          -- PROPERTY_SOURCE
     , CAST( INIT_VALUE AS VARCHAR(2048 OCTETS) )    -- INIT_VALUE
     , CAST( INIT_SOURCE AS VARCHAR(32 OCTETS) )     -- INIT_SOURCE
     , CAST( CASE WHEN DATA_TYPE = 'VARCHAR' THEN NULL
                                             ELSE MIN 
             END
             AS NUMBER )                             -- MIN_VALUE
     , CAST( CASE WHEN DATA_TYPE = 'VARCHAR' THEN NULL
                                             ELSE MAX 
             END
             AS NUMBER )                             -- MAX_VALUE
     , CAST( SES_MODIFIABLE AS VARCHAR(32 OCTETS) )  -- SES_MODIFIABLE
     , CAST( SYS_MODIFIABLE AS VARCHAR(32 OCTETS) )  -- SYS_MODIFIABLE
     , CAST( MODIFIABLE AS VARCHAR(32 OCTETS) )      -- IS_MODIFIABLE
     , CAST( CASE WHEN DOMAIN = 'DEPRECATED' THEN 'TRUE'
                                             ELSE 'FALSE'
             END
             AS VARCHAR(32 OCTETS) )                 -- IS_DEPRECATED
     , CAST( CASE WHEN CLUSTER_SCOPE = 'GLOBAL' THEN 'TRUE'
                                                ELSE 'FALSE' 
             END
             AS VARCHAR(32 OCTETS) )                 -- IS_GLOBAL
  FROM 
       FIXED_TABLE_SCHEMA.X$SPROPERTY@GLOBAL[IGNORE_INACTIVE_MEMBER]
 WHERE 
       DOMAIN = 'EXTERNAL' OR DOMAIN = 'DEPRECATED'
ORDER BY 
      1,
      PROPERTY_ID
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY 
( 
       PROPERTY_NAME
     , DESCRIPTION
     , DATA_TYPE
     , STARTUP_PHASE
     , VALUE_UNIT
     , PROPERTY_VALUE
     , PROPERTY_SOURCE
     , INIT_VALUE
     , INIT_SOURCE
     , MIN_VALUE
     , MAX_VALUE
     , SES_MODIFIABLE
     , SYS_MODIFIABLE
     , IS_MODIFIABLE
     , IS_DEPRECATED
     , IS_GLOBAL
)
AS 
SELECT 
       PROPERTY_NAME
     , DESCRIPTION
     , DATA_TYPE
     , STARTUP_PHASE
     , VALUE_UNIT
     , PROPERTY_VALUE
     , PROPERTY_SOURCE
     , INIT_VALUE
     , INIT_SOURCE
     , MIN_VALUE
     , MAX_VALUE
     , SES_MODIFIABLE
     , SYS_MODIFIABLE
     , IS_MODIFIABLE
     , IS_DEPRECATED
     , IS_GLOBAL
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$SPROPERTY@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY  
        IS 'The V$SPROPERTY displays a list of Properties. This is store a binary property file';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY.PROPERTY_NAME
        IS 'name of the property';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY.DESCRIPTION
        IS 'description of the property';        
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY.DATA_TYPE
        IS 'data type of the property';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY.STARTUP_PHASE
        IS 'modifiable startup-phase: the value IN ( NO MOUNT / MOUNT / OPEN & [BELOW|ABOVE] )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY.VALUE_UNIT
        IS 'unit of the property value: the value in ( NONE, BYTE, MS(milisec) )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY.PROPERTY_VALUE
        IS 'property value stored in the binary property file';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY.PROPERTY_SOURCE
        IS 'source of the current property value: the value is BINARY_FILE';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY.INIT_VALUE
        IS 'property init value for the system';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY.INIT_SOURCE
        IS 'source of the current property INIT_VALUE: the value IN ( USER, DEFAULT, ENV_VAR, BINARY_FILE, FILE, SYSTEM )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY.MIN_VALUE
        IS 'minimum value for property. null if type is varchar.';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY.MAX_VALUE
        IS 'maximum value for property. null if type is varchar.';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY.SES_MODIFIABLE
        IS 'property can be changed with ALTER SESSION or not: the value in ( TRUE, FALSE )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY.SYS_MODIFIABLE
        IS 'property can be changed with ALTER SYSTEM and when the change takes effect: the value in ( NONE, FALSE, IMMEDIATE, DEFERRED )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY.IS_MODIFIABLE
        IS 'property can be changed or not: the value in ( TRUE, FALSE )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY.IS_DEPRECATED
        IS 'property is deprecated: the value in ( TRUE, FALSE )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY.IS_GLOBAL
        IS 'property scope is global or not: the value in ( TRUE, FALSE )';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SPROPERTY TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SPROPERTY;
CREATE PUBLIC SYNONYM GV$SPROPERTY FOR PERFORMANCE_VIEW_SCHEMA.GV$SPROPERTY;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SPROPERTY;
CREATE PUBLIC SYNONYM V$SPROPERTY FOR PERFORMANCE_VIEW_SCHEMA.V$SPROPERTY;
COMMIT;

--##############################################################
--# V$SYSTEM_STAT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_STAT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_STAT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_STAT
(  
       ORIGIN_MEMBER_NAME
     , STAT_NAME
     , STAT_VALUE
     , COMMENTS
)
AS 
SELECT 
       kninfo.CLUSTER_MEMBER_NAME
     , CAST( kninfo.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( kninfo.VALUE AS NUMBER )                   -- STAT_VALUE
     , CAST( kninfo.COMMENTS AS VARCHAR(1024 OCTETS) )  -- COMMENTS
  FROM 
       FIXED_TABLE_SCHEMA.X$KN_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS kninfo   
  WHERE kninfo.CATEGORY = 0
UNION ALL
SELECT 
       sminfo.CLUSTER_MEMBER_NAME
     , CAST( sminfo.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( sminfo.VALUE AS NUMBER )                   -- STAT_VALUE
     , CAST( sminfo.COMMENTS AS VARCHAR(1024 OCTETS) )  -- COMMENTS
  FROM 
       FIXED_TABLE_SCHEMA.X$SM_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sminfo   
  WHERE sminfo.CATEGORY = 0
UNION ALL
SELECT 
       exeinfo.CLUSTER_MEMBER_NAME
     , CAST( exeinfo.NAME AS VARCHAR(128 OCTETS) )      -- STAT_NAME
     , CAST( exeinfo.VALUE AS NUMBER )                  -- STAT_VALUE
     , CAST( exeinfo.COMMENTS AS VARCHAR(1024 OCTETS) ) -- COMMENTS
  FROM 
       FIXED_TABLE_SCHEMA.X$EXE_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS exeinfo
  WHERE exeinfo.CATEGORY = 0
UNION ALL
SELECT 
       clinfo.CLUSTER_MEMBER_NAME
     , CAST( clinfo.NAME AS VARCHAR(128 OCTETS) )      -- STAT_NAME
     , CAST( clinfo.VALUE AS NUMBER )                  -- STAT_VALUE
     , CAST( clinfo.COMMENTS AS VARCHAR(1024 OCTETS) ) -- COMMENTS
  FROM 
       FIXED_TABLE_SCHEMA.X$CL_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS clinfo
  WHERE clinfo.CATEGORY = 0
UNION ALL
SELECT 
       sqlinfo.CLUSTER_MEMBER_NAME
     , CAST( sqlinfo.NAME AS VARCHAR(128 OCTETS) )      -- STAT_NAME
     , CAST( sqlinfo.VALUE AS NUMBER )                  -- STAT_VALUE
     , CAST( sqlinfo.COMMENTS AS VARCHAR(1024 OCTETS) ) -- COMMENTS
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sqlinfo   
  WHERE sqlinfo.CATEGORY = 0
UNION ALL
SELECT 
       slinfo.CLUSTER_MEMBER_NAME
     , CAST( slinfo.NAME AS VARCHAR(128 OCTETS) )      -- STAT_NAME
     , CAST( slinfo.VALUE AS NUMBER )                  -- STAT_VALUE
     , CAST( slinfo.COMMENTS AS VARCHAR(1024 OCTETS) ) -- COMMENTS
  FROM 
       FIXED_TABLE_SCHEMA.X$SL_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS slinfo   
  WHERE slinfo.CATEGORY = 0
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_STAT
(  
       STAT_NAME
     , STAT_VALUE
     , COMMENTS
)
AS 
SELECT 
       STAT_NAME
     , STAT_VALUE
     , COMMENTS
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_STAT@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_STAT
        IS 'The V$SYSTEM_STAT displays system statistics.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_STAT.STAT_NAME
        IS 'statistic name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_STAT.STAT_VALUE
        IS 'statistic value';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_STAT.COMMENTS
        IS 'comments';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_STAT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_STAT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SYSTEM_STAT;
CREATE PUBLIC SYNONYM GV$SYSTEM_STAT FOR PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_STAT;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SYSTEM_STAT;
CREATE PUBLIC SYNONYM V$SYSTEM_STAT FOR PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_STAT;
COMMIT;

--##############################################################
--# V$SYSTEM_MEM_STAT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_MEM_STAT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_MEM_STAT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_MEM_STAT
(  
       ORIGIN_MEMBER_NAME
     , STAT_NAME
     , STAT_VALUE
     , COMMENTS
)
AS 
SELECT
       kninfo.CLUSTER_MEMBER_NAME
     , CAST( kninfo.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( kninfo.VALUE AS NUMBER )                   -- STAT_VALUE
     , CAST( kninfo.COMMENTS AS VARCHAR(1024 OCTETS) )  -- COMMENTS
  FROM 
       FIXED_TABLE_SCHEMA.X$KN_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS kninfo   
  WHERE kninfo.CATEGORY = 11
UNION ALL
SELECT 
       sminfo.CLUSTER_MEMBER_NAME
     , CAST( sminfo.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( sminfo.VALUE AS NUMBER )                   -- STAT_VALUE
     , CAST( sminfo.COMMENTS AS VARCHAR(1024 OCTETS) )  -- COMMENTS
  FROM 
       FIXED_TABLE_SCHEMA.X$SM_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sminfo   
  WHERE sminfo.CATEGORY = 11
UNION ALL
SELECT 
       exeinfo.CLUSTER_MEMBER_NAME
     , CAST( exeinfo.NAME AS VARCHAR(128 OCTETS) )      -- STAT_NAME
     , CAST( exeinfo.VALUE AS NUMBER )                  -- STAT_VALUE
     , CAST( exeinfo.COMMENTS AS VARCHAR(1024 OCTETS) ) -- COMMENTS
  FROM 
       FIXED_TABLE_SCHEMA.X$EXE_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS exeinfo
  WHERE exeinfo.CATEGORY = 11
UNION ALL
SELECT 
       clinfo.CLUSTER_MEMBER_NAME
     , CAST( clinfo.NAME AS VARCHAR(128 OCTETS) )      -- STAT_NAME
     , CAST( clinfo.VALUE AS NUMBER )                  -- STAT_VALUE
     , CAST( clinfo.COMMENTS AS VARCHAR(1024 OCTETS) ) -- COMMENTS
  FROM 
       FIXED_TABLE_SCHEMA.X$CL_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS clinfo
  WHERE clinfo.CATEGORY = 11
UNION ALL
SELECT 
       sqlinfo.CLUSTER_MEMBER_NAME
     , CAST( sqlinfo.NAME AS VARCHAR(128 OCTETS) )      -- STAT_NAME
     , CAST( sqlinfo.VALUE AS NUMBER )                  -- STAT_VALUE
     , CAST( sqlinfo.COMMENTS AS VARCHAR(1024 OCTETS) ) -- COMMENTS
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sqlinfo   
  WHERE sqlinfo.CATEGORY = 11
UNION ALL
SELECT 
       slinfo.CLUSTER_MEMBER_NAME
     , CAST( slinfo.NAME AS VARCHAR(128 OCTETS) )      -- STAT_NAME
     , CAST( slinfo.VALUE AS NUMBER )                  -- STAT_VALUE
     , CAST( slinfo.COMMENTS AS VARCHAR(1024 OCTETS) ) -- COMMENTS
  FROM 
       FIXED_TABLE_SCHEMA.X$SL_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS slinfo   
  WHERE slinfo.CATEGORY = 11
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_MEM_STAT
(  
       STAT_NAME
     , STAT_VALUE
     , COMMENTS
)
AS 
SELECT 
       STAT_NAME
     , STAT_VALUE
     , COMMENTS
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_MEM_STAT@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_MEM_STAT
        IS 'The V$SYSTEM_MEM_STAT displays system memory statistics.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_MEM_STAT.STAT_NAME
        IS 'statistic name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_MEM_STAT.STAT_VALUE
        IS 'statistic value';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_MEM_STAT.COMMENTS
        IS 'comments';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_MEM_STAT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_MEM_STAT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS V$SYSTEM_MEM_STAT;
CREATE PUBLIC SYNONYM V$SYSTEM_MEM_STAT FOR PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_MEM_STAT;
COMMIT;

--##############################################################
--# V$SYSTEM_SQL_STAT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_SQL_STAT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_SQL_STAT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_SQL_STAT
(  
       ORIGIN_MEMBER_NAME
     , STAT_NAME
     , STAT_VALUE
     , COMMENTS
)
AS 
SELECT 
       sysinfo.CLUSTER_MEMBER_NAME
     , CAST( sysinfo.NAME AS VARCHAR(128 OCTETS) )       -- STAT_NAME
     , CAST( sysinfo.VALUE AS NUMBER )                   -- STAT_VALUE
     , CAST( sysinfo.COMMENTS AS VARCHAR(1024 OCTETS) )  -- COMMENTS
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sysinfo
  WHERE sysinfo.CATEGORY = 20
UNION ALL
SELECT 
       sysexec.CLUSTER_MEMBER_NAME
     , CAST( 'COMMAND: ' || sysexec.STMT_TYPE AS VARCHAR(128 OCTETS) )   -- STAT_NAME
     , CAST( sysexec.EXECUTE_COUNT AS NUMBER )                           -- STAT_VALUE
     , CAST( 'execution count of the command' AS VARCHAR(1024 OCTETS) )  -- COMMENTS
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_SYSTEM_STAT_EXEC_STMT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sysexec
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_SQL_STAT
(  
       STAT_NAME
     , STAT_VALUE
     , COMMENTS
)
AS 
SELECT 
       STAT_NAME
     , STAT_VALUE
     , COMMENTS
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_SQL_STAT@LOCAL
;
      
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_SQL_STAT
        IS 'The V$SYSTEM_SQL_STAT displays system SQL statistics.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_SQL_STAT.STAT_NAME
        IS 'statistic name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_SQL_STAT.STAT_VALUE
        IS 'statistic value';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_SQL_STAT.COMMENTS
        IS 'comments';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_SQL_STAT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_SQL_STAT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SYSTEM_SQL_STAT;
CREATE PUBLIC SYNONYM GV$SYSTEM_SQL_STAT FOR PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_SQL_STAT;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SYSTEM_SQL_STAT;
CREATE PUBLIC SYNONYM V$SYSTEM_SQL_STAT FOR PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_SQL_STAT;
COMMIT;

--##############################################################
--# V$TABLES
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$TABLES;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$TABLES;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$TABLES 
( 
       TABLE_OWNER
     , TABLE_SCHEMA
     , TABLE_NAME
     , STARTUP_PHASE
     , CREATED_TIME
     , MODIFIED_TIME
     , COMMENTS
)
AS 
SELECT 
       auth.AUTHORIZATION_NAME -- TABLE_OWNER
     , sch.SCHEMA_NAME         -- TABLE_SCHEMA
     , tab.TABLE_NAME          -- TABLE_NAME
     , CAST( CASE WHEN ( SELECT COUNT(*) 
                           FROM FIXED_TABLE_SCHEMA.X$FIXED_VIEW@GLOBAL[RANDOM_MEMBER] xfv
                          WHERE xfv.VIEW_NAME         = tab.TABLE_NAME
                            AND xfv.CLUSTER_MEMBER_ID = tab.CLUSTER_MEMBER_ID
                            AND xfv.STARTUP_PHASE = 'NO_MOUNT' ) > 0
                       THEN 'NO_MOUNT'
                  WHEN ( SELECT COUNT(*) 
                           FROM FIXED_TABLE_SCHEMA.X$FIXED_VIEW@GLOBAL[RANDOM_MEMBER] xfv
                          WHERE xfv.VIEW_NAME         = tab.TABLE_NAME
                            AND xfv.CLUSTER_MEMBER_ID = tab.CLUSTER_MEMBER_ID
                            AND xfv.STARTUP_PHASE = 'MOUNT' ) > 0
                       THEN 'MOUNT'
                  ELSE 'OPEN'
             END AS VARCHAR(32 OCTETS) )
     , tab.CREATED_TIME        -- CREATED_TIME
     , tab.MODIFIED_TIME       -- MODIFIED_TIME
     , tab.COMMENTS            -- COMMENTS
  FROM  
       DEFINITION_SCHEMA.TABLES@GLOBAL[RANDOM_MEMBER]          AS tab 
     , DEFINITION_SCHEMA.SCHEMATA@GLOBAL[RANDOM_MEMBER]        AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS@GLOBAL[RANDOM_MEMBER]  AS auth 
 WHERE 
       sch.SCHEMA_NAME = 'PERFORMANCE_VIEW_SCHEMA'
   AND tab.SCHEMA_ID         = sch.SCHEMA_ID 
   AND tab.CLUSTER_MEMBER_ID = sch.CLUSTER_MEMBER_ID
   AND tab.OWNER_ID          = auth.AUTH_ID 
   AND tab.CLUSTER_MEMBER_ID = auth.CLUSTER_MEMBER_ID
 ORDER BY
       2
     , 3
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$TABLES 
( 
       TABLE_OWNER
     , TABLE_SCHEMA
     , TABLE_NAME
     , STARTUP_PHASE
     , CREATED_TIME
     , MODIFIED_TIME
     , COMMENTS
)
AS 
SELECT 
       TABLE_OWNER
     , TABLE_SCHEMA
     , TABLE_NAME
     , STARTUP_PHASE
     , CREATED_TIME
     , MODIFIED_TIME
     , COMMENTS
  FROM           
       PERFORMANCE_VIEW_SCHEMA.GV$TABLES@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$TABLES 
        IS 'The V$TABLES contains the definitions of all the performance views (views beginning with V$).';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLES.TABLE_OWNER
        IS 'owner name who owns the performance view';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLES.TABLE_SCHEMA
        IS 'schema name of the performance view';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLES.TABLE_NAME
        IS 'name of the performance view';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLES.STARTUP_PHASE
        IS 'visible startup phase of the performance view';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLES.CREATED_TIME
        IS 'created time of the performance view';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLES.MODIFIED_TIME
        IS 'modified time of the performance view';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLES.COMMENTS
        IS 'comments of the performance view';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$TABLES TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$TABLES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$TABLES;
CREATE PUBLIC SYNONYM GV$TABLES FOR PERFORMANCE_VIEW_SCHEMA.GV$TABLES;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$TABLES;
CREATE PUBLIC SYNONYM V$TABLES FOR PERFORMANCE_VIEW_SCHEMA.V$TABLES;
COMMIT;

--##############################################################
--# V$TABLESPACE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$TABLESPACE;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$TABLESPACE
(  
       ORIGIN_MEMBER_NAME
     , TBS_NAME
     , TBS_ID
     , TBS_ATTR
     , IS_LOGGING
     , IS_ONLINE
     , OFFLINE_STATE
     , EXTENT_SIZE
     , PAGE_SIZE
)
AS 
SELECT
       tbs.CLUSTER_MEMBER_NAME
     , CAST( tbs.NAME AS VARCHAR(128 OCTETS) )            -- TBS_NAME
     , CAST( tbs.ID AS NUMBER )                           -- TBS_ID
     , CAST( tbs.ATTR AS VARCHAR(128 OCTETS) )            -- TBS_ATTR
     , tbs.LOGGING                                        -- IS_LOGGING
     , tbs.ONLINE                                         -- IS_ONLINE
     , CAST( tbs.OFFLINE_STATE AS VARCHAR(32 OCTETS) )    -- OFFLINE_STATE
     , CAST( tbs.EXTSIZE AS NUMBER )                      -- EXTENT_SIZE
     , CAST( tbs.PAGE_SIZE AS NUMBER )                    -- PAGE_SIZE
  FROM 
       FIXED_TABLE_SCHEMA.X$TABLESPACE@GLOBAL[IGNORE_INACTIVE_MEMBER] AS tbs
  WHERE tbs.STATE = 'CREATED'
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE
(  
       TBS_NAME
     , TBS_ID
     , TBS_ATTR
     , IS_LOGGING
     , IS_ONLINE
     , OFFLINE_STATE
     , EXTENT_SIZE
     , PAGE_SIZE
)
AS 
SELECT 
       TBS_NAME
     , TBS_ID
     , TBS_ATTR
     , IS_LOGGING
     , IS_ONLINE
     , OFFLINE_STATE
     , EXTENT_SIZE
     , PAGE_SIZE
  FROM             
       PERFORMANCE_VIEW_SCHEMA.GV$TABLESPACE@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE
        IS 'This view displays tablespace information.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE.TBS_NAME
        IS 'tablespace name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE.TBS_ID
        IS 'tablespace identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE.TBS_ATTR
        IS 'tablespace attribute: the value in ( device attribute (MEMORY) | temporary attribute (TEMPORARY, PERSISTENT) | usage attribute(DICT, UNDO, DATA, TEMPORARY) )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE.IS_LOGGING
        IS 'indicates whether the tablespace is a logging tablespace ( YES ) or not ( NO )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE.IS_ONLINE
        IS 'indicates whether the tablespace is ONLINE ( YES ) or OFFLINE ( NO )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE.OFFLINE_STATE
        IS 'indicates whether the tablespace can be taken online normally ( CONSISTENT ) or not ( INCONSISTENT ). null if the tablespace is ONLINE';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE.EXTENT_SIZE
        IS 'extent size of the tablespace ( in bytes )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE.PAGE_SIZE
        IS 'page size of the tablespace ( in bytes )';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$TABLESPACE TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$TABLESPACE;
CREATE PUBLIC SYNONYM GV$TABLESPACE FOR PERFORMANCE_VIEW_SCHEMA.GV$TABLESPACE;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$TABLESPACE;
CREATE PUBLIC SYNONYM V$TABLESPACE FOR PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE;
COMMIT;

--##############################################################
--# V$TABLESPACE_STAT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$TABLESPACE_STAT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE_STAT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$TABLESPACE_STAT
(  
       ORIGIN_MEMBER_NAME
     , TBS_NAME
     , TBS_ID
     , TOTAL_EXT_COUNT
     , USED_META_EXT_COUNT
     , USED_DATA_EXT_COUNT
     , FREE_EXT_COUNT
     , EXTENT_SIZE
)
AS 
SELECT
       tbs.CLUSTER_MEMBER_NAME
     , CAST( tbs.NAME AS VARCHAR(128 OCTETS) )         -- TBS_NAME
     , CAST( tbs_stat.TBS_ID AS NUMBER )               -- TBS_ID
     , CAST( tbs_stat.TOTAL_EXT_COUNT AS NUMBER )      -- TOTAL_EXT_COUNT
     , CAST( tbs_stat.USED_META_EXT_COUNT AS NUMBER )  -- USED_META_EXT_COUNT
     , CAST( tbs_stat.USED_DATA_EXT_COUNT AS NUMBER )  -- USED_DATA_EXT_COUNT
     , CAST( tbs_stat.FREE_EXT_COUNT AS NUMBER )       -- FREE_EXT_COUNT
     , CAST( tbs_stat.EXT_SIZE AS NUMBER )             -- EXTENT_SIZE
  FROM 
       FIXED_TABLE_SCHEMA.X$TABLESPACE@GLOBAL[IGNORE_INACTIVE_MEMBER]      AS tbs
     , FIXED_TABLE_SCHEMA.X$TABLESPACE_STAT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS tbs_stat
  WHERE tbs.ID = tbs_stat.TBS_ID
    AND tbs.CLUSTER_MEMBER_ID = tbs_stat.CLUSTER_MEMBER_ID
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE_STAT
(  
       TBS_NAME
     , TBS_ID
     , TOTAL_EXT_COUNT
     , USED_META_EXT_COUNT
     , USED_DATA_EXT_COUNT
     , FREE_EXT_COUNT
     , EXTENT_SIZE
)
AS 
SELECT 
       TBS_NAME
     , TBS_ID
     , TOTAL_EXT_COUNT
     , USED_META_EXT_COUNT
     , USED_DATA_EXT_COUNT
     , FREE_EXT_COUNT
     , EXTENT_SIZE
  FROM             
       PERFORMANCE_VIEW_SCHEMA.GV$TABLESPACE_STAT@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE_STAT
        IS 'This view displays tablespace statistical information.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE_STAT.TBS_NAME
        IS 'tablespace name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE_STAT.TBS_ID
        IS 'tablespace identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE_STAT.TOTAL_EXT_COUNT
        IS 'total extent count of the tablespace';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE_STAT.USED_META_EXT_COUNT
        IS 'meta extent count currently used on the tablespace';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE_STAT.USED_DATA_EXT_COUNT
        IS 'data extent count currently used on the tablespace';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE_STAT.FREE_EXT_COUNT
        IS 'free extent count of the tablespace';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE_STAT.EXTENT_SIZE
        IS 'extent size of the tablespace ( in bytes )';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$TABLESPACE_STAT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE_STAT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$TABLESPACE_STAT;
CREATE PUBLIC SYNONYM GV$TABLESPACE_STAT FOR PERFORMANCE_VIEW_SCHEMA.GV$TABLESPACE_STAT;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$TABLESPACE_STAT;
CREATE PUBLIC SYNONYM V$TABLESPACE_STAT FOR PERFORMANCE_VIEW_SCHEMA.V$TABLESPACE_STAT;
COMMIT;

--##############################################################
--# V$TRANSACTION
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$TRANSACTION;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$TRANSACTION
(  
       ORIGIN_MEMBER_NAME
     , TRANS_ID
     , SESSION_ID
     , TRANS_SLOT_ID
     , PHYSICAL_TRANS_ID
     , TRANS_STATE
     , IS_XA
     , TRANS_ATTRIBUTE
     , ISOLATION_LEVEL
     , TRANS_VIEW_SCN
     , TCN
     , TRANS_SEQ
     , START_TIME
)
AS 
SELECT
       xtrans.CLUSTER_MEMBER_NAME
     , CAST( xtrans.LOGICAL_TRANS_ID AS NUMBER )       -- TRANS_ID
     , CAST( xsess.ID AS NUMBER )                      -- SESSION_ID
     , CAST( xtrans.SLOT_ID AS NUMBER )                -- TRANS_SLOT_ID
     , CAST( xtrans.PHYSICAL_TRANS_ID AS NUMBER )      -- PHYSICAL_TRANS_ID
     , CAST( xtrans.STATE AS VARCHAR(32 OCTETS) )      -- TRANS_STATE
     , xtrans.IS_XA                                    -- IS_XA
     , CAST( xtrans.ATTRIBUTE AS VARCHAR(32 OCTETS) )  -- TRANS_ATTRIBUTE
     , CAST( xtrans.ISOLATION_LEVEL AS VARCHAR(32 OCTETS) ) -- ISOLATION_LEVEL
     , CAST( xtrans.VIEW_SCN AS VARCHAR(32 OCTETS) )   -- TRANS_VIEW_SCN
     , CAST( xtrans.TCN AS NUMBER )                    -- TCN
     , CAST( xtrans.SEQ AS NUMBER )                    -- TRANS_SEQ
     , xtrans.BEGIN_TIME                               -- START_TIME
  FROM 
       FIXED_TABLE_SCHEMA.X$TRANSACTION@GLOBAL[IGNORE_INACTIVE_MEMBER] AS xtrans   
       LEFT OUTER JOIN   
       FIXED_TABLE_SCHEMA.X$SESSION@GLOBAL[IGNORE_INACTIVE_MEMBER] AS xsess   
       ON  xtrans.LOGICAL_TRANS_ID = xsess.TRANS_ID
       AND xtrans.CLUSTER_MEMBER_ID = xsess.CLUSTER_MEMBER_ID
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION
(  
       TRANS_ID
     , SESSION_ID
     , TRANS_SLOT_ID
     , PHYSICAL_TRANS_ID
     , TRANS_STATE
     , IS_XA
     , TRANS_ATTRIBUTE
     , ISOLATION_LEVEL
     , TRANS_VIEW_SCN
     , TCN
     , TRANS_SEQ
     , START_TIME
)
AS 
SELECT 
       TRANS_ID
     , SESSION_ID
     , TRANS_SLOT_ID
     , PHYSICAL_TRANS_ID
     , TRANS_STATE
     , IS_XA
     , TRANS_ATTRIBUTE
     , ISOLATION_LEVEL
     , TRANS_VIEW_SCN
     , TCN
     , TRANS_SEQ
     , START_TIME
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$TRANSACTION@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION
        IS 'The V$TRANSACTION lists the active transactions in the system.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION.TRANS_ID
        IS 'transaction identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION.SESSION_ID
        IS 'session identifier ( null if the global transaction is unassociated )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION.TRANS_SLOT_ID
        IS 'transaction slot identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION.PHYSICAL_TRANS_ID
        IS 'physical transaction identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION.TRANS_STATE
        IS 'transaction state: the value in ( ACTIVE, BLOCK, PREPARE, COMMIT, ROLLBACK, IDLE, PRECOMMIT )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION.IS_XA
        IS 'indicates whether the transaction is xa transaction or not';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION.TRANS_ATTRIBUTE
        IS 'transaction attribute: the value in ( READ_ONLY, UPDATABLE, LOCKABLE, UPDATABLE | LOCKABLE )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION.ISOLATION_LEVEL
        IS 'transaction isolation level: the value in ( READ COMMITTED, SERIALIZABLE )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION.TRANS_VIEW_SCN
        IS 'transaction view scn';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION.TCN
        IS 'transaction change number';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION.TRANS_SEQ
        IS 'transaction sequence number';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION.START_TIME
        IS 'transaction start time';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$TRANSACTION TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$TRANSACTION;
CREATE PUBLIC SYNONYM GV$TRANSACTION FOR PERFORMANCE_VIEW_SCHEMA.GV$TRANSACTION;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$TRANSACTION;
CREATE PUBLIC SYNONYM V$TRANSACTION FOR PERFORMANCE_VIEW_SCHEMA.V$TRANSACTION;
COMMIT;

--##############################################################
--# V$INSTANCE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$INSTANCE;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$INSTANCE;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$INSTANCE
(  
       ORIGIN_MEMBER_NAME
     , RELEASE_VERSION
     , STARTUP_TIME
     , INSTANCE_STATUS
     , DATA_ACCESS_MODE
)
AS 
SELECT 
       inst.CLUSTER_MEMBER_NAME
     , inst.VERSION            -- RELEASE_VERSION
     , inst.STARTUP_TIME       -- STARTUP_TIME
     , inst.STATUS             -- INSTANCE_STATUS
     , CAST( CASE WHEN ( inst.STATUS = 'OPEN' ) = FALSE
                       THEN 'NONE'
                  ELSE ( CASE WHEN ( SELECT VALUE
                                       FROM FIXED_TABLE_SCHEMA.X$SM_SYSTEM_INFO xsys
                                      WHERE NAME = 'DATA_ACCESS_MODE'
                                        AND xsys.CLUSTER_MEMBER_ID = inst.CLUSTER_MEMBER_ID ) = 1
                                   THEN 'READ_ONLY'
                              ELSE 'READ_WRITE'
                         END )
             END AS VARCHAR(16 OCTETS) )  -- DATA_ACCESS_MODE
  FROM 
       FIXED_TABLE_SCHEMA.X$INSTANCE@GLOBAL[IGNORE_INACTIVE_MEMBER] AS inst
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$INSTANCE
(  
       RELEASE_VERSION
     , STARTUP_TIME
     , INSTANCE_STATUS
     , DATA_ACCESS_MODE
)
AS 
SELECT 
       RELEASE_VERSION
     , STARTUP_TIME
     , INSTANCE_STATUS
     , DATA_ACCESS_MODE
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$INSTANCE@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$INSTANCE
        IS 'This view displays the state of the current instance.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$INSTANCE.RELEASE_VERSION
        IS 'release version';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$INSTANCE.STARTUP_TIME
        IS 'time when the instance was started';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$INSTANCE.INSTANCE_STATUS
        IS 'status of the instance: the value in ( STARTED, MOUNTED, OPEN )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$INSTANCE.DATA_ACCESS_MODE
        IS 'data access mode of the instance: the value in ( NONE, READ_ONLY, READ_WRITE )';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$INSTANCE TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$INSTANCE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$INSTANCE;
CREATE PUBLIC SYNONYM GV$INSTANCE FOR PERFORMANCE_VIEW_SCHEMA.GV$INSTANCE;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$INSTANCE;
CREATE PUBLIC SYNONYM V$INSTANCE FOR PERFORMANCE_VIEW_SCHEMA.V$INSTANCE;
COMMIT;

--##############################################################
--# V$CONTROLFILE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$CONTROLFILE;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$CONTROLFILE;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$CONTROLFILE
(  
       ORIGIN_MEMBER_NAME
     , STATUS
     , CONTROLFILE_NAME
     , LAST_CHECKPOINT_LSN
     , IS_PRIMARY
     , CREATION_TIME
)
AS 
SELECT 
       ctrl.CLUSTER_MEMBER_NAME
     , ctrl.CONTROLFILE_STATE                 -- STATUS
     , ctrl.CONTROLFILE_NAME                  -- CONTROLFILE_NAME
     , CAST( ctrl.CHECKPOINT_LSN AS NUMBER )  -- LAST_CHECKPOINT_LSN
     , ctrl.IS_PRIMARY                        -- IS_PRIMARY
     , ctrl.CREATION_TIME                     -- CREATION_TIME
  FROM 
       FIXED_TABLE_SCHEMA.X$CONTROLFILE@GLOBAL[IGNORE_INACTIVE_MEMBER] AS ctrl
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$CONTROLFILE
(  
       STATUS
     , CONTROLFILE_NAME
     , LAST_CHECKPOINT_LSN
     , IS_PRIMARY
     , CREATION_TIME
)
AS 
SELECT 
       STATUS
     , CONTROLFILE_NAME
     , LAST_CHECKPOINT_LSN
     , IS_PRIMARY
     , CREATION_TIME
  FROM  
       GV$CONTROLFILE@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$CONTROLFILE
        IS 'This view displays information about controlfiles.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CONTROLFILE.STATUS
        IS 'controlfile status ( valid, invalid )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CONTROLFILE.CONTROLFILE_NAME
        IS 'controlfile name ( absolute path )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CONTROLFILE.LAST_CHECKPOINT_LSN
        IS 'the last checkpoint lsn';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CONTROLFILE.IS_PRIMARY
        IS 'indicates whether the controlfile is primary';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CONTROLFILE.CREATION_TIME
        IS 'timestamp of the database creation';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$CONTROLFILE TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$CONTROLFILE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$CONTROLFILE;
CREATE PUBLIC SYNONYM GV$CONTROLFILE FOR PERFORMANCE_VIEW_SCHEMA.GV$CONTROLFILE;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$CONTROLFILE;
CREATE PUBLIC SYNONYM V$CONTROLFILE FOR PERFORMANCE_VIEW_SCHEMA.V$CONTROLFILE;
COMMIT;

--##############################################################
--# V$DB_FILE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$DB_FILE;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$DB_FILE;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$DB_FILE
(  
       ORIGIN_MEMBER_NAME
     , FILE_NAME
     , FILE_TYPE
)
AS 
SELECT 
       dbf.CLUSTER_MEMBER_NAME
     , CAST( dbf.PATH AS VARCHAR(1024 OCTETS) )        -- FILE_NAME
     , CAST( dbf.TYPE AS VARCHAR(16 OCTETS) )          -- FILE_TYPE
  FROM 
       FIXED_TABLE_SCHEMA.X$DB_FILE@GLOBAL[IGNORE_INACTIVE_MEMBER] AS dbf
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$DB_FILE
(  
       FILE_NAME
     , FILE_TYPE
)
AS 
SELECT 
       FILE_NAME
     , FILE_TYPE
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$DB_FILE@LOCAL
;


--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$DB_FILE
        IS 'The V$DB_FILE displays a list of all files using in database';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DB_FILE.FILE_NAME
        IS 'file name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DB_FILE.FILE_TYPE
        IS 'file type';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$DB_FILE TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$DB_FILE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$DB_FILE;
CREATE PUBLIC SYNONYM GV$DB_FILE FOR PERFORMANCE_VIEW_SCHEMA.GV$DB_FILE;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$DB_FILE;
CREATE PUBLIC SYNONYM V$DB_FILE FOR PERFORMANCE_VIEW_SCHEMA.V$DB_FILE;
COMMIT;

--##############################################################
--# V$SHARED_MODE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SHARED_MODE;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SHARED_MODE;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SHARED_MODE
(  
       ORIGIN_MEMBER_NAME
     , NAME
     , VALUE
)
AS 
SELECT 
       shm.CLUSTER_MEMBER_NAME
     , CAST( shm.NAME AS VARCHAR(128 OCTETS) )    -- NAME
     , CAST( 'NO' AS VARCHAR(128 OCTETS) )        -- VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SL_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS shm
  WHERE shm.NAME = 'SHARED_SERVER_ACTIVITY' AND shm.VALUE = 0
UNION ALL
SELECT 
       shm.CLUSTER_MEMBER_NAME
     , CAST( shm.NAME AS VARCHAR(128 OCTETS) )    -- NAME
     , CAST( 'YES' AS VARCHAR(128 OCTETS) )       -- VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SL_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS shm
  WHERE shm.NAME = 'SHARED_SERVER_ACTIVITY' AND shm.VALUE = 1
UNION ALL
SELECT 
       shm.CLUSTER_MEMBER_NAME
     , CAST( shm.NAME AS VARCHAR(128 OCTETS) )    -- NAME
     , CAST( shm.VALUE AS VARCHAR(128 OCTETS) )   -- VALUE
  FROM 
       FIXED_TABLE_SCHEMA.X$SL_SYSTEM_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS shm
  WHERE shm.NAME != 'SHARED_SERVER_ACTIVITY'
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SHARED_MODE
(  
       NAME
     , VALUE
)
AS 
SELECT 
       NAME
     , VALUE
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$SHARED_MODE@LOCAL
;
      
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SHARED_MODE
        IS 'The V$SHARED_MODE displays information of shared mode.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SHARED_MODE.NAME
        IS 'name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SHARED_MODE.VALUE
        IS 'value';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SHARED_MODE TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SHARED_MODE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SHARED_MODE;
CREATE PUBLIC SYNONYM GV$SHARED_MODE FOR PERFORMANCE_VIEW_SCHEMA.GV$SHARED_MODE;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SHARED_MODE;
CREATE PUBLIC SYNONYM V$SHARED_MODE FOR PERFORMANCE_VIEW_SCHEMA.V$SHARED_MODE;
COMMIT;

--##############################################################
--# V$DISPATCHER
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$DISPATCHER;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$DISPATCHER
(  
       ORIGIN_MEMBER_NAME
     , PROCESS_ID
     , RESPONSE_JOB_COUNT
     , ACCEPT
     , START_TIME
     , CUR_CONNECTIONS
     , CONNECTIONS
     , CONNECTIONS_HIGHWATER
     , MAX_CONNECTIONS
     , RECV_STATUS
     , RECV_BYTES
     , RECV_UNITS
     , RECV_IDLE
     , RECV_BUSY
     , SEND_STATUS
     , SEND_BYTES
     , SEND_UNITS
     , SEND_IDLE
     , SEND_BUSY
     , SEND_ACK_FAIL_COUNT
     , TCP_SEND_BUFFER_FULL_COUNT
     , DISPATCHER_ID
     , REQUEST_GROUP_ID
)
AS 
SELECT 
       dsptr.CLUSTER_MEMBER_NAME
     , CAST( dsptr.PROCESS_ID AS NUMBER )               -- PROCESS_ID
     , CAST( dsptr.RESPONSE_JOB_COUNT AS NUMBER )       -- RESPONSE_JOB_COUNT
     , CAST( dsptr.ACCEPT AS BOOLEAN )                  -- ACCEPT
     , CAST( dsptr.START_TIME AS TIMESTAMP )            -- START_TIME
     , CAST( dsptr.CUR_CONNECTIONS AS NUMBER )          -- CUR_CONNECTIONS
     , CAST( dsptr.CONNECTIONS AS NUMBER )              -- CONNECTIONS
     , CAST( dsptr.CONNECTIONS_HIGHWATER AS NUMBER )    -- CONNECTIONS_HIGHWATER
     , CAST( dsptr.MAX_CONNECTIONS AS NUMBER )          -- MAX_CONNECTIONS
     , CAST( dsptr.RECV_STATUS AS VARCHAR(16 OCTETS) )  -- RECV_STATUS
     , CAST( dsptr.RECV_BYTES AS NUMBER )               -- RECV_BYTES
     , CAST( dsptr.RECV_UNITS AS NUMBER )               -- RECV_UNITS
     , CAST( dsptr.RECV_IDLE AS NUMBER )                -- RECV_IDLE
     , CAST( dsptr.RECV_BUSY AS NUMBER )                -- RECV_BUSY
     , CAST( dsptr.SEND_STATUS AS VARCHAR(16 OCTETS) )  -- SEND_STATUS
     , CAST( dsptr.SEND_BYTES AS NUMBER )               -- SEND_BYTES
     , CAST( dsptr.SEND_UNITS AS NUMBER )               -- SEND_UNITS
     , CAST( dsptr.SEND_IDLE AS NUMBER )                -- SEND_IDLE
     , CAST( dsptr.SEND_BUSY AS NUMBER )                -- SEND_BUSY
     , CAST( dsptr.SEND_ACK_FAIL_COUNT AS NUMBER )      -- SEND_ACK_FAIL_COUNT
     , CAST( dsptr.TCP_SEND_BUFFER_FULL_COUNT AS NUMBER )  -- TCP_SEND_BUFFER_FULL_COUNT
     , CAST( dsptr.DISPATCHER_ID AS NUMBER )            -- DISPATCHER_ID
     , CAST( dsptr.REQUEST_GROUP_ID AS NUMBER )         -- REQUEST_GROUP_ID
  FROM 
       FIXED_TABLE_SCHEMA.X$DISPATCHER@GLOBAL[IGNORE_INACTIVE_MEMBER] AS dsptr
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER
(  
       PROCESS_ID
     , RESPONSE_JOB_COUNT
     , ACCEPT
     , START_TIME
     , CUR_CONNECTIONS
     , CONNECTIONS
     , CONNECTIONS_HIGHWATER
     , MAX_CONNECTIONS
     , RECV_STATUS
     , RECV_BYTES
     , RECV_UNITS
     , RECV_IDLE
     , RECV_BUSY
     , SEND_STATUS
     , SEND_BYTES
     , SEND_UNITS
     , SEND_IDLE
     , SEND_BUSY
     , SEND_ACK_FAIL_COUNT
     , TCP_SEND_BUFFER_FULL_COUNT
     , DISPATCHER_ID
     , REQUEST_GROUP_ID
)
AS 
SELECT 
       PROCESS_ID
     , RESPONSE_JOB_COUNT
     , ACCEPT
     , START_TIME
     , CUR_CONNECTIONS
     , CONNECTIONS
     , CONNECTIONS_HIGHWATER
     , MAX_CONNECTIONS
     , RECV_STATUS
     , RECV_BYTES
     , RECV_UNITS
     , RECV_IDLE
     , RECV_BUSY
     , SEND_STATUS
     , SEND_BYTES
     , SEND_UNITS
     , SEND_IDLE
     , SEND_BUSY
     , SEND_ACK_FAIL_COUNT
     , TCP_SEND_BUFFER_FULL_COUNT
     , DISPATCHER_ID
     , REQUEST_GROUP_ID
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$DISPATCHER@LOCAL
;
             
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER
        IS 'The V$DISPATCHER displays information of dispatchers.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.PROCESS_ID
        IS 'dispatcher process identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.RESPONSE_JOB_COUNT
        IS 'response job count';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.ACCEPT
        IS 'indicates whether this dispatcher is accepting new connections';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.START_TIME
        IS 'process start time';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.CUR_CONNECTIONS
        IS 'current number of connections';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.CONNECTIONS
        IS 'total number of connections';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.CONNECTIONS_HIGHWATER
        IS 'highest number of connections';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.MAX_CONNECTIONS
        IS 'maximum connections';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.RECV_STATUS
        IS 'receive status';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.RECV_BYTES
        IS 'total bytes of received';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.RECV_UNITS
        IS 'total units of received';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.RECV_IDLE
        IS 'total idle time of receive (1/100 second)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.RECV_BUSY
        IS 'total busy time of receive (1/100 second)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.SEND_STATUS
        IS 'send status';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.SEND_BYTES
        IS 'total bytes of sent';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.SEND_UNITS
        IS 'total units of sent';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.SEND_IDLE
        IS 'total idle time of send (1/100 second)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.SEND_BUSY
        IS 'total busy time of send (1/100 second)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.SEND_ACK_FAIL_COUNT
        IS 'send ack failure count';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.TCP_SEND_BUFFER_FULL_COUNT
        IS 'tcp socket send buffer full count';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.DISPATCHER_ID
        IS 'dispatcher id';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER.REQUEST_GROUP_ID
        IS 'request group id';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$DISPATCHER TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$DISPATCHER;
CREATE PUBLIC SYNONYM GV$DISPATCHER FOR PERFORMANCE_VIEW_SCHEMA.GV$DISPATCHER;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$DISPATCHER;
CREATE PUBLIC SYNONYM V$DISPATCHER FOR PERFORMANCE_VIEW_SCHEMA.V$DISPATCHER;
COMMIT;

--##############################################################
--# V$SHARED_SERVER
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SHARED_SERVER;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SHARED_SERVER;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SHARED_SERVER
(  
       ORIGIN_MEMBER_NAME
     , PROCESS_ID
     , PROCESSED_JOB_COUNT
     , STATUS
     , IDLE
     , BUSY
     , REQUEST_GROUP_ID
)
AS 
SELECT 
       shsvr.CLUSTER_MEMBER_NAME
     , CAST( shsvr.PROCESS_ID AS NUMBER )           -- PROCESS_ID
     , CAST( shsvr.PROCESSED_JOB_COUNT AS NUMBER )  -- PROCESSED_JOB_COUNT
     , CAST( shsvr.STATUS AS VARCHAR(16 OCTETS) )   -- STATUS
     , CAST( shsvr.IDLE AS NUMBER )                 -- IDLE
     , CAST( shsvr.BUSY AS NUMBER )                 -- BUSY
     , CAST( shsvr.REQUEST_GROUP_ID AS NUMBER )     -- REQUEST_GROUP_ID
     
  FROM 
       FIXED_TABLE_SCHEMA.X$SHARED_SERVER@GLOBAL[IGNORE_INACTIVE_MEMBER] AS shsvr
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SHARED_SERVER
(  
       PROCESS_ID
     , PROCESSED_JOB_COUNT
     , STATUS
     , IDLE
     , BUSY
     , REQUEST_GROUP_ID
)
AS 
SELECT 
       PROCESS_ID
     , PROCESSED_JOB_COUNT
     , STATUS
     , IDLE
     , BUSY
     , REQUEST_GROUP_ID
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$SHARED_SERVER@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SHARED_SERVER
        IS 'The V$SHARED_SERVER displays information of shared servers.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SHARED_SERVER.PROCESS_ID
        IS 'shared server process identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SHARED_SERVER.PROCESSED_JOB_COUNT
        IS 'processed job count';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SHARED_SERVER.STATUS
        IS 'status';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SHARED_SERVER.IDLE
        IS 'total idle time (1/100 second)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SHARED_SERVER.BUSY
        IS 'total busy time (1/100 second)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SHARED_SERVER.REQUEST_GROUP_ID
        IS 'request group id';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SHARED_SERVER TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SHARED_SERVER TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SHARED_SERVER;
CREATE PUBLIC SYNONYM GV$SHARED_SERVER FOR PERFORMANCE_VIEW_SCHEMA.GV$SHARED_SERVER;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SHARED_SERVER;
CREATE PUBLIC SYNONYM V$SHARED_SERVER FOR PERFORMANCE_VIEW_SCHEMA.V$SHARED_SERVER;
COMMIT;

--##############################################################
--# V$BALANCER
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$BALANCER;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$BALANCER;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$BALANCER
(  
       ORIGIN_MEMBER_NAME
     , PROCESS_ID
     , CUR_CONNECTIONS
     , CONNECTIONS
     , CONNECTIONS_HIGHWATER
     , MAX_CONNECTIONS
     , STATUS
     , FORWARD_FD_FAIL_COUNT
     , SEND_ACK_FAIL_COUNT
)
AS 
SELECT
       blcr.CLUSTER_MEMBER_NAME
     , CAST( blcr.PROCESS_ID AS NUMBER )            -- PROCESS_ID
     , CAST( blcr.CUR_CONNECTIONS AS NUMBER )       -- CUR_CONNECTIONS
     , CAST( blcr.CONNECTIONS AS NUMBER )           -- CONNECTIONS
     , CAST( blcr.CONNECTIONS_HIGHWATER AS NUMBER ) -- CONNECTIONS_HIGHWATER
     , CAST( blcr.MAX_CONNECTIONS AS NUMBER )       -- MAX_CONNECTIONS
     , CAST( blcr.STATUS AS VARCHAR(16 OCTETS) )    -- STATUS
     , CAST( blcr.FORWARD_FD_FAIL_COUNT AS NUMBER ) -- FORWARD_FD_FAIL_COUNT
     , CAST( blcr.SEND_ACK_FAIL_COUNT AS NUMBER )   -- SEND_ACK_FAIL_COUNT
  FROM 
       FIXED_TABLE_SCHEMA.X$BALANCER@GLOBAL[IGNORE_INACTIVE_MEMBER] AS blcr
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$BALANCER
(  
       PROCESS_ID
     , CUR_CONNECTIONS
     , CONNECTIONS
     , CONNECTIONS_HIGHWATER
     , MAX_CONNECTIONS
     , STATUS
     , FORWARD_FD_FAIL_COUNT
     , SEND_ACK_FAIL_COUNT
)
AS 
SELECT 
       PROCESS_ID
     , CUR_CONNECTIONS
     , CONNECTIONS
     , CONNECTIONS_HIGHWATER
     , MAX_CONNECTIONS
     , STATUS
     , FORWARD_FD_FAIL_COUNT
     , SEND_ACK_FAIL_COUNT
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$BALANCER@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$BALANCER
        IS 'The V$BALANCER displays information of balancer.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BALANCER.PROCESS_ID
        IS 'balancer process identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BALANCER.CUR_CONNECTIONS
        IS 'current number of connections';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BALANCER.CONNECTIONS
        IS 'total number of connections';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BALANCER.CONNECTIONS_HIGHWATER
        IS 'highest number of connections';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BALANCER.MAX_CONNECTIONS
        IS 'maximum connections';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BALANCER.STATUS
        IS 'status';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BALANCER.FORWARD_FD_FAIL_COUNT
        IS 'forward fd failure count';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BALANCER.SEND_ACK_FAIL_COUNT
        IS 'send ack failure count';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$BALANCER TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$BALANCER TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$BALANCER;
CREATE PUBLIC SYNONYM GV$BALANCER FOR PERFORMANCE_VIEW_SCHEMA.GV$BALANCER;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$BALANCER;
CREATE PUBLIC SYNONYM V$BALANCER FOR PERFORMANCE_VIEW_SCHEMA.V$BALANCER;
COMMIT;

--##############################################################
--# V$QUEUE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$QUEUE;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$QUEUE;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$QUEUE
(  
       ORIGIN_MEMBER_NAME
     , TYPE
     , INDEX
     , QUEUED
     , WAIT
     , FULL_COUNT
     , TOTALQ
     , ENQUEUE_CONTENTION_COUNT
     , DEQUEUE_CONTENTION_COUNT
)
AS 
SELECT 
       queue.CLUSTER_MEMBER_NAME
     , CAST( queue.TYPE AS VARCHAR(16 OCTETS) ) -- TYPE
     , CAST( queue.INDEX AS NUMBER )            -- INDEX
     , CAST( SUM(queue.QUEUED) AS NUMBER )      -- QUEUED
     , CAST( SUM(queue.WAIT) AS NUMBER )        -- WAIT
     , CAST( SUM(queue.FULL_COUNT) AS NUMBER )  -- FULL_COUNT
     , CAST( SUM(queue.TOTALQ) AS NUMBER )      -- TOTALQ
     , CAST( SUM(queue.ENQUEUE_CONTENTION_COUNT) AS NUMBER )  -- ENQUEUE_CONTENTION_COUNT
     , CAST( SUM(queue.DEQUEUE_CONTENTION_COUNT) AS NUMBER )  -- DEQUEUE_CONTENTION_COUNT
  FROM 
       FIXED_TABLE_SCHEMA.X$QUEUE@GLOBAL[IGNORE_INACTIVE_MEMBER] AS queue
 GROUP BY 
       queue.CLUSTER_MEMBER_NAME
     , queue.TYPE
     , queue.INDEX
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$QUEUE
(  
       TYPE
     , INDEX
     , QUEUED
     , WAIT
     , FULL_COUNT
     , TOTALQ
     , ENQUEUE_CONTENTION_COUNT
     , DEQUEUE_CONTENTION_COUNT
)
AS 
SELECT 
       TYPE
     , INDEX
     , QUEUED
     , WAIT
     , FULL_COUNT
     , TOTALQ
     , ENQUEUE_CONTENTION_COUNT
     , DEQUEUE_CONTENTION_COUNT
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$QUEUE@LOCAL
;
      
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$QUEUE
        IS 'The V$QUEUE displays information of queue.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$QUEUE.TYPE
        IS 'queue type ( COMMON or DISPATCHER )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$QUEUE.INDEX
        IS 'index';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$QUEUE.QUEUED
        IS 'number of items in the queue';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$QUEUE.WAIT
        IS 'total time that all items in this queue have waited (1/100 second)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$QUEUE.FULL_COUNT
        IS 'total full count in the queue';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$QUEUE.TOTALQ
        IS 'total number of items that have ever been in the queue';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$QUEUE.ENQUEUE_CONTENTION_COUNT
        IS 'number of enqueue contentions';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$QUEUE.DEQUEUE_CONTENTION_COUNT
        IS 'number of dequeue contentions';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$QUEUE TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$QUEUE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$QUEUE;
CREATE PUBLIC SYNONYM GV$QUEUE FOR PERFORMANCE_VIEW_SCHEMA.GV$QUEUE;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$QUEUE;
CREATE PUBLIC SYNONYM V$QUEUE FOR PERFORMANCE_VIEW_SCHEMA.V$QUEUE;
COMMIT;

--##############################################################
--# V$JOURNALING
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$JOURNALING;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$JOURNALING;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$JOURNALING
(  
       ORIGIN_MEMBER_NAME
     , TABLE_NAME
     , SHARD_ID
     , RECORD_COUNT
     , TOTAL_SIZE
)
AS 
SELECT 
       journaling.CLUSTER_MEMBER_NAME
     , tab.TABLE_NAME                                      -- TABLE_NAME
     , CAST( journaling.SHARD_ID AS NUMBER )               -- SHARD_ID
     , CAST( journaling.RECORD_COUNT AS NUMBER )           -- RECORD_COUNT
     , CAST( journaling.WRITTEN_LENGTH AS NUMBER )         -- TOTAL_SIZE
  FROM 
       FIXED_TABLE_SCHEMA.X$GLOBAL_JOURNALING@GLOBAL[IGNORE_INACTIVE_MEMBER] AS journaling
     , DEFINITION_SCHEMA.TABLES@GLOBAL[IGNORE_INACTIVE_MEMBER]               AS tab 
 WHERE  
       journaling.SEGMENT_ID        = tab.PHYSICAL_ID
   AND journaling.CLUSTER_MEMBER_ID = tab.CLUSTER_MEMBER_ID
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$JOURNALING
(  
       TABLE_NAME
     , SHARD_ID
     , RECORD_COUNT
     , TOTAL_SIZE
)
AS 
SELECT 
       TABLE_NAME
     , SHARD_ID
     , RECORD_COUNT
     , TOTAL_SIZE
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$JOURNALING@LOCAL
;
      
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$JOURNALING
        IS 'The V$JOURNALING displays journaling information.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$JOURNALING.TABLE_NAME
        IS 'table name ';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$JOURNALING.SHARD_ID
        IS 'shard identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$JOURNALING.RECORD_COUNT
        IS 'journaled record count';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$JOURNALING.TOTAL_SIZE
        IS 'total size of journaled records (byte)';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$JOURNALING TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$JOURNALING TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$JOURNALING;
CREATE PUBLIC SYNONYM GV$JOURNALING FOR PERFORMANCE_VIEW_SCHEMA.GV$JOURNALING;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$JOURNALING;
CREATE PUBLIC SYNONYM V$JOURNALING FOR PERFORMANCE_VIEW_SCHEMA.V$JOURNALING;
COMMIT;

--##############################################################
--# V$CLUSTER_MEMBER
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$CLUSTER_MEMBER;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_MEMBER;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$CLUSTER_MEMBER
(  
       MEMBER_ID
     , MEMBER_POSITION
     , STATUS
     , IS_GLOBAL_COORD
     , IS_GROUP_COORD
)
AS 
SELECT 
       CAST( cluster_member.MEMBER_ID AS NUMBER )          -- MEMBER_ID
     , CAST( cluster_member.MEMBER_POSITION AS NUMBER )    -- MEMBER_POSITION
     , cluster_member.LOGICAL_CONNECTION                   -- STATUS
     , cluster_member.IS_GLOBAL_COORD                      -- IS_GLOBAL_COORD
     , cluster_member.IS_DOMAIN_COORD                      -- IS_GROUP_COORD
  FROM 
       FIXED_TABLE_SCHEMA.X$CLUSTER_MEMBER@GLOBAL[RANDOM_MEMBER] AS cluster_member
ORDER BY 
      1
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_MEMBER
(  
       MEMBER_ID
     , MEMBER_POSITION
     , STATUS
     , IS_GLOBAL_COORD
     , IS_GROUP_COORD
)
AS 
SELECT 
       MEMBER_ID
     , MEMBER_POSITION
     , STATUS
     , IS_GLOBAL_COORD
     , IS_GROUP_COORD
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$CLUSTER_MEMBER@LOCAL
;
      
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_MEMBER
        IS 'The V$CLUSTER_MEMBER displays cluster member information.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_MEMBER.MEMBER_ID
        IS 'member identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_MEMBER.MEMBER_POSITION
        IS 'member position';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_MEMBER.STATUS
        IS 'status of the member: the value in ( ACTIVE, INACTIVE )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_MEMBER.IS_GLOBAL_COORD
        IS 'indicates whether a member is global coordnator (TRUE) or not (FALSE)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_MEMBER.IS_GROUP_COORD
        IS 'indicates whether a member is group coordnator (TRUE) or not (FALSE)';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$CLUSTER_MEMBER TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_MEMBER TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$CLUSTER_MEMBER;
CREATE PUBLIC SYNONYM GV$CLUSTER_MEMBER FOR PERFORMANCE_VIEW_SCHEMA.GV$CLUSTER_MEMBER;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$CLUSTER_MEMBER;
CREATE PUBLIC SYNONYM V$CLUSTER_MEMBER FOR PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_MEMBER;
COMMIT;

--##############################################################
--# V$CLUSTER_DISPATCHER
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$CLUSTER_DISPATCHER;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_DISPATCHER;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$CLUSTER_DISPATCHER
(  
       ORIGIN_MEMBER_NAME
     , DISPATCHER_ID
     , TYPE
     , RX_BYTES
     , TX_BYTES
     , RX_JOBS
     , TX_JOBS
)
AS 
SELECT 
       cluster_dispatcher.CLUSTER_MEMBER_NAME
     , CAST( cluster_dispatcher.DISPATCHER_ID AS NUMBER )             -- DISPATCHER_ID
     , CAST( cluster_dispatcher.TYPE          AS VARCHAR(64 OCTETS) ) -- TYPE
     , CAST( cluster_dispatcher.RX_BYTES      AS NUMBER )             -- RX_BYTES
     , CAST( cluster_dispatcher.TX_BYTES      AS NUMBER )             -- TX_BYTES
     , CAST( cluster_dispatcher.RX_JOBS       AS NUMBER )             -- RX_JOBS
     , CAST( cluster_dispatcher.TX_JOBS       AS NUMBER )             -- TX_JOBS
  FROM 
       FIXED_TABLE_SCHEMA.X$CLUSTER_DISPATCHER@GLOBAL[IGNORE_INACTIVE_MEMBER] AS cluster_dispatcher
ORDER BY 
      1
    , 2
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_DISPATCHER
(  
       DISPATCHER_ID
     , TYPE
     , RX_BYTES
     , TX_BYTES
     , RX_JOBS
     , TX_JOBS
)
AS 
SELECT 
       DISPATCHER_ID
     , TYPE
     , RX_BYTES
     , TX_BYTES
     , RX_JOBS
     , TX_JOBS
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$CLUSTER_DISPATCHER@LOCAL
;
      
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_DISPATCHER
        IS 'The V$CLUSTER_DISPATCHER displays cluster dispacher information.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_DISPATCHER.DISPATCHER_ID
        IS 'dispatcher identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_DISPATCHER.TYPE
        IS 'dispatcher type: the value in ( lockable, lockless, sync, urgent )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_DISPATCHER.RX_BYTES
        IS 'total amount of data that has received through the dispatcher';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_DISPATCHER.TX_BYTES
        IS 'total amount of data that has transmitted through the dispatcher';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_DISPATCHER.RX_JOBS
        IS 'the total number of jobs received';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_DISPATCHER.TX_JOBS
        IS 'the total number of jobs transmitted';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$CLUSTER_DISPATCHER TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_DISPATCHER TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$CLUSTER_DISPATCHER;
CREATE PUBLIC SYNONYM GV$CLUSTER_DISPATCHER FOR PERFORMANCE_VIEW_SCHEMA.GV$CLUSTER_DISPATCHER;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$CLUSTER_DISPATCHER;
CREATE PUBLIC SYNONYM V$CLUSTER_DISPATCHER FOR PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_DISPATCHER;
COMMIT;


--##############################################################
--# V$CLUSTER_LOCATION
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$CLUSTER_LOCATION;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_LOCATION;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$CLUSTER_LOCATION
(  
       ORIGIN_MEMBER_NAME
     , MEMBER_NAME
     , HOST
     , PORT
)
AS 
SELECT 
       cluster_location.CLUSTER_MEMBER_NAME
     , cluster_location.MEMBER_NAME                         -- MEMBER_NAME
     , cluster_location.HOST                                -- HOST
     , CAST( cluster_location.PORT AS NUMBER )              -- PORT
  FROM 
       FIXED_TABLE_SCHEMA.X$CLUSTER_LOCATION@GLOBAL[IGNORE_INACTIVE_MEMBER] AS cluster_location
ORDER BY 
      1
    , 2
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_LOCATION
(  
       MEMBER_NAME
     , HOST
     , PORT
)
AS 
SELECT 
       MEMBER_NAME
     , HOST
     , PORT
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$CLUSTER_LOCATION@LOCAL
;
      
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_LOCATION
        IS 'The V$CLUSTER_LOCATION displays cluster location information.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_LOCATION.MEMBER_NAME
        IS 'member name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_LOCATION.HOST
        IS 'host address of a member';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_LOCATION.PORT
        IS 'host port of a member';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$CLUSTER_LOCATION TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_LOCATION TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$CLUSTER_LOCATION;
CREATE PUBLIC SYNONYM GV$CLUSTER_LOCATION FOR PERFORMANCE_VIEW_SCHEMA.GV$CLUSTER_LOCATION;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$CLUSTER_LOCATION;
CREATE PUBLIC SYNONYM V$CLUSTER_LOCATION FOR PERFORMANCE_VIEW_SCHEMA.V$CLUSTER_LOCATION;
COMMIT;

--##############################################################
--# V$WAIT_EVENT_NAME
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$WAIT_EVENT_NAME;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_NAME;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$WAIT_EVENT_NAME
(  
       ORIGIN_MEMBER_NAME
     , WAIT_EVENT_ID
     , NAME
     , DESCRIPTION
     , PARAMETER1
     , PARAMETER2
     , PARAMETER3
     , CLASS_ID
     , CLASS_NAME
)
AS 
SELECT 
       we.CLUSTER_MEMBER_NAME
     , CAST( we.WAIT_EVENT_ID AS NUMBER )               -- WAIT_EVENT_ID
     , CAST( we.NAME AS VARCHAR(64 OCTETS) )            -- NAME
     , CAST( we.DESCRIPTION AS VARCHAR(128 OCTETS) )    -- DESCRIPTION
     , CAST( we.PARAMETER1 AS VARCHAR(64 OCTETS) )      -- PARAMETER1
     , CAST( we.PARAMETER2 AS VARCHAR(64 OCTETS) )      -- PARAMETER2
     , CAST( we.PARAMETER3 AS VARCHAR(64 OCTETS) )      -- PARAMETER3
     , CAST( we.CLASS_ID AS NUMBER )                    -- CLASS_ID
     , ( SELECT CAST( NAME AS VARCHAR(64 OCTETS) )
           FROM FIXED_TABLE_SCHEMA.X$WAIT_EVENT_CLASS_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] wec
           WHERE wec.CLASS_ID          = we.CLASS_ID 
             AND wec.CLUSTER_MEMBER_ID = we.CLUSTER_MEMBER_ID)  -- CLASS_NAME
  FROM 
       FIXED_TABLE_SCHEMA.X$WAIT_EVENT_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] AS we
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_NAME
(  
       WAIT_EVENT_ID
     , NAME
     , DESCRIPTION
     , PARAMETER1
     , PARAMETER2
     , PARAMETER3
     , CLASS_ID
     , CLASS_NAME
)
AS 
SELECT 
       WAIT_EVENT_ID
     , NAME
     , DESCRIPTION
     , PARAMETER1
     , PARAMETER2
     , PARAMETER3
     , CLASS_ID
     , CLASS_NAME
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$WAIT_EVENT_NAME@LOCAL
;
             
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_NAME
        IS 'The V$WAIT_EVENT_NAME displays information about wait events.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_NAME.WAIT_EVENT_ID
        IS 'Identifier of the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_NAME.NAME
        IS 'Name of the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_NAME.DESCRIPTION
        IS 'Description of the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_NAME.PARAMETER1
        IS 'Description of the first parameter for the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_NAME.PARAMETER2
        IS 'Description of the second parameter for the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_NAME.PARAMETER3
        IS 'Description of the third parameter for the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_NAME.CLASS_ID
        IS 'Identifier of the class of the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_NAME.CLASS_NAME
        IS 'Name of the class of the wait event';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$WAIT_EVENT_NAME TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_NAME TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$WAIT_EVENT_NAME;
CREATE PUBLIC SYNONYM GV$WAIT_EVENT_NAME FOR PERFORMANCE_VIEW_SCHEMA.GV$WAIT_EVENT_NAME;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$WAIT_EVENT_NAME;
CREATE PUBLIC SYNONYM V$WAIT_EVENT_NAME FOR PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_NAME;
COMMIT;

--##############################################################
--# V$WAIT_EVENT_CLASS_NAME
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$WAIT_EVENT_CLASS_NAME;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_CLASS_NAME;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$WAIT_EVENT_CLASS_NAME
(  
       ORIGIN_MEMBER_NAME
     , CLASS_ID
     , NAME
     , DESCRIPTION
)
AS 
SELECT 
       wec.CLUSTER_MEMBER_NAME
     , CAST( wec.CLASS_ID AS NUMBER )                   -- WAIT_EVENT_CLASS_ID
     , CAST( wec.NAME AS VARCHAR(64 OCTETS) )           -- NAME
     , CAST( wec.DESCRIPTION AS VARCHAR(128 OCTETS) )   -- DESCRIPTION
  FROM 
       FIXED_TABLE_SCHEMA.X$WAIT_EVENT_CLASS_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] AS wec
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_CLASS_NAME
(  
       CLASS_ID
     , NAME
     , DESCRIPTION
)
AS 
SELECT 
       CLASS_ID
     , NAME
     , DESCRIPTION
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$WAIT_EVENT_CLASS_NAME@LOCAL
;
             
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_CLASS_NAME
        IS 'The V$WAIT_EVENT_CLASS_NAME displays information about Class of wait event.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_CLASS_NAME.CLASS_ID
        IS 'Identifier of the class of the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_CLASS_NAME.NAME
        IS 'Name of the class of the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_CLASS_NAME.DESCRIPTION
        IS 'Description of the class of the wait event';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$WAIT_EVENT_CLASS_NAME TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_CLASS_NAME TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$WAIT_EVENT_CLASS_NAME;
CREATE PUBLIC SYNONYM GV$WAIT_EVENT_CLASS_NAME FOR PERFORMANCE_VIEW_SCHEMA.GV$WAIT_EVENT_CLASS_NAME;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$WAIT_EVENT_CLASS_NAME;
CREATE PUBLIC SYNONYM V$WAIT_EVENT_CLASS_NAME FOR PERFORMANCE_VIEW_SCHEMA.V$WAIT_EVENT_CLASS_NAME;
COMMIT;

--##############################################################
--# V$SYSTEM_EVENT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_EVENT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_EVENT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_EVENT
(  
       ORIGIN_MEMBER_NAME
     , WAIT_EVENT_ID
     , WAIT_EVENT_NAME
     , TOTAL_WAITS
     , TOTAL_TIMEOUTS
     , TIME_WAITED
     , AVERAGE_WAIT
     , CLASS_NAME
)
AS 
SELECT 
       syse.CLUSTER_MEMBER_NAME
     , CAST( syse.WAIT_EVENT_ID AS NUMBER )                     -- WAIT_EVENT_ID
     , ( SELECT CAST( NAME AS VARCHAR(64 OCTETS) )
           FROM FIXED_TABLE_SCHEMA.X$WAIT_EVENT_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] wen
           WHERE syse.WAIT_EVENT_ID     = wen.WAIT_EVENT_ID
             AND syse.CLUSTER_MEMBER_ID = wen.CLUSTER_MEMBER_ID )   -- WAIT_EVENT_NAME
     , CAST( syse.TOTAL_WAITS AS NUMBER )                       -- TOTAL_WAITS
     , CAST( syse.TOTAL_TIMEOUTS AS NUMBER )                    -- TOTAL_TIMEOUTS
     , CAST( syse.TIME_WAITED AS NUMBER )                       -- TIME_WAITED
     , CAST( syse.AVERAGE_WAIT AS NUMBER )                      -- AVERAGE_WAIT
     , ( SELECT CAST( wecn.NAME AS VARCHAR(64 OCTETS) )
           FROM FIXED_TABLE_SCHEMA.X$WAIT_EVENT_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] wen
              , FIXED_TABLE_SCHEMA.X$WAIT_EVENT_CLASS_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] wecn
           WHERE syse.WAIT_EVENT_ID     = wen.WAIT_EVENT_ID
             AND syse.CLUSTER_MEMBER_ID = wen.CLUSTER_MEMBER_ID
             AND wen.CLASS_ID           = wecn.CLASS_ID 
             AND syse.CLUSTER_MEMBER_ID = wecn.CLUSTER_MEMBER_ID )  -- CLASS_NAME
  FROM 
       FIXED_TABLE_SCHEMA.X$SYSTEM_EVENT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS syse
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_EVENT
(  
       WAIT_EVENT_ID
     , WAIT_EVENT_NAME
     , TOTAL_WAITS
     , TOTAL_TIMEOUTS
     , TIME_WAITED
     , AVERAGE_WAIT
     , CLASS_NAME
)
AS 
SELECT 
       WAIT_EVENT_ID
     , WAIT_EVENT_NAME
     , TOTAL_WAITS
     , TOTAL_TIMEOUTS
     , TIME_WAITED
     , AVERAGE_WAIT
     , CLASS_NAME
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_EVENT@LOCAL
;

             
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_EVENT
        IS 'The V$SYSTEM_EVENT displays information on total waits for an event.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_EVENT.WAIT_EVENT_ID
        IS 'Identifier of the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_EVENT.WAIT_EVENT_NAME
        IS 'Name of the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_EVENT.TOTAL_WAITS
        IS 'Total number of waits for the event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_EVENT.TOTAL_TIMEOUTS
        IS 'Total number of timeouts for the event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_EVENT.TIME_WAITED
        IS 'Total amount of time waited for the event (in microseconds)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_EVENT.AVERAGE_WAIT
        IS 'Average amount of time waited for the event (in microseconds)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_EVENT.CLASS_NAME
        IS 'Name of the class of the wait event';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_EVENT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_EVENT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SYSTEM_EVENT;
CREATE PUBLIC SYNONYM GV$SYSTEM_EVENT FOR PERFORMANCE_VIEW_SCHEMA.GV$SYSTEM_EVENT;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SYSTEM_EVENT;
CREATE PUBLIC SYNONYM V$SYSTEM_EVENT FOR PERFORMANCE_VIEW_SCHEMA.V$SYSTEM_EVENT;
COMMIT;

--##############################################################
--# V$SESSION_EVENT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SESSION_EVENT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SESSION_EVENT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SESSION_EVENT
(  
       ORIGIN_MEMBER_NAME
     , SESSION_ID
     , WAIT_EVENT_ID
     , WAIT_EVENT_NAME
     , TOTAL_WAITS
     , TOTAL_TIMEOUTS
     , TIME_WAITED
     , AVERAGE_WAIT
     , MAX_WAIT
     , CLASS_NAME
)
AS 
SELECT 
       sese.CLUSTER_MEMBER_NAME
     , CAST( sese.SESSION_ID AS NUMBER )                        -- SESSION_ID
     , CAST( sese.WAIT_EVENT_ID AS NUMBER )                     -- WAIT_EVENT_ID
     , ( SELECT CAST( NAME AS VARCHAR(64 OCTETS) )
           FROM FIXED_TABLE_SCHEMA.X$WAIT_EVENT_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] wen
           WHERE sese.WAIT_EVENT_ID     = wen.WAIT_EVENT_ID
             AND sese.CLUSTER_MEMBER_ID = wen.CLUSTER_MEMBER_ID )   -- WAIT_EVENT_NAME
     , CAST( sese.TOTAL_WAITS AS NUMBER )                       -- TOTAL_WAITS
     , CAST( sese.TOTAL_TIMEOUTS AS NUMBER )                    -- TOTAL_TIMEOUTS
     , CAST( sese.TIME_WAITED AS NUMBER )                       -- TIME_WAITED
     , CAST( sese.AVERAGE_WAIT AS NUMBER )                      -- AVERAGE_WAIT
     , CAST( sese.MAX_WAIT AS NUMBER )                          -- MAX_WAIT
     , ( SELECT CAST( wecn.NAME AS VARCHAR(64 OCTETS) )
           FROM FIXED_TABLE_SCHEMA.X$WAIT_EVENT_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] wen
              , FIXED_TABLE_SCHEMA.X$WAIT_EVENT_CLASS_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] wecn
           WHERE sese.WAIT_EVENT_ID     = wen.WAIT_EVENT_ID
             AND sese.CLUSTER_MEMBER_ID = wen.CLUSTER_MEMBER_ID
             AND wen.CLASS_ID           = wecn.CLASS_ID 
             AND sese.CLUSTER_MEMBER_ID = wecn.CLUSTER_MEMBER_ID )        -- CLASS_NAME
  FROM 
       FIXED_TABLE_SCHEMA.X$SESSION_EVENT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sese
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SESSION_EVENT
(  
       SESSION_ID
     , WAIT_EVENT_ID
     , WAIT_EVENT_NAME
     , TOTAL_WAITS
     , TOTAL_TIMEOUTS
     , TIME_WAITED
     , AVERAGE_WAIT
     , MAX_WAIT
     , CLASS_NAME
)
AS 
SELECT 
       SESSION_ID
     , WAIT_EVENT_ID
     , WAIT_EVENT_NAME
     , TOTAL_WAITS
     , TOTAL_TIMEOUTS
     , TIME_WAITED
     , AVERAGE_WAIT
     , MAX_WAIT
     , CLASS_NAME
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$SESSION_EVENT@LOCAL
;
             
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SESSION_EVENT
        IS 'The V$SESSION_EVENT lists information on waits for an event by a session.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_EVENT.SESSION_ID
        IS 'ID of the session';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_EVENT.WAIT_EVENT_ID
        IS 'Identifier of the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_EVENT.WAIT_EVENT_NAME
        IS 'Name of the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_EVENT.TOTAL_WAITS
        IS 'Total number of waits for the event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_EVENT.TOTAL_TIMEOUTS
        IS 'Total number of timeouts for the event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_EVENT.TIME_WAITED
        IS 'Total amount of time waited for the event (in microseconds)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_EVENT.AVERAGE_WAIT
        IS 'Average amount of time waited for the event (in microseconds)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_EVENT.MAX_WAIT
        IS 'Maximum time waited for the event by the session (in microseconds)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_EVENT.CLASS_NAME
        IS 'Name of the class of the wait event';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SESSION_EVENT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SESSION_EVENT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SESSION_EVENT;
CREATE PUBLIC SYNONYM GV$SESSION_EVENT FOR PERFORMANCE_VIEW_SCHEMA.GV$SESSION_EVENT;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SESSION_EVENT;
CREATE PUBLIC SYNONYM V$SESSION_EVENT FOR PERFORMANCE_VIEW_SCHEMA.V$SESSION_EVENT;
COMMIT;

--##############################################################
--# V$SESSION_WAIT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SESSION_WAIT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SESSION_WAIT
(  
       ORIGIN_MEMBER_NAME
     , SESSION_ID
     , SEQ_NO
     , WAIT_EVENT_ID
     , WAIT_EVENT_NAME
     , P1TEXT
     , P1
     , P1HEX
     , P2TEXT
     , P2
     , P2HEX
     , P3TEXT
     , P3
     , P3HEX
     , STATE
     , WAIT_TIME
     , TIME_SINCE_LAST_WAIT
     , CLASS_NAME
)
AS 
SELECT 
       sesw.CLUSTER_MEMBER_NAME
     , CAST( sesw.SESSION_ID AS NUMBER )                        -- SESSION_ID
     , CAST( sesw.SEQ_NO AS NUMBER )                            -- SEQ_NO
     , CAST( sesw.WAIT_EVENT_ID AS NUMBER )                     -- WAIT_EVENT_ID
     , ( SELECT CAST( NAME AS VARCHAR(64 OCTETS) )
           FROM FIXED_TABLE_SCHEMA.X$WAIT_EVENT_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] wen
           WHERE sesw.WAIT_EVENT_ID     = wen.WAIT_EVENT_ID
             AND sesw.CLUSTER_MEMBER_ID = wen.CLUSTER_MEMBER_ID )   -- WAIT_EVENT_NAME
     , ( SELECT CAST( PARAMETER1 AS VARCHAR(64 OCTETS) )
           FROM FIXED_TABLE_SCHEMA.X$WAIT_EVENT_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] wen
           WHERE sesw.WAIT_EVENT_ID     = wen.WAIT_EVENT_ID
             AND sesw.CLUSTER_MEMBER_ID = wen.CLUSTER_MEMBER_ID )   -- PARAMETER1
     , CAST( sesw.P1 AS NUMBER )                                -- P1
     , CAST( TO_CHAR(sesw.P1,'XXXXXXXXXXXXXXXX') AS VARCHAR(32 OCTETS) ) -- P1HEX
     , ( SELECT CAST( PARAMETER2 AS VARCHAR(64 OCTETS) )
           FROM FIXED_TABLE_SCHEMA.X$WAIT_EVENT_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] wen
           WHERE sesw.WAIT_EVENT_ID     = wen.WAIT_EVENT_ID
             AND sesw.CLUSTER_MEMBER_ID = wen.CLUSTER_MEMBER_ID )   -- PARAMETER2
     , CAST( sesw.P2 AS NUMBER )                                -- P2
     , CAST( TO_CHAR(sesw.P2,'XXXXXXXXXXXXXXXX') AS VARCHAR(32 OCTETS) ) -- P2HEX
     , ( SELECT CAST( PARAMETER3 AS VARCHAR(64 OCTETS) )
           FROM FIXED_TABLE_SCHEMA.X$WAIT_EVENT_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] wen
           WHERE sesw.WAIT_EVENT_ID     = wen.WAIT_EVENT_ID 
             AND sesw.CLUSTER_MEMBER_ID = wen.CLUSTER_MEMBER_ID )   -- PARAMETER3
     , CAST( sesw.P3 AS NUMBER )                                -- P3
     , CAST( TO_CHAR(sesw.P3,'XXXXXXXXXXXXXXXX') AS VARCHAR(32 OCTETS) ) -- P3HEX
     , CAST( sesw.STATE AS VARCHAR(64 OCTETS) )                 -- STATE
     , CAST( sesw.WAIT_TIME AS NUMBER )                         -- WAIT_TIME
     , CAST( sesw.TIME_SINCE_LAST_WAIT AS NUMBER )              -- TIME_SINCE_LAST_WAIT
     , ( SELECT CAST( wecn.NAME AS VARCHAR(64 OCTETS) )
           FROM FIXED_TABLE_SCHEMA.X$WAIT_EVENT_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] wen
              , FIXED_TABLE_SCHEMA.X$WAIT_EVENT_CLASS_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] wecn
           WHERE sesw.WAIT_EVENT_ID     = wen.WAIT_EVENT_ID
             AND sesw.CLUSTER_MEMBER_ID = wen.CLUSTER_MEMBER_ID
             AND wen.CLASS_ID           = wecn.CLASS_ID 
             AND sesw.CLUSTER_MEMBER_ID = wecn.CLUSTER_MEMBER_ID )        -- CLASS_NAME
  FROM 
       FIXED_TABLE_SCHEMA.X$SESSION_WAIT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sesw
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT
(  
       SESSION_ID
     , SEQ_NO
     , WAIT_EVENT_ID
     , WAIT_EVENT_NAME
     , P1TEXT
     , P1
     , P1HEX
     , P2TEXT
     , P2
     , P2HEX
     , P3TEXT
     , P3
     , P3HEX
     , STATE
     , WAIT_TIME
     , TIME_SINCE_LAST_WAIT
     , CLASS_NAME
)
AS 
SELECT            
       SESSION_ID
     , SEQ_NO
     , WAIT_EVENT_ID
     , WAIT_EVENT_NAME
     , P1TEXT
     , P1
     , P1HEX
     , P2TEXT
     , P2
     , P2HEX
     , P3TEXT
     , P3
     , P3HEX
     , STATE
     , WAIT_TIME
     , TIME_SINCE_LAST_WAIT
     , CLASS_NAME
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$SESSION_WAIT@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT
        IS 'The V$SESSION_WAIT displays the current or last wait for each session.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.SESSION_ID
        IS 'ID of the session';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.WAIT_EVENT_ID
        IS 'Identifier of the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.WAIT_EVENT_NAME
        IS 'Name of the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.SEQ_NO
        IS 'A number that uniquely identifies the current or last wait (incremented for each wait)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.P1TEXT
        IS 'Description of the first parameter for the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.P1
        IS 'First wait event parameter (in decimal)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.P1HEX
        IS 'First wait event parameter (in hex)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.P2TEXT
        IS 'Description of the second parameter for the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.P2
        IS 'Second wait event parameter (in decimal)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.P2HEX
        IS 'Second wait event parameter (in hex)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.P3TEXT
        IS 'Description of the third parameter for the wait event';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.P3
        IS 'Third wait event parameter (in decimal)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.P3HEX
        IS 'Third wait event parameter (in hex)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.STATE
        IS 'Wait state';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.WAIT_TIME
        IS 'If the session is currently waiting, then the value is time waited for the current wait. If the session is not in a wait, then the value is the duration of the last wait (in microseconds)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.TIME_SINCE_LAST_WAIT
        IS 'Time elapsed since the end of the last wait (in microseconds). If the session is currently in a wait, then the value is 0.';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT.CLASS_NAME
        IS 'Name of the class of the wait event';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SESSION_WAIT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SESSION_WAIT;
CREATE PUBLIC SYNONYM GV$SESSION_WAIT FOR PERFORMANCE_VIEW_SCHEMA.GV$SESSION_WAIT;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SESSION_WAIT;
CREATE PUBLIC SYNONYM V$SESSION_WAIT FOR PERFORMANCE_VIEW_SCHEMA.V$SESSION_WAIT;
COMMIT;

--##############################################################
--# V$AGABLE_INFO
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$AGABLE_INFO;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$AGABLE_INFO;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$AGABLE_INFO
(  
       ORIGIN_MEMBER_NAME
     , GLOBAL_SCN
     , LOCAL_SCN
     , AGABLE_SCN
     , AGABLE_SCN_GAP
     , LOCAL_AGABLE_SCN
     , REMOTE_AGABLE_SCN
     , OLDEST_SESSION_ID
)
AS 
SELECT 
       agableInfo.CLUSTER_MEMBER_NAME
     , CAST( agableInfo.GLOBAL_SCN AS VARCHAR(32 OCTETS) )               -- GLOBAL_SCN
     , CAST( agableInfo.LOCAL_SCN AS VARCHAR(32 OCTETS) )                -- LOCAL_SCN
     , CAST( agableInfo.AGABLE_SCN AS VARCHAR(32 OCTETS) )               -- AGABLE_SCN
     , CAST( agableInfo.AGABLE_SCN_GAP AS VARCHAR(32 OCTETS) )           -- AGABLE_SCN_GAP
     , CAST( agableInfo.LOCAL_AGABLE_SCN AS VARCHAR(32 OCTETS) )         -- LOCAL_AGABLE_SCN
     , CAST( agableInfo.REMOTE_AGABLE_SCN AS VARCHAR(32 OCTETS) )        -- REMOTE_AGABLE_SCN
     , CAST( agableInfo.SESSION_ID_BLOCKING_AGABLE_SCN AS NUMBER )       -- OLDEST_SESSION_ID
  FROM 
       FIXED_TABLE_SCHEMA.X$AGABLE_INFO@GLOBAL[IGNORE_INACTIVE_MEMBER] AS agableInfo
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$AGABLE_INFO
(  
       GLOBAL_SCN
     , LOCAL_SCN
     , AGABLE_SCN
     , AGABLE_SCN_GAP
     , LOCAL_AGABLE_SCN
     , REMOTE_AGABLE_SCN
     , OLDEST_SESSION_ID
)
AS 
SELECT 
       GLOBAL_SCN
     , LOCAL_SCN
     , AGABLE_SCN
     , AGABLE_SCN_GAP
     , LOCAL_AGABLE_SCN
     , REMOTE_AGABLE_SCN
     , OLDEST_SESSION_ID
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$AGABLE_INFO@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$AGABLE_INFO
        IS 'The V$AGABLE_INFO displays the system agable information.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$AGABLE_INFO.GLOBAL_SCN
        IS 'global scn';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$AGABLE_INFO.LOCAL_SCN
        IS 'local scn';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$AGABLE_INFO.AGABLE_SCN
        IS 'agable scn';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$AGABLE_INFO.AGABLE_SCN_GAP
        IS 'agable scn gap';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$AGABLE_INFO.LOCAL_AGABLE_SCN
        IS 'local agable scn';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$AGABLE_INFO.REMOTE_AGABLE_SCN
        IS 'remote agble scn';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$AGABLE_INFO.OLDEST_SESSION_ID
        IS 'id of session blocking agable scn';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$AGABLE_INFO TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$AGABLE_INFO TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS V$AGABLE_INFO;
CREATE PUBLIC SYNONYM V$AGABLE_INFO FOR PERFORMANCE_VIEW_SCHEMA.GV$AGABLE_INFO;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$AGABLE_INFO;
CREATE PUBLIC SYNONYM V$AGABLE_INFO FOR PERFORMANCE_VIEW_SCHEMA.V$AGABLE_INFO;
COMMIT;

--##############################################################
--# V$AGABLE_INFO
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SQL_HISTORY;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SQL_HISTORY;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SQL_HISTORY
(  
       DRIVER_MEMBER_POS
     , SESSION_ID
     , START_TIME
     , EXEC_TIME
     , PREPARED
     , SUCCESS
     , STATUS
     , SQL_TEXT
)
AS 
SELECT 
       CAST( sqlHistory.DRIVER_MEMBER_POS AS NUMBER )       -- DRIVER_MEMBER_POS 
     , CAST( sqlHistory.SESSION_ID AS NUMBER )              -- SESSION_ID
     , sqlHistory.START_TIME                                -- START_TIME
     , CAST( sqlHistory.EXEC_TIME AS NUMBER )               -- EXEC_TIME
     , CAST( sqlHistory.PREPARED AS BOOLEAN )               -- PREPARED      
     , CAST( sqlHistory.SUCCESS AS BOOLEAN )                -- SUCCESS
     , CAST( sqlHistory.STATUS AS VARCHAR(16 OCTETS) )      -- STATUS
     , CAST( sqlHistory.SQL_TEXT AS VARCHAR(1024 OCTETS) )  -- SQL_TEXT
  FROM 
       FIXED_TABLE_SCHEMA.X$SQL_HISTORY@GLOBAL[IGNORE_INACTIVE_MEMBER] AS sqlHistory
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SQL_HISTORY
(  
       DRIVER_MEMBER_POS
     , SESSION_ID
     , START_TIME
     , EXEC_TIME
     , PREPARED
     , SUCCESS
     , STATUS
     , SQL_TEXT
)
AS 
SELECT 
       DRIVER_MEMBER_POS
     , SESSION_ID
     , START_TIME
     , EXEC_TIME
     , PREPARED
     , SUCCESS
     , STATUS
     , SQL_TEXT
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$SQL_HISTORY@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SQL_HISTORY
        IS 'The V$SQL_HISTORY displays information of SQLs.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_HISTORY.DRIVER_MEMBER_POS
        IS 'driver member position';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_HISTORY.SESSION_ID
        IS 'session identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_HISTORY.START_TIME
        IS 'statement start time';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_HISTORY.EXEC_TIME
        IS 'execution time(us)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_HISTORY.PREPARED
        IS 'indicates whether the statement is prepared ( YES ) or not ( NO )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_HISTORY.SUCCESS
        IS 'indicates whether the statement is success ( YES ) or not ( NO )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_HISTORY.STATUS
        IS 'status of the statement: the value in ( RUNNING, DONE )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SQL_HISTORY.SQL_TEXT
        IS 'first 1024 bytes of the SQL text for the statement';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SQL_HISTORY TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SQL_HISTORY TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS V$SQL_HISTORY;
CREATE PUBLIC SYNONYM V$SQL_HISTORY FOR PERFORMANCE_VIEW_SCHEMA.GV$SQL_HISTORY;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SQL_HISTORY;
CREATE PUBLIC SYNONYM V$SQL_HISTORY FOR PERFORMANCE_VIEW_SCHEMA.V$SQL_HISTORY;
COMMIT;




--##############################################################
--# V$AUDITABLE_DB_PRIVILEGES
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$AUDITABLE_DB_PRIVILEGES;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$AUDITABLE_DB_PRIVILEGES;

COMMIT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$AUDITABLE_DB_PRIVILEGES
(  
       ORIGIN_MEMBER_NAME
     , PRIVILEGE_ID
     , PRIVILEGE_NAME
)
AS 
SELECT 
       priv.CLUSTER_MEMBER_NAME                    -- ORIGIN_MEMBER_NAME
     , CAST( priv.PRIV_ID AS NUMBER )              -- PRIVILEGE_ID
     , priv.PRIV_NAME                              -- PRIVILEGE_NAME
  FROM 
       FIXED_TABLE_SCHEMA.X$DATABASE_PRIVILEGE@GLOBAL[IGNORE_INACTIVE_MEMBER] AS priv
 WHERE
       priv.IS_AUDITABLE = TRUE
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$AUDITABLE_DB_PRIVILEGES
(  
       PRIVILEGE_ID
     , PRIVILEGE_NAME
)
AS 
SELECT 
       PRIVILEGE_ID
     , PRIVILEGE_NAME
  FROM
       GV$AUDITABLE_DB_PRIVILEGES@LOCAL
;
  
COMMIT;


--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$AUDITABLE_DB_PRIVILEGES
        IS 'The V$AUDITABLE_DB_PRIVILEGES displays auditable database privileges.';
COMMIT;

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$AUDITABLE_DB_PRIVILEGES.PRIVILEGE_ID
        IS 'database privilege identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$AUDITABLE_DB_PRIVILEGES.PRIVILEGE_NAME
        IS 'database privilege name';
COMMIT;

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$AUDITABLE_DB_PRIVILEGES TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$AUDITABLE_DB_PRIVILEGES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$AUDITABLE_DB_PRIVILEGES;
CREATE PUBLIC SYNONYM GV$AUDITABLE_DB_PRIVILEGES FOR PERFORMANCE_VIEW_SCHEMA.GV$AUDITABLE_DB_PRIVILEGES;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$AUDITABLE_DB_PRIVILEGES;
CREATE PUBLIC SYNONYM V$AUDITABLE_DB_PRIVILEGES FOR PERFORMANCE_VIEW_SCHEMA.V$AUDITABLE_DB_PRIVILEGES;
COMMIT;


--##############################################################
--# V$AUDITABLE_SYSTEM_ACTIONS
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$AUDITABLE_SYSTEM_ACTIONS;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$AUDITABLE_SYSTEM_ACTIONS;
COMMIT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$AUDITABLE_SYSTEM_ACTIONS
(  
       ORIGIN_MEMBER_NAME
     , ACTION_ID
     , ACTION_NAME
)
AS 
SELECT 
       act.CLUSTER_MEMBER_NAME                      -- ORIGIN_MEMBER_NAME
     , CAST( act.ACTION_ID AS NUMBER )              -- ACTION_ID
     , act.ACTION_NAME                              -- ACTION_NAME
  FROM 
       FIXED_TABLE_SCHEMA.X$AUDIT_SYS_ACTION@GLOBAL[IGNORE_INACTIVE_MEMBER] AS act
 WHERE
       act.IS_SUPPORT = TRUE
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$AUDITABLE_SYSTEM_ACTIONS
(  
       ACTION_ID
     , ACTION_NAME
)
AS 
SELECT 
       ACTION_ID
     , ACTION_NAME
  FROM
       GV$AUDITABLE_SYSTEM_ACTIONS@LOCAL
;

COMMIT;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$AUDITABLE_SYSTEM_ACTIONS
        IS 'The V$AUDITABLE_SYSTEM_ACTIONS displays auditable system actions.';
COMMIT;

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$AUDITABLE_SYSTEM_ACTIONS.ACTION_ID
        IS 'auditable system action identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$AUDITABLE_SYSTEM_ACTIONS.ACTION_NAME
        IS 'auditable system action name';
COMMIT;

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$AUDITABLE_SYSTEM_ACTIONS TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$AUDITABLE_SYSTEM_ACTIONS TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$AUDITABLE_SYSTEM_ACTIONS;
CREATE PUBLIC SYNONYM GV$AUDITABLE_SYSTEM_ACTIONS FOR PERFORMANCE_VIEW_SCHEMA.GV$AUDITABLE_SYSTEM_ACTIONS;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$AUDITABLE_SYSTEM_ACTIONS;
CREATE PUBLIC SYNONYM V$AUDITABLE_SYSTEM_ACTIONS FOR PERFORMANCE_VIEW_SCHEMA.V$AUDITABLE_SYSTEM_ACTIONS;
COMMIT;


--##############################################################
--# V$SEQUENCE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$SEQUENCE;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$SEQUENCE
(  
       ORIGIN_MEMBER_NAME
     , SEQUENCE_NAME
     , PHYSICAL_ID
     , START_WITH
     , INCREMENT_BY
     , MAXVALUE
     , MINVALUE
     , CACHE_SIZE
     , LOCAL_NEXT_VALUE
     , LOCAL_CURR_VALUE
     , RESTART_VALUE
     , CYCLE
     , USE_LAST_VALUE
     , LOCAL_CACHE_COUNT
     , GLOBAL_NEXT_VALUE
     , SYNC_COMPARE_SN
     , GLOBAL_LATCH_SESSION_ID
     , GLOBAL_LATCH_SESSION_SERIAL
     , DDL_LATCH_SESSION_ID
     , DDL_LATCH_SESSION_SERIAL
     , LOCAL_LATCH_SESSION_ID
     , LOCAL_LATCH_SESSION_SERIAL
     , IS_ONLINE
)
AS 
SELECT
       seqs.CLUSTER_MEMBER_NAME
     , CAST( seq_def.SEQUENCE_NAME   AS VARCHAR(128 OCTETS) )     -- SEQUENCE_NAME
     , CAST( seq_def.PHYSICAL_ID     AS NUMBER )                  -- PHYSICAL_ID
     , CAST( seqs.START_WITH         AS NUMBER )                  -- START_WITH
     , CAST( seqs.INCREMENT_BY       AS NUMBER )                  -- INCREMENT_BY
     , CAST( seqs.MAXVALUE           AS NUMBER )                  -- MAXVALUE
     , CAST( seqs.MINVALUE           AS NUMBER )                  -- MINVALUE
     , CAST( seqs.CACHE_SIZE         AS NUMBER )                  -- CACHE_SIZE
     , CAST( seqs.LOCAL_NEXT_VALUE   AS NUMBER )                  -- LOCAL_NEXT_VALUE
     , CAST( seqs.LOCAL_CURR_VALUE   AS NUMBER )                  -- LOCAL_CURR_VALUE
     , CAST( seqs.RESTART_VALUE      AS NUMBER )                  -- RESTART_VALUE
     , CAST( seqs.CYCLE              AS BOOLEAN )                 -- CYCLE
     , CAST( seqs.USE_LAST_VALUE     AS BOOLEAN )                 -- USE_LAST_VALUE
     , CAST( seqs.LOCAL_CACHE_COUNT  AS NUMBER )                  -- LOCAL_CACHE_COUNT
     , CAST( seqs.GLOBAL_NEXT_VALUE  AS NUMBER )                  -- GLOBAL_NEXT_VALUE
     , CAST( seqs.SYNC_COMPARE_SN    AS NUMBER )                  -- SYNC_COMPARE_SN
     , CAST( seqs.GLOBAL_LATCH_SESSION_ID      AS NUMBER )        -- GLOBAL_LATCH_SESSION_ID
     , CAST( seqs.GLOBAL_LATCH_SESSION_SERIAL  AS NUMBER )        -- GLOBAL_LATCH_SESSION_SERIAL
     , CAST( seqs.DDL_LATCH_SESSION_ID         AS NUMBER )        -- DDL_LATCH_SESSION_ID
     , CAST( seqs.DDL_LATCH_SESSION_SERIAL     AS NUMBER )        -- DDL_LATCH_SESSION_SERIAL
     , CAST( seqs.LOCAL_LATCH_SESSION_ID       AS NUMBER )        -- LOCAL_LATCH_SESSION_ID
     , CAST( seqs.LOCAL_LATCH_SESSION_SERIAL   AS NUMBER )        -- LOCAL_LATCH_SESSION_SERIAL
     , CAST( seqs.IS_ONLINE                    AS BOOLEAN )       -- IS_ONLINE
  FROM 
       FIXED_TABLE_SCHEMA.X$SEQUENCE@GLOBAL[IGNORE_INACTIVE_MEMBER] AS seqs,
       DEFINITION_SCHEMA.SEQUENCES@GLOBAL[IGNORE_INACTIVE_MEMBER]   AS seq_def
 WHERE
       seqs.PHYSICAL_ID = seq_def.PHYSICAL_ID
   AND seqs.CLUSTER_MEMBER_ID = seq_def.CLUSTER_MEMBER_ID
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE
(  
       SEQUENCE_NAME
     , PHYSICAL_ID
     , START_WITH
     , INCREMENT_BY
     , MAXVALUE
     , MINVALUE
     , CACHE_SIZE
     , LOCAL_NEXT_VALUE
     , LOCAL_CURR_VALUE
     , RESTART_VALUE
     , CYCLE
     , USE_LAST_VALUE
     , LOCAL_CACHE_COUNT
     , GLOBAL_NEXT_VALUE
     , SYNC_COMPARE_SN
     , GLOBAL_LATCH_SESSION_ID
     , GLOBAL_LATCH_SESSION_SERIAL
     , DDL_LATCH_SESSION_ID
     , DDL_LATCH_SESSION_SERIAL
     , LOCAL_LATCH_SESSION_ID
     , LOCAL_LATCH_SESSION_SERIAL
     , IS_ONLINE
)
AS 
SELECT 
       CAST( seq_def.SEQUENCE_NAME   AS VARCHAR(128 OCTETS) )     -- SEQUENCE_NAME
     , CAST( seq_def.PHYSICAL_ID     AS NUMBER )                  -- PHYSICAL_ID
     , CAST( seqs.START_WITH         AS NUMBER )                  -- START_WITH
     , CAST( seqs.INCREMENT_BY       AS NUMBER )                  -- INCREMENT_BY
     , CAST( seqs.MAXVALUE           AS NUMBER )                  -- MAXVALUE
     , CAST( seqs.MINVALUE           AS NUMBER )                  -- MINVALUE
     , CAST( seqs.CACHE_SIZE         AS NUMBER )                  -- CACHE_SIZE
     , CAST( seqs.LOCAL_NEXT_VALUE   AS NUMBER )                  -- LOCAL_NEXT_VALUE
     , CAST( seqs.LOCAL_CURR_VALUE   AS NUMBER )                  -- LOCAL_CURR_VALUE
     , CAST( seqs.RESTART_VALUE      AS NUMBER )                  -- RESTART_VALUE
     , CAST( seqs.CYCLE              AS BOOLEAN )                 -- CYCLE
     , CAST( seqs.USE_LAST_VALUE     AS BOOLEAN )                 -- USE_LAST_VALUE
     , CAST( seqs.LOCAL_CACHE_COUNT  AS NUMBER )                  -- LOCAL_CACHE_COUNT
     , CAST( seqs.GLOBAL_NEXT_VALUE  AS NUMBER )                  -- GLOBAL_NEXT_VALUE
     , CAST( seqs.SYNC_COMPARE_SN    AS NUMBER )                  -- SYNC_COMPARE_SN
     , CAST( seqs.GLOBAL_LATCH_SESSION_ID      AS NUMBER )        -- GLOBAL_LATCH_SESSION_ID
     , CAST( seqs.GLOBAL_LATCH_SESSION_SERIAL  AS NUMBER )        -- GLOBAL_LATCH_SESSION_SERIAL
     , CAST( seqs.DDL_LATCH_SESSION_ID         AS NUMBER )        -- DDL_LATCH_SESSION_ID
     , CAST( seqs.DDL_LATCH_SESSION_SERIAL     AS NUMBER )        -- DDL_LATCH_SESSION_SERIAL
     , CAST( seqs.LOCAL_LATCH_SESSION_ID       AS NUMBER )        -- LOCAL_LATCH_SESSION_ID
     , CAST( seqs.LOCAL_LATCH_SESSION_SERIAL   AS NUMBER )        -- LOCAL_LATCH_SESSION_SERIAL
     , CAST( seqs.IS_ONLINE                    AS BOOLEAN )       -- IS_ONLINE
  FROM 
       FIXED_TABLE_SCHEMA.X$SEQUENCE@LOCAL  AS seqs,
       DEFINITION_SCHEMA.SEQUENCES@LOCAL    AS seq_def
 WHERE
       seqs.PHYSICAL_ID = seq_def.PHYSICAL_ID
;
             
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE
        IS 'The V$SEQUENCE displays information of sequences';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.SEQUENCE_NAME
        IS 'sequence name';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.PHYSICAL_ID
        IS 'physical identifier';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.START_WITH
        IS 'start with value';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.INCREMENT_BY
        IS 'increment value';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.MAXVALUE
        IS 'maximum value';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.MINVALUE
        IS 'minimum value';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.CACHE_SIZE
        IS 'cache size';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.LOCAL_NEXT_VALUE
        IS 'local next value';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.LOCAL_CURR_VALUE
        IS 'local current value';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.RESTART_VALUE
        IS 'restart value';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.CYCLE
        IS 'allow cycle';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.USE_LAST_VALUE
        IS 'use last value or not';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.LOCAL_CACHE_COUNT
        IS 'current local cache count';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.GLOBAL_NEXT_VALUE
        IS 'global next cache chunk start value';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.SYNC_COMPARE_SN
        IS 'serial number for global sequence synchronization';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.GLOBAL_LATCH_SESSION_ID
        IS 'session identifier of global latch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.GLOBAL_LATCH_SESSION_SERIAL
        IS 'session serial number of global latch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.DDL_LATCH_SESSION_ID
        IS 'session identifier of ddl latch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.DDL_LATCH_SESSION_SERIAL
        IS 'session serial number of ddl latch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.LOCAL_LATCH_SESSION_ID
        IS 'owner session identifier of ddl latch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.LOCAL_LATCH_SESSION_SERIAL
        IS 'session serial number of local latch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE.IS_ONLINE
        IS 'is online';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$SEQUENCE TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$SEQUENCE;
CREATE PUBLIC SYNONYM GV$SEQUENCE FOR PERFORMANCE_VIEW_SCHEMA.GV$SEQUENCE;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$SEQUENCE;
CREATE PUBLIC SYNONYM V$SEQUENCE FOR PERFORMANCE_VIEW_SCHEMA.V$SEQUENCE;
COMMIT;

--##############################################################
--# V$BCH
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$BCH;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$BCH;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$BCH
(  
       ORIGIN_MEMBER_NAME
     , BCH_SEQ
     , TABLESPACE_ID
     , PAGE_ID
     , LOGICAL_ADDRESS
     , DIRTY
     , PAGE_TYPE
     , FIRST_DIRTY_LSN
     , RECOVERY_LSN
     , LAST_FLUSHED_LSN
     , FIXED_COUNT
     , TOUCHED_COUNT
     , RECENT_TOUCH_COUNT_INCREASED_TIME
     , BCH_LIST_TYPE
     , BCH_STATE
)
AS 
SELECT 
       bch.CLUSTER_MEMBER_NAME
     , CAST( bch.BCH_SEQ           AS NUMBER )                 -- BCH_SEQ
     , CAST( bch.TBS_ID            AS NUMBER )                 -- TABLESPACE_ID
     , CAST( bch.PAGE_ID           AS NUMBER )                 -- PAGE_ID
     , CAST( bch.LOGICAL_ADDRESS   AS VARCHAR(18 OCTETS) )     -- LOGCIAL_ADDRESS
     , bch.DIRTY                                               -- DIRTY
     , CAST( bch.PAGE_TYPE         AS VARCHAR(20 OCTETS) )     -- PAGE_TYPE
     , CAST( bch.FIRST_DIRTY_LSN   AS NUMBER )                 -- FIRST_DIRTY_LSN
     , CAST( bch.RECOVERY_LSN      AS NUMBER )                 -- RECOVERY_LSN
     , CAST( bch.LAST_FLUSHED_LSN  AS NUMBER )                 -- LAST_FLUSHED_LSN
     , CAST( bch.FIXED_COUNT       AS NUMBER )                 -- FIXED_COUNT
     , CAST( bch.TOUCH_COUNT       AS NUMBER )                 -- TOUCH_COUNT
     , bch.RECENT_TOUCH_COUNT_INCREASED_TIME                   -- RECENT_TOUCH_COUNT_INCREASED_TIME
     , CAST( bch.BCH_LIST_TYPE     AS VARCHAR(16 OCTETS) )     -- BCH_LIST_TYPE
     , CAST( bch.BCH_STATE         AS VARCHAR(16 OCTETS) )     -- BCH_STATE
  FROM 
       FIXED_TABLE_SCHEMA.X$BCH@GLOBAL[IGNORE_INACTIVE_MEMBER] AS bch
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$BCH
(  
       BCH_SEQ
     , TABLESPACE_ID
     , PAGE_ID
     , LOGICAL_ADDRESS
     , DIRTY
     , PAGE_TYPE
     , FIRST_DIRTY_LSN
     , RECOVERY_LSN
     , LAST_FLUSHED_LSN
     , FIXED_COUNT
     , TOUCHED_COUNT
     , RECENT_TOUCH_COUNT_INCREASED_TIME
     , BCH_LIST_TYPE
     , BCH_STATE
)
AS 
SELECT 
       BCH_SEQ
     , TABLESPACE_ID
     , PAGE_ID
     , LOGICAL_ADDRESS
     , DIRTY
     , PAGE_TYPE
     , FIRST_DIRTY_LSN
     , RECOVERY_LSN
     , LAST_FLUSHED_LSN
     , FIXED_COUNT
     , TOUCHED_COUNT
     , RECENT_TOUCH_COUNT_INCREASED_TIME
     , BCH_LIST_TYPE
     , BCH_STATE
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$BCH@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$BCH
        IS 'The V$BCH displays information of database buffer contol header';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BCH.BCH_SEQ
        IS 'bch sequence';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BCH.TABLESPACE_ID
        IS 'tablespace identifier of the page cached in the frame of bch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BCH.PAGE_ID
        IS 'page identifier of the page cached in the frame of bch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BCH.LOGICAL_ADDRESS
        IS 'logical address of the frame of bch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BCH.DIRTY
        IS 'dirty state of the page cached in the frame of bch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BCH.PAGE_TYPE
        IS 'page type of the page cached in the frame of bch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BCH.FIRST_DIRTY_LSN
        IS 'first dirty lsn of the page cached in the frame of bch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BCH.RECOVERY_LSN
        IS 'recovery lsn of the page cached in the frame of bch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BCH.LAST_FLUSHED_LSN
        IS 'last flushed lsn of the page cached in the frame of bch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BCH.FIXED_COUNT
        IS 'fixed count of the page cached in the frame of bch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BCH.TOUCHED_COUNT
        IS 'touched count of the page cached in the frame of bch';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BCH.RECENT_TOUCH_COUNT_INCREASED_TIME
        IS 'timestamp that touch count of the page cached in the frame of bch increased most recently';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BCH.BCH_LIST_TYPE
        IS 'list type to which the bch belongs';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BCH.BCH_STATE
        IS 'bch state';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$BCH TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$BCH TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$BCH;
CREATE PUBLIC SYNONYM GV$BCH FOR PERFORMANCE_VIEW_SCHEMA.GV$BCH;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$BCH;
CREATE PUBLIC SYNONYM V$BCH FOR PERFORMANCE_VIEW_SCHEMA.V$BCH;
COMMIT;

--##############################################################
--# V$BUFFER_STAT
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$BUFFER_STAT;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$BUFFER_STAT
(  
       ORIGIN_MEMBER_NAME
     , BUFFER_POOL_SIZE
     , HASH_BUCKET_COUNT
     , LRU_LIST_COUNT
     , HOT_REGION_PERCENTAGE
     , HOT_REGION_CRITERIA
     , CHECKPOINT_LIST_COUNT
     , FLUSH_LIST_COUNT
     , FREE_LIST_COUNT
     , FREE_BUFFER_WAIT
     , READ_COMPLETE_WAIT
     , BUFFER_LOOKUPS
     , BUFFER_HIT
     , BUFFER_MISS
     , TOTAL_WRITES
)
AS 
SELECT 
       buff.CLUSTER_MEMBER_NAME
     , CAST( buff.BUFFER_POOL_SIZE       AS NUMBER )              -- BUFFER_POOL_SIZE
     , CAST( buff.HASH_BUCKET_COUNT      AS NUMBER )              -- HASH_BUCKET_COUNT
     , CAST( buff.LRU_LIST_COUNT         AS NUMBER )              -- LRU_LIST_COUNT
     , CAST( buff.HOT_REGION_PERCENTAGE  AS NUMBER )              -- HOT_REGION_PERCENTAGE
     , CAST( buff.HOT_REGION_CRITERIA    AS NUMBER )              -- HOT_REGION_CRITERIA
     , CAST( buff.CHECKPOINT_LIST_COUNT  AS NUMBER )              -- CHECKPOINT_LIST_COUNT
     , CAST( buff.FLUSH_LIST_COUNT       AS NUMBER )              -- FLUSH_LIST_COUNT
     , CAST( buff.FREE_LIST_COUNT        AS NUMBER )              -- FREE_LIST_COUNT
     , CAST( buff.FREE_BUFFER_WAIT       AS NUMBER )              -- FREE_BUFFER_WAIT
     , CAST( buff.READ_COMPLETE_WAIT     AS NUMBER )              -- READ_COMPLETE_WAIT
     , CAST( buff.BUFFER_LOOKUPS         AS NUMBER )              -- BUFFER_LOOKUPS
     , CAST( buff.BUFFER_HIT             AS NUMBER )              -- BUFFER_HIT
     , CAST( buff.BUFFER_MISS            AS NUMBER )              -- BUFFER_MISS
     , CAST( buff.TOTAL_WRITES           AS NUMBER )              -- TOTAL_WRITES
  FROM
       FIXED_TABLE_SCHEMA.X$BUFFER_STAT@GLOBAL[IGNORE_INACTIVE_MEMBER] AS buff
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT
(  
       BUFFER_POOL_SIZE
     , HASH_BUCKET_COUNT
     , LRU_LIST_COUNT
     , HOT_REGION_PERCENTAGE
     , HOT_REGION_CRITERIA
     , CHECKPOINT_LIST_COUNT
     , FLUSH_LIST_COUNT
     , FREE_LIST_COUNT
     , FREE_BUFFER_WAIT
     , READ_COMPLETE_WAIT
     , BUFFER_LOOKUPS
     , BUFFER_HIT
     , BUFFER_MISS
     , TOTAL_WRITES
)
AS 
SELECT 
       BUFFER_POOL_SIZE
     , HASH_BUCKET_COUNT
     , LRU_LIST_COUNT
     , HOT_REGION_PERCENTAGE
     , HOT_REGION_CRITERIA
     , CHECKPOINT_LIST_COUNT
     , FLUSH_LIST_COUNT
     , FREE_LIST_COUNT
     , FREE_BUFFER_WAIT
     , READ_COMPLETE_WAIT
     , BUFFER_LOOKUPS
     , BUFFER_HIT
     , BUFFER_MISS
     , TOTAL_WRITES
  FROM
       PERFORMANCE_VIEW_SCHEMA.GV$BUFFER_STAT@LOCAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT
        IS 'The V$BUFFER_STAT displays database statistics';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT.BUFFER_POOL_SIZE
        IS 'total buffer frame size ( page count )';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT.HASH_BUCKET_COUNT
        IS 'buffer hash bucket count';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT.LRU_LIST_COUNT
        IS 'buffer lru list count';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT.HOT_REGION_PERCENTAGE
        IS 'percentage of lru hot region';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT.HOT_REGION_CRITERIA
        IS 'touch count criteria of lru hot region';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT.CHECKPOINT_LIST_COUNT
        IS 'buffer checkpoint list count';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT.FLUSH_LIST_COUNT
        IS 'buffer flush list count';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT.FREE_LIST_COUNT
        IS 'buffer free list count';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT.FREE_BUFFER_WAIT
        IS 'total number of waiting for free buffer';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT.READ_COMPLETE_WAIT
        IS 'total number of waiting for read page complete';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT.BUFFER_LOOKUPS
        IS 'total number of lookups in the buffer for requested pages';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT.BUFFER_HIT
        IS 'total number of hits in the buffer for requested pages';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT.BUFFER_MISS
        IS 'total number of misses in the buffer for requested pages';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT.TOTAL_WRITES
        IS 'total number of physical writes';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$BUFFER_STAT TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$BUFFER_STAT;
CREATE PUBLIC SYNONYM GV$BUFFER_STAT FOR PERFORMANCE_VIEW_SCHEMA.GV$BUFFER_STAT;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$BUFFER_STAT;
CREATE PUBLIC SYNONYM V$BUFFER_STAT FOR PERFORMANCE_VIEW_SCHEMA.V$BUFFER_STAT;
COMMIT;

--##############################################################
--# V$DB_CHANGE_TRACKING
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.GV$DB_CHANGE_TRACKING;

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.V$DB_CHANGE_TRACKING;

--#####################
--# create view
--#####################

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.GV$DB_CHANGE_TRACKING
(  
       ORIGIN_MEMBER_NAME
     , TABLESPACE_ID
     , DATAFILE_ID
     , CHANGE_TRACKING_STATE
     , CHANGE_TRACKING_CHUNK_SEQ
     , MAX_SIZE
     , BITMAP_BLOCK_COUNT
     , LAST_PAGE_SEQ
)
AS 
SELECT 
       dbct.CLUSTER_MEMBER_NAME
     , CAST( dbct.TABLESPACE_ID AS NUMBER )                        -- TABLESPACE_ID
     , CAST( dbct.DATAFILE_ID AS NUMBER )                          -- DATAFILE_ID
     , CAST( dbct.CHANGE_TRACKING_STATE AS VARCHAR(32 OCTETS) )    -- CHANGE_TRACKING_STATE
     , CAST( dbct.CHANGE_TRACKING_CHUNK_SEQ AS NUMBER )            -- CHANGE_TRACKING_CHUNK_SEQ
     , CAST( dbct.MAX_SIZE AS NUMBER )                             -- MAX_SIZE
     , CAST( dbct.BITMAP_BLOCK_COUNT AS NUMBER )                   -- BITMAP_BLOCK_COUNT
     , CAST( dbct.LAST_PAGE_SEQ AS NUMBER )                        -- LAST_PAGE_SEQ
  FROM 
       FIXED_TABLE_SCHEMA.X$DB_CHANGE_TRACKING@GLOBAL[IGNORE_INACTIVE_MEMBER] AS dbct
;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.V$DB_CHANGE_TRACKING
(  
       TABLESPACE_ID
     , DATAFILE_ID
     , CHANGE_TRACKING_STATE
     , CHANGE_TRACKING_CHUNK_SEQ
     , MAX_SIZE
     , BITMAP_BLOCK_COUNT
     , LAST_PAGE_SEQ
)
AS 
SELECT 
       TABLESPACE_ID
     , DATAFILE_ID
     , CHANGE_TRACKING_STATE
     , CHANGE_TRACKING_CHUNK_SEQ
     , MAX_SIZE
     , BITMAP_BLOCK_COUNT
     , LAST_PAGE_SEQ
  FROM 
       PERFORMANCE_VIEW_SCHEMA.GV$DB_CHANGE_TRACKING@LOCAL
;
             
--#####################
--# comment view
--#####################

COMMENT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$DB_CHANGE_TRACKING
        IS 'The V$DB_CHANGE_TRACKING displays information of database change tracking';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DB_CHANGE_TRACKING.TABLESPACE_ID
        IS 'tablespace id';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DB_CHANGE_TRACKING.DATAFILE_ID
        IS 'datafile id';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DB_CHANGE_TRACKING.CHANGE_TRACKING_STATE
        IS 'state of datafile change tracking';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DB_CHANGE_TRACKING.CHANGE_TRACKING_CHUNK_SEQ
        IS 'sequence of change tracking chunk for datafile';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DB_CHANGE_TRACKING.MAX_SIZE
        IS 'maximum size of datafile (byte)';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DB_CHANGE_TRACKING.BITMAP_BLOCK_COUNT
        IS 'bitmap block count of change tracking chunk';
COMMENT ON COLUMN PERFORMANCE_VIEW_SCHEMA.V$DB_CHANGE_TRACKING.LAST_PAGE_SEQ
        IS 'the last page sequence of change tracking chunk';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.GV$DB_CHANGE_TRACKING TO PUBLIC;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.V$DB_CHANGE_TRACKING TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS GV$DB_CHANGE_TRACKING;
CREATE PUBLIC SYNONYM GV$DB_CHANGE_TRACKING FOR PERFORMANCE_VIEW_SCHEMA.GV$DB_CHANGE_TRACKING;
COMMIT;

DROP PUBLIC SYNONYM IF EXISTS V$DB_CHANGE_TRACKING;
CREATE PUBLIC SYNONYM V$DB_CHANGE_TRACKING FOR PERFORMANCE_VIEW_SCHEMA.V$DB_CHANGE_TRACKING;
COMMIT;
