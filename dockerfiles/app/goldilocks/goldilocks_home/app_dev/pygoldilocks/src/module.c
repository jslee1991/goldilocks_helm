/*******************************************************************************
 * module.c
 *
 * Copyright (c) 2011, SUNJESOFT Inc.
 *
 *
 * IDENTIFICATION & REVISION
 *        $Id: module.c 33320 2021-03-24 08:02:10Z lkh $
 *
 * NOTES
 *
 *
 ******************************************************************************/

#include <pydbc.h>
#include <buffer.h>
#include <connection.h>
#include <cursor.h>
#include <error.h>
#include <getdata.h>
#include <param.h>
#include <type.h>
#include <datetime.h>


/**
 * @file module.c
 * @brief Goldilocks Python database API funcionts
 */

/**
 * @addtogroup Module
 * @{
 */

PyObject   * gModule = NULL;
SQLHENV      gHENV = SQL_NULL_HANDLE;
Py_UNICODE   gChDecimal = '.';
int          gDbcCnt = 0;

PyObject * GetClassForThread( const char * aModuleStr,
                              const char * aClassStr )
{
    /**
     * Returns the given class, specific to the current thread's interpreter.
     * For performance these are cached for each thread.
     *
     * This is for internal use only, so we'll cache using only the class name.
     * Make sure they are unique.
     * (That is, don't try to import classes with the same name from two different modules.)
     */
    PyObject * sDict = PyThreadState_GetDict();
    PyObject * sClass = NULL;
    PyObject * sModule = NULL;

    if( sDict == NULL )
    {
        // I don't know why there wouldn't be thread state so I'm going to raise an exception
        // unless I find more info.
        return PyErr_Format( PyExc_Exception, "PyThreadState_GetDict returned NULL" );
    }

    /**
     * Check the cache. GetItemString returns a borrowed reference.
     */
    sClass = PyDict_GetItemString( sDict, aClassStr );
    if( sClass != NULL )
    {
        Py_INCREF( sClass );
        return sClass;
    }

    /* Import the class and cache it.  GetAttrString returns a new reference. */
    sModule = PyImport_ImportModule( aModuleStr );
    if( sModule == NULL )
    {
        return NULL;
    }
    
    sClass = PyObject_GetAttrString( sModule, aClassStr );
    Py_DECREF( sModule );
    
    if( sClass == NULL )
    {
        return NULL;
    }
    
    // SetItemString increments the refcount (not documented)
    PyDict_SetItemString( sDict, aClassStr, sClass );

    return sClass;
}

bool IsInstanceForThread( PyObject    * aParam,
                          const char  * aModuleStr,
                          const char  * aClassStr,
                          PyObject   ** aClass )
{
    /**
     * Like PyObject_IsInstance but compares against a class specific to the current thread's
     * interpreter, for proper subinterpreter support.  Uses GetClassForThread.
     *
     * If `param` is an instance of the given class, true is returned and a new reference to
     * the class, specific to the current thread, is returned via pcls.  The caller is
     * responsible for decrementing the class.
     *
     * If `aParam` is not an instance, true is still returned (!) but *pcls will be zero.
     *
     * False is only returned when an exception has been raised.  (That is, the return value is
     * not used to indicate whether the instance check matched or not.)
     */ 
    PyObject * sClass = NULL;
    int        sInt   = FALSE;
    
    if( aParam == NULL )
    {
        *aClass = NULL;
        return TRUE;
    }

    sClass = GetClassForThread( aModuleStr, aClassStr );
    
    if( sClass == NULL )
    {
        *aClass = NULL;
        return FALSE;
    }

    sInt = PyObject_IsInstance( aParam, sClass );
    
    // (The checks below can be compressed into just a few lines, but I was concerned it
    //  wouldn't be clear.)
    if( sInt == 1 )
    {
        // We have a match.
        *aClass = sClass;
        return TRUE;
    }

    Py_DECREF( sClass );
    *aClass = NULL;

    if( sInt == 0 )
    {
        // No exception, but not a match.
        return TRUE;
    }

    // n == -1; an exception occurred
    return FALSE;
}


static void InitLocaleInfo()
{
    PyObject * sModule = NULL;
    PyObject * sLDict = NULL;
    PyObject * sValue = NULL;
    int        sState = 0;
    
    sModule = PyImport_ImportModule( "locale" );
    TRY( sModule != NULL );
    sState = 1;
    
    sLDict = PyObject_CallMethod( sModule, "localeconv", 0 );
    TRY( sLDict != NULL );
    sState = 2;

    sValue = PyDict_GetItemString( sLDict, "decimal_point" );
    if( sValue != NULL )
    {
        if( (PyBytes_Check( sValue ) == TRUE) && (PyBytes_Size( sValue ) == 1) )
        {
            gChDecimal = (Py_UNICODE)PyBytes_AS_STRING( sValue )[0];
        }
        if( (PyUnicode_Check( sValue ) == TRUE) && (PyUnicode_GET_SIZE( sValue ) == 1) )
        {
            gChDecimal = PyUnicode_AS_UNICODE( sValue )[0];
        }
    }

    sState = 1;
    Py_XDECREF( sLDict );

    sState = 0;
    Py_XDECREF( sModule );
    
    return;

    FINISH;

    PyErr_Clear();

    switch( sState )
    {
        case 2:
            Py_XDECREF( sLDict );
        case 1:
            Py_XDECREF( sModule );
        default:
            break;
    }
    
    return;
}

static STATUS ImportTypes()
{
    PyObject * sDateTime = PyImport_ImportModule( "datetime" );

    TRY( sDateTime != NULL );

    PyDateTime_IMPORT;

    InitCursor();
    
    InitGetData();

    InitType();
    
    TRY( InitParams() == SUCCESS );

    return SUCCESS;

    FINISH;

    return FAILURE;
}

static STATUS AllocateEnv()
{
    SQLRETURN   sRet;

    sRet = GDLAllocHandle( SQL_HANDLE_ENV,
                           SQL_NULL_HANDLE,
                           &gHENV );

    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_ALLOCENV );

    sRet = GDLSetEnvAttr( gHENV,
                          SQL_ATTR_ODBC_VERSION,
                          (SQLPOINTER)SQL_OV_ODBC3,
                          sizeof( int ) );

    TRY_THROW( SQL_SUCCEEDED( sRet ), RAMP_ERR_ODBC_VERSION );

    return SUCCESS;
    
    CATCH( RAMP_ERR_ALLOCENV )
    {
        PyErr_SetString( PyExc_RuntimeError,
                         "Can't initialize module pygoldilocks.  SQLAllocEnv failed." );
    }
    
    CATCH( RAMP_ERR_ODBC_VERSION )
    {
        PyErr_SetString( PyExc_RuntimeError,
                         "Unable to set SQL_ATTR_ODBC_VERSION attribute." );
    }
    
    FINISH;

    return FAILURE;
}


// Map DB API recommended keywords to ODBC keywords.
static KeywordMap gKeywordMaps[] =
{
    { "user",     "uid",    0 },
    { "password", "pwd",    0 },
};

static PyObject * CheckAttrsDict( PyObject * aAttrs )
{
    /**
     * The attrs_before dictionary must be keys to integer values.
     * If valid and non-empty, increment the reference count and return the pointer
     * to indicate the calling code should keep it.
     * If empty, just return NULL which indicates to the calling code it should not keep the value.
     * If an error occurs, set an error. The calling code must look for this in the zero case.
     * We already know this is a dictionary.
     */
    Py_ssize_t   sPos = 0;
    PyObject   * sKey = NULL;
    PyObject   * sValue = NULL;
    
    TRY( PyDict_Size( aAttrs ) != 0 );
    
    while( PyDict_Next( aAttrs, &sPos, &sKey, &sValue ) )
    {
        TRY_THROW( IsIntOrLong( sKey ) == TRUE, RAMP_ERR_TYPE_ERROR );

        TRY_THROW( (IsIntOrLong( sValue ) == TRUE) ||
                   (IsTextType( sValue ) == TRUE), RAMP_ERR_TYPE_ERROR );
    }

    Py_INCREF( aAttrs );

    return aAttrs;

    CATCH( RAMP_ERR_TYPE_ERROR )
    {
        PyErr_SetString( PyExc_TypeError,
                         "Attribute dictionary keys/attrs must be integers or string or unicode" );
    }
    
    FINISH;

    return NULL;
}

static PyObject * MakeConnectionString( PyObject * aExisting,
                                        PyObject * aParts )
{
    Py_ssize_t   sLength = 0;
    Py_ssize_t   sPos = 0;
    PyObject   * sKey = 0;
    PyObject   * sValue = 0;
    PyObject   * sResult;
    Py_UNICODE * sBuffer;
    Py_ssize_t   sOffset;

    /**
     * Creates a connection string from an optional existing connection string plus a dictionary of keyword value pairs.
     *  existing
     *  Optional Unicode connection string we will be appending to.
     *   Used when a partial connection string is passed in, followed by keyword parameters:
     *   connect("driver={x};database={y}", user='z')
     * parts
     *   A dictionary of text keywords and text values that will be appended.
     */

    DASSERT( PyUnicode_Check( aExisting ) );

    sLength = 0;      // length in *characters*
    if( aExisting != NULL )
    {
        sLength = GetTextSize( aExisting ) + 1; // + 1 to add a trailing semicolon
    }
    
    while( PyDict_Next( aParts, &sPos, &sKey, &sValue ) )
    {
        sLength += GetTextSize( sKey ) + 1 + GetTextSize( sValue ) + 1; // key=value;
    }

    sResult = PyUnicode_FromUnicode( NULL, sLength );
    TRY( sResult != NULL );

    sBuffer = PyUnicode_AS_UNICODE( sResult );
    sOffset = 0;

    if( aExisting != NULL )
    {
        sOffset += CopyTextToUnicode( &sBuffer[sOffset], aExisting );
        sBuffer[sOffset++] = (Py_UNICODE)';';
    }

    sPos = 0;
    while( PyDict_Next( aParts, &sPos, &sKey, &sValue ) )
    {
        sOffset += CopyTextToUnicode( &sBuffer[sOffset], sKey );
        sBuffer[sOffset++] = (Py_UNICODE)'=';

        sOffset += CopyTextToUnicode( &sBuffer[sOffset], sValue );
        sBuffer[sOffset++] = (Py_UNICODE)';';
    }

    DASSERT( sOffset == sLength );

    return sResult;

    FINISH;

    return NULL;
}

static char gConnectMethodDoc[] =
    "connect( connection_str, **kwargs) --> Connection\n"
    "\n"
    "Accepts an ODBC connection string and returns a new Connection object.\n"
    "\n"
    "The connection string will be passed to SQLDriverConnect, so a DSN connection\n"
    "can be created using:\n"
    "\n"
    "  cnxn = pygoldilocks.connect('DSN=DataSourceName;UID=user;PWD=password')\n"
    "\n"
    "To connect without requiring a DSN, specify the driver and connection\n"
    "information:\n"
    "\n"
    "  HOST=127.0.0.1;PORT=22581;UID=user;PWD=password;\n"
    "To get more information, "
    "\n"
    "Note the use of braces when a value contains spaces.\n"
    "Refer to SQLDriverConnect documentation for details.\n"
    "\n"
    "The connection string can be passed as the string `str`, as a list of keywords,\n"
    "or a combination of the two.  Any keywords except autocommit, and timeout\n"
    "(see below) are simply added to the connection string.\n"
    "\n"
    "  connect('dsn=goldilocks;user=me')\n"
    "  connect('dsn=goldilocks', user='me')\n"
    "\n"
    "The DB API recommends the keywords 'user', 'password',  but these\n"
    "are not valid ODBC keywords, so these will be converted to 'uid', 'pwd'.\n"
    "\n"
    "Special Keywords\n"
    "\n"
    "The following specal keywords are processed by pygoldilocks and are not added to the connection string.\n"
    "(If you must use these in your connection string, pass them as a string, not as keywords.)\n"
    "\n"
    "  autocommit\n"
    "    If False or zero, the default, transactions are created automatically as\n"
    "    defined in the DB API 2.  If True or non-zero, the connection is put into\n"
    "    ODBC autocommit mode and statements are committed automatically.\n"
    "   \n"
    "  timeout\n"
    "    An integer login timeout in seconds, used to set the SQL_ATTR_LOGIN_TIMEOUT\n"
    "    attribute of the connection.  The default is 0 which means the database's\n"
    "    default timeout, if any, is used.\n"
    "   \n"
    "  attrs_before"
    "   The attrs_before keyword is an optional dictionary of connection attributes.\n"
    "   These will be set on the connection via SQLSetConnectAttr before a connection is made.\n"
    "   The dictionary keys must be the integer constant defined by ODBC or the driver. Only integer \n"
    "   values are supported at this time. Below is an example that sets the SQL_ATTR_PACKET_SIZE\n"
    "   connection attribute to 32K."
    "  encoding"
    "   Set encoding character set."
    "\n"
    "   connect( cnxn_str, attrs_before{ SQL_ATTR_TXN_ISOLATION: 0} ) "
    "\n";

static PyObject * Module_Connect( PyObject * aSelf,
                                  PyObject * aArgs,
                                  PyObject * aKeywords )
{
    PyObject    * sCnxnStr = NULL;
    PyObject    * sPyCnxn = NULL;
    bool          sAutoCommit = FALSE;
    bool          sReadOnly = FALSE;
    long          sTimeout = 0;
    size_t        i;
    Py_ssize_t    sSize = 0;

    PyObject    * sDictParts = NULL;
    PyObject    * sKey = NULL;
    PyObject    * sValue = NULL;
    PyObject    * sStr = NULL;
    Py_ssize_t    sPos = 0;
    PyObject    * sAttrsBefore = NULL;
    
    if( aArgs != NULL )
    {
        sSize = PyTuple_Size( aArgs );
    }
    
    TRY_THROW( sSize <= 1, RAMP_ERR_NON_KEYWORD_ARGUMENT );

    if( sSize == 1 )
    {
        TRY_THROW( ((PyString_Check( PyTuple_GET_ITEM(aArgs, 0) ) == TRUE) ||
                    (PyUnicode_Check( PyTuple_GET_ITEM(aArgs, 0) ) == TRUE)),
                   RAMP_ERR_ARGUMENT_TYPE );

        sCnxnStr = PyUnicode_FromObject( PyTuple_GetItem(aArgs, 0) );
        TRY( IS_VALID_PYOBJECT( sCnxnStr ) );
    }
    
    if( (aKeywords != NULL) && (PyDict_Size( aKeywords ) > 0) )
    {
        sDictParts = PyDict_New();
        TRY( IS_VALID_PYOBJECT( sDictParts ) == TRUE );

        while( PyDict_Next( aKeywords, &sPos, &sKey, &sValue ) == TRUE )
        {
            TRY_THROW( IsTextType( sKey ) == TRUE, RAMP_ERR_DICTIONARY_ITEM_TYPE );

            if( IsEqualText( sKey, "autocommit" ) == TRUE )
            {
                sAutoCommit = PyObject_IsTrue( sValue );
                continue;
            }

            if( IsEqualText( sKey, "timeout" ) == TRUE )
            {
                sTimeout = PyInt_AsLong( sValue );
                TRY( !PyErr_Occurred() );
                continue;
            }

            if( IsEqualText( sKey, "readonly" ) == TRUE )
            {
                sReadOnly = PyObject_IsTrue( sValue );
                continue;
            }

            if( IsEqualText( sKey, "attrs_before" ) == TRUE )
            {
                sAttrsBefore = CheckAttrsDict( sValue );

                TRY( !PyErr_Occurred() );
                continue;
            }
            
            for( i = 0; i < COUNTOF( gKeywordMaps ); i++ )
            {
                if( IsEqualText( sKey, gKeywordMaps[i].mOldName ) == TRUE )
                {
                    if( gKeywordMaps[i].mNewNameObject == NULL )
                    {
                        gKeywordMaps[i].mNewNameObject = PyString_FromString( gKeywordMaps[i].mNewName );
                        TRY( gKeywordMaps[i].mNewNameObject != NULL );
                    }

                    sKey = gKeywordMaps[i].mNewNameObject;
                    break;
                }
            }

            sStr = PyObject_Str( sValue );

            TRY( sStr != NULL );
            
            if( PyDict_SetItem( sDictParts, sKey, sStr ) == -1 )
            {
                Py_XDECREF( sStr );
                TRY( FALSE );
            }

            Py_XDECREF( sStr );
        }

        if( PyDict_Size( sDictParts ) )
        {
            sCnxnStr = MakeConnectionString( sCnxnStr, sDictParts );
        }
    }

    TRY_THROW( IS_VALID_PYOBJECT( sCnxnStr ) == TRUE,
               RAMP_ERR_NO_CONNECTION_INFO );

    if( gHENV == SQL_NULL_HANDLE )
    {
        TRY( AllocateEnv() != FAILURE );
    }

    TRY( Connect( sCnxnStr,
                  sAutoCommit,
                  sTimeout,
                  sReadOnly,
                  sAttrsBefore,
                  &sPyCnxn ) == SUCCESS );

    Py_XDECREF( sCnxnStr );
    Py_XDECREF( sAttrsBefore );
    Py_XDECREF( sDictParts );

    return sPyCnxn;

    CATCH( RAMP_ERR_NON_KEYWORD_ARGUMENT )
    {
        PyErr_SetString( PyExc_TypeError,
                         "Function takes at most 1 non-keyword argument" );
    }
    
    CATCH( RAMP_ERR_ARGUMENT_TYPE )
    {
        PyErr_SetString( PyExc_TypeError,
                         "Argument 1 must be a string or unicode object" );
    }
    
    CATCH( RAMP_ERR_DICTIONARY_ITEM_TYPE )
    {
        PyErr_SetString( PyExc_TypeError,
                         "Dictionary items passed to connect must be strings" );
    }
    
    CATCH( RAMP_ERR_NO_CONNECTION_INFO )
    {
        PyErr_SetString( PyExc_TypeError,
                         "No connection information was passed" );
    }

    FINISH;

    Py_XDECREF( sCnxnStr );
    Py_XDECREF( sAttrsBefore );
    Py_XDECREF( sDictParts );
    
    return NULL;
}


static char gTimeFromTicksDoc[] =
    "TimeFromTicks(ticks) --> datetime.time\n"
    "\n"
    "Returns a time object initialized from the given ticks value (number of seconds\n"
    "since the epoch; see the documentation of the standard Python time module for\n"
    "details).";

static PyObject * Module_TimeFromTicks( PyObject * aSelf,
                                        PyObject * aArgs )
{
    PyObject  * sNum = NULL;
    time_t      sTick;
    struct tm * sTime = NULL;
    
    TRY( PyArg_ParseTuple( aArgs, "O", &sNum ) == TRUE );
    
    TRY_THROW( PyNumber_Check( sNum ) == TRUE, RAMP_ERR_TIME_FROM_TICKS );

    TRY( PyNumber_Long( sNum ) != NULL );

    sTick = PyLong_AsLong( sNum );

    sTime = localtime( &sTick );

    return PyTime_FromTime( sTime->tm_hour, sTime->tm_min, sTime->tm_sec, 0);

    CATCH( RAMP_ERR_TIME_FROM_TICKS )
    {
        PyErr_SetString( PyExc_TypeError,
                         "TimeFromTicks requires a number." );
    }
    
    FINISH;

    return NULL;
}


static char gDateFromTicksDoc[] =
    "DateFromTicks(ticks) --> datetime.date\n"  
    "\n"
    "Returns a date object initialized from the given ticks value (number of seconds\n"
    "since the epoch; see the documentation of the standard Python time module for\n"
    "details).";

static PyObject * Module_DateFromTicks( PyObject * aSelf,
                                        PyObject * aArgs )
{
    return PyDate_FromTimestamp( aArgs );
}


static char gTimestampFromTicksDoc[] =
    "TimestampFromTicks(ticks) --> datetime.datetime\n"
    "\n"
    "Returns a datetime object initialized from the given ticks value (number of\n"
    "seconds since the epoch; see the documentation of the standard Python time\n" 
    "module for details";

static PyObject * Module_TimestampFromTicks( PyObject * aSelf,
                                             PyObject * aArgs )
{
    return PyDateTime_FromTimestamp( aArgs );
}


static char gSetDecimalSepDoc[] =
    "setDecimalSeparator(string) -> None\n"
    "\n"
    "Sets the decimal separator character used when parsing NUMERIC from the database.";

static PyObject * Module_SetDecimalSep( PyObject * aSelf,
                                        PyObject * aArgs )
{
    PyObject * sValue = NULL;

    if( (PyString_Check( PyTuple_GET_ITEM( aArgs, 0) ) == FALSE) &&
        (PyUnicode_Check( PyTuple_GET_ITEM( aArgs, 0) ) == FALSE) )
    {
        return PyErr_Format(PyExc_TypeError, "argument 1 must be a string or unicode object");
    }
    
    sValue = PyUnicode_FromObject( PyTuple_GetItem( aArgs, 0 ) );
    
    if( sValue != NULL )
    {
        if( (PyBytes_Check( sValue ) == TRUE) && (PyBytes_Size( sValue ) == 1) )
        {
            gChDecimal = (Py_UNICODE)PyBytes_AS_STRING( sValue )[0];
        }

        if( (PyUnicode_Check( sValue ) == TRUE) && (PyUnicode_GET_SIZE( sValue ) == 1) )
        {
            gChDecimal = PyUnicode_AS_UNICODE( sValue )[0];
        }
    }
    
    Py_RETURN_NONE;
}


static char gGetDecimalSepDoc[] =
    "getDecimalSeparator() -> string\n"
    "\n"
    "Gets the decimal separator character used when parsing NUMERIC from the database.";

static PyObject * Module_GetDecimalSep( PyObject * aSelf )
{
    return PyUnicode_FromUnicode( &gChDecimal, 1 );
}

static PyMethodDef gPyMethods[] =
{
    { "connect", (PyCFunction)Module_Connect, METH_VARARGS|METH_KEYWORDS, gConnectMethodDoc },
    { "TimeFromTicks", (PyCFunction)Module_TimeFromTicks, METH_VARARGS, gTimeFromTicksDoc },
    { "DateFromTicks", (PyCFunction)Module_DateFromTicks, METH_VARARGS, gDateFromTicksDoc },
    { "TimestampFromTicks", (PyCFunction)Module_TimestampFromTicks, METH_VARARGS, gTimestampFromTicksDoc },
    { "setDecimalSeparator", (PyCFunction)Module_SetDecimalSep, METH_VARARGS, gSetDecimalSepDoc },
    { "getDecimalSeparator", (PyCFunction)Module_GetDecimalSep, METH_NOARGS, gGetDecimalSepDoc },

    { NULL, NULL, 0, NULL }
};


static const ConstantDef gConstants[] = {
    MAKE_CONSTANT(SQL_UNKNOWN_TYPE),
    MAKE_CONSTANT(SQL_CHAR),
    MAKE_CONSTANT(SQL_VARCHAR),
    MAKE_CONSTANT(SQL_LONGVARCHAR),
    MAKE_CONSTANT(SQL_WCHAR),
    MAKE_CONSTANT(SQL_WVARCHAR),
    MAKE_CONSTANT(SQL_WLONGVARCHAR),
    MAKE_CONSTANT(SQL_DECIMAL),
    MAKE_CONSTANT(SQL_NUMERIC),
    MAKE_CONSTANT(SQL_SMALLINT),
    MAKE_CONSTANT(SQL_INTEGER),
    MAKE_CONSTANT(SQL_REAL),
    MAKE_CONSTANT(SQL_FLOAT),
    MAKE_CONSTANT(SQL_DOUBLE),
    MAKE_CONSTANT(SQL_BIT),
    MAKE_CONSTANT(SQL_TINYINT),
    MAKE_CONSTANT(SQL_BIGINT),
    MAKE_CONSTANT(SQL_BINARY),
    MAKE_CONSTANT(SQL_VARBINARY),
    MAKE_CONSTANT(SQL_LONGVARBINARY),
    MAKE_CONSTANT(SQL_TYPE_DATE),
    MAKE_CONSTANT(SQL_TYPE_TIME),
    MAKE_CONSTANT(SQL_TYPE_TIMESTAMP),
    MAKE_CONSTANT(SQL_INTERVAL_MONTH),
    MAKE_CONSTANT(SQL_INTERVAL_YEAR),
    MAKE_CONSTANT(SQL_INTERVAL_YEAR_TO_MONTH),
    MAKE_CONSTANT(SQL_INTERVAL_DAY),
    MAKE_CONSTANT(SQL_INTERVAL_HOUR),
    MAKE_CONSTANT(SQL_INTERVAL_MINUTE),
    MAKE_CONSTANT(SQL_INTERVAL_SECOND),
    MAKE_CONSTANT(SQL_INTERVAL_DAY_TO_HOUR),
    MAKE_CONSTANT(SQL_INTERVAL_DAY_TO_MINUTE),
    MAKE_CONSTANT(SQL_INTERVAL_DAY_TO_SECOND),
    MAKE_CONSTANT(SQL_INTERVAL_HOUR_TO_MINUTE),
    MAKE_CONSTANT(SQL_INTERVAL_HOUR_TO_SECOND),
    MAKE_CONSTANT(SQL_INTERVAL_MINUTE_TO_SECOND),
    MAKE_CONSTANT(SQL_NULLABLE),
    MAKE_CONSTANT(SQL_NO_NULLS),
    MAKE_CONSTANT(SQL_NULLABLE_UNKNOWN),
    MAKE_CONSTANT(SQL_SCOPE_CURROW),
    MAKE_CONSTANT(SQL_SCOPE_TRANSACTION),
    MAKE_CONSTANT(SQL_SCOPE_SESSION),
    MAKE_CONSTANT(SQL_PC_UNKNOWN),
    MAKE_CONSTANT(SQL_PC_NOT_PSEUDO),
    MAKE_CONSTANT(SQL_PC_PSEUDO),

    // SQLGetInfo
    MAKE_CONSTANT(SQL_ACCESSIBLE_PROCEDURES),
    MAKE_CONSTANT(SQL_ACCESSIBLE_TABLES),
    MAKE_CONSTANT(SQL_ACTIVE_ENVIRONMENTS),
    MAKE_CONSTANT(SQL_AGGREGATE_FUNCTIONS),
    MAKE_CONSTANT(SQL_ALTER_DOMAIN),
    MAKE_CONSTANT(SQL_ALTER_TABLE),
    MAKE_CONSTANT(SQL_ASYNC_MODE),
    MAKE_CONSTANT(SQL_BATCH_ROW_COUNT),
    MAKE_CONSTANT(SQL_BATCH_SUPPORT),
    MAKE_CONSTANT(SQL_BOOKMARK_PERSISTENCE),
    MAKE_CONSTANT(SQL_CATALOG_LOCATION),
    MAKE_CONSTANT(SQL_CATALOG_NAME),
    MAKE_CONSTANT(SQL_CATALOG_NAME_SEPARATOR),
    MAKE_CONSTANT(SQL_CATALOG_TERM),
    MAKE_CONSTANT(SQL_CATALOG_USAGE),
    MAKE_CONSTANT(SQL_COLLATION_SEQ),
    MAKE_CONSTANT(SQL_COLUMN_ALIAS),
    MAKE_CONSTANT(SQL_CONCAT_NULL_BEHAVIOR),
    MAKE_CONSTANT(SQL_CONVERT_BIGINT),
    MAKE_CONSTANT(SQL_CONVERT_BINARY),
    MAKE_CONSTANT(SQL_CONVERT_BIT),
    MAKE_CONSTANT(SQL_CONVERT_CHAR),
    MAKE_CONSTANT(SQL_CONVERT_GUID),
    MAKE_CONSTANT(SQL_CONVERT_DATE),
    MAKE_CONSTANT(SQL_CONVERT_DECIMAL),
    MAKE_CONSTANT(SQL_CONVERT_DOUBLE),
    MAKE_CONSTANT(SQL_CONVERT_FLOAT),
    MAKE_CONSTANT(SQL_CONVERT_INTEGER),
    MAKE_CONSTANT(SQL_CONVERT_INTERVAL_YEAR_MONTH),
    MAKE_CONSTANT(SQL_CONVERT_INTERVAL_DAY_TIME),
    MAKE_CONSTANT(SQL_CONVERT_LONGVARBINARY),
    MAKE_CONSTANT(SQL_CONVERT_LONGVARCHAR),
    MAKE_CONSTANT(SQL_CONVERT_NUMERIC),
    MAKE_CONSTANT(SQL_CONVERT_REAL),
    MAKE_CONSTANT(SQL_CONVERT_SMALLINT),
    MAKE_CONSTANT(SQL_CONVERT_TIME),
    MAKE_CONSTANT(SQL_CONVERT_TIMESTAMP),
    MAKE_CONSTANT(SQL_CONVERT_TINYINT),
    MAKE_CONSTANT(SQL_CONVERT_VARBINARY),
    MAKE_CONSTANT(SQL_CONVERT_VARCHAR),
    MAKE_CONSTANT(SQL_CONVERT_FUNCTIONS),

    MAKE_CONSTANT(SQL_CORRELATION_NAME),
    MAKE_CONSTANT(SQL_CREATE_ASSERTION),
    MAKE_CONSTANT(SQL_CREATE_CHARACTER_SET),
    MAKE_CONSTANT(SQL_CREATE_COLLATION),
    MAKE_CONSTANT(SQL_CREATE_DOMAIN),
    MAKE_CONSTANT(SQL_CREATE_SCHEMA),
    MAKE_CONSTANT(SQL_CREATE_TABLE),
    MAKE_CONSTANT(SQL_CREATE_TRANSLATION),
    MAKE_CONSTANT(SQL_CREATE_VIEW),
    MAKE_CONSTANT(SQL_CURSOR_COMMIT_BEHAVIOR),
    MAKE_CONSTANT(SQL_CURSOR_ROLLBACK_BEHAVIOR),
    MAKE_CONSTANT(SQL_CURSOR_SENSITIVITY),

    MAKE_CONSTANT(SQL_DATABASE_NAME),
    MAKE_CONSTANT(SQL_DATA_SOURCE_NAME),
    MAKE_CONSTANT(SQL_DATA_SOURCE_READ_ONLY),
    MAKE_CONSTANT(SQL_DATETIME_LITERALS),
    MAKE_CONSTANT(SQL_DBMS_NAME),
    MAKE_CONSTANT(SQL_DBMS_VER),
    MAKE_CONSTANT(SQL_DDL_INDEX),
    MAKE_CONSTANT(SQL_DEFAULT_TXN_ISOLATION),
    MAKE_CONSTANT(SQL_DESCRIBE_PARAMETER),
    MAKE_CONSTANT(SQL_DM_VER),
    MAKE_CONSTANT(SQL_DRIVER_HDBC),
    MAKE_CONSTANT(SQL_DRIVER_HDESC),
    MAKE_CONSTANT(SQL_DRIVER_HENV),
    MAKE_CONSTANT(SQL_DRIVER_HLIB),
    MAKE_CONSTANT(SQL_DRIVER_HSTMT),
    MAKE_CONSTANT(SQL_DRIVER_NAME),
    MAKE_CONSTANT(SQL_DRIVER_ODBC_VER),
    MAKE_CONSTANT(SQL_DRIVER_VER),
    MAKE_CONSTANT(SQL_DROP_ASSERTION),
    MAKE_CONSTANT(SQL_DROP_CHARACTER_SET),
    MAKE_CONSTANT(SQL_DROP_COLLATION),
    MAKE_CONSTANT(SQL_DROP_DOMAIN),
    MAKE_CONSTANT(SQL_DROP_SCHEMA),
    MAKE_CONSTANT(SQL_DROP_TABLE),
    MAKE_CONSTANT(SQL_DROP_TRANSLATION),
    MAKE_CONSTANT(SQL_DROP_VIEW),
    MAKE_CONSTANT(SQL_DYNAMIC_CURSOR_ATTRIBUTES1),
    MAKE_CONSTANT(SQL_DYNAMIC_CURSOR_ATTRIBUTES2),
    MAKE_CONSTANT(SQL_EXPRESSIONS_IN_ORDERBY),
    MAKE_CONSTANT(SQL_FILE_USAGE),
    MAKE_CONSTANT(SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES1),
    MAKE_CONSTANT(SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES2),
    MAKE_CONSTANT(SQL_GETDATA_EXTENSIONS),
    MAKE_CONSTANT(SQL_GROUP_BY),
    MAKE_CONSTANT(SQL_IDENTIFIER_CASE),
    MAKE_CONSTANT(SQL_IDENTIFIER_QUOTE_CHAR),
    MAKE_CONSTANT(SQL_INDEX_KEYWORDS),
    MAKE_CONSTANT(SQL_INFO_SCHEMA_VIEWS),
    MAKE_CONSTANT(SQL_INSERT_STATEMENT),
    MAKE_CONSTANT(SQL_INTEGRITY),
    MAKE_CONSTANT(SQL_KEYSET_CURSOR_ATTRIBUTES1),
    MAKE_CONSTANT(SQL_KEYSET_CURSOR_ATTRIBUTES2),
    MAKE_CONSTANT(SQL_KEYWORDS),
    MAKE_CONSTANT(SQL_LIKE_ESCAPE_CLAUSE),
    MAKE_CONSTANT(SQL_MAX_ASYNC_CONCURRENT_STATEMENTS),
    MAKE_CONSTANT(SQL_MAX_BINARY_LITERAL_LEN),
    MAKE_CONSTANT(SQL_MAX_CATALOG_NAME_LEN),
    MAKE_CONSTANT(SQL_MAX_CHAR_LITERAL_LEN),
    MAKE_CONSTANT(SQL_MAX_COLUMNS_IN_GROUP_BY),
    MAKE_CONSTANT(SQL_MAX_COLUMNS_IN_INDEX),
    MAKE_CONSTANT(SQL_MAX_COLUMNS_IN_ORDER_BY),
    MAKE_CONSTANT(SQL_MAX_COLUMNS_IN_SELECT),
    MAKE_CONSTANT(SQL_MAX_COLUMNS_IN_TABLE),
    MAKE_CONSTANT(SQL_MAX_COLUMN_NAME_LEN),
    MAKE_CONSTANT(SQL_MAX_CONCURRENT_ACTIVITIES),
    MAKE_CONSTANT(SQL_MAX_CURSOR_NAME_LEN),
    MAKE_CONSTANT(SQL_MAX_DRIVER_CONNECTIONS),
    MAKE_CONSTANT(SQL_MAX_IDENTIFIER_LEN),
    MAKE_CONSTANT(SQL_MAX_INDEX_SIZE),
    MAKE_CONSTANT(SQL_MAX_PROCEDURE_NAME_LEN),
    MAKE_CONSTANT(SQL_MAX_ROW_SIZE),
    MAKE_CONSTANT(SQL_MAX_ROW_SIZE_INCLUDES_LONG),
    MAKE_CONSTANT(SQL_MAX_SCHEMA_NAME_LEN),
    MAKE_CONSTANT(SQL_MAX_STATEMENT_LEN),
    MAKE_CONSTANT(SQL_MAX_TABLES_IN_SELECT),
    MAKE_CONSTANT(SQL_MAX_TABLE_NAME_LEN),
    MAKE_CONSTANT(SQL_MAX_USER_NAME_LEN),
    MAKE_CONSTANT(SQL_MULTIPLE_ACTIVE_TXN),
    MAKE_CONSTANT(SQL_MULT_RESULT_SETS),
    MAKE_CONSTANT(SQL_NEED_LONG_DATA_LEN),
    MAKE_CONSTANT(SQL_NON_NULLABLE_COLUMNS),
    MAKE_CONSTANT(SQL_NULL_COLLATION),
    MAKE_CONSTANT(SQL_NUMERIC_FUNCTIONS),
    MAKE_CONSTANT(SQL_ODBC_INTERFACE_CONFORMANCE),
    MAKE_CONSTANT(SQL_ODBC_VER),
    MAKE_CONSTANT(SQL_OJ_CAPABILITIES),
    MAKE_CONSTANT(SQL_OUTER_JOINS),
    MAKE_CONSTANT(SQL_ORDER_BY_COLUMNS_IN_SELECT),
    MAKE_CONSTANT(SQL_PARAM_ARRAY_ROW_COUNTS),
    MAKE_CONSTANT(SQL_PARAM_ARRAY_SELECTS),
    MAKE_CONSTANT(SQL_PARAM_TYPE_UNKNOWN),
    MAKE_CONSTANT(SQL_PARAM_INPUT),
    MAKE_CONSTANT(SQL_PARAM_INPUT_OUTPUT),
    MAKE_CONSTANT(SQL_PARAM_OUTPUT),
    MAKE_CONSTANT(SQL_RETURN_VALUE),
    MAKE_CONSTANT(SQL_RESULT_COL),
    MAKE_CONSTANT(SQL_PROCEDURES),
    MAKE_CONSTANT(SQL_PROCEDURE_TERM),
    MAKE_CONSTANT(SQL_QUOTED_IDENTIFIER_CASE),
    MAKE_CONSTANT(SQL_ROW_UPDATES),
    MAKE_CONSTANT(SQL_SCHEMA_TERM),
    MAKE_CONSTANT(SQL_SCHEMA_USAGE),
    MAKE_CONSTANT(SQL_SCROLL_OPTIONS),
    MAKE_CONSTANT(SQL_SEARCH_PATTERN_ESCAPE),
    MAKE_CONSTANT(SQL_SERVER_NAME),
    MAKE_CONSTANT(SQL_SPECIAL_CHARACTERS),
    MAKE_CONSTANT(SQL_SQL92_DATETIME_FUNCTIONS),
    MAKE_CONSTANT(SQL_SQL92_FOREIGN_KEY_DELETE_RULE),
    MAKE_CONSTANT(SQL_SQL92_FOREIGN_KEY_UPDATE_RULE),
    MAKE_CONSTANT(SQL_SQL92_GRANT),
    MAKE_CONSTANT(SQL_SQL92_NUMERIC_VALUE_FUNCTIONS),
    MAKE_CONSTANT(SQL_SQL92_PREDICATES),
    MAKE_CONSTANT(SQL_SQL92_RELATIONAL_JOIN_OPERATORS),
    MAKE_CONSTANT(SQL_SQL92_REVOKE),
    MAKE_CONSTANT(SQL_SQL92_ROW_VALUE_CONSTRUCTOR),
    MAKE_CONSTANT(SQL_SQL92_STRING_FUNCTIONS),
    MAKE_CONSTANT(SQL_SQL92_VALUE_EXPRESSIONS),
    MAKE_CONSTANT(SQL_SQL_CONFORMANCE),
    MAKE_CONSTANT(SQL_STANDARD_CLI_CONFORMANCE),
    MAKE_CONSTANT(SQL_STATIC_CURSOR_ATTRIBUTES1),
    MAKE_CONSTANT(SQL_STATIC_CURSOR_ATTRIBUTES2),
    MAKE_CONSTANT(SQL_STRING_FUNCTIONS),
    MAKE_CONSTANT(SQL_SUBQUERIES),
    MAKE_CONSTANT(SQL_SYSTEM_FUNCTIONS),
    MAKE_CONSTANT(SQL_TABLE_TERM),
    MAKE_CONSTANT(SQL_TIMEDATE_ADD_INTERVALS),
    MAKE_CONSTANT(SQL_TIMEDATE_DIFF_INTERVALS),
    MAKE_CONSTANT(SQL_TIMEDATE_FUNCTIONS),
    MAKE_CONSTANT(SQL_TXN_CAPABLE),
    MAKE_CONSTANT(SQL_TXN_ISOLATION_OPTION),
    MAKE_CONSTANT(SQL_UNION),
    MAKE_CONSTANT(SQL_USER_NAME),
    MAKE_CONSTANT(SQL_XOPEN_CLI_YEAR),

    // SQLSetConnectAttr 
    MAKE_CONSTANT( SQL_ATTR_ACCESS_MODE ),
    MAKE_CONSTANT( SQL_MODE_READ_ONLY ),
    MAKE_CONSTANT( SQL_MODE_READ_WRITE ),

    MAKE_CONSTANT( SQL_ATTR_AUTOCOMMIT ),
    MAKE_CONSTANT( SQL_AUTOCOMMIT_OFF ),
    MAKE_CONSTANT( SQL_AUTOCOMMIT_ON ),

    MAKE_CONSTANT( SQL_ATTR_CURRENT_CATALOG ),
    MAKE_CONSTANT( SQL_ATTR_MAX_ROWS ),
    MAKE_CONSTANT( SQL_ATTR_TIMEZONE ),
    MAKE_CONSTANT( SQL_ATTR_CHARACTER_SET ),
    MAKE_CONSTANT( SQL_ATTR_DATE_FORMAT ),
    MAKE_CONSTANT( SQL_ATTR_TIME_FORMAT ),
    MAKE_CONSTANT( SQL_ATTR_TIME_WITH_TIMEZONE_FORMAT ),
    MAKE_CONSTANT( SQL_ATTR_TIMESTAMP_FORMAT ),
    MAKE_CONSTANT( SQL_ATTR_TIMESTAMP_WITH_TIMEZONE_FORMAT ),
    MAKE_CONSTANT( SQL_ATTR_OLDPWD ),
    
    // SQLSetConnectAttr transaction isolation
    MAKE_CONSTANT( SQL_ATTR_TXN_ISOLATION ),
    MAKE_CONSTANT( SQL_TXN_READ_UNCOMMITTED ),
    MAKE_CONSTANT( SQL_TXN_READ_COMMITTED ),
    MAKE_CONSTANT( SQL_TXN_REPEATABLE_READ ),
    MAKE_CONSTANT( SQL_TXN_SERIALIZABLE ),
};

static char gModuleDoc[] =
    "A database module for accessing databases via ODBC.\n"
    "\n"
    "This module conforms to the DB API 2.0 specification while providing\n"
    "non-standard convenience features.  Only standard Python data types are used\n"
    "so additional DLLs are not required.\n"
    "\n"
    "Static Variables:\n\n"
    "version\n"
    "  The module version string.  Official builds will have a version in the format\n"
    "  `major.minor.revision`, such as 2.1.7.  Beta versions will have -beta appended,\n"
    "  such as 2.1.8-beta03.  (This would be a build before the official 2.1.8 release.)\n"
    "  Some special test builds will have a test name (the git branch name) prepended,\n"
    "  such as fixissue90-2.1.8-beta03.\n"
    "\n"
    "apilevel\n"
    "  The string constant '2.0' indicating this module supports DB API level 2.0.\n"
    "\n"
    "lowercase\n"
    "  A Boolean that controls whether column names in result rows are lowercased.\n"
    "  This can be changed any time and affects queries executed after the change.\n"
    "  The default is False.  This can be useful when database columns have\n"
    "  inconsistent capitalization.\n"
    "\n"
    "threadsafety\n"
    "  The integer 1, indicating that threads may share the module but not\n"
    "  connections.  Note that connections and cursors may be used by different\n"
    "  threads, just not at the same time.\n"
    "\n"
    "paramstyle\n"
    "  The string constant 'qmark' to indicate parameters are identified using\n"
    "  question marks.";


#if PY_MAJOR_VERSION >= 3
static struct PyModuleDef gModuleDef =
{
    PyModuleDef_HEAD_INIT, 
    "pygoldilocks",         /* m_name */
    gModuleDoc,             /* m_doc */
    -1,                     /* m_size*/
    gPyMethods,             /* m_methods */
    NULL,                   /* m_reload */
    NULL,                   /* m_traverse */
    NULL,                   /* m_clear */
    NULL,                   /* m_free */
};

#define MODRETURN(v) v
#else
#define MODRETURN(v)
#endif


PyMODINIT_FUNC
#if PY_MAJOR_VERSION >= 3
PyInit_pygoldilocks()
#else
initpygoldilocks( void )
#endif
{
    PyObject    * sModule = NULL;
    const char  * sVersion;
    uint          i = 0;
    PyObject    * sBinaryType;
    bool          sDoesImportTypes = FALSE;
    bool          sDoesInitExceptions = FALSE;
    
    ErrorInit();

    if( (PyType_Ready( &gConnectionType ) < 0) || (PyType_Ready( &gCursorType ) < 0) ||
        (PyType_Ready( &gRowType ) < 0) )
    {
        return MODRETURN( 0 );
    }
    
#if PY_MAJOR_VERSION >= 3
    ATTACH_PYOBJECT( sModule, PyModule_Create( &gModuleDef ) );
#else
    ATTACH_PYOBJECT( sModule,
                     Py_InitModule4( "pygoldilocks",
                                     gPyMethods,
                                     gModuleDoc,
                                     NULL,
                                     PYTHON_API_VERSION ) );
#endif

    gModule = sModule;

    sDoesImportTypes    = ImportTypes();
    sDoesInitExceptions = InitExceptions();
    
    if( (sModule == NULL) || (sDoesImportTypes == FAILURE) || (sDoesInitExceptions == FAILURE) )
    {
        return MODRETURN( 0 );
    }

    InitLocaleInfo();

    (void)PyModule_AddIntConstant( sModule, "threadsafety", 1 );
    sVersion = TOSTRING( PYGOLDILOCKS_VERSION );
    (void)PyModule_AddStringConstant( sModule, "version", (char*)sVersion );
    (void)PyModule_AddStringConstant( sModule, "apilevel", "2.0" );
    (void)PyModule_AddStringConstant( sModule, "paramstyle", "qmark");
    
    (void)PyModule_AddObject( sModule, "lowercase", Py_False );
    Py_INCREF( Py_False );

    (void)PyModule_AddObject( sModule, "Connection", (PyObject*)&gConnectionType);
    Py_INCREF( (PyObject*)&gConnectionType );

    (void)PyModule_AddObject( sModule, "Cursor", (PyObject*)&gCursorType);
    Py_INCREF( (PyObject*)&gCursorType );
    
    (void)PyModule_AddObject( sModule, "Row", (PyObject*)&gRowType);
    Py_INCREF((PyObject*)&gRowType);

    /* Add the SQL_XXX defines from ODBC */
    for( i = 0; i < COUNTOF( gConstants ); i++ )
    {
        (void)PyModule_AddIntConstant( sModule,
                                       (char*)gConstants[i].mName,
                                       gConstants[i].mValue );
    }

    (void)PyModule_AddObject( sModule, "Date", (PyObject*)PyDateTimeAPI->DateType );
    Py_INCREF( (PyObject*)PyDateTimeAPI->DateType );
    
    (void)PyModule_AddObject( sModule, "Time", (PyObject*)PyDateTimeAPI->TimeType );
    Py_INCREF( (PyObject*)PyDateTimeAPI->TimeType );

    (void)PyModule_AddObject( sModule, "Timestamp", (PyObject*)PyDateTimeAPI->DateTimeType);
    Py_INCREF( (PyObject*)PyDateTimeAPI->DateTimeType );

    (void)PyModule_AddObject( sModule, "DATETIME", (PyObject*)PyDateTimeAPI->DateTimeType);
    Py_INCREF( (PyObject*)PyDateTimeAPI->DateTimeType );

    (void)PyModule_AddObject( sModule, "STRING", (PyObject*)&PyString_Type);
    Py_INCREF( (PyObject*)&PyString_Type );

    (void)PyModule_AddObject( sModule, "NUMBER", (PyObject*)&PyFloat_Type);
    Py_INCREF( (PyObject*)&PyFloat_Type );

    (void)PyModule_AddObject( sModule, "ROWID", (PyObject*)&PyString_Type);
    Py_INCREF( (PyObject*)&PyString_Type );

#if PY_VERSION_HEX >= 0x02060000
    sBinaryType = (PyObject*)&PyByteArray_Type;
#else
    sBinaryType = (PyObject*)&PyBuffer_Type;
#endif
    (void)PyModule_AddObject( sModule, "BINARY", sBinaryType );
    Py_INCREF( sBinaryType );

    (void)PyModule_AddObject( sModule, "Binary", sBinaryType );
    Py_INCREF( sBinaryType );

    DASSERT( gNullBinary != NULL );        // must be initialized first
    (void)PyModule_AddObject( sModule, "BinaryNull", gNullBinary );
    
    (void)PyModule_AddIntConstant( sModule, "UNICODE_SIZE", sizeof(Py_UNICODE) );
    (void)PyModule_AddIntConstant( sModule, "SQLWCHAR_SIZE", sizeof(SQLWCHAR) );
    
    if( !PyErr_Occurred() )
    {
        sModule = NULL;
    }
    else
    {
        ErrorCleanup();
    }
    
    return MODRETURN( gModule );
}

/* @} */
