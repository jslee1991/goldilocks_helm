/*******************************************************************************
 * param.c
 *
 * Copyright (c) 2011, SUNJESOFT Inc.
 *
 *
 * IDENTIFICATION & REVISION
 *        $Id: param.c 33240 2021-03-15 07:08:33Z lkh $
 *
 * NOTES
 *
 *
 ******************************************************************************/

/**
 * @file param.c
 * @brief Python Parameters for Goldilocks Python Database API
 */

/**
 * @addtogroup Param
 * @{
 */

/**
 * @brief External
 */

#include <pydbc.h>
#include <param.h>
#include <connection.h>
#include <cursor.h>
#include <buffer.h>
#include <error.h>
#include <module.h>
#include <type.h>
#include <encoding.h>
#include <datetime.h>

PyObject * gNullBinary;

STATUS FreeParameterInfos( Cursor * aCursor )
{
    ParamInfo * sParamInfos = NULL;
    int         i;

    if( aCursor->mParamInfos != NULL )
    {
        sParamInfos = aCursor->mParamInfos;
        
        for( i = 0; i < aCursor->mParamCount; i++ )
        {
            if( sParamInfos[i].mValueAllocated == TRUE )
            {
                free( sParamInfos[i].mParameterValuePtr );
            }
        }

        free( aCursor->mParamInfos );
        aCursor->mParamInfos = NULL;
    }

    return SUCCESS;
}


static bool CompareParameterInfo( ParamInfo   * aInfo,
                                  SQLSMALLINT   aCtype,
                                  SQLSMALLINT   aSqlType,
                                  SQLULEN       aColumnSize,
                                  SQLSMALLINT   aDecimalDigits )
{
    if( aInfo->mValueType != aCtype )
    {
        return FALSE;
    }

    if( aInfo->mParameterType != aSqlType )
    {
        return FALSE;
    }

    if( aInfo->mColumnSize != aColumnSize )
    {
        return FALSE;
    }

    if( aInfo->mDecimalDigits != aDecimalDigits )
    {
        return FALSE;
    }
    
    return TRUE;
}

static bool GetNullInfo( Cursor     * aCursor,
                         Py_ssize_t   aIndex,
                         ParamInfo  * aInfo )
{
    SQLRETURN   sRet;
    SQLULEN     sParameterSizePtr;
    SQLSMALLINT sDecimalDigitsPtr;
    SQLSMALLINT sNullablePtr;
    SQLSMALLINT sParameterType;
    
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLDescribeParam( aCursor->mHStmt,
                             (SQLUSMALLINT)(aIndex + 1),
                             &sParameterType,
                             &sParameterSizePtr,
                             &sDecimalDigitsPtr,
                             &sNullablePtr );
    Py_END_ALLOW_THREADS;

    if( !SQL_SUCCEEDED( sRet ) )
    {
        sParameterType = SQL_VARCHAR;
    }

    if( CompareParameterInfo( aInfo,
                              SQL_C_DEFAULT,  /* aCtype */
                              sParameterType, /* aSqlType */
                              1,              /* aColumnSize */
                              0 )             /* aDecimalDigts */
        == FALSE )
    {
        aInfo->mNeedBindParameter = TRUE;
        aInfo->mValueType         = SQL_C_DEFAULT;
        aInfo->mParameterType     = sParameterType;
        aInfo->mColumnSize        = 1;
        aInfo->mDecimalDigits     = 0;
        aInfo->mStrLen_or_Ind     = SQL_NULL_DATA;
        aInfo->mBufferLength      = 0;
        aInfo->mParameterValuePtr = NULL;
    }
    
    return TRUE;
}

static bool GetNullBinaryInfo( Cursor     * aCursor,
                               Py_ssize_t   aIndex,
                               PyObject   * aParam,
                               ParamInfo  * aInfo )

{    
    if( CompareParameterInfo( aInfo,
                              SQL_C_BINARY, /* aCtype */
                              SQL_BINARY,   /* aSqlType */
                              1,            /* aColumnSize */
                              0 )           /* aDecimalDigts */
        == FALSE )
    {
        aInfo->mNeedBindParameter = TRUE;
        aInfo->mValueType         = SQL_C_BINARY;
        aInfo->mParameterType     = SQL_BINARY;
        aInfo->mColumnSize        = 1;
        aInfo->mDecimalDigits     = 0;
        aInfo->mStrLen_or_Ind     = SQL_NULL_DATA;
        aInfo->mBufferLength      = 0;
        aInfo->mParameterValuePtr = NULL;
    }
    
    return TRUE;
}

#if PY_MAJOR_VERSION >= 3
static bool GetBytesInfo( Cursor     * aCursor,
                          Py_ssize_t   aIndex,
                          PyObject   * aParam,
                          ParamInfo  * aInfo )
{   // In Python 3, it is passed as binary.

    Py_ssize_t    sLen = PyBytes_GET_SIZE( aParam );
    Connection  * sConnection = GetConnection( aCursor );
    SQLLEN        sMaxLength;
    SQLSMALLINT   sValueType;
    SQLSMALLINT   sParameterType;
    SQLULEN       sColumnSize;
    
    sValueType = SQL_C_BINARY;
    sColumnSize = (SQLULEN)MAX(sLen, 1);

    sMaxLength = GetMaxLength( sConnection, sValueType );
    
    if( sLen <= sMaxLength )
    {
        sParameterType  = SQL_VARBINARY;
        aInfo->mStrLen_or_Ind    = sLen;
        aInfo->mBufferLength     = (SQLLEN)sColumnSize;
        aInfo->mParameterValuePtr = PyBytes_AS_STRING( aParam );
    }
    else
    {
        // Too long to pass all at once, so we'll provide the data at execute.
        sParameterType  = SQL_LONGVARBINARY;
        aInfo->mStrLen_or_Ind= SQL_DATA_AT_EXEC;
        aInfo->mParameterValuePtr = aInfo;
        aInfo->mBufferLength = sizeof( ParamInfo* );
        aInfo->mParam = aParam;
        Py_INCREF( aInfo->mParam );
        aInfo->mMaxLength = sMaxLength;
    }

    if( CompareParameterInfo( aInfo,
                              sValueType,     /* aCtype */
                              sParameterType, /* aSqlType */
                              sColumnSize,    /* aColumnSize */
                              0 )             /* aDecimalDigts */
        == FALSE )
    {
        aInfo->mNeedBindParameter = TRUE;
        aInfo->mValueType         = sValueType;
        aInfo->mParameterType     = sParameterType;
        aInfo->mColumnSize        = sColumnSize;
        aInfo->mDecimalDigits     = 0;
    }
    
    return TRUE;
}
#endif

#if PY_MAJOR_VERSION < 3
static bool GetStrInfo( Cursor     * aCursor,
                        Py_ssize_t   aIndex,
                        PyObject   * aParam,
                        ParamInfo  * aInfo )
{
    Connection  * sCnxn;
    Encoding    * sEncoding;
    Py_ssize_t    sSize;
    SQLLEN        sMaxLength;
    SQLSMALLINT   sValueType;
    SQLSMALLINT   sParameterType;
    SQLULEN       sColumnSize;
    
    sCnxn = GetConnection( aCursor );
    sEncoding = &sCnxn->mWritingEnc;
    
    sValueType = sEncoding->mCType;
    sSize = PyBytes_GET_SIZE( aParam );

    sColumnSize = (SQLULEN)MAX( sSize, 1 );

    sMaxLength = GetMaxLength( sCnxn, sValueType );
    
    if( (sMaxLength == 0) || (sSize <= sMaxLength) )
    {
        sParameterType = SQL_VARCHAR;
        aInfo->mStrLen_or_Ind     = (SQLINTEGER)sSize;
        aInfo->mBufferLength      = (SQLLEN)sColumnSize;
        aInfo->mParameterValuePtr = PyBytes_AS_STRING( aParam );
    }
    else
    {
        // Too long to pass all at once, so we'll provide the data at execute.
        sParameterType = SQL_LONGVARCHAR;        
        aInfo->mParameterValuePtr = aInfo;
        aInfo->mBufferLength      = sizeof( ParamInfo *);
        aInfo->mStrLen_or_Ind     = SQL_DATA_AT_EXEC;
        aInfo->mMaxLength         = sMaxLength;
        aInfo->mParam             = aParam;
        Py_INCREF( aInfo->mParam );
    }

    if( CompareParameterInfo( aInfo,
                              sValueType,     /* aCtype */
                              sParameterType, /* aSqlType */
                              sColumnSize,    /* aColumnSize */
                              0 )             /* aDecimalDigts */
        == FALSE )
    {
        aInfo->mNeedBindParameter = TRUE;
        aInfo->mValueType         = sValueType;
        aInfo->mParameterType     = sParameterType;
        aInfo->mColumnSize        = sColumnSize;
        aInfo->mDecimalDigits     = 0;
    }
    
    return TRUE;
}
#endif


static bool GetUnicodeInfo( Cursor     * aCursor,
                            Py_ssize_t   aIndex,
                            PyObject   * aParam,
                            ParamInfo  * aInfo )
{
    Encoding    * sEncoding;
    Connection  * sCnxn = GetConnection( aCursor );
    Py_ssize_t    sSize;
    PyObject    * sEncoded = NULL;
    SQLLEN        sMaxLength;
    SQLSMALLINT   sValueType;
    SQLSMALLINT   sParameterType;
    SQLULEN       sColumnSize;
    
    sEncoding = &sCnxn->mWritingEnc;//UnicodeEnc;
    
    sValueType = sEncoding->mCType;

    sSize = PyUnicode_GET_SIZE( aParam );

    sColumnSize = (SQLULEN)MAX( sSize, 1 );

    sEncoded = PyCodec_Encode( aParam, sEncoding->mName, "strict" );
    TRY( sEncoded != NULL );
    
    TRY_THROW( PyBytes_CheckExact( sEncoded ) == TRUE,
               RAMP_ERR_UNEXPECTED_DATA_TYPE );

    sSize = PyBytes_GET_SIZE( sEncoded );
    
    aInfo->mParam = sEncoded;

    sMaxLength = GetMaxLength( sCnxn, sEncoding->mCType );

    if( (sMaxLength == 0) || (sSize <= sMaxLength) )
    {
        sParameterType  = SQL_VARCHAR;
        aInfo->mParameterValuePtr = PyBytes_AS_STRING( aInfo->mParam );
        aInfo->mBufferLength      = (SQLLEN)sSize;
        aInfo->mStrLen_or_Ind     = (SQLLEN)sSize;
    }
    else
    {
        // Too long to pass all at once, so we'll provide the data at execute.
        sParameterType  = SQL_LONGVARCHAR;
        aInfo->mParameterValuePtr = aInfo;
        aInfo->mBufferLength      = sizeof( ParamInfo* );
        aInfo->mStrLen_or_Ind     = SQL_DATA_AT_EXEC;
        aInfo->mMaxLength         = sMaxLength;
    }

    if( CompareParameterInfo( aInfo,
                              sValueType,     /* aCtype */
                              sParameterType, /* aSqlType */
                              sColumnSize,    /* aColumnSize */
                              0 )             /* aDecimalDigts */
        == FALSE )
    {
        aInfo->mNeedBindParameter = TRUE;
        aInfo->mValueType         = sValueType;
        aInfo->mParameterType     = sParameterType;
        aInfo->mColumnSize        = sColumnSize;
        aInfo->mDecimalDigits     = 0;
    }
    
    return TRUE;

    CATCH( RAMP_ERR_UNEXPECTED_DATA_TYPE )
    {
        PyErr_Format( PyExc_TypeError,
                      "Unicode write encoding '%s' returned unexpected data type: %s",
                      sEncoding->mName,
                      Py_TYPE( sEncoded )->tp_name );
    }
    
    FINISH;

    return FALSE;
}


static bool GetBooleanInfo( Cursor     * aCursor,
                            Py_ssize_t   aIndex,
                            PyObject   * aParam,
                            ParamInfo  * aInfo )
{
    if( aParam == Py_True )
    {
        aInfo->mData.mBool = TRUE;
    }
    else
    {
        aInfo->mData.mBool = FALSE;
    }
    
    aInfo->mStrLen_or_Ind = 1;
    aInfo->mParameterValuePtr = &aInfo->mData.mBool;

    if( CompareParameterInfo( aInfo,
                              SQL_C_BIT,   /* aCtype */
                              SQL_BIT,     /* aSqlType */
                              0,           /* aColumnSize */
                              0 )          /* aDecimalDigts */
        == FALSE )
    {
        aInfo->mNeedBindParameter = TRUE;
        aInfo->mValueType         = SQL_C_BIT;
        aInfo->mParameterType     = SQL_BIT;
        aInfo->mColumnSize        = 0;
        aInfo->mDecimalDigits     = 0;
    }
    
    return TRUE;
}

static bool GetDateTimeInfo( Cursor     * aCursor,
                             Py_ssize_t   aIndex,
                             PyObject   * aParam,
                             ParamInfo  * aInfo )
{
    int           sPrecision;
    int           sKeep;
    Connection  * sCnxn = GetConnection( aCursor );
    SQLSMALLINT   sValueType;
    SQLSMALLINT   sParameterType;
    SQLULEN       sColumnSize;
    SQLSMALLINT   sDecimalDigits = 0;
    
    aInfo->mData.mTimestamp.year   = (SQLSMALLINT) PyDateTime_GET_YEAR( aParam );
    aInfo->mData.mTimestamp.month  = (SQLUSMALLINT)PyDateTime_GET_MONTH( aParam );
    aInfo->mData.mTimestamp.day    = (SQLUSMALLINT)PyDateTime_GET_DAY( aParam );
    aInfo->mData.mTimestamp.hour   = (SQLUSMALLINT)PyDateTime_DATE_GET_HOUR( aParam );
    aInfo->mData.mTimestamp.minute = (SQLUSMALLINT)PyDateTime_DATE_GET_MINUTE( aParam );
    aInfo->mData.mTimestamp.second = (SQLUSMALLINT)PyDateTime_DATE_GET_SECOND( aParam );

    // SQL Server chokes if the fraction has more data than the database supports.
    // We expect other databases to be the same, so we reduce the value to what the database supports.
    // http://support.microsoft.com/kb/263872

    sPrecision = sCnxn->mDatetimePrecision - 20; // (20 includes a separating period)

    if( sPrecision <= 0 )
    {
        aInfo->mData.mTimestamp.fraction = 0;
    }
    else
    {
        // 1000 == micro -> nano
        aInfo->mData.mTimestamp.fraction =
            (SQLUINTEGER)(PyDateTime_DATE_GET_MICROSECOND(aParam) * 1000);

        // (How many leading digits do we want to keep?
        // With SQL Server 2005, this should be 3: 123000000)
        sKeep = (int)pow( 10.0, 9 - MIN( 9, sPrecision ) );
        aInfo->mData.mTimestamp.fraction =
            (aInfo->mData.mTimestamp.fraction / (int) sKeep) * (int)sKeep;
        sDecimalDigits = (SQLSMALLINT)sPrecision;
    }

    sValueType     = SQL_C_TYPE_TIMESTAMP;
    sParameterType = SQL_TYPE_TIMESTAMP;
    sColumnSize    = (SQLUINTEGER)sCnxn->mDatetimePrecision;
    aInfo->mStrLen_or_Ind     = sizeof( SQL_TIMESTAMP_STRUCT );
    aInfo->mParameterValuePtr = &aInfo->mData.mTimestamp;

    if( CompareParameterInfo( aInfo,
                              sValueType,       /* aCtype */
                              sParameterType,   /* aSqlType */
                              sColumnSize,      /* aColumnSize */
                              sDecimalDigits ) /* aDecimalDigts */
        == FALSE )
    {
        aInfo->mNeedBindParameter = TRUE;
        aInfo->mValueType         = sValueType;
        aInfo->mParameterType     = sParameterType;
        aInfo->mColumnSize        = sColumnSize;
        aInfo->mDecimalDigits     = sDecimalDigits;
    }
    
    return TRUE;
}

static bool GetDateInfo( Cursor     * aCursor,
                         Py_ssize_t   aIndex,
                         PyObject   * aParam,
                         ParamInfo  * aInfo )
{
    aInfo->mData.mDate.year  = (SQLSMALLINT) PyDateTime_GET_YEAR( aParam );
    aInfo->mData.mDate.month = (SQLUSMALLINT)PyDateTime_GET_MONTH( aParam );
    aInfo->mData.mDate.day   = (SQLUSMALLINT)PyDateTime_GET_DAY( aParam );
    aInfo->mParameterValuePtr = &aInfo->mData.mDate;
    aInfo->mStrLen_or_Ind     = sizeof( SQL_DATE_STRUCT );

    if( CompareParameterInfo( aInfo,
                              SQL_C_TYPE_DATE,  /* aCtype */
                              SQL_TYPE_DATE,    /* aSqlType */
                              10,               /* aColumnSize */
                              0 )               /* aDecimalDigts */
        == FALSE )
    {
        aInfo->mNeedBindParameter = TRUE;
        aInfo->mValueType         = SQL_C_TYPE_DATE;
        aInfo->mParameterType     = SQL_TYPE_DATE;
        aInfo->mColumnSize        = 10;
        aInfo->mDecimalDigits     = 0;
    }
    
    return TRUE;
}

static bool GetTimeInfo( Cursor     * aCursor,
                         Py_ssize_t   aIndex,
                         PyObject   * aParam,
                         ParamInfo  * aInfo )
{
    aInfo->mData.mTime.hour   = (SQLUSMALLINT)PyDateTime_TIME_GET_HOUR( aParam );
    aInfo->mData.mTime.minute = (SQLUSMALLINT)PyDateTime_TIME_GET_MINUTE( aParam );
    aInfo->mData.mTime.second = (SQLUSMALLINT)PyDateTime_TIME_GET_SECOND( aParam );
    aInfo->mParameterValuePtr = &aInfo->mData.mTime;
    aInfo->mStrLen_or_Ind     = sizeof( SQL_TIME_STRUCT );

    if( CompareParameterInfo( aInfo,
                              SQL_C_TYPE_TIME,  /* aCtype */
                              SQL_TYPE_TIME,    /* aSqlType */
                              8,                /* aColumnSize */
                              0 )               /* aDecimalDigts */
        == FALSE )
    {
        aInfo->mNeedBindParameter = TRUE;
        aInfo->mValueType         = SQL_C_TYPE_TIME;
        aInfo->mParameterType     = SQL_TYPE_TIME;
        aInfo->mColumnSize        = 8;
        aInfo->mDecimalDigits     = 0;
    }
    
    return TRUE;
}

#if PY_MAJOR_VERSION < 3
static bool GetIntInfo( Cursor     * aCursor,
                        Py_ssize_t   aIndex,
                        PyObject   * aParam,
                        ParamInfo  * aInfo )
{
    SQLSMALLINT sValueType;
    SQLSMALLINT sParameterType;

#if LONG_BIT == 64
    aInfo->mData.mLongLong    = PyInt_AsLong( aParam );
    aInfo->mParameterValuePtr = &aInfo->mData.mLongLong;
    sValueType     = SQL_C_SBIGINT;
    sParameterType = SQL_BIGINT;
#elif LONG_BIT == 32
    aInfo->mData.mLong        = PyInt_AsLong( aParam );
    aInfo->mParameterValuePtr = &aInfo->mData.mLong;
    sValueType     = SQL_C_LONG;
    sParameterType = SQL_INTEGER;
#else
#error Unexpected LONG_BIT value
#endif

    if( CompareParameterInfo( aInfo,
                              sValueType,     /* aCtype */
                              sParameterType, /* aSqlType */
                              0,              /* aColumnSize */
                              0 )             /* aDecimalDigts */
        == FALSE )
    {
        aInfo->mNeedBindParameter = TRUE;
        aInfo->mValueType         = sValueType;
        aInfo->mParameterType     = sParameterType;
        aInfo->mColumnSize        = 0;
        aInfo->mDecimalDigits     = 0;
    }
    
    /* aInfo->mParameterValuePtr = &aInfo->mData.mInt32; */
    return TRUE;
}
#endif

static bool GetLongInfo( Cursor     * aCursor,
                         Py_ssize_t   aIndex,
                         PyObject   * aParam,
                         ParamInfo  * aInfo )
{
    /**
     *@note PyLong_AsLong 함수를 사용하면 overflow 감지를 못한다.
     * 작은 수와 큰 수 모두 허용하기 위해 PyLong_AsLongLong 함수를 사용한다.
     */ 
    aInfo->mData.mLongLong    = (INT64)PyLong_AsLongLong( aParam );
    aInfo->mParameterValuePtr = &aInfo->mData.mLongLong;

    if( CompareParameterInfo( aInfo,
                              SQL_C_SBIGINT,  /* aCtype */
                              SQL_BIGINT,     /* aSqlType */
                              0,              /* aColumnSize */
                              0 )             /* aDecimalDigts */
        == FALSE )
    {
        aInfo->mNeedBindParameter = TRUE;
        aInfo->mValueType         = SQL_C_SBIGINT;
        aInfo->mParameterType     = SQL_BIGINT;
        aInfo->mColumnSize        = 0;
        aInfo->mDecimalDigits     = 0;
    }
    
    return (!PyErr_Occurred());
}

static bool GetFloatInfo( Cursor     * aCursor,
                          Py_ssize_t   aIndex,
                          PyObject   * aParam,
                          ParamInfo  * aInfo )
{
    /**
     * @note Python 자체적으로 aParam의 값이 소수점은 잘려서 입력되는 문제가 있다.
     */ 
    aInfo->mData.mDouble = PyFloat_AsDouble( aParam );
    aInfo->mParameterValuePtr = &aInfo->mData.mDouble;
    
    if( CompareParameterInfo( aInfo,
                              SQL_C_DOUBLE, /* aCtype */
                              SQL_DOUBLE,   /* aSqlType */
                              15,           /* aColumnSize */
                              0 )           /* aDecimalDigts */
        == FALSE )
    {
        aInfo->mNeedBindParameter = TRUE;
        aInfo->mValueType         = SQL_C_DOUBLE;
        aInfo->mParameterType     = SQL_DOUBLE;
        aInfo->mColumnSize        = 15;
        aInfo->mDecimalDigits     = 0;
    }
    
    return TRUE;
}

/**
 * @brief Allocate an ASCII string containing the given decimal.
 */ 
static char * CreateDecimalString( long       aSign,
                                   PyObject * aDigits,
                                   long       aExp )
{
    long    sCount = (long)PyTuple_GET_SIZE( aDigits );
    char  * sString = NULL;
    long    sLen;
    long    i = 0;
    char  * sPtr = NULL;
    
    if( aExp >= 0 )
    {
        // (1 2 3) exp = 2 --> '12300'

        sLen = aSign + sCount + aExp + 1; // 1: NULL

        sString = (char*) malloc( sLen );

        if( sString != NULL )
        {
            sPtr = sString;
            if( aSign )
            {
                *sPtr = '-';
                sPtr++;
            }
            
            for( i = 0; i < sCount; i++ )
            {
                *sPtr = (char)( '0' + PyInt_AS_LONG( PyTuple_GET_ITEM( aDigits, i ) ) );
                sPtr++;
            }
            
            for (i = 0; i < aExp; i++)
            {
                *sPtr = '0';
                sPtr++;
            }

            *sPtr = '\0';
        }
    }
    else if( -aExp < sCount )
    {
        // (1 2 3) exp = -2 --> 1.23 : prec = 3, scale = 2

        sLen = aSign + sCount + 2; // 2: decimal + NULL
        sString = (char*) malloc( sLen );

        if( sString != NULL )
        {
            sPtr = sString;
            if( aSign )
            {
                *sPtr = '-';
                sPtr++;
            }

            for( ; i < (sCount + aExp); i++ )
            {
                *sPtr = (char)( '0' + PyInt_AS_LONG( PyTuple_GET_ITEM( aDigits, i ) ) );
                sPtr++;
            }
            
            *sPtr = '.';
            sPtr++;

            for( ; i < sCount; i++ )
            {
                *sPtr = (char)( '0' + PyInt_AS_LONG( PyTuple_GET_ITEM( aDigits, i ) ) );
                sPtr++;
            }

            *sPtr = '\0';
            sPtr++;
        }
    }
    else
    {
        // (1 2 3) exp = -5 --> 0.00123 : prec = 5, scale = 5

        sLen = aSign + -aExp + 3; // 3: leading zero + decimal + NULL

        sString = (char*) malloc( sLen );

        if( sString != NULL )
        {
            sPtr = sString;
            if( aSign )
            {
                *sPtr = '-';
                sPtr++;
            }
            
            *sPtr = '0';
            sPtr++;
            *sPtr = '.';
            sPtr++;
            
            for( i = 0; i < -(aExp + sCount); i++ )
            {
                *sPtr = '0';
                sPtr++;
            }

            for( i = 0; i < sCount; i++ )
            {
                *sPtr = (char)( '0' + PyInt_AS_LONG( PyTuple_GET_ITEM( aDigits, i ) ) );
                sPtr++;
            }

            *sPtr = '\0';
            sPtr++;
        }
    }

    DASSERT( ( strlen( sString ) + 1 ) == sLen );

    return sString;
}

static bool GetDecimalInfo( Cursor     * aCursor,
                            Py_ssize_t   aIndex,
                            PyObject   * aParam,
                            ParamInfo  * aInfo )
{
    PyObject  * sTuple = NULL;
    PyObject  * sDigits;
    long        sSign;
    long        sExp;
    Py_ssize_t  sCount;
    SQLSMALLINT sValueType;
    SQLSMALLINT sParameterType;
    SQLULEN     sColumnSize;
    SQLSMALLINT sDecimalDigits;
    
    // The NUMERIC structure never works right with SQL Server and probably a lot of other drivers.
    // We'll bind as a string.
    // Unfortunately, the Decimal class doesn't seem to have a way to force it to return a string without exponents, so we'll have to build it ourselves.

    sTuple = PyObject_CallMethod( aParam, "as_tuple", 0 );
    TRY( IS_VALID_PYOBJECT( sTuple ) == TRUE );

    sSign   = PyInt_AsLong( PyTuple_GET_ITEM( sTuple, 0 ) );
    sDigits = PyTuple_GET_ITEM( sTuple, 1 );
    sExp    = PyInt_AsLong( PyTuple_GET_ITEM( sTuple, 2 ) );

    sCount = PyTuple_GET_SIZE( sDigits );

    sValueType     = SQL_C_CHAR;
    sParameterType = SQL_NUMERIC;

    if( sExp >= 0 )
    {
        // (1 2 3) exp = 2 --> '12300'
        sColumnSize    = (SQLUINTEGER)sCount + sExp;
        sDecimalDigits = 0;

    }
    else if( -sExp <= sCount )
    {
        // (1 2 3) exp = -2 --> 1.23 : prec = 3, scale = 2
        sColumnSize    = (SQLUINTEGER)sCount;
        sDecimalDigits = (SQLSMALLINT)-sExp;
    }
    else
    {
        // (1 2 3) exp = -5 --> 0.00123 : prec = 5, scale = 5
        sColumnSize    = (SQLUINTEGER)(sCount + (-sExp));
        sDecimalDigits = (SQLSMALLINT)sColumnSize;
    }

    DASSERT(sColumnSize >= (SQLULEN)sDecimalDigits);

    aInfo->mParameterValuePtr = CreateDecimalString( sSign,
                                                     sDigits,
                                                     sExp );
    TRY_THROW( aInfo->mParameterValuePtr != NULL, RAMP_ERR_NO_MEMORY );

    aInfo->mValueAllocated = TRUE;
    
    aInfo->mStrLen_or_Ind = (SQLINTEGER)strlen((char*)aInfo->mParameterValuePtr);

    Py_XDECREF( sTuple );

    if( CompareParameterInfo( aInfo,
                              sValueType,      /* aCtype */
                              sParameterType,  /* aSqlType */
                              sColumnSize,     /* aColumnSize */
                              sDecimalDigits ) /* aDecimalDigts */
        == FALSE )
    {
        aInfo->mNeedBindParameter = TRUE;
        aInfo->mValueType         = sValueType;
        aInfo->mParameterType     = sParameterType;
        aInfo->mColumnSize        = sColumnSize;
        aInfo->mDecimalDigits     = sDecimalDigits;
    }
    
    return TRUE;

    CATCH( RAMP_ERR_NO_MEMORY )
    {
        PyErr_NoMemory();
    }

    FINISH;

    return FALSE;
}

#if PY_MAJOR_VERSION < 3
static bool GetBufferInfo( Cursor     * aCursor,
                           Py_ssize_t   aIndex,
                           PyObject   * aParam,
                           ParamInfo  * aInfo )
{
    char        * sBuffer;
    Py_ssize_t    sSize = 0;
    Connection  * sConnection = GetConnection( aCursor );
    SQLLEN        sMaxLength;
    SQLSMALLINT   sValueType;
    SQLSMALLINT   sParameterType;
    SQLULEN       sColumnSize;

    sValueType = SQL_C_BINARY;
    
    sSize = GetBufferMemory( aParam, &sBuffer );

    sMaxLength = GetMaxLength( sConnection, sValueType );
    
    if( sSize <= sMaxLength )
    {
        // There is one segment, so we can bind directly into the buffer object.
        sParameterType            = SQL_VARBINARY;
        aInfo->mParameterValuePtr = (SQLPOINTER)sBuffer;
        aInfo->mBufferLength      = sSize;
        sColumnSize               = (SQLULEN)MAX( sSize, 1 );
        aInfo->mStrLen_or_Ind     = sSize;
    }
    else
    {
        // There are multiple segments, so we'll provide the data at execution time.  Pass the PyObject pointer as
        // the parameter value which will be pased back to us when the data is needed.  (If we release threads, we
        // need to up the refcount!)

        sParameterType            = SQL_LONGVARBINARY;
        aInfo->mParameterValuePtr = aInfo;
        sColumnSize               = (SQLUINTEGER)GetBufferSize(aParam);
        aInfo->mBufferLength      = sizeof( ParamInfo* );
        aInfo->mStrLen_or_Ind     = SQL_DATA_AT_EXEC;
        
        aInfo->mParam = aParam;
        Py_INCREF( aInfo->mParam );
        aInfo->mMaxLength = sMaxLength;
    }

    if( CompareParameterInfo( aInfo,
                              sValueType,       /* aCtype */
                              sParameterType,   /* aSqlType */
                              sColumnSize,      /* aColumnSize */
                              0 )               /* aDecimalDigts */
        == FALSE )
    {
        aInfo->mNeedBindParameter = TRUE;
        aInfo->mValueType         = sValueType;
        aInfo->mParameterType     = sParameterType;
        aInfo->mColumnSize        = sColumnSize;
        aInfo->mDecimalDigits     = 0;
    }
    
    return TRUE;
}
#endif

#if PY_VERSION_HEX >= 0x02060000
static bool GetByteArrayInfo( Cursor     * aCursor,
                              Py_ssize_t   aIndex,
                              PyObject   * aParam,
                              ParamInfo  * aInfo )
{
    Py_ssize_t    sSize = PyByteArray_Size( aParam );
    Connection  * sConnection = GetConnection( aCursor );
    SQLLEN        sMaxLength;
    SQLSMALLINT   sValueType;
    SQLSMALLINT   sParameterType;
    SQLULEN       sColumnSize;
    
    sValueType = SQL_C_BINARY;

    sMaxLength = GetMaxLength( sConnection, sValueType );
    
    if( (sMaxLength == 0) || (sSize <= sMaxLength)  )
    {
        sParameterType            = SQL_VARBINARY;
        aInfo->mParameterValuePtr = (SQLPOINTER)PyByteArray_AsString( aParam );
        aInfo->mBufferLength      = (SQLINTEGER)sSize;
        sColumnSize               = (SQLULEN)MAX(sSize, 1);
        aInfo->mStrLen_or_Ind     = sSize;
    }
    else
    {
        sParameterType            = SQL_LONGVARBINARY;
        aInfo->mParameterValuePtr = aInfo;
        sColumnSize               = (SQLUINTEGER)sSize;
        aInfo->mBufferLength      = sizeof(ParamInfo*);
        aInfo->mStrLen_or_Ind     = SQL_DATA_AT_EXEC;

        aInfo->mParam = aParam;
        Py_INCREF( aInfo->mParam );
        aInfo->mMaxLength = sMaxLength;
    }

    if( CompareParameterInfo( aInfo,
                              sValueType,     /* aCtype */
                              sParameterType, /* aSqlType */
                              sColumnSize,    /* aColumnSize */
                              0 )             /* aDecimalDigts */
        == FALSE )
    {
        aInfo->mNeedBindParameter = TRUE;
        aInfo->mValueType         = sValueType;
        aInfo->mParameterType     = sParameterType;
        aInfo->mColumnSize        = sColumnSize;
        aInfo->mDecimalDigits     = 0;
    }
    
    return TRUE;
}
#endif

/**
 * @brief Determines the type of SQL parameter that will be used for this parameter based on the Python data type. 
 */ 
bool GetParameterInfo( Cursor     * aCursor,
                       Py_ssize_t   aIndex,
                       PyObject   * aParam,
                       ParamInfo  * aInfo )
{
    PyObject * sClass = NULL;
    bool       sIsTrue = FALSE;
    
    /**
     * Populates `aInfo`.
     * Hold a reference to param until info is freed, because info will often be holding data borrowed from param.
     */ 
    aInfo->mParam = aParam;

    if( aParam == Py_None )
    {
        return GetNullInfo( aCursor,
                            aIndex,
                            aInfo );
    }
    
    if( aParam == gNullBinary )
    {
        return GetNullBinaryInfo( aCursor,
                                  aIndex,
                                  aParam,
                                  aInfo );
    }

#if PY_MAJOR_VERSION >= 3
    if( PyBytes_Check( aParam ) == TRUE )
    {
        return GetBytesInfo( aCursor,
                             aIndex,
                             aParam,
                             aInfo );
    }
#else
    if( PyBytes_Check( aParam ) == TRUE )
    {
        return GetStrInfo( aCursor,
                           aIndex,
                           aParam,
                           aInfo );
    }
#endif
    
    if( PyUnicode_Check( aParam ) == TRUE )
    {
        return GetUnicodeInfo( aCursor,
                               aIndex,
                               aParam,
                               aInfo );
    }
    
    if( PyBool_Check( aParam ) == TRUE )
    {
        return GetBooleanInfo( aCursor,
                               aIndex,
                               aParam,
                               aInfo );
    }

    if( PyDateTime_Check( aParam ) == TRUE )
    {
        return GetDateTimeInfo( aCursor,
                                aIndex,
                                aParam,
                                aInfo );
    }

    if( PyDate_Check( aParam ) == TRUE )
    {
        return GetDateInfo( aCursor,
                            aIndex,
                            aParam,
                            aInfo );
    }
    
    if( PyTime_Check( aParam ) == TRUE )
    {
        return GetTimeInfo( aCursor,
                            aIndex,
                            aParam,
                            aInfo );
    }
    
    if( PyLong_Check( aParam ) == TRUE )
    {
        return GetLongInfo( aCursor,
                            aIndex,
                            aParam,
                            aInfo );
    }
    
    if( PyFloat_Check( aParam ) == TRUE )
    {
        return GetFloatInfo( aCursor,
                             aIndex,
                             aParam,
                             aInfo );
    }
    
#if PY_VERSION_HEX >= 0x02060000
    if( PyByteArray_Check( aParam ) != FALSE )
    {
        return GetByteArrayInfo( aCursor,
                                 aIndex,
                                 aParam,
                                 aInfo );
    }
#endif

#if PY_MAJOR_VERSION < 3
    if( PyInt_Check( aParam ) != FALSE )
    {
        return GetIntInfo( aCursor,
                           aIndex,
                           aParam,
                           aInfo );
    }
    
    if( PyBuffer_Check( aParam ) != FALSE )
    {
        return GetBufferInfo( aCursor,
                              aIndex,
                              aParam,
                              aInfo );
    }
#endif

    /**
     * note: vs 2017에서 if문 안에 함수의 반환 값을 잘못된 값으로 인식한다.
     */ 
    sIsTrue = IsInstanceForThread( aParam, "decimal", "Decimal", &sClass );
    if( sIsTrue == TRUE )
    {
        Py_XDECREF( sClass );
        return GetDecimalInfo( aCursor,
                               aIndex,
                               aParam,
                               aInfo );
    }
    
    RaiseErrorV( "HY105",
                 ProgrammingError,
                 "Invalid parameter type. aParam-mIndex=%zd param-type=%s",
                 aIndex,
                 Py_TYPE( aParam )->tp_name );

    return FALSE;
}


   
STATUS GetInOutParameterData( Cursor     * aCursor,
                              Py_ssize_t   aIndex,
                              PyObject   * aParam,
                              ParamInfo  * aParamInfo )
{
    Py_ssize_t             sLen;
    int                    sBufferLength;
    Connection           * sCnxn;
    Encoding             * sEncoding;
    PyObject             * sEncoded = NULL;
    SQL_TIMESTAMP_STRUCT * sTimestamp = NULL;
    SQL_DATE_STRUCT      * sDate = NULL;
    SQL_TIME_STRUCT      * sTime = NULL;
#if PY_MAJOR_VERSION < 3
    char                 * sBuffer;
    BufSegIterator         sIterator;
    Py_ssize_t             sRemain;
    SQLLEN                 sOffset;
#if LONG_BIT == 32
    int                    sInt;
#endif

#endif
    PyObject             * sClass = NULL;
    PyObject             * sTuple = NULL;
    PyObject             * sDigits;
    long                   sSign;
    long                   sExp;
    char                 * sDecimal = NULL;

    long                   sLong;

    sCnxn = GetConnection( aCursor );
    sEncoding = &sCnxn->mWritingEnc;

    sBufferLength = MAX( aParamInfo->mColumnSize, (SQLULEN)aParamInfo->mBufferLength );
    
    if( aParam == Py_None )
    {
        aParamInfo->mValueType = SQL_C_DEFAULT;
        aParamInfo->mStrLen_or_Ind = SQL_NULL_DATA;
    }
    else if( aParam == gNullBinary )
    {
        aParamInfo->mValueType = SQL_C_BINARY;
        aParamInfo->mStrLen_or_Ind = SQL_NULL_DATA; 
    }
#if PY_MAJOR_VERSION >= 3
    /* byte */
    else if( PyBytes_Check( aParam ) == TRUE )
    {
        aParamInfo->mValueType = SQL_C_BINARY;
        
        sLen = PyBytes_GET_SIZE( aParam );

        TRY_THROW( sLen <= sBufferLength, RAMP_ERR_DATA_TRUNCATED );
        
        aParamInfo->mStrLen_or_Ind = sLen;
        memcpy( aParamInfo->mData.mBuffer, PyBytes_AS_STRING( aParam ), sLen );
    }
#else
    /* String */
    else if( PyBytes_Check( aParam ) == TRUE )
    {
        aParamInfo->mValueType = SQL_C_CHAR;

        if( sEncoding->mType == ENC_RAW )
        {
            sEncoded = aParam;
        }
        else
        {
            sEncoded = PyCodec_Encode( aParam, sEncoding->mName, "strict" );
            TRY( sEncoded != NULL );

            TRY_THROW( PyBytes_CheckExact( sEncoded ) == TRUE, RAMP_ERR_UNEXPECTED_DATA_TYPE );
        }

        sLen = PyBytes_GET_SIZE( sEncoded );

        TRY_THROW( sLen <= sBufferLength, RAMP_ERR_DATA_TRUNCATED );
        
        aParamInfo->mStrLen_or_Ind = sLen;
        memcpy( aParamInfo->mData.mBuffer, PyBytes_AS_STRING( aParam ), sLen );
    }
#endif
#if PY_VERSION_HEX >= 0x02060000
    else if( PyByteArray_Check( aParam ) != FALSE )
    {
        aParamInfo->mValueType = SQL_C_BINARY;

        sLen = PyByteArray_Size( aParam );

        TRY_THROW( sLen <= sBufferLength, RAMP_ERR_DATA_TRUNCATED );
        aParamInfo->mStrLen_or_Ind = sLen;
        memcpy( aParamInfo->mData.mBuffer, PyByteArray_AsString( aParam ), sLen );
    }
#endif
    else if( PyUnicode_Check( aParam ) == TRUE )
    {
        aParamInfo->mValueType = SQL_C_CHAR;

        sLen = PyUnicode_GET_SIZE( aParam );

        sEncoded = PyCodec_Encode( aParam, sEncoding->mName, "strict" );
        TRY( sEncoded != NULL );

        TRY_THROW( PyBytes_CheckExact( sEncoded ) == TRUE, RAMP_ERR_UNEXPECTED_DATA_TYPE );

        TRY_THROW( sLen <= sBufferLength, RAMP_ERR_DATA_TRUNCATED );
        aParamInfo->mStrLen_or_Ind = sLen;
        memcpy( aParamInfo->mData.mBuffer, PyBytes_AS_STRING( aParam ), sLen );
        
    }
    else if( PyBool_Check( aParam ) == TRUE )
    {
        aParamInfo->mValueType = SQL_C_BIT;
        if( aParam == Py_True )
        {
            *(bool*)aParamInfo->mData.mBuffer = TRUE;
        }
        else
        {
            *(bool*)aParamInfo->mData.mBuffer = FALSE;
        }

        aParamInfo->mStrLen_or_Ind = 1;
    }
    else if( PyDateTime_Check( aParam ) == TRUE )
    {
        sTimestamp = (SQL_TIMESTAMP_STRUCT*)aParamInfo->mData.mBuffer;
        sTimestamp->year = PyDateTime_GET_YEAR( aParam );
        sTimestamp->month  = PyDateTime_GET_MONTH( aParam );
        sTimestamp->day    = PyDateTime_GET_DAY( aParam );
        sTimestamp->hour   = PyDateTime_DATE_GET_HOUR( aParam );
        sTimestamp->minute = PyDateTime_DATE_GET_MINUTE( aParam );
        sTimestamp->second = PyDateTime_DATE_GET_SECOND( aParam );
        sTimestamp->fraction = PyDateTime_DATE_GET_MICROSECOND( aParam ) * 1000; 
        
        aParamInfo->mValueType = SQL_C_TYPE_TIMESTAMP;
        aParamInfo->mStrLen_or_Ind = sizeof( SQL_TIMESTAMP_STRUCT );
        
    }
    else if( PyDate_Check( aParam ) == TRUE )
    {
        sDate = (SQL_DATE_STRUCT*)aParamInfo->mData.mBuffer;
    
        sDate->year = PyDateTime_GET_YEAR( aParam );
        sDate->month = PyDateTime_GET_MONTH( aParam );
        sDate->day = PyDateTime_GET_DAY( aParam );

        aParamInfo->mValueType = SQL_C_TYPE_DATE;
        aParamInfo->mStrLen_or_Ind = sizeof( SQL_DATE_STRUCT );
    } 
    else if( PyTime_Check( aParam ) == TRUE )
    {
        sTime = (SQL_TIME_STRUCT*)aParamInfo->mData.mBuffer;
    
        sTime->hour = PyDateTime_TIME_GET_HOUR( aParam );
        sTime->minute = PyDateTime_TIME_GET_MINUTE( aParam );
        sTime->second = PyDateTime_TIME_GET_SECOND( aParam );
        
        aParamInfo->mValueType = SQL_C_TYPE_TIME;
        aParamInfo->mStrLen_or_Ind = sizeof( SQL_TIME_STRUCT );
    }
    else if( PyFloat_Check( aParam ) == TRUE )
    {
        *(double*)aParamInfo->mData.mBuffer = PyFloat_AsDouble( aParam );
        aParamInfo->mValueType = SQL_C_DOUBLE;
        aParamInfo->mStrLen_or_Ind = sizeof( double );
    }
    else if( PyLong_Check( aParam ) == TRUE )
    {
        sLong = PyLong_AsLongLong( aParam );

        if( (aParamInfo->mDecimalDigits == 0) &&
            (aParamInfo->mColumnSize <= 19) )
        {
            aParamInfo->mValueType = SQL_C_SBIGINT;
            *(long*)aParamInfo->mData.mBuffer = sLong;
            aParamInfo->mStrLen_or_Ind = sizeof( long );
        }
        else
        {
            aParamInfo->mValueType = SQL_C_CHAR;
            aParamInfo->mStrLen_or_Ind = snprintf( (char*)aParamInfo->mData.mBuffer,
                                                   sBufferLength,
                                                   "%ld",
                                                   sLong );
        }
    }
#if PY_MAJOR_VERSION < 3
    else if( PyInt_Check( aParam ) != FALSE )
    {   
#if LONG_BIT == 64
        sLong = PyLong_AsLongLong( aParam );

        if( (aParamInfo->mDecimalDigits == 0) &&
            (aParamInfo->mColumnSize <= 19) )
        {
            aParamInfo->mValueType = SQL_C_SBIGINT;
            *(long*)aParamInfo->mData.mBuffer = sLong;
            aParamInfo->mStrLen_or_Ind = sizeof( long );
        }
        else
        {
            aParamInfo->mValueType = SQL_C_CHAR;
            aParamInfo->mStrLen_or_Ind = snprintf( (char*)aParamInfo->mData.mBuffer,
                                                   sBufferLength,
                                                   "%ld",
                                                   sLong );
        }
#elif LONG_BIT == 32
        sInt = PyInt_AsLong( aParam );

        if( (aParamInfo->mDecimalDigits == 0) &&
            (aParamInfo->mColumnSize <= 19) )
        {
            aParamInfo->mValueType = SQL_C_LONG;
            *(long*)aParamInfo->mData.mBuffer = sInt;
            aParamInfo->mStrLen_or_Ind = sizeof( int );
        }
        else
        {
            aParamInfo->mValueType = SQL_C_CHAR;
            aParamInfo->mStrLen_or_Ind = snprintf( (char*)aParamInfo->mData.mBuffer,
                                                   sBufferLength,
                                                   "%d",
                                                   sInt );
        }
#else
#error Unexpected LONG_BIT value
#endif
    } 
    else if( PyBuffer_Check( aParam ) != FALSE )
    {
        aParamInfo->mValueType = SQL_C_BINARY;

        InitBufSegIterator( &sIterator, aParam );

        sRemain = sBufferLength;
        sOffset = 0;
        
        while( GetNextBufSegIterator( &sIterator, &sBuffer, &sLen) == TRUE )
        {
            TRY_THROW( sLen <= sRemain, RAMP_ERR_DATA_TRUNCATED );

            memcpy( (char*)aParamInfo->mData.mBuffer + sOffset, sBuffer, sLen );
            
            sOffset += sLen;
            sRemain -= sLen;
        }
    }
#endif
    else if( IsInstanceForThread( aParam, "decimal", "Decimal", &sClass ) == TRUE )
    {
        Py_XDECREF( sClass );

        sTuple = PyObject_CallMethod( aParam, "as_tuple", 0 );
        TRY( IS_VALID_PYOBJECT( sTuple ) == TRUE );

        sSign   = PyInt_AsLong( PyTuple_GET_ITEM( sTuple, 0 ) );
        sDigits = PyTuple_GET_ITEM( sTuple, 1 );
        sExp    = PyInt_AsLong( PyTuple_GET_ITEM( sTuple, 2 ) );

        aParamInfo->mValueType = SQL_C_CHAR;

        sDecimal = CreateDecimalString( sSign, sDigits, sExp );
        TRY_THROW( sDecimal != NULL, RAMP_ERR_NO_MEMORY );
        
        sLen = strlen( sDecimal );

        TRY_THROW( sLen <= sBufferLength, RAMP_ERR_DATA_TRUNCATED );

        memcpy( aParamInfo->mData.mBuffer, sDecimal, sLen );
        free( sDecimal );

        aParamInfo->mStrLen_or_Ind = sLen;
    }
    else
    {
        THROW( RAMP_ERR_UNEXPECTED_DATA_TYPE );
    }
    
    return SUCCESS;

    CATCH( RAMP_ERR_NO_MEMORY )
    {
        PyErr_NoMemory();
    }

    CATCH( RAMP_ERR_UNEXPECTED_DATA_TYPE )
    {
        PyErr_Format( PyExc_TypeError,
                      "Unicode read encoding '%s' returned unexpected data type: %s",
                      sEncoding->mName,
                      Py_TYPE( sEncoded )->tp_name );
    }

    CATCH( RAMP_ERR_DATA_TRUNCATED )
    {
        RaiseErrorV( NULL,
                     DataError,
                     "Data is truncated" );
    }
    
    FINISH;
    
    return FAILURE;
}


STATUS MakeOutputParameter( Cursor       * aCursor,
                            PyObject     * aParamSeq,
                            PyObject    ** aOutParam,
                            PsmParamInfo * aPsmParamInfo )
{
    ParamInfo  * sParamInfos;
    PyObject   * sParam = NULL;
    Py_ssize_t   sCount = PySequence_Fast_GET_SIZE( aParamSeq );
    Py_ssize_t   i;
    PyObject   * sPyObject = NULL;
    
    sParamInfos = aCursor->mParamInfos;
    *aOutParam = PyTuple_New( sCount );
    for( i = 0; i < sCount; i++ )
    {
        sParam = PySequence_GetItem( aParamSeq, i );
        
        if( aPsmParamInfo[i].mColumnType == SQL_PARAM_INPUT )
        {
            PyTuple_SET_ITEM( *aOutParam, i , sParam );
        }
        else
        {
            sPyObject = CToPyTypeByCType( aCursor,
                                          sParamInfos[i].mValueType,
                                          sParamInfos[i].mParameterValuePtr,
                                          sParamInfos[i].mParameterType,
                                          sParamInfos[i].mColumnSize,
                                          sParamInfos[i].mDecimalDigits,
                                          sParamInfos[i].mStrLen_or_Ind );

            TRY( !PyErr_Occurred() );
            PyTuple_SET_ITEM( *aOutParam, i, sPyObject );
        }
    }

    return SUCCESS;

    FINISH;

    return FAILURE;
}

STATUS BindParameter( Cursor      * aCursor,
                      Py_ssize_t    aIndex,
                      SQLSMALLINT   aInputOutputType,
                      ParamInfo   * aParamInfo )
{
    SQLRETURN     sRet = SQL_ERROR;
    Connection  * sCnxn = NULL;
    SQLULEN       sColumnSize = aParamInfo->mColumnSize;
    PyObject    * sDesc = NULL;
    
    if( (aInputOutputType == SQL_PARAM_INPUT) &&
        (aCursor->mInputSizes != NULL) && (aIndex < PySequence_Length(aCursor->mInputSizes)) )
    {
        sDesc = PySequence_GetItem( aCursor->mInputSizes, (aIndex - 1) );

#if PY_MAJOR_VERSION < 3
        if( PyInt_Check( sDesc ) == TRUE )
        {
            sColumnSize = (SQLULEN)PyInt_AsLong( sDesc );
        }
        else
#endif
        if( PyLong_Check( sDesc ) == TRUE )
        {
            sColumnSize = (SQLULEN)PyLong_AsLong( sDesc );
        }
        
        Py_XDECREF( sDesc );
    }
    
    Py_BEGIN_ALLOW_THREADS;
    sRet = GDLBindParameter( aCursor->mHStmt,
                             (SQLUSMALLINT)aIndex,
                             aInputOutputType,
                             aParamInfo->mValueType,
                             aParamInfo->mParameterType,
                             sColumnSize,
                             aParamInfo->mDecimalDigits,
                             aParamInfo->mParameterValuePtr,
                             aParamInfo->mBufferLength,
                             &aParamInfo->mStrLen_or_Ind );
    Py_END_ALLOW_THREADS;

    sCnxn = GetConnection( aCursor );
    
    TRY_THROW( sCnxn->mHDbc != SQL_NULL_HANDLE, RAMP_ERR_CLOSED_CONNECTION );
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
                              "SQLBindParameter",
                              sCnxn->mHDbc,
                              aCursor->mHStmt );
    }
    
    FINISH;

    return FAILURE;
}


/**
 *@brief unbind parameters and free the parameter buffer.
 */ 
STATUS FreeParameter( Cursor * aCursor )
{
    Connection * sCnxn = NULL;

    if( aCursor->mParamInfos != NULL )
    {
        sCnxn = GetConnection( aCursor );
        
        if( sCnxn->mHDbc != SQL_NULL_HANDLE )
        {
            Py_BEGIN_ALLOW_THREADS;
            GDLFreeStmt( aCursor->mHStmt, SQL_RESET_PARAMS );
            Py_END_ALLOW_THREADS;
        }

        TRY( FreeParameterInfos( aCursor ) == SUCCESS );
    }

    return SUCCESS;

    FINISH;

    return FAILURE;
}


STATUS Prepare( Cursor   * aCursor,
                PyObject * aSql )
{
    SQLRETURN     sRet = 0;
    SQLSMALLINT   sParamCount = 0;
    Encoding    * sEncoding;
    Connection  * sCnxn;
    PyObject    * sQuery = NULL;
    bool          sIsWide = FALSE;
    char        * sPtr;
    SQLINTEGER    sSize;
    char        * sErrFunc = NULL;
    
    sCnxn = GetConnection( aCursor );
    
#if PY_MAJOR_VERSION >= 3
    if( PyUnicode_Check( aSql ) == FALSE )
    {
        PyErr_SetString(PyExc_TypeError, "SQL must be a Unicode string");
        TRY( FALSE );
    }
#endif

    /**
     * Prepare the SQL if necessary.
     * @todo check 비교연산이 가능한가? 문자열 비교 방식으로 바꿔서 해야하는게 아닐까?
     */
    if( aSql != aCursor->mPreparedSQL )
    {
        TRY( FreeParameter( aCursor ) == SUCCESS );

        Py_XDECREF( aCursor->mPreparedSQL );
        aCursor->mPreparedSQL = NULL;
        aCursor->mParamCount  = 0;

        sEncoding = &sCnxn->mWritingEnc;

        sQuery = Encode( aSql, sEncoding );

        TRY( sQuery != NULL );

        sPtr = PyBytes_AS_STRING( sQuery );

        if( sEncoding->mType >= ENC_UTF16 )
        {
            sIsWide = TRUE;
        }
        
        sPtr = PyBytes_AS_STRING( sQuery );

        if( sIsWide == TRUE )
        {
            sSize = (SQLINTEGER)(PyBytes_GET_SIZE( sQuery ) / sizeof( SQLWCHAR ));
        }
        else
        {
            sSize = (SQLINTEGER)PyBytes_GET_SIZE( sQuery );
        }

        Py_BEGIN_ALLOW_THREADS;
        if( sIsWide == TRUE )
        {
            sErrFunc = "SQLPrepareW";
            sRet = GDLPrepareW( aCursor->mHStmt, (SQLWCHAR*)sPtr, sSize );
        }
        else
        {
            sErrFunc = "SQLPrepare";
            sRet = GDLPrepare( aCursor->mHStmt, (SQLCHAR*)sPtr, sSize );
        }
        
        if( SQL_SUCCEEDED( sRet ) )
        {
            sErrFunc = "SQLNumParams";
            sRet = GDLNumParams( aCursor->mHStmt, &sParamCount );
        }
        Py_END_ALLOW_THREADS;

        TRY_THROW( sCnxn->mHDbc != SQL_NULL_HANDLE, RAMP_ERR_CLOSED_CURSOR );

        TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

        aCursor->mParamCount = (int)sParamCount;

        aCursor->mPreparedSQL = aSql;

        Py_INCREF( aCursor->mPreparedSQL );
    }

    Py_XDECREF( sQuery );
    
    return SUCCESS;

    CATCH( RAMP_ERR_CLOSED_CURSOR )
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

STATUS PrepareAndBind( Cursor   * aCursor,
                       PyObject * aSql,
                       PyObject * aOrgParams,
                       bool       aSkipFirst )
{
    int          sParamsOffset = 0;
    Py_ssize_t   sParamCount = 0;
    Py_ssize_t   i = 0;
    PyObject   * sParam = NULL;
    ParamInfo  * sParamInfos;
    int          sState = 0;
    
    if( aSkipFirst == TRUE )
    {
        sParamsOffset = 1;
    }
    
    if( aOrgParams != NULL )
    {
        sParamCount = PySequence_Length( aOrgParams ) - sParamsOffset;
    }

    TRY( Prepare( aCursor, aSql ) == SUCCESS );

    TRY_THROW( sParamCount == aCursor->mParamCount, RAMP_ERR_INVALID_COUNT );

    /**
     * ParamInfo를 할당하고 재사용을 위해 execute 후 해제 하지 않는다.
     * 해제는 Cursor_dealloc에서 한다.
     */ 
    if( aCursor->mParamInfos == NULL )
    {
        aCursor->mParamInfos = (ParamInfo*) malloc( sizeof( ParamInfo ) * sParamCount );

        TRY_THROW( aCursor->mParamInfos != NULL, RAMP_ERR_NO_MEMORY );
        memset( aCursor->mParamInfos, 0x00, sizeof( ParamInfo ) * sParamCount );
    }
    sState = 1;

    sParamInfos = aCursor->mParamInfos;
    
    for( i = 0; i < sParamCount; i++ )
    {
        sParam = PySequence_GetItem( aOrgParams, i + sParamsOffset );

        TRY( GetParameterInfo( aCursor,
                               i,
                               sParam,
                               &sParamInfos[i] ) == TRUE );

        
        if( sParamInfos[i].mNeedBindParameter == TRUE )
        {
            TRY( BindParameter( aCursor,
                                i + 1,
                                SQL_PARAM_INPUT,
                                &sParamInfos[i] ) == SUCCESS );
        }
    }
    
    return SUCCESS;

    CATCH( RAMP_ERR_NO_MEMORY )
    {
        PyErr_NoMemory();
    }
    
    CATCH( RAMP_ERR_INVALID_COUNT )
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "The SQL contains %d parameter markers, but %d parameters were supplied",
                     aCursor->mParamCount,
                     sParamCount );
    }
    
    FINISH;

    switch( sState )
    {
        case 1:
            (void)FreeParameterInfos( aCursor );
        default:
            break;
    }
    
    return FAILURE;
}

STATUS ExecuteMulti( Cursor   * aCursor,
                     PyObject * aSql,
                     PyObject * aParamArrObj )
{
    SQLRETURN     sRet;
    Py_ssize_t    i;
    SQLSMALLINT   sNullable;
    Py_ssize_t    sRowCount;
    PyObject   ** sPyRows;
    Py_ssize_t    r = 0;
    PyObject    * sPyCurRow;
    PyObject   ** sPyColumns;
    char        * sBindPtr;
    int           sErrorState = 0;
    Connection  * sCnxn;
    SQLHDESC      sDescHandle;
    Py_ssize_t    sRowLen;
    char        * sParamData;
    Py_ssize_t    sRowsConverted;
    ParamInfo   * sParamInfo;
    SQLULEN       sBindOffset;
    char        * sErrFunc = NULL;
    long          sAllocSize = 0;
    
    sCnxn = GetConnection( aCursor );
    
    TRY( Prepare( aCursor, aSql ) == SUCCESS );

    aCursor->mParamInfos = (ParamInfo*) malloc( sizeof(ParamInfo) * aCursor->mParamCount );
    sErrorState = 1;
    
    TRY_THROW( aCursor->mParamInfos != NULL, RAMP_ERR_NO_MEMORY );
    
    memset( aCursor->mParamInfos, 0x00, sizeof( ParamInfo ) * aCursor->mParamCount );

    // Describe each parameter (SQL type) in preparation for allocation of paramset array
    for( i = 0; i < aCursor->mParamCount; i++ )
    {
        sRet = GDLDescribeParam( aCursor->mHStmt,
                                 i + 1,
                                 &aCursor->mParamInfos[i].mParameterType,
                                 &aCursor->mParamInfos[i].mColumnSize,
                                 &aCursor->mParamInfos[i].mDecimalDigits,
                                 &sNullable );

        if( !SQL_SUCCEEDED( sRet ) )
        {
            // Default to a medium-length varchar if describing the parameter didn't work
            aCursor->mParamInfos[i].mParameterType = SQL_VARCHAR;
            aCursor->mParamInfos[i].mColumnSize = 4000;
            aCursor->mParamInfos[i].mDecimalDigits = 0;
        }
    }

    sPyRows   = PySequence_Fast_ITEMS( aParamArrObj );
    sRowCount = PySequence_Fast_GET_SIZE( aParamArrObj );
    
    while( r < sRowCount )
    {
        // Scan current row to determine C types
        sPyCurRow = *sPyRows;
        sPyRows++;
        
        TRY_THROW( (PyTuple_Check( sPyCurRow ) == TRUE) || (PyList_Check( sPyCurRow ) == TRUE) ||
                   (ROW_CHECK( sPyCurRow ) == TRUE), RAMP_ERR_INVALID_PARAMS_TYPE );

        TRY_THROW( PySequence_Fast_GET_SIZE( sPyCurRow ) == aCursor->mParamCount,
                   RAMP_ERR_PARAMETER_COUNT );

        sPyColumns = PySequence_Fast_ITEMS( sPyCurRow );

        // Start at a non-zero offset to prevent null pointer detection.
        sBindPtr = (char*)16;

        for( i = 0; i < aCursor->mParamCount; i++ )
        {
            TRY( DetectCType( sPyColumns[i],
                              &aCursor->mParamInfos[i] ) == TRUE );
            
            sRet = GDLBindParameter( aCursor->mHStmt,
                                     i + 1,
                                     SQL_PARAM_INPUT,
                                     aCursor->mParamInfos[i].mValueType,
                                     aCursor->mParamInfos[i].mParameterType,
                                     aCursor->mParamInfos[i].mColumnSize,
                                     aCursor->mParamInfos[i].mDecimalDigits,
                                     sBindPtr,
                                     aCursor->mParamInfos[i].mBufferLength,
                                     (SQLLEN*)(sBindPtr + aCursor->mParamInfos[i].mBufferLength ) );
            sErrorState = 2;
            sErrFunc = "SQLBindParameter";
            TRY( SQL_SUCCEEDED( sRet ) );

            if( aCursor->mParamInfos[i].mValueType == SQL_C_NUMERIC )
            {
                GDLGetStmtAttr( aCursor->mHStmt,
                                SQL_ATTR_APP_PARAM_DESC,
                                &sDescHandle,
                                0,
                                0 );
                
                GDLSetDescField( sDescHandle,
                                 i + 1,
                                 SQL_DESC_TYPE,
                                 (SQLPOINTER)SQL_C_NUMERIC,
                                 0 );
                
                GDLSetDescField( sDescHandle,
                                 i + 1,
                                 SQL_DESC_PRECISION,
                                 (SQLPOINTER)aCursor->mParamInfos[i].mColumnSize,
                                 0 );
                
                GDLSetDescField( sDescHandle,
                                 i + 1,
                                 SQL_DESC_SCALE,
                                 (SQLPOINTER)(SQLLEN)aCursor->mParamInfos[i].mDecimalDigits,
                                 0 );
                
                GDLSetDescField( sDescHandle,
                                 i + 1,
                                 SQL_DESC_DATA_PTR,
                                 sBindPtr,
                                 0 );
            }

            sBindPtr += aCursor->mParamInfos[i].mBufferLength + sizeof( SQLLEN );
        }

        sRowLen = sBindPtr - (char*)16;

        /**
         * Assume parameters are homogeneous between rows in the common case,
         * to avoid another rescan for determining the array height.
         * Subtract number of rows processed as an upper bound.
         */
        if( (sRowLen * (sRowCount - r)) > sAllocSize )
        {
            if( aCursor->mParamArray != NULL )
            {
                free( aCursor->mParamArray );
                aCursor->mParamArray = NULL;
            }

            sAllocSize = sRowLen * (sRowCount - r);
            aCursor->mParamArray = (char*) malloc( sAllocSize );
        }
        TRY_THROW( aCursor->mParamArray != NULL, RAMP_ERR_NO_MEMORY );
        sErrorState = 3;
        
        sParamData = aCursor->mParamArray;
        memset( sParamData, 0x00, sAllocSize );
        
        sRowsConverted = 0;

        while( TRUE )
        {
            sParamInfo = &aCursor->mParamInfos[0];

            /* Column Loop */
            for( i = 0; i < aCursor->mParamCount; i++, sParamInfo++ )
            {
                /* bind parameter 이후 ctype이 다르다면 다시 execute 후 다시 bind parameter 해야한다.*/
                if( IsSamePyTypeWithCType( *sPyColumns,
                                           sParamInfo ) == FALSE )
                {
                    sPyRows--;
                    THROW( RAMP_EXECUTE );
                }
                
                /* sParamData will be incremented and returned out*/
                if( PyToCType( aCursor, &sParamData, *sPyColumns, sParamInfo ) == FALSE )
                {
                    sPyRows--;
                    THROW( RAMP_EXECUTE );
                }
                sPyColumns++;
            }
            
            sRowsConverted++;
            r++;

            if( r >= sRowCount )
            {
                break;
            }

            sPyCurRow = *sPyRows++;

            TRY_THROW( PySequence_Fast_GET_SIZE( sPyCurRow ) == aCursor->mParamCount,
                       RAMP_ERR_PARAMETER_COUNT );

            sPyColumns = PySequence_Fast_ITEMS( sPyCurRow );
        }

        RAMP( RAMP_EXECUTE );

        if( sRowsConverted == 0 )
        {
            TRY_THROW( PyErr_Occurred(), RAMP_ERR_NO_SUITABLE_CONVERSION );
        }
        else
        {
            if( PyErr_Occurred() )
            {
                PyErr_Clear();
            }
        }

        sBindOffset = (SQLULEN)(aCursor->mParamArray) - 16;

        sRet = GDLSetStmtAttr( aCursor->mHStmt,
                               SQL_ATTR_PARAM_BIND_TYPE,
                               (SQLPOINTER)sRowLen,
                               SQL_IS_UINTEGER );
        sErrorState = 4;

        sErrFunc = "SQLSetStmtAttr";
        TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

        sRet = GDLSetStmtAttr( aCursor->mHStmt,
                               SQL_ATTR_PARAMSET_SIZE,
                               (SQLPOINTER)sRowsConverted,
                               SQL_IS_UINTEGER );
        sErrorState = 5;
        TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

        sRet = GDLSetStmtAttr( aCursor->mHStmt,
                               SQL_ATTR_PARAM_BIND_OFFSET_PTR,
                               (SQLPOINTER)&sBindOffset,
                               SQL_IS_POINTER );
        sErrorState = 6;
        TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_SQLFUNCTION );

        Py_BEGIN_ALLOW_THREADS;
        sRet = GDLExecute( aCursor->mHStmt );
        Py_END_ALLOW_THREADS;

        TRY_THROW( sCnxn->mHDbc != SQL_NULL_HANDLE, RAMP_ERR_CONNECTION_CLOSED );

        sErrFunc = "SQLExecute";
        TRY_THROW( (SQL_SUCCEEDED( sRet )) || (sRet == SQL_NEED_DATA) || (sRet == SQL_NO_DATA),
                       RAMP_ERR_SQLFUNCTION );

        TRY( ProcessLongParamDatas( &sRet,
                                    aCursor ) == SUCCESS );
    }

    if( aCursor->mParamArray != NULL )
    {
        free( aCursor->mParamArray );
        aCursor->mParamArray = NULL;
    }
    
    GDLSetStmtAttr( aCursor->mHStmt,
                    SQL_ATTR_PARAMSET_SIZE,
                    (SQLPOINTER)1,
                    SQL_IS_UINTEGER );

    GDLSetStmtAttr( aCursor->mHStmt,
                    SQL_ATTR_PARAM_BIND_OFFSET_PTR,
                    0,
                    SQL_IS_POINTER );

    TRY( FreeParameter( aCursor ) == SUCCESS );
    
    return SUCCESS;

    CATCH( RAMP_ERR_NO_MEMORY )
    {
        PyErr_NoMemory();
    }

    CATCH( RAMP_ERR_INVALID_PARAMS_TYPE )
    {
        RaiseErrorV( NULL,
                     PyExc_TypeError,
                     "Params must be in a list, tuple, or Row" );
    }

    CATCH( RAMP_ERR_PARAMETER_COUNT )
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "Expected %u parameters, supplied %u",
                     aCursor->mParamCount,
                     PySequence_Fast_GET_SIZE( sPyCurRow ) );
    }

    CATCH( RAMP_ERR_NO_SUITABLE_CONVERSION )
    {
        RaiseErrorV( NULL,
                     ProgrammingError,
                     "No suitable conversion for one or more parameters." );
    }

    CATCH( RAMP_ERR_CONNECTION_CLOSED )
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

    switch( sErrorState )
    {
        case 6:
            (void)FreeParameter( aCursor );
            GDLSetStmtAttr( aCursor->mHStmt,
                            SQL_ATTR_PARAM_BIND_OFFSET_PTR,
                            0,
                            SQL_IS_POINTER );
        case 5:
            GDLSetStmtAttr( aCursor->mHStmt,
                            SQL_ATTR_PARAMSET_SIZE,
                            (SQLPOINTER)1,
                            SQL_IS_UINTEGER );
        case 4:
            GDLSetStmtAttr( aCursor->mHStmt,
                            SQL_ATTR_PARAM_BIND_TYPE,
                            SQL_BIND_BY_COLUMN,
                            SQL_IS_UINTEGER );
        case 3:
            if( aCursor->mParamArray != NULL )
            {   
                free( aCursor->mParamArray );
                aCursor->mParamArray = NULL;
            }
        case 2:
            GDLFreeStmt( aCursor->mHStmt, SQL_RESET_PARAMS );
        case 1:
            if( aCursor->mParamInfos != NULL )
            {
                free( aCursor->mParamInfos );
                aCursor->mParamInfos = NULL;
            }
        default:
            break;
    }
    
    return FAILURE;
}


static PyTypeObject gNullParamType =
{
    PyVarObject_HEAD_INIT(NULL, 0)
    "pygoldilocks.NullParam",   // tp_name
    sizeof(NullParam),          // tp_basicsize
    0,                          // tp_itemsize
    0,                          // destructor tp_dealloc
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
};

STATUS InitParams()
{
    TRY( PyType_Ready( &gNullParamType ) >= 0 );
    
    gNullBinary = (PyObject*)PyObject_New( NullParam, &gNullParamType );
    TRY( gNullBinary != NULL );

    PyDateTime_IMPORT;

    return SUCCESS;

    FINISH;

    return FAILURE;
}

/**
 * @}
 */
