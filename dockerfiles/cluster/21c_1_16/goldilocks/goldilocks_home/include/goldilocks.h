#ifndef _GOLDILOCKS_H_
#define _GOLDILOCKS_H_ 1




/* #undef SQL_WCHART_CONVERT */

#ifndef WIN32
#define SIZEOF_LONG_INT 8
#define HAVE_LONG_LONG  1
#endif

#include <xa.h>
#include <sqltypes.h>
#include <sql.h>
#include <sqlext.h>
#include <goldilockstypes.h>
#include <goldilocksxa.h>

#ifdef __cplusplus
extern "C" {
#endif

SQLRETURN SQL_API SQLGetGroupCount( SQLHDBC      ConnectionHandle,
                                    SQLINTEGER * GroupCountPtr );

SQLRETURN SQL_API SQLGetGroupIDs( SQLHDBC      ConnectionHandle,
                                  SQLINTEGER * GroupIDArray );

SQLRETURN SQL_API SQLGetGroupName( SQLHDBC       ConnectionHandle,
                                   SQLINTEGER    GroupID,
                                   SQLCHAR     * GroupName,
                                   SQLSMALLINT   BufferLength,
                                   SQLSMALLINT * NameLengthPtr );

SQLRETURN SQL_API SQLGetSuitableGroupID( SQLHSTMT     StatementHandle,
                                         SQLINTEGER * GroupIDPtr );

SQLRETURN SQL_API GDLAllocConnect( SQLHENV   EnvironmentHandle,
                                   SQLHDBC * ConnectionHandle );

SQLRETURN SQL_API GDLAllocEnv( SQLHENV * EnvironmentHandle );

SQLRETURN SQL_API GDLAllocHandle( SQLSMALLINT   HandleType,
                                  SQLHANDLE     InputHandle,
                                  SQLHANDLE   * OutputHandlePtr );

SQLRETURN SQL_API GDLAllocStmt( SQLHDBC    ConnectionHandle,
                                SQLHSTMT * StatementHandle );

SQLRETURN SQL_API GDLBindCol( SQLHSTMT       StatementHandle,
                              SQLUSMALLINT   ColumnNumber,
                              SQLSMALLINT    TargetType,
                              SQLPOINTER     TargetValuePtr,
                              SQLLEN         BufferLength,
                              SQLLEN       * StrLen_or_Ind );

SQLRETURN SQL_API GDLBindParam( SQLHSTMT       StatementHandle,
                                SQLUSMALLINT   ParameterNumber,
                                SQLSMALLINT    ValueType,
                                SQLSMALLINT    ParameterType,
                                SQLULEN        LengthPrecision,
                                SQLSMALLINT    ParameterScale,
                                SQLPOINTER     ParameterValuePtr,
                                SQLLEN       * StrLen_or_IndPtr );

SQLRETURN SQL_API GDLBindParameter( SQLHSTMT      StatementHandle,
                                    SQLUSMALLINT  ParameterNumber,
                                    SQLSMALLINT   InputOutputType,
                                    SQLSMALLINT   ValueType,
                                    SQLSMALLINT   ParameterType,
                                    SQLULEN       ColumnSize,
                                    SQLSMALLINT   DecimalDigits,
                                    SQLPOINTER    ParameterValuePtr,
                                    SQLLEN        BufferLength,
                                    SQLLEN      * StrLen_or_IndPtr );

SQLRETURN SQL_API GDLBrowseConnect( SQLHDBC       ConnectionHandle,
                                    SQLCHAR     * InConnectionString,
                                    SQLSMALLINT   StringLength1,
                                    SQLCHAR     * OutConnectionString,
                                    SQLSMALLINT   BufferLength,
                                    SQLSMALLINT * StringLength2Ptr);

SQLRETURN SQL_API GDLBrowseConnectW( SQLHDBC       ConnectionHandle,
                                     SQLWCHAR    * InConnectionString,
                                     SQLSMALLINT   StringLength1,
                                     SQLWCHAR    * OutConnectionString,
                                     SQLSMALLINT   BufferLength,
                                     SQLSMALLINT * StringLength2Ptr);

SQLRETURN SQL_API GDLBulkOperations( SQLHSTMT     StatementHandle,
                                     SQLSMALLINT  Operation );

SQLRETURN SQL_API GDLCancel( SQLHSTMT StatementHandle );

SQLRETURN SQL_API GDLCancelHandle( SQLSMALLINT HandleType,
                                   SQLHANDLE   Handle );

SQLRETURN SQL_API GDLCloseCursor( SQLHSTMT StatementHandle );

SQLRETURN SQL_API GDLColAttribute( SQLHSTMT      StatementHandle,
                                   SQLUSMALLINT  ColumnNumber,
                                   SQLUSMALLINT  FieldIdentifier,
                                   SQLPOINTER    CharacterAttributePtr,
                                   SQLSMALLINT   BufferLength,
                                   SQLSMALLINT * StringLengthPtr,
                                   SQLLEN      * NumericAttributePtr );

SQLRETURN SQL_API GDLColAttributeW( SQLHSTMT      StatementHandle,
                                    SQLUSMALLINT  ColumnNumber,
                                    SQLUSMALLINT  FieldIdentifier,
                                    SQLPOINTER    CharacterAttributePtr,
                                    SQLSMALLINT   BufferLength,
                                    SQLSMALLINT * StringLengthPtr,
                                    SQLLEN      * NumericAttributePtr );

SQLRETURN SQL_API GDLColAttributes( SQLHSTMT      StatementHandle,
                                    SQLUSMALLINT  ColumnNumber,
                                    SQLUSMALLINT  FieldIdentifier,
                                    SQLPOINTER    CharacterAttributePtr,
                                    SQLSMALLINT   BufferLength,
                                    SQLSMALLINT * StringLengthPtr,
                                    SQLLEN      * NumericAttributePtr );

SQLRETURN SQL_API GDLColAttributesW( SQLHSTMT      StatementHandle,
                                     SQLUSMALLINT  ColumnNumber,
                                     SQLUSMALLINT  FieldIdentifier,
                                     SQLPOINTER    CharacterAttributePtr,
                                     SQLSMALLINT   BufferLength,
                                     SQLSMALLINT * StringLengthPtr,
                                     SQLLEN      * NumericAttributePtr );

SQLRETURN SQL_API GDLColumnPrivileges( SQLHSTMT      StatementHandle,
                                       SQLCHAR     * CatalogName,
                                       SQLSMALLINT   NameLength1,
                                       SQLCHAR     * SchemaName,
                                       SQLSMALLINT   NameLength2,
                                       SQLCHAR     * TableName,
                                       SQLSMALLINT   NameLength3,
                                       SQLCHAR     * ColumnName,
                                       SQLSMALLINT   NameLength4 );

SQLRETURN SQL_API GDLColumnPrivilegesW( SQLHSTMT      StatementHandle,
                                        SQLWCHAR    * CatalogName,
                                        SQLSMALLINT   NameLength1,
                                        SQLWCHAR    * SchemaName,
                                        SQLSMALLINT   NameLength2,
                                        SQLWCHAR    * TableName,
                                        SQLSMALLINT   NameLength3,
                                        SQLWCHAR    * ColumnName,
                                        SQLSMALLINT   NameLength4 );

SQLRETURN SQL_API GDLColumns( SQLHSTMT      StatementHandle,
                              SQLCHAR     * CatalogName,
                              SQLSMALLINT   NameLength1,
                              SQLCHAR     * SchemaName,
                              SQLSMALLINT   NameLength2,
                              SQLCHAR     * TableName,
                              SQLSMALLINT   NameLength3,
                              SQLCHAR     * ColumnName,
                              SQLSMALLINT   NameLength4 );

SQLRETURN SQL_API GDLColumnsW( SQLHSTMT      StatementHandle,
                               SQLWCHAR    * CatalogName,
                               SQLSMALLINT   NameLength1,
                               SQLWCHAR    * SchemaName,
                               SQLSMALLINT   NameLength2,
                               SQLWCHAR    * TableName,
                               SQLSMALLINT   NameLength3,
                               SQLWCHAR    * ColumnName,
                               SQLSMALLINT   NameLength4 );

SQLRETURN SQL_API GDLConnect( SQLHDBC       ConnectionHandle,
                              SQLCHAR     * ServerName,
                              SQLSMALLINT   NameLength1,
                              SQLCHAR     * UserName,
                              SQLSMALLINT   NameLength2,
                              SQLCHAR     * Authentication,
                              SQLSMALLINT   NameLength3 );

SQLRETURN SQL_API GDLConnectW( SQLHDBC       ConnectionHandle,
                               SQLWCHAR    * ServerName,
                               SQLSMALLINT   NameLength1,
                               SQLWCHAR    * UserName,
                               SQLSMALLINT   NameLength2,
                               SQLWCHAR    * Authentication,
                               SQLSMALLINT   NameLength3 );

SQLRETURN SQL_API GDLCopyDesc( SQLHDESC SourceDescHandle,
                               SQLHDESC TargetDescHandle );

SQLRETURN SQL_API GDLDescribeCol( SQLHSTMT       StatementHandle,
                                  SQLUSMALLINT   ColumnNumber,
                                  SQLCHAR      * ColumnName,
                                  SQLSMALLINT    BufferLength,
                                  SQLSMALLINT  * NameLengthPtr,
                                  SQLSMALLINT  * DataTypePtr,
                                  SQLULEN      * ColumnSizePtr,
                                  SQLSMALLINT  * DecimalDigitsPtr,
                                  SQLSMALLINT  * NullablePtr );

SQLRETURN SQL_API GDLDescribeColW( SQLHSTMT       StatementHandle,
                                   SQLUSMALLINT   ColumnNumber,
                                   SQLWCHAR     * ColumnName,
                                   SQLSMALLINT    BufferLength,
                                   SQLSMALLINT  * NameLengthPtr,
                                   SQLSMALLINT  * DataTypePtr,
                                   SQLULEN      * ColumnSizePtr,
                                   SQLSMALLINT  * DecimalDigitsPtr,
                                   SQLSMALLINT  * NullablePtr );

SQLRETURN SQL_API GDLDescribeParam( SQLHSTMT       StatementHandle,
                                    SQLUSMALLINT   ParameterNumber,
                                    SQLSMALLINT  * DataTypePtr,
                                    SQLULEN      * ParameterSizePtr,
                                    SQLSMALLINT  * DecimalDigitsPtr,
                                    SQLSMALLINT  * NullablePtr );

SQLRETURN SQL_API GDLDisconnect( SQLHDBC ConnectionHandle );

SQLRETURN SQL_API GDLDriverConnect( SQLHDBC        ConnectionHandle,
                                    SQLHWND        WindowHandle,
                                    SQLCHAR      * InConnectionString,
                                    SQLSMALLINT    StringLength1,
                                    SQLCHAR      * OutConnectionString,
                                    SQLSMALLINT    BufferLength,
                                    SQLSMALLINT  * StringLength2Ptr,
                                    SQLUSMALLINT   DriverCompletion );

SQLRETURN SQL_API GDLDriverConnectW( SQLHDBC        ConnectionHandle,
                                     SQLHWND        WindowHandle,
                                     SQLWCHAR     * InConnectionString,
                                     SQLSMALLINT    StringLength1,
                                     SQLWCHAR     * OutConnectionString,
                                     SQLSMALLINT    BufferLength,
                                     SQLSMALLINT  * StringLength2Ptr,
                                     SQLUSMALLINT   DriverCompletion );

SQLRETURN SQL_API GDLEndTran( SQLSMALLINT HandleType,
                              SQLHANDLE   Handle,
                              SQLSMALLINT CompletionType );

SQLRETURN SQL_API GDLError( SQLHENV       EnvironmentHandle,
                            SQLHDBC       ConnectionHandle,
                            SQLHSTMT      StatementHandle,
                            SQLCHAR     * SQLState,
                            SQLINTEGER  * NativeError,
                            SQLCHAR     * MessageText,
                            SQLSMALLINT   BufferLength,
                            SQLSMALLINT * TextLength );

SQLRETURN SQL_API GDLErrorW( SQLHENV       EnvironmentHandle,
                             SQLHDBC       ConnectionHandle,
                             SQLHSTMT      StatementHandle,
                             SQLWCHAR    * SQLState,
                             SQLINTEGER  * NativeError,
                             SQLWCHAR    * MessageText,
                             SQLSMALLINT   BufferLength,
                             SQLSMALLINT * TextLength );

SQLRETURN SQL_API GDLExecDirect( SQLHSTMT     StatementHandle,
                                 SQLCHAR    * StatementText,
                                 SQLINTEGER   TextLength );

SQLRETURN SQL_API GDLExecDirectW( SQLHSTMT     StatementHandle,
                                  SQLWCHAR   * StatementText,
                                  SQLINTEGER   TextLength );

SQLRETURN SQL_API GDLExecute( SQLHSTMT StatementHandle );

SQLRETURN SQL_API GDLExtendedFetch( SQLHSTMT       StatementHandle,
                                    SQLUSMALLINT   FetchOrientation,
                                    SQLLEN         FetchOffset,
                                    SQLULEN      * RowCountPtr,
                                    SQLUSMALLINT * RowStatusArray );

SQLRETURN SQL_API GDLFetch( SQLHSTMT StatementHandle );

SQLRETURN SQL_API GDLFetchScroll( SQLHSTMT    StatementHandle,
                                  SQLSMALLINT FetchOrientation,
                                  SQLLEN      FetchOffset );

SQLRETURN SQL_API GDLForeignKeys( SQLHSTMT      StatementHandle,
                                  SQLCHAR     * PKCatalogName,
                                  SQLSMALLINT   NameLength1,
                                  SQLCHAR     * PKSchemaName,
                                  SQLSMALLINT   NameLength2,
                                  SQLCHAR     * PKTableName,
                                  SQLSMALLINT   NameLength3,
                                  SQLCHAR     * FKCatalogName,
                                  SQLSMALLINT   NameLength4,
                                  SQLCHAR     * FKSchemaName,
                                  SQLSMALLINT   NameLength5,
                                  SQLCHAR     * FKTableName,
                                  SQLSMALLINT   NameLength6 );

SQLRETURN SQL_API GDLForeignKeysW( SQLHSTMT      StatementHandle,
                                   SQLWCHAR    * PKCatalogName,
                                   SQLSMALLINT   NameLength1,
                                   SQLWCHAR    * PKSchemaName,
                                   SQLSMALLINT   NameLength2,
                                   SQLWCHAR    * PKTableName,
                                   SQLSMALLINT   NameLength3,
                                   SQLWCHAR    * FKCatalogName,
                                   SQLSMALLINT   NameLength4,
                                   SQLWCHAR    * FKSchemaName,
                                   SQLSMALLINT   NameLength5,
                                   SQLWCHAR    * FKTableName,
                                   SQLSMALLINT   NameLength6 );

SQLRETURN SQL_API GDLFreeConnect( SQLHDBC ConnectionHandle );

SQLRETURN SQL_API GDLFreeEnv( SQLHENV EnvironmentHandle );

SQLRETURN SQL_API GDLFreeHandle( SQLSMALLINT HandleType,
                                 SQLHANDLE   Handle );

SQLRETURN SQL_API GDLFreeStmt( SQLHSTMT     StatementHandle,
                               SQLUSMALLINT Option );

SQLRETURN SQL_API GDLGetConnectAttr( SQLHDBC      ConnectionHandle,
                                     SQLINTEGER   Attribute,
                                     SQLPOINTER   ValuePtr,
                                     SQLINTEGER   BufferLength,
                                     SQLINTEGER * StringLengthPtr );

SQLRETURN SQL_API GDLGetConnectAttrW( SQLHDBC      ConnectionHandle,
                                      SQLINTEGER   Attribute,
                                      SQLPOINTER   ValuePtr,
                                      SQLINTEGER   BufferLength,
                                      SQLINTEGER * StringLengthPtr );

SQLRETURN SQL_API GDLGetConnectOption( SQLHDBC      ConnectionHandle,
                                       SQLUSMALLINT Option,
                                       SQLPOINTER   Value);

SQLRETURN SQL_API GDLGetConnectOptionW( SQLHDBC      ConnectionHandle,
                                        SQLUSMALLINT Option,
                                        SQLPOINTER   Value);

SQLRETURN SQL_API GDLGetCursorName( SQLHSTMT      StatementHandle,
                                    SQLCHAR     * CursorName,
                                    SQLSMALLINT   BufferLength,
                                    SQLSMALLINT * NameLengthPtr );

SQLRETURN SQL_API GDLGetCursorNameW( SQLHSTMT      StatementHandle,
                                     SQLWCHAR    * CursorName,
                                     SQLSMALLINT   BufferLength,
                                     SQLSMALLINT * NameLengthPtr );

SQLRETURN SQL_API GDLGetData( SQLHSTMT       StatementHandle,
                              SQLUSMALLINT   Col_or_Param_Num,
                              SQLSMALLINT    TargetType,
                              SQLPOINTER     TargetValuePtr,
                              SQLLEN         BufferLength,
                              SQLLEN       * StrLen_or_IndPtr );

SQLRETURN SQL_API GDLGetDescField( SQLHDESC      DescriptorHandle,
                                   SQLSMALLINT   RecNumber,
                                   SQLSMALLINT   FieldIdentifier,
                                   SQLPOINTER    ValuePtr,
                                   SQLINTEGER    BufferLength,
                                   SQLINTEGER  * StringLengthPtr );

SQLRETURN SQL_API GDLGetDescFieldW( SQLHDESC      DescriptorHandle,
                                    SQLSMALLINT   RecNumber,
                                    SQLSMALLINT   FieldIdentifier,
                                    SQLPOINTER    ValuePtr,
                                    SQLINTEGER    BufferLength,
                                    SQLINTEGER  * StringLengthPtr );

SQLRETURN SQL_API GDLGetDescRec( SQLHDESC      DescriptorHandle,
                                 SQLSMALLINT   RecNumber,
                                 SQLCHAR     * Name,
                                 SQLSMALLINT   BufferLength,
                                 SQLSMALLINT * StringLengthPtr,
                                 SQLSMALLINT * TypePtr,
                                 SQLSMALLINT * SubTypePtr,
                                 SQLLEN      * LengthPtr,
                                 SQLSMALLINT * PrecisionPtr,
                                 SQLSMALLINT * ScalePtr,
                                 SQLSMALLINT * NullablePtr );

SQLRETURN SQL_API GDLGetDescRecW( SQLHDESC      DescriptorHandle,
                                  SQLSMALLINT   RecNumber,
                                  SQLWCHAR    * Name,
                                  SQLSMALLINT   BufferLength,
                                  SQLSMALLINT * StringLengthPtr,
                                  SQLSMALLINT * TypePtr,
                                  SQLSMALLINT * SubTypePtr,
                                  SQLLEN      * LengthPtr,
                                  SQLSMALLINT * PrecisionPtr,
                                  SQLSMALLINT * ScalePtr,
                                  SQLSMALLINT * NullablePtr );

SQLRETURN SQL_API GDLGetDiagField( SQLSMALLINT   HandleType,
                                   SQLHANDLE     Handle,
                                   SQLSMALLINT   RecNumber,
                                   SQLSMALLINT   DiagIdentifier,
                                   SQLPOINTER    DiagInfoPtr,
                                   SQLSMALLINT   BufferLength,
                                   SQLSMALLINT * StringLengthPtr );

SQLRETURN SQL_API GDLGetDiagFieldW( SQLSMALLINT   HandleType,
                                    SQLHANDLE     Handle,
                                    SQLSMALLINT   RecNumber,
                                    SQLSMALLINT   DiagIdentifier,
                                    SQLPOINTER    DiagInfoPtr,
                                    SQLSMALLINT   BufferLength,
                                    SQLSMALLINT * StringLengthPtr );

SQLRETURN SQL_API GDLGetDiagRec( SQLSMALLINT   HandleType,
                                 SQLHANDLE     Handle,
                                 SQLSMALLINT   RecNumber,
                                 SQLCHAR     * SQLState,
                                 SQLINTEGER  * NativeErrorPtr,
                                 SQLCHAR     * MessageText,
                                 SQLSMALLINT   BufferLength,
                                 SQLSMALLINT * TextLengthPtr );

SQLRETURN SQL_API GDLGetDiagRecW( SQLSMALLINT   HandleType,
                                  SQLHANDLE     Handle,
                                  SQLSMALLINT   RecNumber,
                                  SQLWCHAR    * SQLState,
                                  SQLINTEGER  * NativeErrorPtr,
                                  SQLWCHAR    * MessageText,
                                  SQLSMALLINT   BufferLength,
                                  SQLSMALLINT * TextLengthPtr );

SQLRETURN SQL_API GDLGetEnvAttr( SQLHENV      EnvironmentHandle,
                                 SQLINTEGER   Attribute,
                                 SQLPOINTER   ValuePtr,
                                 SQLINTEGER   BufferLength,
                                 SQLINTEGER * StringLengthPtr );

SQLRETURN SQL_API GDLGetFunctions( SQLHDBC        ConnectionHandle,
                                   SQLUSMALLINT   FunctionId,
                                   SQLUSMALLINT * SupportedPtr );

SQLRETURN SQL_API GDLGetInfo( SQLHDBC        ConnectionHandle,
                              SQLUSMALLINT   InfoType,
                              SQLPOINTER     InfoValuePtr,
                              SQLSMALLINT    BufferLength,
                              SQLSMALLINT  * StringLengthPtr );

SQLRETURN SQL_API GDLGetInfoW( SQLHDBC        ConnectionHandle,
                               SQLUSMALLINT   InfoType,
                               SQLPOINTER     InfoValuePtr,
                               SQLSMALLINT    BufferLength,
                               SQLSMALLINT  * StringLengthPtr );

SQLRETURN SQL_API GDLGetStmtAttr( SQLHSTMT     StatementHandle,
                                  SQLINTEGER   Attribute,
                                  SQLPOINTER   ValuePtr,
                                  SQLINTEGER   BufferLength,
                                  SQLINTEGER * StringLengthPtr );

SQLRETURN SQL_API GDLGetStmtAttrW( SQLHSTMT     StatementHandle,
                                   SQLINTEGER   Attribute,
                                   SQLPOINTER   ValuePtr,
                                   SQLINTEGER   BufferLength,
                                   SQLINTEGER * StringLengthPtr );

SQLRETURN SQL_API GDLGetStmtOption( SQLHSTMT     StatementHandle,
                                    SQLUSMALLINT Option,
                                    SQLPOINTER   Value );

SQLRETURN SQL_API GDLGetTypeInfo( SQLHSTMT    StatementHandle,
                                  SQLSMALLINT DataType );

SQLRETURN SQL_API GDLGetTypeInfoW( SQLHSTMT    StatementHandle,
                                   SQLSMALLINT DataType );

SQLRETURN SQL_API GDLMoreResults( SQLHSTMT StatementHandle );

SQLRETURN SQL_API GDLNativeSql( SQLHDBC      ConnectionHandle,
                                SQLCHAR    * InStatementText,
                                SQLINTEGER   TextLength1,
                                SQLCHAR    * OutStatementText,
                                SQLINTEGER   BufferLength,
                                SQLINTEGER * TextLength2Ptr );

SQLRETURN SQL_API GDLNativeSqlW( SQLHDBC      ConnectionHandle,
                                 SQLWCHAR   * InStatementText,
                                 SQLINTEGER   TextLength1,
                                 SQLWCHAR   * OutStatementText,
                                 SQLINTEGER   BufferLength,
                                 SQLINTEGER * TextLength2Ptr );

SQLRETURN SQL_API GDLNumParams( SQLHSTMT      StatementHandle,
                                SQLSMALLINT * ParameterCountPtr );

SQLRETURN SQL_API GDLNumResultCols( SQLHSTMT      StatementHandle,
                                    SQLSMALLINT * ColumnCountPtr );

SQLRETURN SQL_API GDLParamData( SQLHSTMT     StatementHandle,
                                SQLPOINTER * ValuePtrPtr );

SQLRETURN SQL_API GDLParamOptions( SQLHSTMT   hstmt,
                                   SQLULEN    crow,
                                   SQLULEN  * pirow );

SQLRETURN SQL_API GDLPrepare( SQLHSTMT     StatementHandle,
                              SQLCHAR    * StatementText,
                              SQLINTEGER   TextLength );

SQLRETURN SQL_API GDLPrepareW( SQLHSTMT     StatementHandle,
                               SQLWCHAR   * StatementText,
                               SQLINTEGER   TextLength );

SQLRETURN SQL_API GDLPrimaryKeys( SQLHSTMT      StatementHandle,
                                  SQLCHAR     * CatalogName,
                                  SQLSMALLINT   NameLength1,
                                  SQLCHAR     * SchemaName,
                                  SQLSMALLINT   NameLength2,
                                  SQLCHAR     * TableName,
                                  SQLSMALLINT   NameLength3 );

SQLRETURN SQL_API GDLPrimaryKeysW( SQLHSTMT      StatementHandle,
                                   SQLWCHAR    * CatalogName,
                                   SQLSMALLINT   NameLength1,
                                   SQLWCHAR    * SchemaName,
                                   SQLSMALLINT   NameLength2,
                                   SQLWCHAR    * TableName,
                                   SQLSMALLINT   NameLength3 );

SQLRETURN SQL_API GDLProcedureColumns( SQLHSTMT      StatementHandle,
                                       SQLCHAR     * CatalogName,
                                       SQLSMALLINT   NameLength1,
                                       SQLCHAR     * SchemaName,
                                       SQLSMALLINT   NameLength2,
                                       SQLCHAR     * ProcName,
                                       SQLSMALLINT   NameLength3,
                                       SQLCHAR     * ColumnName,
                                       SQLSMALLINT   NameLength4 );

SQLRETURN SQL_API GDLProcedureColumnsW( SQLHSTMT      StatementHandle,
                                        SQLWCHAR    * CatalogName,
                                        SQLSMALLINT   NameLength1,
                                        SQLWCHAR    * SchemaName,
                                        SQLSMALLINT   NameLength2,
                                        SQLWCHAR    * ProcName,
                                        SQLSMALLINT   NameLength3,
                                        SQLWCHAR    * ColumnName,
                                        SQLSMALLINT   NameLength4 );

SQLRETURN SQL_API GDLProcedures( SQLHSTMT      StatementHandle,
                                 SQLCHAR     * CatalogName,
                                 SQLSMALLINT   NameLength1,
                                 SQLCHAR     * SchemaName,
                                 SQLSMALLINT   NameLength2,
                                 SQLCHAR     * ProcName,
                                 SQLSMALLINT   NameLength3 );

SQLRETURN SQL_API GDLProceduresW( SQLHSTMT      StatementHandle,
                                  SQLWCHAR    * CatalogName,
                                  SQLSMALLINT   NameLength1,
                                  SQLWCHAR    * SchemaName,
                                  SQLSMALLINT   NameLength2,
                                  SQLWCHAR    * ProcName,
                                  SQLSMALLINT   NameLength3 );

SQLRETURN SQL_API GDLPutData( SQLHSTMT   StatementHandle,
                              SQLPOINTER DataPtr,
                              SQLLEN     StrLen_or_Ind );

SQLRETURN SQL_API GDLRowCount( SQLHSTMT   StatementHandle,
                               SQLLEN   * RowCountPtr );

SQLRETURN SQL_API GDLSetConnectAttr( SQLHDBC    ConnectionHandle,
                                     SQLINTEGER Attribute,
                                     SQLPOINTER ValuePtr,
                                     SQLINTEGER StringLength );

SQLRETURN SQL_API GDLSetConnectAttrW( SQLHDBC    ConnectionHandle,
                                      SQLINTEGER Attribute,
                                      SQLPOINTER ValuePtr,
                                      SQLINTEGER StringLength );

SQLRETURN SQL_API GDLSetConnectOption( SQLHDBC      ConnectionHandle,
                                       SQLUSMALLINT Option,
                                       SQLULEN      Value );

SQLRETURN SQL_API GDLSetConnectOptionW( SQLHDBC      ConnectionHandle,
                                        SQLUSMALLINT Option,
                                        SQLULEN      Value );

SQLRETURN SQL_API GDLSetCursorName( SQLHSTMT      StatementHandle,
                                    SQLCHAR     * CursorName,
                                    SQLSMALLINT   NameLength );

SQLRETURN SQL_API GDLSetCursorNameW( SQLHSTMT      StatementHandle,
                                     SQLWCHAR    * CursorName,
                                     SQLSMALLINT   NameLength );

SQLRETURN SQL_API GDLSetDescField( SQLHDESC    DescriptorHandle,
                                   SQLSMALLINT RecNumber,
                                   SQLSMALLINT FieldIdentifier,
                                   SQLPOINTER  ValuePtr,
                                   SQLINTEGER  BufferLength );

SQLRETURN SQL_API GDLSetDescFieldW( SQLHDESC    DescriptorHandle,
                                    SQLSMALLINT RecNumber,
                                    SQLSMALLINT FieldIdentifier,
                                    SQLPOINTER  ValuePtr,
                                    SQLINTEGER  BufferLength );

SQLRETURN SQL_API GDLSetDescRec( SQLHDESC      DescriptorHandle,
                                 SQLSMALLINT   RecNumber,
                                 SQLSMALLINT   Type,
                                 SQLSMALLINT   SubType,
                                 SQLLEN        Length,
                                 SQLSMALLINT   Precision,
                                 SQLSMALLINT   Scale,
                                 SQLPOINTER    DataPtr,
                                 SQLLEN      * StringLengthPtr,
                                 SQLLEN      * IndicatorPtr );

SQLRETURN SQL_API GDLSetEnvAttr( SQLHENV    EnvironmentHandle,
                                 SQLINTEGER Attribute,
                                 SQLPOINTER ValuePtr,
                                 SQLINTEGER StringLength );

SQLRETURN SQL_API GDLSetParam( SQLHSTMT      StatementHandle,
                               SQLUSMALLINT  ParameterNumber,
                               SQLSMALLINT   ValueType,
                               SQLSMALLINT   ParameterType,
                               SQLULEN       LengthPrecision,
                               SQLSMALLINT   ParameterScale,
                               SQLPOINTER    ParameterValuePtr,
                               SQLLEN      * StrLen_or_IndPtr );

SQLRETURN SQL_API GDLSetPos( SQLHSTMT      StatementHandle,
                             SQLSETPOSIROW RowNumber,
                             SQLUSMALLINT  Operation,
                             SQLUSMALLINT  LockType );

SQLRETURN SQL_API GDLSetScrollOptions( SQLHSTMT     hstmt,
                                       SQLUSMALLINT fConcurrency,
                                       SQLLEN       crowKeyset,
                                       SQLUSMALLINT crowRowset );

SQLRETURN SQL_API GDLSetStmtAttr( SQLHSTMT   StatementHandle,
                                  SQLINTEGER Attribute,
                                  SQLPOINTER ValuePtr,
                                  SQLINTEGER StringLength );

SQLRETURN SQL_API GDLSetStmtAttrW( SQLHSTMT   StatementHandle,
                                   SQLINTEGER Attribute,
                                   SQLPOINTER ValuePtr,
                                   SQLINTEGER StringLength );

SQLRETURN SQL_API GDLSetStmtOption( SQLHSTMT     StatementHandle,
                                    SQLUSMALLINT Option,
                                    SQLULEN      Value );

SQLRETURN SQL_API GDLSpecialColumns( SQLHSTMT       StatementHandle,
                                     SQLUSMALLINT   IdentifierType,
                                     SQLCHAR      * CatalogName,
                                     SQLSMALLINT    NameLength1,
                                     SQLCHAR      * SchemaName,
                                     SQLSMALLINT    NameLength2,
                                     SQLCHAR      * TableName,
                                     SQLSMALLINT    NameLength3,
                                     SQLUSMALLINT   Scope,
                                     SQLUSMALLINT   Nullable );

SQLRETURN SQL_API GDLSpecialColumnsW( SQLHSTMT       StatementHandle,
                                      SQLUSMALLINT   IdentifierType,
                                      SQLWCHAR     * CatalogName,
                                      SQLSMALLINT    NameLength1,
                                      SQLWCHAR     * SchemaName,
                                      SQLSMALLINT    NameLength2,
                                      SQLWCHAR     * TableName,
                                      SQLSMALLINT    NameLength3,
                                      SQLUSMALLINT   Scope,
                                      SQLUSMALLINT   Nullable );

SQLRETURN SQL_API GDLStatistics( SQLHSTMT       StatementHandle,
                                 SQLCHAR      * CatalogName,
                                 SQLSMALLINT    NameLength1,
                                 SQLCHAR      * SchemaName,
                                 SQLSMALLINT    NameLength2,
                                 SQLCHAR      * TableName,
                                 SQLSMALLINT    NameLength3,
                                 SQLUSMALLINT   Unique,
                                 SQLUSMALLINT   Reserved );

SQLRETURN SQL_API GDLStatisticsW( SQLHSTMT       StatementHandle,
                                  SQLWCHAR     * CatalogName,
                                  SQLSMALLINT    NameLength1,
                                  SQLWCHAR     * SchemaName,
                                  SQLSMALLINT    NameLength2,
                                  SQLWCHAR     * TableName,
                                  SQLSMALLINT    NameLength3,
                                  SQLUSMALLINT   Unique,
                                  SQLUSMALLINT   Reserved );

SQLRETURN SQL_API GDLTablePrivileges( SQLHSTMT      StatementHandle,
                                      SQLCHAR     * CatalogName,
                                      SQLSMALLINT   NameLength1,
                                      SQLCHAR     * SchemaName,
                                      SQLSMALLINT   NameLength2,
                                      SQLCHAR     * TableName,
                                      SQLSMALLINT   NameLength3 );

SQLRETURN SQL_API GDLTablePrivilegesW( SQLHSTMT      StatementHandle,
                                       SQLWCHAR    * CatalogName,
                                       SQLSMALLINT   NameLength1,
                                       SQLWCHAR    * SchemaName,
                                       SQLSMALLINT   NameLength2,
                                       SQLWCHAR    * TableName,
                                       SQLSMALLINT   NameLength3 );

SQLRETURN SQL_API GDLTables( SQLHSTMT      StatementHandle,
                             SQLCHAR     * CatalogName,
                             SQLSMALLINT   NameLength1,
                             SQLCHAR     * SchemaName,
                             SQLSMALLINT   NameLength2,
                             SQLCHAR     * TableName,
                             SQLSMALLINT   NameLength3,
                             SQLCHAR     * TableType,
                             SQLSMALLINT   NameLength4 );

SQLRETURN SQL_API GDLTablesW( SQLHSTMT      StatementHandle,
                              SQLWCHAR    * CatalogName,
                              SQLSMALLINT   NameLength1,
                              SQLWCHAR    * SchemaName,
                              SQLSMALLINT   NameLength2,
                              SQLWCHAR    * TableName,
                              SQLSMALLINT   NameLength3,
                              SQLWCHAR    * TableType,
                              SQLSMALLINT   NameLength4 );

SQLRETURN SQL_API GDLTransact( SQLHENV      EnvironmentHandle,
                               SQLHDBC      ConnectionHandle,
                               SQLUSMALLINT CompletionType );

SQLRETURN SQL_API GDLGetGroupCount( SQLHDBC      ConnectionHandle,
                                    SQLINTEGER * GroupCountPtr );

SQLRETURN SQL_API GDLGetGroupIDs( SQLHDBC      ConnectionHandle,
                                  SQLINTEGER * GroupIDArray );

SQLRETURN SQL_API GDLGetGroupName( SQLHDBC       ConnectionHandle,
                                   SQLINTEGER    GroupID,
                                   SQLCHAR     * GroupName,
                                   SQLSMALLINT   BufferLength,
                                   SQLSMALLINT * NameLengthPtr );

SQLRETURN SQL_API GDLGetSuitableGroupID( SQLHSTMT     StatementHandle,
                                         SQLINTEGER * GroupIDPtr );

#ifdef __cplusplus
}
#endif

#endif
