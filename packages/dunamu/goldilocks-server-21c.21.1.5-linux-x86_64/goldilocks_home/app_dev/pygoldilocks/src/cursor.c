/*******************************************************************************
 * cursor.c
 *
 * Copyright (c) 2011, SUNJESOFT Inc.
 *
 *
 * IDENTIFICATION & REVISION
 *        $Id$
 *
 * NOTES
 *
 *
 ******************************************************************************/

/**
 * @file cursor.c
 * @brief Python Cursor for Goldilocks Python Database API
 */

/**
 * @addtogroup Cursor
 * @{
 */

/**
 * @brief Internal
 */

#include <pydbc.h>
#include <error.h>
#include <cursor.h>
#include <connection.h>
#include <row.h>
#include <buffer.h>
#include <param.h>
#include <getdata.h>
#include <encoding.h>
#include <type.h>
#include <datetime.h>

static bool IsValidStatement( Cursor * aCursor )
{
    Connection * sCnxn = GetConnection( aCursor );
    
    return (sCnxn != NULL) && (sCnxn->mHDbc != SQL_NULL_HANDLE) &&
        (aCursor->mHStmt != SQL_NULL_HANDLE);
}

static bool CheckCursor( PyObject * aObj )
{
    return ( (aObj != NULL) && (Py_TYPE(aObj) == &gCursorType) );
}

/**
 * @brief validates that a PyObject is a Cursor.
 */ 
static Cursor * ValidateCursor( PyObject * aObj,
                                int        aFlags )
{
    /**
     * optionally some other requirements controlled by `flags`.
     * If valid and all requirements (from the flags) are met,
     * the cursor is returned, cast to Cursor.
     * Otherwise NULL is returned.
     * Designed to be used at the top of methods to convert the PyObject pointer and perform necessary checks.
     * Valid flags are from the CURSOR_ enum above.
     * Note that unless CURSOR_RAISE_ERROR is supplied, an exception will not be set.
     * (When deallocating, we really don't want an exception.)
     */ 

    Connection * sCnxn   = 0;
    Cursor     * sCursor = 0;
    char       * sErrMsg;
    
    if( CheckCursor( aObj ) == FALSE )
    {
        sErrMsg = "Invalid cursor object.";
        TRY_THROW( (aFlags & CURSOR_RAISE_ERROR) != CURSOR_RAISE_ERROR,
                   RAMP_ERR_SET_ERROR );
    }

    sCursor = (Cursor*)aObj;
    sCnxn   = (Connection*)sCursor->mConnection;

    if( sCnxn == NULL )
    {
        sErrMsg = "Attempt to use a closed connection.";
        TRY_THROW( (aFlags & CURSOR_RAISE_ERROR) != CURSOR_RAISE_ERROR,
                   RAMP_ERR_SET_ERROR );
    }

    if( IS_SET( aFlags, CURSOR_REQUIRE_OPEN ) == TRUE )
    {
        if( sCursor->mHStmt == SQL_NULL_HANDLE )
        {
            sErrMsg = "Attempt to use a closed cursor.";
            TRY_THROW( (aFlags & CURSOR_RAISE_ERROR) != CURSOR_RAISE_ERROR,
                       RAMP_ERR_SET_ERROR );
        }

        if( sCnxn->mHDbc == SQL_NULL_HANDLE )
        {
            sErrMsg = "The cursor's connection has been closed.";
            TRY_THROW( (aFlags & CURSOR_RAISE_ERROR) != CURSOR_RAISE_ERROR,
                       RAMP_ERR_SET_ERROR );
        }
    }

    if( (IS_SET( aFlags, CURSOR_REQUIRE_RESULTS ) == TRUE) &&
        (sCursor->mColumnInfos == NULL) )
    {
        sErrMsg = "No results. Previous SQL was not a query.";
        TRY_THROW( (aFlags & CURSOR_RAISE_ERROR) != CURSOR_RAISE_ERROR,
                   RAMP_ERR_SET_ERROR );
    }

    return sCursor;

    CATCH( RAMP_ERR_SET_ERROR )
    {
        PyErr_SetString( ProgrammingError, sErrMsg );
    }
    
    FINISH;

    return NULL;
}

/**
 * @brief Called after an execute to construct the map shared by rows.
 */ 
static STATUS CreateNameMap( Cursor * aCursor,
                             bool     aLower )
{
    int           i = 0;
    SQLRETURN     sRet;
    PyObject    * sDesc = NULL;
    PyObject    * sColMap = NULL;
    PyObject    * sColInfo = NULL;
    PyObject    * sPyType = NULL;
    PyObject    * sIndex = NULL;
    PyObject    * sNullableObj = NULL;
    Connection  * sCnxn = GetConnection( aCursor );
    SQLCHAR       sName[300];
    SQLSMALLINT   sNameLen;
    SQLSMALLINT   sDataType;
    SQLULEN       sColSize;       // precision
    SQLSMALLINT   sDecimalDigits; // scale
    SQLSMALLINT   sNullable;
    SQLLEN        sDisplaySize;
    PyObject    * sPyName = NULL;
    PyObject    * sLowerName = NULL;
    Encoding    * sEncoding = NULL;
    Py_ssize_t    sNameEncodingLen;
    char        * sErrFunc = NULL;
    
    DASSERT( (aCursor->mHStmt != SQL_NULL_HANDLE) && (aCursor->mColumnInfos != NULL) );

    /**
     * These are the values we expect after FreeResults.
     * If this function fails, we do not modify any members,
     * so they should be set to something Cursor_close can deal with.
     */
    DASSERT( aCursor->mDescription == Py_None );
    DASSERT( aCursor->mMapNameToIndex == NULL );

    TRY_THROW( sCnxn->mHDbc != SQL_NULL_HANDLE, RAMP_ERR_CLOSED_CONNECTION );

    sDesc   = PyTuple_New( (Py_ssize_t)aCursor->mColumnCount );
    sColMap = PyDict_New();

    TRY( (sDesc != NULL) && (sColMap != NULL) );

    for( i = 0; i < aCursor->mColumnCount; i++ )
    {
        Py_BEGIN_ALLOW_THREADS;
        sRet = GDLDescribeCol( aCursor->mHStmt,
                               (SQLUSMALLINT)(i + 1),
                               sName,
                               COUNTOF( sName ),
                               &sNameLen,
                               &sDataType,
                               &sColSize,
                               &sDecimalDigits,
                               &sNullable );
        Py_END_ALLOW_THREADS;

        TRY_THROW( sCnxn->mHDbc != SQL_NULL_HANDLE, RAMP_ERR_CLOSED_CONNECTION );

        sErrFunc = "SQLDescribeCol";
        TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

        Py_BEGIN_ALLOW_THREADS;
        sRet = GDLColAttribute( aCursor->mHStmt,
                                (SQLUSMALLINT)(i + 1 ),
                                SQL_DESC_DISPLAY_SIZE,
                                NULL,
                                0,
                                NULL,
                                &sDisplaySize );
        Py_END_ALLOW_THREADS;
        TRY_THROW( sCnxn->mHDbc != SQL_NULL_HANDLE, RAMP_ERR_CLOSED_CONNECTION );

        sErrFunc = "SQLColAttribute";
        TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
        
        sEncoding = &sCnxn->mReadingEnc;

        sNameEncodingLen = sNameLen;

        switch( sEncoding->mType )
        {
            case ENC_UTF32:
            case ENC_UTF32LE:
            case ENC_UTF32BE:
                sNameEncodingLen *= 4;
                break;
            default:
                if( sEncoding->mCType == SQL_C_WCHAR )
                {
                    sNameEncodingLen *= 2;
                }
                break;
        }
        
        sPyName = TextToPyObject( sEncoding,
                                  sName,
                                  sNameEncodingLen );

        TRY( sPyName != NULL );
        
        if( aLower == TRUE )
        {
            sLowerName = PyObject_CallMethod( sPyName, "lower", 0 );

            TRY( sLowerName != NULL );
            
            ATTACH_PYOBJECT( sPyName, sLowerName );
        }

        sPyType = PythonTypeFromSqlType( aCursor, sDataType );

        TRY( sPyType != NULL );

        switch( sNullable )
        {
            case SQL_NO_NULLS:
                sNullableObj = Py_False;
                break;
            case SQL_NULLABLE:
                sNullableObj = Py_True;
                break;
            case SQL_NULLABLE_UNKNOWN:
            default:
                sNullableObj = Py_None;
                break;
        }

        sColInfo = Py_BuildValue( "(OOliiiO)",
                                  sPyName,
                                  sPyType,             // type_code
                                  sDisplaySize,        // display size
                                  (int)sColSize,       // internal_size
                                  (int)sColSize,       // precision
                                  (int)sDecimalDigits, // scale
                                  sNullableObj );      // null_ok

        TRY( sColInfo != NULL );

        sNullableObj = NULL;

        sIndex = PyInt_FromLong( i );

        TRY( sIndex != NULL );
        
        (void)PyDict_SetItem( sColMap, sPyName, sIndex);
        Py_DECREF( sIndex );  // SetItemString increments
        sIndex = NULL;

        PyTuple_SET_ITEM( sDesc, i, sColInfo );
        sColInfo = NULL;      // reference stolen by SET_ITEM
    }

    Py_XDECREF( aCursor->mDescription );

    aCursor->mDescription = sDesc;
    aCursor->mMapNameToIndex = sColMap;

    Py_XDECREF( sPyName );
    Py_XDECREF( sNullableObj );
    Py_XDECREF( sIndex);
    Py_XDECREF( sColInfo );

    return SUCCESS;

    CATCH( RAMP_ERR_CLOSED_CONNECTION )
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "The cursor's connection was closed." );
    }

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              aCursor->mHStmt );
    }
    
    FINISH;

    Py_XDECREF( sPyName );
    Py_XDECREF( sNullableObj );
    Py_XDECREF( sDesc );
    Py_XDECREF( sColMap );
    Py_XDECREF( sIndex);
    Py_XDECREF( sColInfo );
    
    return FAILURE;
}

static void FreeColumnInfos( Cursor * aCursor )
{
    ColumnInfo * sColumnInfo;
    SQLLEN       i;
    
    if( aCursor->mColumnInfos != NULL )
    {
        for( i = 0; i < aCursor->mColumnCount; i++ )
        {
            sColumnInfo = aCursor->mColumnInfos + i;
            if( sColumnInfo->mValue != NULL )
            {
                free( sColumnInfo->mValue );
            }
        }

        free( aCursor->mColumnInfos );
        aCursor->mColumnInfos = NULL;
    }
}

/**
 * Query results에 대한 메모리 및 Statement handle 해제.
 */ 
static STATUS FreeResults( Cursor * aCursor,
                           int      aFlags )
{
    /**
     * Internal function called any time we need to free the memory associated with query results.
     * It is safe to call this even when a query has not been executed.
     * If we ran out of memory, it is possible that we have a cursor but colinfos is zero.
     * However, we should be deleting this object,
     * so the cursor will be freed when the HSTMT is destroyed.
     */
    Connection * sCnxn = GetConnection( aCursor );
    
    DASSERT( (aFlags & STATEMENT_MASK) != 0 );
    DASSERT( (aFlags & PREPARED_MASK) != 0 );
    
    if( (aFlags & PREPARED_MASK) == FREE_PREPARED )
    {
        Py_XDECREF( aCursor->mPreparedSQL );
        aCursor->mPreparedSQL = NULL;
    }

    FreeColumnInfos( aCursor );

    if( IsValidStatement( aCursor ) == TRUE )
    {
        if( (aFlags & STATEMENT_MASK) == FREE_STATEMENT )
        {
            Py_BEGIN_ALLOW_THREADS;
            GDLFreeStmt( aCursor->mHStmt, SQL_CLOSE );
            Py_END_ALLOW_THREADS;
        }
        else
        {
            Py_BEGIN_ALLOW_THREADS;
            GDLFreeStmt( aCursor->mHStmt, SQL_UNBIND );
            GDLFreeStmt( aCursor->mHStmt, SQL_RESET_PARAMS );
            Py_END_ALLOW_THREADS;
        }

        TRY_THROW( sCnxn->mHDbc != SQL_NULL_HANDLE, RAMP_ERR_CLOSED_CONNECTION );
    }

    if( aCursor->mDescription != Py_None )
    {
        Py_XDECREF( aCursor->mDescription );
        aCursor->mDescription = Py_None;
        Py_INCREF(Py_None);
    }

    if( aCursor->mMapNameToIndex != NULL )
    {
        Py_XDECREF( aCursor->mMapNameToIndex );
        aCursor->mMapNameToIndex = NULL;
    }

    aCursor->mRowCount = -1;

    return SUCCESS;

    CATCH( RAMP_ERR_CLOSED_CONNECTION )
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "The cursor's connection was closed." );
    }
    
    FINISH;

    return FAILURE;
}


static void CloseImplement( Cursor * aCursor )
{  
    SQLHSTMT     sHStmt = aCursor->mHStmt;
    SQLRETURN    sRet;
    Connection * sCnxn = GetConnection( aCursor );

    (void)FreeColumnInfos( aCursor );
    (void)FreeParameterInfos( aCursor );

    if( IsValidStatement( aCursor ) == TRUE )
    {
        sHStmt = aCursor->mHStmt;
        
        aCursor->mHStmt = SQL_NULL_HANDLE;

        Py_BEGIN_ALLOW_THREADS;
        sRet = GDLFreeHandle( SQL_HANDLE_STMT, sHStmt );
        Py_END_ALLOW_THREADS;

        if( (!SQL_SUCCEEDED( sRet )) && (!PyErr_Occurred()) )
        {
            RaiseErrorFromHandle( sCnxn,
                                  "SQLFreeHandle",
                                  sCnxn->mHDbc,
                                  SQL_NULL_HANDLE );
        }
    }


    Py_XDECREF( aCursor->mPreparedSQL );
    Py_XDECREF( aCursor->mDescription );
    Py_XDECREF( aCursor->mMapNameToIndex );
    Py_XDECREF( (PyObject *)aCursor->mConnection );

    aCursor->mParamCount  = 0;
    aCursor->mPreparedSQL = NULL;
    aCursor->mDescription = NULL;
    aCursor->mMapNameToIndex = NULL;
    aCursor->mConnection  = NULL;
}

static char gCloseDoc[] =
    "Close the cursor now (rather than whenever __del__ is called).  The cursor will\n"
    "be unusable from this point forward; a ProgrammingError exception will be\n"
    "raised if any operation is attempted with the cursor.";

static PyObject * Cursor_close( PyObject * aSelf, PyObject * aArgs )
{
    Cursor * sCursor = NULL;
    
    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN | CURSOR_RAISE_ERROR );

    TRY( sCursor != NULL );
    
    CloseImplement( sCursor );

    TRY( !PyErr_Occurred() );

    Py_RETURN_NONE; 

    FINISH;
    
    return NULL;
}

static void Cursor_dealloc( Cursor * aCursor )
{    
    CloseImplement( aCursor );
    
    Py_XDECREF( aCursor->mInputSizes );
    PyObject_Del( aCursor );
}


/**
 * @brief Initializes ColumnInfo from result set metadata.
 */ 
STATUS InitColumnInfo( Cursor       * aCursor,
                       SQLUSMALLINT   aIndex,
                       ColumnInfo   * aInfo )
{
    SQLRETURN     sRet;

    // REVIEW: This line fails on OS/X with the FileMaker driver : http://www.filemaker.com/support/updaters/xdbc_odbc_mac.html
    //
    // I suspect the problem is that it doesn't allow NULLs in some of the parameters, so I'm going to supply them all to see what happens.

    SQLCHAR       sColumnName[200];
    SQLSMALLINT   sBufferLength  = COUNTOF( sColumnName );
    SQLSMALLINT   sNameLength    = 0;
    SQLSMALLINT   sDataType      = 0;
    SQLULEN       sColumnSize    = 0;
    SQLSMALLINT   sDecimalDigits = 0;
    SQLSMALLINT   sNullable      = 0;
    Connection  * sCnxn = GetConnection( aCursor );
    char        * sErrFunc = NULL;
    
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLDescribeCol( aCursor->mHStmt,
                           aIndex,
                           sColumnName,
                           sBufferLength,
                           &sNameLength,
                           &sDataType,
                           &sColumnSize,
                           &sDecimalDigits,
                           &sNullable );
    Py_END_ALLOW_THREADS;

    aInfo->mSqlType       = sDataType;
    aInfo->mColumnSize    = sColumnSize;
    aInfo->mDecimalDigits = sDecimalDigits;
    
    TRY_THROW( sCnxn->mHDbc != SQL_NULL_HANDLE, RAMP_ERR_CLOSED_CONNECTION );

    sErrFunc = "SQLDescribeCol";
    TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );

    return SUCCESS;

    CATCH( RAMP_ERR_CLOSED_CONNECTION )
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "The cursor's connection was closed." );
    }

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              aCursor->mHStmt );
    }
    
    FINISH;

    return FAILURE;
}

static STATUS BindColumn( Cursor       * aCursor,
                          SQLUSMALLINT   aIndex )
{
    Connection  * sCnxn = GetConnection( aCursor );
    ColumnInfo  * sColumnInfo;
    SQLSMALLINT   sValueType = 0;
    char        * sErrFunc;
    size_t        sAllocSize = 0;
    SQLRETURN     sRet;
    
    sColumnInfo = &aCursor->mColumnInfos[ aIndex - 1 ];
    
    switch( sColumnInfo->mSqlType )
    {
        case SQL_VARCHAR:
        case SQL_CHAR:
            sValueType = sCnxn->mReadingEnc.mCType;
            break;
        case SQL_VARBINARY:
        case SQL_BINARY:
            sValueType = SQL_C_BINARY;
            break;
        case SQL_BOOLEAN:
            sValueType = SQL_C_BOOLEAN;
            break;
        case SQL_BIT:
            sValueType = SQL_C_BIT;
            break;
        case SQL_SMALLINT:
            sValueType = SQL_C_SSHORT;
            break;
        case SQL_INTEGER:
            sValueType = SQL_C_SLONG;
            break;
        case SQL_FLOAT:
        case SQL_REAL:
        case SQL_DOUBLE:
            sValueType = SQL_C_DOUBLE;
            break;
        case SQL_BIGINT:
            sValueType = SQL_C_SBIGINT;
            break;
        case SQL_DECIMAL:
        case SQL_NUMERIC:
            if( sColumnInfo->mDecimalDigits == 0 )
            {
                if( sColumnInfo->mColumnSize > 19 )
                {
                    sValueType = SQL_C_CHAR;
                }
                else 
                {
                    sValueType = SQL_C_SBIGINT;
                }       
            }
            else
            {
                sValueType = sCnxn->mReadingEnc.mCType;
                //sValueType = SQL_C_CHAR;
            }
            break;
        case SQL_TYPE_DATE:
        case SQL_TYPE_TIME:
        case SQL_TYPE_TIMESTAMP:
            sValueType = SQL_C_TYPE_TIMESTAMP;
            break;
        case SQL_TYPE_TIME_WITH_TIMEZONE:
        case SQL_TYPE_TIMESTAMP_WITH_TIMEZONE:
        case SQL_INTERVAL_YEAR :
        case SQL_INTERVAL_MONTH :
        case SQL_INTERVAL_DAY :
        case SQL_INTERVAL_HOUR :
        case SQL_INTERVAL_MINUTE :
        case SQL_INTERVAL_SECOND :
        case SQL_INTERVAL_YEAR_TO_MONTH :
        case SQL_INTERVAL_DAY_TO_HOUR :
        case SQL_INTERVAL_DAY_TO_MINUTE :
        case SQL_INTERVAL_DAY_TO_SECOND :
        case SQL_INTERVAL_HOUR_TO_MINUTE :
        case SQL_INTERVAL_HOUR_TO_SECOND :
        case SQL_INTERVAL_MINUTE_TO_SECOND :
            sValueType = SQL_C_CHAR;
            break;
        case SQL_LONGVARCHAR:
        case SQL_LONGVARBINARY:
            THROW( RAMP_SKIP );
            break;
        default:
            THROW( RAMP_ERR_INVALID_TYPE );
            break;
    }

    /**
     *@todo check column size 
     */ 
    sAllocSize = sColumnInfo->mColumnSize + 3;

    sColumnInfo->mValue = (void*) malloc( sAllocSize );
    TRY_THROW( sColumnInfo->mValue != NULL, RAMP_ERR_NO_MEMORY );
    
    Py_BEGIN_ALLOW_THREADS;
    sErrFunc = "SQLBindCol";
    sRet = GDLBindCol( aCursor->mHStmt,
                       aIndex,
                       sValueType,
                       sColumnInfo->mValue,
                       sAllocSize,
                       &sColumnInfo->mIndicator );     
    Py_END_ALLOW_THREADS;

    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    
    RAMP( RAMP_SKIP );
    
    return SUCCESS;

    CATCH( RAMP_ERR_NO_MEMORY )
    {
        PyErr_NoMemory();
    }
    
    CATCH( RAMP_ERR_INVALID_TYPE )
    {
        PyErr_Format( ProgrammingError,
                      "Invalid sql type %d",
                      (int) aCursor->mColumnInfos[ aIndex - 1 ].mSqlType );
    }
    
    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              aCursor->mHStmt );
    }

    FINISH;

    return FAILURE;
}

static STATUS PrepareResults( Cursor * aCursor )
{
    /**
     * Called after a SELECT has been executed to perform pre-fetch work.
     * Allocates the ColumnInfo structures describing the returned data.
     */
    int          i;
    int          sState = 0;
    
    DASSERT( aCursor->mColumnInfos == NULL );

    aCursor->mColumnInfos = (ColumnInfo*)malloc( sizeof( ColumnInfo ) * aCursor->mColumnCount );
    TRY_THROW( aCursor->mColumnInfos != NULL, RAMP_ERR_NO_MEMORY );
    sState = 1;
    
    memset( aCursor->mColumnInfos, 0x00, sizeof( ColumnInfo ) * aCursor->mColumnCount );
    
    for( i = 0; i < aCursor->mColumnCount; i++ )
    {
        TRY( InitColumnInfo( aCursor,
                             (SQLUSMALLINT)(i + 1),
                             &aCursor->mColumnInfos[i] ) == SUCCESS );

        TRY( BindColumn( aCursor,
                         (SQLUSMALLINT)(i + 1) ) == SUCCESS );
    }

    return SUCCESS;

    CATCH( RAMP_ERR_NO_MEMORY )
    {
        PyErr_NoMemory();
    }
    
    FINISH;

    switch( sState )
    {
        case 1:
            free( aCursor->mColumnInfos );
            aCursor->mColumnInfos = NULL;
        default:
            break;
    }

    return FAILURE;
}

STATUS ProcessLongParamDatas( SQLRETURN * aRet,
                              Cursor    * aCursor )
{
    SQLRETURN      sRet;
    char         * sPtr = NULL;
    SQLLEN         sOffset = 0;
    SQLLEN         sSize = 0;
    SQLLEN         sRemaining;
    char         * sErrFunc = NULL;
    ParamInfo    * sParamInfo = NULL;
    Connection   * sCnxn = GetConnection( aCursor );
#if PY_MAJOR_VERSION < 3
    BufSegIterator sIter;
#endif

    sRet = *aRet;
    
    while( sRet == SQL_NEED_DATA )
    {
        /**
         * One or more parameters were too long to bind normally so we set the length
         * to SQL_LEN_DATA_AT_EXEC.  ODBC will return SQL_NEED_DATA for each of
         * the parameters we did this for.
         *
         * For each one we set a pointer to the ParamInfo as the "parameter data"
         * we can access with SQLParamData. We've stashed everything we need in there.
         */        
        Py_BEGIN_ALLOW_THREADS;
        sRet = GDLParamData( aCursor->mHStmt, (SQLPOINTER*)&sParamInfo );
        Py_END_ALLOW_THREADS;

        sErrFunc = "SQLParamData";
        TRY_THROW( (sRet == SQL_NEED_DATA) || (sRet == SQL_NO_DATA) || SQL_SUCCEEDED(sRet),
                   RAMP_ERR_SQLFUNCTION );

        sOffset = 0;
        sErrFunc = "SQLPutData";
        if( sRet == SQL_NEED_DATA )
        {            
            if( PyBytes_Check( sParamInfo->mParam ) == TRUE )
            {
                sPtr  = PyBytes_AS_STRING( sParamInfo->mParam );
                sSize = (SQLLEN)PyBytes_GET_SIZE( sParamInfo->mParam );
                while( sOffset < sSize )
                {
                    sRemaining = MIN( sParamInfo->mMaxLength, sSize - sOffset );
                    
                    Py_BEGIN_ALLOW_THREADS;
                    sRet = GDLPutData( aCursor->mHStmt,
                                       (SQLPOINTER)&sPtr[sOffset],
                                       sRemaining );
                    Py_END_ALLOW_THREADS;

                    TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );
                    
                    sOffset += sRemaining;
                }
            }
#if PY_VERSION_HEX >= 0x02060000
            else if( PyByteArray_Check( sParamInfo->mParam ) == TRUE )
            {
                sPtr  = PyByteArray_AS_STRING( sParamInfo->mParam );
                sSize = (SQLLEN)PyByteArray_GET_SIZE( sParamInfo->mParam );
                while( sOffset < sSize )
                {
                    sRemaining = MIN( sParamInfo->mMaxLength, sSize - sOffset );

                    Py_BEGIN_ALLOW_THREADS;
                    sRet = GDLPutData( aCursor->mHStmt,
                                       (SQLPOINTER)&sPtr[sOffset],
                                       sRemaining );
                    Py_END_ALLOW_THREADS;

                    TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );
                    
                    sOffset += sRemaining;
                }
            }
#endif
#if PY_MAJOR_VERSION < 3
            else if( PyBuffer_Check( sParamInfo->mParam ) == TRUE )
            {
                /**
                 * Buffers can have multiple segments, so we might need multiple writes.
                 * Looping through buffers isn't difficult,
                 * but we've wrapped it up in an iterator object to keep this loop simple.
                 */
                InitBufSegIterator( &sIter, sParamInfo->mParam );
                while( GetNextBufSegIterator( &sIter, &sPtr, &sSize ) == TRUE )
                {
                    Py_BEGIN_ALLOW_THREADS;
                    sRet = GDLPutData( aCursor->mHStmt,
                                       sPtr,
                                       sSize );
                    Py_END_ALLOW_THREADS;

                    TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );
                }
            }
#endif
            sRet = SQL_NEED_DATA;
        }
    }

    *aRet = sRet;

    return SUCCESS;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              aCursor->mHStmt );
    }
    
    FINISH;

    return FAILURE;
}

static STATUS Execute( Cursor    * aCursor,
                       PyObject  * aSql,
                       PyObject  * aParams,
                       bool        aSkipFirst,
                       PyObject ** aOutCursor )
{
    int           sParamOffset = 0;
    Py_ssize_t    sParamsSize = 0;
    SQLLEN        sRowCount;
    SQLSMALLINT   sColumnCount = 0;
    SQLRETURN     sRet = 0;
    Connection  * sCnxn = GetConnection( aCursor );
    PyObject    * sBytesSql = NULL;
    SQLINTEGER    sQuerySize;
    Encoding    * sEncoding = NULL;
    bool          sIsWide = FALSE;
    char        * sStr;
    char        * sErrFunc = NULL;
    
    /**
     * Internal function to execute SQL, called by .execute and .executemany.
     * aSql
     *  A PyString, PyUnicode, or derived object containing the SQL.
     * aParams
     *  Pointer to an optional sequence of parameters, and possibly the SQL statement (see skip_first):
     *  (SQL, param1, param2) or (param1, param2).
     * aSkipFirst
     *  If true, the first element in `aParams` is ignored.
     *   (It will be the SQL statement and `aParams` will be the entire tuple passed to Cursor.execute.)
     *  Otherwise all of the aParams are used.
     *  (This case occurs when called from Cursor.executemany,
     *  in which case the sequences do not contain the SQL statement.)
     * Ignored if aParams is NULL.
     */  

    if( aParams != NULL )
    {
        TRY_THROW( (PyTuple_Check(aParams) == TRUE) || (PyList_Check(aParams) == TRUE) ||
                   (ROW_CHECK(aParams) == TRUE), RAMP_ERR_INVALID_PARAMS_TYPE );
    }

    // Normalize the parameter variables.
    if( aSkipFirst == TRUE )
    {
        sParamOffset = 1;
    }

    if( aParams != NULL )
    {
        sParamsSize = PySequence_Length( aParams ) - sParamOffset;
    }

    /**
     * 
     */ 
    TRY( FreeResults( aCursor, FREE_STATEMENT | KEEP_PREPARED ) == SUCCESS );

    if( sParamsSize > 0 )
    {
        /**
         * There are parameters, so we'll need to prepare the SQL statement and bind the parameters.
         * (We need to prepare the statement because we can't bind a NULL (None) object
         * without knowing the target datatype.
         * There is no one data type that always maps to the others (no, not even varchar)).
         */
        TRY( PrepareAndBind( aCursor,
                             aSql,
                             aParams,
                             aSkipFirst ) == SUCCESS );

        sErrFunc = "SQLExecute";
        Py_BEGIN_ALLOW_THREADS;
        sRet = GDLExecute( aCursor->mHStmt );
        Py_END_ALLOW_THREADS;
    }
    else
    {
        // REVIEW: Why don't we always prepare?
        // It is highly unlikely that a user would need to execute the same SQL repeatedly if it did not have parameters, so we are not losing performance, but it would simplify the code.

        Py_XDECREF( aCursor->mPreparedSQL );
        aCursor->mPreparedSQL = NULL;

        sEncoding = &sCnxn->mWritingEnc;
        sBytesSql = Encode( aSql, sEncoding );

        TRY( sBytesSql != NULL );
        if( sEncoding->mType >=  ENC_UTF16 )
        {
            sIsWide = TRUE;
        }
        
        sStr = PyBytes_AS_STRING( sBytesSql );
        if( sIsWide == TRUE )
        {
            sQuerySize = (SQLINTEGER)(PyBytes_GET_SIZE( sBytesSql ) / sizeof( SQLWCHAR ));
        }
        else
        {
            sQuerySize = (SQLINTEGER)PyBytes_GET_SIZE( sBytesSql );
        }

        Py_BEGIN_ALLOW_THREADS;
        if( sIsWide == TRUE )
        {
            sErrFunc = "SQLExecDirectW";
            sRet = GDLExecDirectW( aCursor->mHStmt,(SQLWCHAR*) sStr, sQuerySize );
        }
        else
        {
            sErrFunc = "SQLExecDirect";
            sRet = GDLExecDirect( aCursor->mHStmt, (SQLCHAR*)sStr, sQuerySize );
        }
        Py_END_ALLOW_THREADS;
    }

    TRY_THROW( sCnxn->mHDbc != SQL_NULL_HANDLE, RAMP_ERR_CLOSED_CURSOR );

    /**
     * We could try dropping through the while and if below, but if there is an error,
     * we need to raise it before FreeParameterData calls more ODBC functions.
     */
    TRY_THROW( (sRet == SQL_NEED_DATA) || (sRet == SQL_NO_DATA) || SQL_SUCCEEDED(sRet),
               RAMP_ERR_SQLFUNCTION );

    TRY( ProcessLongParamDatas( &sRet, aCursor ) == SUCCESS );
    
    if( sRet == SQL_NO_DATA )
    {
        // Example: A delete statement that did not delete anything.
        aCursor->mRowCount = 0;
        Py_INCREF(aCursor);

        THROW( RAMP_FINISH );
    }

    sErrFunc = "SQLPutData";
    TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );
    
    sRowCount = -1;
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLRowCount( aCursor->mHStmt, &sRowCount );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLRowCount";
    TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );
    
    aCursor->mRowCount = (int)sRowCount;

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLNumResultCols( aCursor->mHStmt, &sColumnCount );
    Py_END_ALLOW_THREADS;

    /**
     * Note: The SQL Server driver sometimes returns HY007 here if multiple statements (separated by ;) were
     * submitted.  This is not documented, but I've seen it with multiple successful inserts.
     */ 
    sErrFunc = "SQLNumResultCols";
    TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );

    TRY_THROW( sCnxn->mHDbc != SQL_NULL_HANDLE, RAMP_ERR_CLOSED_CURSOR );

    aCursor->mColumnCount = sColumnCount;
    if( sColumnCount != 0 )
    {
        // A result set was created.
        TRY( PrepareResults( aCursor ) == SUCCESS );

        TRY( CreateNameMap( aCursor, IsLowerCase() ) == SUCCESS );
    }

    RAMP( RAMP_FINISH );
    
    Py_INCREF( aCursor );
    *aOutCursor = (PyObject*)aCursor;

    return SUCCESS;

    CATCH( RAMP_ERR_INVALID_PARAMS_TYPE )
    {
        RaiseErrorV( NULL,
                     PyExc_TypeError,
                     "Params must be in a list, tuple, or Row" );
    }
    
    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              aCursor->mHStmt );
    }

    CATCH( RAMP_ERR_CLOSED_CURSOR )
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "The cursor's connection was closed." );
    }
    
    FINISH;
    
    *aOutCursor = NULL;
    
    return FAILURE;
}


static bool IsSequence( PyObject * aObj )
{
    // Used to determine if the first parameter of execute is a collection of SQL parameters or is a SQL parameter
    // itself.  If the first parameter is a list, tuple, or Row object, then we consider it a collection.  Anything
    // else, including other sequences (e.g. bytearray), are considered SQL parameters.

    return PyList_Check( aObj ) || PyTuple_Check( aObj ) || ROW_CHECK( aObj );
}


static char gExecuteDoc[] =
    "C.execute(sql, [params]) --> Cursor\n"
    "\n"
    "Prepare and execute a database query or command.\n"
    "\n"
    "Parameters may be provided as a sequence (as specified by the DB API) or\n"
    "simply passed in one after another (non-standard):\n"
    "\n"
    "  cursor.execute(sql, (param1, param2))\n"
    "\n"
    "    or\n"
    "\n"
    "  cursor.execute(sql, param1, param2)\n";

PyObject * Cursor_execute( PyObject * aSelf,
                           PyObject * aArgs )
{
    Py_ssize_t   sParamSize;
    Cursor     * sCursor = NULL;
    PyObject   * sSql;
    bool         sSkipFirst = FALSE;
    PyObject   * sParams = NULL;
    PyObject   * sPyCursor = NULL;

    sParamSize = PyTuple_Size( aArgs ) - 1;
    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN | CURSOR_RAISE_ERROR );
    TRY( sCursor != NULL );

    TRY_THROW( sParamSize >= 0, RAMP_ERR_ARGUMENT_COUNT );

    sSql = PyTuple_GET_ITEM( aArgs, 0 );

    TRY_THROW( (PyString_Check( sSql ) == TRUE) || (PyUnicode_Check( sSql ) == TRUE),
               RAMP_ERR_ARGUMENT_TYPE );

    /**
     *  For example, SQL has 2 parameter what looks like
     * type1: execute('?,?', param1, param2) or type2: execute( '?,?', (param1,param2) ).
     * type1 is a sequence, but type2 is a sequence having a sequence.
     * We want to handle both in the same format as type1.
     *
     *  Moreover, aArgs can not have multiple sequence like
     * execute( '?,?', (parama1,Param2), (param1,parma2) ).
     */
    if( (sParamSize == 1) && (IsSequence( PyTuple_GET_ITEM(aArgs, 1) ) == TRUE) )
    {
        /**
         * There is a single argument and it is a sequence,
         * so we must treat it as a sequence of parameters.
         * (This is the normal Cursor.execute behavior.)
         */
        sParams = PyTuple_GET_ITEM(aArgs, 1);
    }
    else if( sParamSize > 0 )
    {
        sParams    = aArgs;
        sSkipFirst = TRUE;
    }

    // Execute.
    TRY( Execute( sCursor,
                  sSql,
                  sParams,
                  sSkipFirst,
                  &sPyCursor ) == SUCCESS );

    return sPyCursor;

    CATCH( RAMP_ERR_ARGUMENT_COUNT )
    {
        PyErr_SetString( PyExc_TypeError,
                         "execute() takes at least 1 argument (0 given)" );
    }

    CATCH( RAMP_ERR_ARGUMENT_TYPE )
    {
        PyErr_SetString( PyExc_TypeError,
                         "The first argument to execute must be a string or unicode query." );
    }
    
    FINISH;
    
    return NULL;
}


static char gExecuteManyDoc[] =
    "executemany(sql, seq_of_params) --> Cursor | count | None\n" \
    "\n" \
    "Prepare a database query or command and then execute it against all parameter\n" \
    "sequences found in the sequence seq_of_params.\n" \
    "\n" \
    "Only the result of the final execution is returned.  See `execute` for a\n" \
    "description of parameter passing the return value.";

static PyObject * Cursor_executemany( PyObject * aSelf,
                                      PyObject * aArgs )
{
    Cursor      * sCursor = NULL;
    PyObject    * sSql;
    PyObject    * sParamsSeq;
    Py_ssize_t    sSize;
    Py_ssize_t    i = 0;
    PyObject    * sParam = NULL;
    PyObject    * sPyCursor = NULL;
    bool          sSuccess = FALSE;
    PyObject    * sIter = NULL;
    
    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN | CURSOR_RAISE_ERROR );
    TRY( sCursor != NULL );
    
    sCursor->mRowCount = -1;

    TRY( PyArg_ParseTuple( aArgs, "OO", &sSql, &sParamsSeq ) == TRUE );

    TRY_THROW( (PyString_Check( sSql ) == TRUE) || (PyUnicode_Check( sSql ) == TRUE),
               RAMP_ERR_FIRST_PARAMETER_TYPE );
    
    if( IsSequence( sParamsSeq ) == TRUE )
    {
        sSize = PySequence_Size( sParamsSeq );

        TRY_THROW( sSize > 0, RAMP_ERR_SECOND_PARAMETER_EMPTY );

        if( sCursor->mFastExecMany == TRUE )
        {
            TRY( ExecuteMulti( sCursor,
                               sSql,
                               sParamsSeq ) == SUCCESS );
        }
        else
        {
            for( i = 0; i < sSize; i++ )
            {
                sParam  = PySequence_GetItem( sParamsSeq, i );

                if( Execute( sCursor,
                             sSql,
                             sParam,
                             FALSE, /* aSkipFirst */
                             &sPyCursor ) == SUCCESS )
                {
                    sSuccess = TRUE;
                }
                else
                {
                    sSuccess = FALSE;
                }

                Py_XDECREF( sPyCursor );
                Py_DECREF( sParam );

                if( sSuccess == FALSE )
                {
                    sCursor->mRowCount = -1;
                    TRY( FALSE );
                }
            }
        }
    }
    else if( (PyGen_Check( sParamsSeq ) == TRUE) || (PyIter_Check( sParamsSeq ) == TRUE) )
    {
        if( PyGen_Check( sParamsSeq ) == TRUE )
        {
            sIter = PyObject_GetIter( sParamsSeq );
        }
        else
        {
            sIter = sParamsSeq;
            Py_INCREF( sParamsSeq );
        }
        
        while( TRUE )
        {
            ATTACH_PYOBJECT( sParam, PyIter_Next( sIter ) );
            if( sParam == NULL )
            {
                break;
            }

            if( Execute( sCursor,
                         sSql,
                         sParam,
                         FALSE, /* aSkipFirst */
                         &sPyCursor ) != SUCCESS )
            {
                sCursor->mRowCount = -1;
                TRY( FALSE );
            }

            Py_XDECREF( sPyCursor );
        }

        TRY( !PyErr_Occurred() );
    }
    else
    {
        THROW( RAMP_ERR_INVALID_PARAMEMTER );
    }

    sCursor->mRowCount = -1;
    
    Py_RETURN_NONE;

    CATCH( RAMP_ERR_FIRST_PARAMETER_TYPE )
    {
        PyErr_SetString( PyExc_TypeError,
                         "The first argument to execute must be a string or unicode query." );
    }
    
    CATCH( RAMP_ERR_SECOND_PARAMETER_EMPTY )
    {
        PyErr_SetString( ProgrammingError,
                         "The second parameter to executemany must not be empty." );
    }

    CATCH( RAMP_ERR_INVALID_PARAMEMTER )
    {
        PyErr_SetString( ProgrammingError,
                         "The second parameter to executemany must be a sequence, iterator, or generator." );
    }
    
    FINISH;
    
    return NULL;
}

static char gSetInputSizesDoc[] =
    "setinputsizes(sizes) -> None\n" \
    "\n" \
    "Sets the type information to be used when binding parameters.\n" \
    "sizes must be a sequence of values, one for each input parameter.\n" \
    "Each value may be an integer to override the column size when binding character\n" \
    "data, a Type Object to override the SQL type, or a sequence of integers to specify\n" \
    "(SQL type, column size, decimal digits) where any may be none to use the default.\n" \
    "\n" \
    "Parameters beyond the length of the sequence will be bound with the defaults.\n" \
    "Setting sizes to None reverts all parameters to the defaults.";

static PyObject * Cursor_setinputsizes( PyObject * aSelf,
                                        PyObject * aSizes )
{
    Cursor * sCursor = (Cursor*)aSelf;
    
    TRY_THROW( CheckCursor( aSelf ) == TRUE, RAMP_ERR_INVALID_CURSOR );
    
    if( Py_None == aSizes )
    {
        Py_XDECREF( sCursor->mInputSizes );
        sCursor->mInputSizes = NULL;
    }
    else
    {
        TRY_THROW( IsSequence( aSizes ) == TRUE, RAMP_ERR_INVALID_PARAMETER );

        Py_XDECREF( sCursor->mInputSizes );
        Py_INCREF( aSizes );
        sCursor->mInputSizes = aSizes;
    }

    Py_RETURN_NONE;

    CATCH( RAMP_ERR_INVALID_CURSOR )
    {
        PyErr_SetString( ProgrammingError,
                         "Invalid cursor object." );
    }

    CATCH( RAMP_ERR_INVALID_PARAMETER )
    {
        PyErr_SetString( ProgrammingError,
                         "A non-None parameter to setinputsizes must be a sequence, iterator, or generator." );
    }
    
    FINISH;

    return NULL;
}

/**
 * @todo ( size, index ) n개 저장할 수 있어야 한다..
 */ 
static char gSetOutputSizeDoc[] =
    "setoutputsize(size[,column]) -> None\n" \
    "\n" \
    "Sets the buffer length to be used when out binding parameters.\n"
    "The size may be an integer to override the column size when binding character\n" \
    "data, or large size object.\n" \
    "(SQL type, column size, decimal digits) where any may be none to use the default.\n" \
    "\n"\
    "Setting sizes to None reverts all parameters to the defaults.";

static PyObject * Cursor_setoutputsize( PyObject * aSelf,
                                        PyObject * aArgs )
{
    Cursor     * sCursor = (Cursor*)aSelf;
    long         sSize  = 0;
    Py_ssize_t   sIndex = -1;
    
    TRY_THROW( CheckCursor( aSelf ) == TRUE, RAMP_ERR_INVALID_CURSOR );
    
    if( Py_None == aArgs )
    {
        sCursor->mOutputSize = 0;
    }
    else
    {
        TRY( PyArg_ParseTuple( aArgs,
                               "l|i",
                               &sSize,
                               &sIndex ) == TRUE );
        
        sCursor->mOutputSize      = sSize;
        sCursor->mOutputSizeIndex = sIndex;
    }

    Py_RETURN_NONE;

    CATCH( RAMP_ERR_INVALID_CURSOR )
    {
        PyErr_SetString( ProgrammingError,
                         "Invalid cursor object." );
    }

    FINISH;

    return NULL;
}


static STATUS CursorFetchInternal( Cursor    * aCursor,
                                   PyObject ** aResultRow )
{
    // Internal function to fetch a single row and construct a Row object from it.
    // Used by all of the fetching functions.
    //
    // Returns a Row object if successful.
    // If there are no more rows, zero is returned.
    // If an error occurs, an exception is set and zero is returned.
    // (To differentiate between the last two, use PyErr_Occurred.)

    SQLRETURN     sRet = 0;
    Py_ssize_t    sColumnCount;
    Py_ssize_t    i;
    PyObject   ** sValues = NULL;
    Connection  * sCnxn = GetConnection( aCursor );
    PyObject    * sData = NULL;
    char        * sErrFunc = NULL;
    ColumnInfo  * sColumnInfo;
    
    *aResultRow = NULL;
    
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLFetch( aCursor->mHStmt );
    Py_END_ALLOW_THREADS;

    TRY_THROW( sCnxn->mHDbc != SQL_NULL_HANDLE, RAMP_ERR_CLOSED_CONNECTION );

    TRY_THROW( sRet != SQL_NO_DATA, RAMP_FINISH );

    sErrFunc = "SQLFetch";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    
    sColumnCount = PyTuple_GET_SIZE( aCursor->mDescription );

    sValues = (PyObject**) malloc( sizeof(PyObject*) * sColumnCount  );
    
    TRY_THROW( sValues != NULL, RAMP_ERR_NO_MEMORY );
    
    for( i = 0; i < sColumnCount; i++ )
    {
        sColumnInfo = aCursor->mColumnInfos + i;
        
        if( IsLongVariableType( sColumnInfo->mSqlType ) != TRUE )
        {
            sData = CToPyTypeBySQLType( aCursor,
                                        sColumnInfo->mSqlType,
                                        sColumnInfo->mValue,
                                        sColumnInfo->mColumnSize,
                                        sColumnInfo->mDecimalDigits,
                                        sColumnInfo->mIndicator );
        }
        else
        {
            /**
             * SQLBindCol을 하지 않은 Column을 여기에서 얻음.
             */ 
            TRY( GetData( aCursor,
                          i,
                          &sData ) == SUCCESS );
        }

        if( sData == NULL )
        {
            FreeRowValues( sValues );
            THROW( RAMP_FINISH; );
        }

        sValues[i] = sData;
    }

    *aResultRow = (PyObject*)MakeRowInternal( aCursor->mDescription,
                                              aCursor->mMapNameToIndex,
                                              sColumnCount,
                                              sValues );

    RAMP( RAMP_FINISH );
    
    return SUCCESS;

    
    CATCH( RAMP_ERR_CLOSED_CONNECTION )
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "The cursor's connection was closed." );
    }

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              aCursor->mHStmt );
    }

    CATCH( RAMP_ERR_NO_MEMORY )
    {
        PyErr_NoMemory();
    }
    
    FINISH;

    return FAILURE;
}


static STATUS Cursor_fetchlist( Cursor      * aCursor,
                                Py_ssize_t    aMax,
                                PyObject   ** aRowList )
{
    // aMax
    //   The maximum number of rows to fetch.  If -1, fetch all rows.
    //
    // Returns a list of Rows.  If there are no rows, an empty list is returned.
    PyObject   * sResults;
    PyObject   * sRow;
    Py_ssize_t   sMax = aMax;
    
    *aRowList = NULL;

    sResults = PyList_New(0);
    TRY( sResults != NULL );

    while( sMax == -1 || sMax > 0 )
    {
        TRY( CursorFetchInternal( aCursor,
                                  &sRow ) == SUCCESS );

        if( sRow == NULL )
        {   
            if( PyErr_Occurred() )
            {
                Py_DECREF( sResults );

                TRY( FALSE );
            }
            break;
        }

        (void)PyList_Append( sResults, sRow );
        Py_DECREF( sRow );

        if( sMax != -1 )
        {
            sMax--;
        }
    }

    *aRowList = sResults;
    
    return SUCCESS;

    FINISH;

    return FAILURE;
}


static PyObject * Cursor_iter( PyObject * aSelf )
{
    Py_INCREF( aSelf );

    return aSelf;
}


static PyObject * Cursor_iternext( PyObject * aSelf )
{
    /**
     * Implements the iterator protocol for cursors.
     * Fetches the next row.
     * Returns zero without setting an exception when there are no rows.
     */ 

    PyObject * sRow;
    Cursor   * sCursor = NULL;
    
    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_RESULTS | CURSOR_RAISE_ERROR );
    TRY( sCursor != NULL );

    TRY( CursorFetchInternal( sCursor,
                              &sRow ) == SUCCESS );

    return sRow;

    FINISH;

    return NULL;
}


static char gFetchValDoc[] =
    "fetchval() --> value | None\n" \
    "\n"
    "Returns the first column of the next row in the result set or None\n" \
    "if there are no more rows.";

static PyObject * Cursor_fetchval( PyObject * aSelf,
                                   PyObject * aArgs )
{
    Cursor   * sCursor = NULL;
    PyObject * sRow;
    
    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_RESULTS | CURSOR_RAISE_ERROR );

    TRY( sCursor != NULL );

    TRY( CursorFetchInternal( sCursor,
                              &sRow ) == SUCCESS );

    /**
     * Row가 NULL이고, error가 있다면 NULL 반환. error가 없다면 Py_NONE 반환.
     */
    if( sRow == NULL )
    {
        TRY( !PyErr_Occurred() );
        
        Py_RETURN_NONE;
    }

    return Row_item( sRow, 0 );

    FINISH;

    return NULL;
}

static char gFetchOneDoc[] =
    "fetchone() --> Row | None\n" \
    "\n" \
    "Fetch the next row of a query result set, returning a single Row instance, or\n" \
    "None when no more data is available.\n" \
    "\n" \
    "A ProgrammingError exception is raised if the previous call to execute() did\n" \
    "not produce any result set or no call was issued yet.";

static PyObject * Cursor_fetchone( PyObject * aSelf, PyObject * aArgs )
{
    PyObject * sRow = NULL;
    Cursor   * sCursor = NULL;
    
    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_RESULTS | CURSOR_RAISE_ERROR );
    TRY( sCursor != NULL );

    TRY( CursorFetchInternal( sCursor,
                              &sRow ) == SUCCESS );

    /**
     * Row가 NULL이고, error가 있다면 NULL 반환. error가 없다면 Py_NONE 반환.
     */ 
    if( sRow == NULL )
    {
        TRY( !PyErr_Occurred() );

        Py_RETURN_NONE;
    }

    return sRow;

    FINISH;

    return NULL;
}


static char gFetchAllDoc[] =
    "fetchmany(size=cursor.arraysize) --> list of Rows\n" \
    "\n" \
    "Fetch the next set of rows of a query result, returning a list of Row\n" \
    "instances. An empty list is returned when no more rows are available.\n" \
    "\n" \
    "The number of rows to fetch per call is specified by the parameter.  If it is\n" \
    "not given, the cursor's arraysize determines the number of rows to be\n" \
    "fetched. The method should try to fetch as many rows as indicated by the size\n" \
    "parameter. If this is not possible due to the specified number of rows not\n" \
    "being available, fewer rows may be returned.\n" \
    "\n" \
    "A ProgrammingError exception is raised if the previous call to execute() did\n" \
    "not produce any result set or no call was issued yet.";

static PyObject * Cursor_fetchall( PyObject * aSelf, PyObject * aArgs )
{
    PyObject * sRowList;
    Cursor   * sCursor = NULL;
    
    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_RESULTS | CURSOR_RAISE_ERROR );

    TRY( sCursor != NULL );

    TRY( Cursor_fetchlist( sCursor,
                           -1,
                           &sRowList ) == SUCCESS );

    return sRowList;

    FINISH;

    return NULL;
}


static char gFetchManyDoc[] =
    "fetchmany( [size] ) --> list of Rows\n" \
    "\n" \
    "Fetch all remaining rows of a query result, returning them as a list of Rows.\n" \
    "An empty list is returned if there are no more rows.\n" \
    "\n" \
    "A ProgrammingError exception is raised if the previous call to execute() did\n" \
    "not produce any result set or no call was issued yet.";

static PyObject * Cursor_fetchmany( PyObject * aSelf, PyObject * aArgs )
{
    long       sSize;
    PyObject * sRowList;
    Cursor   * sCursor = NULL;
    
    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_RESULTS | CURSOR_RAISE_ERROR );
    
    TRY( sCursor != NULL );
    
    sSize = sCursor->mArraySize;
    
    TRY( PyArg_ParseTuple( aArgs, "|l", &sSize ) == TRUE );
    
    TRY( Cursor_fetchlist( sCursor,
                           sSize,
                           &sRowList ) == SUCCESS );

    return sRowList;

    FINISH;

    return NULL;
}


static char gTablesDoc[] =
    "C.tables(table=None, catalog=None, schema=None, tableType=None) --> self\n"
    "\n"
    "Executes SQLTables and creates a results set of tables defined in the data\n"
    "source.\n"
    "\n"
    "The table, catalog, and schema interpret the '_' and '%' characters as\n"
    "wildcards.  The escape character is driver specific, so use\n"
    "`Connection.searchescape`.\n"
    "\n"
    "Each row fetched has the following columns:\n"
    " 0) table_cat: The catalog name.\n"
    " 1) table_schem: The schema name.\n"
    " 2) table_name: The table name.\n"
    " 3) table_type: One of 'TABLE', 'VIEW', SYSTEM TABLE', 'GLOBAL TEMPORARY'\n"
    "    'LOCAL TEMPORARY', 'ALIAS', 'SYNONYM', or a data source-specific type name.";

char * Cursor_tables_kwnames[] = { "table", "catalog", "schema", "tableType", 0 };

static PyObject * Cursor_tables( PyObject * aSelf,
                                 PyObject * aArgs,
                                 PyObject * aKeywords )
{
    char        * sCatalog = NULL;
    char        * sSchema = NULL;
    char        * sTableName = NULL;
    char        * sTableType = NULL;
    Cursor      * sCursor = NULL;
    SQLRETURN     sRet = 0;
    SQLSMALLINT   sColumnCount = 0;
    Connection  * sCnxn;
    char        * sErrFunc = NULL;
    
    TRY( PyArg_ParseTupleAndKeywords( aArgs,
                                      aKeywords,
                                      "|zzzz",
                                      Cursor_tables_kwnames,
                                      &sTableName,
                                      &sCatalog,
                                      &sSchema,
                                      &sTableType) == TRUE );

    sCursor =ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN );
    TRY( sCursor != NULL );
    
    TRY( FreeResults( sCursor, FREE_STATEMENT | FREE_PREPARED ) == SUCCESS );

    sCnxn = GetConnection( sCursor );
    
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLTables( sCursor->mHStmt,
                      (SQLCHAR*)sCatalog,
                      SQL_NTS,
                      (SQLCHAR*)sSchema,
                      SQL_NTS,
                      (SQLCHAR*)sTableName,
                      SQL_NTS,
                      (SQLCHAR*)sTableType,
                      SQL_NTS );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLTables";
    TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );
    
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLNumResultCols( sCursor->mHStmt, &sColumnCount );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLNumResultCols";
    TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );

    sCursor->mColumnCount = sColumnCount;
    TRY( PrepareResults( sCursor ) == SUCCESS );

    TRY( CreateNameMap( sCursor, TRUE ) == SUCCESS );

    // Return the cursor so the results can be iterated over directly.
    Py_INCREF( sCursor );

    return (PyObject*)sCursor;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              sCursor->mHStmt );
    }
    
    FINISH;

    return NULL;
}


static char gColumnsDoc[] =
    "C.columns(table=None, catalog=None, schema=None, column=None)\n\n"
    "Creates a results set of column names in specified tables by executing the ODBC SQLColumns function.\n"
    "Each row fetched has the following columns:\n"
    "  0) table_cat\n"
    "  1) table_schem\n"
    "  2) table_name\n"
    "  3) column_name\n"
    "  4) data_type\n"
    "  5) type_name\n"
    "  6) column_size\n"
    "  7) buffer_length\n"
    "  8) decimal_digits\n"
    "  9) num_prec_radix\n"
    " 10) nullable\n"
    " 11) remarks\n"
    " 12) column_def\n"
    " 13) sql_data_type\n"
    " 14) sql_datetime_sub\n"
    " 15) char_octet_length\n"
    " 16) ordinal_position\n"
    " 17) is_nullable";

char * Cursor_column_kwnames[] = { "table", "catalog", "schema", "column", 0 };

static PyObject * Cursor_columns( PyObject * aSelf,
                                  PyObject * aArgs,
                                  PyObject * aKeywords )
{
    char        * sCatalog = NULL;
    char        * sSchema  = NULL;
    char        * sTable   = NULL;
    char        * sColumn  = NULL;
    Cursor      * sCursor = NULL;
    SQLRETURN     sRet = 0;
    SQLSMALLINT   sColumnCount = 0;
    Connection  * sCnxn = NULL;
    char        * sErrFunc = NULL;
    
    TRY( PyArg_ParseTupleAndKeywords( aArgs,
                                      aKeywords,
                                      "|zzzz",
                                      Cursor_column_kwnames,
                                      &sTable,
                                      &sCatalog,
                                      &sSchema,
                                      &sColumn ) == TRUE );
    
    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN );
    sCnxn = GetConnection( sCursor );
    
    TRY( FreeResults( sCursor, FREE_STATEMENT | FREE_PREPARED ) == SUCCESS );

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLColumns( sCursor->mHStmt,
                       (SQLCHAR*)sCatalog,
                       SQL_NTS,
                       (SQLCHAR*)sSchema,
                       SQL_NTS,
                       (SQLCHAR*)sTable,
                       SQL_NTS,
                       (SQLCHAR*)sColumn,
                       SQL_NTS );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLColumns";
    TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );
    
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLNumResultCols( sCursor->mHStmt, &sColumnCount );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLNumResultCols";
    TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );

    sCursor->mColumnCount = sColumnCount;
    TRY( PrepareResults( sCursor ) == SUCCESS );

    TRY( CreateNameMap( sCursor, TRUE ) == SUCCESS );
    
    // Return the cursor so the results can be iterated over directly.
    Py_INCREF( sCursor );
    return (PyObject *)sCursor;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              sCursor->mHStmt );
    }
    
    FINISH;

    return NULL;
}


static char gStatisticsDoc[] =
    "C.statistics(catalog=None, schema=None, unique=False, quick=True) --> self\n\n"
    "Creates a results set of statistics about a single table and the indexes associated with \n"
    "the table by executing SQLStatistics.\n"
    "unique\n"
    "  If True, only unique indexes are retured.  Otherwise all indexes are returned.\n"
    "quick\n"
    "  If True, CARDINALITY and PAGES are returned  only if they are readily available\n"
    "  from the server\n"
    "\n"
    "Each row fetched has the following columns:\n\n"
    "  0) table_cat\n"
    "  1) table_schem\n"
    "  2) table_name\n"
    "  3) non_unique\n"
    "  4) index_qualifier\n"
    "  5) index_name\n"
    "  6) type\n"
    "  7) ordinal_position\n"
    "  8) column_name\n"
    "  9) asc_or_desc\n"
    " 10) cardinality\n"
    " 11) pages\n"
    " 12) filter_condition";

char * Cursor_statistics_kwnames[] = { "table", "catalog", "schema", "unique", "quick", 0 };

static PyObject * Cursor_statistics( PyObject * aSelf,
                                     PyObject * aArgs,
                                     PyObject * aKeywords )
{
    char         * sCatalog = NULL;
    char         * sSchema  = NULL;
    char         * sTable   = NULL;
    PyObject     * sPyUnique = Py_False;
    PyObject     * sPyQuick  = Py_True;
    Cursor       * sCursor = NULL;
    SQLUSMALLINT   sUnique;
    SQLUSMALLINT   sReserved;
    SQLRETURN      sRet = 0;
    SQLSMALLINT    sColumnCount = 0;
    Connection   * sCnxn;
    char         * sErrFunc = NULL;
    
    TRY( PyArg_ParseTupleAndKeywords( aArgs,
                                      aKeywords,
                                      "s|zzOO",
                                      Cursor_statistics_kwnames,
                                      &sTable,
                                      &sCatalog,
                                      &sSchema,
                                      &sPyUnique,
                                      &sPyQuick ) == TRUE );
    
    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN );
    TRY( sCursor != NULL );
    
    sCnxn = GetConnection( sCursor );
    
    TRY( FreeResults( sCursor, FREE_STATEMENT | FREE_PREPARED ) == SUCCESS );

    if( PyObject_IsTrue( sPyUnique ) == TRUE )
    {
        sUnique = (SQLUSMALLINT) SQL_INDEX_UNIQUE;
    }
    else
    {
        sUnique = (SQLUSMALLINT) SQL_INDEX_ALL;
    }

    if( PyObject_IsTrue( sPyQuick ) == TRUE )
    {
        sReserved = SQL_QUICK;
    }
    else
    {
        sReserved = SQL_ENSURE;
    }

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLStatistics( sCursor->mHStmt,
                          (SQLCHAR*)sCatalog,
                          SQL_NTS,
                          (SQLCHAR*)sSchema,
                          SQL_NTS,
                          (SQLCHAR*)sTable,
                          SQL_NTS,
                          sUnique,
                          sReserved );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLStatistics";
    TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLNumResultCols( sCursor->mHStmt, &sColumnCount );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLNumResultCols";
    TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );

    sCursor->mColumnCount = sColumnCount;
    TRY( PrepareResults( sCursor ) == SUCCESS );
    
    TRY( CreateNameMap( sCursor, TRUE ) == SUCCESS );

    // Return the cursor so the results can be iterated over directly.
    Py_INCREF(sCursor);
    return (PyObject *)sCursor;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              sCursor->mHStmt );
    }

    FINISH;

    return NULL;
}


static char gRowIdColumnsDoc[] =
    "C.rowIdColumns(table, catalog=None, schema=None, nullable=True) -->\n\n"
    "Executes SQLSpecialColumns with SQL_BEST_ROWID which creates a result set of columns that\n"
    "uniquely identify a row\n\n"
    "Each row fetched has the following columns:\n"
    " 0) scope\n"
    " 1) column_name\n"
    " 2) data_type\n"
    " 3) type_name\n"
    " 4) column_size\n"
    " 5) buffer_length\n"
    " 6) decimal_digits\n"
    " 7) pseudo_column";

static char gRowVerColumnsDoc[] =
    "C.rowVerColumns(table, catalog=None, schema=None, nullable=True) --> self\n\n"
    "Executes SQLSpecialColumns with SQL_ROWVER which creates a result set of columns that\n"
    "are automatically updated when any value in the row is updated.\n\n"
    "Each row fetched has the following columns:\n"
    " 0) scope\n"
    " 1) column_name\n"
    " 2) data_type\n"
    " 3) type_name\n"
    " 4) column_size\n"
    " 5) buffer_length\n"
    " 6) decimal_digits\n"
    " 7) pseudo_column";

char * Cursor_specialColumn_kwnames[] = { "table", "catalog", "schema", "nullable", 0 };

static PyObject * GetSpecialColumns( PyObject     * aSelf,
                                     PyObject     * aArgs,
                                     PyObject     * aKeywords,
                                     SQLUSMALLINT   aIdType )
{
    char         * sTable   = NULL;
    char         * sCatalog = NULL;
    char         * sSchema  = NULL;
    PyObject     * sPyNullable = Py_True;
    Cursor       * sCursor = NULL;
    SQLRETURN      sRet = 0;
    SQLUSMALLINT   sNullable;
    SQLSMALLINT    sColumnCount = 0;
    Connection   * sCnxn;
    char         * sErrFunc = NULL;
    
    TRY( PyArg_ParseTupleAndKeywords( aArgs,
                                      aKeywords,
                                      "s|zzO",
                                      Cursor_specialColumn_kwnames,
                                      &sTable,
                                      &sCatalog,
                                      &sSchema,
                                      &sPyNullable ) == TRUE );

    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN);
    TRY( sCursor != NULL );
    
    sCnxn = GetConnection( sCursor );

    TRY( FreeResults( sCursor, FREE_STATEMENT | FREE_PREPARED ) == SUCCESS );

    if( PyObject_IsTrue( sPyNullable ) == TRUE )
    {
        sNullable = (SQLUSMALLINT) SQL_NULLABLE;
    }
    else
    {
        sNullable = (SQLUSMALLINT) SQL_NO_NULLS;
    }

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLSpecialColumns( sCursor->mHStmt,
                              aIdType,
                              (SQLCHAR*)sCatalog,
                              SQL_NTS,
                              (SQLCHAR*)sSchema,
                              SQL_NTS,
                              (SQLCHAR*)sTable,
                              SQL_NTS,
                              SQL_SCOPE_TRANSACTION,
                              sNullable );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLSpecialColumns";
    TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLNumResultCols( sCursor->mHStmt, &sColumnCount );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLNumResultCols";
    TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );

    sCursor->mColumnCount = sColumnCount;
    TRY( PrepareResults( sCursor ) == SUCCESS );

    TRY( CreateNameMap( sCursor, TRUE ) == SUCCESS );

    // Return the cursor so the results can be iterated over directly.
    Py_INCREF( sCursor );
    return (PyObject *) sCursor;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              sCursor->mHStmt );
    }
    
    FINISH;

    return NULL;
}


static PyObject * Cursor_rowIdColumns( PyObject * aSelf,
                                       PyObject * aArgs,
                                       PyObject * aKeywords )
{
    return GetSpecialColumns( aSelf, aArgs, aKeywords, SQL_BEST_ROWID );
}


static PyObject * Cursor_rowVerColumns( PyObject * aSelf,
                                        PyObject * aArgs,
                                        PyObject * aKeywords )
{
    return GetSpecialColumns( aSelf, aArgs, aKeywords, SQL_ROWVER );
}


static char gPrimaryKeysDoc[] =
    "C.primaryKeys(table, catalog=None, schema=None) --> self\n\n"
    "Creates a results set of column names that make up the primary key for a table\n"
    "by executing the SQLPrimaryKeys function.\n"
    "Each row fetched has the following columns:\n"
    " 0) table_cat\n"
    " 1) table_schem\n"
    " 2) table_name\n"
    " 3) column_name\n"
    " 4) key_seq\n"
    " 5) pk_name";

char* Cursor_primaryKeys_kwnames[] = { "table", "catalog", "schema", 0 };

static PyObject * Cursor_primaryKeys( PyObject * aSelf,
                                      PyObject * aArgs,
                                      PyObject * aKeywords)
{
    char        * sTable = NULL;
    char        * sCatalog = NULL;
    char        * sSchema  = NULL;
    Cursor      * sCursor = NULL;
    SQLRETURN     sRet = 0;
    SQLSMALLINT   sColumnCount = 0;
    Connection  * sCnxn;
    char        * sErrFunc = NULL;
    
    TRY( PyArg_ParseTupleAndKeywords( aArgs,
                                      aKeywords,
                                      "s|zz",
                                      Cursor_primaryKeys_kwnames,
                                      &sTable,
                                      &sCatalog,
                                      &sSchema ) == TRUE );

    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN );
    TRY( sCursor != NULL );
    
    sCnxn = GetConnection( sCursor );

    TRY( FreeResults( sCursor, FREE_STATEMENT | FREE_PREPARED ) == SUCCESS );

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLPrimaryKeys( sCursor->mHStmt,
                           (SQLCHAR*)sCatalog,
                           SQL_NTS,
                           (SQLCHAR*)sSchema,
                           SQL_NTS,
                           (SQLCHAR*)sTable,
                           SQL_NTS );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLPrimaryKeys";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLNumResultCols( sCursor->mHStmt, &sColumnCount );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLNumResultCols";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    sCursor->mColumnCount = sColumnCount;
    TRY( PrepareResults( sCursor ) == SUCCESS );
    
    TRY( CreateNameMap( sCursor, TRUE ) == SUCCESS );

    // Return the cursor so the results can be iterated over directly.
    Py_INCREF( sCursor );
    return (PyObject *)sCursor;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              sCursor->mHStmt );
    }
    
    FINISH;

    return NULL;
}


static char gForeignKeysDoc[] =
    "C.foreignKeys(table=None, catalog=None, schema=None,\n"
    "            foreignTable=None, foreignCatalog=None, foreignSchema=None) --> self\n\n"
    "Executes the SQLForeignKeys function and creates a results set of column names\n"
    "that are foreign keys in the specified table (columns in the specified table\n"
    "that refer to primary keys in other tables) or foreign keys in other tables\n"
    "that refer to the primary key in the specified table.\n\n"
    "Each row fetched has the following columns:\n"
    "  0) pktable_cat\n"
    "  1) pktable_schem\n"
    "  2) pktable_name\n"
    "  3) pkcolumn_name\n"
    "  4) fktable_cat\n"
    "  5) fktable_schem\n"
    "  6) fktable_name\n"
    "  7) fkcolumn_name\n"
    "  8) key_seq\n"
    "  9) update_rule\n"
    " 10) delete_rule\n"
    " 11) fk_name\n"
    " 12) pk_name\n"
    " 13) deferrability";

char * Cursor_foreignKeys_kwnames[] = { "table", "catalog", "schema", "foreignTable", "foreignCatalog", "foreignSchema", 0 };

static PyObject * Cursor_foreignKeys( PyObject * aSelf,
                                      PyObject * aArgs,
                                      PyObject * aKeywords )
{
    char        * sTable          = NULL;
    char        * sCatalog        = NULL;
    char        * sSchema         = NULL;
    char        * sForeignTable   = NULL;
    char        * sForeignCatalog = NULL;
    char        * sForeignSchema  = NULL;
    Cursor      * sCursor = NULL;
    SQLRETURN     sRet = 0;
    SQLSMALLINT   sColumnCount = 0;
    Connection  * sCnxn;
    char        * sErrFunc = NULL;
    
    TRY( PyArg_ParseTupleAndKeywords( aArgs,
                                      aKeywords,
                                      "|zzzzzz",
                                      Cursor_foreignKeys_kwnames,
                                      &sTable,
                                      &sCatalog,
                                      &sSchema,
                                      &sForeignTable,
                                      &sForeignCatalog,
                                      &sForeignSchema ) == TRUE );

    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN );
    TRY( sCursor != NULL );
    
    sCnxn = GetConnection( sCursor );

    TRY( FreeResults( sCursor, FREE_STATEMENT | FREE_PREPARED ) == SUCCESS );

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLForeignKeys( sCursor->mHStmt,
                           (SQLCHAR*)sCatalog,
                           SQL_NTS,
                           (SQLCHAR*)sSchema,
                           SQL_NTS,
                           (SQLCHAR*)sTable,
                           SQL_NTS,
                           (SQLCHAR*)sForeignCatalog,
                           SQL_NTS,
                           (SQLCHAR*)sForeignSchema,
                           SQL_NTS,
                           (SQLCHAR*)sForeignTable,
                           SQL_NTS );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLForeignKeys";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );    

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLNumResultCols( sCursor->mHStmt, &sColumnCount );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLNumResultCols";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    sCursor->mColumnCount = sColumnCount;
    TRY( PrepareResults( sCursor ) == SUCCESS );

    TRY( CreateNameMap( sCursor, TRUE ) == SUCCESS );

    // Return the cursor so the results can be iterated over directly.
    Py_INCREF( sCursor );
    return (PyObject *)sCursor;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              sCursor->mHStmt );
    }

    FINISH;

    return NULL;
}

static char gGetTypeInfoDoc[] =
    "C.getTypeInfo(sqlType=None) --> self\n\n"
    "Executes SQLGetTypeInfo a creates a result set with information about the\n"
    "specified data type or all data types supported by the ODBC driver if not\n"
    "specified.\n\n"
    "Each row fetched has the following columns:\n"
    " 0) type_name\n"
    " 1) data_type\n"
    " 2) column_size\n"
    " 3) literal_prefix\n"
    " 4) literal_suffix\n"
    " 5) create_params\n"
    " 6) nullable\n"
    " 7) case_sensitive\n"
    " 8) searchable\n"
    " 9) unsigned_attribute\n"
    "10) fixed_prec_scale\n"
    "11) auto_unique_value\n"
    "12) local_type_name\n"
    "13) minimum_scale\n"
    "14) maximum_scale\n"
    "15) sql_data_type\n"
    "16) sql_datetime_sub\n"
    "17) num_prec_radix\n"
    "18) interval_precision";

static PyObject * Cursor_getTypeInfo( PyObject * aSelf,
                                      PyObject * aArgs,
                                      PyObject * aKeywords )
{
    SQLSMALLINT   sDataType = SQL_ALL_TYPES;
    Cursor      * sCursor = NULL;
    SQLRETURN     sRet = 0;
    SQLSMALLINT   sColumnCount = 0;
    Connection  * sCnxn;
    char        * sErrFunc = NULL;
    
    TRY( PyArg_ParseTuple( aArgs, "|i", &sDataType ) == TRUE );

    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN );
    TRY( sCursor != NULL );
    
    sCnxn = GetConnection( sCursor );
    
    TRY( FreeResults( sCursor, FREE_STATEMENT | FREE_PREPARED ) == SUCCESS );

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLGetTypeInfo( sCursor->mHStmt, sDataType );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLGetTypeInfo";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLNumResultCols( sCursor->mHStmt, &sColumnCount );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLNumResultCols";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    sCursor->mColumnCount = sColumnCount;
    TRY( PrepareResults( sCursor ) == SUCCESS );

    TRY( CreateNameMap( sCursor, TRUE ) == SUCCESS );

    // Return the cursor so the results can be iterated over directly.
    Py_INCREF( sCursor );
    return (PyObject *)sCursor;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              sCursor->mHStmt );
    }
    
    FINISH;

    return NULL;
}

static char gNextSetDoc[] = "nextset() --> True | None\n" \
    "\n" \
    "Jumps to the next resultset if the last sql has multiple resultset." \
    "Returns True if there is a next resultset otherwise None.";
static PyObject * Cursor_nextset( PyObject * aSelf,
                                  PyObject * aArgs )
{
    Cursor      * sCursor = NULL;
    SQLRETURN     sRet = 0;
    SQLSMALLINT   sColumnCount = 0;
    SQLLEN        sRowCount;
    Connection  * sCnxn;
    PyObject    * sError = NULL;
    char        * sErrFunc = NULL;
    
    sCursor = ValidateCursor( aSelf, 0);
    
    TRY( sCursor != NULL );

    sCursor->mRowCount = -1;
    
    sCnxn = GetConnection( sCursor );
    
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLMoreResults( sCursor->mHStmt );
    Py_END_ALLOW_THREADS;

    if( sRet == SQL_NO_DATA )
    {
        FreeResults( sCursor, FREE_STATEMENT | KEEP_PREPARED );
        Py_RETURN_FALSE;
    }

    if( !SQL_SUCCEEDED( sRet ) )
    {
        sError = GetErrorFromHandle( sCnxn,
                                     "SQLMoreResults",
                                     sCnxn->mHDbc,
                                     sCursor->mHStmt );

        /**
         * FreeResults must be run after the error has been collected
         * from the cursor as it's lost otherwise.
         * If FreeResults raises an error (eg a lost connection) report that instead.
         */
        TRY( FreeResults( sCursor, FREE_STATEMENT | KEEP_PREPARED ) == SUCCESS );

        TRY_THROW( sError == NULL, RAMP_ERR_RAISE_ERROR );

        /**
         * 여기에 어떻게 올 수 있는지 모름..
         * error가 없이 error state가 발생. nextset이 없는 것으로 간주한다.
         */ 
        Py_RETURN_FALSE;
    }
    
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLNumResultCols( sCursor->mHStmt, &sColumnCount );
    Py_END_ALLOW_THREADS;

    if( !SQL_SUCCEEDED( sRet ) )
    {
        sError = GetErrorFromHandle( sCnxn,
                                     "SQLNumResultCols",
                                     sCnxn->mHDbc,
                                     sCursor->mHStmt );

        FreeResults( sCursor, FREE_STATEMENT | KEEP_PREPARED );
        return sError;
    }

    FreeResults( sCursor, KEEP_STATEMENT | KEEP_PREPARED );

    sCursor->mColumnCount = sColumnCount;
    if( sColumnCount != 0) 
    {
        // A result set was created.
        TRY( PrepareResults( sCursor ) == SUCCESS );

        TRY( CreateNameMap( sCursor, IsLowerCase() ) == SUCCESS );
    }

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLRowCount( sCursor->mHStmt, &sRowCount );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLRowCount";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    sCursor->mRowCount = (int)sRowCount;
    
    Py_RETURN_TRUE;

    CATCH( RAMP_ERR_RAISE_ERROR )
    {
        RaiseErrorFromException( sError );
        Py_DECREF( sError );
    }
 
    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              sCursor->mHStmt );
    }
    
    FINISH;

    return NULL;
}


static char gProcedureColumnsDoc[] =
    "C.procedureColumns(procedure=None, catalog=None, schema=None) --> self\n\n"
    "Executes SQLProcedureColumns and creates a result set of information\n"
    "about stored procedure columns and results.\n"
    "  0) procedure_cat\n"
    "  1) procedure_schem\n"
    "  2) procedure_name\n"
    "  3) column_name\n"
    "  4) column_type\n"
    "  5) data_type\n"
    "  6) type_name\n"
    "  7) column_size\n"
    "  8) buffer_length\n"
    "  9) decimal_digits\n"
    " 10) num_prec_radix\n"
    " 11) nullable\n"
    " 12) remarks\n"
    " 13) column_def\n"
    " 14) sql_data_type\n"
    " 15) sql_datetime_sub\n"
    " 16) char_octet_length\n"
    " 17) ordinal_position\n"
    " 18) is_nullable";

char* Cursor_procedureColumns_kwnames[] = { "procedure", "catalog", "schema", 0 };

static PyObject * Cursor_procedureColumns( PyObject * aSelf,
                                           PyObject * aArgs,
                                           PyObject * aKeywords )
{
    char        * sProcedure = NULL;
    char        * sCatalog   = NULL;
    char        * sSchema    = NULL;
    Cursor      * sCursor = NULL;
    SQLRETURN     sRet = 0;
    SQLSMALLINT   sColumnCount = 0;
    Connection  * sCnxn;
    char        * sErrFunc = NULL;
    
    TRY( PyArg_ParseTupleAndKeywords( aArgs,
                                      aKeywords,
                                      "|zzz",
                                      Cursor_procedureColumns_kwnames,
                                      &sProcedure,
                                      &sCatalog,
                                      &sSchema ) == TRUE );

    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN );

    TRY( sCursor != NULL );
    
    sCnxn = GetConnection( sCursor );

    TRY( FreeResults( sCursor, FREE_STATEMENT | FREE_PREPARED ) == SUCCESS );

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLProcedureColumns( sCursor->mHStmt,
                                (SQLCHAR*)sCatalog,
                                SQL_NTS,
                                (SQLCHAR*)sSchema,
                                SQL_NTS,
                                (SQLCHAR*)sProcedure,
                                SQL_NTS,
                                0,
                                0 );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLProcedureColumns";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLNumResultCols( sCursor->mHStmt, &sColumnCount );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLNumResultCols";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    sCursor->mColumnCount = sColumnCount;
    TRY( PrepareResults( sCursor ) == SUCCESS );

    TRY( CreateNameMap( sCursor, TRUE ) == SUCCESS );

    // Return the cursor so the results can be iterated over directly.
    Py_INCREF( sCursor);
    return (PyObject *) sCursor;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              sCursor->mHStmt );
    }
    
    FINISH;

    return NULL;
}


static char gProceduresDoc[] =
    "C.procedures(procedure=None, catalog=None, schema=None) --> self\n\n"
    "Executes SQLProcedures and creates a result set of information about the\n"
    "procedures in the data source.\n"
    "Each row fetched has the following columns:\n"
    " 0) procedure_cat\n"
    " 1) procedure_schem\n"
    " 2) procedure_name\n"
    " 3) num_input_params\n"
    " 4) num_output_params\n"
    " 5) num_result_sets\n"
    " 6) remarks\n"
    " 7) procedure_type";

char* Cursor_procedures_kwnames[] = { "procedure", "catalog", "schema", 0 };

static PyObject * Cursor_procedures( PyObject * aSelf,
                                     PyObject * aArgs,
                                     PyObject * aKeywords )
{
    char        * sProcedure = NULL;
    char        * sCatalog   = NULL;
    char        * sSchema    = NULL;
    Cursor      * sCursor = NULL;
    SQLRETURN     sRet = 0;
    SQLSMALLINT   sColumnCount = 0;
    Connection  * sCnxn;
    char        * sErrFunc = NULL;
    
    TRY( PyArg_ParseTupleAndKeywords( aArgs,
                                      aKeywords,
                                      "|zzz",
                                      Cursor_procedures_kwnames,
                                      &sProcedure,
                                      &sCatalog,
                                      &sSchema ) == TRUE );

    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN );
    sCnxn = GetConnection( sCursor );

    TRY( FreeResults( sCursor,
                      FREE_STATEMENT | FREE_PREPARED ) == SUCCESS );

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLProcedures( sCursor->mHStmt,
                          (SQLCHAR*)sCatalog,
                          SQL_NTS,
                          (SQLCHAR*)sSchema,
                          SQL_NTS,
                          (SQLCHAR*)sProcedure,
                          SQL_NTS );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLProcedures";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLNumResultCols( sCursor->mHStmt, &sColumnCount );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLNumResultCols";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    sCursor->mColumnCount = sColumnCount;
    TRY( PrepareResults( sCursor ) == SUCCESS );

    TRY( CreateNameMap( sCursor, TRUE ) == SUCCESS );

    // Return the cursor so the results can be iterated over directly.
    Py_INCREF( sCursor );
    return (PyObject *) sCursor;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              sCursor->mHStmt );
    }
    
    FINISH;

    return NULL;
}

static char gSkipDoc[] =
    "skip(count) --> None\n" \
    "\n" \
    "Skips the next `count` records by calling SQLFetchScroll with SQL_FETCH_NEXT.\n"
    "For convenience, skip(0) is accepted and will do nothing.";

static PyObject * Cursor_skip( PyObject * aSelf,
                               PyObject * aArgs )
{
    Cursor     * sCursor = NULL;
    int          sCount;
    SQLRETURN    sRet = 0;
    int          i = 0;
    Connection * sCnxn;
    
    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_RESULTS | CURSOR_RAISE_ERROR);
    
    TRY( sCursor != NULL );
    
    sCnxn = GetConnection( sCursor );
    
    TRY( PyArg_ParseTuple( aArgs, "i", &sCount ) == TRUE );

    if( sCount == 0 )
    {
        Py_RETURN_NONE;
    }

    // Note: I'm not sure about the performance implications of looping here
    // -- I certainly would rather use SQLFetchScroll(SQL_FETCH_RELATIVE, count),
    // but it requires scrollable cursors which are often slower.
    // I would not expect skip to be used in performance intensive code
    // since different SQL would probably be the "right" answer instead of skip anyway.

    Py_BEGIN_ALLOW_THREADS;
    for( i = 0; i < sCount; i++)
    {
        sRet = GDLFetchScroll( sCursor->mHStmt, SQL_FETCH_NEXT, 0 );
        if( !SQL_SUCCEEDED( sRet ) )
        {
            break;
        }
    }
    Py_END_ALLOW_THREADS;

    TRY_THROW( SQL_SUCCEEDED( sRet ) || (sRet == SQL_NO_DATA), RAMP_ERR_SQLFUNCTION );
    
    Py_RETURN_NONE;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              "SQLFetchScroll",
                              sCnxn->mHDbc,
                              sCursor->mHStmt );
    }
    
    FINISH;

    return NULL;
}

static char gCommitDoc[] =
    "Commits any pending transaction to the database on the current connection,\n"
    "including those from other cursors.\n";

static PyObject * Cursor_commit( PyObject * aSelf,
                                 PyObject * aArgs )
{
    Cursor     * sCursor = NULL;
    Connection * sCnxn;

    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN | CURSOR_RAISE_ERROR );

    TRY( sCursor != NULL );

    sCnxn = GetConnection( sCursor );

    return (PyObject*)Connection_endtrans( sCnxn, SQL_COMMIT );

    FINISH;

    return NULL;
}

static char gRollbackDoc[] =
    "Rolls back any pending transaction to the database on the current connection,\n"
    "including those from other cursors.\n";

static PyObject * Cursor_rollback( PyObject * aSelf,
                                   PyObject * aArgs )
{
    Cursor     * sCursor = NULL;
    Connection * sCnxn;

    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN | CURSOR_RAISE_ERROR );

    TRY( sCursor != NULL );

    sCnxn = GetConnection( sCursor );
    
    return (PyObject*)Connection_endtrans( sCnxn, SQL_ROLLBACK );

    FINISH;

    return NULL;
}

static char gCancelDoc[] =
    "Cursor.cancel() -> None\n"
    "Cancels the processing of the current statement.\n"
    "\n"
    "Cancels the processing of the current statement.\n"
    "\n"
    "This calls SQLCancel and is designed to be called from another thread to"
    "stop processing of an ongoing query.";

static PyObject * Cursor_cancel( PyObject * aSelf,
                                 PyObject * aArgs )
{
    SQLRETURN    sRet;
    Connection * sCnxn;
    Cursor     * sCursor = NULL;

    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN | CURSOR_RAISE_ERROR );
    
    TRY( sCursor != NULL );

    sCnxn = GetConnection( sCursor );
    
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLCancel( sCursor->mHStmt );
    Py_END_ALLOW_THREADS;

    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    Py_RETURN_NONE;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              "SQLCancel",
                              sCnxn->mHDbc,
                              sCursor->mHStmt );
    }
    
    FINISH;

    return NULL;
}


static char gEnterDoc[] = "__enter__() -> self.";
static PyObject * Cursor_enter( PyObject * aSelf,
                                PyObject * aArgs )
{
    Py_INCREF( aSelf );
    return aSelf;
}

static char gExitDoc[] = "__exit__(*excinfo) -> None.  Commits the connection if necessary..";
static PyObject * Cursor_exit( PyObject * aSelf,
                               PyObject * aArgs )
{
    Connection * sCnxn;
    Cursor     * sCursor = NULL;
    SQLRETURN       sRet;

    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN | CURSOR_RAISE_ERROR);

    TRY( sCursor != NULL );

    sCnxn = GetConnection( sCursor );
    
    /**
     * If an error has occurred, `args` will be a tuple of 3 values.
     * Otherwise it will be a tuple of 3 `None`s.
     */ 
    DASSERT( PyTuple_Check( aArgs ) == TRUE );

    if( (sCnxn->mAutoCommit == SQL_AUTOCOMMIT_OFF) && (PyTuple_GetItem(aArgs, 0) == Py_None) )
    {

        Py_BEGIN_ALLOW_THREADS;
        sRet = GDLEndTran( SQL_HANDLE_DBC,
                           sCnxn->mHDbc,
                           SQL_COMMIT );
        Py_END_ALLOW_THREADS;

        TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    }

    Py_RETURN_NONE;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              "SQLEndTran(SQL_COMMIT)",
                              sCnxn->mHDbc,
                              sCursor->mHStmt );
    }
    
    FINISH;

    return NULL;
}

static STATUS GetPsmParamInfo( Cursor       * aCursor,
                               char         * aProcName,
                               Py_ssize_t     aCount,
                               PsmParamInfo * aPsmParamInfo,
                               PsmParamInfo * aReturnParamInfo )
{
    Connection * sCnxn = GetConnection( aCursor );
    char       * sTmp;
    char       * sSchema = NULL;
    char       * sName = NULL;
    SQLRETURN    sRet = SQL_ERROR;
    char       * sPos;
    int          sState = 0;
    char       * sErrFunc = NULL;
    Py_ssize_t   i = 0;
    SQLSMALLINT  sColumnType;
    SQLSMALLINT  sDataType;
    SQLINTEGER   sColumnSize;
    SQLINTEGER   sBufferLength;
    SQLSMALLINT  sDecimalDigits;
    SQLINTEGER   sOrdinaryPosition;
    SQLLEN       sColumnTypeInd;
    SQLLEN       sDataTypeInd;
    SQLLEN       sColumnSizeInd;
    SQLLEN       sBufferLengthInd;
    SQLLEN       sDecimalDigitsInd;
    SQLLEN       sOrdinaryPositionInd;
    SQLHSTMT     sStmt;
    
    sTmp = (char*)malloc( strlen( aProcName ) + 1 );
    sState = 1;
    
    strncpy( sTmp, aProcName, strlen( aProcName ) + 1 );
    
    sPos = strchr( sTmp, '.' );

    if( sPos == NULL )
    {
        sName = sTmp;
    }
    else
    {
        *sPos = '\0';
        sSchema = sTmp;
        sName = sPos + 1;
    }

    sRet = GDLAllocHandle( SQL_HANDLE_STMT,
                           sCnxn->mHDbc,
                           &sStmt );

    sErrFunc = "SQLAllocHandle";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    sState = 2;
    
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLProcedureColumns( sStmt,
                                NULL, /* catalog name */
                                0,
                                (SQLCHAR*)sSchema,
                                SQL_NTS,
                                (SQLCHAR*)sName,
                                SQL_NTS,
                                NULL, /* COLUMN NAME */
                                0 );
    Py_END_ALLOW_THREADS;

    sErrFunc = "SQLProcedureColumns";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    sErrFunc = "SQLBindCol";
    
    sRet = GDLBindCol( sStmt,
                       5,
                       SQL_C_SSHORT,
                       &sColumnType,
                       sizeof( sColumnType ),
                       &sColumnTypeInd );
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    
    sRet = GDLBindCol( sStmt,
                       6,
                       SQL_C_SSHORT,
                       &sDataType,
                       sizeof( sDataType ),
                       &sDataTypeInd );
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    
    sRet = GDLBindCol( sStmt,
                       8,
                       SQL_C_SLONG,
                       &sColumnSize,
                       sizeof( sColumnSize ),
                       &sColumnSizeInd );
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    
    sRet = GDLBindCol( sStmt,
                       9,
                       SQL_C_SLONG,
                       &sBufferLength,
                       sizeof( sBufferLength ),
                       &sBufferLengthInd );
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    
    sRet = GDLBindCol( sStmt,
                       10,
                       SQL_C_SSHORT,
                       &sDecimalDigits,
                       sizeof( sDecimalDigits ),
                       &sDecimalDigitsInd );
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    sRet = GDLBindCol( sStmt,
                       18,
                       SQL_C_SLONG,
                       &sOrdinaryPosition,
                       sizeof( sOrdinaryPosition ),
                       &sOrdinaryPositionInd );
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    sErrFunc = "SQLFetch";
    while( TRUE )
    {
        sRet = GDLFetch( sStmt );

        if( sRet == SQL_NO_DATA )
        {
            break;
        }

        TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

        if( sOrdinaryPosition == 0 )
        {
            if( aReturnParamInfo != NULL )
            {
                aReturnParamInfo->mColumnType = sColumnType;
                aReturnParamInfo->mDataType  = sDataType;
                aReturnParamInfo->mColumnSize = sColumnSize;
                aReturnParamInfo->mBufferLength = MAX( sColumnSize, sBufferLength ) + 2; // + null
                aReturnParamInfo->mDecimalDigits = sDecimalDigits;
            }
        }
        else
        {
            if( i < aCount )
            {
                aPsmParamInfo[i].mColumnType = sColumnType;
                aPsmParamInfo[i].mDataType  = sDataType;
                aPsmParamInfo[i].mColumnSize = sColumnSize;
                aPsmParamInfo[i].mBufferLength = MAX( sColumnSize, sBufferLength ) + 2; // + null
                aPsmParamInfo[i].mDecimalDigits = sDecimalDigits;
            }
            i++;
        }
    }

    sRet = GDLCloseCursor( sStmt );
    sErrFunc = "SQLCloseCursor";
    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    sState = 1;
    sRet = GDLFreeHandle( SQL_HANDLE_STMT, sStmt );
    
    sState = 0;
    free( sTmp );

    return SUCCESS;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              sErrFunc,
                              sCnxn->mHDbc,
                              sStmt );
    }

    FINISH;

    switch( sState )
    {
        case 2:
            GDLFreeHandle( SQL_HANDLE_STMT, sStmt );
        case 1:
            free( sTmp );
        default:
            break;
    }
    
    return FAILURE;
}

static PyObject * MakeCallPsmString( char       * aName,
                                     bool         aIsFunction,
                                     Py_ssize_t   aCount )
{
    Py_ssize_t   sLength = 0;
    PyObject   * sResult = NULL;
    char       * sBuffer = NULL;
    Py_ssize_t   i;

    // procedure CALL name (?,?)
    // function {? = CALL name (?,?)}
    // length = default len + name len + (param count * 2)
    sLength = strlen( aName ) + (aCount * 2) + PROCEDURE_DEFAULT_LENGTH;

    sBuffer = (char*)malloc( sLength );

    if( aIsFunction == TRUE )
    {
        snprintf( sBuffer,
                  sLength,
                  "{?=CALL %s(",
                  aName );
    }
    else
    {
        snprintf( sBuffer,
                  sLength,
                  "CALL %s(",
                  aName );
    }
    
    for( i = 0; i < aCount; i++ )
    {
        if( (i + 1) == aCount )
        {
            strncat( sBuffer, "?", sLength );
        }
        else
        {
            strncat( sBuffer, "?,", sLength );
        }
    }

    if( aIsFunction == TRUE )
    {
        strncat( sBuffer, ")}", sLength );
    }
    else
    {
        strncat( sBuffer, ")", sLength );
    }

    sResult = PyUnicode_FromStringAndSize( sBuffer, strlen( sBuffer ) );
    TRY( sResult != NULL );

    free( sBuffer );

    return sResult;
    
    FINISH;

    if( sBuffer != NULL )
    {
        free( sBuffer );
    }
    
    return NULL;
}


static STATUS AllocOutParamBuffer( Cursor     * aCursor,
                                   Py_ssize_t   aIndex,
                                   ParamInfo  * aParamInfo )
{
    /**
     * Parameter type is long variable type, Output size is set and
     * Output size index is -1 or set.
     *
     */
    if( (IsLongVariableType( aParamInfo->mParameterType ) == TRUE) &&
        (aCursor->mOutputSize != 0) &&
        ((aCursor->mOutputSizeIndex == -1) ||
         (aCursor->mOutputSizeIndex == (aIndex + 1))))
    {
        aParamInfo->mBufferLength = aCursor->mOutputSize;
    }

    aParamInfo->mData.mBuffer = malloc( aParamInfo->mBufferLength );
    TRY_THROW( aParamInfo->mData.mBuffer != NULL, RAMP_ERR_NO_MEMORY );

    aParamInfo->mValueAllocated = TRUE;
    aParamInfo->mParameterValuePtr = aParamInfo->mData.mBuffer;
    
    return SUCCESS;

    CATCH( RAMP_ERR_NO_MEMORY )
    {
        PyErr_NoMemory();
    }

    FINISH;

    return FAILURE;
}


static STATUS CallProcedure( Cursor    * aCursor,
                             char      * aProcName,
                             PyObject  * aParamSeq,
                             PyObject ** aOutParam )
{
    Connection   * sCnxn;
    PyObject     * sSql;
    Py_ssize_t     sCount = 0; 
    ParamInfo    * sParamInfos;
    PyObject     * sParam = NULL;
    int            sState = 0;
    SQLRETURN      sRet = 0;
    Py_ssize_t     i;
    PsmParamInfo * sPsmParamInfo = NULL;
    
    sCnxn = GetConnection( aCursor );

    if( aParamSeq != NULL )
    {
        sCount = PySequence_Fast_GET_SIZE( aParamSeq );
        sPsmParamInfo = (PsmParamInfo*)malloc( sCount * sizeof( PsmParamInfo ) );
        TRY_THROW( sPsmParamInfo != NULL, RAMP_ERR_NO_MEMORY );
        memset( sPsmParamInfo, 0x00, sCount * sizeof( PsmParamInfo ) );
    }
    sState = 1;
    
    TRY( GetPsmParamInfo( aCursor,
                          aProcName,
                          sCount,
                          sPsmParamInfo,
                          NULL ) == SUCCESS );
    
    //make string
    sSql = MakeCallPsmString( aProcName, FALSE, sCount );
    
    //prepare
    TRY( Prepare( aCursor, sSql ) == SUCCESS );

    if( aCursor->mParamInfos == NULL )
    {
        aCursor->mParamInfos = (ParamInfo*)malloc( sizeof( ParamInfo ) * sCount );
        TRY_THROW( aCursor->mParamInfos != NULL, RAMP_ERR_NO_MEMORY );
        memset( aCursor->mParamInfos, 0x00, sizeof( ParamInfo ) * sCount );
    }
    sState = 2;
    
    sParamInfos = aCursor->mParamInfos;
    for( i = 0; i < aCursor->mParamCount; i++ )
    {
        sParam = PySequence_GetItem( aParamSeq, i );

        if( sPsmParamInfo[i].mColumnType == SQL_PARAM_INPUT )
        {
            TRY( GetParameterInfo( aCursor,
                                   i,
                                   sParam,
                                   &sParamInfos[i] ) == TRUE );
        }
        else
        {
            sParamInfos[i].mParameterType = sPsmParamInfo[i].mDataType;
            sParamInfos[i].mColumnSize = sPsmParamInfo[i].mColumnSize;
            sParamInfos[i].mDecimalDigits = sPsmParamInfo[i].mDecimalDigits;
            sParamInfos[i].mBufferLength = sPsmParamInfo[i].mBufferLength;

            TRY( AllocOutParamBuffer( aCursor,
                                      i,
                                      &sParamInfos[i] ) == SUCCESS );
            
            if( sPsmParamInfo[i].mColumnType == SQL_PARAM_INPUT_OUTPUT )
            {
                TRY( GetInOutParameterData( aCursor,
                                            i,
                                            sParam,
                                            &sParamInfos[i] ) == SUCCESS );
            }
            else
            {
                if( (sParamInfos[i].mParameterType == SQL_DECIMAL) ||
                    (sParamInfos[i].mParameterType == SQL_NUMERIC) )
                {
                    if( (sParamInfos[i].mDecimalDigits == 0) &&
                        (sParamInfos[i].mColumnSize <= 19) )
                    {
                        if( sParamInfos[i].mColumnSize > 10 )
                        {
                            sParamInfos[i].mValueType = SQL_C_SBIGINT;
                        }
                        else
                        {
                            sParamInfos[i].mValueType = SQL_C_LONG;
                        }
                    }
                    else
                    {
                        sParamInfos[i].mValueType = SQL_C_CHAR;
                    }
                }
                else
                {
                    sParamInfos[i].mValueType = SQLTypeToCType( sParamInfos[i].mParameterType );
                }
            }
        }
        
        TRY( BindParameter( aCursor,
                            i + 1,
                            sPsmParamInfo[i].mColumnType,
                            &sParamInfos[i] ) == SUCCESS );
        
    }

    //execute
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLExecute( aCursor->mHStmt );
    Py_END_ALLOW_THREADS;

    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

    //make output param
    TRY( MakeOutputParameter( aCursor,
                              aParamSeq,
                              aOutParam,
                              sPsmParamInfo ) == SUCCESS );

    sState = 0;
    free( sPsmParamInfo );

    return SUCCESS;

    CATCH( RAMP_ERR_NO_MEMORY )
    {
        PyErr_NoMemory();
    }

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              "SQLExecute",
                              sCnxn->mHDbc,
                              aCursor->mHStmt );
    }

    FINISH;

    switch( sState )
    {
        case 2:
            (void)FreeParameterInfos( aCursor );
        case 1:
            if( sPsmParamInfo != NULL )
            {
                free( sPsmParamInfo );
            }
        default:
            break;
    }

    return FAILURE;
}

static char gCallProcDoc[] =
    "C.callproc(proc_name, [params]) --> [params]\n"
    "Calls the stored procedure named by the proc_name argument.\n"
    "The params sequence of parameters must contain one entry for each argument that the procedure expects.\n"
    "The result of the call is returned as modified copy of the input sequence. Input parameters are left untouched, output and input/output parameters replaced with possibly new values.\n"
    "\n"
    "The procedure does not provide a result set as output yet.";

PyObject * Cursor_callproc( PyObject * aSelf,
                            PyObject * aArgs )
{
    Cursor    * sCursor = NULL;
    char      * sProcName = NULL;
    PyObject  * sParamSeq = NULL;
    PyObject  * sOutParam = NULL;

    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN | CURSOR_RAISE_ERROR );
    TRY( sCursor != NULL );
    
    TRY( PyArg_ParseTuple( aArgs, "s|O", &sProcName, &sParamSeq ) == TRUE );

    TRY( sProcName != NULL );

    TRY_THROW( (sParamSeq == NULL) || (PyTuple_Check( sParamSeq ) == TRUE) || (PyList_Check( sParamSeq ) == TRUE),
               RAMP_ERR_INVALID_PARAMS_TYPE );

    TRY( CallProcedure( sCursor,
                        sProcName,
                        sParamSeq,
                        &sOutParam ) == SUCCESS );
    
    return sOutParam; // tuple이 되야함.

    CATCH( RAMP_ERR_INVALID_PARAMS_TYPE )
    {
        RaiseErrorV( NULL,
                     PyExc_TypeError,
                     "Params must be in a list, tuple, or Row" );
    }

    FINISH;

    return NULL;
}


STATUS CallFunction( Cursor    * aCursor,
                     char      * aFuncName,
                     PyObject  * aParamSeq,
                     PyObject ** aOutParam )
{
    Connection   * sCnxn;
    PyObject     * sSql;
    Py_ssize_t     sCount = 0; 
    ParamInfo    * sParamInfos;
    ParamInfo      sRetParamInfo;
    PsmParamInfo * sPsmParamInfo = NULL;
    PsmParamInfo   sRetPsmParamInfo;
    PyObject     * sParam = NULL;
    int            sState = 0;
    SQLRETURN      sRet = 0;
    Py_ssize_t     i;
    
    sCnxn = GetConnection( aCursor );

    memset( &sRetParamInfo, 0x00, sizeof( ParamInfo ) );
    memset( &sRetPsmParamInfo, 0x00, sizeof( PsmParamInfo ) );

    if( aParamSeq != NULL )
    {
        sCount = PySequence_Fast_GET_SIZE( aParamSeq );
        sPsmParamInfo = (PsmParamInfo*)malloc( sCount * sizeof( PsmParamInfo ) );
        TRY_THROW( sPsmParamInfo != NULL, RAMP_ERR_NO_MEMORY );
        memset( sPsmParamInfo, 0x00, sCount * sizeof( PsmParamInfo ) );
    }
    sState = 1;
    
    TRY( GetPsmParamInfo( aCursor,
                          aFuncName,
                          sCount,
                          sPsmParamInfo,
                          &sRetPsmParamInfo ) == SUCCESS );

    sSql = MakeCallPsmString( aFuncName, TRUE, sCount );

    TRY( Prepare( aCursor, sSql ) == SUCCESS );

    if( aCursor->mParamInfos == NULL )
    {
        aCursor->mParamInfos = (ParamInfo*)malloc( sCount * sizeof( ParamInfo ) );
        TRY_THROW( aCursor->mParamInfos != NULL, RAMP_ERR_NO_MEMORY );
        memset( aCursor->mParamInfos, 0x00, sCount * sizeof( ParamInfo ) );
    }
    sState = 2;

    sRetParamInfo.mParameterType = sRetPsmParamInfo.mDataType;
    sRetParamInfo.mColumnSize    = sRetPsmParamInfo.mColumnSize;
    sRetParamInfo.mDecimalDigits = sRetPsmParamInfo.mDecimalDigits;
    sRetParamInfo.mBufferLength  = sRetPsmParamInfo.mBufferLength;

    if( (sRetParamInfo.mParameterType == SQL_DECIMAL) ||
        (sRetParamInfo.mParameterType == SQL_NUMERIC) )
    {
        if( (sRetParamInfo.mDecimalDigits == 0) &&
            (sRetParamInfo.mColumnSize <= 19) )
        {
            if( sRetParamInfo.mColumnSize > 10 )
            {
                sRetParamInfo.mValueType = SQL_C_SBIGINT;
            }
            else
            {
                sRetParamInfo.mValueType = SQL_C_LONG;
            }
        }
        else
        {
            sRetParamInfo.mValueType = SQL_C_CHAR;
        }
    }
    else
    {
        sRetParamInfo.mValueType = SQLTypeToCType( sRetParamInfo.mParameterType );
    }

    TRY( AllocOutParamBuffer( aCursor,
                              0,
                              &sRetParamInfo ) == SUCCESS );
    sState = 3;
    
    TRY( BindParameter( aCursor,
                        1,
                        SQL_PARAM_OUTPUT,
                        &sRetParamInfo ) == SUCCESS );
    
    sParamInfos = aCursor->mParamInfos;
    for( i = 0; i < sCount; i++ )
    {
        sParam = PySequence_GetItem( aParamSeq, i );
        
        TRY( GetParameterInfo( aCursor,
                               i,
                               sParam,
                               &sParamInfos[i] ) == TRUE );

        TRY( BindParameter( aCursor,
                            i + 2,
                            sPsmParamInfo[i].mColumnType,
                            &sParamInfos[i] ) == SUCCESS );
    }
    
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLExecute( aCursor->mHStmt );
    Py_END_ALLOW_THREADS;

    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );
    
    *aOutParam = CToPyTypeByCType( aCursor,
                                   sRetParamInfo.mValueType,
                                   sRetParamInfo.mParameterValuePtr,
                                   sRetParamInfo.mParameterType,
                                   sRetParamInfo.mColumnSize,
                                   sRetParamInfo.mDecimalDigits,
                                   sRetParamInfo.mStrLen_or_Ind );

    TRY( aOutParam != NULL );

    free( sRetParamInfo.mParameterValuePtr );

    free( sPsmParamInfo );
    
    return SUCCESS;

    CATCH( RAMP_ERR_NO_MEMORY )
    {
        PyErr_NoMemory();
    }

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              "SQLExecute",
                              sCnxn->mHDbc,
                              aCursor->mHStmt );
    }
    
    FINISH;

    switch( sState )
    {
        case 3:
            free( sRetParamInfo.mParameterValuePtr );
        case 2:
            (void)FreeParameterInfos( aCursor );
        case 1:
            if( sPsmParamInfo != NULL )
            {
                free( sPsmParamInfo );
            }
        default:
            break;
    }
    
    return FAILURE;
}


static char gCallFuncDoc[] =
    "C.callfunc(func_name, [params]) --> [params]\n"
    "Calls the  named by the func_name argument.\n"
    "The params sequence of parameters must contain one entry for each argument that the procedure expects.\n";

PyObject * Cursor_callfunc( PyObject * aSelf,
                            PyObject * aArgs )
{
    Cursor    * sCursor = NULL;
    char      * sFuncName = NULL;
    PyObject  * sParamSeq = NULL;
    PyObject  * sOutParam = NULL;

    sCursor = ValidateCursor( aSelf, CURSOR_REQUIRE_OPEN | CURSOR_RAISE_ERROR );
    TRY( sCursor != NULL );
    
    TRY( PyArg_ParseTuple( aArgs, "s|O", &sFuncName, &sParamSeq ) == TRUE );

    TRY( sFuncName != NULL );

    TRY_THROW( (sParamSeq == NULL) || (PyTuple_Check( sParamSeq ) == TRUE) || (PyList_Check( sParamSeq ) == TRUE),
               RAMP_ERR_INVALID_PARAMS_TYPE );

    TRY( CallFunction( sCursor,
                       sFuncName,
                       sParamSeq,
                       &sOutParam ) == SUCCESS );
    
    return sOutParam;

    CATCH( RAMP_ERR_INVALID_PARAMS_TYPE )
    {
        RaiseErrorV( NULL,
                     PyExc_TypeError,
                     "Params must be in a list, tuple, or Row" );
    }

    FINISH;

    return NULL;
}

static char gRowCountDoc[] =
    "This read-only attribute specifies the number of rows the last DML statement\n"
    " (INSERT, UPDATE, DELETE) affected.  This is set to -1 for SELECT statements.";

static char gDescriptionDoc[] =
    "This read-only attribute is a sequence of 7-item sequences.  Each of these\n" \
    "sequences contains information describing one result column: (name, type_code,\n" \
    "display_size, internal_size, precision, scale, null_ok).  All values except\n" \
    "name, type_code, and internal_size are None.  The type_code entry will be the\n" \
    "type object used to create values for that column (e.g. `str` or\n" \
    "`datetime.datetime`).\n" \
    "\n" \
    "This attribute will be None for operations that do not return rows or if the\n" \
    "cursor has not had an operation invoked via the execute() method yet.\n" \
    "\n" \
    "The type_code can be interpreted by comparing it to the Type Objects defined in\n" \
    "the DB API and defined the pyodbc module: Date, Time, Timestamp, Binary,\n" \
    "STRING, BINARY, NUMBER, and DATETIME.";

static char gArraysizeDoc[] =
    "This read/write attribute specifies the number of rows to fetch at a time with\n" \
    "fetchmany(). It defaults to 1 meaning to fetch a single row at a time.";

static char gConnectionDoc[] =
    "This read-only attribute return a reference to the Connection object on which\n" \
    "the cursor was created.\n" \
    "\n" \
    "The attribute simplifies writing polymorph code in multi-connection\n" \
    "environments.";

static char gFastExecManyDoc[] =
    "This read/write attribute specifies whether to use a faster executemany() which\n" \
    "uses parameter arrays. Not all drivers may work with this implementation.";

static PyMemberDef gCursor_members[] =
{
    {"rowcount",    T_INT,       OFFSETOF(Cursor, mRowCount),      READONLY, gRowCountDoc },
    {"description", T_OBJECT_EX, OFFSETOF(Cursor, mDescription),   READONLY, gDescriptionDoc },
    {"arraysize",   T_INT,       OFFSETOF(Cursor, mArraySize),     0,        gArraysizeDoc },
    {"connection",  T_OBJECT_EX, OFFSETOF(Cursor, mConnection),    READONLY, gConnectionDoc },
    {"fast_executemany",T_BOOL,  OFFSETOF(Cursor, mFastExecMany),  0,        gFastExecManyDoc },
    { NULL, 0, 0, 0, NULL }
};

static PyMethodDef gCursorMethods[] =
{
    {
        "close",
        (PyCFunction)Cursor_close,
        METH_NOARGS,
        gCloseDoc
    },
    {
        "execute",
        (PyCFunction)Cursor_execute,
        METH_VARARGS,
        gExecuteDoc
    },
    {
        "executemany",
        (PyCFunction)Cursor_executemany,
        METH_VARARGS,
        gExecuteManyDoc
    },
    {
        "setinputsizes",
        (PyCFunction)Cursor_setinputsizes,
        METH_O,
        gSetInputSizesDoc
    },
    {
        "setoutputsize",
        (PyCFunction)Cursor_setoutputsize,
        METH_VARARGS,
        gSetOutputSizeDoc
    },
    {
        "fetchval",
        (PyCFunction)Cursor_fetchval,
        METH_NOARGS,
        gFetchValDoc
    },
    {
        "fetchone",
        (PyCFunction)Cursor_fetchone,
        METH_NOARGS,
        gFetchOneDoc
    },
    {
        "fetchall",
        (PyCFunction)Cursor_fetchall,
        METH_NOARGS,
        gFetchAllDoc
    },
    {
        "fetchmany",
        (PyCFunction)Cursor_fetchmany,
        METH_VARARGS,
        gFetchManyDoc
    },
    {
        "nextset",
        (PyCFunction)Cursor_nextset,
        METH_NOARGS,
        gNextSetDoc
    },
    {
        "tables",
        (PyCFunction)Cursor_tables,
        METH_VARARGS | METH_KEYWORDS,
        gTablesDoc
    },
    {
        "columns",
        (PyCFunction)Cursor_columns,
        METH_VARARGS | METH_KEYWORDS,
        gColumnsDoc
    },
    {
        "statistics",
        (PyCFunction)Cursor_statistics,
        METH_VARARGS | METH_KEYWORDS,
        gStatisticsDoc
    },
    {
        "rowIdColumns",
        (PyCFunction)Cursor_rowIdColumns,
        METH_VARARGS | METH_KEYWORDS,
        gRowIdColumnsDoc
    },
    {
        "rowVerColumns",
        (PyCFunction)Cursor_rowVerColumns,
        METH_VARARGS | METH_KEYWORDS,
        gRowVerColumnsDoc
    },
    {
        "primaryKeys",
        (PyCFunction)Cursor_primaryKeys,
        METH_VARARGS | METH_KEYWORDS,
        gPrimaryKeysDoc
    },
    {
        "foreignKeys",
        (PyCFunction)Cursor_foreignKeys,
        METH_VARARGS | METH_KEYWORDS,
        gForeignKeysDoc
    },
    {
        "getTypeInfo",
        (PyCFunction)Cursor_getTypeInfo,
        METH_VARARGS  |METH_KEYWORDS,
        gGetTypeInfoDoc
    },
    {
        "procedures",
        (PyCFunction)Cursor_procedures,
        METH_VARARGS | METH_KEYWORDS,
        gProceduresDoc
    },
    {
        "procedureColumns",
        (PyCFunction)Cursor_procedureColumns,
        METH_VARARGS|METH_KEYWORDS,
        gProcedureColumnsDoc
    },
    {
        "skip",
        (PyCFunction)Cursor_skip,
        METH_VARARGS,
        gSkipDoc
    },
    {
        "commit",
        (PyCFunction)Cursor_commit,
        METH_NOARGS,
        gCommitDoc
    },
    {
        "rollback",
        (PyCFunction)Cursor_rollback,
        METH_NOARGS,
        gRollbackDoc
    },
    {
        "cancel",
        (PyCFunction)Cursor_cancel,
        METH_NOARGS,
        gCancelDoc
    },
    {
        "__enter__",
        Cursor_enter,
        METH_NOARGS,
        gEnterDoc
    },
    {
        "__exit__",
        Cursor_exit,
        METH_VARARGS,
        gExitDoc
    },
    {
        "callproc",
        (PyCFunction)Cursor_callproc,
        METH_VARARGS,
        gCallProcDoc
    },
    {
        "callfunc",
        (PyCFunction)Cursor_callfunc,
        METH_VARARGS,
        gCallFuncDoc
    },
    { NULL, NULL, 0, NULL }
};

static char gCursorDoc[] =
    "Cursor objects represent a database cursor, which is used to manage the context\n" \
    "of a fetch operation.  Cursors created from the same connection are not\n" \
    "isolated, i.e., any changes done to the database by a cursor are immediately\n" \
    "visible by the other cursors.  Cursors created from different connections are\n" \
    "isolated.\n" \
    "\n" \
    "Cursors implement the iterator protocol, so results can be iterated:\n" \
    "\n" \
    "  cursor.execute(sql)\n" \
    "  for row in cursor:\n" \
    "     print row[0]";

PyTypeObject gCursorType =
{
    PyVarObject_HEAD_INIT(NULL, 0)
    "pygoldilocks.Cursor",             // tp_name
    sizeof(Cursor),                                  // tp_basicsize
    0,                                               // tp_itemsize
    (destructor)Cursor_dealloc,                      // destructor tp_dealloc
    0,                                               // tp_print
    0,                                               // tp_getattr
    0,                                               // tp_setattr
    0,                                               // tp_compare
    0,                                               // tp_repr
    0,                                               // tp_as_number
    0,                                               // tp_as_sequence
    0,                                               // tp_as_mapping
    0,                                               // tp_hash
    0,                                               // tp_call
    0,                                               // tp_str
    0,                                               // tp_getattro
    0,                                               // tp_setattro
    0,                                               // tp_as_buffer
#if defined(Py_TPFLAGS_HAVE_ITER)
    Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_ITER,
#else
    Py_TPFLAGS_DEFAULT,
#endif
    gCursorDoc,                                      // tp_doc
    0,                                               // tp_traverse
    0,                                               // tp_clear
    0,                                               // tp_richcompare
    0,                                               // tp_weaklistoffset
    Cursor_iter,                                     // tp_iter
    Cursor_iternext,                                 // tp_iternext
    gCursorMethods,                                  // tp_methods
    gCursor_members,                                 // tp_members
    0,                                               // tp_getset
    0,                                               // tp_base
};

/**
 * @brief To allow the connection to create cursors.
 */ 
Cursor * MakeCursor( Connection * aCnxn )
{
    SQLRETURN   sRet;
    char      * sErrFunc = NULL;
#ifdef _MSC_VER
#pragma warning(disable : 4365)
#endif
    Cursor    * sCursor = PyObject_NEW( Cursor, &gCursorType );
#ifdef _MSC_VER
#pragma warning(default : 4365)
#endif

    if( sCursor != NULL )
    {
        sCursor->mConnection       = aCnxn;
        sCursor->mHStmt            = SQL_NULL_HANDLE;
        sCursor->mDescription      = Py_None;
        sCursor->mPreparedSQL      = NULL;
        sCursor->mParamCount       = 0;
        sCursor->mParamInfos       = NULL;
        sCursor->mInputSizes       = NULL;
        sCursor->mOutputSize       = 0;
        sCursor->mOutputSizeIndex  = -1;
        sCursor->mColumnInfos      = NULL;
        sCursor->mColumnCount      = 0;
        sCursor->mArraySize        = 1;
        sCursor->mRowCount         = -1;
        sCursor->mMapNameToIndex   = NULL;
        sCursor->mFastExecMany     = FALSE;
        sCursor->mParamArray       = NULL;

        Py_INCREF( aCnxn );
        Py_INCREF( sCursor->mDescription );

        Py_BEGIN_ALLOW_THREADS;
        sRet = GDLAllocHandle( SQL_HANDLE_STMT,
                               aCnxn->mHDbc,
                               &sCursor->mHStmt );
        Py_END_ALLOW_THREADS;

        sErrFunc = "SQLAllocHandle";
        TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );

        if( aCnxn->mTimeout != 0 )
        {
            Py_BEGIN_ALLOW_THREADS;
            sRet = GDLSetStmtAttr( sCursor->mHStmt,
                                   SQL_ATTR_QUERY_TIMEOUT,
                                   (SQLPOINTER)(SQLULEN)aCnxn->mTimeout,
                                   0 );
            Py_END_ALLOW_THREADS;

            sErrFunc = "SQLSetStmtAttr(SQL_ATTR_QUERY_TIMEOUT)";
            TRY_THROW( SQL_SUCCEEDED(sRet), RAMP_ERR_SQLFUNCTION );
        }
    }

    return sCursor;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( aCnxn,
                              sErrFunc,
                              aCnxn->mHDbc,
                              sCursor->mHStmt );
        Py_DECREF( (PyObject *)sCursor );
    }
    
    FINISH;

    return NULL;
}

void InitCursor()
{
    PyDateTime_IMPORT;
}

/**
 * @}
 */
