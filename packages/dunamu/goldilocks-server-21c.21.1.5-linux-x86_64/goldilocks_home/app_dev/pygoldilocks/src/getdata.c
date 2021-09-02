/*******************************************************************************
 * getdata.c
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
 * @file getdata.c
 * @brief Python get data function for Goldilocks Python Database API
 */

/**
 * @addtogroup getdata
 * @{
 */

/**
 * @brief Internal
 */


// The functions for reading a single value from the database using SQLGetData.
// There is a different function for every data type.

#include <pydbc.h>
#include <buffer.h>
#include <connection.h>
#include <param.h>
#include <error.h>
#include <module.h>
#include <encoding.h>
#include <type.h>

#include <datetime.h>

void InitGetData()
{
    PyDateTime_IMPORT;
}

static char * ReallocOrFreeBuffer( void       * aPtr,
                                   Py_ssize_t   aNeedSize )
{
    /**
     * Attempts to reallocate `aPtr` to size `aNeedSize`.
     * If the realloc fails, the original memory is freed,
     * a memory exception is set, and 0 is returned.
     * Otherwise the new pointer is returned.
     */
    char * sNewPtr = NULL;
    
    sNewPtr = (char*)realloc( aPtr, aNeedSize );

    TRY_THROW( sNewPtr != NULL, RAMP_ERR_NO_MEMORY );

    return sNewPtr;

    CATCH( RAMP_ERR_NO_MEMORY )
    {
        PyErr_NoMemory();
    }

    FINISH;

    free( aPtr );
    
    return NULL;
}

static bool IsBinaryType( SQLSMALLINT aSqlType )
{
    // Is this SQL type (e.g. SQL_VARBINARY) a binary type or not?
    switch( aSqlType )
    {
        case SQL_BINARY:
        case SQL_VARBINARY:
        case SQL_LONGVARBINARY:
            return TRUE;
    }
    
    return FALSE;
}

// TODO: Wont pyodbc_free crash if we didn't use pyodbc_realloc.
static STATUS ReadVarColumn( Cursor       * aCursor,
                             Py_ssize_t     aIndex,
                             SQLSMALLINT    aCType,
                             bool         * aIsNull,
                             char        ** aResult,
                             Py_ssize_t   * aResultLen )
{
    /**
     * Called to read a variable-length column and return its data in a newly-allocated heap buffer.
     *
     * Returns true if the read was successful and false if the read failed.  If the read
     * failed a Python exception will have been set.
     *
     * If a non-null and non-empty value was read, aResult will be set to a buffer containing
     * the data and aResult will be set to the byte length.  This length does *not* include a
     * null terminator.  In this case the data *must* be freed using pyodbc_free.
     *
     * If a null value was read, aIsNull is set to true and aResult and aResultLen will be set to 0.
     *
     * If a zero-length value was read, aIsNull is set to false and aResult and aResultLen will
     * be set to 0.
     */
    Py_ssize_t   sElement = 1;
    Py_ssize_t   sNullTerminator = 0;
    /**
     *@todo outputsize 
     */
    Py_ssize_t   sAllocSize = 4096;
    Py_ssize_t   sUsed = 0;
    char       * sPtr;
    SQLRETURN    sRet = SQL_SUCCESS_WITH_INFO;
    Py_ssize_t   sAvailable;
    SQLLEN       sDataLen;
    Connection * sCnxn = GetConnection( aCursor );
    Py_ssize_t   sRemaining;
    Py_ssize_t   sReadLen;
    Py_ssize_t   sNeedSize;
    
    *aIsNull = FALSE;
    *aResult = NULL;
    *aResultLen = 0;

    if( IsWideType( aCType ) == TRUE )
    {
        sElement = sizeof( SQLWCHAR );
    }
    
    if( IsBinaryType( aCType ) != TRUE )
    {
        sNullTerminator = sElement;
    }
    
    // TODO: Make the initial allocation size configurable?
    sPtr = (char*) malloc( sAllocSize );

    if( sPtr == NULL )
    {
        PyErr_NoMemory();
        TRY( FALSE );
    }

    do
    {
        /**
         * Call SQLGetData in a loop as long as it keeps returning partial data (ret ==
         * SQL_SUCCESS_WITH_INFO).
         * Each time through, update the buffer sPtr, sAllocated, and sUsed.
         */
        sAvailable = sAllocSize - sUsed;
        sDataLen = 0;

        Py_BEGIN_ALLOW_THREADS;
        sRet = GDLGetData( aCursor->mHStmt,
                           (SQLUSMALLINT)(aIndex + 1),
                           aCType,
                           &sPtr[ sUsed ],
                           (SQLLEN)sAvailable,
                           &sDataLen );
        Py_END_ALLOW_THREADS;

        TRY_THROW( SQL_SUCCEEDED( sRet ) || (sRet == SQL_NO_DATA),
                   RAMP_ERR_SQLFUNCTION );

        if( (sRet == SQL_SUCCESS) && ((int)sDataLen < 0) )
        {
            // HACK: FreeTDS 0.91 on OS/X returns -4 for NULL data instead of SQL_NULL_DATA
            // (-1).  I've traced into the code and it appears to be the result of assigning -1
            // to a SQLLEN.  We are going to treat all negative values as NULL.
            sRet = SQL_NULL_DATA;
            sDataLen = 0;
        }

        /**
         * SQLGetData behavior is incredibly quirky: It doesn't tell us the total, the total
         * we've read, or even the amount just read.  It returns the amount just read, plus any
         * remaining.  Unfortunately, the only way to pick them apart is to subtract out the
         * amount of buffer we supplied.
        */
        if( sRet == SQL_SUCCESS_WITH_INFO )
        {
            /**
             * This means we read some data, but there is more.  SQLGetData is very weird - it
             * sets cbRead to the number of bytes we read *plus* the amount remaining.
             */
            sRemaining = 0; // How many more bytes do we need to allocate, not including null?
            sReadLen = 0; // How much did we just read, not including null?

            if( sDataLen == SQL_NO_TOTAL )
            {
                // This special value indicates there is more data but the driver can't tell us
                // how much more, so we'll just add whatever we want and try again.  It also
                // tells us, however, that the buffer is full, so the amount we read equals the
                // amount we offered.  Remember that if the type requires a null terminator, it
                // will be added *every* time, not just at the end, so we need to subtract it.

                sReadLen = sAvailable - sNullTerminator;
                sRemaining = 1024 * 1024;
            }
            else if( (Py_ssize_t)sDataLen >= sAvailable )
            {
                // We offered cbAvailable space, but there was cbData data.  The driver filled
                // the buffer with what it could.  Remember that if the type requires a null
                // terminator, the driver is going to append one on *every* read, so we need to
                // subtract them out.  At least we know the exact data amount now and we can
                // allocate a precise amount.

                sReadLen = sAvailable - sNullTerminator;
                sRemaining = sDataLen - sReadLen;
            }
            else
            {
                // I would not expect to get here - we apparently read all of the data but the
                // driver did not return SQL_SUCCESS?
                sReadLen = sDataLen - sNullTerminator;
                sRemaining = 0;
            }

            sUsed += sReadLen;

            if( sRemaining > 0 )
            {
                // This is a tiny bit complicated by the fact that the data is null terminated,
                // meaning we haven't actually used up the entire buffer (sAllocSize), only
                // sUsed (which should be sAllocSize - sNullTerminator).
                sNeedSize = sUsed + sRemaining + sNullTerminator;

                sPtr = ReallocOrFreeBuffer( sPtr, sNeedSize );                
                TRY( sPtr != NULL );

                sAllocSize = sNeedSize;
            }
        }
        else if( sRet == SQL_SUCCESS )
        {
            /**
             * We read some data and this is the last batch (so we'll drop out of the loop).
             * If I'm reading the documentation correctly, SQLGetData is not going to
             * include the null terminator in sDataLen.
             */

            sUsed += sDataLen;
        }
    }  while( sRet == SQL_SUCCESS_WITH_INFO );

    if( sRet == SQL_NULL_DATA )
    {   
        *aIsNull = TRUE;
    }

    if( (*aIsNull == FALSE) && (sUsed > 0) )
    {
        *aResult = sPtr;
        *aResultLen = sUsed;
    }
    else
    {
        free( sPtr );
    }

    return SUCCESS;

    CATCH( RAMP_ERR_SQLFUNCTION )
    {
        RaiseErrorFromHandle( sCnxn,
                              "SQLGetData",
                              sCnxn->mHDbc,
                              aCursor->mHStmt );

    }
        
    FINISH;

    return FAILURE;
}


static PyObject * GetText( Cursor     * aCursor,
                           Py_ssize_t   aIndex )
{
    /**
     * We are reading one of the SQL_WCHAR, SQL_WVARCHAR, etc., and will return a string.
     *
     * If there is no configuration we would expect this to be UTF-16 encoded data.  (If no
     * byte-order-mark, we would expect it to be big-endian.)
     *
     * Now, just because the driver is telling us it is wide data doesn't mean it is true.
     * psqlodbc with UTF-8 will tell us it is wide data but you must ask for single-byte.
     * (Otherwise it is just UTF-8 with each character stored as 2 bytes.)  That's why we allow
     * the user to configure.
    */
    Connection * sCnxn = GetConnection( aCursor );
    Encoding   * sEncoding;
    bool         sIsNull = FALSE;
    char       * sData = NULL;
    Py_ssize_t   sDataLen = 0;
    PyObject   * sResult = NULL;

    sEncoding = &sCnxn->mReadingEnc;
    
    TRY( ReadVarColumn( aCursor,
                        aIndex,
                        sEncoding->mCType,
                        &sIsNull,
                        &sData,
                        &sDataLen ) == SUCCESS );
    
    if( sIsNull == TRUE )
    {
        DASSERT( (sData == NULL) && (sDataLen == 0) );
        Py_RETURN_NONE;
    }

    sResult = TextToPyObject( sEncoding, sData, sDataLen );
    free( sData );

    return sResult;

    FINISH;

    return NULL;
}



static PyObject * GetBinary( Cursor     * aCursor,
                             Py_ssize_t   aIndex )
{
    // Reads SQL_BINARY.

    bool         sIsNull = FALSE;
    char       * sData = NULL;
    Py_ssize_t   sDataLen = 0;
    PyObject   * sObj;
    
    TRY( ReadVarColumn( aCursor,
                        aIndex,
                        SQL_C_BINARY,
                        &sIsNull,
                        &sData,
                        &sDataLen ) == SUCCESS );

    if( sIsNull == TRUE )
    {
        DASSERT( (sData == NULL) && (sDataLen == 0) );
        Py_RETURN_NONE;
    }


#if PY_MAJOR_VERSION >= 3
    sObj = PyBytes_FromStringAndSize( (char*)sData, sDataLen );
#else
    sObj = PyByteArray_FromStringAndSize((char*)sData, sDataLen );
#endif

    free( sData );

    return sObj;

    FINISH;

    return NULL;
}

/**
 *@brief Returns a type object ('int', 'str', etc.) for the given ODBC C type.
 */ 
PyObject * PythonTypeFromSqlType( Cursor      * aCursor,
                                  SQLSMALLINT   aType )
{
    /**
     * This is used to populate Cursor.description with the type of Python object
     * that will be returned for each column.
     * name
     *  The name of the column, only used to create error messages.
     * type
     *  The ODBC C type (SQL_C_CHAR, etc.) of the column.
     * The returned object does not have its reference count incremented!
     */ 

    PyObject   * sPyType = NULL;
    bool         sIncRef = TRUE;
#if PY_MAJOR_VERSION < 3    
    Connection * sCnxn = GetConnection( aCursor );
#endif

    switch( aType )
    {
        case SQL_WCHAR:
        case SQL_WVARCHAR:
        case SQL_WLONGVARCHAR:
            sPyType = (PyObject*)&PyUnicode_Type;
            break;

        case SQL_DECIMAL:
        case SQL_NUMERIC:
            sPyType = GetClassForThread( "decimal", "Decimal" );
            sIncRef = FALSE;
            break;
            
        case SQL_REAL:
        case SQL_FLOAT:
        case SQL_DOUBLE:
            sPyType = (PyObject*)&PyFloat_Type;
            break;
            
        case SQL_SMALLINT:
        case SQL_INTEGER:
        case SQL_TINYINT:
            sPyType = (PyObject*)&PyInt_Type;
            break;

        case SQL_TYPE_DATE:
            sPyType = (PyObject*)PyDateTimeAPI->DateType;
            break;

        case SQL_TYPE_TIME:
            sPyType = (PyObject*)PyDateTimeAPI->TimeType;
            break;

        case SQL_TYPE_TIMESTAMP:
            sPyType = (PyObject*)PyDateTimeAPI->DateTimeType;
            break;

        case SQL_BIGINT:
            sPyType = (PyObject*)&PyLong_Type;
            break;

        case SQL_BIT:
            sPyType = (PyObject*)&PyBool_Type;
            break;

        case SQL_BINARY:
        case SQL_VARBINARY:
        case SQL_LONGVARBINARY:
        
#if PY_VERSION_HEX >= 0x02060000
            sPyType = (PyObject*)&PyByteArray_Type;
#else
            sPyType = (PyObject*)&PyBuffer_Type;
#endif
            break;
        case SQL_CHAR:
        case SQL_VARCHAR:
        case SQL_LONGVARCHAR:
        default:
#if PY_MAJOR_VERSION < 3
            if( (sCnxn->mWritingEnc.mCType == SQL_C_CHAR) ||
                (sCnxn->mWritingEnc.mCType == SQL_C_LONGVARCHAR))
            {
                sPyType = (PyObject*)&PyString_Type;
            }
            else
#endif
            {
                sPyType = (PyObject*)&PyUnicode_Type;
            }
            break;
    }

    if( (sPyType != NULL) && (sIncRef == TRUE) )
    {
        Py_INCREF( sPyType );
    }
    
    return sPyType;
}

STATUS GetData( Cursor      * aCursor,
                Py_ssize_t    aIndex,
                PyObject   ** aData )
{
    /**
     * Returns an object representing the value in the row/field.
     * If NULL is returned, an exception has already been set.
     * The data is assumed to be the default C type for the column's SQL type.
     */
    ColumnInfo * sColumnInfo = NULL;

    sColumnInfo = &aCursor->mColumnInfos[aIndex];

    // First see if there is a user-defined conversion.

    switch( sColumnInfo->mSqlType )
    {
        case SQL_LONGVARCHAR:
            *aData = GetText( aCursor, aIndex );
            break;
        case SQL_LONGVARBINARY:
            *aData = GetBinary( aCursor, aIndex );
            break;
        default:
            DASSERT( FALSE );
            break;
    }
    
    return SUCCESS;
}

/**
 * @}
 */

