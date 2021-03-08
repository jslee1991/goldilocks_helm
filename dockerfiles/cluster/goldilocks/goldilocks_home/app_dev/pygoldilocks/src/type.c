/*******************************************************************************
 * type.c
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
 * @file type.c
 * @brief Python type for Goldilocks Python Database API
 */

#include <pydbc.h>
#include <buffer.h>
#include <connection.h>
#include <error.h>
#include <module.h>
#include <param.h>
#include <encoding.h>
#include <type.h>
#include <datetime.h>

void InitType()
{
    PyDateTime_IMPORT;
}

#if PY_MAJOR_VERSION < 3
bool IsStringType( PyObject * aObj )
{
    return (void*)aObj == (void*)&PyString_Type;
}

bool IsUnicodeType( PyObject * aObj )
{
    return (void*)aObj == (void*)&PyUnicode_Type;
}
#endif

bool IsTextType( PyObject * aObject )
{
    /**
     * A compatibility function that determines if the object is a string,
     * based on the version of Python.
     * For Python 2, an ASCII or Unicode string is allowed.
     * For Python 3, it must be a Unicode object.
     */

#if PY_MAJOR_VERSION < 3
    if( aObject && PyString_Check( aObject ))
    {
        return TRUE;
    }
#endif
    
    return aObject && (PyUnicode_Check( aObject ) == TRUE);
}

bool IsWideType( SQLSMALLINT aSqlType )
{
    switch( aSqlType )
    {
        case SQL_WCHAR:
        case SQL_WVARCHAR:
        case SQL_WLONGVARCHAR:
            return TRUE;
    }
    
    return FALSE;
}

bool IsLongVariableType( SQLSMALLINT aSqlType )
{
    switch( aSqlType )
    {
        case SQL_LONGVARCHAR:
        case SQL_WLONGVARCHAR:
        case SQL_LONGVARBINARY:
            return TRUE;
    }
    
    return FALSE;
}

bool IsIntOrLong( PyObject * aObj )
{
    // A compatability function to check for an int or long. Python 3 doesn't differentate anymore.
    // A compatibility function that determines if the object is a string, based on the version of Python.
    // For Python 2, an ASCII or Unicode string is allowed.  For Python 3, it must be a Unicode object.

#if PY_MAJOR_VERSION < 3
    if( (aObj != NULL) && (PyInt_Check(aObj) == TRUE) )
    {
        return TRUE;
    }
#endif

    if( (aObj != NULL) && (PyLong_Check( aObj ) == TRUE) )
    {
        return TRUE;
    }

    return FALSE;
}

/**
 * @brief Detects and sets the appropriate C type to use for binding the specified Python object.
 * Also sets the buffer length to use.
 */ 
bool DetectCType( PyObject  * aData,
                  ParamInfo * aParamInfo )
{
    PyObject * sClass = NULL;
    
    /**
     * todo sizeof 확인
     */ 
    if( PyBool_Check( aData ) == TRUE )
    {
        aParamInfo->mValueType = SQL_C_BIT;
        aParamInfo->mBufferLength = 1;
    }
#if PY_MAJOR_VERSION < 3
    else if( PyInt_Check( aData ) == TRUE )
    {
        if( sizeof( long ) == 8 )
        {
            aParamInfo->mValueType = SQL_C_SBIGINT;
        }
        else
        {
            aParamInfo->mValueType = SQL_C_LONG;
        }
        
        aParamInfo->mBufferLength = sizeof( long );
    }
#endif
    else if( PyLong_Check( aData ) == TRUE )
    {
        (void)PyLong_AsLongLong( aData );
        if( PyErr_Occurred() )
        {
            PyErr_Clear();
            aParamInfo->mValueType = SQL_C_NUMERIC;
            aParamInfo->mBufferLength = sizeof( SQL_NUMERIC_STRUCT );
        }
        else
        {
            if( (aParamInfo->mParameterType == SQL_NUMERIC) ||
                (aParamInfo->mParameterType == SQL_DECIMAL) )
            {
                aParamInfo->mValueType = SQL_C_NUMERIC;
                aParamInfo->mBufferLength = sizeof( SQL_NUMERIC_STRUCT );
            }
            else
            {
                aParamInfo->mValueType = SQL_C_SBIGINT;
                aParamInfo->mBufferLength = sizeof( long long );
            }
        }
    }
    else if( PyFloat_Check( aData ) == TRUE )
    {
        aParamInfo->mValueType = SQL_C_DOUBLE;
        aParamInfo->mBufferLength = sizeof( double );
    }
    else if( PyBytes_Check( aData ) == TRUE )
    {
#if PY_MAJOR_VERSION < 3
        aParamInfo->mValueType = SQL_C_CHAR;
#else
        aParamInfo->mValueType = SQL_C_BINARY;
#endif
        aParamInfo->mBufferLength = aParamInfo->mColumnSize;
    }
    else if( PyUnicode_Check( aData ) == TRUE )
    {
        // Assume the SQL type is also wide character.
        // If it is a max-type (ColumnSize == 0), use DAE.
        if( sizeof( Py_UNICODE ) != sizeof( SQLWCHAR ) )
        {
            aParamInfo->mValueType = SQL_C_CHAR;
        }
        else
        {
            aParamInfo->mValueType = SQL_C_WCHAR;
        }

        if( aParamInfo->mColumnSize != 0 )
        {
            aParamInfo->mBufferLength = aParamInfo->mColumnSize;
        }
        else
        {
            aParamInfo->mBufferLength = sizeof( ParamInfo );
        }
    }
    else if( PyDateTime_Check( aData ) == TRUE )
    {
        aParamInfo->mValueType = SQL_C_TYPE_TIMESTAMP;
        aParamInfo->mBufferLength = sizeof( SQL_TIMESTAMP_STRUCT );
    }
    else if( PyDate_Check( aData ) == TRUE )
    {
        aParamInfo->mValueType = SQL_C_TYPE_DATE;
        aParamInfo->mBufferLength = sizeof( SQL_DATE_STRUCT );
    }
    else if( PyTime_Check( aData ) == TRUE )
    {
        aParamInfo->mValueType = SQL_C_TYPE_TIME;
        aParamInfo->mBufferLength = sizeof( SQL_TIME_STRUCT );
    }
#if PY_VERSION_HEX >= 0x02060000
    else if( PyByteArray_Check( aData ) == TRUE )
    {
        aParamInfo->mValueType = SQL_C_BINARY;
        aParamInfo->mBufferLength = aParamInfo->mColumnSize;
    }
#endif
#if PY_MAJOR_VERSION < 3
    else if( PyBuffer_Check( aData ) == TRUE )
    {
        aParamInfo->mValueType = SQL_C_BINARY;

        if( GetBufferMemory(aData, 0) >= 0 )
        {
            aParamInfo->mBufferLength = aParamInfo->mColumnSize;
        }
        else
        {
            aParamInfo->mBufferLength = sizeof( ParamInfo );
        }
    }
#endif
    else if( aData == Py_None )
    {
        switch( aParamInfo->mParameterType )
        {
            case SQL_CHAR:
            case SQL_VARCHAR:
            case SQL_LONGVARCHAR:
#if PY_MAJOR_VERSION < 3
                aParamInfo->mValueType = SQL_C_CHAR;
#else
                aParamInfo->mValueType = SQL_C_BINARY;
#endif
                aParamInfo->mBufferLength = aParamInfo->mColumnSize;
                break;
            case SQL_DECIMAL:
            case SQL_NUMERIC:
                aParamInfo->mValueType = SQL_C_NUMERIC;
                aParamInfo->mBufferLength = sizeof( SQL_NUMERIC_STRUCT );
                break;
            case SQL_BIGINT:
                if( (aParamInfo->mParameterType == SQL_NUMERIC) ||
                    (aParamInfo->mParameterType == SQL_DECIMAL) )
                {
                    aParamInfo->mValueType = SQL_C_NUMERIC;
                    aParamInfo->mBufferLength = sizeof( SQL_NUMERIC_STRUCT );
                }
                else
                {
                    aParamInfo->mValueType = SQL_C_SBIGINT;
                    aParamInfo->mBufferLength = sizeof( long long );
                }
                break;
            case SQL_SMALLINT:
            case SQL_INTEGER:
            case SQL_TINYINT:
#if PY_MAJOR_VERSION < 3
                if( sizeof( long ) == 8 )
                {
                    aParamInfo->mValueType = SQL_C_SBIGINT;
                }
                else
                {
                    aParamInfo->mValueType = SQL_C_LONG;
                }
        
                aParamInfo->mBufferLength = sizeof( long );
#else
                if( (aParamInfo->mParameterType == SQL_NUMERIC) ||
                    (aParamInfo->mParameterType == SQL_DECIMAL) )
                {
                    aParamInfo->mValueType = SQL_C_NUMERIC;
                    aParamInfo->mBufferLength = sizeof( SQL_NUMERIC_STRUCT );
                }
                else
                {
                    aParamInfo->mValueType = SQL_C_SBIGINT;
                    aParamInfo->mBufferLength = sizeof( long long );
                }
#endif
                break;
            case SQL_REAL:
            case SQL_FLOAT:
            case SQL_DOUBLE:
                aParamInfo->mValueType = SQL_C_DOUBLE;
                aParamInfo->mBufferLength = sizeof( double );
                break;
            case SQL_BIT:
                aParamInfo->mValueType = SQL_C_BIT;
                aParamInfo->mBufferLength = 1;
                break;
            case SQL_BINARY:
            case SQL_VARBINARY:
            case SQL_LONGVARBINARY:
#if PY_VERSION_HEX >= 0x02060000
                aParamInfo->mValueType = SQL_C_BINARY;
                aParamInfo->mBufferLength = aParamInfo->mColumnSize;
#else
#if PY_MAJOR_VERSION < 3
                aParamInfo->mValueType = SQL_C_CHAR;
#else
                aParamInfo->mValueType = SQL_C_BINARY;
#endif
                aParamInfo->mBufferLength = aParamInfo->mColumnSize;
#endif
                break;
            case SQL_TYPE_DATE:
                aParamInfo->mValueType = SQL_C_TYPE_DATE;
                aParamInfo->mBufferLength = sizeof( SQL_DATE_STRUCT );
                break;
            case SQL_TYPE_TIME:
                aParamInfo->mValueType = SQL_C_TYPE_TIME;
                aParamInfo->mBufferLength = sizeof( SQL_TIME_STRUCT );
                break;
            case SQL_TYPE_TIMESTAMP:
                aParamInfo->mValueType = SQL_C_TYPE_TIMESTAMP;
                aParamInfo->mBufferLength = sizeof( SQL_TIMESTAMP_STRUCT );
                break;
            default:
#if PY_MAJOR_VERSION < 3
                aParamInfo->mValueType = SQL_C_CHAR;
#else
                aParamInfo->mValueType = SQL_C_BINARY;
#endif
                aParamInfo->mBufferLength = aParamInfo->mColumnSize;
                break;
        }
    }
    else if( (IsInstanceForThread( aData, "decimal", "Decimal", &sClass ) == TRUE) &&
             (sClass != NULL) )
    {
        aParamInfo->mValueType = SQL_C_NUMERIC;
        aParamInfo->mBufferLength = sizeof( SQL_NUMERIC_STRUCT );
    }
    else
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "Unknown object type %s during describe",
                     aData->ob_type->tp_name );
        
        return FALSE;
    }

    return TRUE;
}

#define WRITEOUT( aType, aPtr, aVal, aIndv )    \
    {                                           \
        *(aType*)(*aPtr) = (aVal);              \
        (*aPtr) += sizeof( aType );             \
        (aIndv) = sizeof( aType );              \
    }


static bool SetLongType( Cursor     * aCursor,
                         char      ** aOutBuf,
                         PyObject   * aData,
                         ParamInfo  * aParamInfo,
                         SQLLEN     * aInd )
{
    SQL_NUMERIC_STRUCT * sNum = NULL;
    PyObject           * sAbsVal = NULL;
    static PyObject    * sScalerTable[38];
    static PyObject    * sTenObject = NULL;
    PyObject           * sScaleObj;
    PyObject           * sScaledVal;
    
    if( aParamInfo->mValueType == SQL_C_SBIGINT )
    {
        WRITEOUT( long long, aOutBuf, PyLong_AsLongLong( aData ), *aInd );        
    }
    else if( aParamInfo->mValueType == SQL_C_NUMERIC )
    {
        // Convert a PyLong into a SQL_NUMERIC_STRUCT, without losing precision
        // or taking an unnecessary trip through character strings.
        sNum = (SQL_NUMERIC_STRUCT*)*aOutBuf;
        sAbsVal = PyNumber_Absolute( aData );
            
        if( aParamInfo->mDecimalDigits != 0 )
        {
            // Need to scale by 10**pi->DecimalDigits
            TRY_THROW( aParamInfo->mDecimalDigits <= 38, RAMP_ERR_NUMERIC_OVERFLOW );

            if( sScalerTable[ aParamInfo->mDecimalDigits - 1 ] != NULL )
            {
                if( sTenObject != NULL )
                {
                    sTenObject = PyInt_FromLong(10);
                }
                
                sScaleObj = PyInt_FromLong( aParamInfo->mDecimalDigits );
                
                sScalerTable[ aParamInfo->mDecimalDigits - 1 ] =
                    PyNumber_Power( sTenObject, sScaleObj, Py_None );

                Py_XDECREF(sScaleObj);
            }
                
            sScaledVal = PyNumber_Multiply( sAbsVal,
                                            sScalerTable[aParamInfo->mDecimalDigits - 1] );
            
            Py_XDECREF( sAbsVal );
            sAbsVal = sScaledVal;
        }
            
        sNum->precision = aParamInfo->mColumnSize;
        sNum->scale = aParamInfo->mDecimalDigits;
        sNum->sign = _PyLong_Sign( aData ) >= 0;
        
        TRY_THROW( _PyLong_AsByteArray( (PyLongObject*)sAbsVal,
                                        sNum->val,
                                        sizeof( sNum->val ),
                                        1,
                                        0 ) != -1,
                   RAMP_ERR_NUMERIC_OVERFLOW );

        Py_XDECREF( sAbsVal );
        *aOutBuf += aParamInfo->mBufferLength;
        *aInd = sizeof( SQL_NUMERIC_STRUCT );
    }
    else
    {
        return FALSE;
    }

    return TRUE;

    CATCH( RAMP_ERR_NUMERIC_OVERFLOW )
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "Numeric overflow" );
        Py_XDECREF( sAbsVal );
    }
    
    FINISH;

    return FALSE;
}


static bool SetBytesType( Cursor     * aCursor,
                          char      ** aOutBuf,
                          PyObject   * aData,
                          ParamInfo  * aParamInfo,
                          SQLLEN     * aInd )
{
    Py_ssize_t   sLen;
    
#if PY_MAJOR_VERSION < 3
    TRY( aParamInfo->mValueType == SQL_C_CHAR );
#else
    TRY( aParamInfo->mValueType == SQL_C_BINARY);
#endif

    sLen = PyBytes_GET_SIZE( aData );

    TRY_THROW(  sLen <= aParamInfo->mBufferLength, RAMP_ERR_TRUNCATED_DATA );

    memcpy( *aOutBuf, PyBytes_AS_STRING( aData ), sLen );
    *aOutBuf += aParamInfo->mBufferLength;
    *aInd = sLen;

    return TRUE;

    CATCH( RAMP_ERR_TRUNCATED_DATA )
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "byte length(%u) of data greater than column length(%u)",
                     sLen,
                     aParamInfo->mBufferLength );
    }
    
    FINISH;

    return FALSE;
}

static bool SetUnicodeType( Cursor     * aCursor,
                            char      ** aOutBuf,
                            PyObject   * aData,
                            ParamInfo  * aParamInfo,
                            SQLLEN     * aInd )
{
    Py_ssize_t   sLen;
    Encoding     sEncoding;
    PyObject   * sEncoded = NULL;
    Connection * sCnxn = GetConnection( aCursor );
    
    TRY( (aParamInfo->mValueType == SQL_C_CHAR) || (aParamInfo->mValueType == SQL_C_WCHAR) );

    sLen = PyUnicode_GET_SIZE( aData );
    
    //                  Same size              Different size
    // BufferLen       BufferLen only      Convert + BufferLen
    // non-BufferLen   Copy                Convert + Copy
    if( sizeof( Py_UNICODE ) != sizeof( SQLWCHAR ) )
    {
        memcpy( &sEncoding, &sCnxn->mWritingEnc, sizeof( Encoding ) );

        sEncoded = PyCodec_Encode( aData, sEncoding.mName, "strict" );
        TRY( sEncoded != NULL );
        
        TRY_THROW( (sEncoding.mType != ENC_NONE) || (PyBytes_CheckExact( sEncoded ) == TRUE),
                   RAMP_ERR_UNEXPECTED_TYPE );

        sLen = PyBytes_GET_SIZE( sEncoded );
        
        TRY_THROW(  sLen <= aParamInfo->mBufferLength, RAMP_ERR_TRUNCATED_DATA );
            
        memcpy( *aOutBuf, PyBytes_AS_STRING((PyObject*)sEncoded), sLen );
        *aOutBuf += aParamInfo->mBufferLength;
        *aInd = sLen;
    }
    else
    {
        sLen *= sizeof( SQLWCHAR );

        TRY_THROW(  sLen <= aParamInfo->mBufferLength, RAMP_ERR_TRUNCATED_DATA );
        
        memcpy( *aOutBuf, PyUnicode_AS_DATA( aData ), sLen );
        *aOutBuf += aParamInfo->mBufferLength;
        *aInd = sLen;
    }

    Py_XDECREF( sEncoded );

    return TRUE;

    CATCH( RAMP_ERR_UNEXPECTED_TYPE )
    {
        PyErr_Format( PyExc_TypeError,
                      "Unicode write encoding '%s' returned unexpected data type: %s",
                      sEncoding.mName,
                      sEncoded->ob_type->tp_name );
    }

    CATCH( RAMP_ERR_TRUNCATED_DATA )
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "byte length(%u) of data greater than column length(%u)",
                     sLen,
                     aParamInfo->mBufferLength );
    }
    
    FINISH;

    return FALSE;
}


static bool SetTimestampType( Cursor     * aCursor,
                              char      ** aOutBuf,
                              PyObject   * aData,
                              ParamInfo  * aParamInfo,
                              SQLLEN     * aInd )
{
    SQL_TIMESTAMP_STRUCT * sTms;
    
    if( aParamInfo->mValueType != SQL_C_TYPE_TIMESTAMP )
    {
        return FALSE;
    }
    
    sTms = (SQL_TIMESTAMP_STRUCT*)*aOutBuf;
    sTms->year = PyDateTime_GET_YEAR( aData );
    sTms->month = PyDateTime_GET_MONTH( aData );
    sTms->day = PyDateTime_GET_DAY( aData );
    sTms->hour = PyDateTime_DATE_GET_HOUR( aData );
    sTms->minute = PyDateTime_DATE_GET_MINUTE( aData );
    sTms->second = PyDateTime_DATE_GET_SECOND( aData );

    /**
     * @todo check decimal digit와 관련있음.
     */ 
    sTms->fraction = PyDateTime_DATE_GET_MICROSECOND( aData ) * 1000;
    
    *aOutBuf += sizeof( SQL_TIMESTAMP_STRUCT );
    *aInd = sizeof( SQL_TIMESTAMP_STRUCT );

    return TRUE;
}

static bool SetDateType( Cursor     * aCursor,
                         char      ** aOutBuf,
                         PyObject   * aData,
                         ParamInfo  * aParamInfo,
                         SQLLEN     * aInd )
{
    SQL_DATE_STRUCT * sDate; 
    if( aParamInfo->mValueType != SQL_C_TYPE_DATE )
    {
        return FALSE;
    }

    sDate = (SQL_DATE_STRUCT*)*aOutBuf;
    
    sDate->year = PyDateTime_GET_YEAR( aData );
    sDate->month = PyDateTime_GET_MONTH( aData );
    sDate->day = PyDateTime_GET_DAY( aData );

    *aOutBuf += sizeof( SQL_DATE_STRUCT );
    *aInd = sizeof( SQL_DATE_STRUCT );

    return TRUE;
}

static bool SetTimeType( Cursor     * aCursor,
                         char      ** aOutBuf,
                         PyObject   * aData,
                         ParamInfo  * aParamInfo,
                         SQLLEN     * aInd )
{
    SQL_TIME_STRUCT * sTime;
    
    if( aParamInfo->mValueType != SQL_C_TYPE_TIME )
    {
        return FALSE;
    }

    sTime = (SQL_TIME_STRUCT*)*aOutBuf;
    
    sTime->hour = PyDateTime_TIME_GET_HOUR( aData );
    sTime->minute = PyDateTime_TIME_GET_MINUTE( aData );
    sTime->second = PyDateTime_TIME_GET_SECOND( aData );

    *aOutBuf += sizeof( SQL_TIME_STRUCT );
    *aInd = sizeof( SQL_TIME_STRUCT );

    return TRUE;
}

#if PY_VERSION_HEX >= 0x02060000
static bool SetByteArrayType( Cursor     * aCursor,
                              char      ** aOutBuf,
                              PyObject   * aData,
                              ParamInfo  * aParamInfo,
                              SQLLEN     * aInd )
{
    Py_ssize_t   sLen;
    
    TRY_THROW( aParamInfo->mValueType == SQL_C_BINARY, RAMP_ERR_UNEXPECTED_TYPE );
    
    sLen = PyByteArray_GET_SIZE( aData );
    
    TRY_THROW( sLen <= aParamInfo->mBufferLength, RAMP_ERR_TRUNCATED_DATA );
        
    memcpy( *aOutBuf, PyByteArray_AS_STRING( aData ), sLen );        
    *aOutBuf += aParamInfo->mBufferLength;
    *aInd = sLen;
        
    return TRUE;

    CATCH( RAMP_ERR_UNEXPECTED_TYPE )
    {
        PyErr_Format( PyExc_TypeError,
                      "Bytearray type has to be matched with SQL_BINARY" );
    }

    CATCH( RAMP_ERR_TRUNCATED_DATA )
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "byte length(%u) of data greater than column length(%u)",
                     sLen,
                     aParamInfo->mBufferLength );
    }
    
    FINISH;

    return FALSE;
}
#endif

#if PY_MAJOR_VERSION < 3
static bool SetBufferType( Cursor    * aCursor,
                           char     ** aOutBuf,
                           PyObject  * aData,
                           ParamInfo * aParamInfo,
                           SQLLEN    * aInd )
{
    Py_ssize_t   sLen;
    char       * sPtr;
    ParamInfo  * sParamInfo;
    Connection * sCnxn = GetConnection( aCursor );

    TRY_THROW( aParamInfo->mValueType == SQL_C_BINARY, RAMP_ERR_UNEXPECTED_TYPE );
    
    sLen = GetBufferMemory( aData, &sPtr );
    
    if( sLen < 0 )
    {
        sParamInfo = (ParamInfo*)*aOutBuf;
        
        sLen = GetBufferSize( aData );

        Py_INCREF( aData );
        sParamInfo->mParam = aData;
        sParamInfo->mMaxLength = GetMaxLength( sCnxn, aParamInfo->mValueType );
        
        *aOutBuf += aParamInfo->mBufferLength;//mBufferLength는 sizeof( ParamInfo ) 이다.
        *aInd = SQL_DATA_AT_EXEC;
    }
    else
    {
        TRY_THROW( sLen <= aParamInfo->mBufferLength, RAMP_ERR_TRUNCATED_DATA );
        
        memcpy( *aOutBuf, sPtr, sLen );
        *aOutBuf += aParamInfo->mBufferLength;
        *aInd = sLen;
    }
    
    return TRUE;

    CATCH( RAMP_ERR_UNEXPECTED_TYPE )
    {
        PyErr_Format( PyExc_TypeError,
                      "Buffer type has to be matched with SQL_BINARY" );
    }

    CATCH( RAMP_ERR_TRUNCATED_DATA )
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "byte length(%u) of data greater than column length(%u)",
                     sLen,
                     aParamInfo->mBufferLength );
    }

    FINISH;

    return FALSE;
}
#endif

static bool SetDecimalType( Cursor     * aCursor,
                            char      ** aOutBuf,
                            PyObject   * aData,
                            ParamInfo  * aParamInfo,
                            SQLLEN     * aInd )
{
    PyObject           * sNormalise = NULL;
    PyObject           * sCellParts = NULL;
    SQL_NUMERIC_STRUCT * sNum = NULL;
    PyObject           * sDigits;
    long                 sExp;
    Py_ssize_t           sNumDigits;
    Py_ssize_t           sScaleDiff;
    PyObject           * sNewDigits = NULL;
    Py_ssize_t           i;
    PyObject           * sArgs = NULL;
    PyObject           * sScaledDecimal = NULL;
    PyObject           * sDigitLong = NULL;
    int                  sRet;
    
    if( aParamInfo->mValueType != SQL_C_NUMERIC )
    {
        return FALSE;
    }
    
    // Normalise, then get sign, exponent, and digits.
    sNormalise = PyObject_CallMethod( aData, "normalize", 0);
    if( sNormalise == NULL )
    {
        return FALSE;
    }
    
    sCellParts = PyObject_CallMethod( sNormalise, "as_tuple", 0 );
    if( sCellParts == NULL )
    {
        return FALSE;
    }

    Py_XDECREF( sNormalise );
        
    sNum = (SQL_NUMERIC_STRUCT*)*aOutBuf;
    
    sNum->sign = !PyInt_AsLong( PyTuple_GET_ITEM( sCellParts, 0 ) );
    
    sDigits = PyTuple_GET_ITEM( sCellParts, 1 );
    sExp    = PyInt_AsLong( PyTuple_GET_ITEM( sCellParts, 2 ) );
    sNumDigits = PyTuple_GET_SIZE( sDigits );

    // PyDecimal is digits * 10**exp = digits / 10**-exp
    // SQL_NUMERIC_STRUCT is val / 10**scale
    sScaleDiff = aParamInfo->mDecimalDigits + sExp;
    
    if( sScaleDiff < 0 )
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "Converting decimal loses precision" );
        return FALSE;
    }
        
    // Append '0's to the end of the digits to effect the scaling.
    sNewDigits = PyTuple_New( sNumDigits + sScaleDiff );

    for( i = 0; i < sNumDigits; i++ )
    {
        PyTuple_SET_ITEM( sNewDigits,
                          i,
                          PyInt_FromLong( PyNumber_AsSsize_t( PyTuple_GET_ITEM( sDigits, i ), 0 ) ) );
    }
    
    for( i = sNumDigits; i < sScaleDiff + sNumDigits; i++ )
    {
        PyTuple_SET_ITEM( sNewDigits, i, PyInt_FromLong( 0 ) );
    }
    
    sArgs = Py_BuildValue( "((iOi))", 0, sNewDigits, 0 );
    sScaledDecimal = PyObject_CallObject( (PyObject*)aData->ob_type, sArgs );
    sDigitLong = PyNumber_Long( sScaledDecimal );

    Py_XDECREF( sArgs );
    Py_XDECREF( sScaledDecimal );
    Py_XDECREF( sCellParts );

    sNum->precision = aParamInfo->mColumnSize;
    sNum->scale = aParamInfo->mDecimalDigits;

    sRet = _PyLong_AsByteArray( (PyLongObject*)sDigitLong,
                                sNum->val,
                                sizeof( sNum->val ),
                                1, /* little endian */
                                0 );
    
    Py_XDECREF( sDigitLong );
    if( sRet != 0 )
    {
        PyErr_Clear();
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "Numeric overflow" );
        return FALSE;
    }
    
    *aOutBuf += aParamInfo->mBufferLength;
    
    *aInd = sizeof( SQL_NUMERIC_STRUCT );

    return TRUE;
}

int PyToCType( Cursor     * aCursor,
               char      ** aOutBuf,
               PyObject   * aData,
               ParamInfo  * aParamInfo )
{
    PyObject * sClass = NULL;
    // TODO: Any way to make this a switch (O(1)) or similar instead of if-else chain?
    // TODO: Otherwise, rearrange these cases in order of frequency...
    SQLLEN     sInd;

    if( PyBool_Check( aData ) == TRUE )
    {
        if( aParamInfo->mValueType != SQL_C_BIT )
        {
            return FALSE;
        }
        
        WRITEOUT( char, aOutBuf, aData == Py_True, sInd );
    }
#if PY_MAJOR_VERSION < 3
    else if( PyInt_Check( aData ) == TRUE )
    {
        if( sizeof( long ) == 8 )
        {
            if( aParamInfo->mValueType != SQL_C_SBIGINT )
            {
                return FALSE;
            }
        }
        else
        {
            if( aParamInfo->mValueType != SQL_C_LONG )
            {
                return FALSE;
            }
        }
        
        WRITEOUT( long, aOutBuf, PyInt_AS_LONG( aData ), sInd );
    }
#endif
    else if( PyLong_Check( aData ) == TRUE )
    {
        if( SetLongType( aCursor,
                         aOutBuf,
                         aData,
                         aParamInfo,
                         &sInd ) == FALSE )
        {
            return FALSE;
        }
    }
    else if( PyFloat_Check( aData ) == TRUE )
    {
        if( aParamInfo->mValueType != SQL_C_DOUBLE )
        {
            return FALSE;
        }
        
        WRITEOUT( double, aOutBuf, PyFloat_AS_DOUBLE( aData ), sInd );
    }
    else if( PyBytes_Check( aData ) == TRUE )
    {
        if( SetBytesType( aCursor,
                          aOutBuf,
                          aData,
                          aParamInfo,
                          &sInd ) == FALSE )
        {
            return FALSE;
        }
    }
    else if( PyUnicode_Check( aData ) == TRUE )
    {
        if( SetUnicodeType( aCursor,
                            aOutBuf,
                            aData,
                            aParamInfo,
                            &sInd ) == FALSE )
        {
            return FALSE;
        }
    }
    else if( PyDateTime_Check( aData ) == TRUE )
    {
        if( SetTimestampType( aCursor,
                              aOutBuf,
                              aData,
                              aParamInfo,
                              &sInd ) == FALSE )
        {
            return FALSE;
        }
    }
    else if( PyDate_Check( aData ) == TRUE )
    {
        if( SetDateType( aCursor,
                         aOutBuf,
                         aData,
                         aParamInfo,
                         &sInd ) == FALSE )
        {
            return FALSE;
        }
    }
    else if( PyTime_Check( aData ) == TRUE )
    {
        if( SetTimeType( aCursor,
                         aOutBuf,
                         aData,
                         aParamInfo,
                         &sInd ) == FALSE )
        {
            return FALSE;
        }
    }
#if PY_VERSION_HEX >= 0x02060000
    else if( PyByteArray_Check( aData ) == TRUE )
    {
        if( SetByteArrayType( aCursor,
                              aOutBuf,
                              aData,
                              aParamInfo,
                              &sInd ) == FALSE )
        {
            return FALSE;
        }
    }
#endif
#if PY_MAJOR_VERSION < 3
    else if( PyBuffer_Check( aData ) == TRUE )
    {
        if( SetBufferType( aCursor,
                           aOutBuf,
                           aData,
                           aParamInfo,
                           &sInd ) == FALSE )
        {
            return FALSE;
        }
    }
#endif
    else if( IsInstanceForThread( aData, "decimal", "Decimal", &sClass ) &&
             (sClass != NULL) )
    {
        if( SetDecimalType( aCursor,
                            aOutBuf,
                            aData,
                            aParamInfo,
                            &sInd ) == FALSE )
        {
            return FALSE;
        }
    }
    else if( aData == Py_None )
    {
        *aOutBuf += aParamInfo->mBufferLength;
        sInd = SQL_NULL_DATA;
    }
    else
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "Unknown object type: %s",
                     aData->ob_type->tp_name );
        return FALSE;
    }
    
    *(SQLLEN*)(*aOutBuf) = sInd;
    *aOutBuf += sizeof( SQLLEN );

    return TRUE;
}



static PyObject * GetPyDecimal( Cursor * aCursor,
                                char   * aData,
                                SQLLEN   aDataLen )
{
    /**
     * The SQL_NUMERIC_STRUCT support is hopeless
     * (SQL Server ignores scale on input parameters and output columns,
     * Oracle does something else weird, and many drivers don't support it at all),
     * so we'll rely on the Decimal's string parsing.
     *
     * Unfortunately, the Decimal author does not pay attention to the locale, so we have to modify
     * the string ourselves.
     *
     * Oracle inserts group separators (commas in US, periods in some countries),
     * so leave room for that too.
     *
     * Some databases support a 'money' type which also inserts currency symbols.
     * Since we don't want to keep track of all these, we'll ignore all characters we don't recognize.
     * We will look for digits, negative sign (which I hope is universal), and a decimal point
     * ('.' or ',' usually).
     * We'll do everything as Unicode in case currencies, etc. are too far out.
     */
    Connection * sCnxn = GetConnection( aCursor );
    Encoding   * sEncoding = &sCnxn->mReadingEnc;
    PyObject   * sEncodedData;
    char       * sPtr;
    Py_ssize_t   sPyLen;
    int          sInt;
#if PY_MAJOR_VERSION < 3
    PyObject   * sTemp = NULL;
#endif
    // TODO: Why is this limited to 100?  Also, can we perform a check on the original and use
    // it as-is?
    char         sAscii[100];
    size_t       sAsciiLen = 0;
    char       * sPtrMax;
    PyObject   * sStr;
    PyObject   * sDecimalType;
    PyObject   * sDecimal;

    /* sEncodedData = PyUnicode_DecodeUTF8( (char*)aData, */
    /*                                      aDataLen, */
    /*                                      "strict" ); */
    sEncodedData = TextToPyObject( sEncoding, aData, aDataLen );

    TRY( sEncodedData != NULL );
    
    // Remove non-digits and convert the databases decimal to a '.' (required by decimal ctor).
    //
    // We are assuming that the decimal point and digits fit within the size of ODBCCHAR.

    // If Unicode, convert to UTF-8 and copy the digits and punctuation out.  Since these are
    // all ASCII characters, we can ignore any multiple-byte characters.  Fortunately, if a
    // character is multi-byte all bytes will have the high bit set.

#if PY_MAJOR_VERSION >= 3
    if( PyUnicode_Check( sEncodedData ) == TRUE )
    {
        sPtr = PyUnicode_AsUTF8AndSize( sEncodedData, &sPyLen );
    }
    else
    {
        sInt = PyBytes_AsStringAndSize( sEncodedData, &sPtr, &sPyLen );
        
        if( sInt < 0 )
        {
            sPtr = NULL;
        }
    }
#else
    if( PyUnicode_Check( sEncodedData ) == TRUE )
    {
        sTemp = PyUnicode_AsUTF8String( sEncodedData );
        TRY( sTemp != NULL );

        sEncodedData = sTemp;
    }
    
    sInt = PyString_AsStringAndSize( sEncodedData, &sPtr, &sPyLen );
    if( sInt < 0 )
    {
        sPtr = NULL;
    }
#endif

    TRY( sPtr != NULL );

    sPtrMax = sPtr + sPyLen;
    
    while( sPtr < sPtrMax )
    {
        if( (*sPtr & 0x80) == 0 )
        {
            if( *sPtr == gChDecimal )
            {
                // Must force it to use '.' since the Decimal class doesn't pay attention to the locale.
                sAscii[sAsciiLen] = '.';
                sAsciiLen++;
            }
            else if( ((*sPtr >= '0') && (*sPtr <= '9')) || (*sPtr == '-') )
            {
                sAscii[sAsciiLen] = (char)(*sPtr);
                sAsciiLen++;
            }
        }
        
        sPtr++;
    }

    sAscii[ sAsciiLen ] = '\0';

    sStr = PyString_FromStringAndSize( sAscii, (Py_ssize_t)sAsciiLen );
    TRY( sStr != NULL );
    
    sDecimalType = GetClassForThread( "decimal", "Decimal" );
    
    TRY( sDecimalType != NULL );
    
    sDecimal = PyObject_CallFunction( sDecimalType, "O", sStr );

    Py_DECREF( sDecimalType );
    Py_XDECREF( sEncodedData );
    Py_XDECREF( sStr );
    
    return sDecimal;
    
    FINISH;

    return NULL;
}


PyObject * CToPyTypeBySQLType( Cursor      * aCursor,
                               SQLSMALLINT   aSqlType,
                               void        * aValue,
                               SQLULEN       aColumnSize,
                               SQLSMALLINT   aDecimalDigits,
                               SQLLEN        aLen )
{
    Connection           * sCnxn = GetConnection( aCursor );
    Encoding             * sEnc = &sCnxn->mReadingEnc;
    SQL_TIMESTAMP_STRUCT * sValue;
    
    if( aLen == SQL_NULL_DATA )
    {
        Py_RETURN_NONE;
    }
    
    switch( aSqlType )
    {
        case SQL_VARCHAR:
        case SQL_CHAR:
            return TextToPyObject( sEnc, aValue, aLen );
        case SQL_VARBINARY:
        case SQL_BINARY:
#if PY_MAJOR_VERSION >= 3
            return PyBytes_FromStringAndSize( (char*)aValue, aLen );
#else
            return PyByteArray_FromStringAndSize((char*)aValue, aLen );
#endif
        case SQL_BOOLEAN:
        case SQL_BIT:
            if( *(SQLCHAR*)aValue == SQL_TRUE )
            {
                Py_RETURN_TRUE;
            }
            Py_RETURN_FALSE;
        case SQL_SMALLINT:
            return PyInt_FromLong( *(SQLSMALLINT*)aValue );
        case SQL_INTEGER:
            return PyInt_FromLong( *(SQLINTEGER*)aValue );
        case SQL_FLOAT:
        case SQL_REAL:
        case SQL_DOUBLE:
            return PyFloat_FromDouble( *(double*)aValue );
        case SQL_BIGINT:
            return PyLong_FromLongLong(*(PY_LONG_LONG*)aValue );
        case SQL_DECIMAL:
        case SQL_NUMERIC:
            if( (aDecimalDigits == 0) && (aColumnSize <= 19) )
            {
                if( aColumnSize <= 10 )
                {
                    return PyInt_FromLong( *(long*) aValue );
                }

                return PyLong_FromLongLong( *(PY_LONG_LONG*)aValue );
            }
            
            return GetPyDecimal( aCursor, aValue, aLen );
        case SQL_TYPE_DATE:
            sValue = (SQL_TIMESTAMP_STRUCT*)aValue;
            return PyDate_FromDate( sValue->year,
                                    sValue->month,
                                    sValue->day );
        case SQL_TYPE_TIME:
            sValue = (SQL_TIMESTAMP_STRUCT*)aValue;
            return PyTime_FromTime( sValue->hour,
                                    sValue->minute,
                                    sValue->second,
                                    sValue->fraction / 1000 ); //nanos -->micors
        case SQL_TYPE_TIMESTAMP:
            sValue = (SQL_TIMESTAMP_STRUCT*)aValue;
            return PyDateTime_FromDateAndTime( sValue->year,
                                               sValue->month,
                                               sValue->day,
                                               sValue->hour,
                                               sValue->minute,
                                               sValue->second,
                                               sValue->fraction / 1000 ); //nanos -->micors
        case SQL_TYPE_TIME_WITH_TIMEZONE:
        case SQL_TYPE_TIMESTAMP_WITH_TIMEZONE:
        case SQL_C_INTERVAL_YEAR :
        case SQL_C_INTERVAL_MONTH :
        case SQL_C_INTERVAL_DAY :
        case SQL_C_INTERVAL_HOUR :
        case SQL_C_INTERVAL_MINUTE :
        case SQL_C_INTERVAL_SECOND :
        case SQL_C_INTERVAL_YEAR_TO_MONTH :
        case SQL_C_INTERVAL_DAY_TO_HOUR :
        case SQL_C_INTERVAL_DAY_TO_MINUTE :
        case SQL_C_INTERVAL_DAY_TO_SECOND :
        case SQL_C_INTERVAL_HOUR_TO_MINUTE :
        case SQL_C_INTERVAL_HOUR_TO_SECOND :
        case SQL_C_INTERVAL_MINUTE_TO_SECOND :
            return TextToPyObject( sEnc, aValue, aLen );
        default:
            break;
    }

    return RaiseErrorV( NULL,
                        ProgrammingError,
                        "Unknown sql type: %d",
                        aSqlType );
}

PyObject * CToPyTypeByCType( Cursor      * aCursor,
                             SQLSMALLINT   aCType,
                             void        * aValue,
                             SQLSMALLINT   aSQLType,
                             SQLULEN       aColumnSize,
                             SQLSMALLINT   aDecimalDigits,
                             SQLLEN        aLen )
{
    Connection           * sCnxn = GetConnection( aCursor );
    Encoding             * sEncoding = &sCnxn->mReadingEnc;
    SQL_DATE_STRUCT      * sDate; 
    SQL_TIME_STRUCT      * sTime;
    SQL_TIMESTAMP_STRUCT * sTms;
    PyObject             * sPyObject = NULL;
    PyObject             * sEncoded;
    Py_ssize_t             sEncodedLen;
#if PY_MAJOR_VERSION < 3 
    PyObject             * sTemp = NULL;
#endif
    char                 * sPtr;
    char                 * sPtrEnd;
    char                   sAscii[100];  	 	 
    Py_ssize_t             sAsciiLen = 0; 
    PyObject             * sStrObject;  	 	 
    PyObject             * sDecimalType;
    
    if( aLen == SQL_NULL_DATA )
    {
        Py_RETURN_NONE;
    }

    switch( aCType )
    {
        case SQL_C_CHAR:
            if( (aSQLType == SQL_DECIMAL) || (aSQLType == SQL_NUMERIC) )
            {
                sEncoded = TextToPyObject( sEncoding,
                                           aValue,
                                           aLen );
#if PY_MAJOR_VERSION >= 3
                if( PyUnicode_Check( sEncoded ) == TRUE )
                {
                    sPtr = PyUnicode_AsUTF8AndSize( sEncoded, &sEncodedLen );
                }
                else
                {
                    if( PyBytes_AsStringAndSize( sEncoded, &sPtr, &sEncodedLen ) < 0 )
                    {
                        sPtr = NULL;
                    }
                }
#else
                if( PyUnicode_Check( sEncoded ) == TRUE )
                {
                    sTemp = PyUnicode_AsUTF8String( sEncoded );
                    TRY( sTemp != NULL );

                    sEncoded = sTemp;
                }

                if( PyString_AsStringAndSize( sEncoded, &sPtr, &sEncodedLen ) < 0 )
                {
                    sPtr = NULL;
                }
#endif
                TRY( sPtr != NULL );

                sPtrEnd = sPtr + sEncodedLen;

                while( sPtr < sPtrEnd )
                {
                    if( (*sPtr & 0x80) == 0 )
                    {
                        if( *sPtr == gChDecimal )
                        {
                            sAscii[ sAsciiLen ] = '.';
                            sAsciiLen++;
                        }
                        else if( ((*sPtr >= '0') && (*sPtr <= '9')) ||
                                 (*sPtr == '-') )
                        {
                            sAscii[ sAsciiLen ] = (char)(*sPtr);
                            sAsciiLen++;
                        }
                    }
                        
                    sPtr++;
                }

                sAscii[ sAsciiLen ] = '\0';

                sStrObject = PyString_FromStringAndSize( sAscii, sAsciiLen );
                TRY( sStrObject );
                    
                sDecimalType = GetClassForThread( "decimal", "Decimal" );

                TRY( sDecimalType != NULL );

                sPyObject = PyObject_CallFunction( sDecimalType, "O", sStrObject );

                TRY( !PyErr_Occurred() );
#if PY_MAJOR_VERSION < 3
                Py_XDECREF( sTemp );
#endif
                Py_XDECREF( sDecimalType );
                Py_XDECREF( sEncoded );
                Py_XDECREF( sStrObject );

                
            }
            else
            {
                sPyObject = TextToPyObject( sEncoding,
                                            aValue,
                                            aLen );
            }

            return sPyObject;
        case SQL_C_BINARY:
#if PY_MAJOR_VERSION >= 3
            sPyObject = PyBytes_FromStringAndSize( (char*)aValue, aLen );
#else
            sPyObject = PyByteArray_FromStringAndSize( (char*)aValue, aLen );
#endif
            break;
        case SQL_C_BIT:
            if( (*(SQLCHAR*)aValue) == SQL_TRUE )
            {
                sPyObject = Py_True;
                Py_INCREF( Py_True );
            }
            else
            {
                sPyObject = Py_False;
                Py_INCREF( Py_False );
            }
            break;
        case SQL_C_TYPE_TIMESTAMP:
            sTms = (SQL_TIMESTAMP_STRUCT*)aValue;
            sPyObject = PyDateTime_FromDateAndTime( sTms->year,
                                                    sTms->month,
                                                    sTms->day,
                                                    sTms->hour,
                                                    sTms->minute,
                                                    sTms->second,
                                                    ((int)sTms->fraction / 1000) );
            break;
        case SQL_C_TYPE_TIME:
            sTime = (SQL_TIME_STRUCT*)aValue,
            sPyObject = PyTime_FromTime( sTime->hour,
                                         sTime->minute,
                                         sTime->second,
                                         0 );
            break;
        case SQL_C_TYPE_DATE:
            sDate = (SQL_DATE_STRUCT*)aValue;
            sPyObject = PyDate_FromDate( sDate->year,
                                         sDate->month,
                                         sDate->day);
            break;
        case SQL_C_DOUBLE:
            sPyObject = PyFloat_FromDouble( *(double*)aValue );
            break;
        case SQL_C_SBIGINT:
            sPyObject = PyLong_FromLongLong( *(PY_LONG_LONG*)aValue );
            break;
        case SQL_C_LONG:
            sPyObject = PyInt_FromLong( *(SQLINTEGER*)aValue );
            break;
        default:
            DASSERT( FALSE );
            break;
    }

    return sPyObject;

    FINISH;

    return NULL;
}

SQLSMALLINT SQLTypeToCType( SQLSMALLINT aSqlType )
{
    switch( aSqlType  )
    {
        case SQL_BOOLEAN:
        case SQL_BIT:
            return SQL_C_BIT;
        case SQL_BINARY:
        case SQL_VARBINARY:
        case SQL_LONGVARBINARY:
            return SQL_C_BINARY;
        case SQL_SMALLINT:
            return SQL_C_SHORT;
        case SQL_INTEGER:
            return SQL_C_LONG;
        case SQL_BIGINT:
            return SQL_C_SBIGINT;
        case SQL_FLOAT:
        case SQL_REAL:
        case SQL_DOUBLE:
            return SQL_C_DOUBLE;
        case SQL_DECIMAL:
        case SQL_NUMERIC:
            return SQL_C_CHAR;
        case SQL_TYPE_DATE:
            return SQL_C_TYPE_DATE;
        case SQL_TYPE_TIME:
            return SQL_C_TYPE_TIME;
        case SQL_TYPE_TIMESTAMP:
            return SQL_C_TYPE_TIMESTAMP;                  
        case SQL_CHAR:
        case SQL_VARCHAR:
        case SQL_LONGVARCHAR:
        case SQL_TYPE_TIME_WITH_TIMEZONE:
        case SQL_TYPE_TIMESTAMP_WITH_TIMEZONE:
        case SQL_C_INTERVAL_YEAR :
        case SQL_C_INTERVAL_MONTH :
        case SQL_C_INTERVAL_DAY :
        case SQL_C_INTERVAL_HOUR :
        case SQL_C_INTERVAL_MINUTE :
        case SQL_C_INTERVAL_SECOND :
        case SQL_C_INTERVAL_YEAR_TO_MONTH :
        case SQL_C_INTERVAL_DAY_TO_HOUR :
        case SQL_C_INTERVAL_DAY_TO_MINUTE :
        case SQL_C_INTERVAL_DAY_TO_SECOND :
        case SQL_C_INTERVAL_HOUR_TO_MINUTE :
        case SQL_C_INTERVAL_HOUR_TO_SECOND :
        case SQL_C_INTERVAL_MINUTE_TO_SECOND :
        default:
            return SQL_C_CHAR;
    }
}

bool IsSamePyTypeWithCType( PyObject  * aPyData,
                            ParamInfo * aParamInfo )
{
    PyObject * sClass = NULL;
    
    if( PyBool_Check( aPyData ) == TRUE )
    {
        if( aParamInfo->mValueType == SQL_C_BIT )
        {
            return TRUE;
        }
    }
#if PY_MAJOR_VERSION < 3
    else if( PyInt_Check( aPyData ) == TRUE )
    {
        if( sizeof( long ) == 8 )
        {
            if( aParamInfo->mValueType == SQL_C_SBIGINT )
            {
                return TRUE;
            }
        }
        else
        {
            if( aParamInfo->mValueType == SQL_C_LONG )
            {
                return TRUE;
            }
        }
    }
#endif
    else if( PyLong_Check( aPyData ) == TRUE )
    {
        (void)PyLong_AsLongLong( aPyData );
        if( PyErr_Occurred() )
        {
            PyErr_Clear();
            
            if( aParamInfo->mValueType == SQL_C_NUMERIC )
            {
                return TRUE;
            }
        }
        else
        {
            if( (aParamInfo->mParameterType == SQL_NUMERIC) ||
                (aParamInfo->mParameterType == SQL_DECIMAL) )
            {
                if( aParamInfo->mValueType == SQL_C_NUMERIC )
                {
                    return TRUE;
                }
            }
            else
            {
                if( aParamInfo->mValueType == SQL_C_SBIGINT )
                {
                    return TRUE;
                }
            }
        }
    }
    else if( PyFloat_Check( aPyData ) == TRUE )
    {
        if( aParamInfo->mValueType == SQL_C_DOUBLE )
        {
            return TRUE;
        }
    }
    else if( PyBytes_Check( aPyData ) == TRUE )
    {
#if PY_MAJOR_VERSION < 3
        if( aParamInfo->mValueType == SQL_C_CHAR )
#else
        if( aParamInfo->mValueType == SQL_C_BINARY )
#endif
        {
            return TRUE;
        }
    }
    else if( PyUnicode_Check( aPyData ) == TRUE )
    {
        // Assume the SQL type is also wide character.
        // If it is a max-type (ColumnSize == 0), use DAE.
        if( sizeof( Py_UNICODE ) != sizeof( SQLWCHAR ) )
        {
            if( aParamInfo->mValueType == SQL_C_CHAR )
            {
                return TRUE;
            }
        }
        else
        {
            if( aParamInfo->mValueType == SQL_C_WCHAR )
            {
                return TRUE;
            }
        }
    }
    else if( PyDateTime_Check( aPyData ) == TRUE )
    {
        if( aParamInfo->mValueType == SQL_C_TYPE_TIMESTAMP )
        {
            return TRUE;
        }
    }
    else if( PyDate_Check( aPyData ) == TRUE )
    {
        if( aParamInfo->mValueType == SQL_C_TYPE_DATE )
        {
            return TRUE;
        }
    }
    else if( PyTime_Check( aPyData ) == TRUE )
    {
        if( aParamInfo->mValueType == SQL_C_TYPE_TIME )
        {
            return TRUE;
        }
    }
#if PY_VERSION_HEX >= 0x02060000
    else if( PyByteArray_Check( aPyData ) == TRUE )
    {
        if( aParamInfo->mValueType == SQL_C_BINARY )
        {
            return TRUE;
        }
    }
#endif
#if PY_MAJOR_VERSION < 3
    else if( PyBuffer_Check( aPyData ) == TRUE )
    {
        if( aParamInfo->mValueType == SQL_C_BINARY )
        {
            return TRUE;
        }
    }
#endif
    else if( aPyData == Py_None )
    {
        switch( aParamInfo->mParameterType )
        {
            case SQL_CHAR:
            case SQL_VARCHAR:
            case SQL_LONGVARCHAR:
#if PY_MAJOR_VERSION < 3
                if( aParamInfo->mValueType == SQL_C_CHAR )
#else
                if( aParamInfo->mValueType == SQL_C_BINARY )
#endif
                {
                    return TRUE;
                }
                break;
            case SQL_DECIMAL:
            case SQL_NUMERIC:
                if( aParamInfo->mValueType == SQL_C_NUMERIC )
                {
                    return TRUE;
                }
                break;
            case SQL_BIGINT:
                if( (aParamInfo->mParameterType == SQL_NUMERIC) ||
                    (aParamInfo->mParameterType == SQL_DECIMAL) )
                {
                    if( aParamInfo->mValueType == SQL_C_NUMERIC )
                    {
                        return TRUE;
                    }
                }
                else
                {
                    if( aParamInfo->mValueType == SQL_C_SBIGINT )
                    {
                        return TRUE;
                    }
                }
                break;
            case SQL_SMALLINT:
            case SQL_INTEGER:
            case SQL_TINYINT:
#if PY_MAJOR_VERSION < 3
                if( sizeof( long ) == 8 )
                {
                    if( aParamInfo->mValueType == SQL_C_SBIGINT )
                    {
                        return TRUE;
                    }
                }
                else
                {
                    if( aParamInfo->mValueType == SQL_C_LONG )
                    {
                        return TRUE;
                    }
                }
#else
                if( (aParamInfo->mParameterType == SQL_NUMERIC) ||
                    (aParamInfo->mParameterType == SQL_DECIMAL) )
                {
                    if( aParamInfo->mValueType == SQL_C_NUMERIC )
                    {
                        return TRUE;
                    }
                }
                else
                {
                    if( aParamInfo->mValueType == SQL_C_SBIGINT )
                    {
                        return TRUE;
                    }
                }
#endif
                break;
            case SQL_REAL:
            case SQL_FLOAT:
            case SQL_DOUBLE:
                if( aParamInfo->mValueType == SQL_C_DOUBLE )
                {
                    return TRUE;
                }
                break;
            case SQL_BIT:
                if( aParamInfo->mValueType == SQL_C_BIT )
                {
                    return TRUE;
                }
                break;
            case SQL_BINARY:
            case SQL_VARBINARY:
            case SQL_LONGVARBINARY:
#if PY_VERSION_HEX >= 0x02060000
                if( aParamInfo->mValueType == SQL_C_BINARY )
                {
                    return TRUE;
                }
#else
#if PY_MAJOR_VERSION < 3
                if( aParamInfo->mValueType == SQL_C_CHAR )
                {
                    return TRUE;
                }
#else
                if( aParamInfo->mValueType == SQL_C_BINARY )
                {
                    return TRUE;
                }
#endif
#endif
                break;
            case SQL_TYPE_DATE:
                if( aParamInfo->mValueType == SQL_C_TYPE_DATE )
                {
                    return TRUE;
                }
                break;
            case SQL_TYPE_TIME:
                if( aParamInfo->mValueType == SQL_C_TYPE_TIME )
                {
                    return TRUE;
                }
                break;
            case SQL_TYPE_TIMESTAMP:
                if( aParamInfo->mValueType == SQL_C_TYPE_TIMESTAMP )
                {
                    return TRUE;
                }
                break;
            default:
#if PY_MAJOR_VERSION < 3
                if( aParamInfo->mValueType == SQL_C_CHAR )
                {
                    return TRUE;
                }
#else
                if( aParamInfo->mValueType == SQL_C_BINARY )
                {
                    return TRUE;
                }
#endif
                break;
        }
    }
    else if( (IsInstanceForThread( aPyData, "decimal", "Decimal", &sClass ) == TRUE) &&
             (sClass != NULL) )
    {
        if( aParamInfo->mValueType == SQL_C_NUMERIC )
        {
            return TRUE;
        }
    }
    else
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "Unknown object type %s during describe",
                     aPyData->ob_type->tp_name );
        
        return FALSE;
    }

    return FALSE;
}
