/*******************************************************************************
 * pydbc.h
 *
 * Copyright (c) 2011, SUNJESOFT Inc.
 *
 *
 * IDENTIFICATION & REVISION
 *        $Id: pydbc.h 26607 2018-12-20 09:45:10Z lkh $
 *
 * NOTES
 *
 *
 ******************************************************************************/


#ifndef _PYDBC_H_
#define _PYDBC_H_ 1

#ifdef _MSC_VER
// The MS headers generate a ton of warnings.
#pragma warning(push, 0)
#define _CRT_SECURE_NO_WARNINGS
#pragma warning(pop)
typedef __int64 INT64;
typedef unsigned __int64 UINT64;
#else
typedef unsigned char byte;
typedef unsigned int UINT;
typedef long long INT64;
typedef unsigned long long UINT64;
#endif


#include <Python.h>
#include <structmember.h>
#include <stdio.h>
#include <stdlib.h>
#include <wchar.h>
#include <sys/types.h>
#include <errno.h>
#include <ctype.h>
#include <goldilocks.h>

#if PY_VERSION_HEX < 0x02050000
typedef int Py_ssize_t;
#endif

typedef unsigned long ulong;
typedef unsigned int  uint;
typedef char          bool;

#define ENCODING_STRING_LENGTH    20
#define PROCEDURE_DEFAULT_LENGTH  12

#define TRUE    1
#define FALSE   0

#define DEFAULT_TIMESTAMP_PRECISTION 26

#define OFFSET(aType, aMember)                                                  \
    ((size_t) (((char *) (&(((aType)NULL)->aMember))) - ((char *) NULL)))

#define OFFSETOF(aType, aMember) OFFSET(aType*, aMember)

#define COUNTOF(a) (sizeof(a) / sizeof(a[0]))

#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)

#define MAKE_CONSTANT( v ) { #v, v }

#define ATTACH_PYOBJECT(aSelf, aNewPyObject)    \
    {                                           \
        Py_XDECREF(aSelf);                      \
        aSelf = aNewPyObject;                   \
    }

#define IS_VALID_PYOBJECT(x)  ( (x) != NULL ? TRUE : FALSE )

#ifndef MIN
#define MIN( aA, aB )                           \
    ( ( (aA) < (aB) ) ? (aA) : (aB) )
#endif

#ifndef MAX
#define MAX( aA, aB )                           \
    ( ( (aA) > (aB) ) ? (aA) : (aB) )
#endif

#define FINISH                                  \
    FINISH_LABEL:

#define TRY( aExpression )                      \
    if( !(aExpression) )                        \
    {                                           \
        goto FINISH_LABEL;                      \
    }

#define TRY_THROW( aExpression, aLabel )        \
    if( !(aExpression) )                        \
    {                                           \
        goto aLabel;                            \
    }

#define THROW( aLabel ) goto aLabel;

#define CATCH( aLabel )                         \
    goto FINISH_LABEL;                          \
    aLabel:

#define RAMP( aLabel ) aLabel:

#define ASSERT( aExp )                          \
    {                                           \
        if( !(aExp) )                           \
        {                                       \
            printf( "ASSERT(%s)\n"              \
                    "failed in file %s %d\n",   \
                    #aExp,                      \
                    __FILE__,                   \
                    __LINE__ );                 \
        }                                       \
    }

#if defined( PYGOLDILOCKS_DEBUG )
#define DASSERT( aExp )   ASSERT( aExp )
#else
#define DASSERT( aExp )
#endif

typedef enum
{
    SUCCESS = 0,
    FAILURE
} STATUS;

/** module. */

extern PyTypeObject gRowType;
extern PyTypeObject gCursorType;
extern PyTypeObject gConnectionType;

extern PyObject * Error;
extern PyObject * Warning;
extern PyObject * InterfaceError;
extern PyObject * DatabaseError;
extern PyObject * InternalError;
extern PyObject * OperationalError;
extern PyObject * ProgrammingError;
extern PyObject * IntegrityError;
extern PyObject * DataError;
extern PyObject * NotSupportedError;

extern PyObject * gNullBinary;

extern PyObject   * gModule;
extern SQLHENV      gHENV;
extern Py_UNICODE   gChDecimal;
extern int          gDbcCnt;

/**
 *@brief module
 */ 
typedef struct KeywordMap
{
    const char * mOldName;
    const char * mNewName;
    PyObject   * mNewNameObject;  // PyString object version of newname, created as needed.
} KeywordMap;

typedef struct ConstantDef
{
    const char * mName;
    int          mValue;
} ConstantDef;

/**
 * @brief Text Encoding
 */

typedef enum EncodingType
{
    ENC_NONE = 0, /* No optimized encoding - use the named encoding */
    ENC_RAW,      /* In Python 2, pass bytes directly to string - no decoder */
    ENC_UTF8,
    ENC_CP949,
    ENC_LATIN1,
    ENC_GB18030,
    ENC_UTF16,    /* "Native", so check for BOM and default to BE */
    ENC_UTF16BE,
    ENC_UTF16LE,
    ENC_UTF32,
    ENC_UTF32LE,
    ENC_UTF32BE
} EncodingType;

#define BYTE_ORDER_LE      (-1)
#define BYTE_ORDER_NATIVE  (0)
#define BYTE_ORDER_BE      (1)

#if PY_MAJOR_VERSION < 3
#define TO_UNICODE     (1)
#define TO_STRING      (2)
#endif

#ifdef  WORDS_BIGENDIAN
# define ENC_UTF16NE     ENC_UTF16BE
# define ENCSTR_UTF16NE  "utf-16be"
#else
# define ENC_UTF16NE     ENC_UTF16LE
# define ENCSTR_UTF16NE  "utf-16le"
#endif

#define ENCSTR_CP949     "cp949"
#define ENCSTR_GB18030   "gb18030"

typedef struct Encoding
{
    /**
     * Holds encoding information for reading or writing text.
     * Since some drivers / databases are not easy to configure efficiently,
     * a separate instance of this structure is configured for:
     *
     * reading SQL_CHAR
     * reading SQL_WCHAR
     * writing unicode strings
     * writing non-unicode strings (Python 2.7 only)
     **/
    
#if PY_MAJOR_VERSION < 3
    int         mTo; /* DB로 읽은 Object의 반환 타입: str 또는 unicode. */
#endif

    /**
     * Set to one of the OPTENC constants to indicate whether an optimized encoding is to be
     * used or a custom one.  If OPTENC_NONE, no optimized encoding is set and `mName` should be
     * used.
     */ 
    int         mType;
    char        mName[ENCODING_STRING_LENGTH]; /* The name of the encoding. */

    /**
     * Normally this matches the SQL type of the column (SQL_C_CHAR is used for SQL_CHAR, etc.).
     * At least one database reports it has SQL_WCHAR data even when configured for UTF-8
     * which is better suited for SQL_C_CHAR.
     */
    SQLSMALLINT mCType; /* SQL_C_CHAR 또는 SQL_C_WCHAR */
} Encoding;

/**
 * @brief Connection
 */

#define CONNECTION_CHECK(op) PyObject_TypeCheck( (op), &gConnectionType )
#define CONNECTION_CHECK_EXACT(op) ( Py_TYPE( (op) ) == &gConnectionType )

/**
 * Get info type
 */ 
typedef enum GetInfoType
{
    GI_YESNO,
    GI_STRING,
    GI_UINTEGER,
    GI_USMALLINT,
} GetInfoType;

typedef struct GetInfo
{
    SQLUSMALLINT  mInfoType;
    int           mDataType; // GI_XXX
} GetInfo;

typedef struct Connection
{
    PyObject_HEAD
    SQLHDBC       mHDbc;         /* Set to SQL_NULL_HANDLE when the connection is closed. */
    ulong         mAutoCommit;   /* Will be SQL_AUTOCOMMIT_ON or SQL_AUTOCOMMIT_OFF. */
    
    char          mOdbcMajor;    /* The ODBC version the driver supports, */
    char          mOdbcMinor;    /* from SQLGetInfo(DRIVER_ODBC_VER). This is set after connecting.*/

    PyObject    * mSearchEscape; /* SQLGetInfo 얻는 escape 문자, 요청이 있어야 설정됨 */
    int           mDatetimePrecision; /* SQLGetInfo()에서 얻는 datetime column의 size. datetime의 precision에 사용된다. */

    long          mTimeout;      /* The connection timeout in seconds. */

    /**
     * Connection 할 때, Db character set을 읽고 db char set에 맞게 encoding을 변경한다.
     */ 
    char          mDbCharSet[ENCODING_STRING_LENGTH];

    Encoding      mReadingEnc;
    Encoding      mWritingEnc;
    
    // Used when reading column names for Cursor.description.  I originally thought I could use
    // the zlyTextEncoding above based on whether I called SQLDescribeCol vs SQLDescribeColW.
    // Unfortunately it looks like PostgreSQL and MySQL (and probably others) ignore the ODBC
    // specification regarding encoding everywhere *except* in these functions - SQLDescribeCol
    // seems to always return UTF-16LE by them regardless of the connection settings.
    
    SQLLEN        mMaxWrite; /* Used to override mVarcharMaxlength, etc. SQLGetTypeInfo로 얻음. */
    /* These are copied from cnxn info for performance and convenience.*/
    SQLLEN        mVarcharMaxLength;
    SQLLEN        mBinaryMaxLength;  
    SQLLEN        mLongVariableMaxLength;
    
    bool          mNeedLongDataLen;
} Connection;


/**
 * @brief Parameters
 */

typedef struct ColumnInfo
{
    SQLSMALLINT mSqlType;

    /**
     * The column size from SQLDescribeCol.
     * For character types, this is the maximum length, not including the NULL terminator.
     * For binary values, this is the maximum length.
     * For numeric and decimal values, it is the defined number of digits.
     * For example, the precision of a column defined as NUMERIC(10,3) is 10.
     * This value can be SQL_NO_TOTAL in which case the driver doesn't know the maximum length, such as for LONGVARCHAR fields.
     */ 
    SQLULEN     mColumnSize;
    SQLSMALLINT mDecimalDigits;

    void      * mValue;
    SQLLEN      mIndicator;
} ColumnInfo;

typedef struct ParamInfo
{
    // The following correspond to the SQLBindParameter parameters.
    SQLSMALLINT   mValueType;
    SQLSMALLINT   mParameterType;
    SQLULEN       mColumnSize;
    SQLSMALLINT   mDecimalDigits;
    SQLLEN        mBufferLength;
    SQLLEN        mStrLen_or_Ind;
    bool          mNeedBindParameter;
    
    /**
     * The value pointer that will be bound.
     * If `mValueAllocated` is true, this was allocated with malloc and must be freed.
     * Otherwise it is zero or points into memory owned by the original Python parameter.
     */
    bool          mValueAllocated;
    SQLPOINTER    mParameterValuePtr;

    /**
     * Long Data에 대해 SQLPutData를 사용하여 하는 경우.
     * Python 객체가 mParam에 연결된다.
     *
     * SQLPutData를 실행을 위해 mMaxLength를 설정한다.
     */
    PyObject    * mParam;
    SQLLEN        mMaxLength;
    
    // Optional data. If used, mParameterValuePtr will point into this.
    union
    {
        bool                            mBool;
        long                            mLong;  
        INT64                           mLongLong;
        double                          mDouble;
        SQL_TIMESTAMP_STRUCT            mTimestamp;
        SQL_DATE_STRUCT                 mDate;
        SQL_TIME_STRUCT                 mTime;
        void                          * mBuffer;
    } mData;
} ParamInfo;

typedef struct PsmParamInfo
{
    SQLINTEGER   mColumnSize;
    SQLINTEGER   mBufferLength;
    SQLSMALLINT  mColumnType;
    SQLSMALLINT  mDataType;
    SQLSMALLINT  mDecimalDigits;
} PsmParamInfo;


typedef struct NullParam
{
    PyObject_HEAD
} NullParam;

/**
 * @brief Cursor
 */

typedef struct Cursor
{
    PyObject_HEAD
    Connection * mConnection;
    SQLHSTMT     mHStmt; /* Set to SQL_NULL_HANDLE when the cursor is closed. */

    /* SQL Parameters */
    PyObject   * mPreparedSQL; /* If not null, 이전의 Prepared SQL String 이다. */
                               /* prepare와 parameter data 수집을 건너뛸 수 있다. */
    int          mParamCount;  /* 매개변수 개수, mPreparedSQL가 null이면 0 */

    /**
     * If non-zero, a pointer to a buffer containing the actual parameters bound.
     * If pPreparedSQL is zero, this should be freed using free and set to zero.
     * Even if the same SQL statement is executed twice,
     * the parameter bindings are redone from scratch
     * since we try to bind into the Python objects directly.
     */
    ParamInfo  * mParamInfos;

    char       * mParamArray;/* Parameter set array (used with executemany) */

    /* Whether to use fast executemany with parameter arrays and other optimisations */
    bool         mFastExecMany;
    
    PyObject   * mInputSizes;  /* The list of information for setinputsizes(). */
    long         mOutputSize;  /* The size for setoutputsizes(). */
    int          mOutputSizeIndex; /* The index for setoutputsizes(). */
    
    /* Result Information */
    ColumnInfo * mColumnInfos; /* Query result가 없으면 NULL */
    int          mColumnCount;

    /**
     * The description tuple described in the DB API 2.0 specification.
     * Set to None when there are no results.
     */ 
    PyObject   * mDescription;

    int          mArraySize;
    int          mRowCount; /* The Cursor.rowcount attribute from the DB API specification. */

    /**
     * A dictionary that maps from column name (PyString) to index into the result columns (PyInteger).
     * This is constructued during an execute and shared with each row (reference counted) to implement accessing results by column name.
     * This duplicates some ODBC functionality, but allows us to use Row objects after the statement is closed and should use less memory than putting each column into the Row's __dict__.
     * Since this is shared by Row objects, it cannot be reused.
     * New dictionaries are created for every execute.
     * This will be zero whenever there are no results.
     */ 
    PyObject   * mMapNameToIndex;
} Cursor;

typedef enum CursorRequireEnum
{
    CURSOR_REQUIRE_CNXN    = 0x00000001,
    CURSOR_REQUIRE_OPEN    = 0x00000003, // includes _CNXN
    CURSOR_REQUIRE_RESULTS = 0x00000007, // includes _OPEN
    CURSOR_RAISE_ERROR     = 0x00000010,
} CursorRequireEnum;

typedef enum FreeResultsFlags
{
    FREE_STATEMENT = 0x01,
    KEEP_STATEMENT = 0x02,
    FREE_PREPARED  = 0x04,
    KEEP_PREPARED  = 0x08,

    STATEMENT_MASK = 0x03,
    PREPARED_MASK  = 0x0C
} FreeResultsFlags;

/**
 * @brief Row
 */

/**
 *@brief A Row must act like a sequence (a tuple of results) to meet the DB API specification,
 * but we also allow values to be accessed via lowercased column names.
 * We also supply a `columns` attribute which returns the list of column names.
 */ 
typedef struct Row
{
    PyObject_HEAD
    
    PyObject    * mDescription;    /* Cursor.mDescription, accessed as _description */
    PyObject    * mMapNameToIndex; /* A Python dictionary mapping from column name to a PyInteger, used to access columns by name. */
    Py_ssize_t    mValueCount;   /* The number of values in apValues. */
    PyObject   ** mColumnValues; /* The column values, stored as an array. */
} Row;

#define ROW_CHECK( op ) PyObject_TypeCheck((op), &gRowType)
#define ROW_CHECK_EXACT( op ) (Py_TYPE(op) == &gRowType)

/**
 * @brief Buffer 타입인 PyObject에서 유효한 buffer를 읽기 위해 사용된다.
 */
typedef struct BufSegIterator
{
    PyObject   * mBuffer;
    Py_ssize_t   mSegment;
    Py_ssize_t   mSegCount;
} BufSegIterator;

/**
 * @brief Error
 */

typedef struct ExceptionInfo
{
    const char  * mName;
    const char  * mFullName;
    PyObject   ** mException;
    PyObject   ** mExcParent;
    const char  * mDoc;
} ExceptionInfo;

extern ExceptionInfo gExcInfos[];

#endif 
