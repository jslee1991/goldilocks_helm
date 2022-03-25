--###################################################################################
--# build views of INFORMATION_SCHEMA
--###################################################################################

--##############################################################
--# SYS AUTHORIZATION
--##############################################################

SET SESSION AUTHORIZATION SYS;

--##############################################################
--# INFORMATION_SCHEMA.WHOLE_TABLES
--# internal use only
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.WHOLE_TABLES;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.WHOLE_TABLES
(
       OWNER_ID
     , SCHEMA_ID
     , TABLE_ID
     , TABLESPACE_ID
     , TABLE_NAME
     , TABLE_TYPE
     , TABLE_TYPE_ID
     , SYSTEM_VERSION_START_COLUMN_NAME
     , SYSTEM_VERSION_END_COLUMN_NAME
     , SYSTEM_VERSION_RETENTION_PERIOD
     , SELF_REFERENCING_COLUMN_NAME
     , REFERENCE_GENERATION
     , USER_DEFINED_TYPE_OWNER_ID
     , USER_DEFINED_TYPE_SCHEMA_ID
     , USER_DEFINED_TYPE_ID
     , IS_INSERTABLE_INTO
     , IS_TYPED
     , COMMIT_ACTION
     , IS_SET_SUPPLOG_PK
     , CREATED_TIME
     , MODIFIED_TIME
     , COMMENTS
)
AS
SELECT 
       OWNER_ID
     , SCHEMA_ID
     , TABLE_ID
     , TABLESPACE_ID
     , TABLE_NAME
     , TABLE_TYPE
     , TABLE_TYPE_ID
     , SYSTEM_VERSION_START_COLUMN_NAME
     , SYSTEM_VERSION_END_COLUMN_NAME
     , SYSTEM_VERSION_RETENTION_PERIOD
     , SELF_REFERENCING_COLUMN_NAME
     , REFERENCE_GENERATION
     , USER_DEFINED_TYPE_OWNER_ID
     , USER_DEFINED_TYPE_SCHEMA_ID
     , USER_DEFINED_TYPE_ID
     , IS_INSERTABLE_INTO
     , IS_TYPED
     , COMMIT_ACTION
     , IS_SET_SUPPLOG_PK
     , CREATED_TIME
     , MODIFIED_TIME
     , COMMENTS
  FROM DEFINITION_SCHEMA.TABLES
 WHERE TABLE_TYPE <> 'SEQUENCE'
   AND IS_DROPPED = FALSE
 UNION ALL
SELECT 
       ( SELECT OWNER_ID FROM DEFINITION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'FIXED_TABLE_SCHEMA' ) -- OWNER_ID
     , ( SELECT SCHEMA_ID FROM DEFINITION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'FIXED_TABLE_SCHEMA' ) -- SCHEMA_ID
     , TABLE_ID
     , NULL -- TABLESPACE_ID
     , TABLE_NAME
     , USAGE_TYPE -- TABLE_TYPE
     , DECODE( USAGE_TYPE, 'FIXED TABLE', 7, 8 )  -- TABLE_TYPE_ID  
     , NULL -- SYSTEM_VERSION_START_COLUMN_NAME
     , NULL -- SYSTEM_VERSION_END_COLUMN_NAME
     , NULL -- SYSTEM_VERSION_RETENTION_PERIOD
     , NULL -- SELF_REFERENCING_COLUMN_NAME
     , NULL -- REFERENCE_GENERATION
     , NULL -- USER_DEFINED_TYPE_OWNER_ID
     , NULL -- USER_DEFINED_TYPE_SCHEMA_ID
     , NULL -- USER_DEFINED_TYPE_ID
     , FALSE -- IS_INSERTABLE_INTO
     , FALSE -- IS_TYPED 
     , NULL -- IS_TYPED
     , FALSE -- IS_SET_SUPPLOG_PK
     , NULL -- CREATED_TIME
     , NULL -- MODIFIED_TIME
     , COMMENTS
  FROM FIXED_TABLE_SCHEMA.X$TABLES;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.WHOLE_TABLES
        IS 'internal use only';

--#####################
--# comment column
--#####################


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.WHOLE_TABLES TO PUBLIC;

COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.WHOLE_COLUMNS
--# internal use only
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.WHOLE_COLUMNS;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.WHOLE_COLUMNS
(
       OWNER_ID
     , SCHEMA_ID
     , TABLE_ID
     , COLUMN_ID
     , COLUMN_NAME
     , PHYSICAL_ORDINAL_POSITION
     , LOGICAL_ORDINAL_POSITION
     , DTD_IDENTIFIER
     , DOMAIN_OWNER_ID
     , DOMAIN_SCHEMA_ID 
     , DOMAIN_ID   
     , COLUMN_DEFAULT  
     , IS_NULLABLE     
     , IS_SELF_REFERENCING 
     , IS_IDENTITY         
     , IDENTITY_GENERATION 
     , IDENTITY_GENERATION_ID 
     , IDENTITY_START     
     , IDENTITY_INCREMENT 
     , IDENTITY_MAXIMUM   
     , IDENTITY_MINIMUM   
     , IDENTITY_CYCLE     
     , IDENTITY_PHYSICAL_ID   
     , IDENTITY_CACHE_SIZE    
     , IS_GENERATED           
     , IS_SYSTEM_VERSION_START  
     , IS_SYSTEM_VERSION_END    
     , SYSTEM_VERSION_TIMESTAMP_GENERATION 
     , IS_UPDATABLE                        
     , IS_UNUSED                           
     , COMMENTS        
)
AS
SELECT 
       OWNER_ID
     , SCHEMA_ID
     , TABLE_ID
     , COLUMN_ID
     , COLUMN_NAME
     , PHYSICAL_ORDINAL_POSITION
     , LOGICAL_ORDINAL_POSITION
     , DTD_IDENTIFIER
     , DOMAIN_OWNER_ID
     , DOMAIN_SCHEMA_ID 
     , DOMAIN_ID   
     , COLUMN_DEFAULT  
     , IS_NULLABLE     
     , IS_SELF_REFERENCING 
     , IS_IDENTITY         
     , IDENTITY_GENERATION 
     , IDENTITY_GENERATION_ID 
     , IDENTITY_START     
     , IDENTITY_INCREMENT 
     , IDENTITY_MAXIMUM   
     , IDENTITY_MINIMUM   
     , IDENTITY_CYCLE     
     , IDENTITY_PHYSICAL_ID   
     , IDENTITY_CACHE_SIZE    
     , IS_GENERATED           
     , IS_SYSTEM_VERSION_START  
     , IS_SYSTEM_VERSION_END    
     , SYSTEM_VERSION_TIMESTAMP_GENERATION 
     , IS_UPDATABLE                        
     , IS_UNUSED      
     , COMMENTS        
  FROM DEFINITION_SCHEMA.COLUMNS
 UNION ALL
SELECT 
       ( SELECT OWNER_ID FROM DEFINITION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'FIXED_TABLE_SCHEMA' ) -- OWNER_ID
     , ( SELECT SCHEMA_ID FROM DEFINITION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'FIXED_TABLE_SCHEMA' ) -- SCHEMA_ID
     , TABLE_ID
     , COLUMN_ID
     , COLUMN_NAME
     , ORDINAL_POSITION
     , ORDINAL_POSITION
     , COLUMN_ID -- DTD_IDENTIFIER
     , NULL -- DOMAIN_OWNER_ID
     , NULL -- DOMAIN_SCHEMA_ID
     , NULL -- DOMAIN_ID   
     , NULL -- COLUMN_DEFAULT  
     , FALSE -- IS_NULLABLE     
     , FALSE -- IS_SELF_REFERENCING 
     , FALSE -- IS_IDENTITY         
     , NULL -- IDENTITY_GENERATION 
     , NULL -- IDENTITY_GENERATION_ID 
     , NULL -- IDENTITY_START     
     , NULL -- IDENTITY_INCREMENT 
     , NULL -- IDENTITY_MAXIMUM   
     , NULL -- IDENTITY_MINIMUM   
     , NULL -- IDENTITY_CYCLE     
     , NULL -- IDENTITY_PHYSICAL_ID   
     , NULL -- IDENTITY_CACHE_SIZE    
     , FALSE -- IS_GENERATED           
     , FALSE -- IS_SYSTEM_VERSION_START  
     , FALSE -- IS_SYSTEM_VERSION_END    
     , NULL -- SYSTEM_VERSION_TIMESTAMP_GENERATION 
     , FALSE -- IS_UPDATABLE                        
     , FALSE -- IS_UNUSED                           
     , COMMENTS        
  FROM FIXED_TABLE_SCHEMA.X$COLUMNS
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.WHOLE_COLUMNS
        IS 'internal use only';

--#####################
--# comment column
--#####################


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.WHOLE_COLUMNS TO PUBLIC;

COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.WHOLE_DTDS
--# internal use only
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.WHOLE_DTDS;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.WHOLE_DTDS
(
       OBJECT_OWNER_ID
     , OBJECT_SCHEMA_ID
     , OBJECT_ID
     , OBJECT_TYPE
     , DTD_IDENTIFIER
     , DATA_TYPE 
     , DATA_TYPE_ID
     , CHARACTER_SET_OWNER_ID
     , CHARACTER_SET_SCHEMA_ID
     , CHARACTER_SET_ID
     , STRING_LENGTH_UNIT
     , STRING_LENGTH_UNIT_ID
     , CHARACTER_MAXIMUM_LENGTH
     , CHARACTER_OCTET_LENGTH
     , COLLATION_OWNER_ID
     , COLLATION_SCHEMA_ID
     , COLLATION_ID 
     , NUMERIC_PRECISION 
     , NUMERIC_PRECISION_RADIX
     , NUMERIC_SCALE 
     , DECLARED_DATA_TYPE
     , DECLARED_NUMERIC_PRECISION
     , DECLARED_NUMERIC_SCALE
     , DATETIME_PRECISION
     , INTERVAL_TYPE
     , INTERVAL_TYPE_ID
     , INTERVAL_PRECISION
     , USER_DEFINED_TYPE_SCHEMA_NAME
     , USER_DEFINED_TYPE_MODULE_NAME
     , USER_DEFINED_TYPE_NAME
     , SCOPE_OWNER_ID
     , SCOPE_SCHEMA_ID
     , SCOPE_ID
     , ATTR_TYPE_SCHEMA_NAME
     , ATTR_TYPE_TABLE_NAME
     , ATTR_TYPE_COLUMN_NAME
     , MAXIMUM_CARDINALITY
     , PHYSICAL_MAXIMUM_LENGTH
     , ATTR_TYPE_MODULE_SCHEMA_NAME
     , ATTR_TYPE_MODULE_NAME
     , ATTR_TYPE_VARIABLE_NAME
     , ATTR_TYPE_FIELD_NAME
)
AS
SELECT
       OBJECT_OWNER_ID
     , OBJECT_SCHEMA_ID
     , OBJECT_ID
     , OBJECT_TYPE
     , DTD_IDENTIFIER
     , CAST( CASE WHEN DATA_TYPE IN ( 'INTERVAL YEAR TO MONTH', 'INTERVAL DAY TO SECOND' )
                       THEN 'INTERVAL ' || INTERVAL_TYPE 
                  WHEN ( DATA_TYPE = 'NUMBER' AND NUMERIC_PRECISION_RADIX = 2 )
                       THEN 'FLOAT'
                  ELSE DATA_TYPE
                  END
             AS VARCHAR(128 OCTETS) ) -- DATA_TYPE
     , DATA_TYPE_ID
     , CHARACTER_SET_OWNER_ID
     , CHARACTER_SET_SCHEMA_ID
     , CHARACTER_SET_ID
     , STRING_LENGTH_UNIT
     , STRING_LENGTH_UNIT_ID
     , CHARACTER_MAXIMUM_LENGTH
     , CHARACTER_OCTET_LENGTH
     , COLLATION_OWNER_ID
     , COLLATION_SCHEMA_ID 
     , COLLATION_ID 
     , NUMERIC_PRECISION 
     , NUMERIC_PRECISION_RADIX
     , CAST( CASE WHEN NUMERIC_SCALE BETWEEN -256 AND 256
                  THEN NUMERIC_SCALE
                  ELSE NULL
                  END 
             AS NUMBER ) 
     , DECLARED_DATA_TYPE
     , DECLARED_NUMERIC_PRECISION
     , DECLARED_NUMERIC_SCALE
     , DATETIME_PRECISION
     , INTERVAL_TYPE
     , INTERVAL_TYPE_ID
     , INTERVAL_PRECISION
     , USER_DEFINED_TYPE_SCHEMA_NAME
     , USER_DEFINED_TYPE_MODULE_NAME
     , USER_DEFINED_TYPE_NAME
     , SCOPE_OWNER_ID
     , SCOPE_SCHEMA_ID
     , SCOPE_ID
     , ATTR_TYPE_SCHEMA_NAME
     , ATTR_TYPE_TABLE_NAME
     , ATTR_TYPE_COLUMN_NAME
     , MAXIMUM_CARDINALITY
     , PHYSICAL_MAXIMUM_LENGTH
     , ATTR_TYPE_MODULE_SCHEMA_NAME
     , ATTR_TYPE_MODULE_NAME
     , ATTR_TYPE_VARIABLE_NAME
     , ATTR_TYPE_FIELD_NAME
  FROM DEFINITION_SCHEMA.DATA_TYPE_DESCRIPTOR
 UNION ALL
SELECT
       ( SELECT OWNER_ID FROM DEFINITION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'FIXED_TABLE_SCHEMA' )  -- OBJECT_OWNER_ID
     , ( SELECT SCHEMA_ID FROM DEFINITION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'FIXED_TABLE_SCHEMA' ) -- OBJECT_SCHEMA_ID
     , TABLE_ID  -- OBJECT_ID
     , 'TABLE'
     , COLUMN_ID -- DTD_IDENTIFIER
     , DATA_TYPE 
     , DATA_TYPE_ID
     , NULL -- CHARACTER_SET_OWNER_ID
     , NULL -- CHARACTER_SET_SCHEMA_ID
     , NULL -- CHARACTER_SET_ID
     , DECODE( DATA_TYPE, 'VARCHAR', 'OCTETS', NULL ) -- STRING_LENGTH_UNIT
     , DECODE( DATA_TYPE, 'VARCHAR', 2, NULL ) -- STRING_LENGTH_UNIT_ID
     , DECODE( DATA_TYPE, 'VARCHAR', 128, NULL ) -- CHARACTER_MAXIMUM_LENGTH
     , DECODE( DATA_TYPE, 'VARCHAR', 128, NULL ) -- CHARACTER_OCTET_LENGTH
     , NULL -- COLLATION_OWNER_ID
     , NULL -- COLLATION_SCHEMA_ID 
     , NULL -- COLLATION_ID 
     , DECODE( DATA_TYPE, 'NATIVE_SMALLINT', 16, 'NATIVE_INTEGER', 32, 'NATIVE_BIGINT', 64, 'NATIVE_REAL', 24, 'NATIVE_DOUBLE', 53, NULL ) -- NUMERIC_PRECISION 
     , DECODE( DATA_TYPE, 'NATIVE_SMALLINT', 2, 'NATIVE_INTEGER', 2, 'NATIVE_BIGINT', 2, 'NATIVE_REAL', 2, 'NATIVE_DOUBLE', 2, NULL ) -- NUMERIC_PRECISION_RADIX
     , DECODE( DATA_TYPE, 'NATIVE_SMALLINT', 0, 'NATIVE_INTEGER', 0, 'NATIVE_BIGINT', 0, 'NATIVE_REAL', NULL, 'NATIVE_DOUBLE', NULL, NULL ) -- NUMERIC_SCALE 
     , DATA_TYPE -- DECLARED_DATA_TYPE
     , DECODE( DATA_TYPE, 'VARCHAR', COLUMN_LENGTH, NULL ) -- DECLARED_NUMERIC_PRECISION
     , NULL -- DECLARED_NUMERIC_SCALE
     , DECODE( DATA_TYPE, 'TIMESTAMP WITHOUT TIME ZONE', 6, NULL ) -- DATETIME_PRECISION
     , NULL -- INTERVAL_TYPE
     , NULL -- INTERVAL_TYPE_ID
     , NULL -- INTERVAL_PRECISION
     , NULL -- USER_DEFINED_TYPE_SCHEMA_NAME
     , NULL -- USER_DEFINED_TYPE_MODULE_NAME
     , NULL -- USER_DEFINED_TYPE_NAME
     , NULL -- SCOPE_OWNER_ID
     , NULL -- SCOPE_SCHEMA_ID
     , NULL -- SCOPE_ID
     , NULL -- ATTR_TYPE_SCHEMA_NAME
     , NULL -- ATTR_TYPE_TABLE_NAME
     , NULL -- ATTR_TYPE_COLUMN_NAME
     , NULL -- MAXIMUM_CARDINALITY
     , COLUMN_LENGTH  -- PHYSICAL_MAXIMUM_LENGTH
     , NULL -- ATTR_TYPE_MODULE_SCHEMA_NAME
     , NULL -- ATTR_TYPE_MODULE_NAME
     , NULL -- ATTR_TYPE_VARIABLE_NAME
     , NULL -- ATTR_TYPE_FIELD_NAME
  FROM FIXED_TABLE_SCHEMA.X$COLUMNS
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.WHOLE_DTDS
        IS 'internal use only';

--#####################
--# comment column
--#####################


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.WHOLE_DTDS TO PUBLIC;

COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.COLUMNS
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.COLUMNS;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.COLUMNS 
( 
       TABLE_CATALOG 
     , TABLE_OWNER 
     , TABLE_SCHEMA 
     , TABLE_NAME 
     , COLUMN_NAME 
     , ORDINAL_POSITION 
     , COLUMN_DEFAULT 
     , IS_NULLABLE 
     , DATA_TYPE 
     , CHARACTER_MAXIMUM_LENGTH 
     , CHARACTER_OCTET_LENGTH 
     , NUMERIC_PRECISION 
     , NUMERIC_PRECISION_RADIX 
     , NUMERIC_SCALE 
     , DATETIME_PRECISION 
     , INTERVAL_TYPE 
     , INTERVAL_PRECISION 
     , CHARACTER_SET_CATALOG 
     , CHARACTER_SET_SCHEMA 
     , CHARACTER_SET_NAME 
     , COLLATION_CATALOG 
     , COLLATION_SCHEMA 
     , COLLATION_NAME 
     , DOMAIN_CATALOG 
     , DOMAIN_SCHEMA 
     , DOMAIN_NAME 
     , UDT_CATALOG 
     , UDT_SCHEMA 
     , UDT_NAME 
     , SCOPE_CATALOG 
     , SCOPE_SCHEMA 
     , SCOPE_NAME 
     , MAXIMUM_CARDINALITY 
     , DTD_IDENTIFIER 
     , IS_SELF_REFERENCING 
     , IS_IDENTITY 
     , IDENTITY_GENERATION 
     , IDENTITY_START 
     , IDENTITY_INCREMENT 
     , IDENTITY_MAXIMUM 
     , IDENTITY_MINIMUM 
     , IDENTITY_CYCLE 
     , IS_GENERATED 
     , GENERATION_EXPRESSION 
     , IS_SYSTEM_VERSION_START 
     , IS_SYSTEM_VERSION_END 
     , SYSTEM_VERSION_TIMESTAMP_GENERATION 
     , IS_UPDATABLE 
     , DECLARED_DATA_TYPE 
     , DECLARED_NUMERIC_PRECISION 
     , DECLARED_NUMERIC_SCALE 
     , COMMENTS 
) 
AS 
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth.AUTHORIZATION_NAME 
     , sch.SCHEMA_NAME 
     , tab.TABLE_NAME 
     , col.COLUMN_NAME 
     , CAST( col.LOGICAL_ORDINAL_POSITION AS NUMBER ) 
     , col.COLUMN_DEFAULT 
     , col.IS_NULLABLE 
     , CAST( dtd.DATA_TYPE AS VARCHAR(128 OCTETS) )
     , CAST( dtd.CHARACTER_MAXIMUM_LENGTH AS NUMBER ) 
     , CAST( dtd.CHARACTER_OCTET_LENGTH AS NUMBER ) 
     , CAST( dtd.NUMERIC_PRECISION AS NUMBER ) 
     , CAST( dtd.NUMERIC_PRECISION_RADIX AS NUMBER ) 
     , CAST( dtd.NUMERIC_SCALE AS NUMBER ) 
     , CAST( dtd.DATETIME_PRECISION AS NUMBER ) 
     , dtd.INTERVAL_TYPE 
     , CAST( dtd.INTERVAL_PRECISION AS NUMBER ) 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- dtd.CHARACTER_SET_CATALOG
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- dtd.CHARACTER_SET_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- dtd.CHARACTER_SET_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- dtd.COLLATION_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- dtd.COLLATION_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- dtd.COLLATION_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- col.DOMAIN_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- col.DOMAIN_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- col.DOMAIN_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- dtd.USER_DEFINED_TYPE_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- dtd.USER_DEFINED_TYPE_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- dtd.USER_DEFINED_TYPE_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- dtd.SCOPE_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- dtd.SCOPE_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- dtd.SCOPE_NAME 
     , CAST( dtd.MAXIMUM_CARDINALITY AS NUMBER ) 
     , CAST( dtd.DTD_IDENTIFIER AS NUMBER ) 
     , col.IS_SELF_REFERENCING 
     , col.IS_IDENTITY 
     , col.IDENTITY_GENERATION 
     , CAST( col.IDENTITY_START AS NUMBER ) 
     , CAST( col.IDENTITY_INCREMENT AS NUMBER ) 
     , CAST( col.IDENTITY_MAXIMUM AS NUMBER ) 
     , CAST( col.IDENTITY_MINIMUM AS NUMBER ) 
     , col.IDENTITY_CYCLE 
     , col.IS_GENERATED 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) AS GENERATION_EXPRESSION 
     , col.IS_SYSTEM_VERSION_START 
     , col.IS_SYSTEM_VERSION_END 
     , col.SYSTEM_VERSION_TIMESTAMP_GENERATION 
     , col.IS_UPDATABLE 
     , dtd.DECLARED_DATA_TYPE 
     , CAST( dtd.DECLARED_NUMERIC_PRECISION AS NUMBER ) 
     , CAST( dtd.DECLARED_NUMERIC_SCALE AS NUMBER ) 
     , col.COMMENTS 
  FROM 
       INFORMATION_SCHEMA.WHOLE_COLUMNS       AS col 
     , INFORMATION_SCHEMA.WHOLE_DTDS          AS dtd 
     , INFORMATION_SCHEMA.WHOLE_TABLES        AS tab 
     , DEFINITION_SCHEMA.SCHEMATA             AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS       AS auth 
 WHERE  
       col.IS_UNUSED = FALSE
   AND col.DTD_IDENTIFIER = dtd.DTD_IDENTIFIER 
   AND col.TABLE_ID       = tab.TABLE_ID 
   AND col.SCHEMA_ID      = sch.SCHEMA_ID 
   AND col.OWNER_ID       = auth.AUTH_ID 
   AND ( col.COLUMN_ID IN ( SELECT pvcol.COLUMN_ID 
                              FROM DEFINITION_SCHEMA.COLUMN_PRIVILEGES AS pvcol 
                             WHERE ( pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                             FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS aucol 
                                                            WHERE aucol.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                         ) 
                                  -- OR  
                                  -- pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                  --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                   )
                          ) 
         OR 
         tab.TABLE_ID IN ( SELECT pvtab.TABLE_ID 
                             FROM DEFINITION_SCHEMA.TABLE_PRIVILEGES AS pvtab 
                            WHERE ( pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                            FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS autab 
                                                           WHERE autab.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                        ) 
                                 -- OR  
                                 -- pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                 --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                  )  
                          ) 
         OR 
         sch.SCHEMA_ID IN ( SELECT pvsch.SCHEMA_ID 
                              FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch 
                             WHERE pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'SELECT TABLE', 'INSERT TABLE', 'DELETE TABLE', 'UPDATE TABLE', 'LOCK TABLE' ) 
                               AND ( pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                             FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS ausch 
                                                            WHERE ausch.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                         ) 
                                  -- OR  
                                  -- pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                  --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                   )  
                          ) 
         OR 
         EXISTS ( SELECT GRANTEE_ID  
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES pvdba 
                   WHERE pvdba.PRIVILEGE_TYPE IN ( 'SELECT ANY TABLE', 'INSERT ANY TABLE', 'DELETE ANY TABLE', 'UPDATE ANY TABLE', 'LOCK ANY TABLE' ) 
                     AND ( pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                   FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS audba 
                                                  WHERE audba.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                               ) 
                        -- OR  
                        -- pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                        --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                         )  
                ) 
       ) 
ORDER BY 
      col.SCHEMA_ID 
    , col.TABLE_ID 
    , col.PHYSICAL_ORDINAL_POSITION
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.COLUMNS 
        IS 'Identify the columns of tables defined in this cataog that are accessible to given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.TABLE_CATALOG                    
        IS 'catalog name of the column';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.TABLE_OWNER                      
        IS 'owner name of the column'; 
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.TABLE_SCHEMA                     
        IS 'schema name of the column'; 
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.TABLE_NAME                       
        IS 'table name of the column'; 
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.COLUMN_NAME                      
        IS 'column name';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.ORDINAL_POSITION                 
        IS 'the ordinal position (> 0) of the column in the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.COLUMN_DEFAULT                   
        IS 'the default for the column'; 
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.IS_NULLABLE                      
        IS 'is nullable of the column'; 
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.DATA_TYPE                        
        IS 'the standard name of the data type'; 
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.CHARACTER_MAXIMUM_LENGTH         
        IS 'the maximum length in characters';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.CHARACTER_OCTET_LENGTH           
        IS 'the maximum length in octets';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.NUMERIC_PRECISION                
        IS 'the numeric precision of the numerical data type'; 
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.NUMERIC_PRECISION_RADIX          
        IS 'the radix ( 2 or 10 ) of the precision of the numerical data type';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.NUMERIC_SCALE                    
        IS 'the numeric scale of the exact numerical data type';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.DATETIME_PRECISION               
        IS 'for a datetime or interval type, the value is the fractional seconds precision';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.INTERVAL_TYPE                    
        IS 'for a interval type, the value is in ( YEAR, MONTH, DAY, HOUR, MINUTE, SECOND, YEAR TO MONTH, DAY TO HOUR, DAY TO MINUTE, DAY TO SECOND, HOUR TO MINUTE, HOUR TO SECOND, MINUTE TO SECOND )';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.INTERVAL_PRECISION               
        IS 'for a interval type, the value is the leading precision';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.CHARACTER_SET_CATALOG            
        IS 'catalog name of the character set if is is a character string type';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.CHARACTER_SET_SCHEMA             
        IS 'schema name of the character set if is is a character string type';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.CHARACTER_SET_NAME               
        IS 'character set name of the character set if is is a character string type';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.COLLATION_CATALOG                
        IS 'catalog name of the applicable collation if is is a character string type';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.COLLATION_SCHEMA                 
        IS 'schema name of the applicable collation if is is a character string type';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.COLLATION_NAME                   
        IS 'collation name of the applicable collation if is is a character string type';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.DOMAIN_CATALOG                   
        IS 'catalog name of the domain used by the column being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.DOMAIN_SCHEMA                    
        IS 'schema name of the domain used by the column being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.DOMAIN_NAME                      
        IS 'domain name of the domain used by the column being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.UDT_CATALOG                      
        IS 'catalog name of the user-defined type of the data type being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.UDT_SCHEMA                       
        IS 'schema name of the user-defined type of the data type being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.UDT_NAME                         
        IS 'user-defined type name of the user-defined type of the data type being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.SCOPE_CATALOG                    
        IS 'catalog name of the referenceable table if DATA_TYPE is REF';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.SCOPE_SCHEMA                     
        IS 'schema name of the referenceable table if DATA_TYPE is REF';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.SCOPE_NAME                       
        IS 'scope name of the referenceable table if DATA_TYPE is REF';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.MAXIMUM_CARDINALITY              
        IS 'maximum cardinality if DATA_TYPE is ARRAY';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.DTD_IDENTIFIER                   
        IS 'data type descriptor identifier';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.IS_SELF_REFERENCING              
        IS 'is a self-referencing column';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.IS_IDENTITY                      
        IS 'is an identity column';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.IDENTITY_GENERATION              
        IS 'for an identity column, the value is in ( ALWAYS, BY DEFAULT )';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.IDENTITY_START                   
        IS 'for an identity column, the start value of the identity column';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.IDENTITY_INCREMENT               
        IS 'for an identity column, the increment of the identity column';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.IDENTITY_MAXIMUM                 
        IS 'for an identity column, the maximum value of the identity column';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.IDENTITY_MINIMUM                 
        IS 'for an identity column, the minimum value of the identity column'; 
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.IDENTITY_CYCLE                   
        IS 'for an identity column, the cycle option';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.IS_GENERATED                     
        IS 'is a generated column';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.GENERATION_EXPRESSION            
        IS 'for a generated column, the text of the generation expression';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.IS_SYSTEM_VERSION_START          
        IS 'is a system-version start column';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.IS_SYSTEM_VERSION_END            
        IS 'is a system-version end column';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.SYSTEM_VERSION_TIMESTAMP_GENERATION  
        IS 'for a system-version column, the value is ALWAYS';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.IS_UPDATABLE                     
        IS 'is an updatable column';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.DECLARED_DATA_TYPE               
        IS 'the data type name that a user declared';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.DECLARED_NUMERIC_PRECISION       
        IS 'the precision value that a user declared'; 
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.DECLARED_NUMERIC_SCALE           
        IS 'the scale value that a user declared';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMNS.COMMENTS                         
        IS 'comments of the column';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.COLUMNS TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS COLUMNS;
CREATE PUBLIC SYNONYM COLUMNS FOR INFORMATION_SCHEMA.COLUMNS;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.COLUMN_PRIVILEGES
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.COLUMN_PRIVILEGES;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.COLUMN_PRIVILEGES
( 
       GRANTOR
     , GRANTEE
     , TABLE_CATALOG
     , TABLE_OWNER 
     , TABLE_SCHEMA 
     , TABLE_NAME 
     , COLUMN_NAME 
     , PRIVILEGE_TYPE
     , IS_GRANTABLE
)
AS
SELECT
       grantor.AUTHORIZATION_NAME
     , grantee.AUTHORIZATION_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , owner.AUTHORIZATION_NAME
     , sch.SCHEMA_NAME
     , tab.TABLE_NAME
     , col.COLUMN_NAME
     , pvcol.PRIVILEGE_TYPE
     , pvcol.IS_GRANTABLE
  FROM
       DEFINITION_SCHEMA.COLUMN_PRIVILEGES AS pvcol 
     , DEFINITION_SCHEMA.COLUMNS           AS col 
     , DEFINITION_SCHEMA.TABLES            AS tab 
     , DEFINITION_SCHEMA.SCHEMATA          AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS    AS grantor
     , DEFINITION_SCHEMA.AUTHORIZATIONS    AS grantee
     , DEFINITION_SCHEMA.AUTHORIZATIONS    AS owner
 WHERE
       pvcol.COLUMN_ID  = col.COLUMN_ID
   AND pvcol.TABLE_ID   = tab.TABLE_ID
   AND pvcol.SCHEMA_ID  = sch.SCHEMA_ID
   AND pvcol.GRANTOR_ID = grantor.AUTH_ID
   AND pvcol.GRANTEE_ID = grantee.AUTH_ID
   AND tab.OWNER_ID     = owner.AUTH_ID
   AND tab.IS_DROPPED = FALSE
   AND ( grantee.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )
      -- OR  
      -- pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
      --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
         OR
         grantor.AUTHORIZATION_NAME = CURRENT_USER
       )
 ORDER BY 
       pvcol.SCHEMA_ID
     , pvcol.TABLE_ID
     , pvcol.COLUMN_ID
     , pvcol.GRANTOR_ID
     , pvcol.GRANTEE_ID
     , pvcol.PRIVILEGE_TYPE_ID   
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.COLUMN_PRIVILEGES
        IS 'Identify the privileges on columns of tables defined in this catalog that are available to or granted by a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMN_PRIVILEGES.GRANTOR
        IS 'authorization name of the user who granted column privileges';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMN_PRIVILEGES.GRANTEE
        IS 'authorization name of some user or role, or PUBLIC to indicate all users, to whom the column privilege being described is granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMN_PRIVILEGES.TABLE_CATALOG
        IS 'catalog name of the column on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMN_PRIVILEGES.TABLE_OWNER 
        IS 'table owner name of the column on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMN_PRIVILEGES.TABLE_SCHEMA 
        IS 'schema name of the column on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMN_PRIVILEGES.TABLE_NAME 
        IS 'table name of the column on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMN_PRIVILEGES.COLUMN_NAME 
        IS 'column name of the column on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMN_PRIVILEGES.PRIVILEGE_TYPE
        IS 'the value is in ( SELECT, INSERT, UPDATE, REFERENCES )';
COMMENT ON COLUMN INFORMATION_SCHEMA.COLUMN_PRIVILEGES.IS_GRANTABLE
        IS 'is grantable';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.COLUMN_PRIVILEGES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS COLUMN_PRIVILEGES;
CREATE PUBLIC SYNONYM COLUMN_PRIVILEGES FOR INFORMATION_SCHEMA.COLUMN_PRIVILEGES;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
(
       TABLE_CATALOG
     , TABLE_OWNER
     , TABLE_SCHEMA
     , TABLE_NAME
     , COLUMN_NAME
     , CONSTRAINT_CATALOG
     , CONSTRAINT_OWNER
     , CONSTRAINT_SCHEMA
     , CONSTRAINT_NAME    
)
AS
SELECT
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth1.AUTHORIZATION_NAME
     , sch1.SCHEMA_NAME
     , tab.TABLE_NAME
     , col.COLUMN_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth2.AUTHORIZATION_NAME
     , sch2.SCHEMA_NAME
     , tcon.CONSTRAINT_NAME
  FROM
       ( ( 
           SELECT 
                  CONSTRAINT_OWNER_ID
                , CONSTRAINT_SCHEMA_ID
                , CONSTRAINT_ID
                , TABLE_OWNER_ID
                , TABLE_SCHEMA_ID
                , TABLE_ID
                , COLUMN_ID
             FROM DEFINITION_SCHEMA.CHECK_COLUMN_USAGE ccu 
         )
         UNION ALL
         (
           SELECT
                  rfc.CONSTRAINT_OWNER_ID
                , rfc.CONSTRAINT_SCHEMA_ID
                , rfc.CONSTRAINT_ID
                , kcu.TABLE_OWNER_ID
                , kcu.TABLE_SCHEMA_ID
                , kcu.TABLE_ID
                , kcu.COLUMN_ID
             FROM DEFINITION_SCHEMA.REFERENTIAL_CONSTRAINTS AS rfc
                , DEFINITION_SCHEMA.KEY_COLUMN_USAGE        AS kcu 
            WHERE
                  rfc.CONSTRAINT_ID = kcu.CONSTRAINT_ID
         ) 
         UNION ALL
         (
           SELECT
                  tcn.CONSTRAINT_OWNER_ID
                , tcn.CONSTRAINT_SCHEMA_ID
                , tcn.CONSTRAINT_ID
                , kcu.TABLE_OWNER_ID
                , kcu.TABLE_SCHEMA_ID
                , kcu.TABLE_ID
                , kcu.COLUMN_ID
             FROM DEFINITION_SCHEMA.TABLE_CONSTRAINTS       AS tcn
                , DEFINITION_SCHEMA.KEY_COLUMN_USAGE        AS kcu 
            WHERE
                  tcn.CONSTRAINT_ID = kcu.CONSTRAINT_ID
              AND tcn.CONSTRAINT_TYPE IN ( 'UNIQUE', 'PRIMARY KEY' )
         ) 
       ) AS vwccu ( CONSTRAINT_OWNER_ID
                  , CONSTRAINT_SCHEMA_ID
                  , CONSTRAINT_ID
                  , TABLE_OWNER_ID
                  , TABLE_SCHEMA_ID
                  , TABLE_ID
                  , COLUMN_ID )
     , DEFINITION_SCHEMA.COLUMNS            AS col
     , DEFINITION_SCHEMA.TABLES             AS tab
     , DEFINITION_SCHEMA.TABLE_CONSTRAINTS  AS tcon
     , DEFINITION_SCHEMA.SCHEMATA           AS sch1
     , DEFINITION_SCHEMA.SCHEMATA           AS sch2
     , DEFINITION_SCHEMA.AUTHORIZATIONS     AS auth1
     , DEFINITION_SCHEMA.AUTHORIZATIONS     AS auth2
 WHERE
       vwccu.COLUMN_ID            = col.COLUMN_ID
   AND vwccu.TABLE_ID             = tab.TABLE_ID
   AND vwccu.TABLE_SCHEMA_ID      = sch1.SCHEMA_ID
   AND vwccu.TABLE_OWNER_ID       = auth1.AUTH_ID
   AND vwccu.CONSTRAINT_ID        = tcon.CONSTRAINT_ID
   AND vwccu.CONSTRAINT_SCHEMA_ID = sch2.SCHEMA_ID
   AND vwccu.CONSTRAINT_OWNER_ID  = auth2.AUTH_ID
   AND tab.IS_DROPPED = FALSE
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       )
 ORDER BY
       vwccu.TABLE_SCHEMA_ID
     , vwccu.TABLE_ID
     , vwccu.COLUMN_ID
     , vwccu.CONSTRAINT_ID
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
        IS 'Identify the columns used by referential constraints, unique constraints, check constraints, and assertions defined in this catalog and owned by a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE.TABLE_CATALOG
        IS 'catalog name of the column that participates in the constraint being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE.TABLE_OWNER
        IS 'owner name of the column that participates in the constraint being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE.TABLE_SCHEMA
        IS 'schema name of the column that participates in the constraint being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE.TABLE_NAME
        IS 'table name of the column that participates in the constraint being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE.COLUMN_NAME
        IS 'column name that participates in the constraint being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE.CONSTRAINT_CATALOG
        IS 'catalog name of the constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE.CONSTRAINT_OWNER
        IS 'owner name of the constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE.CONSTRAINT_SCHEMA
        IS 'schema name of the constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE.CONSTRAINT_NAME
        IS 'constraint name';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS CONSTRAINT_COLUMN_USAGE;
CREATE PUBLIC SYNONYM CONSTRAINT_COLUMN_USAGE FOR INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
(
       TABLE_CATALOG
     , TABLE_OWNER
     , TABLE_SCHEMA
     , TABLE_NAME
     , CONSTRAINT_CATALOG
     , CONSTRAINT_OWNER
     , CONSTRAINT_SCHEMA
     , CONSTRAINT_NAME    
)
AS
SELECT
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth1.AUTHORIZATION_NAME
     , sch1.SCHEMA_NAME
     , tab.TABLE_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth2.AUTHORIZATION_NAME
     , sch2.SCHEMA_NAME
     , tcon.CONSTRAINT_NAME
  FROM
       ( ( 
           SELECT 
                  CONSTRAINT_OWNER_ID
                , CONSTRAINT_SCHEMA_ID
                , CONSTRAINT_ID
                , TABLE_OWNER_ID
                , TABLE_SCHEMA_ID
                , TABLE_ID
             FROM DEFINITION_SCHEMA.CHECK_TABLE_USAGE ctu 
         )
         UNION ALL
         (
           SELECT
                  rfc.CONSTRAINT_OWNER_ID
                , rfc.CONSTRAINT_SCHEMA_ID
                , rfc.CONSTRAINT_ID
                , tcn.TABLE_OWNER_ID
                , tcn.TABLE_SCHEMA_ID
                , tcn.TABLE_ID
             FROM DEFINITION_SCHEMA.REFERENTIAL_CONSTRAINTS AS rfc
                , DEFINITION_SCHEMA.TABLE_CONSTRAINTS       AS tcn
            WHERE
                  rfc.CONSTRAINT_ID = tcn.CONSTRAINT_ID
         ) 
         UNION ALL
         (
           SELECT
                  tcn.CONSTRAINT_OWNER_ID
                , tcn.CONSTRAINT_SCHEMA_ID
                , tcn.CONSTRAINT_ID
                , tcn.TABLE_OWNER_ID
                , tcn.TABLE_SCHEMA_ID
                , tcn.TABLE_ID
             FROM DEFINITION_SCHEMA.TABLE_CONSTRAINTS       AS tcn
            WHERE
                  tcn.CONSTRAINT_TYPE IN ( 'UNIQUE', 'PRIMARY KEY' )
         ) 
       ) AS vwctu ( CONSTRAINT_OWNER_ID
                  , CONSTRAINT_SCHEMA_ID
                  , CONSTRAINT_ID
                  , TABLE_OWNER_ID
                  , TABLE_SCHEMA_ID
                  , TABLE_ID )
     , DEFINITION_SCHEMA.TABLES             AS tab
     , DEFINITION_SCHEMA.TABLE_CONSTRAINTS  AS tcon
     , DEFINITION_SCHEMA.SCHEMATA           AS sch1
     , DEFINITION_SCHEMA.SCHEMATA           AS sch2
     , DEFINITION_SCHEMA.AUTHORIZATIONS     AS auth1
     , DEFINITION_SCHEMA.AUTHORIZATIONS     AS auth2
 WHERE
       vwctu.TABLE_ID             = tab.TABLE_ID
   AND vwctu.TABLE_SCHEMA_ID      = sch1.SCHEMA_ID
   AND vwctu.TABLE_OWNER_ID       = auth1.AUTH_ID
   AND vwctu.CONSTRAINT_ID        = tcon.CONSTRAINT_ID
   AND vwctu.CONSTRAINT_SCHEMA_ID = sch2.SCHEMA_ID
   AND vwctu.CONSTRAINT_OWNER_ID  = auth2.AUTH_ID
   AND tab.IS_DROPPED = FALSE
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       )
 ORDER BY
       vwctu.TABLE_SCHEMA_ID
     , vwctu.TABLE_ID
     , vwctu.CONSTRAINT_ID
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
        IS 'Identify the tables that are used by referential constraints, unique constraints, check constraints, and assertions defined in this catalog and owned by a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE.TABLE_CATALOG
        IS 'catalog name of the table that participates in the constraint being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE.TABLE_OWNER
        IS 'owner name of the table that participates in the constraint being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE.TABLE_SCHEMA
        IS 'schema name of the table that participates in the constraint being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE.TABLE_NAME
        IS 'table name that participates in the constraint being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE.CONSTRAINT_CATALOG
        IS 'catalog name of the constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE.CONSTRAINT_OWNER
        IS 'owner name of the constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE.CONSTRAINT_SCHEMA
        IS 'schema name of the constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE.CONSTRAINT_NAME
        IS 'constraint name';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS CONSTRAINT_TABLE_USAGE;
CREATE PUBLIC SYNONYM CONSTRAINT_TABLE_USAGE FOR INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.INFORMATION_SCHEMA_CATALOG_NAME
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.INFORMATION_SCHEMA_CATALOG_NAME;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.INFORMATION_SCHEMA_CATALOG_NAME
( 
       CATALOG_NAME
)
AS 
SELECT
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
  FROM FIXED_TABLE_SCHEMA.DUAL
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.INFORMATION_SCHEMA_CATALOG_NAME
        IS 'Identify the catalog that contains the Information Schema';
          
--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.INFORMATION_SCHEMA_CATALOG_NAME.CATALOG_NAME
        IS 'the name of catalog in which this Information Schema resides';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.INFORMATION_SCHEMA_CATALOG_NAME TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS INFORMATION_SCHEMA_CATALOG_NAME;
CREATE PUBLIC SYNONYM INFORMATION_SCHEMA_CATALOG_NAME FOR INFORMATION_SCHEMA.INFORMATION_SCHEMA_CATALOG_NAME;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.KEY_COLUMN_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.KEY_COLUMN_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.KEY_COLUMN_USAGE
(
       CONSTRAINT_CATALOG
     , CONSTRAINT_OWNER
     , CONSTRAINT_SCHEMA
     , CONSTRAINT_NAME    
     , TABLE_CATALOG
     , TABLE_OWNER
     , TABLE_SCHEMA
     , TABLE_NAME
     , COLUMN_NAME
     , ORDINAL_POSITION
     , POSITION_IN_UNIQUE_CONSTRAINT
)
AS
SELECT
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) )      -- CONSTRAINT_CATALOG
     , auth1.AUTHORIZATION_NAME                            -- CONSTRAINT_OWNER
     , sch1.SCHEMA_NAME                                    -- CONSTRAINT_SCHEMA
     , tcn.CONSTRAINT_NAME                                 -- CONSTRAINT_NAME    
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) )      -- TABLE_CATALOG
     , auth2.AUTHORIZATION_NAME                            -- TABLE_OWNER
     , sch2.SCHEMA_NAME                                    -- TABLE_SCHEMA
     , tab.TABLE_NAME                                      -- TABLE_NAME
     , col.COLUMN_NAME                                     -- COLUMN_NAME
     , CAST( kcu.ORDINAL_POSITION AS NUMBER )              -- ORDINAL_POSITION
     , CAST( kcu.POSITION_IN_UNIQUE_CONSTRAINT AS NUMBER ) -- POSITION_IN_UNIQUE_CONSTRAINT
  FROM
       DEFINITION_SCHEMA.KEY_COLUMN_USAGE   AS kcu 
     , DEFINITION_SCHEMA.TABLE_CONSTRAINTS  AS tcn
     , DEFINITION_SCHEMA.COLUMNS            AS col
     , DEFINITION_SCHEMA.TABLES             AS tab
     , DEFINITION_SCHEMA.SCHEMATA           AS sch1
     , DEFINITION_SCHEMA.SCHEMATA           AS sch2
     , DEFINITION_SCHEMA.AUTHORIZATIONS     AS auth1
     , DEFINITION_SCHEMA.AUTHORIZATIONS     AS auth2
 WHERE
       kcu.CONSTRAINT_ID        = tcn.CONSTRAINT_ID
   AND kcu.CONSTRAINT_SCHEMA_ID = sch1.SCHEMA_ID
   AND kcu.CONSTRAINT_OWNER_ID  = auth1.AUTH_ID
   AND kcu.COLUMN_ID            = col.COLUMN_ID
   AND kcu.TABLE_ID             = tab.TABLE_ID
   AND kcu.TABLE_SCHEMA_ID      = sch2.SCHEMA_ID
   AND kcu.TABLE_OWNER_ID       = auth2.AUTH_ID
   AND tab.IS_DROPPED = FALSE
   AND ( 
         ( SELECT MAX( kcu2.ORDINAL_POSITION )
             FROM DEFINITION_SCHEMA.KEY_COLUMN_USAGE   AS kcu2
            WHERE kcu2.CONSTRAINT_ID = kcu.CONSTRAINT_ID )
         =
         ( SELECT COUNT(*)
             FROM DEFINITION_SCHEMA.KEY_COLUMN_USAGE   AS kcu3
            WHERE kcu3.CONSTRAINT_ID = kcu.CONSTRAINT_ID
              AND kcu3.COLUMN_ID IN ( SELECT pvcol.COLUMN_ID
                                        FROM DEFINITION_SCHEMA.COLUMN_PRIVILEGES AS pvcol
                                       WHERE 
                                          -- pvcol.PRIVILEGE_TYPE <> 'SELECT'
                                             pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                                    FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS aucol 
                                                                   WHERE aucol.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                                 ) 
                                       -- OR  
                                       -- pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                       --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                    )
         )
         OR 
         tcn.TABLE_ID IN ( SELECT pvtab.TABLE_ID 
                             FROM DEFINITION_SCHEMA.TABLE_PRIVILEGES AS pvtab 
                            WHERE 
                               -- pvtab.PRIVILEGE_TYPE <> 'SELECT'
                                  ( pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                            FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS autab 
                                                           WHERE autab.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                        ) 
                                 -- OR  
                                 -- pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                 --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                  )
                          ) 
         OR 
         tcn.TABLE_SCHEMA_ID IN ( SELECT pvsch.SCHEMA_ID 
                                    FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch 
                                   WHERE pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'SELECT TABLE', 'INSERT TABLE', 'DELETE TABLE', 'UPDATE TABLE' ) 
                                     AND ( pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                                     FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS ausch 
                                                                    WHERE ausch.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                                 ) 
                                          -- OR  
                                          -- pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                          --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                           )  
                                   ) 
         OR 
         EXISTS ( SELECT GRANTEE_ID  
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES pvdba 
                   WHERE pvdba.PRIVILEGE_TYPE IN ( 'SELECT ANY TABLE', 'INSERT ANY TABLE', 'DELETE ANY TABLE', 'UPDATE ANY TABLE' ) 
                     AND ( pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                   FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS audba 
                                                  WHERE audba.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                               ) 
                        -- OR  
                        -- pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                        --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                          )  
                ) 
       ) 
 ORDER BY
       kcu.TABLE_SCHEMA_ID
     , kcu.TABLE_ID
     , kcu.CONSTRAINT_ID
     , kcu.ORDINAL_POSITION
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.KEY_COLUMN_USAGE
        IS 'Identify the columns defined in this catalog that are constrained as keys and that are accessible by a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.KEY_COLUMN_USAGE.CONSTRAINT_CATALOG
        IS 'catalog name of the constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.KEY_COLUMN_USAGE.CONSTRAINT_OWNER
        IS 'owner name of the constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.KEY_COLUMN_USAGE.CONSTRAINT_SCHEMA
        IS 'schema name of the constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.KEY_COLUMN_USAGE.CONSTRAINT_NAME
        IS 'constraint name';
COMMENT ON COLUMN INFORMATION_SCHEMA.KEY_COLUMN_USAGE.TABLE_CATALOG
        IS 'catalog name of the column that participates in the constraint being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.KEY_COLUMN_USAGE.TABLE_OWNER
        IS 'owner name of the column that participates in the constraint being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.KEY_COLUMN_USAGE.TABLE_SCHEMA
        IS 'schema name of the column that participates in the constraint being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.KEY_COLUMN_USAGE.TABLE_NAME
        IS 'table name of the column that participates in the constraint being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.KEY_COLUMN_USAGE.COLUMN_NAME
        IS 'column name that participates in the constraint being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.KEY_COLUMN_USAGE.ORDINAL_POSITION
        IS 'the ordinal position of the specific column in the constraint being described. If the constraint described is a key of cardinality 1 (one), then the value of ORDINAL_POSITION is always 1 (one).';
COMMENT ON COLUMN INFORMATION_SCHEMA.KEY_COLUMN_USAGE.POSITION_IN_UNIQUE_CONSTRAINT
        IS 'If the constraint being described is a foreign key constraint, then the value of POSITION_IN_UNIQUE_CONSTRAINT is the ordinal position of the referenced column corresponding to the referencing column being described, in the corresponding unique key constraint.';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.KEY_COLUMN_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS KEY_COLUMN_USAGE;
CREATE PUBLIC SYNONYM KEY_COLUMN_USAGE FOR INFORMATION_SCHEMA.KEY_COLUMN_USAGE;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
(
       CONSTRAINT_CATALOG
     , CONSTRAINT_OWNER
     , CONSTRAINT_SCHEMA
     , CONSTRAINT_NAME
     , CONSTRAINT_TABLE_NAME
     , CONSTRAINT_COLUMN_NAME
     , ORDINAL_POSITION
     , UNIQUE_CONSTRAINT_CATALOG
     , UNIQUE_CONSTRAINT_OWNER
     , UNIQUE_CONSTRAINT_SCHEMA
     , UNIQUE_CONSTRAINT_NAME
     , UNIQUE_CONSTRAINT_TABLE_NAME
     , UNIQUE_CONSTRAINT_COLUMN_NAME
     , IS_PRIMARY_KEY
     , MATCH_OPTION
     , UPDATE_RULE
     , DELETE_RULE
     , IS_DEFERRABLE
     , INITIALLY_DEFERRED
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth1.AUTHORIZATION_NAME
     , sch1.SCHEMA_NAME
     , tcon.CONSTRAINT_NAME
     , rtab.TABLE_NAME
     , rcol.COLUMN_NAME
     , CAST( rkcu.ORDINAL_POSITION AS NUMBER )
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth2.AUTHORIZATION_NAME
     , sch2.SCHEMA_NAME
     , ucon.CONSTRAINT_NAME
     , utab.TABLE_NAME
     , ucol.COLUMN_NAME
     , CAST( CASE WHEN ucon.CONSTRAINT_TYPE = 'PRIMARY KEY' 
                  THEN TRUE
                  ELSE FALSE
                  END
             AS BOOLEAN ) 
     , rcon.MATCH_OPTION
     , rcon.UPDATE_RULE
     , rcon.DELETE_RULE
     , tcon.IS_DEFERRABLE
     , tcon.INITIALLY_DEFERRED
  FROM 
       DEFINITION_SCHEMA.REFERENTIAL_CONSTRAINTS  AS rcon
     , DEFINITION_SCHEMA.TABLE_CONSTRAINTS        AS tcon
     , DEFINITION_SCHEMA.KEY_COLUMN_USAGE         AS rkcu
     , DEFINITION_SCHEMA.TABLE_CONSTRAINTS        AS ucon
     , DEFINITION_SCHEMA.KEY_COLUMN_USAGE         AS ukcu
     , DEFINITION_SCHEMA.COLUMNS                  AS rcol
     , DEFINITION_SCHEMA.COLUMNS                  AS ucol
     , DEFINITION_SCHEMA.TABLES                   AS rtab
     , DEFINITION_SCHEMA.TABLES                   AS utab
     , DEFINITION_SCHEMA.SCHEMATA                 AS sch1 
     , DEFINITION_SCHEMA.SCHEMATA                 AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS           AS auth1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS           AS auth2 
 WHERE 
       rcon.CONSTRAINT_ID                = tcon.CONSTRAINT_ID
   AND rcon.UNIQUE_CONSTRAINT_ID         = ucon.CONSTRAINT_ID
   AND tcon.CONSTRAINT_ID                = rkcu.CONSTRAINT_ID
   AND tcon.TABLE_ID                     = rtab.TABLE_ID
   AND rkcu.COLUMN_ID                    = rcol.COLUMN_ID
   AND ucon.CONSTRAINT_ID                = ukcu.CONSTRAINT_ID
   AND ucon.TABLE_ID                     = utab.TABLE_ID
   AND rkcu.POSITION_IN_UNIQUE_CONSTRAINT = ukcu.ORDINAL_POSITION
   AND ukcu.COLUMN_ID                    = ucol.COLUMN_ID
   AND rcon.CONSTRAINT_SCHEMA_ID         = sch1.SCHEMA_ID
   AND rcon.CONSTRAINT_OWNER_ID          = auth1.AUTH_ID
   AND rcon.UNIQUE_CONSTRAINT_SCHEMA_ID  = sch2.SCHEMA_ID
   AND rcon.UNIQUE_CONSTRAINT_OWNER_ID   = auth2.AUTH_ID
   AND ( tcon.TABLE_ID IN ( SELECT pvcol.TABLE_ID 
                              FROM DEFINITION_SCHEMA.COLUMN_PRIVILEGES AS pvcol 
                             WHERE 
                                -- pvcol.PRIVILEGE_TYPE <> 'SELECT'
                                   ( pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                             FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS aucol 
                                                            WHERE aucol.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                         ) 
                                    -- OR  
                                    -- pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                    --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                   )
                          ) 
         OR 
         tcon.TABLE_ID IN ( SELECT pvtab.TABLE_ID 
                              FROM DEFINITION_SCHEMA.TABLE_PRIVILEGES AS pvtab 
                             WHERE 
                                -- pvtab.PRIVILEGE_TYPE <> 'SELECT'
                                   ( pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                             FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS autab 
                                                            WHERE autab.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                         ) 
                                  -- OR  
                                  -- pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                  --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                   )
                         ) 
         OR 
         tcon.TABLE_SCHEMA_ID IN ( SELECT pvsch.SCHEMA_ID 
                                     FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch 
                                    WHERE pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'SELECT TABLE', 'INSERT TABLE', 'DELETE TABLE', 'UPDATE TABLE' ) 
                                      AND ( pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                                    FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS ausch 
                                                                   WHERE ausch.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                                ) 
                                         -- OR  
                                         -- pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                         --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                          )  
                                  ) 
         OR 
         EXISTS ( SELECT GRANTEE_ID  
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES pvdba 
                   WHERE pvdba.PRIVILEGE_TYPE IN ( 'SELECT ANY TABLE', 'INSERT ANY TABLE', 'DELETE ANY TABLE', 'UPDATE ANY TABLE' ) 
                     AND ( pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                   FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS audba 
                                                  WHERE audba.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                ) 
                        -- OR  
                        -- pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                        --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                          )  
                ) 
       ) 
ORDER BY 
      rcon.CONSTRAINT_SCHEMA_ID 
    , rcon.CONSTRAINT_ID
    , rkcu.ORDINAL_POSITION
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
        IS 'Identify the referential constraints defined on tables in this catalog that are accssible to a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.CONSTRAINT_CATALOG
        IS 'catalog name of the referential constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.CONSTRAINT_OWNER
        IS 'owner name who owns the referential constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.CONSTRAINT_SCHEMA
        IS 'schema name of the referential constraint being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.CONSTRAINT_NAME
        IS 'referential constraint name';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.CONSTRAINT_TABLE_NAME
        IS 'name of the table to which the referential constraint being described applies';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.CONSTRAINT_COLUMN_NAME
        IS 'column name of the table to which the referential constraint being described applies';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.ORDINAL_POSITION
        IS 'the ordinal position of the specific column in the referentail constraint being described.';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.UNIQUE_CONSTRAINT_CATALOG
        IS 'catalog name of the unique or primary key constraint applied to the referenced column list being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.UNIQUE_CONSTRAINT_OWNER
        IS 'owner name of the unique or primary key constraint applied to the referenced column list being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.UNIQUE_CONSTRAINT_SCHEMA
        IS 'schema name of the unique or primary key constraint applied to the referenced column list being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.UNIQUE_CONSTRAINT_NAME
        IS 'constraint name of the unique or primary key constraint applied to the referenced column list being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.UNIQUE_CONSTRAINT_TABLE_NAME
        IS 'table name of the unique or primary key constraint applied to the referenced column list being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.UNIQUE_CONSTRAINT_COLUMN_NAME
        IS 'column name of the unique or primary key constraint applied to the referenced column list being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.IS_PRIMARY_KEY
        IS 'whether the constraint applied to the referenced column list being described, is primary key or not';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.MATCH_OPTION
        IS 'the referential constraint that has a match option: the value in ( SIMPLE, PARTIAL, FULL )';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.UPDATE_RULE
        IS 'the referential constraint that has an update rule: the value in ( NO ACTION, RESTRICT, CASCADE, SET NULL, SET DEFAULT )';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.DELETE_RULE
        IS 'the referential constraint that has a delete rule: the value in ( NO ACTION, RESTRICT, CASCADE, SET NULL, SET DEFAULT )';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.IS_DEFERRABLE
        IS 'is a deferrable constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS.INITIALLY_DEFERRED
        IS 'is an initially deferred constraint';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS REFERENTIAL_CONSTRAINTS;
CREATE PUBLIC SYNONYM REFERENTIAL_CONSTRAINTS FOR INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.SCHEMATA
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.SCHEMATA;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.SCHEMATA 
(
       CATALOG_NAME
     , SCHEMA_NAME
     , SCHEMA_OWNER
     , DEFAULT_CHARACTER_SET_CATALOG
     , DEFAULT_CHARACTER_SET_SCHEMA
     , DEFAULT_CHARACTER_SET_NAME
     , SQL_PATH
     , CREATED_TIME
     , MODIFIED_TIME
     , COMMENTS
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , sch.SCHEMA_NAME
     , auth.AUTHORIZATION_NAME
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- sch.DEFAULT_CHARACTER_SET_CATALOG
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- sch.DEFAULT_CHARACTER_SET_SCHEMA
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- sch.DEFAULT_CHARACTER_SET_NAME
     , sch.SQL_PATH
     , sch.CREATED_TIME
     , sch.MODIFIED_TIME
     , sch.COMMENTS
  FROM 
       DEFINITION_SCHEMA.SCHEMATA        AS sch
     , DEFINITION_SCHEMA.AUTHORIZATIONS  AS auth
 WHERE 
       sch.OWNER_ID = auth.AUTH_ID
   AND ( auth.AUTHORIZATION_NAME = CURRENT_USER
         OR
         sch.SCHEMA_ID IN ( SELECT pvcol.SCHEMA_ID 
                              FROM DEFINITION_SCHEMA.COLUMN_PRIVILEGES AS pvcol 
                             WHERE ( pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                             FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS aucol 
                                                            WHERE aucol.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                         ) 
                                  -- OR  
                                  -- pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                  --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                   )
                          ) 
         OR 
         sch.SCHEMA_ID IN ( SELECT pvtab.SCHEMA_ID 
                             FROM DEFINITION_SCHEMA.TABLE_PRIVILEGES AS pvtab 
                            WHERE ( pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                            FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS autab 
                                                           WHERE autab.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                        ) 
                                 -- OR  
                                 -- pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                 --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                  )  
                          ) 
         OR
         sch.SCHEMA_ID IN ( SELECT pvusg.SCHEMA_ID 
                             FROM DEFINITION_SCHEMA.USAGE_PRIVILEGES AS pvusg
                            WHERE ( pvusg.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                            FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS auusg 
                                                           WHERE auusg.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                        ) 
                                 -- OR  
                                 -- pvusg.GRANTEE_ID IN ( SELECT AUTH_ID 
                                 --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                  )  
                          ) 
         OR
         sch.SCHEMA_ID IN ( SELECT pvsch.SCHEMA_ID 
                              FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch 
                                     WHERE ( pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                                     FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS ausch 
                                                                    WHERE ausch.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                                 ) 
                                          -- OR  
                                          -- pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                          --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                           )  
                                   ) 
         OR 
         EXISTS ( SELECT GRANTEE_ID  
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES pvdba 
                   WHERE pvdba.PRIVILEGE_TYPE IN ( 'ALTER SCHEMA', 'DROP SCHEMA', 
                                                   'CREATE ANY TABLE', 'ALTER ANY TABLE', 'DROP ANY TABLE', 
                                                   'SELECT ANY TABLE', 'INSERT ANY TABLE', 'DELETE ANY TABLE', 'UPDATE ANY TABLE', 'LOCK ANY TABLE',
                                                   'CREATE ANY VIEW', 'DROP ANY VIEW', 
                                                   'CREATE ANY SEQUENCE', 'ALTER ANY SEQUENCE', 'DROP ANY SEQUENCE', 'USAGE ANY SEQUENCE',
                                                   'CREATE ANY INDEX', 'ALTER ANY INDEX', 'DROP ANY INDEX' ) 
                     AND ( pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                   FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS audba 
                                                  WHERE audba.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                               ) 
                        -- OR  
                        -- pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                        --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                          )  
                ) 
       ) 
 ORDER BY
       sch.SCHEMA_ID
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.SCHEMATA 
        IS 'Identify the schemata in a catalog that are owned by given user or accessible to given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.SCHEMATA.CATALOG_NAME
        IS 'catalog name of the schema';
COMMENT ON COLUMN INFORMATION_SCHEMA.SCHEMATA.SCHEMA_NAME
        IS 'schema name';
COMMENT ON COLUMN INFORMATION_SCHEMA.SCHEMATA.SCHEMA_OWNER
        IS 'authorization name who owns the schema';
COMMENT ON COLUMN INFORMATION_SCHEMA.SCHEMATA.DEFAULT_CHARACTER_SET_CATALOG
        IS 'catalog name of the default character set for columns and domains in the schemata';
COMMENT ON COLUMN INFORMATION_SCHEMA.SCHEMATA.DEFAULT_CHARACTER_SET_SCHEMA
        IS 'schema name of the default character set for columns and domains in the schemata';
COMMENT ON COLUMN INFORMATION_SCHEMA.SCHEMATA.DEFAULT_CHARACTER_SET_NAME
        IS 'character set name of the default character set for columns and domains in the schemata';
COMMENT ON COLUMN INFORMATION_SCHEMA.SCHEMATA.SQL_PATH
        IS 'character representation of schema path specification';
COMMENT ON COLUMN INFORMATION_SCHEMA.SCHEMATA.CREATED_TIME
        IS 'created time of the schema';
COMMENT ON COLUMN INFORMATION_SCHEMA.SCHEMATA.MODIFIED_TIME
        IS 'last modified time of the schema';
COMMENT ON COLUMN INFORMATION_SCHEMA.SCHEMATA.COMMENTS
        IS 'comments of the schema';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.SCHEMATA TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS SCHEMATA;
CREATE PUBLIC SYNONYM SCHEMATA FOR INFORMATION_SCHEMA.SCHEMATA;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.SEQUENCES
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.SEQUENCES;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.SEQUENCES 
( 
       SEQUENCE_CATALOG
     , SEQUENCE_OWNER
     , SEQUENCE_SCHEMA
     , SEQUENCE_NAME
     , DATA_TYPE
     , NUMERIC_PRECISION
     , NUMERIC_PRECISION_RADIX
     , NUMERIC_SCALE
     , START_VALUE
     , MINIMUM_VALUE
     , MAXIMUM_VALUE
     , INCREMENT
     , CYCLE_OPTION
     , CACHE_SIZE
     , DECLARED_DATA_TYPE
     , DECLARED_NUMERIC_PRECISION
     , DECLARED_NUMERIC_SCALE
     , CREATED_TIME
     , MODIFIED_TIME
     , COMMENTS
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth.AUTHORIZATION_NAME
     , sch.SCHEMA_NAME
     , sqc.SEQUENCE_NAME
     , CAST( 'NATIVE_BIGINT' AS VARCHAR(128 OCTETS) )
     , CAST( 63 AS NUMBER )
     , CAST( 2 AS NUMBER )
     , CAST( 0 AS NUMBER )
     , CAST( sqc.START_VALUE AS NUMBER )
     , CAST( sqc.MINIMUM_VALUE AS NUMBER )
     , CAST( sqc.MAXIMUM_VALUE AS NUMBER )
     , CAST( sqc.INCREMENT AS NUMBER )
     , sqc.CYCLE_OPTION
     , sqc.CACHE_SIZE
     , CAST( NULL AS VARCHAR(128 OCTETS) )
     , CAST( NULL AS NUMBER )
     , CAST( NULL AS NUMBER )
     , sqc.CREATED_TIME
     , sqc.MODIFIED_TIME
     , sqc.COMMENTS
  FROM 
       DEFINITION_SCHEMA.SEQUENCES       AS sqc
     , DEFINITION_SCHEMA.SCHEMATA        AS sch
     , DEFINITION_SCHEMA.AUTHORIZATIONS  AS auth
 WHERE 
       sqc.SCHEMA_ID = sch.SCHEMA_ID
   AND sqc.OWNER_ID  = auth.AUTH_ID
   AND ( sqc.SEQUENCE_ID IN ( SELECT pvusg.OBJECT_ID 
                                FROM DEFINITION_SCHEMA.USAGE_PRIVILEGES AS pvusg
                               WHERE pvusg.OBJECT_TYPE = 'SEQUENCE'
                                 AND ( pvusg.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                               FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS auusg 
                                                              WHERE auusg.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                           ) 
                                    -- OR  
                                    -- pvusg.GRANTEE_ID IN ( SELECT AUTH_ID 
                                    --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                     )  
                            ) 
         OR
         sqc.SCHEMA_ID IN ( SELECT pvsch.SCHEMA_ID 
                              FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch 
                             WHERE pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER SEQUENCE', 'DROP SEQUENCE', 'USAGE SEQUENCE' )
                               AND ( pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                             FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS ausch 
                                                            WHERE ausch.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                          ) 
                                  -- OR  
                                  -- pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                  --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                   )  
                           ) 
         OR 
         EXISTS ( SELECT GRANTEE_ID  
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES pvdba 
                   WHERE pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY SEQUENCE', 'DROP ANY SEQUENCE', 'USAGE ANY SEQUENCE' ) 
                     AND ( pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                   FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS audba 
                                                  WHERE audba.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                               ) 
                        -- OR  
                        -- pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                        --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                          )  
                ) 
       ) 
 ORDER BY
       sqc.SCHEMA_ID
     , sqc.SEQUENCE_ID
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.SEQUENCES 
        IS 'Identify the external sequence generators defined in this catalog that are accesible to a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.SEQUENCE_CATALOG
        IS 'catalog name of the sequence';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.SEQUENCE_OWNER
        IS 'owner name of the sequence';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.SEQUENCE_SCHEMA
        IS 'schema name of the sequence';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.SEQUENCE_NAME
        IS 'sequence name';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.DATA_TYPE
        IS 'the standard name of the data type';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.NUMERIC_PRECISION
        IS 'the numeric precision of the numerical data type';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.NUMERIC_PRECISION_RADIX
        IS 'the radix ( 2 or 10 ) of the precision of the numerical data type';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.NUMERIC_SCALE
        IS 'the numeric scale of the exact numerical data type';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.START_VALUE
        IS 'the start value of the sequence generator';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.MINIMUM_VALUE
        IS 'the minimum value of the sequence generator';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.MAXIMUM_VALUE
        IS 'the maximum value of the sequence generator';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.INCREMENT
        IS 'the increment of the sequence generator';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.CYCLE_OPTION
        IS 'cycle option';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.CACHE_SIZE
        IS 'number of sequence numbers to cache';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.DECLARED_DATA_TYPE
        IS 'the data type name that a user declared';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.DECLARED_NUMERIC_PRECISION
        IS 'the precision value that a user declared';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.DECLARED_NUMERIC_SCALE
        IS 'the scale value that a user declared';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.CREATED_TIME
        IS 'created time of the sequence generator';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.MODIFIED_TIME
        IS 'last modified time of the sequence generator';
COMMENT ON COLUMN INFORMATION_SCHEMA.SEQUENCES.COMMENTS
        IS 'comments of the sequence generator';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.SEQUENCES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS SEQUENCES;
CREATE PUBLIC SYNONYM SEQUENCES FOR INFORMATION_SCHEMA.SEQUENCES;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.SQL_FEATURES
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.SQL_FEATURES;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.SQL_FEATURES
( 
       FEATURE_ID
     , FEATURE_NAME
     , SUB_FEATURE_ID
     , SUB_FEATURE_NAME
     , IS_SUPPORTED
     , IS_VERIFIED_BY
     , COMMENTS
)
AS
SELECT
       ID
     , NAME
     , SUB_ID
     , SUB_NAME
     , IS_SUPPORTED
     , IS_VERIFIED_BY
     , COMMENTS
  FROM 
       DEFINITION_SCHEMA.SQL_CONFORMANCE
 WHERE
       TYPE IN ( 'FEATURE', 'SUBFEATURE' )
 ORDER BY
       ID
     , SUB_ID
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.SQL_FEATURES 
        IS 'List the features and subfeatures of this ISO/IEC 9075 standard, and indicate which of these the SQL-implementation supports.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_FEATURES.FEATURE_ID
        IS 'identifier string of the conformance element';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_FEATURES.FEATURE_NAME
        IS 'descriptive name of the conformance element';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_FEATURES.SUB_FEATURE_ID
        IS 'identifier string of the subfeature, or a single space if not a subfeature';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_FEATURES.SUB_FEATURE_NAME
        IS 'descriptive name of the subfeature, or a single space if not a subfeature';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_FEATURES.IS_SUPPORTED
        IS 'TRUE if an SQL-implementation fully supports that conformance element described when SQL-data in the identified catalog is accessed through that implementation, FALSE if not';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_FEATURES.IS_VERIFIED_BY
        IS 'If full support for the conformance element described has been verified by testing, then the IS_VERIFIED_BY column shall contain information identifying the conformance test used to verify the conformance claim; otherwise, IS_VERIFIED_BY shall be the null value';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_FEATURES.COMMENTS
        IS 'possibly a comment pertaining to the conformance element';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.SQL_FEATURES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS SQL_FEATURES;
CREATE PUBLIC SYNONYM SQL_FEATURES FOR INFORMATION_SCHEMA.SQL_FEATURES;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.SQL_IMPLEMENTATION_INFO
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.SQL_IMPLEMENTATION_INFO;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.SQL_IMPLEMENTATION_INFO
( 
       IMPLEMENTATION_INFO_ID
     , IMPLEMENTATION_INFO_NAME
     , INTEGER_VALUE
     , CHARACTER_VALUE
     , COMMENTS
)
AS
SELECT
       IMPLEMENTATION_INFO_ID
     , IMPLEMENTATION_INFO_NAME
     , CASE WHEN ( INTEGER_VALUE < 0 ) THEN NULL ELSE INTEGER_VALUE END
     , CHARACTER_VALUE
     , COMMENTS
  FROM 
       DEFINITION_SCHEMA.SQL_IMPLEMENTATION_INFO
 ORDER BY
       IMPLEMENTATION_INFO_ID
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.SQL_IMPLEMENTATION_INFO 
        IS 'List the SQL-implementation information items defined in this ISO/IEC 9075 standard and, for each of these, indicate the value supported by the SQL-implementation.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_IMPLEMENTATION_INFO.IMPLEMENTATION_INFO_ID
        IS 'identifier string of the implementation information item';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_IMPLEMENTATION_INFO.IMPLEMENTATION_INFO_NAME
        IS 'descriptive name of the implementation information item';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_IMPLEMENTATION_INFO.INTEGER_VALUE
        IS 'value of the implementation information item, or null if the value is contained in the column CHARACTER_VALUE';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_IMPLEMENTATION_INFO.CHARACTER_VALUE
        IS 'value of the implementation information item, or null if the value is contained in the column INTEGER_VALUE';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_IMPLEMENTATION_INFO.COMMENTS
        IS 'possibly a comment pertaining to the implementation information item';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.SQL_IMPLEMENTATION_INFO TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS SQL_IMPLEMENTATION_INFO;
CREATE PUBLIC SYNONYM SQL_IMPLEMENTATION_INFO FOR INFORMATION_SCHEMA.SQL_IMPLEMENTATION_INFO;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.SQL_PACKAGES
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.SQL_PACKAGES;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.SQL_PACKAGES
( 
       ID
     , NAME
     , IS_SUPPORTED
     , IS_VERIFIED_BY
     , COMMENTS
)
AS
SELECT
       ID
     , NAME
     , IS_SUPPORTED
     , IS_VERIFIED_BY
     , COMMENTS
  FROM 
       DEFINITION_SCHEMA.SQL_CONFORMANCE
 WHERE TYPE = 'PACKAGE'
 ORDER BY
       ID
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.SQL_PACKAGES 
        IS 'List the packages of this ISO/IEC 9075 standard, and indicate which of these the SQL-implementation supports.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_PACKAGES.ID
        IS 'identifier string of the conformance element';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_PACKAGES.NAME
        IS 'descriptive name of the conformance element';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_PACKAGES.IS_SUPPORTED
        IS 'TRUE if an SQL-implementation fully supports that conformance element described when SQL-data in the identified catalog is accessed through that implementation, FALSE if not';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_PACKAGES.IS_VERIFIED_BY
        IS 'If full support for the conformance element described has been verified by testing, then the IS_VERIFIED_BY column shall contain information identifying the conformance test used to verify the conformance claim; otherwise, IS_VERIFIED_BY shall be the null value';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_PACKAGES.COMMENTS
        IS 'possibly a comment pertaining to the conformance element';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.SQL_PACKAGES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS SQL_PACKAGES;
CREATE PUBLIC SYNONYM SQL_PACKAGES FOR INFORMATION_SCHEMA.SQL_PACKAGES;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.SQL_PARTS
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.SQL_PARTS;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.SQL_PARTS
( 
       ID
     , NAME
     , IS_SUPPORTED
     , IS_VERIFIED_BY
     , COMMENTS
)
AS
SELECT
       ID
     , NAME
     , IS_SUPPORTED
     , IS_VERIFIED_BY
     , COMMENTS
  FROM 
       DEFINITION_SCHEMA.SQL_CONFORMANCE
 WHERE TYPE = 'PART'
 ORDER BY
       CAST( ID AS NUMBER )
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.SQL_PARTS 
        IS 'List the parts of this ISO/IEC 9075 standard, and indicate which of these the SQL-implementation supports.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_PARTS.ID
        IS 'identifier string of the conformance element';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_PARTS.NAME
        IS 'descriptive name of the conformance element';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_PARTS.IS_SUPPORTED
        IS 'TRUE if an SQL-implementation fully supports that conformance element described when SQL-data in the identified catalog is accessed through that implementation, FALSE if not';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_PARTS.IS_VERIFIED_BY
        IS 'If full support for the conformance element described has been verified by testing, then the IS_VERIFIED_BY column shall contain information identifying the conformance test used to verify the conformance claim; otherwise, IS_VERIFIED_BY shall be the null value';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_PARTS.COMMENTS
        IS 'possibly a comment pertaining to the conformance element';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.SQL_PARTS TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS SQL_PARTS;
CREATE PUBLIC SYNONYM SQL_PARTS FOR INFORMATION_SCHEMA.SQL_PARTS;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.SQL_SIZING
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.SQL_SIZING;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.SQL_SIZING
( 
       SIZING_ID
     , SIZING_NAME
     , SUPPORTED_VALUE
     , COMMENTS
)
AS
SELECT
       SIZING_ID
     , SIZING_NAME
     , SUPPORTED_VALUE
     , COMMENTS
  FROM 
       DEFINITION_SCHEMA.SQL_SIZING
 ORDER BY
       SIZING_ID
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.SQL_SIZING 
        IS 'List the sizing items of this ISO/IEC 9075 standard, for each of these, indicate the size supported by the SQL-implementation.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_SIZING.SIZING_ID
        IS 'identifier of the sizing item';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_SIZING.SIZING_NAME
        IS 'descriptive name of the sizing item';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_SIZING.SUPPORTED_VALUE
        IS 'value of the sizing item, or 0 if the size is unlimited or cannot be determined, or null if the features for which the sizing item is applicable are not supported';
COMMENT ON COLUMN INFORMATION_SCHEMA.SQL_SIZING.COMMENTS
        IS 'possibly a comment pertaining to the sizing item';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.SQL_SIZING TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS SQL_SIZING;
CREATE PUBLIC SYNONYM SQL_SIZING FOR INFORMATION_SCHEMA.SQL_SIZING;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.STATISTICS
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.STATISTICS;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.STATISTICS 
( 
       TABLE_CATALOG 
     , TABLE_OWNER 
     , TABLE_SCHEMA 
     , TABLE_NAME 
     , STAT_TYPE
     , NON_UNIQUE
     , INDEX_CATALOG
     , INDEX_OWNER
     , INDEX_SCHEMA
     , INDEX_NAME
     , COLUMN_NAME
     , ORDINAL_POSITION
     , IS_ASCENDING_ORDER
     , IS_NULLS_FIRST
     , CARDINALITY
     , PAGES
     , FILTER_CONDITION
     , COMMENTS 
) 
AS
(
SELECT
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) )  -- TABLE_CATALOG 
     , auth2.AUTHORIZATION_NAME                        -- TABLE_OWNER 
     , sch2.SCHEMA_NAME                                -- TABLE_SCHEMA 
     , tab.TABLE_NAME                                  -- TABLE_NAME 
     , CAST( CASE idx.INDEX_TYPE WHEN 'HASH' THEN 'INDEX HASHED'
                                 ELSE 'INDEX OTHER'
                                 END
             AS VARCHAR(32 OCTETS) )                   -- STAT_TYPE
     , NOT idx.IS_UNIQUE                               -- NON_UNIQUE
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) )  -- INDEX_CATALOG
     , auth1.AUTHORIZATION_NAME                        -- INDEX_OWNER
     , sch1.SCHEMA_NAME                                -- INDEX_SCHEMA
     , idx.INDEX_NAME                                  -- INDEX_NAME
     , col.COLUMN_NAME                                 -- COLUMN_NAME
     , CAST( ikey.ORDINAL_POSITION AS NUMBER )         -- ORDINAL_POSITION
     , ikey.IS_ASCENDING_ORDER                         -- IS_ASCENDING_ORDER
     , ikey.IS_NULLS_FIRST                             -- IS_NULLS_FIRST
     , CAST( stat.NUM_DISTINCT AS NUMBER )             -- CARDINALITY
     , CAST( xseg.ALLOC_PAGE_COUNT AS NUMBER )         -- PAGES
     , CAST( NULL AS VARCHAR(1024 OCTETS) )            -- FILTER_CONDITION
     , idx.COMMENTS                                    -- COMMENTS 
  FROM
       DEFINITION_SCHEMA.INDEX_KEY_COLUMN_USAGE AS ikey
     , DEFINITION_SCHEMA.INDEXES                AS idx
       LEFT OUTER JOIN
       DEFINITION_SCHEMA.STAT_INDEX             AS stat
       ON idx.INDEX_ID = stat.INDEX_ID
       LEFT OUTER JOIN
       FIXED_TABLE_SCHEMA.X$SEGMENT             AS xseg
       ON idx.PHYSICAL_ID = xseg.PHYSICAL_ID
     , DEFINITION_SCHEMA.COLUMNS                AS col
     , DEFINITION_SCHEMA.TABLES                 AS tab 
     , DEFINITION_SCHEMA.SCHEMATA               AS sch1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS         AS auth1 
     , DEFINITION_SCHEMA.SCHEMATA               AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS         AS auth2 
 WHERE
       ikey.INDEX_ID          = idx.INDEX_ID
   AND ikey.COLUMN_ID         = col.COLUMN_ID
   AND ikey.TABLE_ID          = tab.TABLE_ID
   AND ikey.INDEX_SCHEMA_ID   = sch1.SCHEMA_ID
   AND ikey.INDEX_OWNER_ID    = auth1.AUTH_ID
   AND ikey.TABLE_SCHEMA_ID   = sch2.SCHEMA_ID
   AND ikey.TABLE_OWNER_ID    = auth2.AUTH_ID
   AND tab.IS_DROPPED = FALSE
   AND ( col.COLUMN_ID IN ( SELECT pvcol.COLUMN_ID 
                             FROM DEFINITION_SCHEMA.COLUMN_PRIVILEGES AS pvcol 
                            WHERE ( pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                            FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS aucol 
                                                           WHERE aucol.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                        ) 
                                   -- OR  
                                   -- pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                   --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                  )
                         ) 
         OR 
         tab.TABLE_ID IN ( SELECT pvtab.TABLE_ID 
                             FROM DEFINITION_SCHEMA.TABLE_PRIVILEGES AS pvtab 
                            WHERE ( pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                            FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS autab 
                                                           WHERE autab.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                        ) 
                                 -- OR  
                                 -- pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                 --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                  )
                          ) 
         OR 
         sch2.SCHEMA_ID IN ( SELECT pvsch.SCHEMA_ID 
                              FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch 
                             WHERE pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER TABLE', 'DROP TABLE', 
                                                             'SELECT TABLE', 'INSERT TABLE', 'DELETE TABLE', 'UPDATE TABLE', 'LOCK TABLE' ) 
                               AND ( pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                             FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS ausch 
                                                            WHERE ausch.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                         ) 
                                  -- OR  
                                  -- pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                  --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                   )
                          ) 
         OR 
         EXISTS ( SELECT GRANTEE_ID  
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES pvdba 
                   WHERE pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY TABLE', 'DROP ANY TABLE', 
                                                   'SELECT ANY TABLE', 'INSERT ANY TABLE', 'DELETE ANY TABLE', 'UPDATE ANY TABLE', 'LOCK ANY TABLE' ) 
                     AND ( pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                   FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS audba 
                                                  WHERE audba.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                               ) 
                        -- OR  
                        -- pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                        --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                         )  
                ) 
       ) 
 ORDER BY 
       ikey.INDEX_SCHEMA_ID
     , ikey.INDEX_ID
     , ikey.ORDINAL_POSITION
) 
UNION ALL
(
SELECT  
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) )  -- TABLE_CATALOG 
     , auth.AUTHORIZATION_NAME                         -- TABLE_OWNER 
     , sch.SCHEMA_NAME                                 -- TABLE_SCHEMA 
     , tab.TABLE_NAME                                  -- TABLE_NAME 
     , CAST( 'TABLE STAT' AS VARCHAR(32 OCTETS) )      -- STAT_TYPE
     , CAST( NULL AS BOOLEAN )                         -- NON_UNIQUE
     , CAST( NULL AS VARCHAR(128 OCTETS) )             -- INDEX_CATALOG
     , CAST( NULL AS VARCHAR(128 OCTETS) )             -- INDEX_OWNER
     , CAST( NULL AS VARCHAR(128 OCTETS) )             -- INDEX_SCHEMA
     , CAST( NULL AS VARCHAR(128 OCTETS) )             -- INDEX_NAME
     , CAST( NULL AS VARCHAR(128 OCTETS) )             -- COLUMN_NAME
     , CAST( NULL AS NUMBER )                          -- ORDINAL_POSITION
     , CAST( NULL AS BOOLEAN )                         -- IS_ASCENDING_ORDER
     , CAST( NULL AS BOOLEAN )                         -- IS_NULLS_FIRST
     , CAST( stat.NUM_ROWS AS NUMBER )                 -- CARDINALITY
     , CAST( xseg.ALLOC_PAGE_COUNT AS NUMBER )         -- PAGES
     , CAST( NULL AS VARCHAR(1024 OCTETS) )            -- FILTER_CONDITION
     , tab.COMMENTS                                    -- COMMENTS 
  FROM  
       DEFINITION_SCHEMA.TABLES           AS tab 
       LEFT OUTER JOIN
       DEFINITION_SCHEMA.STAT_TABLE       AS stat
       ON tab.TABLE_ID = stat.TABLE_ID
       LEFT OUTER JOIN
       FIXED_TABLE_SCHEMA.X$SEGMENT       AS xseg
       ON tab.PHYSICAL_ID = xseg.PHYSICAL_ID
     , DEFINITION_SCHEMA.SCHEMATA         AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth 
 WHERE
       (    tab.TABLE_TYPE = 'BASE TABLE'
         OR tab.TABLE_TYPE = 'GLOBAL TEMPORARY'
         OR tab.TABLE_TYPE = 'IMMUTABLE TABLE' )
   AND tab.SCHEMA_ID   = sch.SCHEMA_ID 
   AND tab.OWNER_ID    = auth.AUTH_ID 
   AND tab.IS_DROPPED = FALSE
   AND ( tab.TABLE_ID IN ( SELECT pvcol.TABLE_ID 
                             FROM DEFINITION_SCHEMA.COLUMN_PRIVILEGES AS pvcol 
                            WHERE ( pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                            FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS aucol 
                                                           WHERE aucol.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                        ) 
                                  -- OR  
                                  -- pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                  --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                  )
                          ) 
         OR 
         tab.TABLE_ID IN ( SELECT pvtab.TABLE_ID 
                             FROM DEFINITION_SCHEMA.TABLE_PRIVILEGES AS pvtab 
                            WHERE ( pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                            FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS autab 
                                                           WHERE autab.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                        ) 
                                 -- OR  
                                 -- pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                 --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                  )
                          ) 
         OR 
         sch.SCHEMA_ID IN ( SELECT pvsch.SCHEMA_ID 
                              FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch 
                             WHERE pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER TABLE', 'DROP TABLE', 
                                                             'SELECT TABLE', 'INSERT TABLE', 'DELETE TABLE', 'UPDATE TABLE', 'LOCK TABLE' ) 
                               AND ( pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                             FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS ausch 
                                                            WHERE ausch.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                         ) 
                                  -- OR  
                                  -- pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                  --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                   )
                          ) 
         OR 
         EXISTS ( SELECT GRANTEE_ID  
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES pvdba 
                   WHERE pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY TABLE', 'DROP ANY TABLE', 
                                                   'SELECT ANY TABLE', 'INSERT ANY TABLE', 'DELETE ANY TABLE', 'UPDATE ANY TABLE', 'LOCK ANY TABLE' ) 
                     AND ( pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                   FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS audba 
                                                  WHERE audba.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                ) 
                        -- OR  
                        -- pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                        --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                          )  
                ) 
       ) 
ORDER BY 
      tab.SCHEMA_ID 
    , tab.TABLE_ID 
)
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.STATISTICS 
        IS 'Provides a list of statistics about a single table and the indexes associated with the table that are accessible to a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.TABLE_CATALOG                    
        IS 'catalog name of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.TABLE_OWNER                      
        IS 'owner name of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.TABLE_SCHEMA                     
        IS 'schema name of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.TABLE_NAME
        IS 'table name of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.STAT_TYPE
        IS 'statistics type: the value in ( TABLE STAT, INDEX CLUSTERED, INDEX HASHED, INDEX OTHER )';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.NON_UNIQUE
        IS 'indicates whether the index does not allow duplicate values';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.INDEX_CATALOG
        IS 'catalog name of the index';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.INDEX_OWNER
        IS 'owner name of the index';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.INDEX_SCHEMA
        IS 'schema name of the index';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.INDEX_NAME
        IS 'name of the index';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.COLUMN_NAME
        IS 'column name that participates in the index';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.ORDINAL_POSITION
        IS 'ordinal position of the specific column in the index described';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.IS_ASCENDING_ORDER
        IS 'index key column being described is sorted in ASCENDING(TRUE) or DESCENDING(FALSE) order';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.IS_NULLS_FIRST
        IS 'the null values of the key column are sorted before(TRUE) or after(FALSE) non-null values';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.CARDINALITY
        IS 'if STAT_TYPE is (TABLE TYPE), then this is the number of rows in the table; otherwise, it is the number of unique values in the index';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.PAGES
        IS 'if STAT_TYPE is (TABLE TYPE), then this is the number of pages used for the table; otherwise, it is the number of pages used for the current index.';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.FILTER_CONDITION
        IS 'filter condition, if any.';
COMMENT ON COLUMN INFORMATION_SCHEMA.STATISTICS.COMMENTS 
        IS 'if STAT_TYPE is (TABLE TYPE), then this is the table comments; otherwise, it is the index comments.';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.STATISTICS TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS STATISTICS;
CREATE PUBLIC SYNONYM STATISTICS FOR INFORMATION_SCHEMA.STATISTICS;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.TABLES
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.TABLES;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.TABLES 
( 
       TABLE_CATALOG 
     , TABLE_OWNER 
     , TABLE_SCHEMA 
     , TABLE_NAME 
     , TABLE_TYPE 
     , DBC_TABLE_TYPE 
     , TABLESPACE_NAME 
     , SYSTEM_VERSION_START_COLUMN_NAME 
     , SYSTEM_VERSION_END_COLUMN_NAME 
     , SYSTEM_VERSION_RETENTION_PERIOD 
     , SELF_REFERENCING_COLUMN_NAME 
     , REFERENCE_GENERATION 
     , USER_DEFINED_TYPE_CATALOG 
     , USER_DEFINED_TYPE_SCHEMA 
     , USER_DEFINED_TYPE_NAME 
     , IS_INSERTABLE_INTO 
     , IS_TYPED 
     , COMMIT_ACTION 
     , CREATED_TIME
     , MODIFIED_TIME
     , COMMENTS 
) 
AS 
SELECT  
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth.AUTHORIZATION_NAME 
     , sch.SCHEMA_NAME 
     , tab.TABLE_NAME 
     , tab.TABLE_TYPE 
     , CAST( CASE WHEN sch.SCHEMA_NAME = 'INFORMATION_SCHEMA' AND tab.TABLE_TYPE = 'VIEW'
                  THEN 'SYSTEM TABLE'
                  ELSE DECODE( tab.TABLE_TYPE, 'BASE TABLE', 'TABLE', tab.TABLE_TYPE )
                  END 
             AS VARCHAR(32 OCTETS) )
     , spc.TABLESPACE_NAME 
     , tab.SYSTEM_VERSION_START_COLUMN_NAME 
     , tab.SYSTEM_VERSION_END_COLUMN_NAME 
     , tab.SYSTEM_VERSION_RETENTION_PERIOD 
     , tab.SELF_REFERENCING_COLUMN_NAME 
     , tab.REFERENCE_GENERATION 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- tab.USER_DEFINED_TYPE_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- tab.USER_DEFINED_TYPE_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- tab.USER_DEFINED_TYPE_NAME 
     , tab.IS_INSERTABLE_INTO 
     , tab.IS_TYPED 
     , tab.COMMIT_ACTION 
     , tab.CREATED_TIME
     , tab.MODIFIED_TIME
     , tab.COMMENTS 
  FROM  
       ( INFORMATION_SCHEMA.WHOLE_TABLES    AS tab 
         LEFT OUTER JOIN 
         DEFINITION_SCHEMA.TABLESPACES      AS spc  
         ON tab.TABLESPACE_ID = spc.TABLESPACE_ID ) 
     , DEFINITION_SCHEMA.SCHEMATA           AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS     AS auth 
 WHERE 
       tab.SCHEMA_ID = sch.SCHEMA_ID 
   AND tab.OWNER_ID  = auth.AUTH_ID 
   AND ( tab.TABLE_ID IN ( SELECT pvcol.TABLE_ID 
                              FROM DEFINITION_SCHEMA.COLUMN_PRIVILEGES AS pvcol 
                             WHERE ( pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                             FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS aucol 
                                                            WHERE aucol.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                         ) 
                                  -- OR  
                                  -- pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                  --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                   )
                          ) 
         OR 
         tab.TABLE_ID IN ( SELECT pvtab.TABLE_ID 
                             FROM DEFINITION_SCHEMA.TABLE_PRIVILEGES AS pvtab 
                            WHERE ( pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                            FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS autab 
                                                           WHERE autab.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                        ) 
                                 -- OR  
                                 -- pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                 --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                  )
                          ) 
         OR 
         tab.SCHEMA_ID IN ( SELECT pvsch.SCHEMA_ID 
                              FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch 
                             WHERE pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER TABLE', 'DROP TABLE', 
                                                             'SELECT TABLE', 'INSERT TABLE', 'DELETE TABLE', 'UPDATE TABLE', 'LOCK TABLE' ) 
                               AND ( pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                             FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS ausch 
                                                            WHERE ausch.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                         ) 
                                  -- OR  
                                  -- pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                  --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                   )
                          ) 
         OR 
         EXISTS ( SELECT GRANTEE_ID  
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES pvdba 
                   WHERE pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY TABLE', 'DROP ANY TABLE', 
                                                   'SELECT ANY TABLE', 'INSERT ANY TABLE', 'DELETE ANY TABLE', 'UPDATE ANY TABLE', 'LOCK ANY TABLE' ) 
                     AND ( pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                   FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS audba 
                                                  WHERE audba.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                ) 
                        -- OR  
                        -- pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                        --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                          )  
                ) 
       ) 
ORDER BY 
      tab.SCHEMA_ID 
    , tab.TABLE_ID 
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.TABLES 
        IS 'Identify the tables defined in this catalog that are accessible to a given user or role';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.TABLE_CATALOG                    
        IS 'catalog name of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.TABLE_OWNER                      
        IS 'owner name of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.TABLE_SCHEMA                     
        IS 'schema name of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.TABLE_NAME                       
        IS 'table name of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.TABLE_TYPE                       
        IS 'the value is in ( BASE TABLE, VIEW, GLOBAL TEMPORARY, LOCAL TEMPORARY, SYSTEM VERSIONED, FIXED TABLE, DUMP TABLE, IMMUTABLE TABLE )';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.DBC_TABLE_TYPE                       
        IS 'ODBC/JDBC table type: the value is in ( TABLE, VIEW, GLOBAL TEMPORARY, LOCAL TEMPORARY, SYSTEM TABLE, ALIAS, SYNONYM, IMMUTABLE TABLE )';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.TABLESPACE_NAME                  
        IS 'tablespace name of the table, NULL if view';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.SYSTEM_VERSION_START_COLUMN_NAME 
        IS 'if the table is a system-versioned table, then the name of the system-version start column of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.SYSTEM_VERSION_END_COLUMN_NAME   
        IS 'if the table is a system-versioned table, then the name of the system-version end column of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.SYSTEM_VERSION_RETENTION_PERIOD  
        IS 'if the table is a system-versioned table, then the character representation of the value of the retention period of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.SELF_REFERENCING_COLUMN_NAME     
        IS 'if the table is a typed table, then the name of the self-referencing column of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.REFERENCE_GENERATION             
        IS 'if the table has a self-referencing column, the value is in ( SYSTEM GENERATED, USER GENERATED, DERIVED )';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.USER_DEFINED_TYPE_CATALOG        
        IS 'if the table being described is a table of a structured type, the catalog name of the structured type';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.USER_DEFINED_TYPE_SCHEMA         
        IS 'if the table being described is a table of a structured type, the schema name of the structured type';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.USER_DEFINED_TYPE_NAME           
        IS 'if the table being described is a table of a structured type, the name of the structured type';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.IS_INSERTABLE_INTO               
        IS 'is an insertable-into table';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.IS_TYPED                         
        IS 'is a typed table';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.COMMIT_ACTION                    
        IS 'if the table is a temporary table, the value is in ( DELETE, PRESERVE )';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.CREATED_TIME                    
        IS 'created time of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.MODIFIED_TIME                    
        IS 'last modified time of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLES.COMMENTS                         
        IS 'comments of the table';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.TABLES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS TABLES;
CREATE PUBLIC SYNONYM TABLES FOR INFORMATION_SCHEMA.TABLES;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.TABLE_CONSTRAINTS
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.TABLE_CONSTRAINTS;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
(
       CONSTRAINT_CATALOG
     , CONSTRAINT_OWNER
     , CONSTRAINT_SCHEMA
     , CONSTRAINT_NAME
     , TABLE_CATALOG 
     , TABLE_OWNER 
     , TABLE_SCHEMA 
     , TABLE_NAME 
     , CONSTRAINT_TYPE
     , IS_DEFERRABLE
     , INITIALLY_DEFERRED
     , ENFORCED
     , CREATED_TIME
     , MODIFIED_TIME
     , COMMENTS
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth1.AUTHORIZATION_NAME
     , sch1.SCHEMA_NAME
     , const.CONSTRAINT_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth2.AUTHORIZATION_NAME
     , sch2.SCHEMA_NAME
     , tab.TABLE_NAME
     , const.CONSTRAINT_TYPE
     , const.IS_DEFERRABLE
     , const.INITIALLY_DEFERRED
     , const.ENFORCED
     , const.CREATED_TIME
     , const.MODIFIED_TIME
     , const.COMMENTS
  FROM 
       DEFINITION_SCHEMA.TABLE_CONSTRAINTS  AS const
     , DEFINITION_SCHEMA.TABLES             AS tab 
     , DEFINITION_SCHEMA.SCHEMATA           AS sch1 
     , DEFINITION_SCHEMA.SCHEMATA           AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS     AS auth1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS     AS auth2 
 WHERE 
       const.TABLE_ID             = tab.TABLE_ID
   AND const.CONSTRAINT_SCHEMA_ID = sch1.SCHEMA_ID
   AND const.CONSTRAINT_OWNER_ID  = auth1.AUTH_ID
   AND const.TABLE_SCHEMA_ID      = sch2.SCHEMA_ID
   AND const.TABLE_OWNER_ID       = auth2.AUTH_ID
   AND tab.IS_DROPPED = FALSE
   AND ( const.TABLE_ID IN ( SELECT pvcol.TABLE_ID 
                               FROM DEFINITION_SCHEMA.COLUMN_PRIVILEGES AS pvcol 
                              WHERE 
                                 -- pvcol.PRIVILEGE_TYPE <> 'SELECT'
                                    ( pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                              FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS aucol 
                                                             WHERE aucol.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                          ) 
                                     -- OR  
                                     -- pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                     --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                    )
                           ) 
         OR 
         const.TABLE_ID IN ( SELECT pvtab.TABLE_ID 
                               FROM DEFINITION_SCHEMA.TABLE_PRIVILEGES AS pvtab 
                              WHERE 
                                 -- pvtab.PRIVILEGE_TYPE <> 'SELECT'
                                    ( pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                              FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS autab 
                                                             WHERE autab.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                          ) 
                                   -- OR  
                                   -- pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                   --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                    )
                          ) 
         OR 
         const.TABLE_SCHEMA_ID IN ( SELECT pvsch.SCHEMA_ID 
                                      FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch 
                                     WHERE pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'SELECT TABLE', 'INSERT TABLE', 'DELETE TABLE', 'UPDATE TABLE' ) 
                                       AND ( pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                                     FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS ausch 
                                                                    WHERE ausch.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                                 ) 
                                          -- OR  
                                          -- pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                          --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                           )  
                                   ) 
         OR 
         EXISTS ( SELECT GRANTEE_ID  
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES pvdba 
                   WHERE pvdba.PRIVILEGE_TYPE IN ( 'SELECT ANY TABLE', 'INSERT ANY TABLE', 'DELETE ANY TABLE', 'UPDATE ANY TABLE' ) 
                     AND ( pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                   FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS audba 
                                                  WHERE audba.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                ) 
                        -- OR  
                        -- pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                        --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                          )  
                ) 
       ) 
ORDER BY 
      const.TABLE_SCHEMA_ID 
    , const.TABLE_ID 
    , const.CONSTRAINT_ID
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
        IS 'Identify the table constraints defined on tables in this catalog that are accessible to a given user or role';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.CONSTRAINT_CATALOG
        IS 'catalog name of the constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.CONSTRAINT_OWNER
        IS 'authorization name who owns the constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.CONSTRAINT_SCHEMA
        IS 'schema name of the constraint being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.CONSTRAINT_NAME
        IS 'constraint name';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.TABLE_CATALOG
        IS 'catalog name of the table to which the table constraint being described applies';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.TABLE_OWNER 
        IS 'authorization name who owns the table to to which the table constraint being described applies';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.TABLE_SCHEMA
        IS 'schema name of the table to to which the table constraint being described applies';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.TABLE_NAME 
        IS 'table name of the table to to which the table constraint being described applies';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.CONSTRAINT_TYPE
        IS 'the value is in ( PRIMARY KEY, UNIQUE, FOREIGN KEY, NOT NULL, CHECK )';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.IS_DEFERRABLE
        IS 'is a deferrable constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.INITIALLY_DEFERRED
        IS 'is an initially deferred constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.ENFORCED
        IS 'is an enforced constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.CREATED_TIME
        IS 'created time of the constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.MODIFIED_TIME
        IS 'last modified time of the constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_CONSTRAINTS.COMMENTS
        IS 'comments of the constraint';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.TABLE_CONSTRAINTS TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS TABLE_CONSTRAINTS;
CREATE PUBLIC SYNONYM TABLE_CONSTRAINTS FOR INFORMATION_SCHEMA.TABLE_CONSTRAINTS;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.TABLE_PRIVILEGES
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.TABLE_PRIVILEGES;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.TABLE_PRIVILEGES
( 
       GRANTOR
     , GRANTEE
     , TABLE_CATALOG
     , TABLE_OWNER 
     , TABLE_SCHEMA 
     , TABLE_NAME 
     , PRIVILEGE_TYPE
     , IS_GRANTABLE
     , WITH_HIERARCHY
)
AS
SELECT
       grantor.AUTHORIZATION_NAME
     , grantee.AUTHORIZATION_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , owner.AUTHORIZATION_NAME
     , sch.SCHEMA_NAME
     , tab.TABLE_NAME
     , pvtab.PRIVILEGE_TYPE
     , pvtab.IS_GRANTABLE
     , pvtab.WITH_HIERARCHY
  FROM
       DEFINITION_SCHEMA.TABLE_PRIVILEGES  AS pvtab
     , DEFINITION_SCHEMA.TABLES            AS tab 
     , DEFINITION_SCHEMA.SCHEMATA          AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS    AS grantor
     , DEFINITION_SCHEMA.AUTHORIZATIONS    AS grantee
     , DEFINITION_SCHEMA.AUTHORIZATIONS    AS owner
 WHERE
       pvtab.TABLE_ID   = tab.TABLE_ID
   AND pvtab.SCHEMA_ID  = sch.SCHEMA_ID
   AND pvtab.GRANTOR_ID = grantor.AUTH_ID
   AND pvtab.GRANTEE_ID = grantee.AUTH_ID
   AND tab.OWNER_ID     = owner.AUTH_ID
   AND tab.IS_DROPPED = FALSE
   AND ( grantee.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )
      -- OR  
      -- pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
      --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
         OR
         grantor.AUTHORIZATION_NAME = CURRENT_USER
       )
 ORDER BY 
       pvtab.SCHEMA_ID
     , pvtab.TABLE_ID
     , pvtab.GRANTOR_ID
     , pvtab.GRANTEE_ID
     , pvtab.PRIVILEGE_TYPE_ID   
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.TABLE_PRIVILEGES
        IS 'Identify the privileges on tables of tables defined in this catalog that are available to or granted by a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_PRIVILEGES.GRANTOR
        IS 'authorization name of the user who granted table privileges';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_PRIVILEGES.GRANTEE
        IS 'authorization name of some user or role, or PUBLIC to indicate all users, to whom the table privilege being described is granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_PRIVILEGES.TABLE_CATALOG
        IS 'catalog name of the table on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_PRIVILEGES.TABLE_OWNER 
        IS 'table owner name of the table on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_PRIVILEGES.TABLE_SCHEMA 
        IS 'schema name of the table on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_PRIVILEGES.TABLE_NAME 
        IS 'table name on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_PRIVILEGES.PRIVILEGE_TYPE
        IS 'the value is in ( CONTROL, SELECT, INSERT, UPDATE, DELETE, REFERENCES, LOCK, INDEX, ALTER )';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_PRIVILEGES.IS_GRANTABLE
        IS 'is grantable';
COMMENT ON COLUMN INFORMATION_SCHEMA.TABLE_PRIVILEGES.WITH_HIERARCHY
        IS 'whether the privilege was granted WITH HIERARCHY OPTION or not';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.TABLE_PRIVILEGES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS TABLE_PRIVILEGES;
CREATE PUBLIC SYNONYM TABLE_PRIVILEGES FOR INFORMATION_SCHEMA.TABLE_PRIVILEGES;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.USAGE_PRIVILEGES
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.USAGE_PRIVILEGES;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.USAGE_PRIVILEGES
( 
       GRANTOR
     , GRANTEE
     , OBJECT_CATALOG
     , OBJECT_OWNER 
     , OBJECT_SCHEMA 
     , OBJECT_NAME 
     , OBJECT_TYPE
     , PRIVILEGE_TYPE
     , IS_GRANTABLE
)
AS
SELECT
       grantor.AUTHORIZATION_NAME
     , grantee.AUTHORIZATION_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , owner.AUTHORIZATION_NAME
     , sch.SCHEMA_NAME
     , sqc.SEQUENCE_NAME
     , usg.OBJECT_TYPE
     , CAST( 'USAGE' AS VARCHAR(32 OCTETS) )
     , usg.IS_GRANTABLE
  FROM
       DEFINITION_SCHEMA.USAGE_PRIVILEGES  AS usg
     , DEFINITION_SCHEMA.SEQUENCES         AS sqc
     , DEFINITION_SCHEMA.SCHEMATA          AS sch
     , DEFINITION_SCHEMA.AUTHORIZATIONS    AS grantor
     , DEFINITION_SCHEMA.AUTHORIZATIONS    AS grantee
     , DEFINITION_SCHEMA.AUTHORIZATIONS    AS owner
 WHERE
       usg.OBJECT_ID    = sqc.SEQUENCE_ID
   AND usg.SCHEMA_ID    = sch.SCHEMA_ID
   AND usg.GRANTOR_ID   = grantor.AUTH_ID
   AND usg.GRANTEE_ID   = grantee.AUTH_ID
   AND sqc.OWNER_ID     = owner.AUTH_ID
   AND ( grantee.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )
      -- OR  
      -- pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
      --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
         OR
         grantor.AUTHORIZATION_NAME = CURRENT_USER
       )
 ORDER BY 
       usg.SCHEMA_ID
     , usg.OBJECT_ID
     , usg.GRANTOR_ID
     , usg.GRANTEE_ID
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.USAGE_PRIVILEGES
        IS 'Identify the USAGE privileges on objects defined in this catalog that are available to or granted by a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.USAGE_PRIVILEGES.GRANTOR
        IS 'authorization name of the user who granted usage privileges, on the object of the type identified by OBJECT_TYPE';
COMMENT ON COLUMN INFORMATION_SCHEMA.USAGE_PRIVILEGES.GRANTEE
        IS 'authorization identifier of some user or role, or PUBLIC to indicate all users, to whom the usage privilege being described is granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.USAGE_PRIVILEGES.OBJECT_CATALOG
        IS 'catalog name of the object of the type identified by OBJECT_TYPE on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.USAGE_PRIVILEGES.OBJECT_OWNER 
        IS 'owner name of the object of the type identified by OBJECT_TYPE on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.USAGE_PRIVILEGES.OBJECT_SCHEMA 
        IS 'schema name of the object of the type identified by OBJECT_TYPE on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.USAGE_PRIVILEGES.OBJECT_NAME 
        IS 'object name of the type identified by OBJECT_TYPE on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.USAGE_PRIVILEGES.OBJECT_TYPE 
        IS 'the value is in ( DOMAIN, CHARACTER SET, COLLATION, TRANSLATION, SEQUENCE )';
COMMENT ON COLUMN INFORMATION_SCHEMA.USAGE_PRIVILEGES.PRIVILEGE_TYPE
        IS 'the value is in ( USAGE )';
COMMENT ON COLUMN INFORMATION_SCHEMA.USAGE_PRIVILEGES.IS_GRANTABLE
        IS 'is grantable';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.USAGE_PRIVILEGES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS USAGE_PRIVILEGES;
CREATE PUBLIC SYNONYM USAGE_PRIVILEGES FOR INFORMATION_SCHEMA.USAGE_PRIVILEGES;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.VIEWS
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.VIEWS;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.VIEWS
(
       TABLE_CATALOG
     , TABLE_OWNER
     , TABLE_SCHEMA
     , TABLE_NAME
     , VIEW_DEFINITION
     , CHECK_OPTION
     , IS_UPDATABLE
     , INSERTABLE_INTO
     , IS_TRIGGER_UPDATABLE
     , IS_TRIGGER_DELETABLE
     , IS_TRIGGER_INSERTABLE_INTO
     , IS_COMPILED
     , IS_AFFECTED
     , COMMENTS
)
AS
SELECT
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth1.AUTHORIZATION_NAME
     , sch.SCHEMA_NAME
     , tab.TABLE_NAME
     , CASE WHEN ( CURRENT_USER IN ( auth1.AUTHORIZATION_NAME, auth2.AUTHORIZATION_NAME ) ) THEN viw.VIEW_DEFINITION ELSE CAST( 'not owner' AS LONG VARCHAR ) END
     , viw.CHECK_OPTION
     , viw.IS_UPDATABLE
     , tab.IS_INSERTABLE_INTO
     , viw.IS_TRIGGER_UPDATABLE
     , viw.IS_TRIGGER_DELETABLE
     , viw.IS_TRIGGER_INSERTABLE_INTO
     , viw.IS_COMPILED
     , viw.IS_AFFECTED
     , tab.COMMENTS
  FROM 
       DEFINITION_SCHEMA.VIEWS            AS viw
     , DEFINITION_SCHEMA.TABLES           AS tab 
     , DEFINITION_SCHEMA.SCHEMATA         AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth2 
 WHERE 
       viw.TABLE_ID  = tab.TABLE_ID
   AND viw.SCHEMA_ID = sch.SCHEMA_ID 
   AND viw.OWNER_ID  = auth1.AUTH_ID 
   AND sch.OWNER_ID  = auth2.AUTH_ID
   AND ( viw.TABLE_ID IN ( SELECT pvcol.TABLE_ID 
                             FROM DEFINITION_SCHEMA.COLUMN_PRIVILEGES AS pvcol 
                            WHERE ( pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                            FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS aucol 
                                                           WHERE aucol.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                        ) 
                                 -- OR  
                                 -- pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
                                 --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                  )
                         ) 
         OR 
         viw.TABLE_ID IN ( SELECT pvtab.TABLE_ID 
                             FROM DEFINITION_SCHEMA.TABLE_PRIVILEGES AS pvtab 
                            WHERE ( pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                            FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS autab 
                                                           WHERE autab.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                        ) 
                                 -- OR  
                                 -- pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                 --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                  )
                          ) 
         OR 
         viw.SCHEMA_ID IN ( SELECT pvsch.SCHEMA_ID 
                              FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch 
                             WHERE pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'DROP VIEW', 
                                                             'SELECT TABLE', 'INSERT TABLE', 'DELETE TABLE', 'UPDATE TABLE', 'LOCK TABLE' ) 
                               AND ( pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                             FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS ausch 
                                                            WHERE ausch.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                         ) 
                                  -- OR  
                                  -- pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                  --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                   )
                          ) 
         OR 
         EXISTS ( SELECT GRANTEE_ID  
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES pvdba 
                   WHERE pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY TABLE', 'DROP ANY VIEW', 
                                                   'SELECT ANY TABLE', 'INSERT ANY TABLE', 'DELETE ANY TABLE', 'UPDATE ANY TABLE', 'LOCK ANY TABLE' ) 
                     AND ( pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                   FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS audba 
                                                  WHERE audba.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                ) 
                        -- OR  
                        -- pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                        --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                          )  
                ) 
       ) 
ORDER BY 
      viw.SCHEMA_ID 
    , viw.TABLE_ID 
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.VIEWS
        IS 'Identify the viewed tables defined in this catalog that are accessible to a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.VIEWS.TABLE_CATALOG
        IS 'catalog name of the viewed table';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEWS.TABLE_OWNER
        IS 'owner name of the viewed table';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEWS.TABLE_SCHEMA
        IS 'schema name of the viewed table';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEWS.TABLE_NAME
        IS 'view name of the viewed table';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEWS.VIEW_DEFINITION
        IS 'the character representation of the user-specified query expression contained in the corresponding view descriptor';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEWS.CHECK_OPTION
        IS 'the value is in ( CASCADED, LOCAL, NONE )';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEWS.IS_UPDATABLE
        IS 'is an updatable view';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEWS.INSERTABLE_INTO
        IS 'is an insertable view';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEWS.IS_TRIGGER_UPDATABLE
        IS 'whether an update INSTEAD OF trigger is defined on the view or not';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEWS.IS_TRIGGER_DELETABLE
        IS 'whether a delete INSTEAD OF trigger is defined on the view or not';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEWS.IS_TRIGGER_INSERTABLE_INTO
        IS 'whether an insert INSTEAD OF trigger is defined on the view or not';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEWS.IS_COMPILED
        IS 'whether the view is compiled or not';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEWS.IS_AFFECTED
        IS 'whether the view is affected by modification of underlying object or not';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEWS.COMMENTS
        IS 'comments of the view';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.VIEWS TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS VIEWS;
CREATE PUBLIC SYNONYM VIEWS FOR INFORMATION_SCHEMA.VIEWS;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.VIEW_TABLE_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.VIEW_TABLE_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.VIEW_TABLE_USAGE
(
       VIEW_CATALOG
     , VIEW_OWNER
     , VIEW_SCHEMA
     , VIEW_NAME
     , TABLE_CATALOG
     , TABLE_OWNER
     , TABLE_SCHEMA
     , TABLE_NAME
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth1.AUTHORIZATION_NAME
     , sch1.SCHEMA_NAME
     , tab1.TABLE_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth2.AUTHORIZATION_NAME
     , sch2.SCHEMA_NAME
     , tab2.TABLE_NAME
  FROM 
       DEFINITION_SCHEMA.VIEW_TABLE_USAGE AS vtu
     , INFORMATION_SCHEMA.WHOLE_TABLES    AS tab1 
     , INFORMATION_SCHEMA.WHOLE_TABLES    AS tab2 
     , DEFINITION_SCHEMA.SCHEMATA         AS sch1 
     , DEFINITION_SCHEMA.SCHEMATA         AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth2 
 WHERE 
       vtu.VIEW_ID         = tab1.TABLE_ID
   AND vtu.VIEW_SCHEMA_ID  = sch1.SCHEMA_ID 
   AND vtu.VIEW_OWNER_ID   = auth1.AUTH_ID 
   AND vtu.TABLE_ID        = tab2.TABLE_ID
   AND vtu.TABLE_SCHEMA_ID = sch2.SCHEMA_ID 
   AND vtu.TABLE_OWNER_ID  = auth2.AUTH_ID 
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR 
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       ) 
ORDER BY 
      vtu.VIEW_SCHEMA_ID 
    , vtu.VIEW_ID 
    , vtu.TABLE_SCHEMA_ID
    , vtu.TABLE_ID
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.VIEW_TABLE_USAGE
        IS 'Identify the tables on which viewed tables defined in this catalog and owned by a given user or role are dependent.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_TABLE_USAGE.VIEW_CATALOG
        IS 'catalog name of the viewed table';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_TABLE_USAGE.VIEW_OWNER
        IS 'owner name of the viewed table';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_TABLE_USAGE.VIEW_SCHEMA
        IS 'schema name of the viewed table';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_TABLE_USAGE.VIEW_NAME
        IS 'view name of the viewed table';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_TABLE_USAGE.TABLE_CATALOG
        IS 'catalog name of a table that is explicitly or implicitly referenced in the original query expression of the compiled view being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_TABLE_USAGE.TABLE_OWNER
        IS 'owner name of a table that is explicitly or implicitly referenced in the original query expression of the compiled view being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_TABLE_USAGE.TABLE_SCHEMA
        IS 'schema name of a table that is explicitly or implicitly referenced in the original query expression of the compiled view being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_TABLE_USAGE.TABLE_NAME
        IS 'table name of a table that is explicitly or implicitly referenced in the original query expression of the compiled view being described';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.VIEW_TABLE_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS VIEW_TABLE_USAGE;
CREATE PUBLIC SYNONYM VIEW_TABLE_USAGE FOR INFORMATION_SCHEMA.VIEW_TABLE_USAGE;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.VIEW_ROUTINE_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.VIEW_ROUTINE_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.VIEW_ROUTINE_USAGE
(
       TABLE_CATALOG
     , TABLE_OWNER
     , TABLE_SCHEMA
     , TABLE_NAME
     , SPECIFIC_CATALOG
     , SPECIFIC_OWNER
     , SPECIFIC_SCHEMA
     , SPECIFIC_NAME
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- TABLE_CATALOG
     , auth1.AUTHORIZATION_NAME                       -- TABLE_OWNER
     , sch1.SCHEMA_NAME                               -- TABLE_SCHEMA
     , tab1.TABLE_NAME                                -- TABLE_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- SPECIFIC_CATALOG
     , auth2.AUTHORIZATION_NAME                       -- SPECIFIC_OWNER
     , sch2.SCHEMA_NAME                               -- SPECIFIC_SCHEMA
     , rtn.SPECIFIC_NAME                              -- SPECIFIC_NAME
  FROM 
       DEFINITION_SCHEMA.VIEW_ROUTINE_USAGE AS vru
     , DEFINITION_SCHEMA.TABLES           AS tab1 
     , DEFINITION_SCHEMA.SCHEMATA         AS sch1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth1
     , DEFINITION_SCHEMA.ROUTINES         AS rtn
     , DEFINITION_SCHEMA.SCHEMATA         AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth2
 WHERE 
       vru.TABLE_ID          = tab1.TABLE_ID
   AND vru.TABLE_SCHEMA_ID   = sch1.SCHEMA_ID 
   AND vru.TABLE_OWNER_ID    = auth1.AUTH_ID 
   AND vru.SPECIFIC_ID        = rtn.SPECIFIC_ID 
   AND vru.SPECIFIC_SCHEMA_ID = sch2.SCHEMA_ID
   AND vru.SPECIFIC_OWNER_ID  = auth2.AUTH_ID 
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR 
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       ) 
ORDER BY 
      vru.TABLE_SCHEMA_ID 
    , vru.TABLE_ID 
    , vru.SPECIFIC_SCHEMA_ID
    , vru.SPECIFIC_ID
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.VIEW_ROUTINE_USAGE
        IS 'Identify each routine owned by a given user or role on which a view defined in this catalog is dependent.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_ROUTINE_USAGE.TABLE_CATALOG
        IS 'catalog name of the viewed table';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_ROUTINE_USAGE.TABLE_OWNER
        IS 'owner name of the viewed table';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_ROUTINE_USAGE.TABLE_SCHEMA
        IS 'schema name of the viewed table';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_ROUTINE_USAGE.TABLE_NAME
        IS 'table name of the viewed table';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_ROUTINE_USAGE.SPECIFIC_CATALOG
        IS 'specific catalog name of a routine contained in the query expression of the view being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_ROUTINE_USAGE.SPECIFIC_OWNER
        IS 'specific owner name of a routine contained in the query expression of the view being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_ROUTINE_USAGE.SPECIFIC_SCHEMA
        IS 'specific schema name of a routine contained in the query expression of the view being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_ROUTINE_USAGE.SPECIFIC_NAME
        IS 'specific name of a routine contained in the query expression of the view being described';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.VIEW_ROUTINE_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS VIEW_ROUTINE_USAGE;
CREATE PUBLIC SYNONYM VIEW_ROUTINE_USAGE FOR INFORMATION_SCHEMA.VIEW_ROUTINE_USAGE;
COMMIT;



--##############################################################
--# INFORMATION_SCHEMA.ROUTINES
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.ROUTINES;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.ROUTINES
(
       SPECIFIC_CATALOG
     , SPECIFIC_OWNER
     , SPECIFIC_SCHEMA
     , SPECIFIC_NAME
     , ROUTINE_CATALOG
     , ROUTINE_OWNER
     , ROUTINE_SCHEMA
     , ROUTINE_NAME
     , ROUTINE_TYPE
     , MODULE_CATALOG
     , MODULE_SCHEMA
     , MODULE_NAME
     , UDT_CATALOG
     , UDT_SCHEMA
     , UDT_NAME
     , DATA_TYPE
     , CHARACTER_MAXIMUM_LENGTH
     , CHARACTER_OCTET_LENGTH
     , CHARACTER_SET_CATALOG
     , CHARACTER_SET_SCHEMA
     , CHARACTER_SET_NAME
     , COLLATION_CATALOG
     , COLLATION_SCHEMA
     , COLLATION_NAME
     , NUMERIC_PRECISION
     , NUMERIC_PRECISION_RADIX
     , NUMERIC_SCALE
     , DATETIME_PRECISION
     , INTERVAL_TYPE
     , INTERVAL_PRECISION
     , TYPE_UDT_CATALOG
     , TYPE_UDT_SCHEMA
     , TYPE_UDT_NAME
     , SCOPE_CATALOG
     , SCOPE_SCHEMA
     , SCOPE_NAME
     , MAXIMUM_CARDINALITY
     , DTD_IDENTIFIER
     , ROUTINE_BODY
     , ROUTINE_DEFINITION
     , EXTERNAL_NAME
     , EXTERNAL_LANGUAGE
     , PARAMETER_STYLE
     , IS_DETERMINISTIC
     , SQL_DATA_ACCESS
     , IS_NULL_CALL
     , SQL_PATH
     , SCHEMA_LEVEL_ROUTINE
     , MAX_DYNAMIC_RESULT_SETS
     , IS_USER_DEFINED_CAST
     , IS_IMPLICITLY_INVOCABLE
     , SECURITY_TYPE
     , TO_SQL_SPECIFIC_CATALOG
     , TO_SQL_SPECIFIC_SCHEMA
     , TO_SQL_SPECIFIC_NAME
     , AS_LOCATOR
     , CREATED
     , LAST_ALTERED
     , NEW_SAVEPOINT_LEVEL
     , IS_UDT_DEPENDENT
     , RESULT_CAST_FROM_DATA_TYPE
     , RESULT_CAST_AS_LOCATOR
     , RESULT_CAST_CHAR_MAX_LENGTH
     , RESULT_CAST_CHAR_OCTET_LENGTH
     , RESULT_CAST_CHAR_SET_CATALOG
     , RESULT_CAST_CHAR_SET_SCHEMA
     , RESULT_CAST_CHARACTER_SET_NAME
     , RESULT_CAST_COLLATION_CATALOG
     , RESULT_CAST_COLLATION_SCHEMA
     , RESULT_CAST_COLLATION_NAME
     , RESULT_CAST_NUMERIC_PRECISION
     , RESULT_CAST_NUMERIC_RADIX
     , RESULT_CAST_NUMERIC_SCALE
     , RESULT_CAST_DATETIME_PRECISION
     , RESULT_CAST_INTERVAL_TYPE
     , RESULT_CAST_INTERVAL_PRECISION
     , RESULT_CAST_TYPE_UDT_CATALOG
     , RESULT_CAST_TYPE_UDT_SCHEMA
     , RESULT_CAST_TYPE_UDT_NAME
     , RESULT_CAST_SCOPE_CATALOG
     , RESULT_CAST_SCOPE_SCHEMA
     , RESULT_CAST_SCOPE_NAME
     , RESULT_CAST_MAX_CARDINALITY
     , RESULT_CAST_DTD_IDENTIFIER
     , DECLARED_DATA_TYPE
     , DECLARED_NUMERIC_PRECISION
     , DECLARED_NUMERIC_SCALE
     , RESULT_CAST_FROM_DECLARED_DATA_TYPE
     , RESULT_CAST_DECLARED_NUMERIC_PRECISION
     , RESULT_CAST_DECLARED_NUMERIC_SCALE
)
AS
(
SELECT
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth.AUTHORIZATION_NAME
     , sch.SCHEMA_NAME
     , R.SPECIFIC_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth.AUTHORIZATION_NAME
     , sch.SCHEMA_NAME
     , R.ROUTINE_NAME
     , R.ROUTINE_TYPE
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- MODULE_CATALOG
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- MODULE_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- MODULE_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.USER_DEFINED_TYPE_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.USER_DEFINED_TYPE_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.USER_DEFINED_TYPE_NAME 
     , CAST( D.DATA_TYPE AS VARCHAR(128 OCTETS) )
     , CAST( D.CHARACTER_MAXIMUM_LENGTH AS NUMBER ) 
     , CAST( D.CHARACTER_OCTET_LENGTH AS NUMBER ) 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.CHARACTER_SET_CATALOG
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.CHARACTER_SET_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.CHARACTER_SET_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.COLLATION_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.COLLATION_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.COLLATION_NAME 
     , CAST( D.NUMERIC_PRECISION AS NUMBER ) 
     , CAST( D.NUMERIC_PRECISION_RADIX AS NUMBER ) 
     , CAST( D.NUMERIC_SCALE AS NUMBER ) 
     , CAST( D.DATETIME_PRECISION AS NUMBER ) 
     , D.INTERVAL_TYPE 
     , CAST( D.INTERVAL_PRECISION AS NUMBER ) 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- D.USER_DEFINED_TYPE_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- D.USER_DEFINED_TYPE_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- D.USER_DEFINED_TYPE_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- D.SCOPE_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- D.SCOPE_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- D.SCOPE_NAME 
     , CAST( D.MAXIMUM_CARDINALITY AS NUMBER ) 
     , CAST( D.DTD_IDENTIFIER AS NUMBER ) 
     , R.ROUTINE_BODY
     , CASE WHEN ( CURRENT_USER IN ( auth.AUTHORIZATION_NAME ) ) THEN R.ROUTINE_DEFINITION ELSE CAST( 'not owner' AS LONG VARCHAR ) END
     , R.EXTERNAL_NAME
     , R.EXTERNAL_LANGUAGE
     , R.PARAMETER_STYLE
     , R.IS_DETERMINISTIC
     , R.SQL_DATA_ACCESS
     , R.IS_NULL_CALL
     , R.SQL_PATH
     , R.SCHEMA_LEVEL_ROUTINE
     , CAST( R.MAX_DYNAMIC_RESULT_SETS AS NUMBER ) 
     , R.IS_USER_DEFINED_CAST
     , R.IS_IMPLICITLY_INVOCABLE
     , R.SECURITY_TYPE
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- TO_SQL_SPECIFIC_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- TO_SQL_SPECIFIC_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- TO_SQL_SPECIFIC_NAME 
     , R.AS_LOCATOR
     , R.CREATED_TIME
     , R.MODIFIED_TIME
     , R.NEW_SAVEPOINT_LEVEL
     , R.IS_UDT_DEPENDENT
     , CAST( DT.DATA_TYPE AS VARCHAR(128 OCTETS) )
     , R.RESULT_CAST_AS_LOCATOR
     , CAST( DT.CHARACTER_MAXIMUM_LENGTH AS NUMBER ) 
     , CAST( DT.CHARACTER_OCTET_LENGTH AS NUMBER ) 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.CHARACTER_SET_CATALOG
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.CHARACTER_SET_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.CHARACTER_SET_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.COLLATION_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.COLLATION_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.COLLATION_NAME 
     , CAST( DT.NUMERIC_PRECISION AS NUMBER ) 
     , CAST( DT.NUMERIC_PRECISION_RADIX AS NUMBER ) 
     , CAST( DT.NUMERIC_SCALE AS NUMBER ) 
     , CAST( DT.DATETIME_PRECISION AS NUMBER ) 
     , DT.INTERVAL_TYPE 
     , CAST( DT.INTERVAL_PRECISION AS NUMBER ) 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.USER_DEFINED_TYPE_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.USER_DEFINED_TYPE_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.USER_DEFINED_TYPE_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.SCOPE_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.SCOPE_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.SCOPE_NAME 
     , CAST( DT.MAXIMUM_CARDINALITY AS NUMBER ) 
     , CAST( DT.DTD_IDENTIFIER AS NUMBER ) 
     , D.DECLARED_DATA_TYPE 
     , CAST( D.DECLARED_NUMERIC_PRECISION AS NUMBER ) 
     , CAST( D.DECLARED_NUMERIC_SCALE AS NUMBER ) 
     , DT.DECLARED_DATA_TYPE 
     , CAST( DT.DECLARED_NUMERIC_PRECISION AS NUMBER ) 
     , CAST( DT.DECLARED_NUMERIC_SCALE AS NUMBER ) 
   FROM 
     ( ( DEFINITION_SCHEMA.ROUTINES AS R
     LEFT JOIN
          INFORMATION_SCHEMA.WHOLE_DTDS AS D
       ON ( R.SPECIFIC_SCHEMA_ID, R.SPECIFIC_ID,
           'ROUTINE', R.DTD_IDENTIFIER )
        = ( D.OBJECT_SCHEMA_ID, D.OBJECT_ID,
            D.OBJECT_TYPE, D.DTD_IDENTIFIER ) )
     LEFT JOIN
          INFORMATION_SCHEMA.WHOLE_DTDS AS DT
       ON ( SPECIFIC_SCHEMA_ID, R.SPECIFIC_ID,
            'ROUTINE', R.RESULT_CAST_FROM_DTD_IDENTIFIER )
        = ( DT.OBJECT_SCHEMA_ID, DT.OBJECT_ID,
            DT.OBJECT_TYPE, DT.DTD_IDENTIFIER ) )
     , DEFINITION_SCHEMA.SCHEMATA         AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth 
 WHERE 
       R.MODULE_SCHEMA_ID IS NULL
   AND R.MODULE_ID IS NULL
   AND R.SPECIFIC_SCHEMA_ID = sch.SCHEMA_ID
   AND R.SPECIFIC_OWNER_ID  = auth.AUTH_ID
   AND ( R.SPECIFIC_ID IN ( SELECT pvproc.SPECIFIC_ID 
                              FROM DEFINITION_SCHEMA.ROUTINE_PRIVILEGES AS pvproc 
                             WHERE ( pvproc.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                              FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS autab 
                                                             WHERE autab.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                          ) 
                                   -- OR  
                                   -- pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                   --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                   )
                          ) 
         OR 
         R.SPECIFIC_SCHEMA_ID IN ( SELECT pvsch.SCHEMA_ID 
                                     FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch 
                                    WHERE pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER PROCEDURE', 'DROP PROCEDURE', 'EXECUTE PROCEDURE' ) 
                                      AND ( pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                                    FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS ausch 
                                                                   WHERE ausch.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                                ) 
                                          -- OR  
                                          -- pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                          --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                          )
                                 ) 
         OR 
         EXISTS ( SELECT GRANTEE_ID  
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES pvdba 
                   WHERE pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY PROCEDURE', 'DROP ANY PROCEDURE', 'EXECUTE ANY PROCEDURE' )
                     AND ( pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                   FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS audba 
                                                  WHERE audba.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                ) 
                        -- OR  
                        -- pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                        --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                          )  
                ) 
       ) 
ORDER BY 
      sch.SCHEMA_NAME
    , R.SPECIFIC_NAME
)
UNION ALL
(
SELECT
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth.AUTHORIZATION_NAME
     , sch.SCHEMA_NAME
     , R.SPECIFIC_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth.AUTHORIZATION_NAME
     , sch.SCHEMA_NAME
     , R.ROUTINE_NAME
     , R.ROUTINE_TYPE
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) )  -- MODULE_CATALOG
     , m_sch.SCHEMA_NAME
     , M.MODULE_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.USER_DEFINED_TYPE_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.USER_DEFINED_TYPE_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.USER_DEFINED_TYPE_NAME 
     , CAST( D.DATA_TYPE AS VARCHAR(128 OCTETS) )
     , CAST( D.CHARACTER_MAXIMUM_LENGTH AS NUMBER ) 
     , CAST( D.CHARACTER_OCTET_LENGTH AS NUMBER ) 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.CHARACTER_SET_CATALOG
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.CHARACTER_SET_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.CHARACTER_SET_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.COLLATION_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.COLLATION_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- R.COLLATION_NAME 
     , CAST( D.NUMERIC_PRECISION AS NUMBER ) 
     , CAST( D.NUMERIC_PRECISION_RADIX AS NUMBER ) 
     , CAST( D.NUMERIC_SCALE AS NUMBER ) 
     , CAST( D.DATETIME_PRECISION AS NUMBER ) 
     , D.INTERVAL_TYPE 
     , CAST( D.INTERVAL_PRECISION AS NUMBER ) 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- D.USER_DEFINED_TYPE_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- D.USER_DEFINED_TYPE_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- D.USER_DEFINED_TYPE_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- D.SCOPE_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- D.SCOPE_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- D.SCOPE_NAME 
     , CAST( D.MAXIMUM_CARDINALITY AS NUMBER ) 
     , CAST( D.DTD_IDENTIFIER AS NUMBER ) 
     , R.ROUTINE_BODY
     , CASE WHEN ( CURRENT_USER IN ( auth.AUTHORIZATION_NAME ) ) THEN R.ROUTINE_DEFINITION ELSE CAST( 'not owner' AS LONG VARCHAR ) END
     , R.EXTERNAL_NAME
     , R.EXTERNAL_LANGUAGE
     , R.PARAMETER_STYLE
     , R.IS_DETERMINISTIC
     , R.SQL_DATA_ACCESS
     , R.IS_NULL_CALL
     , R.SQL_PATH
     , R.SCHEMA_LEVEL_ROUTINE
     , CAST( R.MAX_DYNAMIC_RESULT_SETS AS NUMBER ) 
     , R.IS_USER_DEFINED_CAST
     , R.IS_IMPLICITLY_INVOCABLE
     , R.SECURITY_TYPE
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- TO_SQL_SPECIFIC_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- TO_SQL_SPECIFIC_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- TO_SQL_SPECIFIC_NAME 
     , R.AS_LOCATOR
     , R.CREATED_TIME
     , R.MODIFIED_TIME
     , R.NEW_SAVEPOINT_LEVEL
     , R.IS_UDT_DEPENDENT
     , CAST( DT.DATA_TYPE AS VARCHAR(128 OCTETS) )
     , R.RESULT_CAST_AS_LOCATOR
     , CAST( DT.CHARACTER_MAXIMUM_LENGTH AS NUMBER ) 
     , CAST( DT.CHARACTER_OCTET_LENGTH AS NUMBER ) 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.CHARACTER_SET_CATALOG
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.CHARACTER_SET_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.CHARACTER_SET_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.COLLATION_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.COLLATION_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.COLLATION_NAME 
     , CAST( DT.NUMERIC_PRECISION AS NUMBER ) 
     , CAST( DT.NUMERIC_PRECISION_RADIX AS NUMBER ) 
     , CAST( DT.NUMERIC_SCALE AS NUMBER ) 
     , CAST( DT.DATETIME_PRECISION AS NUMBER ) 
     , DT.INTERVAL_TYPE 
     , CAST( DT.INTERVAL_PRECISION AS NUMBER ) 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.USER_DEFINED_TYPE_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.USER_DEFINED_TYPE_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.USER_DEFINED_TYPE_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.SCOPE_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.SCOPE_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DT.SCOPE_NAME 
     , CAST( DT.MAXIMUM_CARDINALITY AS NUMBER ) 
     , CAST( DT.DTD_IDENTIFIER AS NUMBER ) 
     , D.DECLARED_DATA_TYPE 
     , CAST( D.DECLARED_NUMERIC_PRECISION AS NUMBER ) 
     , CAST( D.DECLARED_NUMERIC_SCALE AS NUMBER ) 
     , DT.DECLARED_DATA_TYPE 
     , CAST( DT.DECLARED_NUMERIC_PRECISION AS NUMBER ) 
     , CAST( DT.DECLARED_NUMERIC_SCALE AS NUMBER ) 
   FROM 
     ( ( ( ( DEFINITION_SCHEMA.ROUTINES AS R
     LEFT JOIN
          DEFINITION_SCHEMA.MODULES AS M
       ON ( R.MODULE_SCHEMA_ID = M.MODULE_SCHEMA_ID
            AND
            R.MODULE_ID = M.MODULE_ID ) )
     LEFT JOIN
          DEFINITION_SCHEMA.SCHEMATA AS m_sch
       ON M.MODULE_SCHEMA_ID = m_sch.SCHEMA_ID )
     LEFT JOIN
          INFORMATION_SCHEMA.WHOLE_DTDS AS D
       ON ( R.SPECIFIC_SCHEMA_ID, R.SPECIFIC_ID,
           'ROUTINE', R.DTD_IDENTIFIER )
        = ( D.OBJECT_SCHEMA_ID, D.OBJECT_ID,
            D.OBJECT_TYPE, D.DTD_IDENTIFIER ) )
     LEFT JOIN
          INFORMATION_SCHEMA.WHOLE_DTDS AS DT
       ON ( SPECIFIC_SCHEMA_ID, R.SPECIFIC_ID,
            'ROUTINE', R.RESULT_CAST_FROM_DTD_IDENTIFIER )
        = ( DT.OBJECT_SCHEMA_ID, DT.OBJECT_ID,
            DT.OBJECT_TYPE, DT.DTD_IDENTIFIER ) )
     , DEFINITION_SCHEMA.SCHEMATA         AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth 
 WHERE 
       R.MODULE_SCHEMA_ID IS NOT NULL
   AND R.MODULE_ID IS NOT NULL
   AND R.SPECIFIC_SCHEMA_ID = sch.SCHEMA_ID
   AND R.SPECIFIC_OWNER_ID  = auth.AUTH_ID
   AND ( R.SPECIFIC_ID IN ( SELECT pvproc.SPECIFIC_ID 
                              FROM DEFINITION_SCHEMA.ROUTINE_PRIVILEGES AS pvproc 
                             WHERE ( pvproc.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                              FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS autab 
                                                             WHERE autab.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                          ) 
                                   -- OR  
                                   -- pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                   --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                   )
                          ) 
         OR 
         R.SPECIFIC_SCHEMA_ID IN ( SELECT pvsch.SCHEMA_ID 
                                     FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch 
                                    WHERE pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER PROCEDURE', 'DROP PROCEDURE', 'EXECUTE PROCEDURE' ) 
                                      AND ( pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                                    FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS ausch 
                                                                   WHERE ausch.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                                ) 
                                          -- OR  
                                          -- pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                          --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                          )
                                 ) 
         OR 
         EXISTS ( SELECT GRANTEE_ID  
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES pvdba 
                   WHERE pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY PROCEDURE', 'DROP ANY PROCEDURE', 'EXECUTE ANY PROCEDURE' )
                     AND ( pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                   FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS audba 
                                                  WHERE audba.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                ) 
                        -- OR  
                        -- pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                        --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                          )  
                ) 
       ) 
ORDER BY 
       sch.SCHEMA_NAME
     , R.SPECIFIC_NAME
)
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.ROUTINES
        IS 'Identify the SQL-invoked routines in this catalog that are accessible to a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.SPECIFIC_CATALOG
        IS 'specific catalog name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.SPECIFIC_OWNER
        IS 'specific owner name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.SPECIFIC_SCHEMA
        IS 'specific schema name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.SPECIFIC_NAME
        IS 'specific name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.ROUTINE_CATALOG
        IS 'catalog name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.ROUTINE_OWNER
        IS 'owner name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.ROUTINE_SCHEMA
        IS 'schema name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.ROUTINE_TYPE
        IS 'name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.MODULE_CATALOG
        IS 'module name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.MODULE_SCHEMA
        IS 'schema name of the module in which the routine is defined';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.MODULE_NAME
        IS 'name of the module in which the routine is defined';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.UDT_CATALOG
        IS 'catalog name of the user-defined data type which defined the routine as a method function';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.UDT_SCHEMA
        IS 'schema name of the user-defined data type which defined the routine as a method function';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.UDT_NAME
        IS 'name of the user-defined data type which defined the routine as a method function';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.DATA_TYPE
        IS 'data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.CHARACTER_MAXIMUM_LENGTH
        IS 'maximum character length of data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.CHARACTER_OCTET_LENGTH
        IS 'maximum character length in octets of data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.CHARACTER_SET_CATALOG
        IS 'character set catalog name of data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.CHARACTER_SET_SCHEMA
        IS 'character set schema name of data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.CHARACTER_SET_NAME
        IS 'character set name of data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.COLLATION_CATALOG
        IS 'collation catalog name of data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.COLLATION_SCHEMA
        IS 'collation schema name of data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.COLLATION_NAME
        IS 'collation name of data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.NUMERIC_PRECISION
        IS 'precision of data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.NUMERIC_PRECISION_RADIX
        IS 'precision radix of data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.NUMERIC_SCALE
        IS 'scale of data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.DATETIME_PRECISION
        IS 'fractional seconds precision of data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.INTERVAL_TYPE
        IS 'interval qualifier for data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.INTERVAL_PRECISION
        IS 'interval leading field precision of data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.TYPE_UDT_CATALOG
        IS 'catalog name of the user-defined data type, which is the data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.TYPE_UDT_SCHEMA
        IS 'schema name of the user-defined data type, which is the data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.TYPE_UDT_NAME
        IS 'name of the user-defined data type, which is the data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.SCOPE_CATALOG
        IS 'catalog name of referenceable table';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.SCOPE_SCHEMA
        IS 'schema name of referenceable table';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.SCOPE_NAME
        IS 'name of referenceable table';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.MAXIMUM_CARDINALITY
        IS 'maximum cardinality of data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.DTD_IDENTIFIER
        IS 'dtd ientifier of data type the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.ROUTINE_BODY
        IS 'type of the routine body';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.ROUTINE_DEFINITION
        IS 'catalog name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.EXTERNAL_NAME
        IS 'external name of the external routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.EXTERNAL_LANGUAGE
        IS 'language of the external routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.PARAMETER_STYLE
        IS 'SQL parameter passing style of the external routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.IS_DETERMINISTIC
        IS 'the routine is deterministic or not';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.SQL_DATA_ACCESS
        IS 'routine possibly contains SQL or access data';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.IS_NULL_CALL
        IS 'routine returns NULL if any of parameter values are NULL';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.SQL_PATH
        IS 'described SQL PATH when the routine is defined';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.SCHEMA_LEVEL_ROUTINE
        IS 'the routine is schema-level routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.MAX_DYNAMIC_RESULT_SETS
        IS 'max result set count of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.IS_USER_DEFINED_CAST
        IS 'the routine is a function that is a user-defined cast function';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.IS_IMPLICITLY_INVOCABLE
        IS 'the user-defined cast function is implicitly invocable';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.SECURITY_TYPE
        IS 'security type of the routine(DEFINER/INVOKER)';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.TO_SQL_SPECIFIC_CATALOG
        IS 'catalog name of the to-sql routine of the result type of routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.TO_SQL_SPECIFIC_SCHEMA
        IS 'schema name of the to-sql routine of the result type of routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.TO_SQL_SPECIFIC_NAME
        IS 'name of the to-sql routine of the result type of routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.AS_LOCATOR
        IS 'return value of the routine is passed as locator';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.CREATED
        IS 'creation time of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.LAST_ALTERED
        IS 'most lately altered time of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.NEW_SAVEPOINT_LEVEL
        IS 'specifiy new savepoint level or not';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.IS_UDT_DEPENDENT
        IS 'routine is dependent';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_FROM_DATA_TYPE
        IS 'data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_AS_LOCATOR
        IS 'locator indication which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_CHAR_MAX_LENGTH
        IS 'maximum character length of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_CHAR_OCTET_LENGTH
        IS 'maximum character length in octets of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_CHAR_SET_CATALOG
        IS 'character set catalog name of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_CHAR_SET_SCHEMA
        IS 'character set schema name of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_CHARACTER_SET_NAME
        IS 'character set name of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_COLLATION_CATALOG
        IS 'collation catalog name of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_COLLATION_SCHEMA
        IS 'collation schema name of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_COLLATION_NAME
        IS 'collation name of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_NUMERIC_PRECISION
        IS 'precision of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_NUMERIC_RADIX
        IS 'precision radix of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_NUMERIC_SCALE
        IS 'scale of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_DATETIME_PRECISION
        IS 'fractional seconds precision of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_INTERVAL_TYPE
        IS 'interval qualifier of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_INTERVAL_PRECISION
        IS 'interval precision of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_TYPE_UDT_CATALOG
        IS 'UDT catalog name of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_TYPE_UDT_SCHEMA
        IS 'UDT schema name of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_TYPE_UDT_NAME
        IS 'UDT name of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_SCOPE_CATALOG
        IS 'catalog name of referenceable table described in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_SCOPE_SCHEMA
        IS 'schema name of referenceable table described in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_SCOPE_NAME
        IS 'name of referenceable table described in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_MAX_CARDINALITY
        IS 'maximum cardinality of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_DTD_IDENTIFIER
        IS 'dtd identifier of data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.DECLARED_DATA_TYPE
        IS 'declared data type of the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.DECLARED_NUMERIC_PRECISION
        IS 'declared data type precision of the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.DECLARED_NUMERIC_SCALE
        IS 'declared data type scale of the routine returns';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_FROM_DECLARED_DATA_TYPE
        IS 'declared data type which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_DECLARED_NUMERIC_PRECISION
        IS 'declared data type precision which is specificed in result cast clause of the routine definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINES.RESULT_CAST_DECLARED_NUMERIC_SCALE
        IS 'declared data type scale which is specificed in result cast clause of the routine definition';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.ROUTINES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS ROUTINES;
CREATE PUBLIC SYNONYM ROUTINES FOR INFORMATION_SCHEMA.ROUTINES;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.PARAMETERS
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.PARAMETERS;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.PARAMETERS
(
       SPECIFIC_CATALOG
     , SPECIFIC_OWNER
     , SPECIFIC_SCHEMA
     , SPECIFIC_NAME
     , ORDINAL_POSITION
     , PARAMETER_MODE
     , IS_RESULT
     , AS_LOCATOR
     , PARAMETER_NAME
     , FROM_SQL_SPECIFIC_CATALOG 
     , FROM_SQL_SPECIFIC_SCHEMA 
     , FROM_SQL_SPECIFIC_NAME 
     , TO_SQL_SPECIFIC_CATALOG 
     , TO_SQL_SPECIFIC_SCHEMA 
     , TO_SQL_SPECIFIC_NAME 
     , DATA_TYPE
     , CHARACTER_MAXIMUM_LENGTH
     , CHARACTER_OCTET_LENGTH
     , CHARACTER_SET_CATALOG
     , CHARACTER_SET_SCHEMA
     , CHARACTER_SET_NAME
     , COLLATION_CATALOG 
     , COLLATION_SCHEMA 
     , COLLATION_NAME 
     , NUMERIC_PRECISION
     , NUMERIC_PRECISION_RADIX
     , NUMERIC_SCALE
     , DATETIME_PRECISION
     , INTERVAL_TYPE
     , INTERVAL_PRECISION
     , UDT_CATALOG 
     , UDT_SCHEMA 
     , UDT_NAME 
     , SCOPE_CATALOG 
     , SCOPE_SCHEMA 
     , SCOPE_NAME 
     , MAXIMUM_CARDINALITY
     , DTD_IDENTIFIER
     , DECLARED_DATA_TYPE
     , DECLARED_NUMERIC_PRECISION
     , DECLARED_NUMERIC_SCALE
     , PARAMETER_DEFAULT
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth.AUTHORIZATION_NAME
     , sch.SCHEMA_NAME
     , R.SPECIFIC_NAME
     , CAST( P.ORDINAL_POSITION AS NUMBER ) 
     , P.PARAMETER_MODE
     , P.IS_RESULT
     , P.AS_LOCATOR
     , P.PARAMETER_NAME
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- FROM_SQL_SPECIFIC_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- FROM_SQL_SPECIFIC_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- FROM_SQL_SPECIFIC_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- TO_SQL_SPECIFIC_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- TO_SQL_SPECIFIC_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- TO_SQL_SPECIFIC_NAME 
     , CAST( DTD.DATA_TYPE AS VARCHAR(128 OCTETS) )
     , CAST( DTD.CHARACTER_MAXIMUM_LENGTH AS NUMBER ) 
     , CAST( DTD.CHARACTER_OCTET_LENGTH AS NUMBER ) 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- CHARACTER_SET_CATALOG
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- CHARACTER_SET_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- CHARACTER_SET_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- COLLATION_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- COLLATION_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- COLLATION_NAME 
     , CAST( DTD.NUMERIC_PRECISION AS NUMBER ) 
     , CAST( DTD.NUMERIC_PRECISION_RADIX AS NUMBER ) 
     , CAST( DTD.NUMERIC_SCALE AS NUMBER ) 
     , CAST( DTD.DATETIME_PRECISION AS NUMBER ) 
     , DTD.INTERVAL_TYPE
     , CAST( DTD.INTERVAL_PRECISION AS NUMBER ) 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- UDT_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- UDT_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- UDT_NAME 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- SCOPE_CATALOG 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- SCOPE_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- SCOPE_NAME 
     , CAST( DTD.MAXIMUM_CARDINALITY AS NUMBER ) 
     , CAST( DTD.DTD_IDENTIFIER AS NUMBER ) 
     , DTD.DECLARED_DATA_TYPE
     , CAST( DTD.DECLARED_NUMERIC_PRECISION AS NUMBER ) 
     , CAST( DTD.DECLARED_NUMERIC_SCALE AS NUMBER ) 
     , CASE WHEN ( CURRENT_USER IN ( auth.AUTHORIZATION_NAME ) ) THEN P.PARAMETER_DEFAULT ELSE CAST( 'not owner' AS LONG VARCHAR ) END
  FROM
       ( DEFINITION_SCHEMA.PARAMETERS AS P
       LEFT JOIN
         INFORMATION_SCHEMA.WHOLE_DTDS AS DTD
         ON ( P.SPECIFIC_SCHEMA_ID, P.SPECIFIC_ID,
              'ROUTINE', P.DTD_IDENTIFIER )
          = ( DTD.OBJECT_SCHEMA_ID, DTD.OBJECT_ID,
              DTD.OBJECT_TYPE, DTD.DTD_IDENTIFIER ) )
     , DEFINITION_SCHEMA.ROUTINES AS R
     , DEFINITION_SCHEMA.SCHEMATA         AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth 
 WHERE 
       R.SPECIFIC_SCHEMA_ID = P.SPECIFIC_SCHEMA_ID
   AND R.SPECIFIC_ID = P.SPECIFIC_ID
   AND R.SPECIFIC_SCHEMA_ID = sch.SCHEMA_ID
   AND R.SPECIFIC_OWNER_ID  = auth.AUTH_ID
   AND ( R.SPECIFIC_ID IN ( SELECT pvproc.SPECIFIC_ID 
                              FROM DEFINITION_SCHEMA.ROUTINE_PRIVILEGES AS pvproc 
                             WHERE ( pvproc.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                              FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS autab 
                                                             WHERE autab.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                          ) 
                                   -- OR  
                                   -- pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                   --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                   )
                          ) 
         OR 
         R.SPECIFIC_SCHEMA_ID IN ( SELECT pvsch.SCHEMA_ID 
                                     FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch 
                                    WHERE pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA',
                                                                    'ALTER PROCEDURE', 'DROP PROCEDURE', 'EXECUTE PROCEDURE' ) 
                                      AND ( pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                                    FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS ausch 
                                                                   WHERE ausch.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                                ) 
                                          -- OR  
                                          -- pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                          --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                          )
                                 ) 
         OR 
         EXISTS ( SELECT GRANTEE_ID  
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES pvdba 
                   WHERE pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY PROCEDURE', 'DROP ANY PROCEDURE', 'EXECUTE ANY PROCEDURE' )
                     AND ( pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                   FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS audba 
                                                  WHERE audba.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                ) 
                        -- OR  
                        -- pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                        --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                          )  
                ) 
       ) 
ORDER BY 
       sch.SCHEMA_NAME
     , R.SPECIFIC_NAME
     , P.ORDINAL_POSITION
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.PARAMETERS
        IS 'Identify the SQL parameters of SQL-invoked routines defined in this catalog that are accessible to a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.SPECIFIC_CATALOG
        IS 'catalog name of the specific name of the SQL- invoked routine that contains the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.SPECIFIC_OWNER
        IS 'owner name of the specific name of the SQL- invoked routine that contains the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.SPECIFIC_SCHEMA
        IS 'schema name of the specific name of the SQL- invoked routine that contains the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.SPECIFIC_NAME
        IS 'specific name of the SQL- invoked routine that contains the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.ORDINAL_POSITION
        IS 'ordinal position of the SQL- invoked routine that contains the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.PARAMETER_MODE
        IS 'parameter mode of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.IS_RESULT
        IS 'the parameter is RESULT parameter of type-preserving function';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.AS_LOCATOR
        IS 'the parameter is passed as locator';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.PARAMETER_NAME
        IS 'name of the SQL parameter being descaibed';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.FROM_SQL_SPECIFIC_CATALOG 
        IS 'specific catalog name of the from-sql routine for the input parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.FROM_SQL_SPECIFIC_SCHEMA 
        IS 'specific schema name of the from-sql routine for the input parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.FROM_SQL_SPECIFIC_NAME 
        IS 'specific name of the from-sql routine for the input parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.TO_SQL_SPECIFIC_CATALOG 
        IS 'specific catalog name of the to-sql routine for the input parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.TO_SQL_SPECIFIC_SCHEMA 
        IS 'specific schema name of the to-sql routine for the input parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.TO_SQL_SPECIFIC_NAME 
        IS 'specific name of the to-sql routine for the input parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.DATA_TYPE
        IS 'data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.CHARACTER_MAXIMUM_LENGTH
        IS 'maximum length of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.CHARACTER_OCTET_LENGTH
        IS 'maximum length in octets of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.CHARACTER_SET_CATALOG
        IS 'character set catalog name of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.CHARACTER_SET_SCHEMA
        IS 'character set schema name of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.CHARACTER_SET_NAME
        IS 'character set name of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.COLLATION_CATALOG 
        IS 'collation catalog name of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.COLLATION_SCHEMA 
        IS 'collation schema name of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.COLLATION_NAME 
        IS 'collation name of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.NUMERIC_PRECISION
        IS 'precision of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.NUMERIC_PRECISION_RADIX
        IS 'precision radix of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.NUMERIC_SCALE
        IS 'scale of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.DATETIME_PRECISION
        IS 'fractional second precisions of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.INTERVAL_TYPE
        IS 'interval qualifier of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.INTERVAL_PRECISION
        IS 'interval precision of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.UDT_CATALOG 
        IS 'catalog name of UDT of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.UDT_SCHEMA 
        IS 'schema name of UDT of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.UDT_NAME 
        IS 'name of UDT of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.SCOPE_CATALOG 
        IS 'catalog name of referenceable tables of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.SCOPE_SCHEMA 
        IS 'schema name of referenceable tables of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.SCOPE_NAME 
        IS 'name of referenceable tables of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.MAXIMUM_CARDINALITY
        IS 'maximum cardinality of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.DTD_IDENTIFIER
        IS 'dtd identifier of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.DECLARED_DATA_TYPE
        IS 'declared data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.DECLARED_NUMERIC_PRECISION
        IS 'precision of declared data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.DECLARED_NUMERIC_SCALE
        IS 'scale of declared data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.PARAMETERS.PARAMETER_DEFAULT
        IS 'default value of the SQL parameter being described';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.PARAMETERS TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS PARAMETERS;
CREATE PUBLIC SYNONYM PARAMETERS FOR INFORMATION_SCHEMA.PARAMETERS;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.ROUTINE_PRIVILEGES
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.ROUTINE_PRIVILEGES;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.ROUTINE_PRIVILEGES
(
       GRANTOR
     , GRANTEE
     , SPECIFIC_CATALOG
     , SPECIFIC_OWNER
     , SPECIFIC_SCHEMA
     , SPECIFIC_NAME
     , ROUTINE_CATALOG
     , ROUTINE_OWNER
     , ROUTINE_SCHEMA
     , ROUTINE_NAME
     , PRIVILEGE_TYPE
     , IS_GRANTABLE
)
AS
SELECT 
       grantor.AUTHORIZATION_NAME                     -- GRANTOR
     , grantee.AUTHORIZATION_NAME                     -- GRANTEE
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- SPECIFIC_CATALOG
     , auth.AUTHORIZATION_NAME                        -- SPECIFIC_OWNER
     , sch.SCHEMA_NAME                                -- SPECIFIC_SCHEMA
     , R.SPECIFIC_NAME                                -- SPECIFIC_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- ROUTINE_CATALOG
     , auth.AUTHORIZATION_NAME                        -- ROUTINE_OWNER
     , sch.SCHEMA_NAME                                -- ROUTINE_SCHEMA
     , R.ROUTINE_NAME                                 -- ROUTINE_NAME
     , RP.PRIVILEGE_TYPE                              -- PRIVILEGE_TYPE
     , RP.IS_GRANTABLE                                -- IS_GRANTABLE
  FROM
       DEFINITION_SCHEMA.ROUTINE_PRIVILEGES AS RP
     , DEFINITION_SCHEMA.ROUTINES           AS R
     , DEFINITION_SCHEMA.SCHEMATA           AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS     AS grantor
     , DEFINITION_SCHEMA.AUTHORIZATIONS     AS grantee
     , DEFINITION_SCHEMA.AUTHORIZATIONS     AS auth
 WHERE 
       RP.SPECIFIC_ID = R.SPECIFIC_ID
   AND RP.GRANTOR_ID  = grantor.AUTH_ID
   AND RP.GRANTEE_ID  = grantee.AUTH_ID
   AND RP.SPECIFIC_SCHEMA_ID = sch.SCHEMA_ID
   AND RP.SPECIFIC_OWNER_ID  = auth.AUTH_ID
   AND ( grantee.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )
      -- OR  
      -- pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
      --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
         OR
         grantor.AUTHORIZATION_NAME = CURRENT_USER
       )
ORDER BY 
       RP.SPECIFIC_SCHEMA_ID
     , RP.SPECIFIC_ID
     , RP.GRANTOR_ID
     , RP.GRANTEE_ID
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.ROUTINE_PRIVILEGES
        IS 'Identify the privileges on SQL-invoked routines defined in this catalog that are available to or granted by a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_PRIVILEGES.GRANTOR
        IS 'authorization name of the user who granted routine privileges';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_PRIVILEGES.GRANTEE
        IS 'authorization name of some user or role, or PUBLIC to indicate all users, to whom the routine privilege being described is granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_PRIVILEGES.SPECIFIC_CATALOG
        IS 'specific catalog name of the SQL-invoked routine on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_PRIVILEGES.SPECIFIC_OWNER
        IS 'specific owner name of the the SQL-invoked routine on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_PRIVILEGES.SPECIFIC_SCHEMA
        IS 'specific schema name of the the SQL-invoked routine on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_PRIVILEGES.SPECIFIC_NAME
        IS 'specific name of the the SQL-invoked routine on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_PRIVILEGES.ROUTINE_CATALOG
        IS 'routine catalog name of the SQL-invoked routine on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_PRIVILEGES.ROUTINE_SCHEMA
        IS 'routine schema name of the the SQL-invoked routine on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_PRIVILEGES.ROUTINE_NAME
        IS 'routine name of the the SQL-invoked routine on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_PRIVILEGES.PRIVILEGE_TYPE
        IS 'the value is in ( EXECUTE )';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_PRIVILEGES.IS_GRANTABLE
        IS 'is grantable';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.ROUTINE_PRIVILEGES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS ROUTINE_PRIVILEGES;
CREATE PUBLIC SYNONYM ROUTINE_PRIVILEGES FOR INFORMATION_SCHEMA.ROUTINE_PRIVILEGES;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.ROUTINE_ROUTINE_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.ROUTINE_ROUTINE_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.ROUTINE_ROUTINE_USAGE
(
       SPECIFIC_CATALOG
     , SPECIFIC_OWNER
     , SPECIFIC_SCHEMA
     , SPECIFIC_NAME
     , ROUTINE_CATALOG
     , ROUTINE_OWNER
     , ROUTINE_SCHEMA
     , ROUTINE_NAME
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- SPECIFIC_CATALOG
     , auth1.AUTHORIZATION_NAME                       -- SPECIFIC_OWNER
     , sch1.SCHEMA_NAME                               -- SPECIFIC_SCHEMA
     , rtn1.SPECIFIC_NAME                             -- SPECIFIC_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- ROUTINE_CATALOG
     , auth2.AUTHORIZATION_NAME                       -- ROUTINE_OWNER
     , sch2.SCHEMA_NAME                               -- ROUTINE_SCHEMA
     , rtn2.ROUTINE_NAME                              -- ROUTINE_NAME
  FROM 
       DEFINITION_SCHEMA.ROUTINE_ROUTINE_USAGE AS rru
     , DEFINITION_SCHEMA.ROUTINES         AS rtn1
     , DEFINITION_SCHEMA.SCHEMATA         AS sch1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth1
     , DEFINITION_SCHEMA.ROUTINES         AS rtn2
     , DEFINITION_SCHEMA.SCHEMATA         AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth2
 WHERE 
       rru.SPECIFIC_ID        = rtn1.SPECIFIC_ID
   AND rru.SPECIFIC_SCHEMA_ID = sch1.SCHEMA_ID 
   AND rru.SPECIFIC_OWNER_ID  = auth1.AUTH_ID 
   AND rru.ROUTINE_ID         = rtn2.ROUTINE_ID 
   AND rru.ROUTINE_SCHEMA_ID  = sch2.SCHEMA_ID
   AND rru.ROUTINE_OWNER_ID   = auth2.AUTH_ID 
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR 
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       ) 
ORDER BY 
      rru.SPECIFIC_SCHEMA_ID 
    , rru.SPECIFIC_ID 
    , rru.ROUTINE_SCHEMA_ID
    , rru.ROUTINE_ID
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.ROUTINE_ROUTINE_USAGE
        IS 'Identify each SQL-invoked routine owned by a given user or role on which an SQL routine defined in this catalog is dependent.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_ROUTINE_USAGE.SPECIFIC_CATALOG
        IS 'specific catalog name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_ROUTINE_USAGE.SPECIFIC_OWNER
        IS 'specific owner name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_ROUTINE_USAGE.SPECIFIC_SCHEMA
        IS 'specific schema name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_ROUTINE_USAGE.SPECIFIC_NAME
        IS 'specific name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_ROUTINE_USAGE.ROUTINE_CATALOG
        IS 'routine catalog name of a routine contained in routine body of the SQL-invoked routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_ROUTINE_USAGE.ROUTINE_OWNER
        IS 'routine owner name of a routine contained in routine body of the SQL-invoked routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_ROUTINE_USAGE.ROUTINE_SCHEMA
        IS 'routine schema name of a routine contained in routine body of the SQL-invoked routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_ROUTINE_USAGE.ROUTINE_NAME
        IS 'routine name of a routine contained in routine body of the SQL-invoked routine';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.ROUTINE_ROUTINE_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS ROUTINE_ROUTINE_USAGE;
CREATE PUBLIC SYNONYM ROUTINE_ROUTINE_USAGE FOR INFORMATION_SCHEMA.ROUTINE_ROUTINE_USAGE;
COMMIT;



--##############################################################
--# INFORMATION_SCHEMA.ROUTINE_SEQUENCE_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.ROUTINE_SEQUENCE_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.ROUTINE_SEQUENCE_USAGE
(
       SPECIFIC_CATALOG
     , SPECIFIC_OWNER
     , SPECIFIC_SCHEMA
     , SPECIFIC_NAME
     , SEQUENCE_CATALOG
     , SEQUENCE_OWNER
     , SEQUENCE_SCHEMA
     , SEQUENCE_NAME
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- SPECIFIC_CATALOG
     , auth1.AUTHORIZATION_NAME                       -- SPECIFIC_OWNER
     , sch1.SCHEMA_NAME                               -- SPECIFIC_SCHEMA
     , rtn1.SPECIFIC_NAME                             -- SPECIFIC_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- SEQUENCE_CATALOG
     , auth2.AUTHORIZATION_NAME                       -- SEQUENCE_OWNER
     , sch2.SCHEMA_NAME                               -- SEQUENCE_SCHEMA
     , seq2.SEQUENCE_NAME                             -- SEQUENCE_NAME
  FROM 
       DEFINITION_SCHEMA.ROUTINE_SEQUENCE_USAGE AS rsu
     , DEFINITION_SCHEMA.ROUTINES         AS rtn1
     , DEFINITION_SCHEMA.SCHEMATA         AS sch1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth1
     , DEFINITION_SCHEMA.SEQUENCES        AS seq2
     , DEFINITION_SCHEMA.SCHEMATA         AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth2
 WHERE 
       rsu.SPECIFIC_ID        = rtn1.SPECIFIC_ID
   AND rsu.SPECIFIC_SCHEMA_ID = sch1.SCHEMA_ID 
   AND rsu.SPECIFIC_OWNER_ID  = auth1.AUTH_ID 
   AND rsu.SEQUENCE_ID        = seq2.SEQUENCE_ID 
   AND rsu.SEQUENCE_SCHEMA_ID = sch2.SCHEMA_ID
   AND rsu.SEQUENCE_OWNER_ID  = auth2.AUTH_ID 
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR 
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       ) 
ORDER BY 
      rsu.SPECIFIC_SCHEMA_ID 
    , rsu.SPECIFIC_ID 
    , rsu.SEQUENCE_SCHEMA_ID
    , rsu.SEQUENCE_ID
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.ROUTINE_SEQUENCE_USAGE
        IS 'Identify each external sequence generator owned by a given user or role on which some SQL routine defined in this catalog is dependent.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_SEQUENCE_USAGE.SPECIFIC_CATALOG
        IS 'specific catalog name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_SEQUENCE_USAGE.SPECIFIC_OWNER
        IS 'specific owner name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_SEQUENCE_USAGE.SPECIFIC_SCHEMA
        IS 'specific schema name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_SEQUENCE_USAGE.SPECIFIC_NAME
        IS 'specific name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_SEQUENCE_USAGE.SEQUENCE_CATALOG
        IS 'catalog name of the sequence of contained in routine body of the SQL-invoked routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_SEQUENCE_USAGE.SEQUENCE_OWNER
        IS 'owner name of the sequence of contained in routine body of the SQL-invoked routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_SEQUENCE_USAGE.SEQUENCE_SCHEMA
        IS 'schema name of the sequence of contained in routine body of the SQL-invoked routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_SEQUENCE_USAGE.SEQUENCE_NAME
        IS 'sequence name of contained in routine body of the SQL-invoked routine';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.ROUTINE_SEQUENCE_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS ROUTINE_SEQUENCE_USAGE;
CREATE PUBLIC SYNONYM ROUTINE_SEQUENCE_USAGE FOR INFORMATION_SCHEMA.ROUTINE_SEQUENCE_USAGE;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.ROUTINE_TABLE_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.ROUTINE_TABLE_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.ROUTINE_TABLE_USAGE
(
       SPECIFIC_CATALOG
     , SPECIFIC_OWNER
     , SPECIFIC_SCHEMA
     , SPECIFIC_NAME
     , TABLE_CATALOG
     , TABLE_OWNER
     , TABLE_SCHEMA
     , TABLE_NAME
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- SPECIFIC_CATALOG
     , auth1.AUTHORIZATION_NAME                       -- SPECIFIC_OWNER
     , sch1.SCHEMA_NAME                               -- SPECIFIC_SCHEMA
     , rtn1.SPECIFIC_NAME                             -- SPECIFIC_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- TABLE_CATALOG
     , auth2.AUTHORIZATION_NAME                       -- TABLE_OWNER
     , sch2.SCHEMA_NAME                               -- TABLE_SCHEMA
     , tab2.TABLE_NAME                                -- TABLE_NAME
  FROM 
       DEFINITION_SCHEMA.ROUTINE_TABLE_USAGE AS rtu
     , DEFINITION_SCHEMA.ROUTINES         AS rtn1
     , DEFINITION_SCHEMA.SCHEMATA         AS sch1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth1
     , DEFINITION_SCHEMA.TABLES           AS tab2
     , DEFINITION_SCHEMA.SCHEMATA         AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth2
 WHERE 
       rtu.SPECIFIC_ID        = rtn1.SPECIFIC_ID
   AND rtu.SPECIFIC_SCHEMA_ID = sch1.SCHEMA_ID 
   AND rtu.SPECIFIC_OWNER_ID  = auth1.AUTH_ID 
   AND rtu.TABLE_ID           = tab2.TABLE_ID 
   AND rtu.TABLE_SCHEMA_ID    = sch2.SCHEMA_ID
   AND rtu.TABLE_OWNER_ID     = auth2.AUTH_ID 
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR 
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       ) 
ORDER BY 
      rtu.SPECIFIC_SCHEMA_ID 
    , rtu.SPECIFIC_ID 
    , rtu.TABLE_SCHEMA_ID
    , rtu.TABLE_ID
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.ROUTINE_TABLE_USAGE
        IS 'Identify the tables owned by a given user or role on which SQL routines defined in this catalog are dependent.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_TABLE_USAGE.SPECIFIC_CATALOG
        IS 'specific catalog name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_TABLE_USAGE.SPECIFIC_OWNER
        IS 'specific owner name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_TABLE_USAGE.SPECIFIC_SCHEMA
        IS 'specific schema name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_TABLE_USAGE.SPECIFIC_NAME
        IS 'specific name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_TABLE_USAGE.TABLE_CATALOG
        IS 'catalog name of the table of contained in routine body of the SQL-invoked routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_TABLE_USAGE.TABLE_OWNER
        IS 'owner name of the table of contained in routine body of the SQL-invoked routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_TABLE_USAGE.TABLE_SCHEMA
        IS 'schema name of the table of contained in routine body of the SQL-invoked routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_TABLE_USAGE.TABLE_NAME
        IS 'table name of contained in routine body of the SQL-invoked routine';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.ROUTINE_TABLE_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS ROUTINE_TABLE_USAGE;
CREATE PUBLIC SYNONYM ROUTINE_TABLE_USAGE FOR INFORMATION_SCHEMA.ROUTINE_TABLE_USAGE;
COMMIT;



--##############################################################
--# INFORMATION_SCHEMA.DBC_TABLES for ODBC SQLTables()
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.DBC_TABLES;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.DBC_TABLES 
( 
       TABLE_CATALOG
     , TABLE_SCHEMA
     , TABLE_NAME
     , DBC_TABLE_TYPE
     , COMMENTS      
) 
AS 
SELECT
       /*+
           USE_NL( tab )
           USE_NL( sch ) 
        */
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , sch.SCHEMA_NAME 
     , tab.TABLE_NAME 
     , CAST( CASE WHEN sch.SCHEMA_NAME = 'INFORMATION_SCHEMA' AND tab.TABLE_TYPE = 'VIEW'
                  THEN 'SYSTEM TABLE'
                  ELSE DECODE( tab.TABLE_TYPE, 'BASE TABLE', 'TABLE', tab.TABLE_TYPE )
                  END 
             AS VARCHAR(32 OCTETS) )
     , tab.COMMENTS 
  FROM  
       DEFINITION_SCHEMA.TABLES@LOCAL    AS tab 
     , DEFINITION_SCHEMA.SCHEMATA@LOCAL  AS sch 
 WHERE
       tab.TABLE_TYPE <> 'SEQUENCE' 
   AND tab.SCHEMA_ID = sch.SCHEMA_ID 
   AND tab.IS_DROPPED = FALSE
   AND EXISTS (
                  SELECT /*+ INDEX( pvtab, TABLE_PRIVILEGES_INDEX_TABLE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.TABLE_PRIVILEGES@LOCAL AS pvtab
                   WHERE pvtab.TABLE_ID = tab.TABLE_ID
                     AND pvtab.GRANTEE_ID IN ( USER_ID(), 5 )
                  UNION ALL
                  SELECT /*+ INDEX( pvcol, COLUMN_PRIVILEGES_INDEX_TABLE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.COLUMN_PRIVILEGES@LOCAL AS pvcol 
                   WHERE pvcol.TABLE_ID = tab.TABLE_ID
                     AND pvcol.GRANTEE_ID IN ( USER_ID(), 5 )
                  UNION ALL
                  SELECT /*+ INDEX( pvsch, SCHEMA_PRIVILEGES_INDEX_SCHEMA_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES@LOCAL AS pvsch
                   WHERE pvsch.SCHEMA_ID = tab.SCHEMA_ID
                     AND pvsch.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER TABLE', 'DROP TABLE', 
                                                   'SELECT TABLE', 'INSERT TABLE', 'DELETE TABLE', 'UPDATE TABLE', 'LOCK TABLE' ) 
                  UNION ALL
                  SELECT /*+ INDEX( pvdba, DATABASE_PRIVILEGES_INDEX_GRANTEE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES@LOCAL AS pvdba
                   WHERE pvdba.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY TABLE', 'DROP ANY TABLE', 
                                                   'SELECT ANY TABLE', 'INSERT ANY TABLE', 'DELETE ANY TABLE', 'UPDATE ANY TABLE', 'LOCK ANY TABLE' ) 
              )
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.DBC_TABLES 
        IS 'Identify the tables defined in this catalog that are accessible to a given user or role';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_TABLES.TABLE_CATALOG                    
        IS 'catalog name of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_TABLES.TABLE_SCHEMA                     
        IS 'schema name of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_TABLES.TABLE_NAME                       
        IS 'table name of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_TABLES.DBC_TABLE_TYPE                       
        IS 'ODBC/JDBC table type: the value is in ( TABLE, VIEW, GLOBAL TEMPORARY, LOCAL TEMPORARY, SYSTEM TABLE, ALIAS, SYNONYM, IMMUTABLE TABLE )';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_TABLES.COMMENTS                         
        IS 'comments of the table';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.DBC_TABLES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS DBC_TABLES;
CREATE PUBLIC SYNONYM DBC_TABLES FOR INFORMATION_SCHEMA.DBC_TABLES;
COMMIT;



--##############################################################
--# INFORMATION_SCHEMA.DBC_COLUMNS for ODBC SQLColumns()
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.DBC_COLUMNS;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.DBC_COLUMNS 
( 
       TABLE_CATALOG 
     , TABLE_SCHEMA 
     , TABLE_NAME 
     , COLUMN_NAME 
     , ORDINAL_POSITION 
     , COLUMN_DEFAULT 
     , IS_NULLABLE 
     , DATA_TYPE 
     , CHARACTER_MAXIMUM_LENGTH 
     , CHARACTER_OCTET_LENGTH 
     , NUMERIC_PRECISION 
     , NUMERIC_PRECISION_RADIX 
     , NUMERIC_SCALE 
     , DATETIME_PRECISION 
     , INTERVAL_PRECISION 
     , SCOPE_CATALOG 
     , SCOPE_SCHEMA 
     , SCOPE_NAME 
     , IS_IDENTITY 
     , COMMENTS 
) 
AS 
SELECT
       /*+
           USE_NL( col )
           USE_NL( dtd )
           USE_NL( tab )
           USE_NL( sch )
        */
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , sch.SCHEMA_NAME 
     , tab.TABLE_NAME 
     , col.COLUMN_NAME 
     , CAST( col.LOGICAL_ORDINAL_POSITION AS NUMBER ) 
     , col.COLUMN_DEFAULT 
     , col.IS_NULLABLE 
     , CAST( CASE WHEN dtd.DATA_TYPE IN ( 'INTERVAL YEAR TO MONTH', 'INTERVAL DAY TO SECOND' )
                       THEN 'INTERVAL ' || dtd.INTERVAL_TYPE 
                  WHEN ( dtd.DATA_TYPE = 'NUMBER' AND dtd.NUMERIC_PRECISION_RADIX = 2 )
                       THEN 'FLOAT'
                  ELSE dtd.DATA_TYPE
                  END
             AS VARCHAR(128 OCTETS) ) -- DATA_TYPE
     , CAST( dtd.CHARACTER_MAXIMUM_LENGTH AS NUMBER ) 
     , CAST( dtd.CHARACTER_OCTET_LENGTH AS NUMBER ) 
     , CAST( dtd.NUMERIC_PRECISION AS NUMBER ) 
     , CAST( dtd.NUMERIC_PRECISION_RADIX AS NUMBER ) 
     , CAST( CASE WHEN dtd.NUMERIC_SCALE BETWEEN -256 AND 256
                  THEN dtd.NUMERIC_SCALE
                  ELSE NULL
                  END 
             AS NUMBER )
     , CAST( dtd.DATETIME_PRECISION AS NUMBER ) 
     , CAST( dtd.INTERVAL_PRECISION AS NUMBER ) 
     , CAST( NULL AS VARCHAR(128 OCTETS) )
     , CAST( NULL AS VARCHAR(128 OCTETS) )
     , CAST( NULL AS VARCHAR(128 OCTETS) )
     , col.IS_IDENTITY 
     , col.COMMENTS 
  FROM 
       DEFINITION_SCHEMA.COLUMNS@LOCAL              AS col 
     , DEFINITION_SCHEMA.DATA_TYPE_DESCRIPTOR@LOCAL AS dtd 
     , DEFINITION_SCHEMA.TABLES@LOCAL               AS tab 
     , DEFINITION_SCHEMA.SCHEMATA@LOCAL             AS sch 
 WHERE  
       col.IS_UNUSED = FALSE
   AND tab.IS_DROPPED = FALSE
   AND col.DTD_IDENTIFIER = dtd.DTD_IDENTIFIER 
   AND col.TABLE_ID       = tab.TABLE_ID 
   AND col.SCHEMA_ID      = sch.SCHEMA_ID
   AND EXISTS (
                  SELECT /*+ INDEX( pvtab, TABLE_PRIVILEGES_INDEX_TABLE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.TABLE_PRIVILEGES@LOCAL AS pvtab
                   WHERE pvtab.TABLE_ID = col.TABLE_ID
                     AND pvtab.GRANTEE_ID IN ( USER_ID(), 5 )
                  UNION ALL
                  SELECT /*+ INDEX( pvcol, COLUMN_PRIVILEGES_INDEX_COLUMN_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.COLUMN_PRIVILEGES@LOCAL AS pvcol 
                   WHERE pvcol.COLUMN_ID = col.COLUMN_ID
                     AND pvcol.GRANTEE_ID IN ( USER_ID(), 5 )
                  UNION ALL
                  SELECT /*+ INDEX( pvsch, SCHEMA_PRIVILEGES_INDEX_SCHEMA_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES@LOCAL AS pvsch
                   WHERE pvsch.SCHEMA_ID = col.SCHEMA_ID
                     AND pvsch.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER TABLE', 'DROP TABLE', 
                                                   'SELECT TABLE', 'INSERT TABLE', 'DELETE TABLE', 'UPDATE TABLE', 'LOCK TABLE' ) 
                  UNION ALL
                  SELECT /*+ INDEX( pvdba, DATABASE_PRIVILEGES_INDEX_GRANTEE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES@LOCAL AS pvdba
                   WHERE pvdba.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY TABLE', 'DROP ANY TABLE', 
                                                   'SELECT ANY TABLE', 'INSERT ANY TABLE', 'DELETE ANY TABLE', 'UPDATE ANY TABLE', 'LOCK ANY TABLE' ) 
              )
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.DBC_COLUMNS 
        IS 'Identify the columns of tables defined in this cataog that are accessible to given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.TABLE_CATALOG                    
        IS 'catalog name of the column';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.TABLE_SCHEMA                     
        IS 'schema name of the column'; 
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.TABLE_NAME                       
        IS 'table name of the column'; 
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.COLUMN_NAME                      
        IS 'column name';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.ORDINAL_POSITION                 
        IS 'the ordinal position (> 0) of the column in the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.COLUMN_DEFAULT                   
        IS 'the default for the column'; 
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.IS_NULLABLE                      
        IS 'is nullable of the column'; 
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.DATA_TYPE                        
        IS 'the standard name of the data type'; 
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.CHARACTER_MAXIMUM_LENGTH         
        IS 'the maximum length in characters';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.CHARACTER_OCTET_LENGTH           
        IS 'the maximum length in octets';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.NUMERIC_PRECISION                
        IS 'the numeric precision of the numerical data type'; 
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.NUMERIC_PRECISION_RADIX          
        IS 'the radix ( 2 or 10 ) of the precision of the numerical data type';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.NUMERIC_SCALE                    
        IS 'the numeric scale of the exact numerical data type';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.DATETIME_PRECISION               
        IS 'for a datetime or interval type, the value is the fractional seconds precision';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.INTERVAL_PRECISION               
        IS 'for a interval type, the value is the leading precision';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.SCOPE_CATALOG                    
        IS 'catalog name of the referenceable table if DATA_TYPE is REF';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.SCOPE_SCHEMA                     
        IS 'schema name of the referenceable table if DATA_TYPE is REF';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.SCOPE_NAME                       
        IS 'scope name of the referenceable table if DATA_TYPE is REF';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.IS_IDENTITY                      
        IS 'is an identity column';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMNS.COMMENTS                         
        IS 'comments of the column';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.DBC_COLUMNS TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS DBC_COLUMNS;
CREATE PUBLIC SYNONYM DBC_COLUMNS FOR INFORMATION_SCHEMA.DBC_COLUMNS;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.DBC_PRIMARY_KEYS for ODBC SQLPrimaryKeys()
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.DBC_PRIMARY_KEYS;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.DBC_PRIMARY_KEYS
(
       TABLE_CATALOG
     , TABLE_SCHEMA
     , TABLE_NAME
     , COLUMN_NAME
     , POSITION
     , CONSTRAINT_NAME
)
AS
SELECT
       /*+
           USE_NL(col)
           USE_NL(tab)
           USE_NL(tcn)
           USE_NL(kcu)
           USE_NL(sch)
        */
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- TABLE_CATALOG
     , sch.SCHEMA_NAME                                -- TABLE_SCHEMA
     , tab.TABLE_NAME                                 -- TABLE_NAME
     , col.COLUMN_NAME                                -- COLUMN_NAME
     , CAST( kcu.ORDINAL_POSITION AS NUMBER )         -- POSITION
     , tcn.CONSTRAINT_NAME                            -- CONSTRAINT_NAME
  FROM
       DEFINITION_SCHEMA.TABLE_CONSTRAINTS@LOCAL AS tcn
     , DEFINITION_SCHEMA.KEY_COLUMN_USAGE@LOCAL  AS kcu
     , DEFINITION_SCHEMA.COLUMNS@LOCAL           AS col
     , DEFINITION_SCHEMA.TABLES@LOCAL            AS tab
     , DEFINITION_SCHEMA.SCHEMATA@LOCAL          AS sch
 WHERE
       tcn.CONSTRAINT_TYPE = 'PRIMARY KEY'
   AND tab.IS_DROPPED = FALSE
   AND tcn.CONSTRAINT_ID   = kcu.CONSTRAINT_ID
   AND kcu.COLUMN_ID       = col.COLUMN_ID
   AND kcu.TABLE_ID        = tab.TABLE_ID
   AND kcu.TABLE_SCHEMA_ID = sch.SCHEMA_ID
   AND EXISTS (
                  SELECT /*+ INDEX( pvtab, TABLE_PRIVILEGES_INDEX_TABLE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.TABLE_PRIVILEGES@LOCAL AS pvtab
                   WHERE pvtab.TABLE_ID = col.TABLE_ID
                     AND pvtab.GRANTEE_ID IN ( USER_ID(), 5 )
                  UNION ALL
                  SELECT /*+ INDEX( pvcol, COLUMN_PRIVILEGES_INDEX_COLUMN_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.COLUMN_PRIVILEGES@LOCAL AS pvcol 
                   WHERE pvcol.COLUMN_ID = col.COLUMN_ID
                     AND pvcol.GRANTEE_ID IN ( USER_ID(), 5 )
                  UNION ALL
                  SELECT /*+ INDEX( pvsch, SCHEMA_PRIVILEGES_INDEX_SCHEMA_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES@LOCAL AS pvsch
                   WHERE pvsch.SCHEMA_ID = col.SCHEMA_ID
                     AND pvsch.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER TABLE', 'DROP TABLE', 
                                                   'SELECT TABLE', 'INSERT TABLE', 'DELETE TABLE', 'UPDATE TABLE', 'LOCK TABLE' ) 
                  UNION ALL
                  SELECT /*+ INDEX( pvdba, DATABASE_PRIVILEGES_INDEX_GRANTEE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES@LOCAL AS pvdba
                   WHERE pvdba.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY TABLE', 'DROP ANY TABLE', 
                                                   'SELECT ANY TABLE', 'INSERT ANY TABLE', 'DELETE ANY TABLE', 'UPDATE ANY TABLE', 'LOCK ANY TABLE' ) 
              )
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.DBC_PRIMARY_KEYS
        IS 'DBC_PRIMARY_KEYS describes columns that are accessible to the current user and that are specified in primary key constraints.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PRIMARY_KEYS.TABLE_CATALOG
        IS 'Catalog name of the table with the primary key definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PRIMARY_KEYS.TABLE_SCHEMA
        IS 'Schema of the table with the primary key definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PRIMARY_KEYS.TABLE_NAME
        IS 'Name of the table with the primary key definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PRIMARY_KEYS.COLUMN_NAME
        IS 'Name of the column or attribute of the object type column specified in the primary key definition';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PRIMARY_KEYS.POSITION
        IS 'Original position of the column or attribute in the definition of the object';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PRIMARY_KEYS.CONSTRAINT_NAME
        IS 'Name of the primary key definition';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.DBC_PRIMARY_KEYS TO PUBLIC;

COMMIT;

--#####################
--# public synonym
--#####################

DROP PUBLIC SYNONYM IF EXISTS DBC_PRIMARY_KEYS;
CREATE PUBLIC SYNONYM DBC_PRIMARY_KEYS FOR INFORMATION_SCHEMA.DBC_PRIMARY_KEYS;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.DBC_FOREIGN_KEYS for ODBC SQLForeignKeys()
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.DBC_FOREIGN_KEYS;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.DBC_FOREIGN_KEYS 
(
       CONSTRAINT_CATALOG
     , CONSTRAINT_SCHEMA
     , CONSTRAINT_NAME
     , CONSTRAINT_TABLE_NAME
     , CONSTRAINT_COLUMN_NAME
     , ORDINAL_POSITION
     , UNIQUE_CONSTRAINT_CATALOG
     , UNIQUE_CONSTRAINT_SCHEMA
     , UNIQUE_CONSTRAINT_NAME
     , UNIQUE_CONSTRAINT_TABLE_NAME
     , UNIQUE_CONSTRAINT_COLUMN_NAME
     , UPDATE_RULE
     , DELETE_RULE
     , IS_DEFERRABLE
     , INITIALLY_DEFERRED
)
AS
SELECT
       /*+
           USE_NL( rcon )
           USE_NL( tcon )
           USE_NL( rkcu )
           USE_NL( ucon )
           USE_NL( ukcu )
           USE_NL( rcol )
           USE_NL( ucol )
           USE_NL( rtab )
           USE_NL( utab )
           USE_NL( sch1 )
           USE_NL( sch2 )
        */
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , sch1.SCHEMA_NAME
     , tcon.CONSTRAINT_NAME
     , rtab.TABLE_NAME
     , rcol.COLUMN_NAME
     , CAST( rkcu.ORDINAL_POSITION AS NUMBER )
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , sch2.SCHEMA_NAME
     , ucon.CONSTRAINT_NAME
     , utab.TABLE_NAME
     , ucol.COLUMN_NAME
     , rcon.UPDATE_RULE
     , rcon.DELETE_RULE
     , tcon.IS_DEFERRABLE
     , tcon.INITIALLY_DEFERRED
  FROM 
       DEFINITION_SCHEMA.REFERENTIAL_CONSTRAINTS@LOCAL  AS rcon
     , DEFINITION_SCHEMA.TABLE_CONSTRAINTS@LOCAL        AS tcon
     , DEFINITION_SCHEMA.KEY_COLUMN_USAGE@LOCAL         AS rkcu
     , DEFINITION_SCHEMA.TABLE_CONSTRAINTS@LOCAL        AS ucon
     , DEFINITION_SCHEMA.KEY_COLUMN_USAGE@LOCAL         AS ukcu
     , DEFINITION_SCHEMA.COLUMNS@LOCAL                  AS rcol
     , DEFINITION_SCHEMA.COLUMNS@LOCAL                  AS ucol
     , DEFINITION_SCHEMA.TABLES@LOCAL                   AS rtab
     , DEFINITION_SCHEMA.TABLES@LOCAL                   AS utab
     , DEFINITION_SCHEMA.SCHEMATA@LOCAL                 AS sch1 
     , DEFINITION_SCHEMA.SCHEMATA@LOCAL                 AS sch2 
 WHERE 
       rcon.CONSTRAINT_ID                = tcon.CONSTRAINT_ID
   AND rcon.UNIQUE_CONSTRAINT_ID         = ucon.CONSTRAINT_ID
   AND tcon.CONSTRAINT_ID                = rkcu.CONSTRAINT_ID
   AND tcon.TABLE_ID                     = rtab.TABLE_ID
   AND rkcu.COLUMN_ID                    = rcol.COLUMN_ID
   AND ucon.CONSTRAINT_ID                = ukcu.CONSTRAINT_ID
   AND ucon.TABLE_ID                     = utab.TABLE_ID
   AND rkcu.POSITION_IN_UNIQUE_CONSTRAINT = ukcu.ORDINAL_POSITION
   AND ukcu.COLUMN_ID                    = ucol.COLUMN_ID
   AND rcon.CONSTRAINT_SCHEMA_ID         = sch1.SCHEMA_ID
   AND rcon.UNIQUE_CONSTRAINT_SCHEMA_ID  = sch2.SCHEMA_ID
   AND EXISTS (
                  SELECT /*+ INDEX( pvtab, TABLE_PRIVILEGES_INDEX_TABLE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.TABLE_PRIVILEGES@LOCAL AS pvtab
                   WHERE pvtab.TABLE_ID = tcon.TABLE_ID
                     AND pvtab.GRANTEE_ID IN ( USER_ID(), 5 )
                  UNION ALL
                  SELECT /*+ INDEX( pvcol, COLUMN_PRIVILEGES_INDEX_TABLE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.COLUMN_PRIVILEGES@LOCAL AS pvcol 
                   WHERE pvcol.TABLE_ID = tcon.TABLE_ID
                     AND pvcol.GRANTEE_ID IN ( USER_ID(), 5 )
                  UNION ALL
                  SELECT /*+ INDEX( pvsch, SCHEMA_PRIVILEGES_INDEX_SCHEMA_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES@LOCAL AS pvsch
                   WHERE pvsch.SCHEMA_ID = tcon.TABLE_SCHEMA_ID
                     AND pvsch.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER TABLE', 'DROP TABLE', 
                                                   'SELECT TABLE', 'INSERT TABLE', 'DELETE TABLE', 'UPDATE TABLE', 'LOCK TABLE' ) 
                  UNION ALL
                  SELECT /*+ INDEX( pvdba, DATABASE_PRIVILEGES_INDEX_GRANTEE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES@LOCAL AS pvdba
                   WHERE pvdba.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY TABLE', 'DROP ANY TABLE', 
                                                   'SELECT ANY TABLE', 'INSERT ANY TABLE', 'DELETE ANY TABLE', 'UPDATE ANY TABLE', 'LOCK ANY TABLE' ) 
              )
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.DBC_FOREIGN_KEYS 
        IS 'Identify the foregin keys defined on tables in this catalog that are accssible to a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_FOREIGN_KEYS.CONSTRAINT_CATALOG
        IS 'catalog name of the foreign key';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_FOREIGN_KEYS.CONSTRAINT_SCHEMA
        IS 'schema name of the foreign key being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_FOREIGN_KEYS.CONSTRAINT_NAME
        IS 'foreign key name';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_FOREIGN_KEYS.CONSTRAINT_TABLE_NAME
        IS 'name of the table to which the foreign key being described applies';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_FOREIGN_KEYS.CONSTRAINT_COLUMN_NAME
        IS 'column name of the table to which the foreign key being described applies';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_FOREIGN_KEYS.ORDINAL_POSITION
        IS 'the ordinal position of the specific column in the referentail constraint being described.';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_FOREIGN_KEYS.UNIQUE_CONSTRAINT_CATALOG
        IS 'catalog name of the unique or primary key constraint applied to the referenced column list being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_FOREIGN_KEYS.UNIQUE_CONSTRAINT_SCHEMA
        IS 'schema name of the unique or primary key constraint applied to the referenced column list being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_FOREIGN_KEYS.UNIQUE_CONSTRAINT_NAME
        IS 'constraint name of the unique or primary key constraint applied to the referenced column list being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_FOREIGN_KEYS.UNIQUE_CONSTRAINT_TABLE_NAME
        IS 'table name of the unique or primary key constraint applied to the referenced column list being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_FOREIGN_KEYS.UNIQUE_CONSTRAINT_COLUMN_NAME
        IS 'column name of the unique or primary key constraint applied to the referenced column list being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_FOREIGN_KEYS.UPDATE_RULE
        IS 'the foreign key that has an update rule: the value in ( NO ACTION, RESTRICT, CASCADE, SET NULL, SET DEFAULT )';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_FOREIGN_KEYS.DELETE_RULE
        IS 'the foreign key that has a delete rule: the value in ( NO ACTION, RESTRICT, CASCADE, SET NULL, SET DEFAULT )';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_FOREIGN_KEYS.IS_DEFERRABLE
        IS 'is a deferrable constraint';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_FOREIGN_KEYS.INITIALLY_DEFERRED
        IS 'is an initially deferred constraint';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.DBC_FOREIGN_KEYS TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS DBC_FOREIGN_KEYS;
CREATE PUBLIC SYNONYM DBC_FOREIGN_KEYS FOR INFORMATION_SCHEMA.DBC_FOREIGN_KEYS;
COMMIT;



--##############################################################
--# INFORMATION_SCHEMA.DBC_STATISTICS for ODBC SQLStatistics()
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.DBC_STATISTICS;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.DBC_STATISTICS 
( 
       TABLE_CATALOG
     , TABLE_SCHEMA
     , TABLE_NAME
     , STAT_TYPE
     , NON_UNIQUE
     , INDEX_SCHEMA
     , INDEX_NAME
     , COLUMN_NAME
     , ORDINAL_POSITION
     , IS_ASCENDING_ORDER
     , CARDINALITY       
     , PAGES             
     , FILTER_CONDITION  
     , COMMENTS 
) 
AS
(
SELECT
       /*+
           USE_NL( ikey )
           USE_NL( idx )
           USE_NL( col )
           USE_NL( tab )
           USE_NL( sch1 )
           USE_NL( sch2 )
        */
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) )  -- TABLE_CATALOG 
     , sch2.SCHEMA_NAME                                -- TABLE_SCHEMA 
     , tab.TABLE_NAME                                  -- TABLE_NAME 
     , CAST( CASE idx.INDEX_TYPE WHEN 'HASH' THEN 'INDEX HASHED'
                                 ELSE 'INDEX OTHER'
                                 END
             AS VARCHAR(32 OCTETS) )                   -- STAT_TYPE
     , NOT idx.IS_UNIQUE                               -- NON_UNIQUE
     , sch1.SCHEMA_NAME                                -- INDEX_SCHEMA
     , idx.INDEX_NAME                                  -- INDEX_NAME
     , col.COLUMN_NAME                                 -- COLUMN_NAME
     , CAST( ikey.ORDINAL_POSITION AS NUMBER )         -- ORDINAL_POSITION
     , ikey.IS_ASCENDING_ORDER                         -- IS_ASCENDING_ORDER
     , CAST( ( SELECT stat.NUM_DISTINCT
                 FROM DEFINITION_SCHEMA.STAT_INDEX@LOCAL AS stat
                WHERE stat.INDEX_ID = idx.INDEX_ID )
              AS NUMBER )                              -- CARDINALITY
     , CAST( ( SELECT xseg.ALLOC_PAGE_COUNT
                 FROM FIXED_TABLE_SCHEMA.X$SEGMENT@LOCAL AS xseg
                WHERE xseg.PHYSICAL_ID = idx.PHYSICAL_ID )  
              AS NUMBER )                              -- PAGES
     , CAST( NULL AS VARCHAR(1024 OCTETS) )            -- FILTER_CONDITION
     , idx.COMMENTS                                    -- COMMENTS 
  FROM
       DEFINITION_SCHEMA.INDEX_KEY_COLUMN_USAGE@LOCAL AS ikey
     , DEFINITION_SCHEMA.INDEXES@LOCAL                AS idx
     , DEFINITION_SCHEMA.COLUMNS@LOCAL                AS col
     , DEFINITION_SCHEMA.TABLES@LOCAL                 AS tab 
     , DEFINITION_SCHEMA.SCHEMATA@LOCAL               AS sch1 
     , DEFINITION_SCHEMA.SCHEMATA@LOCAL               AS sch2 
 WHERE
       ikey.INDEX_ID          = idx.INDEX_ID
   AND ikey.COLUMN_ID         = col.COLUMN_ID
   AND ikey.TABLE_ID          = tab.TABLE_ID
   AND ikey.INDEX_SCHEMA_ID   = sch1.SCHEMA_ID
   AND ikey.TABLE_SCHEMA_ID   = sch2.SCHEMA_ID
   AND tab.IS_DROPPED = FALSE
   AND EXISTS (
                  SELECT /*+ INDEX( pvtab, TABLE_PRIVILEGES_INDEX_TABLE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.TABLE_PRIVILEGES@LOCAL AS pvtab
                   WHERE pvtab.TABLE_ID = col.TABLE_ID
                     AND pvtab.GRANTEE_ID IN ( USER_ID(), 5 )
                  UNION ALL
                  SELECT /*+ INDEX( pvcol, COLUMN_PRIVILEGES_INDEX_COLUMN_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.COLUMN_PRIVILEGES@LOCAL AS pvcol 
                   WHERE pvcol.COLUMN_ID = col.COLUMN_ID
                     AND pvcol.GRANTEE_ID IN ( USER_ID(), 5 )
                  UNION ALL
                  SELECT /*+ INDEX( pvsch, SCHEMA_PRIVILEGES_INDEX_SCHEMA_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES@LOCAL AS pvsch
                   WHERE pvsch.SCHEMA_ID = col.SCHEMA_ID
                     AND pvsch.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER TABLE', 'DROP TABLE', 
                                                   'SELECT TABLE', 'INSERT TABLE', 'DELETE TABLE', 'UPDATE TABLE', 'LOCK TABLE' ) 
                  UNION ALL
                  SELECT /*+ INDEX( pvdba, DATABASE_PRIVILEGES_INDEX_GRANTEE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES@LOCAL AS pvdba
                   WHERE pvdba.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY TABLE', 'DROP ANY TABLE', 
                                                   'SELECT ANY TABLE', 'INSERT ANY TABLE', 'DELETE ANY TABLE', 'UPDATE ANY TABLE', 'LOCK ANY TABLE' ) 
              )
) 
UNION ALL
(
SELECT
       /*+
           USE_NL( tab )
           USE_NL( sch )
        */
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) )  -- TABLE_CATALOG 
     , sch.SCHEMA_NAME                                 -- TABLE_SCHEMA 
     , tab.TABLE_NAME                                  -- TABLE_NAME 
     , CAST( 'TABLE STAT' AS VARCHAR(32 OCTETS) )      -- STAT_TYPE
     , CAST( NULL AS BOOLEAN )                         -- NON_UNIQUE
     , CAST( NULL AS VARCHAR(128 OCTETS) )             -- INDEX_SCHEMA
     , CAST( NULL AS VARCHAR(128 OCTETS) )             -- INDEX_NAME
     , CAST( NULL AS VARCHAR(128 OCTETS) )             -- COLUMN_NAME
     , CAST( NULL AS NUMBER )                          -- ORDINAL_POSITION
     , CAST( NULL AS BOOLEAN )                         -- IS_ASCENDING_ORDER
     , CAST( ( SELECT stat.NUM_ROWS
                 FROM DEFINITION_SCHEMA.STAT_TABLE@LOCAL AS stat
                WHERE stat.TABLE_ID = tab.TABLE_ID )
              AS NUMBER )                              -- CARDINALITY
     , CAST( ( SELECT xseg.ALLOC_PAGE_COUNT
                 FROM FIXED_TABLE_SCHEMA.X$SEGMENT@LOCAL AS xseg
                WHERE xseg.PHYSICAL_ID = tab.PHYSICAL_ID )  
              AS NUMBER )                              -- PAGES
     , CAST( NULL AS VARCHAR(1024 OCTETS) )            -- FILTER_CONDITION
     , tab.COMMENTS                                    -- COMMENTS 
  FROM  
       DEFINITION_SCHEMA.TABLES@LOCAL           AS tab 
     , DEFINITION_SCHEMA.SCHEMATA@LOCAL         AS sch 
 WHERE 
       tab.TABLE_TYPE IN ('BASE TABLE', 'GLOBAL TEMPORARY','IMMUTABLE TABLE')
   AND tab.SCHEMA_ID  = sch.SCHEMA_ID 
   AND tab.IS_DROPPED = FALSE
   AND EXISTS (
                  SELECT /*+ INDEX( pvtab, TABLE_PRIVILEGES_INDEX_TABLE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.TABLE_PRIVILEGES@LOCAL AS pvtab
                   WHERE pvtab.TABLE_ID = tab.TABLE_ID
                     AND pvtab.GRANTEE_ID IN ( USER_ID(), 5 )
                  UNION ALL
                  SELECT /*+ INDEX( pvcol, COLUMN_PRIVILEGES_INDEX_TABLE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.COLUMN_PRIVILEGES@LOCAL AS pvcol 
                   WHERE pvcol.TABLE_ID = tab.TABLE_ID
                     AND pvcol.GRANTEE_ID IN ( USER_ID(), 5 )
                  UNION ALL
                  SELECT /*+ INDEX( pvsch, SCHEMA_PRIVILEGES_INDEX_SCHEMA_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES@LOCAL AS pvsch
                   WHERE pvsch.SCHEMA_ID = tab.SCHEMA_ID
                     AND pvsch.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER TABLE', 'DROP TABLE', 
                                                   'SELECT TABLE', 'INSERT TABLE', 'DELETE TABLE', 'UPDATE TABLE', 'LOCK TABLE' ) 
                  UNION ALL
                  SELECT /*+ INDEX( pvdba, DATABASE_PRIVILEGES_INDEX_GRANTEE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES@LOCAL AS pvdba
                   WHERE pvdba.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY TABLE', 'DROP ANY TABLE', 
                                                   'SELECT ANY TABLE', 'INSERT ANY TABLE', 'DELETE ANY TABLE', 'UPDATE ANY TABLE', 'LOCK ANY TABLE' ) 
              )
)
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.DBC_STATISTICS 
        IS 'Provides a list of statistics about a single table and the indexes associated with the table that are accessible to a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_STATISTICS.TABLE_CATALOG                    
        IS 'catalog name of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_STATISTICS.TABLE_SCHEMA                     
        IS 'schema name of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_STATISTICS.TABLE_NAME
        IS 'table name of the table';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_STATISTICS.STAT_TYPE
        IS 'statistics type: the value in ( TABLE STAT, INDEX CLUSTERED, INDEX HASHED, INDEX OTHER )';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_STATISTICS.NON_UNIQUE
        IS 'indicates whether the index does not allow duplicate values';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_STATISTICS.INDEX_SCHEMA
        IS 'schema name of the index';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_STATISTICS.INDEX_NAME
        IS 'name of the index';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_STATISTICS.COLUMN_NAME
        IS 'column name that participates in the index';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_STATISTICS.ORDINAL_POSITION
        IS 'ordinal position of the specific column in the index described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_STATISTICS.IS_ASCENDING_ORDER
        IS 'index key column being described is sorted in ASCENDING(TRUE) or DESCENDING(FALSE) order';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_STATISTICS.CARDINALITY
        IS 'if STAT_TYPE is (TABLE TYPE), then this is the number of rows in the table; otherwise, it is the number of unique values in the index';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_STATISTICS.PAGES
        IS 'if STAT_TYPE is (TABLE TYPE), then this is the number of pages used for the table; otherwise, it is the number of pages used for the current index.';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_STATISTICS.FILTER_CONDITION
        IS 'filter condition, if any.';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_STATISTICS.COMMENTS 
        IS 'if STAT_TYPE is (TABLE TYPE), then this is the table comments; otherwise, it is the index comments.';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.DBC_STATISTICS TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS DBC_STATISTICS;
CREATE PUBLIC SYNONYM DBC_STATISTICS FOR INFORMATION_SCHEMA.DBC_STATISTICS;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.DBC_TABLE_PRIVILEGES for ODBC SQLTablePrivileges()
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.DBC_TABLE_PRIVILEGES;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.DBC_TABLE_PRIVILEGES
( 
       GRANTOR
     , GRANTEE
     , TABLE_CATALOG
     , TABLE_SCHEMA
     , TABLE_NAME
     , PRIVILEGE_TYPE
     , IS_GRANTABLE
)
AS
SELECT
       /*+
           USE_NL( pvtab )
           USE_NL( tab )
           USE_NL( sch )
           USE_NL( grantor )
           USE_NL( grantee )
        */
       grantor.AUTHORIZATION_NAME
     , grantee.AUTHORIZATION_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , sch.SCHEMA_NAME
     , tab.TABLE_NAME
     , pvtab.PRIVILEGE_TYPE
     , pvtab.IS_GRANTABLE
  FROM
       DEFINITION_SCHEMA.TABLE_PRIVILEGES@LOCAL  AS pvtab
     , DEFINITION_SCHEMA.TABLES@LOCAL            AS tab 
     , DEFINITION_SCHEMA.SCHEMATA@LOCAL          AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS@LOCAL    AS grantor
     , DEFINITION_SCHEMA.AUTHORIZATIONS@LOCAL    AS grantee
 WHERE
       pvtab.TABLE_ID   = tab.TABLE_ID
   AND pvtab.SCHEMA_ID  = sch.SCHEMA_ID
   AND pvtab.GRANTOR_ID = grantor.AUTH_ID
   AND pvtab.GRANTEE_ID = grantee.AUTH_ID
   AND tab.IS_DROPPED = FALSE
   AND ( grantee.AUTH_ID IN ( USER_ID(), 5 )
         OR
         grantor.AUTH_ID = USER_ID()
       )
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.DBC_TABLE_PRIVILEGES
        IS 'Identify the privileges on tables of tables defined in this catalog that are available to or granted by a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_TABLE_PRIVILEGES.GRANTOR
        IS 'authorization name of the user who granted table privileges';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_TABLE_PRIVILEGES.GRANTEE
        IS 'authorization name of some user or role, or PUBLIC to indicate all users, to whom the table privilege being described is granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_TABLE_PRIVILEGES.TABLE_CATALOG
        IS 'catalog name of the table on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_TABLE_PRIVILEGES.TABLE_SCHEMA 
        IS 'schema name of the table on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_TABLE_PRIVILEGES.TABLE_NAME 
        IS 'table name on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_TABLE_PRIVILEGES.PRIVILEGE_TYPE
        IS 'the value is in ( CONTROL, SELECT, INSERT, UPDATE, DELETE, REFERENCES, LOCK, INDEX, ALTER )';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_TABLE_PRIVILEGES.IS_GRANTABLE
        IS 'is grantable';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.DBC_TABLE_PRIVILEGES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS DBC_TABLE_PRIVILEGES;
CREATE PUBLIC SYNONYM DBC_TABLE_PRIVILEGES FOR INFORMATION_SCHEMA.DBC_TABLE_PRIVILEGES;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.COLUMN_PRIVILEGES
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.DBC_COLUMN_PRIVILEGES;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.DBC_COLUMN_PRIVILEGES
( 
       GRANTOR
     , GRANTEE
     , TABLE_CATALOG
     , TABLE_SCHEMA
     , TABLE_NAME
     , COLUMN_NAME
     , PRIVILEGE_TYPE
     , IS_GRANTABLE
)
AS
SELECT
       /*+
           USE_NL( pvcol )
           USE_NL( col )
           USE_NL( tab )
           USE_NL( sch )
           USE_NL( grantor )
           USE_NL( grantee )
        */
       grantor.AUTHORIZATION_NAME
     , grantee.AUTHORIZATION_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , sch.SCHEMA_NAME
     , tab.TABLE_NAME
     , col.COLUMN_NAME
     , pvcol.PRIVILEGE_TYPE
     , pvcol.IS_GRANTABLE
  FROM
       DEFINITION_SCHEMA.COLUMN_PRIVILEGES@LOCAL AS pvcol 
     , DEFINITION_SCHEMA.COLUMNS@LOCAL           AS col 
     , DEFINITION_SCHEMA.TABLES@LOCAL            AS tab 
     , DEFINITION_SCHEMA.SCHEMATA@LOCAL          AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS@LOCAL    AS grantor
     , DEFINITION_SCHEMA.AUTHORIZATIONS@LOCAL    AS grantee
 WHERE
       pvcol.COLUMN_ID  = col.COLUMN_ID
   AND pvcol.TABLE_ID   = tab.TABLE_ID
   AND pvcol.SCHEMA_ID  = sch.SCHEMA_ID
   AND pvcol.GRANTOR_ID = grantor.AUTH_ID
   AND pvcol.GRANTEE_ID = grantee.AUTH_ID
   AND tab.IS_DROPPED = FALSE
   AND ( grantee.AUTH_ID IN ( USER_ID(), 5 )
         OR
         grantor.AUTH_ID = USER_ID()
       )
 ORDER BY 
       pvcol.SCHEMA_ID
     , pvcol.TABLE_ID
     , pvcol.COLUMN_ID
     , pvcol.GRANTOR_ID
     , pvcol.GRANTEE_ID
     , pvcol.PRIVILEGE_TYPE_ID   
;

--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.DBC_COLUMN_PRIVILEGES
        IS 'Identify the privileges on columns of tables defined in this catalog that are available to or granted by a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMN_PRIVILEGES.GRANTOR
        IS 'authorization name of the user who granted column privileges';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMN_PRIVILEGES.GRANTEE
        IS 'authorization name of some user or role, or PUBLIC to indicate all users, to whom the column privilege being described is granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMN_PRIVILEGES.TABLE_CATALOG
        IS 'catalog name of the column on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMN_PRIVILEGES.TABLE_SCHEMA 
        IS 'schema name of the column on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMN_PRIVILEGES.TABLE_NAME 
        IS 'table name of the column on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMN_PRIVILEGES.COLUMN_NAME 
        IS 'column name of the column on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMN_PRIVILEGES.PRIVILEGE_TYPE
        IS 'the value is in ( SELECT, INSERT, UPDATE, REFERENCES )';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_COLUMN_PRIVILEGES.IS_GRANTABLE
        IS 'is grantable';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.DBC_COLUMN_PRIVILEGES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS DBC_COLUMN_PRIVILEGES;
CREATE PUBLIC SYNONYM DBC_COLUMN_PRIVILEGES FOR INFORMATION_SCHEMA.DBC_COLUMN_PRIVILEGES;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.DBC_PROCEDURES
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.DBC_PROCEDURES;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.DBC_PROCEDURES
(
       SPECIFIC_CATALOG
     , SPECIFIC_SCHEMA
     , SPECIFIC_NAME
     , ROUTINE_TYPE     
     , MODULE_NAME
)
AS
SELECT
       /*+
           USE_NL( R )
           USE_NL( sch )
        */
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , sch.SCHEMA_NAME
     , R.SPECIFIC_NAME
     , R.ROUTINE_TYPE
     , M.MODULE_NAME
   FROM 
       DEFINITION_SCHEMA.ROUTINES@LOCAL         AS R
         LEFT OUTER JOIN DEFINITION_SCHEMA.MODULES@LOCAL         AS M
         ON     R.MODULE_SCHEMA_ID = M.MODULE_SCHEMA_ID
            AND R.MODULE_ID = M.MODULE_ID
     , DEFINITION_SCHEMA.SCHEMATA@LOCAL         AS sch 
 WHERE 
       R.SPECIFIC_SCHEMA_ID = sch.SCHEMA_ID
   AND EXISTS (
                  SELECT /*+ INDEX( pvproc, ROUTINE_PRIVILEGES_INDEX_SPECIFIC_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.ROUTINE_PRIVILEGES@LOCAL AS pvproc
                   WHERE pvproc.SPECIFIC_ID = R.SPECIFIC_ID
                     AND pvproc.GRANTEE_ID IN ( USER_ID(), 5 )
                  UNION ALL
                  SELECT /*+ INDEX( pvsch, SCHEMA_PRIVILEGES_INDEX_SCHEMA_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch 
                   WHERE pvsch.SCHEMA_ID = R.SPECIFIC_SCHEMA_ID
                     AND pvsch.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER PROCEDURE', 'DROP PROCEDURE', 'EXECUTE PROCEDURE' ) 
                  UNION ALL
                  SELECT /*+ INDEX( pvdba, DATABASE_PRIVILEGES_INDEX_GRANTEE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES@LOCAL AS pvdba
                   WHERE pvdba.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY PROCEDURE', 'DROP ANY PROCEDURE', 'EXECUTE ANY PROCEDURE' )
              )
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.DBC_PROCEDURES
        IS 'Identify the stored procedure/function in this catalog that are accessible to a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURES.SPECIFIC_CATALOG
        IS 'specific catalog name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURES.SPECIFIC_SCHEMA
        IS 'specific schema name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURES.SPECIFIC_NAME
        IS 'specific name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURES.ROUTINE_TYPE
        IS 'name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURES.MODULE_NAME
        IS 'module name of the routine';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.DBC_PROCEDURES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS DBC_PROCEDURES;
CREATE PUBLIC SYNONYM DBC_PROCEDURES FOR INFORMATION_SCHEMA.DBC_PROCEDURES;
COMMIT;



--##############################################################
--# INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS
(
       SPECIFIC_CATALOG
     , SPECIFIC_SCHEMA
     , SPECIFIC_NAME
     , ORDINAL_POSITION
     , PARAMETER_MODE
     , IS_RESULT
     , PARAMETER_NAME
     , DATA_TYPE
     , CHARACTER_MAXIMUM_LENGTH
     , CHARACTER_OCTET_LENGTH
     , NUMERIC_PRECISION
     , NUMERIC_PRECISION_RADIX
     , NUMERIC_SCALE
     , DATETIME_PRECISION
     , INTERVAL_PRECISION
     , PARAMETER_DEFAULT
     , MODULE_NAME
)
AS
SELECT
       /*+
           USE_NL( DTD )
           USE_NL( R )
           USE_NL( sch )
        */
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) )
     , sch.SCHEMA_NAME
     , R.SPECIFIC_NAME
     , CAST( 0 AS NUMBER )                           -- ORDINAL_POSITION
     , CAST( 'OUT' AS VARCHAR(32 OCTETS) )           -- PARAMETER_MODE
     , FALSE                                         -- IS_RESULT
     , CAST( 'RETURN_VALUE' AS VARCHAR(128 OCTETS) ) -- PARAMETER_NAME
     , CAST( CASE WHEN DTD.DATA_TYPE IN ( 'INTERVAL YEAR TO MONTH', 'INTERVAL DAY TO SECOND' )
                       THEN 'INTERVAL ' || dtd.INTERVAL_TYPE
                  WHEN ( DTD.DATA_TYPE = 'NUMBER' AND dtd.NUMERIC_PRECISION_RADIX = 2 )
                       THEN 'FLOAT'
                  ELSE DTD.DATA_TYPE
                  END
             AS VARCHAR(128 OCTETS) ) -- DATA_TYPE
     , CAST( DTD.CHARACTER_MAXIMUM_LENGTH AS NUMBER )
     , CAST( DTD.CHARACTER_OCTET_LENGTH AS NUMBER )
     , CAST( DTD.NUMERIC_PRECISION AS NUMBER )
     , CAST( DTD.NUMERIC_PRECISION_RADIX AS NUMBER )
     , CAST( CASE WHEN DTD.NUMERIC_SCALE BETWEEN -256 AND 256
                  THEN DTD.NUMERIC_SCALE
                  ELSE NULL
                  END
             AS NUMBER )
     , CAST( DTD.DATETIME_PRECISION AS NUMBER )
     , CAST( DTD.INTERVAL_PRECISION AS NUMBER )
     , CAST( NULL AS LONG VARCHAR )            -- PARAMETER_DEFAULT
     , M.MODULE_NAME
  FROM
       DEFINITION_SCHEMA.ROUTINES@LOCAL  AS R
         LEFT OUTER JOIN DEFINITION_SCHEMA.MODULES@LOCAL         AS M
         ON     R.MODULE_SCHEMA_ID = M.MODULE_SCHEMA_ID
            AND R.MODULE_ID = M.MODULE_ID
     , DEFINITION_SCHEMA.DATA_TYPE_DESCRIPTOR@LOCAL AS DTD
     , DEFINITION_SCHEMA.SCHEMATA@LOCAL  AS sch
 WHERE
       R.DTD_IDENTIFIER IS NOT NULL
   AND DTD.OBJECT_TYPE  = 'ROUTINE'
   AND R.DTD_IDENTIFIER     = DTD.DTD_IDENTIFIER
   AND R.SPECIFIC_SCHEMA_ID = sch.SCHEMA_ID
   AND EXISTS (
                  SELECT /*+ INDEX( pvproc, ROUTINE_PRIVILEGES_INDEX_SPECIFIC_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.ROUTINE_PRIVILEGES@LOCAL AS pvproc
                   WHERE pvproc.SPECIFIC_ID = R.SPECIFIC_ID
                     AND pvproc.GRANTEE_ID IN ( USER_ID(), 5 )
                  UNION ALL
                  SELECT /*+ INDEX( pvsch, SCHEMA_PRIVILEGES_INDEX_SCHEMA_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch
                   WHERE pvsch.SCHEMA_ID = R.SPECIFIC_SCHEMA_ID
                     AND pvsch.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER PROCEDURE', 'DROP PROCEDURE', 'EXECUTE PROCEDURE' )
                  UNION ALL
                  SELECT /*+ INDEX( pvdba, DATABASE_PRIVILEGES_INDEX_GRANTEE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES@LOCAL AS pvdba
                   WHERE pvdba.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY PROCEDURE', 'DROP ANY PROCEDURE', 'EXECUTE ANY PROCEDURE' )
              )
UNION ALL
SELECT
       /*+
           USE_NL( P )
           USE_NL( DTD )
           USE_NL( R )
           USE_NL( sch )
        */
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) )
     , sch.SCHEMA_NAME
     , R.SPECIFIC_NAME
     , CAST( P.ORDINAL_POSITION AS NUMBER )
     , P.PARAMETER_MODE
     , P.IS_RESULT
     , P.PARAMETER_NAME
     , CAST( CASE WHEN DTD.DATA_TYPE IN ( 'INTERVAL YEAR TO MONTH', 'INTERVAL DAY TO SECOND' )
                       THEN 'INTERVAL ' || dtd.INTERVAL_TYPE
                  WHEN ( DTD.DATA_TYPE = 'NUMBER' AND dtd.NUMERIC_PRECISION_RADIX = 2 )
                       THEN 'FLOAT'
                  ELSE DTD.DATA_TYPE
                  END
             AS VARCHAR(128 OCTETS) ) -- DATA_TYPE
     , CAST( DTD.CHARACTER_MAXIMUM_LENGTH AS NUMBER )
     , CAST( DTD.CHARACTER_OCTET_LENGTH AS NUMBER )
     , CAST( DTD.NUMERIC_PRECISION AS NUMBER )
     , CAST( DTD.NUMERIC_PRECISION_RADIX AS NUMBER )
     , CAST( CASE WHEN DTD.NUMERIC_SCALE BETWEEN -256 AND 256
                  THEN DTD.NUMERIC_SCALE
                  ELSE NULL
                  END
             AS NUMBER )
     , CAST( DTD.DATETIME_PRECISION AS NUMBER )
     , CAST( DTD.INTERVAL_PRECISION AS NUMBER )
     , P.PARAMETER_DEFAULT
     , M.MODULE_NAME
  FROM
       DEFINITION_SCHEMA.PARAMETERS@LOCAL AS P
     , DEFINITION_SCHEMA.DATA_TYPE_DESCRIPTOR@LOCAL AS DTD
     , DEFINITION_SCHEMA.ROUTINES@LOCAL  AS R
         LEFT OUTER JOIN DEFINITION_SCHEMA.MODULES@LOCAL         AS M
         ON     R.MODULE_SCHEMA_ID = M.MODULE_SCHEMA_ID
            AND R.MODULE_ID = M.MODULE_ID
     , DEFINITION_SCHEMA.SCHEMATA@LOCAL  AS sch
 WHERE
       DTD.OBJECT_TYPE  = 'ROUTINE'
   AND P.SPECIFIC_ID    = DTD.OBJECT_ID
   AND P.DTD_IDENTIFIER = DTD.DTD_IDENTIFIER
   AND R.SPECIFIC_SCHEMA_ID = P.SPECIFIC_SCHEMA_ID
   AND R.SPECIFIC_ID = P.SPECIFIC_ID
   AND R.SPECIFIC_SCHEMA_ID = sch.SCHEMA_ID
   AND EXISTS (
                  SELECT /*+ INDEX( pvproc, ROUTINE_PRIVILEGES_INDEX_SPECIFIC_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.ROUTINE_PRIVILEGES@LOCAL AS pvproc
                   WHERE pvproc.SPECIFIC_ID = R.SPECIFIC_ID
                     AND pvproc.GRANTEE_ID IN ( USER_ID(), 5 )
                  UNION ALL
                  SELECT /*+ INDEX( pvsch, SCHEMA_PRIVILEGES_INDEX_SCHEMA_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch
                   WHERE pvsch.SCHEMA_ID = R.SPECIFIC_SCHEMA_ID
                     AND pvsch.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER PROCEDURE', 'DROP PROCEDURE', 'EXECUTE PROCEDURE' )
                  UNION ALL
                  SELECT /*+ INDEX( pvdba, DATABASE_PRIVILEGES_INDEX_GRANTEE_ID ) */
                         1
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES@LOCAL AS pvdba
                   WHERE pvdba.GRANTEE_ID IN ( USER_ID(), 5 )
                     AND pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY PROCEDURE', 'DROP ANY PROCEDURE', 'EXECUTE ANY PROCEDURE' )
              )
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS
        IS 'Identify the SQL parameters of stored procedures/functions defined in this catalog that are accessible to a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.SPECIFIC_CATALOG
        IS 'catalog name of the specific name of the stored procedure that contains the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.SPECIFIC_SCHEMA
        IS 'schema name of the specific name of the stored procedure that contains the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.SPECIFIC_NAME
        IS 'specific name of the stored procedure that contains the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.ORDINAL_POSITION
        IS 'ordinal position of the stored procedure that contains the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.PARAMETER_MODE
        IS 'parameter mode of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.IS_RESULT
        IS 'the parameter is RESULT parameter of type-preserving function';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.PARAMETER_NAME
        IS 'name of the SQL parameter being descaibed';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.DATA_TYPE
        IS 'data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.CHARACTER_MAXIMUM_LENGTH
        IS 'maximum length of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.CHARACTER_OCTET_LENGTH
        IS 'maximum length in octets of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.NUMERIC_PRECISION
        IS 'precision of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.NUMERIC_PRECISION_RADIX
        IS 'precision radix of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.NUMERIC_SCALE
        IS 'scale of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.DATETIME_PRECISION
        IS 'fractional second precisions of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.INTERVAL_PRECISION
        IS 'interval precision of the data type of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.PARAMETER_DEFAULT
        IS 'default value of the SQL parameter being described';
COMMENT ON COLUMN INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS.MODULE_NAME
        IS 'module name of the specific name of the stored procedure that contains the SQL parameter being described';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS DBC_PROCEDURE_COLUMNS;
CREATE PUBLIC SYNONYM DBC_PROCEDURE_COLUMNS FOR INFORMATION_SCHEMA.DBC_PROCEDURE_COLUMNS;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.MODULES
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.MODULES;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.MODULES
(
       MODULE_CATALOG
     , MODULE_OWNER
     , MODULE_SCHEMA
     , MODULE_NAME
     , DEFAULT_CHARACTER_SET_CATALOG
     , DEFAULT_CHARACTER_SET_SCHEMA
     , DEFAULT_CHARACTER_SET
     , DEFAULT_SCHEMA_CATALOG
     , DEFAULT_SCHEMA_NAME
     , MODULE_DEFINITION
     , MODULE_AUTHORIZATION
     , SQL_PATH
     , CREATED
     , LAST_ALTERED
)
AS
SELECT
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth.AUTHORIZATION_NAME
     , sch.SCHEMA_NAME
     , mdl.MODULE_NAME
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DEFAULT_CHARACTER_SET_CATALOG
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DEFAULT_CHARACTER_SET_SCHEMA 
     , CAST( NULL AS VARCHAR(128 OCTETS) ) -- DEFAULT_CHARACTER_SET_NAME 
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , sch2.SCHEMA_NAME
     , mdl.MODULE_DEFINITION -- MODULE_DEFINITION
     , mdl.SECURITY_TYPE
     , mdl.SQL_PATH
     , mdl.CREATED_TIME
     , mdl.MODIFIED_TIME
  FROM 
       DEFINITION_SCHEMA.MODULES          AS mdl
         LEFT OUTER JOIN  DEFINITION_SCHEMA.SCHEMATA         AS sch2
         ON mdl.DEFAULT_SCHEMA_ID = sch2.SCHEMA_ID
     , DEFINITION_SCHEMA.SCHEMATA         AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth 
 WHERE 
       mdl.MODULE_SCHEMA_ID = sch.SCHEMA_ID
   AND mdl.MODULE_OWNER_ID  = auth.AUTH_ID
   AND ( mdl.MODULE_ID IN ( SELECT pvmdl.MODULE_ID 
                              FROM DEFINITION_SCHEMA.MODULE_PRIVILEGES AS pvmdl 
                             WHERE ( pvmdl.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                             FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS autab 
                                                            WHERE autab.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                         ) 
                                   -- OR  
                                   -- pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                   --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                   )
                          ) 
         OR 
         mdl.MODULE_SCHEMA_ID IN ( SELECT pvsch.SCHEMA_ID 
                                     FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch 
                                    WHERE pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER PACKAGE', 'DROP PACKAGE', 'EXECUTE PACKAGE' ) 
                                      AND ( pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                                    FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS ausch 
                                                                   WHERE ausch.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                                ) 
                                          -- OR  
                                          -- pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                          --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                          )
                                 ) 
         OR 
         EXISTS ( SELECT GRANTEE_ID  
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES pvdba 
                   WHERE pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY PACKAGE', 'DROP ANY PACKAGE', 'EXECUTE ANY PACKAGE' )
                     AND ( pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                   FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS audba 
                                                  WHERE audba.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                ) 
                        -- OR  
                        -- pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                        --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                          )  
                ) 
       ) 
ORDER BY 
      sch.SCHEMA_NAME
    , mdl.MODULE_NAME
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.MODULES
        IS 'Identify the SQL-server modules in this catalog that are accessible to a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.MODULES.MODULE_CATALOG
        IS 'catalog name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULES.MODULE_OWNER
        IS 'owner name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULES.MODULE_SCHEMA
        IS 'schema name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULES.MODULE_NAME
        IS 'name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULES.DEFAULT_CHARACTER_SET_CATALOG
        IS 'default character set catalog name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULES.DEFAULT_CHARACTER_SET_SCHEMA
        IS 'default character set schema name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULES.DEFAULT_CHARACTER_SET
        IS 'default character set name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULES.DEFAULT_SCHEMA_CATALOG
        IS 'catalog name of default schema of SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULES.DEFAULT_SCHEMA_NAME
        IS 'default scheam name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULES.MODULE_DEFINITION
        IS 'definition of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULES.MODULE_AUTHORIZATION
        IS 'authorization of the SQL-server module(DEFINER/INVOKER)';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULES.SQL_PATH
        IS 'described SQL PATH when the SQL-server module is defined';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULES.CREATED
        IS 'creation time of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULES.LAST_ALTERED
        IS 'most lately altered time of the SQL-server module';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.MODULES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS MODULES;
CREATE PUBLIC SYNONYM MODULES FOR INFORMATION_SCHEMA.MODULES;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.MODULE_PRIVILEGES
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.MODULE_PRIVILEGES;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.MODULE_PRIVILEGES
(
       GRANTOR
     , GRANTEE
     , MODULE_CATALOG
     , MODULE_OWNER
     , MODULE_SCHEMA
     , MODULE_NAME
     , PRIVILEGE_TYPE
     , IS_GRANTABLE
)
AS
SELECT 
       grantor.AUTHORIZATION_NAME                     -- GRANTOR
     , grantee.AUTHORIZATION_NAME                     -- GRANTEE
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- MODULE_CATALOG
     , auth.AUTHORIZATION_NAME                        -- MODULE_OWNER
     , sch.SCHEMA_NAME                                -- MODULE_SCHEMA
     , mdl.MODULE_NAME                                -- MODULE_NAME
     , pvmdl.PRIVILEGE_TYPE                           -- PRIVILEGE_TYPE
     , pvmdl.IS_GRANTABLE                             -- IS_GRANTABLE
  FROM
       DEFINITION_SCHEMA.MODULE_PRIVILEGES  AS pvmdl
     , DEFINITION_SCHEMA.MODULES            AS mdl
     , DEFINITION_SCHEMA.SCHEMATA           AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS     AS grantor
     , DEFINITION_SCHEMA.AUTHORIZATIONS     AS grantee
     , DEFINITION_SCHEMA.AUTHORIZATIONS     AS auth
 WHERE 
       pvmdl.MODULE_ID = mdl.MODULE_ID
   AND pvmdl.GRANTOR_ID  = grantor.AUTH_ID
   AND pvmdl.GRANTEE_ID  = grantee.AUTH_ID
   AND pvmdl.MODULE_SCHEMA_ID = sch.SCHEMA_ID
   AND pvmdl.MODULE_OWNER_ID  = auth.AUTH_ID
   AND ( grantee.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )
      -- OR  
      -- pvcol.GRANTEE_ID IN ( SELECT AUTH_ID 
      --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
         OR
         grantor.AUTHORIZATION_NAME = CURRENT_USER
       )
ORDER BY 
       pvmdl.MODULE_SCHEMA_ID
     , pvmdl.MODULE_ID
     , pvmdl.GRANTOR_ID
     , pvmdl.GRANTEE_ID
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.MODULE_PRIVILEGES
        IS 'Identify the privileges on SQL-server modules defined in this catalog that are available to or granted by a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_PRIVILEGES.GRANTOR
        IS 'authorization name of the user who granted SQL-server module privileges';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_PRIVILEGES.GRANTEE
        IS 'authorization name of some user or role, or PUBLIC to indicate all users, to whom the SQL-server module privilege being described is granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_PRIVILEGES.MODULE_CATALOG
        IS 'catalog name of the SQL-server module on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_PRIVILEGES.MODULE_OWNER
        IS 'owner name of the the SQL-server module on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_PRIVILEGES.MODULE_SCHEMA
        IS 'schema name of the the SQL-server module on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_PRIVILEGES.MODULE_NAME
        IS 'name of the the SQL-server module on which the privilege being described was granted';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_PRIVILEGES.PRIVILEGE_TYPE
        IS 'the value is in ( EXECUTE )';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_PRIVILEGES.IS_GRANTABLE
        IS 'is grantable';


--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.MODULE_PRIVILEGES TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS MODULE_PRIVILEGES;
CREATE PUBLIC SYNONYM MODULE_PRIVILEGES FOR INFORMATION_SCHEMA.MODULE_PRIVILEGES;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.MODULE_TABLE_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.MODULE_TABLE_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.MODULE_TABLE_USAGE
(
       MODULE_CATALOG
     , MODULE_OWNER
     , MODULE_SCHEMA
     , MODULE_NAME
     , TABLE_CATALOG
     , TABLE_OWNER
     , TABLE_SCHEMA
     , TABLE_NAME
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- MODULE_CATALOG
     , auth1.AUTHORIZATION_NAME                       -- MODULE_OWNER
     , sch1.SCHEMA_NAME                               -- MODULE_SCHEMA
     , mdl1.MODULE_NAME                               -- MODULE_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- TABLE_CATALOG
     , auth2.AUTHORIZATION_NAME                       -- TABLE_OWNER
     , sch2.SCHEMA_NAME                               -- TABLE_SCHEMA
     , tab2.TABLE_NAME                                -- TABLE_NAME
  FROM 
       DEFINITION_SCHEMA.MODULE_TABLE_USAGE AS mtu
     , DEFINITION_SCHEMA.MODULES          AS mdl1
     , DEFINITION_SCHEMA.SCHEMATA         AS sch1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth1
     , DEFINITION_SCHEMA.TABLES           AS tab2
     , DEFINITION_SCHEMA.SCHEMATA         AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth2
 WHERE 
       mtu.MODULE_ID          = mdl1.MODULE_ID
   AND mtu.MODULE_SCHEMA_ID   = sch1.SCHEMA_ID 
   AND mtu.MODULE_OWNER_ID    = auth1.AUTH_ID 
   AND mtu.TABLE_ID           = tab2.TABLE_ID 
   AND mtu.TABLE_SCHEMA_ID    = sch2.SCHEMA_ID
   AND mtu.TABLE_OWNER_ID     = auth2.AUTH_ID 
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR 
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       ) 
ORDER BY 
      mtu.MODULE_SCHEMA_ID 
    , mtu.MODULE_ID 
    , mtu.TABLE_SCHEMA_ID
    , mtu.TABLE_ID
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.MODULE_TABLE_USAGE
        IS 'Identify the tables owned by a given user or role on which SQL-server modules defined in this catalog are dependent.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_TABLE_USAGE.MODULE_CATALOG
        IS 'catalog name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_TABLE_USAGE.MODULE_OWNER
        IS 'owner name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_TABLE_USAGE.MODULE_SCHEMA
        IS 'schema name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_TABLE_USAGE.MODULE_NAME
        IS 'name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_TABLE_USAGE.TABLE_CATALOG
        IS 'catalog name of the table of contained in definition text of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_TABLE_USAGE.TABLE_OWNER
        IS 'owner name of the table of contained in definition text of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_TABLE_USAGE.TABLE_SCHEMA
        IS 'schema name of the table of contained in definition text of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_TABLE_USAGE.TABLE_NAME
        IS 'table name of contained in definition text of the SQL-server module';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.MODULE_TABLE_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS MODULE_TABLE_USAGE;
CREATE PUBLIC SYNONYM MODULE_TABLE_USAGE FOR INFORMATION_SCHEMA.MODULE_TABLE_USAGE;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.MODULE_MODULE_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.MODULE_MODULE_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.MODULE_MODULE_USAGE
(
       MODULE_CATALOG
     , MODULE_OWNER
     , MODULE_SCHEMA
     , MODULE_NAME
     , REF_MODULE_CATALOG
     , REF_MODULE_OWNER
     , REF_MODULE_SCHEMA
     , REF_MODULE_NAME
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- MODULE_CATALOG
     , auth1.AUTHORIZATION_NAME                       -- MODULE_OWNER
     , sch1.SCHEMA_NAME                               -- MODULE_SCHEMA
     , mdl1.MODULE_NAME                               -- MODULE_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- REF_MODULE_CATALOG
     , auth2.AUTHORIZATION_NAME                       -- REF_MODULE_OWNER
     , sch2.SCHEMA_NAME                               -- REF_MODULE_SCHEMA
     , mdl2.MODULE_NAME                               -- REF_MODULE_NAME
  FROM 
       DEFINITION_SCHEMA.MODULE_MODULE_USAGE AS mmu
     , DEFINITION_SCHEMA.MODULES          AS mdl1
     , DEFINITION_SCHEMA.SCHEMATA         AS sch1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth1
     , DEFINITION_SCHEMA.MODULES          AS mdl2
     , DEFINITION_SCHEMA.SCHEMATA         AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth2
 WHERE 
       mmu.MODULE_ID            = mdl1.MODULE_ID
   AND mmu.MODULE_SCHEMA_ID     = sch1.SCHEMA_ID 
   AND mmu.MODULE_OWNER_ID      = auth1.AUTH_ID 
   AND mmu.REF_MODULE_ID        = mdl2.MODULE_ID 
   AND mmu.REF_MODULE_SCHEMA_ID = sch2.SCHEMA_ID
   AND mmu.REF_MODULE_OWNER_ID  = auth2.AUTH_ID 
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR 
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       ) 
ORDER BY 
      mmu.MODULE_SCHEMA_ID 
    , mmu.MODULE_ID 
    , mmu.REF_MODULE_SCHEMA_ID
    , mmu.REF_MODULE_ID
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.MODULE_MODULE_USAGE
        IS 'Identify the SQL-server modules owned by a given user or role on which SQL-server modules defined in this catalog are dependent.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_MODULE_USAGE.MODULE_CATALOG
        IS 'catalog name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_MODULE_USAGE.MODULE_OWNER
        IS 'owner name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_MODULE_USAGE.MODULE_SCHEMA
        IS 'schema name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_MODULE_USAGE.MODULE_NAME
        IS 'name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_MODULE_USAGE.REF_MODULE_CATALOG
        IS 'catalog name of the SQL-server module of contained in definition text of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_MODULE_USAGE.REF_MODULE_OWNER
        IS 'owner name of the SQL-server module of contained in definition text of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_MODULE_USAGE.REF_MODULE_SCHEMA
        IS 'schema name of the SQL-server module of contained in definition text of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_MODULE_USAGE.REF_MODULE_NAME
        IS 'SQL-server module name of contained in definition text of the SQL-server module';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.MODULE_MODULE_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS MODULE_MODULE_USAGE;
CREATE PUBLIC SYNONYM MODULE_MODULE_USAGE FOR INFORMATION_SCHEMA.MODULE_MODULE_USAGE;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.MODULE_ROUTINE_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.MODULE_ROUTINE_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.MODULE_ROUTINE_USAGE
(
       MODULE_CATALOG
     , MODULE_OWNER
     , MODULE_SCHEMA
     , MODULE_NAME
     , ROUTINE_CATALOG
     , ROUTINE_OWNER
     , ROUTINE_SCHEMA
     , ROUTINE_NAME
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- MODULE_CATALOG
     , auth1.AUTHORIZATION_NAME                       -- MODULE_OWNER
     , sch1.SCHEMA_NAME                               -- MODULE_SCHEMA
     , mdl1.MODULE_NAME                               -- MODULE_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- ROUTINE_CATALOG
     , auth2.AUTHORIZATION_NAME                       -- ROUTINE_OWNER
     , sch2.SCHEMA_NAME                               -- ROUTINE_SCHEMA
     , rtn2.SPECIFIC_NAME                             -- ROUTINE_NAME
  FROM 
       DEFINITION_SCHEMA.MODULE_ROUTINE_USAGE AS mru
     , DEFINITION_SCHEMA.MODULES          AS mdl1
     , DEFINITION_SCHEMA.SCHEMATA         AS sch1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth1
     , DEFINITION_SCHEMA.ROUTINES         AS rtn2
     , DEFINITION_SCHEMA.SCHEMATA         AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth2
 WHERE 
       mru.MODULE_ID         = mdl1.MODULE_ID
   AND mru.MODULE_SCHEMA_ID  = sch1.SCHEMA_ID 
   AND mru.MODULE_OWNER_ID   = auth1.AUTH_ID 
   AND mru.ROUTINE_ID        = rtn2.SPECIFIC_ID 
   AND mru.ROUTINE_SCHEMA_ID = sch2.SCHEMA_ID
   AND mru.ROUTINE_OWNER_ID  = auth2.AUTH_ID 
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR 
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       ) 
ORDER BY 
      mru.MODULE_SCHEMA_ID 
    , mru.MODULE_ID 
    , mru.ROUTINE_SCHEMA_ID
    , mru.ROUTINE_ID
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.MODULE_ROUTINE_USAGE
        IS 'Identify the SQL-invoked routines owned by a given user or role on which SQL-server modules defined in this catalog are dependent.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_ROUTINE_USAGE.MODULE_CATALOG
        IS 'catalog name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_ROUTINE_USAGE.MODULE_OWNER
        IS 'owner name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_ROUTINE_USAGE.MODULE_SCHEMA
        IS 'schema name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_ROUTINE_USAGE.MODULE_NAME
        IS 'name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_ROUTINE_USAGE.ROUTINE_CATALOG
        IS 'catalog name of the SQL-invoked routine of contained in definition text of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_ROUTINE_USAGE.ROUTINE_OWNER
        IS 'owner name of the SQL-invoked routine of contained in definition text of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_ROUTINE_USAGE.ROUTINE_SCHEMA
        IS 'schema name of the SQL-invoked routine of contained in definition text of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_ROUTINE_USAGE.ROUTINE_NAME
        IS 'SQL-invoked routine name of contained in definition text of the SQL-server module';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.MODULE_ROUTINE_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS MODULE_ROUTINE_USAGE;
CREATE PUBLIC SYNONYM MODULE_ROUTINE_USAGE FOR INFORMATION_SCHEMA.MODULE_ROUTINE_USAGE;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.MODULE_SQUENCE_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.MODULE_SEQUENCE_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.MODULE_SEQUENCE_USAGE
(
       MODULE_CATALOG
     , MODULE_OWNER
     , MODULE_SCHEMA
     , MODULE_NAME
     , SEQUENCE_CATALOG
     , SEQUENCE_OWNER
     , SEQUENCE_SCHEMA
     , SEQUENCE_NAME
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- MODULE_CATALOG
     , auth1.AUTHORIZATION_NAME                       -- MODULE_OWNER
     , sch1.SCHEMA_NAME                               -- MODULE_SCHEMA
     , mdl1.MODULE_NAME                               -- MODULE_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- SEQUENCE_CATALOG
     , auth2.AUTHORIZATION_NAME                       -- SEQUENCE_OWNER
     , sch2.SCHEMA_NAME                               -- SEQUENCE_SCHEMA
     , seq2.SEQUENCE_NAME                             -- SEQUENCE_NAME
  FROM 
       DEFINITION_SCHEMA.MODULE_SEQUENCE_USAGE AS msu
     , DEFINITION_SCHEMA.MODULES          AS mdl1
     , DEFINITION_SCHEMA.SCHEMATA         AS sch1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth1
     , DEFINITION_SCHEMA.SEQUENCES        AS seq2
     , DEFINITION_SCHEMA.SCHEMATA         AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth2
 WHERE 
       msu.MODULE_ID          = mdl1.MODULE_ID
   AND msu.MODULE_SCHEMA_ID   = sch1.SCHEMA_ID 
   AND msu.MODULE_OWNER_ID    = auth1.AUTH_ID 
   AND msu.SEQUENCE_ID        = seq2.SEQUENCE_ID 
   AND msu.SEQUENCE_SCHEMA_ID = sch2.SCHEMA_ID
   AND msu.SEQUENCE_OWNER_ID  = auth2.AUTH_ID 
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR 
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       ) 
ORDER BY 
      msu.MODULE_SCHEMA_ID 
    , msu.MODULE_ID 
    , msu.SEQUENCE_SCHEMA_ID
    , msu.SEQUENCE_ID
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.MODULE_SEQUENCE_USAGE
        IS 'Identify the sequences owned by a given user or role on which SQL-server modules defined in this catalog are dependent.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_SEQUENCE_USAGE.MODULE_CATALOG
        IS 'catalog name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_SEQUENCE_USAGE.MODULE_OWNER
        IS 'owner name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_SEQUENCE_USAGE.MODULE_SCHEMA
        IS 'schema name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_SEQUENCE_USAGE.MODULE_NAME
        IS 'name of SQL-server the module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_SEQUENCE_USAGE.SEQUENCE_CATALOG
        IS 'catalog name of the sequence of contained in definition text of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_SEQUENCE_USAGE.SEQUENCE_OWNER
        IS 'owner name of the sequence of contained in definition text of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_SEQUENCE_USAGE.SEQUENCE_SCHEMA
        IS 'schema name of the sequence of contained in definition text of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_SEQUENCE_USAGE.SEQUENCE_NAME
        IS 'sequence name of contained in definition text of the SQL-server module';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.MODULE_SEQUENCE_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS MODULE_SEQUENCE_USAGE;
CREATE PUBLIC SYNONYM MODULE_SEQUENCE_USAGE FOR INFORMATION_SCHEMA.MODULE_SEQUENCE_USAGE;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.MODULE_BODY
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.MODULE_BODY;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.MODULE_BODY
(
       MODULE_CATALOG
     , MODULE_OWNER
     , MODULE_SCHEMA
     , MODULE_NAME
     , MODULE_DEFINITION
     , CREATED
     , LAST_ALTERED
)
AS
SELECT
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) 
     , auth.AUTHORIZATION_NAME
     , sch.SCHEMA_NAME
     , mdl.MODULE_NAME
     , CASE WHEN ( CURRENT_USER IN ( auth.AUTHORIZATION_NAME ) ) THEN mdlbd.MODULE_DEFINITION ELSE CAST( 'not owner' AS LONG VARCHAR ) END
     , mdl.CREATED_TIME
     , mdl.MODIFIED_TIME
  FROM 
       DEFINITION_SCHEMA.MODULES          AS mdl
     , DEFINITION_SCHEMA.MODULE_BODY      AS mdlbd
     , DEFINITION_SCHEMA.SCHEMATA         AS sch 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth 
 WHERE 
       mdl.MODULE_SCHEMA_ID = sch.SCHEMA_ID
   AND mdl.MODULE_OWNER_ID  = auth.AUTH_ID
   AND mdl.MODULE_ID  = mdlbd.MODULE_ID
   AND ( mdl.MODULE_ID IN ( SELECT pvmdl.MODULE_ID 
                              FROM DEFINITION_SCHEMA.MODULE_PRIVILEGES AS pvmdl 
                             WHERE ( pvmdl.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                             FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS autab 
                                                            WHERE autab.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                         ) 
                                   -- OR  
                                   -- pvtab.GRANTEE_ID IN ( SELECT AUTH_ID 
                                   --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                   )
                          ) 
         OR 
         mdl.MODULE_SCHEMA_ID IN ( SELECT pvsch.SCHEMA_ID 
                                     FROM DEFINITION_SCHEMA.SCHEMA_PRIVILEGES AS pvsch 
                                    WHERE pvsch.PRIVILEGE_TYPE IN ( 'CONTROL SCHEMA', 'ALTER PACKAGE', 'DROP PACKAGE', 'EXECUTE PACKAGE' ) 
                                      AND ( pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                                    FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS ausch 
                                                                   WHERE ausch.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                                ) 
                                          -- OR  
                                          -- pvsch.GRANTEE_ID IN ( SELECT AUTH_ID 
                                          --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                                          )
                                 ) 
         OR 
         EXISTS ( SELECT GRANTEE_ID  
                    FROM DEFINITION_SCHEMA.DATABASE_PRIVILEGES pvdba 
                   WHERE pvdba.PRIVILEGE_TYPE IN ( 'ALTER ANY PACKAGE', 'DROP ANY PACKAGE', 'EXECUTE ANY PACKAGE' )
                     AND ( pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                                                   FROM DEFINITION_SCHEMA.AUTHORIZATIONS AS audba 
                                                  WHERE audba.AUTHORIZATION_NAME IN ( 'PUBLIC', CURRENT_USER )  
                                                ) 
                        -- OR  
                        -- pvdba.GRANTEE_ID IN ( SELECT AUTH_ID 
                        --                         FROM INORMATION_SCHEMA.ENABLED_ROLES )  
                          )  
                ) 
       ) 
ORDER BY 
      sch.SCHEMA_NAME
    , mdl.MODULE_NAME
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.MODULE_BODY
        IS 'Identify the SQL-server module bodies in this catalog that are accessible to a given user or role.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY.MODULE_CATALOG
        IS 'catalog name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY.MODULE_OWNER
        IS 'owner name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY.MODULE_SCHEMA
        IS 'schema name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY.MODULE_NAME
        IS 'name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY.MODULE_DEFINITION
        IS 'definition of the SQL-server module body';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY.CREATED
        IS 'creation time of the SQL-server module body';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY.LAST_ALTERED
        IS 'most lately altered time of the SQL-server module body';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.MODULE_BODY TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS MODULE_BODY;
CREATE PUBLIC SYNONYM MODULE_BODY FOR INFORMATION_SCHEMA.MODULE_BODY;
COMMIT;

--##############################################################
--# INFORMATION_SCHEMA.MODULE_BODY_TABLE_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.MODULE_BODY_TABLE_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.MODULE_BODY_TABLE_USAGE
(
       MODULE_CATALOG
     , MODULE_OWNER
     , MODULE_SCHEMA
     , MODULE_NAME
     , TABLE_CATALOG
     , TABLE_OWNER
     , TABLE_SCHEMA
     , TABLE_NAME
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- MODULE_CATALOG
     , auth1.AUTHORIZATION_NAME                       -- MODULE_OWNER
     , sch1.SCHEMA_NAME                               -- MODULE_SCHEMA
     , mdl1.MODULE_NAME                               -- MODULE_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- TABLE_CATALOG
     , auth2.AUTHORIZATION_NAME                       -- TABLE_OWNER
     , sch2.SCHEMA_NAME                               -- TABLE_SCHEMA
     , tab2.TABLE_NAME                                -- TABLE_NAME
  FROM 
       DEFINITION_SCHEMA.MODULE_BODY_TABLE_USAGE AS mbtu
     , DEFINITION_SCHEMA.MODULES          AS mdl1
     , DEFINITION_SCHEMA.SCHEMATA         AS sch1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth1
     , DEFINITION_SCHEMA.TABLES           AS tab2
     , DEFINITION_SCHEMA.SCHEMATA         AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth2
 WHERE 
       mbtu.MODULE_ID          = mdl1.MODULE_ID
   AND mbtu.MODULE_SCHEMA_ID   = sch1.SCHEMA_ID 
   AND mbtu.MODULE_OWNER_ID    = auth1.AUTH_ID 
   AND mbtu.TABLE_ID           = tab2.TABLE_ID 
   AND mbtu.TABLE_SCHEMA_ID    = sch2.SCHEMA_ID
   AND mbtu.TABLE_OWNER_ID     = auth2.AUTH_ID 
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR 
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       ) 
ORDER BY 
      mbtu.MODULE_SCHEMA_ID 
    , mbtu.MODULE_ID 
    , mbtu.TABLE_SCHEMA_ID
    , mbtu.TABLE_ID
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.MODULE_BODY_TABLE_USAGE
        IS 'Identify the tables owned by a given user or role on which SQL-server module bodies defined in this catalog are dependent.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_TABLE_USAGE.MODULE_CATALOG
        IS 'catalog name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_TABLE_USAGE.MODULE_OWNER
        IS 'owner name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_TABLE_USAGE.MODULE_SCHEMA
        IS 'schema name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_TABLE_USAGE.MODULE_NAME
        IS 'name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_TABLE_USAGE.TABLE_CATALOG
        IS 'catalog name of the table of contained in definition text of the SQL-server module body';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_TABLE_USAGE.TABLE_OWNER
        IS 'owner name of the table of contained in definition text of the SQL-server module body';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_TABLE_USAGE.TABLE_SCHEMA
        IS 'schema name of the table of contained in definition text of the SQL-server module body';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_TABLE_USAGE.TABLE_NAME
        IS 'table name of contained in definition text of the SQL-server module body';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.MODULE_BODY_TABLE_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS MODULE_BODY_TABLE_USAGE;
CREATE PUBLIC SYNONYM MODULE_BODY_TABLE_USAGE FOR INFORMATION_SCHEMA.MODULE_BODY_TABLE_USAGE;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.MODULE_BODY_MODULE_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.MODULE_BODY_MODULE_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.MODULE_BODY_MODULE_USAGE
(
       MODULE_CATALOG
     , MODULE_OWNER
     , MODULE_SCHEMA
     , MODULE_NAME
     , REF_MODULE_CATALOG
     , REF_MODULE_OWNER
     , REF_MODULE_SCHEMA
     , REF_MODULE_NAME
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- MODULE_CATALOG
     , auth1.AUTHORIZATION_NAME                       -- MODULE_OWNER
     , sch1.SCHEMA_NAME                               -- MODULE_SCHEMA
     , mdl1.MODULE_NAME                               -- MODULE_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- REF_MODULE_CATALOG
     , auth2.AUTHORIZATION_NAME                       -- REF_MODULE_OWNER
     , sch2.SCHEMA_NAME                               -- REF_MODULE_SCHEMA
     , mdl2.MODULE_NAME                               -- REF_MODULE_NAME
  FROM 
       DEFINITION_SCHEMA.MODULE_BODY_MODULE_USAGE AS mbmu
     , DEFINITION_SCHEMA.MODULES          AS mdl1
     , DEFINITION_SCHEMA.SCHEMATA         AS sch1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth1
     , DEFINITION_SCHEMA.MODULES          AS mdl2
     , DEFINITION_SCHEMA.SCHEMATA         AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth2
 WHERE 
       mbmu.MODULE_ID            = mdl1.MODULE_ID
   AND mbmu.MODULE_SCHEMA_ID     = sch1.SCHEMA_ID 
   AND mbmu.MODULE_OWNER_ID      = auth1.AUTH_ID 
   AND mbmu.REF_MODULE_ID        = mdl2.MODULE_ID 
   AND mbmu.REF_MODULE_SCHEMA_ID = sch2.SCHEMA_ID
   AND mbmu.REF_MODULE_OWNER_ID  = auth2.AUTH_ID 
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR 
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       ) 
ORDER BY 
      mbmu.MODULE_SCHEMA_ID 
    , mbmu.MODULE_ID 
    , mbmu.REF_MODULE_SCHEMA_ID
    , mbmu.REF_MODULE_ID
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.MODULE_BODY_MODULE_USAGE
        IS 'Identify the SQL-server modules owned by a given user or role on which SQL-server module bodies defined in this catalog are dependent.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_MODULE_USAGE.MODULE_CATALOG
        IS 'catalog name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_MODULE_USAGE.MODULE_OWNER
        IS 'owner name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_MODULE_USAGE.MODULE_SCHEMA
        IS 'schema name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_MODULE_USAGE.MODULE_NAME
        IS 'name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_MODULE_USAGE.REF_MODULE_CATALOG
        IS 'catalog name of the SQL-server module of contained in definition text of the SQL-server module body';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_MODULE_USAGE.REF_MODULE_OWNER
        IS 'owner name of the SQL-server module of contained in definition text of the SQL-server module body';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_MODULE_USAGE.REF_MODULE_SCHEMA
        IS 'schema name of the SQL-server module of contained in definition text of the SQL-server module body';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_MODULE_USAGE.REF_MODULE_NAME
        IS 'SQL-server module name of contained in definition text of the SQL-server module body';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.MODULE_BODY_MODULE_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS MODULE_BODY_MODULE_USAGE;
CREATE PUBLIC SYNONYM MODULE_BODY_MODULE_USAGE FOR INFORMATION_SCHEMA.MODULE_BODY_MODULE_USAGE;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.MODULE_BODY_ROUTINE_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.MODULE_BODY_ROUTINE_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.MODULE_BODY_ROUTINE_USAGE
(
       MODULE_CATALOG
     , MODULE_OWNER
     , MODULE_SCHEMA
     , MODULE_NAME
     , ROUTINE_CATALOG
     , ROUTINE_OWNER
     , ROUTINE_SCHEMA
     , ROUTINE_NAME
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- MODULE_CATALOG
     , auth1.AUTHORIZATION_NAME                       -- MODULE_OWNER
     , sch1.SCHEMA_NAME                               -- MODULE_SCHEMA
     , mdl1.MODULE_NAME                               -- MODULE_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- ROUTINE_CATALOG
     , auth2.AUTHORIZATION_NAME                       -- ROUTINE_OWNER
     , sch2.SCHEMA_NAME                               -- ROUTINE_SCHEMA
     , rtn2.SPECIFIC_NAME                             -- ROUTINE_NAME
  FROM 
       DEFINITION_SCHEMA.MODULE_BODY_ROUTINE_USAGE AS mbru
     , DEFINITION_SCHEMA.MODULES          AS mdl1
     , DEFINITION_SCHEMA.SCHEMATA         AS sch1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth1
     , DEFINITION_SCHEMA.ROUTINES         AS rtn2
     , DEFINITION_SCHEMA.SCHEMATA         AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth2
 WHERE 
       mbru.MODULE_ID         = mdl1.MODULE_ID
   AND mbru.MODULE_SCHEMA_ID  = sch1.SCHEMA_ID 
   AND mbru.MODULE_OWNER_ID   = auth1.AUTH_ID 
   AND mbru.ROUTINE_ID        = rtn2.SPECIFIC_ID 
   AND mbru.ROUTINE_SCHEMA_ID = sch2.SCHEMA_ID
   AND mbru.ROUTINE_OWNER_ID  = auth2.AUTH_ID 
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR 
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       ) 
ORDER BY 
      mbru.MODULE_SCHEMA_ID 
    , mbru.MODULE_ID 
    , mbru.ROUTINE_SCHEMA_ID
    , mbru.ROUTINE_ID
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.MODULE_BODY_ROUTINE_USAGE
        IS 'Identify the SQL-invoked routines owned by a given user or role on which SQL-server module bodies defined in this catalog are dependent.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_ROUTINE_USAGE.MODULE_CATALOG
        IS 'catalog name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_ROUTINE_USAGE.MODULE_OWNER
        IS 'owner name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_ROUTINE_USAGE.MODULE_SCHEMA
        IS 'schema name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_ROUTINE_USAGE.MODULE_NAME
        IS 'name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_ROUTINE_USAGE.ROUTINE_CATALOG
        IS 'catalog name of the SQL-invoked routine of contained in definition text of the SQL-server module body';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_ROUTINE_USAGE.ROUTINE_OWNER
        IS 'owner name of the SQL-invoked routine of contained in definition text of the SQL-server module body';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_ROUTINE_USAGE.ROUTINE_SCHEMA
        IS 'schema name of the SQL-invoked routine of contained in definition text of the SQL-server module body';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_ROUTINE_USAGE.ROUTINE_NAME
        IS 'SQL-invoked routine name of contained in definition text of the SQL-server module body';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.MODULE_BODY_ROUTINE_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS MODULE_BODY_ROUTINE_USAGE;
CREATE PUBLIC SYNONYM MODULE_BODY_ROUTINE_USAGE FOR INFORMATION_SCHEMA.MODULE_BODY_ROUTINE_USAGE;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.MODULE_SQUENCE_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.MODULE_BODY_SEQUENCE_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.MODULE_BODY_SEQUENCE_USAGE
(
       MODULE_CATALOG
     , MODULE_OWNER
     , MODULE_SCHEMA
     , MODULE_NAME
     , SEQUENCE_CATALOG
     , SEQUENCE_OWNER
     , SEQUENCE_SCHEMA
     , SEQUENCE_NAME
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- MODULE_CATALOG
     , auth1.AUTHORIZATION_NAME                       -- MODULE_OWNER
     , sch1.SCHEMA_NAME                               -- MODULE_SCHEMA
     , mdl1.MODULE_NAME                               -- MODULE_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- SEQUENCE_CATALOG
     , auth2.AUTHORIZATION_NAME                       -- SEQUENCE_OWNER
     , sch2.SCHEMA_NAME                               -- SEQUENCE_SCHEMA
     , seq2.SEQUENCE_NAME                             -- SEQUENCE_NAME
  FROM 
       DEFINITION_SCHEMA.MODULE_BODY_SEQUENCE_USAGE AS mbsu
     , DEFINITION_SCHEMA.MODULES          AS mdl1
     , DEFINITION_SCHEMA.SCHEMATA         AS sch1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth1
     , DEFINITION_SCHEMA.SEQUENCES        AS seq2
     , DEFINITION_SCHEMA.SCHEMATA         AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth2
 WHERE 
       mbsu.MODULE_ID          = mdl1.MODULE_ID
   AND mbsu.MODULE_SCHEMA_ID   = sch1.SCHEMA_ID 
   AND mbsu.MODULE_OWNER_ID    = auth1.AUTH_ID 
   AND mbsu.SEQUENCE_ID        = seq2.SEQUENCE_ID 
   AND mbsu.SEQUENCE_SCHEMA_ID = sch2.SCHEMA_ID
   AND mbsu.SEQUENCE_OWNER_ID  = auth2.AUTH_ID 
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR 
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       ) 
ORDER BY 
      mbsu.MODULE_SCHEMA_ID 
    , mbsu.MODULE_ID 
    , mbsu.SEQUENCE_SCHEMA_ID
    , mbsu.SEQUENCE_ID
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.MODULE_BODY_SEQUENCE_USAGE
        IS 'Identify the sequences owned by a given user or role on which SQL-server module bodies defined in this catalog are dependent.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_SEQUENCE_USAGE.MODULE_CATALOG
        IS 'catalog name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_SEQUENCE_USAGE.MODULE_OWNER
        IS 'owner name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_SEQUENCE_USAGE.MODULE_SCHEMA
        IS 'schema name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_SEQUENCE_USAGE.MODULE_NAME
        IS 'name of the SQL-server module';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_SEQUENCE_USAGE.SEQUENCE_CATALOG
        IS 'catalog name of the sequence of contained in definition text of the SQL-server module body';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_SEQUENCE_USAGE.SEQUENCE_OWNER
        IS 'owner name of the sequence of contained in definition text of the SQL-server module body';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_SEQUENCE_USAGE.SEQUENCE_SCHEMA
        IS 'schema name of the sequence of contained in definition text of the SQL-server module body';
COMMENT ON COLUMN INFORMATION_SCHEMA.MODULE_BODY_SEQUENCE_USAGE.SEQUENCE_NAME
        IS 'sequence name of contained in definition text of the SQL-server module body';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.MODULE_BODY_SEQUENCE_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS MODULE_BODY_SEQUENCE_USAGE;
CREATE PUBLIC SYNONYM MODULE_BODY_SEQUENCE_USAGE FOR INFORMATION_SCHEMA.MODULE_BODY_SEQUENCE_USAGE;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.VIEW_MODULE_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.VIEW_MODULE_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.VIEW_MODULE_USAGE
(
       TABLE_CATALOG
     , TABLE_OWNER
     , TABLE_SCHEMA
     , TABLE_NAME
     , MODULE_CATALOG
     , MODULE_OWNER
     , MODULE_SCHEMA
     , MODULE_NAME
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- TABLE_CATALOG
     , auth1.AUTHORIZATION_NAME                       -- TABLE_OWNER
     , sch1.SCHEMA_NAME                               -- TABLE_SCHEMA
     , tab1.TABLE_NAME                                -- TABLE_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- MODULE_CATALOG
     , auth2.AUTHORIZATION_NAME                       -- MODULE_OWNER
     , sch2.SCHEMA_NAME                               -- MODULE_SCHEMA
     , mdl2.MODULE_NAME                               -- MODULE_NAME
  FROM 
       DEFINITION_SCHEMA.VIEW_MODULE_USAGE AS vmu
     , DEFINITION_SCHEMA.TABLES           AS tab1
     , DEFINITION_SCHEMA.SCHEMATA         AS sch1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth1
     , DEFINITION_SCHEMA.MODULES          AS mdl2
     , DEFINITION_SCHEMA.SCHEMATA         AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth2
 WHERE 
       vmu.TABLE_ID           = tab1.TABLE_ID 
   AND vmu.TABLE_SCHEMA_ID    = sch1.SCHEMA_ID
   AND vmu.TABLE_OWNER_ID     = auth1.AUTH_ID 
   AND vmu.MODULE_ID          = mdl2.MODULE_ID
   AND vmu.MODULE_SCHEMA_ID   = sch2.SCHEMA_ID 
   AND vmu.MODULE_OWNER_ID    = auth2.AUTH_ID 
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR 
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       ) 
ORDER BY 
      vmu.TABLE_SCHEMA_ID
    , vmu.TABLE_ID
    , vmu.MODULE_SCHEMA_ID 
    , vmu.MODULE_ID 
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.VIEW_MODULE_USAGE
        IS 'Identify the SQL-server modules owned by a given user or role on which views defined in this catalog are dependent.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_MODULE_USAGE.TABLE_CATALOG
        IS 'catalog name of the view';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_MODULE_USAGE.TABLE_OWNER
        IS 'owner name of the view';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_MODULE_USAGE.TABLE_SCHEMA
        IS 'schema name of the view';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_MODULE_USAGE.TABLE_NAME
        IS 'name of the view';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_MODULE_USAGE.MODULE_CATALOG
        IS 'catalog name of the SQL-server module of contained in definition text of the view';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_MODULE_USAGE.MODULE_OWNER
        IS 'owner name of the SQL-server module of contained in definition text of the view';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_MODULE_USAGE.MODULE_SCHEMA
        IS 'schema name of the SQL-server module of contained in definition text of the view';
COMMENT ON COLUMN INFORMATION_SCHEMA.VIEW_MODULE_USAGE.MODULE_NAME
        IS 'SQL-server module name of contained in definition text of the view';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.VIEW_MODULE_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS VIEW_MODULE_USAGE;
CREATE PUBLIC SYNONYM VIEW_MODULE_USAGE FOR INFORMATION_SCHEMA.VIEW_MODULE_USAGE;
COMMIT;


--##############################################################
--# INFORMATION_SCHEMA.ROUTINE_MODULE_USAGE
--##############################################################

--#####################
--# drop view
--#####################

DROP VIEW IF EXISTS INFORMATION_SCHEMA.ROUTINE_MODULE_USAGE;

--#####################
--# create view
--#####################

CREATE VIEW INFORMATION_SCHEMA.ROUTINE_MODULE_USAGE
(
       SPECIFIC_CATALOG
     , SPECIFIC_OWNER
     , SPECIFIC_SCHEMA
     , SPECIFIC_NAME
     , MODULE_CATALOG
     , MODULE_OWNER
     , MODULE_SCHEMA
     , MODULE_NAME
)
AS
SELECT 
       CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- SPECIFIC_CATALOG
     , auth1.AUTHORIZATION_NAME                       -- SPECIFIC_OWNER
     , sch1.SCHEMA_NAME                               -- SPECIFIC_SCHEMA
     , rtn1.SPECIFIC_NAME                             -- SPECIFIC_NAME
     , CAST( CURRENT_CATALOG AS VARCHAR(128 OCTETS) ) -- MODULE_CATALOG
     , auth2.AUTHORIZATION_NAME                       -- MODULE_OWNER
     , sch2.SCHEMA_NAME                               -- MODULE_SCHEMA
     , mdl2.MODULE_NAME                               -- MODULE_NAME
  FROM 
       DEFINITION_SCHEMA.ROUTINE_MODULE_USAGE AS rmu
     , DEFINITION_SCHEMA.ROUTINES         AS rtn1
     , DEFINITION_SCHEMA.SCHEMATA         AS sch1 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth1
     , DEFINITION_SCHEMA.MODULES          AS mdl2
     , DEFINITION_SCHEMA.SCHEMATA         AS sch2 
     , DEFINITION_SCHEMA.AUTHORIZATIONS   AS auth2
 WHERE 
       rmu.SPECIFIC_ID        = rtn1.SPECIFIC_ID
   AND rmu.SPECIFIC_SCHEMA_ID = sch1.SCHEMA_ID 
   AND rmu.SPECIFIC_OWNER_ID  = auth1.AUTH_ID 
   AND rmu.MODULE_ID           = mdl2.MODULE_ID 
   AND rmu.MODULE_SCHEMA_ID    = sch2.SCHEMA_ID
   AND rmu.MODULE_OWNER_ID     = auth2.AUTH_ID 
   AND ( 
         auth1.AUTHORIZATION_NAME = CURRENT_USER
         OR 
         auth2.AUTHORIZATION_NAME = CURRENT_USER
       ) 
ORDER BY 
      rmu.SPECIFIC_SCHEMA_ID 
    , rmu.SPECIFIC_ID 
    , rmu.MODULE_SCHEMA_ID
    , rmu.MODULE_ID
;



--#####################
--# comment view
--#####################

COMMENT ON TABLE INFORMATION_SCHEMA.ROUTINE_MODULE_USAGE
        IS 'Identify the SQL-server modules owned by a given user or role on which SQL routines defined in this catalog are dependent.';

--#####################
--# comment column
--#####################

COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_MODULE_USAGE.SPECIFIC_CATALOG
        IS 'specific catalog name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_MODULE_USAGE.SPECIFIC_OWNER
        IS 'specific owner name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_MODULE_USAGE.SPECIFIC_SCHEMA
        IS 'specific schema name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_MODULE_USAGE.SPECIFIC_NAME
        IS 'specific name of the routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_MODULE_USAGE.MODULE_CATALOG
        IS 'catalog name of the SQL-server module of contained in routine body of the SQL-invoked routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_MODULE_USAGE.MODULE_OWNER
        IS 'owner name of the SQL-server module of contained in routine body of the SQL-invoked routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_MODULE_USAGE.MODULE_SCHEMA
        IS 'schema name of the SQL-server module of contained in routine body of the SQL-invoked routine';
COMMENT ON COLUMN INFORMATION_SCHEMA.ROUTINE_MODULE_USAGE.MODULE_NAME
        IS 'SQL-server module name of contained in routine body of the SQL-invoked routine';

--#####################
--# grant view
--#####################

GRANT SELECT ON TABLE INFORMATION_SCHEMA.ROUTINE_MODULE_USAGE TO PUBLIC;

COMMIT;

--#####################
--# public synonym 
--#####################

DROP PUBLIC SYNONYM IF EXISTS ROUTINE_MODULE_USAGE;
CREATE PUBLIC SYNONYM ROUTINE_MODULE_USAGE FOR INFORMATION_SCHEMA.ROUTINE_MODULE_USAGE;
COMMIT;


