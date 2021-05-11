/*******************************************************************************
 * connection.c
 *
 * Copyright (c) 2011, SUNJESOFT Inc.
 *
 *
 * IDENTIFICATION & REVISION
 *        
 *
 * NOTES
 *
 *
 ******************************************************************************/

/**
 * @file connection.c
 * @brief Python Connection for Goldilocks Python Database API
 */

#include <pydbc.h>
#include <buffer.h>
#include <connection.h>
#include <cursor.h>
#include <error.h>
#include <encoding.h>
#include <type.h>

static const GetInfo gInfoTypes[] = {
    { SQL_ACCESSIBLE_PROCEDURES, GI_YESNO },
    { SQL_ACCESSIBLE_TABLES, GI_YESNO },

    { SQL_ACTIVE_ENVIRONMENTS, GI_USMALLINT },
    { SQL_AGGREGATE_FUNCTIONS, GI_UINTEGER },
    
    { SQL_ALTER_DOMAIN, GI_UINTEGER },
    { SQL_ALTER_TABLE, GI_UINTEGER },

    { SQL_ASYNC_MODE, GI_UINTEGER },
    { SQL_BATCH_ROW_COUNT, GI_UINTEGER },
    { SQL_BATCH_SUPPORT, GI_UINTEGER },
    { SQL_BOOKMARK_PERSISTENCE, GI_UINTEGER },

    { SQL_CATALOG_LOCATION, GI_USMALLINT },
    { SQL_CATALOG_NAME, GI_YESNO },
    { SQL_CATALOG_NAME_SEPARATOR, GI_STRING },
    { SQL_CATALOG_TERM, GI_STRING },
    { SQL_CATALOG_USAGE, GI_UINTEGER },
    
    { SQL_COLLATION_SEQ, GI_STRING },
    { SQL_COLUMN_ALIAS, GI_YESNO },
    { SQL_CONCAT_NULL_BEHAVIOR, GI_USMALLINT },

    { SQL_CONVERT_BIGINT, GI_UINTEGER },
    { SQL_CONVERT_BINARY, GI_UINTEGER },
    { SQL_CONVERT_BIT, GI_UINTEGER },
    { SQL_CONVERT_CHAR, GI_UINTEGER },
    { SQL_CONVERT_GUID, GI_UINTEGER },
    { SQL_CONVERT_DATE, GI_UINTEGER },
    { SQL_CONVERT_DECIMAL, GI_UINTEGER },
    { SQL_CONVERT_DOUBLE, GI_UINTEGER },
    { SQL_CONVERT_FLOAT, GI_UINTEGER },
    { SQL_CONVERT_INTEGER, GI_UINTEGER },
    { SQL_CONVERT_INTERVAL_YEAR_MONTH, GI_UINTEGER },
    { SQL_CONVERT_INTERVAL_DAY_TIME, GI_UINTEGER },
    { SQL_CONVERT_LONGVARBINARY, GI_UINTEGER },
    { SQL_CONVERT_LONGVARCHAR, GI_UINTEGER },
    { SQL_CONVERT_NUMERIC, GI_UINTEGER },
    { SQL_CONVERT_REAL, GI_UINTEGER },
    { SQL_CONVERT_SMALLINT, GI_UINTEGER },
    { SQL_CONVERT_TIME, GI_UINTEGER },
    { SQL_CONVERT_TIMESTAMP, GI_UINTEGER },
    { SQL_CONVERT_TINYINT, GI_UINTEGER },
    { SQL_CONVERT_VARBINARY, GI_UINTEGER },
    { SQL_CONVERT_VARCHAR, GI_UINTEGER },
    { SQL_CONVERT_FUNCTIONS, GI_UINTEGER },
    
    { SQL_CORRELATION_NAME, GI_USMALLINT },
    { SQL_CREATE_ASSERTION, GI_UINTEGER },
    { SQL_CREATE_CHARACTER_SET, GI_UINTEGER },
    { SQL_CREATE_COLLATION, GI_UINTEGER },
    { SQL_CREATE_DOMAIN, GI_UINTEGER },
    { SQL_CREATE_SCHEMA, GI_UINTEGER },
    { SQL_CREATE_TABLE, GI_UINTEGER },
    { SQL_CREATE_TRANSLATION, GI_UINTEGER },
    { SQL_CREATE_VIEW, GI_UINTEGER },
    
    { SQL_CURSOR_COMMIT_BEHAVIOR, GI_USMALLINT },
    { SQL_CURSOR_ROLLBACK_BEHAVIOR, GI_USMALLINT },
    { SQL_CURSOR_SENSITIVITY, GI_UINTEGER },
    
    { SQL_DATABASE_NAME, GI_STRING },
    { SQL_DATA_SOURCE_NAME, GI_STRING },
    { SQL_DATA_SOURCE_READ_ONLY, GI_YESNO },
    { SQL_DATETIME_LITERALS, GI_UINTEGER },
    { SQL_DBMS_NAME, GI_STRING },
    { SQL_DBMS_VER, GI_STRING },
    { SQL_DDL_INDEX, GI_UINTEGER },
    { SQL_DEFAULT_TXN_ISOLATION, GI_UINTEGER },
    { SQL_DESCRIBE_PARAMETER, GI_YESNO },
    { SQL_DM_VER, GI_STRING },

    { SQL_DRIVER_HDBC, GI_UINTEGER },
    { SQL_DRIVER_HENV, GI_UINTEGER },
    { SQL_DRIVER_HDESC, GI_UINTEGER },
    { SQL_DRIVER_HLIB, GI_UINTEGER },
    { SQL_DRIVER_HSTMT, GI_UINTEGER },
    { SQL_DRIVER_NAME, GI_STRING },
    { SQL_DRIVER_ODBC_VER, GI_STRING },
    { SQL_DRIVER_VER, GI_STRING },
    
    { SQL_DROP_ASSERTION, GI_UINTEGER },
    { SQL_DROP_CHARACTER_SET, GI_UINTEGER },
    { SQL_DROP_COLLATION, GI_UINTEGER },
    { SQL_DROP_DOMAIN, GI_UINTEGER },
    { SQL_DROP_SCHEMA, GI_UINTEGER },
    { SQL_DROP_TABLE, GI_UINTEGER },
    { SQL_DROP_TRANSLATION, GI_UINTEGER },
    { SQL_DROP_VIEW, GI_UINTEGER },
    
    { SQL_DYNAMIC_CURSOR_ATTRIBUTES1, GI_UINTEGER },
    { SQL_DYNAMIC_CURSOR_ATTRIBUTES2, GI_UINTEGER },
    { SQL_EXPRESSIONS_IN_ORDERBY, GI_YESNO },
    { SQL_FILE_USAGE, GI_USMALLINT }, 
    { SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES1, GI_UINTEGER },
    { SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES2, GI_UINTEGER },
    { SQL_GETDATA_EXTENSIONS, GI_UINTEGER },
    { SQL_GROUP_BY, GI_USMALLINT },
    { SQL_IDENTIFIER_CASE, GI_USMALLINT },
    { SQL_IDENTIFIER_QUOTE_CHAR, GI_STRING },
    { SQL_INDEX_KEYWORDS, GI_UINTEGER },
    { SQL_INFO_SCHEMA_VIEWS, GI_UINTEGER },
    { SQL_INSERT_STATEMENT, GI_UINTEGER },
    { SQL_INTEGRITY, GI_YESNO },
    { SQL_KEYSET_CURSOR_ATTRIBUTES1, GI_UINTEGER },
    { SQL_KEYSET_CURSOR_ATTRIBUTES2, GI_UINTEGER },
    { SQL_KEYWORDS, GI_STRING },
    { SQL_LIKE_ESCAPE_CLAUSE, GI_YESNO },

    { SQL_MAX_ASYNC_CONCURRENT_STATEMENTS, GI_UINTEGER },
    { SQL_MAX_BINARY_LITERAL_LEN, GI_UINTEGER },
    { SQL_MAX_CATALOG_NAME_LEN, GI_USMALLINT },
    { SQL_MAX_CHAR_LITERAL_LEN, GI_UINTEGER },
    { SQL_MAX_COLUMNS_IN_GROUP_BY, GI_USMALLINT },
    { SQL_MAX_COLUMNS_IN_INDEX, GI_USMALLINT },
    { SQL_MAX_COLUMNS_IN_ORDER_BY, GI_USMALLINT },
    { SQL_MAX_COLUMNS_IN_SELECT, GI_USMALLINT },
    { SQL_MAX_COLUMNS_IN_TABLE, GI_USMALLINT },
    { SQL_MAX_COLUMN_NAME_LEN, GI_USMALLINT },
    { SQL_MAX_CONCURRENT_ACTIVITIES, GI_USMALLINT },
    { SQL_MAX_CURSOR_NAME_LEN, GI_USMALLINT },
    { SQL_MAX_DRIVER_CONNECTIONS, GI_USMALLINT },
    { SQL_MAX_IDENTIFIER_LEN, GI_USMALLINT },
    { SQL_MAX_INDEX_SIZE, GI_UINTEGER },
    { SQL_MAX_PROCEDURE_NAME_LEN, GI_USMALLINT },
    { SQL_MAX_ROW_SIZE, GI_UINTEGER },
    { SQL_MAX_ROW_SIZE_INCLUDES_LONG, GI_YESNO },
    { SQL_MAX_SCHEMA_NAME_LEN, GI_USMALLINT },
    { SQL_MAX_STATEMENT_LEN, GI_UINTEGER },
    { SQL_MAX_TABLES_IN_SELECT, GI_USMALLINT },
    { SQL_MAX_TABLE_NAME_LEN, GI_USMALLINT },
    { SQL_MAX_USER_NAME_LEN, GI_USMALLINT },

    { SQL_MULTIPLE_ACTIVE_TXN, GI_YESNO },
    { SQL_MULT_RESULT_SETS, GI_YESNO },
    { SQL_NEED_LONG_DATA_LEN, GI_YESNO },
    { SQL_NON_NULLABLE_COLUMNS, GI_USMALLINT },
    { SQL_NULL_COLLATION, GI_USMALLINT },
    { SQL_NUMERIC_FUNCTIONS, GI_UINTEGER },

    { SQL_ODBC_INTERFACE_CONFORMANCE, GI_UINTEGER },
    { SQL_ODBC_VER, GI_STRING },

    { SQL_OJ_CAPABILITIES, GI_UINTEGER },
    { SQL_OUTER_JOINS, GI_YESNO },
    { SQL_ORDER_BY_COLUMNS_IN_SELECT, GI_YESNO },
    
    { SQL_PARAM_ARRAY_ROW_COUNTS, GI_UINTEGER },
    { SQL_PARAM_ARRAY_SELECTS, GI_UINTEGER },
    { SQL_PROCEDURES, GI_YESNO },
    { SQL_PROCEDURE_TERM, GI_STRING },
    { SQL_QUOTED_IDENTIFIER_CASE, GI_USMALLINT },
    { SQL_ROW_UPDATES, GI_YESNO },
    { SQL_SCHEMA_TERM, GI_STRING },
    { SQL_SCHEMA_USAGE, GI_UINTEGER },
    { SQL_SCROLL_OPTIONS, GI_UINTEGER },
    { SQL_SEARCH_PATTERN_ESCAPE, GI_STRING },
    { SQL_SERVER_NAME, GI_STRING },
    { SQL_SPECIAL_CHARACTERS, GI_STRING },
    { SQL_SQL_CONFORMANCE, GI_UINTEGER },
    
    { SQL_SQL92_DATETIME_FUNCTIONS, GI_UINTEGER },
    { SQL_SQL92_FOREIGN_KEY_DELETE_RULE, GI_UINTEGER },
    { SQL_SQL92_FOREIGN_KEY_UPDATE_RULE, GI_UINTEGER },
    { SQL_SQL92_GRANT, GI_UINTEGER },
    { SQL_SQL92_NUMERIC_VALUE_FUNCTIONS, GI_UINTEGER },
    { SQL_SQL92_PREDICATES, GI_UINTEGER },
    { SQL_SQL92_RELATIONAL_JOIN_OPERATORS, GI_UINTEGER },
    { SQL_SQL92_REVOKE, GI_UINTEGER },
    { SQL_SQL92_ROW_VALUE_CONSTRUCTOR, GI_UINTEGER },
    { SQL_SQL92_STRING_FUNCTIONS, GI_UINTEGER },
    { SQL_SQL92_VALUE_EXPRESSIONS, GI_UINTEGER },

    { SQL_STANDARD_CLI_CONFORMANCE, GI_UINTEGER },
    { SQL_STATIC_CURSOR_ATTRIBUTES1, GI_UINTEGER },
    { SQL_STATIC_CURSOR_ATTRIBUTES2, GI_UINTEGER },
    { SQL_STRING_FUNCTIONS, GI_UINTEGER },
    { SQL_SUBQUERIES, GI_UINTEGER },
    { SQL_SYSTEM_FUNCTIONS, GI_UINTEGER },
    { SQL_TABLE_TERM, GI_STRING },
    { SQL_TIMEDATE_ADD_INTERVALS, GI_UINTEGER },
    { SQL_TIMEDATE_DIFF_INTERVALS, GI_UINTEGER },
    { SQL_TIMEDATE_FUNCTIONS, GI_UINTEGER },
    { SQL_TXN_CAPABLE, GI_USMALLINT },
    { SQL_TXN_ISOLATION_OPTION, GI_UINTEGER },
    { SQL_UNION, GI_UINTEGER },
    { SQL_USER_NAME, GI_STRING },
    { SQL_XOPEN_CLI_YEAR, GI_STRING },    
};

Connection * GetConnection( Cursor * aCursor )
{
    return (Connection*)aCursor->mConnection;
}

static STATUS AllocateDbc( SQLHDBC * aHDbc )
{
    SQLRETURN sRet;
    SQLHDBC   sHDbc;

    *aHDbc = NULL;
    
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLAllocHandle( SQL_HANDLE_DBC, gHENV, &sHDbc );
    Py_END_ALLOW_THREADS;

    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
#ifndef WIN32
    __sync_fetch_and_add( &gDbcCnt, 1 );
#else
    InterlockedExchangeAdd( (long*)&gDbcCnt, 1 );
#endif
    
    *aHDbc = sHDbc;
    
    return SUCCESS;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( NULL,
                              "SQLAllocHandle(SQL_HANDLE_DBC)",
                              NULL,
                              NULL );
    }
    
    FINISH;

    return FAILURE;
}

static void FreeDbc( SQLHDBC * aHDbc )
{
    Py_BEGIN_ALLOW_THREADS;
#ifndef WIN32
    __sync_fetch_and_sub( &gDbcCnt, 1 );
#else
    InterlockedExchangeAdd( (long*)&gDbcCnt, -1 );
#endif
    
    GDLFreeHandle( SQL_HANDLE_DBC, *aHDbc );    
    Py_END_ALLOW_THREADS;

    *aHDbc = SQL_NULL_HANDLE;
}

static Connection * ValidateConnection( PyObject * aSelf )
{
    Connection * sCnxn;

    TRY_THROW( (aSelf != NULL) && (CONNECTION_CHECK( aSelf ) == TRUE),
               RAMP_ERR_INVALID_CONNECTION );

    sCnxn = (Connection*) aSelf;

    TRY_THROW( sCnxn->mHDbc != SQL_NULL_HANDLE, RAMP_ERR_INVALID_HANDLE );

    return sCnxn;

    CATCH( RAMP_ERR_INVALID_CONNECTION )
    {
        PyErr_SetString( PyExc_TypeError,
                         "A connection is required." );
    }
    
    CATCH( RAMP_ERR_INVALID_HANDLE )
    {
        PyErr_SetString( ProgrammingError,
                         "Attempt to use a close connection." );
    }
    
    FINISH;

    return NULL;
}

static STATUS ConnectInternal( PyObject * aCnxnStr,
                               SQLHDBC    aHdbc,
                               long       aTimeout )
{
    SQLRETURN    sRet;
    SQLINTEGER   sStringSize;
    PyObject   * sPyBytes;
    char       * sStr;
    char       * sErrFunc;
    
    /**
     * This should have been checked by the global connect function.
     */
    DASSERT( PyString_Check(aCnxnStr) || PyUnicode_Check(aCnxnStr) );

    /**
     * The driver manager determines if the app is a Unicode app based on whether we call SQLDriverConnectA or SQLDriverConnectW.
     * Some drivers, notably Microsoft Access/Jet, change their behavior based on this, so we try the Unicode version first.
     * (The Access driver only supports Unicode text, but SQLDescribeCol returns SQL_CHAR instead of SQL_WCHAR if we connect with the ANSI version.
     * Obviously this causes lots of errors since we believe what it tells us (SQL_CHAR).)
     * Python supports only UCS-2 and UCS-4, so we shouldn't need to worry about receiving surrogate pairs.
     * However, Windows does use UCS-16, so it is possible something would be misinterpreted as one.
     * We may need to examine this more.
     */
    if( aTimeout > 0 )
    {
        Py_BEGIN_ALLOW_THREADS;
        sRet = GDLSetConnectAttr( aHdbc,
                                  SQL_ATTR_LOGIN_TIMEOUT,
                                  (SQLPOINTER)(SQLLEN)aTimeout,
                                  SQL_IS_UINTEGER );
        Py_END_ALLOW_THREADS;

        sErrFunc = "SQLSetConnectAttr(SQL_ATTR_LOGIN_TIMEOUT)";
        TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    }

    sPyBytes = PyCodec_Encode( aCnxnStr, "utf-8", "strict" );

    sStr = PyBytes_AS_STRING( sPyBytes );

    sStringSize = (SQLINTEGER)PyBytes_GET_SIZE( sPyBytes );

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLDriverConnect( aHdbc,
                             0,
                             (SQLCHAR*)sStr,
                             sStringSize,
                             NULL,
                             0,
                             NULL,
                             SQL_DRIVER_NOPROMPT );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLDriverConnect";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    return SUCCESS;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( NULL,
                              sErrFunc,
                              aHdbc,
                              SQL_NULL_HANDLE );
    }
    
    FINISH;

    return FAILURE;
}


static char gConnectionDoc[] =
    "Connection objects manage connections to the database.\n"
    "\n"
    "Each manages a single ODBC HDBC.";

STATUS Connect( PyObject  * aConnectString,
                bool        aAutoCommit,
                long        aTimeout,
                bool        aReadOnly,
                PyObject  * aAttrsBefore,
                PyObject ** aOutCnxn )
{
    /** 
     * aConnectString
     *   A string or unicode object. (This must be checked by the caller.)
     */
    SQLHDBC      sHdbc = SQL_NULL_HANDLE;
    SQLHSTMT     sStmt = SQL_NULL_HANDLE;
    SQLRETURN    sRet;
    Connection * sCnxn = NULL;
    int          sState = 0;
    Py_ssize_t   sPos = 0;
    PyObject   * sPyKey = NULL;
    PyObject   * sPyValue = NULL;
    int          sKey = 0;
    int          sEncodingType = ENC_NONE;
    char       * sErrFunc;
    SQLPOINTER   sValue = NULL;
    SQLINTEGER   sStringLength = SQL_NTS;
    PyObject   * sEncoded = NULL;
    Encoding     sDummyEncoding;

    strcpy( sDummyEncoding.mName, "utf-8" );
    
    TRY( AllocateDbc( &sHdbc ) == SUCCESS );
    sState = 1;

    if( aAttrsBefore != NULL )
    {
        while( PyDict_Next( aAttrsBefore, &sPos, &sPyKey, &sPyValue ) == TRUE )
        {
#if PY_MAJOR_VERSION < 3
            if( PyInt_Check( sPyKey ) == TRUE )
            {
                sKey = (int)PyInt_AsLong( sPyKey );
            }
            
            if( PyInt_Check( sPyValue ) == TRUE )
            {
                sValue = (SQLPOINTER)PyInt_AsLong( sPyValue );
                sStringLength = SQL_IS_INTEGER;
            }
#endif
            if( PyLong_Check( sPyKey ) == TRUE )
            {
                sKey = (int)PyLong_AsLong( sPyKey );
            }
            
            if( PyLong_Check( sPyValue ) == TRUE )
            {
                sValue = (SQLPOINTER)(SQLLEN)PyLong_AsLong( sPyValue );
                sStringLength = SQL_IS_INTEGER;
            }

#if PY_MAJOR_VERSION < 3
            if( IsStringType( sPyValue ) == TRUE )
            {
                sValue = (SQLPOINTER)PyBytes_AS_STRING( sPyValue );
                sStringLength = SQL_NTS;
            }
            else
#endif
            if( IsTextType( sPyValue ) == TRUE )
            {
                sEncoded = Encode( sPyValue, &sDummyEncoding );
                TRY( sEncoded != NULL );
                sValue = (SQLPOINTER)PyBytes_AS_STRING( sEncoded );
                sStringLength = SQL_NTS;
            }

            Py_BEGIN_ALLOW_THREADS;
            sRet = GDLSetConnectAttr( sHdbc,
                                      sKey,
                                      (SQLPOINTER)sValue,
                                      sStringLength );
            Py_END_ALLOW_THREADS;

            sErrFunc = "SQLSetConnectAttr";
            TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
        }
    }

    TRY( ConnectInternal( aConnectString,
                          sHdbc,
                          aTimeout ) == SUCCESS );

    /**
     * Connected, so allocate the Connection object.
     * Set all variables to something valid, so we don't crash in dealloc if this function fails.
     */ 

#ifdef _MSC_VER
#pragma warning(disable : 4365)
#endif
    sCnxn = PyObject_NEW( Connection, &gConnectionType );
#ifdef _MSC_VER
#pragma warning(default : 4365)
#endif

    TRY( sCnxn != NULL );
    sState = 2;

    sCnxn->mHDbc              = sHdbc;
    sCnxn->mAutoCommit        = aAutoCommit ? SQL_AUTOCOMMIT_ON : SQL_AUTOCOMMIT_OFF;
    sCnxn->mSearchEscape      = PyString_FromString( "/" );
    sCnxn->mMaxWrite          = 0;
    sCnxn->mTimeout           = 0;
    sCnxn->mOdbcMajor         = '3';
    sCnxn->mOdbcMinor         = '0';
    sCnxn->mNeedLongDataLen   = FALSE;
    sCnxn->mDatetimePrecision = DEFAULT_TIMESTAMP_PRECISTION;
    sCnxn->mVarcharMaxLength  = 4000;
    sCnxn->mBinaryMaxLength   = 4000;
    
    /**
     * Initialize autocommit mode.
     * The DB API says we have to default to manual-commit, but ODBC defaults to auto-commit.
     * We also provide a keyword parameter that allows the user to override the DB API
     * and force us to start in auto-commit (in which case we don't have to do anything).
     */

    if( aAutoCommit == FALSE )
    {
        Py_BEGIN_ALLOW_THREADS;
        sRet = GDLSetConnectAttr( sCnxn->mHDbc,
                                  SQL_ATTR_AUTOCOMMIT,
                                  (SQLPOINTER)(SQLULEN)sCnxn->mAutoCommit,
                                  SQL_IS_UINTEGER );
        Py_END_ALLOW_THREADS;

        sErrFunc = "SQLSetConnnectAttr(SQL_ATTR_AUTOCOMMIT)";
        TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    }

    if( aReadOnly == TRUE )
    {
        Py_BEGIN_ALLOW_THREADS;
        sRet = GDLSetConnectAttr( sCnxn->mHDbc,
                                  SQL_ATTR_ACCESS_MODE,
                                  (SQLPOINTER)SQL_MODE_READ_ONLY,
                                  0 );
        Py_END_ALLOW_THREADS;

        sErrFunc = "SQLSetConnnectAttr(SQL_ATTR_ACCESS_MODE)";
        TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    }

    sRet = GDLGetConnectAttr( sCnxn->mHDbc,
                              SQL_ATTR_CHARACTER_SET,
                              (SQLPOINTER)sCnxn->mCharSet,
                              ENCODING_STRING_LENGTH,
                              NULL );
    sErrFunc = "SQLGetConnectAttr(SQL_ATTR_CHARACTER_SET";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    
    sEncodingType = LookupEncode( sCnxn->mCharSet );
    
    switch( sEncodingType )
    {
        case ENC_UTF8:
            sCnxn->mWritingEnc.mType = sEncodingType;
            sCnxn->mWritingEnc.mCType = SQL_C_CHAR;
            strncpy( sCnxn->mWritingEnc.mName,
                     ENCSTR_UTF8,
                     ENCODING_STRING_LENGTH );
            
            sCnxn->mReadingEnc.mType = sEncodingType;
            sCnxn->mReadingEnc.mCType = SQL_C_CHAR;
            strncpy( sCnxn->mReadingEnc.mName,
                     ENCSTR_UTF8,
                     ENCODING_STRING_LENGTH );

#if PY_MAJOR_VERSION < 3
            sCnxn->mWritingEnc.mTo = TO_STRING;
            sCnxn->mReadingEnc.mTo = TO_STRING;
#endif
            break;
        case ENC_CP949:
            sCnxn->mWritingEnc.mType = ENC_CP949;
            sCnxn->mWritingEnc.mCType = SQL_C_CHAR;
            strncpy( sCnxn->mWritingEnc.mName,
                     ENCSTR_CP949,
                     ENCODING_STRING_LENGTH );

            sCnxn->mReadingEnc.mType = ENC_CP949;
            sCnxn->mReadingEnc.mCType = SQL_C_CHAR;
            strncpy( sCnxn->mReadingEnc.mName,
                     ENCSTR_CP949,
                     ENCODING_STRING_LENGTH );

#if PY_MAJOR_VERSION < 3
            sCnxn->mWritingEnc.mTo = TO_UNICODE;
            sCnxn->mReadingEnc.mTo = TO_UNICODE;
#endif
            break;
        case ENC_GB18030:
            sCnxn->mWritingEnc.mType = ENC_GB18030;
            /**
             * WCHAR? CHAR?
             */
            sCnxn->mWritingEnc.mCType = SQL_C_CHAR;
            strncpy( sCnxn->mWritingEnc.mName,
                     ENCSTR_GB18030,
                     ENCODING_STRING_LENGTH );

            sCnxn->mReadingEnc.mType = ENC_GB18030;
            sCnxn->mReadingEnc.mCType = SQL_C_CHAR;
            strncpy( sCnxn->mReadingEnc.mName,
                     ENCSTR_GB18030,
                     ENCODING_STRING_LENGTH );

#if PY_MAJOR_VERSION < 3
            sCnxn->mWritingEnc.mTo = TO_UNICODE;
            sCnxn->mReadingEnc.mTo = TO_UNICODE;
#endif
            break;
        default:
            sCnxn->mWritingEnc.mType = ENC_UTF16NE;
            /**
             * WCHAR? CHAR?
             */ 
            sCnxn->mWritingEnc.mCType = SQL_C_CHAR;
            strncpy( sCnxn->mWritingEnc.mName,
                     ENCSTR_UTF16NE,
                     ENCODING_STRING_LENGTH );

            sCnxn->mReadingEnc.mType = ENC_UTF16NE;
            sCnxn->mReadingEnc.mCType = SQL_C_WCHAR;
            strncpy( sCnxn->mReadingEnc.mName,
                     ENCSTR_UTF16NE,
                     ENCODING_STRING_LENGTH );

#if PY_MAJOR_VERSION < 3
            sCnxn->mWritingEnc.mTo = TO_UNICODE;
            sCnxn->mReadingEnc.mTo = TO_UNICODE;
#endif
            break;
    }

    *aOutCnxn = (PyObject *)sCnxn;

    return SUCCESS; 

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( NULL,
                              sErrFunc,
                              sHdbc,
                              sStmt );
    }
    
    FINISH;

    switch(sState)
    {
        case 2:
            Py_DECREF((PyObject *)sCnxn);
        case 1:
            FreeDbc( &sHdbc );
        default:
            break;
    }

    return FAILURE;
}

static char gSetAttrDoc[] =
    "set_attr(attr_id, value) -> None\n\n"
    "Calls SQLSetConnectAttr with the given values.\n\n"
    "attr_id\n"
    "  The attribute id (integer) to set.  These are ODBC or driver constants.\n\n"
    "value\n"
    "  An integer value.\n\n"
    "At this time, only integer values are supported and are always passed as SQLUINTEGER.";

static PyObject * Connection_set_attr( PyObject * aSelf,
                                       PyObject * aArgs )
{
    int          sId;
    int          sValue;
    Connection * sCnxn = (Connection*)aSelf;
    SQLRETURN    sRet;

    /**
     * i: int
     */ 
    TRY( PyArg_ParseTuple( aArgs, "ii", &sId, &sValue ) == TRUE );
    
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLSetConnectAttr( sCnxn->mHDbc,
                              sId,
                              (SQLPOINTER)(SQLLEN)sValue,
                              SQL_IS_INTEGER);
    Py_END_ALLOW_THREADS;

    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    
    Py_RETURN_NONE;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              "SQLSetConnectAttr",
                              sCnxn->mHDbc,
                              SQL_NULL_HANDLE );
    }
    
    FINISH;

    return NULL;
}

static int Connection_clear( PyObject * aSelf )
{
    /**
     * Internal method for closing the connection.
     * (Not called close so it isn't confused with the external close method.)
     */
    
    Connection * sCnxn = (Connection*)aSelf;

    if( sCnxn->mHDbc != SQL_NULL_HANDLE )
    {
        Py_BEGIN_ALLOW_THREADS;
        if( sCnxn->mAutoCommit == SQL_AUTOCOMMIT_OFF )
        {
            GDLEndTran(SQL_HANDLE_DBC, sCnxn->mHDbc, SQL_ROLLBACK);
        }

        GDLDisconnect( sCnxn->mHDbc );
        Py_END_ALLOW_THREADS;

        FreeDbc( &sCnxn->mHDbc );
    }

    Py_XDECREF( sCnxn->mSearchEscape );
    sCnxn->mSearchEscape = NULL;

    if( gDbcCnt == 0 )
    {
        GDLFreeHandle( SQL_HANDLE_ENV, gHENV );
        gHENV = SQL_NULL_HANDLE;
    }

    return 0;
}

static void Connection_dealloc( PyObject * aSelf )
{   
    Connection_clear( aSelf );

    PyObject_Del( aSelf );
}

static char gCloseDoc[] =
    "Close the connection now (rather than whenever __del__ is called).\n"
    "\n"
    "The connection will be unusable from this point forward and a ProgrammingError\n"
    "will be raised if any operation is attempted with the connection.  The same\n"
    "applies to all cursor objects trying to use the connection.\n"
    "\n"
    "Note that closing a connection without committing the changes first will cause\n"
    "an implicit rollback to be performed.";

static PyObject * Connection_close( PyObject * aSelf,
                                    PyObject * aArgs )
{
    Connection * sCnxn;
    
    sCnxn = ValidateConnection( aSelf );
    TRY( sCnxn != NULL );

    Connection_clear( aSelf );

    Py_RETURN_NONE;

    FINISH;

    return NULL;
}

static char gCursorDoc[] =
    "Return a new Cursor object using the connection.";

static PyObject * Connection_cursor( PyObject * aSelf,
                                     PyObject * aArgs)
{
    Connection * sCnxn;

    sCnxn = ValidateConnection( aSelf );
    TRY( sCnxn != NULL );

    return (PyObject*)MakeCursor( sCnxn );

    FINISH;

    return NULL;
}

static char gExecuteDoc[] =
    "execute(sql, [params]) --> Cursor\n"
    "\n"
    "Create a new Cursor object, call its execute method, and return it.  See\n"
    "Cursor.execute for more details.\n"
    "\n"
    "This is a convenience method that is not part of the DB API.  Since a new\n"
    "Cursor is allocated by each call, this should not be used if more than one SQL\n"
    "statement needs to be executed.";

static PyObject * Connection_execute( PyObject * aSelf,
                                      PyObject * aArgs)
{
    PyObject   * sResult = NULL;
    Cursor     * sCursor;
    Connection * sCnxn;

    sCnxn = ValidateConnection( aSelf );
    TRY( sCnxn != NULL );

    sCursor = MakeCursor( sCnxn );
    TRY( sCursor != NULL );

    sResult = Cursor_execute( (PyObject*)sCursor, aArgs );

    /* Py_DECREF( (PyObject*)sCursor ); */

    return sResult;

    FINISH;

    return NULL;
}

static char gGetInfoDoc[] =
    "getinfo(type) --> str | int | bool\n"
    "\n"
    "Calls SQLGetInfo, passing `type`, and returns the result formatted as a Python object.";

static PyObject * Connection_getinfo( PyObject * aSelf,
                                      PyObject * aArgs )
{
    unsigned long   sInfoType;
    unsigned int    i = 0;
    Connection    * sCnxn;
    SQLSMALLINT     sCh = 0;
    PyObject      * sResult = NULL;
    SQLRETURN       sRet;
    SQLPOINTER      sPtr = NULL;
    union
    {
        char        mStr[4096];
        SQLUINTEGER mUint;
        SQLSMALLINT mSint;
    } sBuffer;

    /**
     * initialize for compile warning 
     */ 
    sBuffer.mSint = 0;
    sCnxn = ValidateConnection( aSelf );
    TRY( sCnxn != NULL );

    /**
     * k: unsigned long
     */ 
    TRY( PyArg_ParseTuple( aArgs, "k", &sInfoType ) == TRUE );

    for( ; i < COUNTOF( gInfoTypes ); i++ )
    {
        if( gInfoTypes[i].mInfoType == sInfoType )
        {
            switch( gInfoTypes[i].mDataType )
            {
                case GI_YESNO:
                case GI_STRING:
                    sPtr = sBuffer.mStr;
                    break;
                case GI_UINTEGER:
                    sPtr = &sBuffer.mUint;
                    break;
                case GI_USMALLINT:
                    sPtr = &sBuffer.mSint;
                    break;
                default:
                    DASSERT( FALSE );
                    break;
            }
            
            break;
        }
    }

    TRY_THROW( i < COUNTOF( gInfoTypes ), RAMP_ERR_INVALID_GET_INFO_VALUE );

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLGetInfo( sCnxn->mHDbc,
                       (SQLUSMALLINT)sInfoType,
                       sPtr,
                       sizeof(sBuffer),
                       &sCh );
    Py_END_ALLOW_THREADS;
    
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    
    switch( gInfoTypes[i].mDataType )
    {
        case GI_YESNO:
            sResult = (sBuffer.mStr[0] == 'Y') ? Py_True : Py_False;
            Py_INCREF( sResult );
            break;

        case GI_STRING:
            sResult = PyString_FromStringAndSize( sBuffer.mStr, (Py_ssize_t)sCh );
            break;

        case GI_UINTEGER:
        {
#if PY_MAJOR_VERSION >= 3
            sResult = PyLong_FromLong( (long)sBuffer.mUint );
#else
            if( sBuffer.mUint <= (SQLUINTEGER)PyInt_GetMax() )
                sResult = PyInt_FromLong( (long)sBuffer.mUint );
            else
                sResult = PyLong_FromUnsignedLong( sBuffer.mUint );
#endif
            break;
        }

        case GI_USMALLINT:
            sResult = PyInt_FromLong( sBuffer.mSint );
            break;
        default:
            DASSERT( FALSE );
            break;
    }
    
    return sResult;

    CATCH( RAMP_ERR_INVALID_GET_INFO_VALUE )
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "Invalid getinfo value: %d",
                     sInfoType );
    }
    
    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              "SQLGetInfo",
                              sCnxn->mHDbc,
                              SQL_NULL_HANDLE );
    }
    
    FINISH;

    return NULL;
}

PyObject * Connection_endtrans( Connection  * aCnxn,
                                SQLSMALLINT   aType )
{
    /**
     * If called from 'Cursor.commit',
     *  it is possible that `cnxn` is deleted by another thread when we release them below.
     *  (The cursor has had its reference incremented by the method it is calling,
     *  but nothing has incremented the connections count.
     *  We could, but we really only need the HDBC.)
     */
    SQLHDBC     sHdbc = aCnxn->mHDbc;
    SQLRETURN   sRet;
    
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLEndTran( SQL_HANDLE_DBC, sHdbc, aType );
    Py_END_ALLOW_THREADS;

    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    Py_RETURN_NONE;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( aCnxn,
                              "SQLEndTran",
                              sHdbc,
                              SQL_NULL_HANDLE );
    }
    
    FINISH;

    return NULL;
}

static char gCommitDoc[] =
    "Commit any pending transaction to the database.";

static PyObject * Connection_commit( PyObject * aSelf,
                                     PyObject * aArgs )
{
    Connection * sCnxn;

    sCnxn = ValidateConnection( aSelf );
    TRY( sCnxn != NULL );

    return Connection_endtrans( sCnxn, SQL_COMMIT );

    FINISH;

    return NULL;
}

static char gRollbackDoc[] =
    "Causes the the database to roll back to the start of any pending transaction.";

static PyObject * Connection_rollback( PyObject * aSelf,
                                       PyObject * aArgs )
{
    Connection * sCnxn;

    sCnxn = ValidateConnection( aSelf );
    TRY( sCnxn != NULL );

    return Connection_endtrans( sCnxn, SQL_ROLLBACK );

    FINISH;

    return NULL;
}

PyObject * Connection_getautocommit( PyObject * aSelf,
                                     void     * aClosure )
{
    Connection * sCnxn;
    PyObject   * sResult = Py_False;

    sCnxn = ValidateConnection( aSelf );

    TRY( sCnxn != NULL );

    if( sCnxn->mAutoCommit == SQL_AUTOCOMMIT_ON )
    {
        sResult = Py_True;
    }
    
    Py_INCREF( sResult );
    return sResult;

    FINISH;

    return NULL;
}

static int Connection_setautocommit( PyObject * aSelf,
                                     PyObject * aValue,
                                     void     * aClosure )
{
    Connection * sCnxn;
    SQLLEN       sAutoCommit = SQL_AUTOCOMMIT_OFF;
    SQLRETURN    sRet;

    sCnxn = ValidateConnection( aSelf );
    TRY( sCnxn != NULL );

    TRY_THROW( aValue != NULL, RAMP_ERR_AUTOCOMMIT_ATTR );

    if( PyObject_IsTrue( aValue ) == TRUE )
    {   
        sAutoCommit = SQL_AUTOCOMMIT_ON;
    }

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLSetConnectAttr( sCnxn->mHDbc,
                              SQL_ATTR_AUTOCOMMIT,
                              (SQLPOINTER)sAutoCommit,
                              SQL_IS_UINTEGER );
    Py_END_ALLOW_THREADS;

    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    sCnxn->mAutoCommit = sAutoCommit;

    return 0;

    CATCH( RAMP_ERR_AUTOCOMMIT_ATTR )
    {
        PyErr_SetString( PyExc_TypeError,
                         "Can not delete the autocommit attribute." );
    }

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              "SQLSetConnectAttr",
                              sCnxn->mHDbc,
                              SQL_NULL_HANDLE );
    }
    
    FINISH;

    return -1;
}


static PyObject * Connection_getsearchescape( PyObject * aSelf,
                                              void     * aClosure )
{
    Connection * sCnxn;

    sCnxn = (Connection*)aSelf;

    Py_INCREF( sCnxn->mSearchEscape );

    return sCnxn->mSearchEscape;
}

/**
 *@todo remove, QUERY TIMEOUT으로 두면 안되나?
 */ 
static PyObject * Connection_gettimeout( PyObject * aSelf,
                                         void     * aClosure )
{
    Connection * sCnxn;

    sCnxn = ValidateConnection( aSelf );
    TRY( sCnxn != NULL );

    return PyInt_FromLong( sCnxn->mTimeout );

    FINISH;

    return NULL;
}

static int Connection_settimeout( PyObject * aSelf,
                                  PyObject * aValue,
                                  void     * aClosure )
{
    Connection * sCnxn;
    SQLRETURN    sRet;
    intptr_t     sTimeout;

    sCnxn = ValidateConnection( aSelf );
    TRY( sCnxn != NULL );

    if( aValue == NULL )
    {
        PyErr_SetString( PyExc_TypeError, "Cannot delete the timeout attribute." );
        TRY( FALSE );
    }

    sTimeout = PyInt_AsLong( aValue );
    TRY( (sTimeout != -1) || (!PyErr_Occurred()) );

    TRY_THROW( sTimeout >= 0, RAMP_ERR_NEGATIVE_TIMEOUT );

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLSetConnectAttr( sCnxn->mHDbc,
                              SQL_ATTR_QUERY_TIMEOUT,
                              (SQLPOINTER)sTimeout,
                              SQL_IS_UINTEGER );
    Py_END_ALLOW_THREADS;

    TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNC );

    sCnxn->mTimeout = sTimeout;

    return 0;

    CATCH( RAMP_ERR_NEGATIVE_TIMEOUT )
    {
        PyErr_SetString(PyExc_ValueError, "Cannot set a negative timeout.");
    }

    CATCH( RAMP_ERR_SQLFUNC )
    {
        RaiseErrorFromHandle( sCnxn,
                              "SQLSetConnectAttr",
                              sCnxn->mHDbc,
                              SQL_NULL_HANDLE );
    }
    
    FINISH;

    return -1;
}

static PyObject * Connection_getmaxwrite( PyObject * aSelf,
                                          void     * aClosure )
{
    Connection * sCnxn = ValidateConnection( aSelf );

    TRY( sCnxn != NULL );
    
    return PyLong_FromSsize_t( sCnxn->mMaxWrite );

    FINISH;

    return NULL;
}

static int Connection_setmaxwrite( PyObject * aSelf,
                                   PyObject * aValue,
                                   void     * aClosure )
{
    Connection * sCnxn = ValidateConnection( aSelf );
    long         sMaxWrite;
    Py_ssize_t   sMinVal = 255;

    TRY( sCnxn != NULL );

    TRY_THROW( aValue != NULL, RAMP_ERR_MAXWRITE_VALUE );

    sMaxWrite = PyLong_AsLong( aValue ); 
    TRY( !PyErr_Occurred() );

    TRY_THROW( (sMaxWrite == 0) || (sMaxWrite >= sMinVal), RAMP_ERR_MAXWRITE_LESS_MIN );

    sCnxn->mMaxWrite = sMaxWrite;

    return 0;

    CATCH( RAMP_ERR_MAXWRITE_VALUE )
    {
        PyErr_SetString( PyExc_TypeError,
                         "Cannot delete the maxwrite attribute." );
    }

    CATCH( RAMP_ERR_MAXWRITE_LESS_MIN )
    {
        PyErr_Format( PyExc_ValueError,
                      "Cannot set maxwrite less than %d unless setting to 0.",
                      (int) sMinVal );
    }
    
    FINISH;

    return -1;
}

static char gEnterDoc[] = "__enter__() -> self.";

static PyObject * Connection_enter( PyObject * aSelf,
                                    PyObject * aArgs )
{
    Py_INCREF( aSelf );
    return aSelf;
}

static char gExitDoc[] = "__exit__(*excinfo) -> None.  Closes the connection.";

static PyObject * Connection_exit( PyObject * aSelf,
                                   PyObject * aArgs )
{
    Connection  * sCnxn = (Connection*) aSelf;
    SQLSMALLINT   sCompletionType = SQL_ROLLBACK;
    SQLRETURN     sRet;

    DASSERT( PyTuple_Check( aArgs ) );

    if( sCnxn->mAutoCommit == SQL_AUTOCOMMIT_OFF )
    {
        if( PyTuple_GetItem( aArgs, 0 ) == Py_None )
        {
            sCompletionType = SQL_COMMIT;
        }
                           
        Py_BEGIN_ALLOW_THREADS;
        sRet = GDLEndTran( SQL_HANDLE_DBC,
                           sCnxn->mHDbc,
                           sCompletionType );
        Py_END_ALLOW_THREADS;

        TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    }

    Py_RETURN_NONE;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              "SQLEndTran",
                              sCnxn->mHDbc,
                              SQL_NULL_HANDLE );
    }
        
    FINISH;

    return NULL;
}
                       

static struct PyMethodDef gConnectionMethods[] =
{
    { "cursor",                  Connection_cursor,      METH_NOARGS,  gCursorDoc    },
    { "close",                   Connection_close,       METH_NOARGS,  gCloseDoc     },
    { "execute",                 Connection_execute,     METH_VARARGS, gExecuteDoc   },
    { "commit",                  Connection_commit,      METH_NOARGS,  gCommitDoc    },
    { "rollback",                Connection_rollback,    METH_NOARGS,  gRollbackDoc  },
    { "getinfo",                 Connection_getinfo,     METH_VARARGS, gGetInfoDoc   },
    { "set_attr",                Connection_set_attr,    METH_VARARGS, gSetAttrDoc },
    { "__enter__",               Connection_enter,       METH_NOARGS,  gEnterDoc     },
    { "__exit__",                Connection_exit,        METH_VARARGS, gExitDoc      },

    { 0, 0, 0, 0 }
};

static PyGetSetDef gConnectionGetSeters[] = {
    {
        "searchescape",
        (getter)Connection_getsearchescape,
        0,
        "The ODBC search pattern escape character, as returned by\n"
        "SQLGetInfo(SQL_SEARCH_PATTERN_ESCAPE).  These are driver specific.",
        0
    },
    {
        "autocommit",
        Connection_getautocommit,
        Connection_setautocommit,
        "Returns True if the connection is in autocommit mode; False otherwise.",
        0
    },
    {
        "timeout",
        Connection_gettimeout,
        Connection_settimeout,
        "The query timeout in seconds, zero means no timeout.",
        0
    },
    {
        "maxwrite",
        Connection_getmaxwrite,
        Connection_setmaxwrite,
        "The maximum bytes to write before using SQLPutData.",
        0
    },
    { NULL, NULL, NULL, NULL, NULL }
};

PyTypeObject gConnectionType =
{
    PyVarObject_HEAD_INIT(0, 0)
    "pygoldilocks.Connection",  // tp_name
    sizeof(Connection),         // tp_basicsize
    0,                          // tp_itemsize
    Connection_dealloc,         // destructor tp_dealloc
    0,                          // tp_print
    0,                          // tp_getattr
    0,                          // tp_setattr
    0,                          // tp_compare
    0,                          // tp_repr
    0,                          // tp_as_number
    0,                          // tp_as_sequence
    0,                          // tp_as_mapping
    0,                          // tp_hash
    0,                          // tp_call
    0,                          // tp_str
    0,                          // tp_getattro
    0,                          // tp_setattro
    0,                          // tp_as_buffer
    Py_TPFLAGS_DEFAULT,         // tp_flags
    gConnectionDoc,             // tp_doc
    0,                          // tp_traverse
    0,                          // tp_clear
    0,                          // tp_richcompare
    0,                          // tp_weaklistoffset
    0,                          // tp_iter
    0,                          // tp_iternext
    gConnectionMethods,         // tp_methods
    0,                          // tp_members
    gConnectionGetSeters,       // tp_getset
    0,                          // tp_base
    0,                          // tp_dict
    0,                          // tp_descr_get
    0,                          // tp_descr_set
    0,                          // tp_dictoffset
    0,                          // tp_init
    0,                          // tp_alloc
    0,                          // tp_new
    0,                          // tp_free
    0,                          // tp_is_gc
    0,                          // tp_bases
    0,                          // tp_mro
    0,                          // tp_cache
    0,                          // tp_subclasses
    0,                          // tp_weaklist
    0,                          // tp_del
    0,                          // tp_version_tag
};

SQLLEN GetMaxLength( Connection  * aCnxn,
                     SQLSMALLINT   aCType )
{
    DASSERT( (aCType == SQL_C_BINARY) || (aCType == SQL_C_CHAR) || (aCType == SQL_C_WCHAR) ||
             (aCType == SQL_C_LONGVARBINARY) || (aCType == SQL_C_LONGVARCHAR) );
    
    if( aCnxn->mMaxWrite != 0)
    {
        return aCnxn->mMaxWrite;
    }
    
    if( aCType == SQL_C_BINARY )
    {
        return aCnxn->mBinaryMaxLength;
    }

    if( IsLongVariableType( aCType ) == TRUE )
    {
        return aCnxn->mLongVariableMaxLength;
    }
    
    return aCnxn->mVarcharMaxLength;
}
