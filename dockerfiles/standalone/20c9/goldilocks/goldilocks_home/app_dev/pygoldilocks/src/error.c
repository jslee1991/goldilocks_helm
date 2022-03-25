/*******************************************************************************
 * error.c
 *
 * Copyright (c) 2011, SUNJESOFT Inc.
 *
 *
 * IDENTIFICATION & REVISION
 *        $Id: error.c 26607 2018-12-20 09:45:10Z lkh $
 *
 * NOTES
 *
 *
 ******************************************************************************/

/**
 * @file error.c
 * @brief Python exception handler for Goldilocks Python Database API
 */

#include <pydbc.h>
#include <error.h>
#include <buffer.h>

struct SqlStateMap
{
    char      * mPrefix;
    size_t      mPrefixLen;
    PyObject ** mPexcClass; /* During startup pointer values are not initialized.*/
};

PyObject * Error;
PyObject * Warning;
PyObject * InterfaceError;
PyObject * DatabaseError;
PyObject * InternalError;
PyObject * OperationalError;
PyObject * ProgrammingError;
PyObject * IntegrityError;
PyObject * DataError;
PyObject * NotSupportedError;

static const char * DEFAULT_ERROR = "The driver did not supply an error!";

static const struct SqlStateMap gSqlStateMap[] =
{
    { "01002", 5, &OperationalError },
    { "08001", 5, &OperationalError },
    { "08003", 5, &OperationalError },
    { "08004", 5, &OperationalError },
    { "08007", 5, &OperationalError },
    { "08S01", 5, &OperationalError },
    { "0A000", 5, &NotSupportedError },
    { "28000", 5, &InterfaceError },
    { "40002", 5, &IntegrityError },
    { "22",    2, &DataError },
    { "23",    2, &IntegrityError },
    { "24",    2, &ProgrammingError },
    { "25",    2, &ProgrammingError },
    { "42",    2, &ProgrammingError },
    { "HY001", 5, &OperationalError },
    { "HY014", 5, &OperationalError },
    { "HYT00", 5, &OperationalError },
    { "HYT01", 5, &OperationalError },
    { "IM001", 5, &InterfaceError },
    { "IM002", 5, &InterfaceError },
    { "IM003", 5, &InterfaceError },
};

/**
 * Because window raise error C2099, mException and mExcParanet set to NULL.
 */ 
ExceptionInfo gExcInfos[] = {
    {
        "Error",
        "PyGoldilocks.Error",
        NULL,
        NULL,
        "Exception that is the base class of all other error exceptions. You can use\n"
        "this to catch all errors with one single 'except' statement."
    },
    {
        "Warning",
        "PyGoldilocks.Warning",
        NULL,
        NULL,
        "Exception raised for important warnings like data truncations while inserting,\n"
        "etc."
    },
    {
        "InterfaceError",
        "PyGoldilocks.InterfaceError",
        NULL,
        NULL,
        "Exception raised for errors that are related to the database interface rather\n"
        "than the database itself."
    },
    {
        "DatabaseError",
        "PyGoldilocks.DatabaseError",
        NULL,
        NULL,
        "Exception raised for errors that are related to the database."
    },
    {
        "DataError",
        "PyGoldilocks.DataError",
        NULL,
        NULL,
        "Exception raised for errors that are due to problems with the processed data\n"
        "like division by zero, numeric value out of range, etc."
    },
    {
        "OperationalError",
        "PyGoldilocks.OperationalError",
        NULL,
        NULL,
        "Exception raised for errors that are related to the database's operation and\n"
        "not necessarily under the control of the programmer, e.g. an unexpected\n"
        "disconnect occurs, the data source name is not found, a transaction could not\n"
        "be processed, a memory allocation error occurred during processing, etc."
    },
    {
        "IntegrityError",
        "PyGoldilocks.IntegrityError",
        NULL,
        NULL,
        "Exception raised when the relational integrity of the database is affected,\n"
        "e.g. a foreign key check fails."
    },
    {
        "InternalError",
        "PyGoldilocks.InternalError",
        NULL,
        NULL,
        "Exception raised when the database encounters an internal error, e.g. the\n"
        "cursor is not valid anymore, the transaction is out of sync, etc."
    },
    {
        "ProgrammingError",
        "PyGoldilocks.ProgrammingError",
        NULL,
        NULL,
        "Exception raised for programming errors, e.g. table not found or already\n"
        "exists, syntax error in the SQL statement, wrong number of parameters\nspecified, etc."
    },
    {
        "NotSupportedError",
        "PyGoldilocks.NotSupportedError",
        NULL,
        NULL,
        "Exception raised in case a method or database API was used which is not\n"
        "supported by the database, e.g. requesting a .rollback() on a connection that\n"
        "does not support transaction or has transactions turned off."
    }
};



void ErrorInit()
{
    int i = 0;

    /**
     * Called during startup to initialize any variables that will be freed by ErrorCleanup.
     * Because window raise error C2099, mException and mExcParanet set here.
     */
    Error = NULL;
    gExcInfos[i].mException = &Error;
    gExcInfos[i].mExcParent = &PyExc_Exception;
    i++;
    
    Warning = NULL;
    gExcInfos[i].mException = &Warning;
    gExcInfos[i].mExcParent = &PyExc_Exception;
    i++;
    
    InterfaceError = NULL;
    gExcInfos[i].mException = &InterfaceError;
    gExcInfos[i].mExcParent = &Error;
    i++;
    
    DatabaseError = NULL;
    gExcInfos[i].mException = &DatabaseError;
    gExcInfos[i].mExcParent = &Error;
    i++;
    
    DataError = NULL;
    gExcInfos[i].mException = &DataError;
    gExcInfos[i].mExcParent = &DatabaseError;
    i++;
    
    OperationalError = NULL;
    gExcInfos[i].mException = &OperationalError;
    gExcInfos[i].mExcParent = &DatabaseError;
    i++;
    
    IntegrityError = NULL;
    gExcInfos[i].mException = &IntegrityError;
    gExcInfos[i].mExcParent = &DatabaseError;
    i++;
    
    InternalError = NULL;
    gExcInfos[i].mException = &InternalError;
    gExcInfos[i].mExcParent = &DatabaseError;
    i++;
    
    ProgrammingError = NULL;
    gExcInfos[i].mException = &ProgrammingError;
    gExcInfos[i].mExcParent = &DatabaseError;
    i++;
    
    NotSupportedError = NULL;
    gExcInfos[i].mException = &NotSupportedError;
    gExcInfos[i].mExcParent = &DatabaseError;
    i++;

    ASSERT( i == COUNTOF( gExcInfos ) );
}

void ErrorCleanup()
{
    Py_XDECREF( Error );
    Py_XDECREF( Warning );
    Py_XDECREF( InterfaceError );
    Py_XDECREF( DatabaseError );
    Py_XDECREF( InternalError );
    Py_XDECREF( OperationalError );
    Py_XDECREF( ProgrammingError );
    Py_XDECREF( IntegrityError );
    Py_XDECREF( DataError );
    Py_XDECREF( NotSupportedError );
}

static PyObject * ExceptionFromSqlState( const char * aSqlState )
{
    size_t i = 0;

    /**
     * Returns the appropriate Python exception class given a SQLSTATE value.
     */
    if( (aSqlState != NULL) && (*aSqlState != '\0') )
    {
        for( i = 0; i < COUNTOF( gSqlStateMap ); i++ )
        {
            if( memcmp( (void*)aSqlState, gSqlStateMap[i].mPrefix, gSqlStateMap[i].mPrefixLen ) == 0 )
            {
                return *gSqlStateMap[i].mPexcClass;
            }
        }
    }

    return Error;
}

PyObject * RaiseErrorV( const char * aSqlState,
                        PyObject   * aExcClass,
                        const char * aFormat,
                        ... )
{
    PyObject * sAttrs = NULL;
    PyObject * sError = NULL;
    PyObject * sMsg;
    va_list    sMarker;

    if( (aSqlState == NULL ) || (*aSqlState == '\0') )
    {
        aSqlState = "HY000";
    }

    if( aExcClass == NULL )
    {
        aExcClass = ExceptionFromSqlState( aSqlState );
    }

    /**
     * Note: Don't use any native strprintf routines.
     * With Py_ssize_t, we need "%zd", but VC .NET doesn't support it.
     * PyString_FromFormatV already takes this into account.
     */
    va_start( sMarker, aFormat );
    sMsg = PyString_FromFormatV( aFormat, sMarker );
    va_end( sMarker );

    if( sMsg == NULL )
    {
        PyErr_NoMemory();
        return NULL;
    }

    /**
     * Create an exception with a 'sqlstate' attribute (set to None if we don't have one) whose
     * 'args' attribute is a tuple containing the message and sqlstate value.
     * The 'sqlstate' attribute ensures it is easy to access in Python
     * (and more understandable to the reader than ex.args[1]),
     * but putting it in the args ensures it shows up in logs because of the default repr/str.
     */
    sAttrs = Py_BuildValue( "(Os)", sMsg, aSqlState );

    if( sAttrs != NULL )
    {
        sError = PyEval_CallObject( aExcClass, sAttrs );
        if( sError != NULL )
        {
            RaiseErrorFromException( sError );
        }
    }

    Py_DECREF( sMsg );
    Py_XDECREF( sAttrs );
    Py_XDECREF( sError );

    return NULL;
}


static PyObject * GetError( const char * aSqlState,
                            PyObject      * aExcClass,
                            PyObject      * aMsg )
{
    PyObject * sSqlState = NULL;
    PyObject * sAttrs = NULL;
    PyObject * sError = NULL;

    if( aSqlState == NULL || *aSqlState == '\0' )
    {
        aSqlState = "HY000";
    }

    if( aExcClass == NULL )
    {
        aExcClass = ExceptionFromSqlState( aSqlState );
    }

    sAttrs = PyTuple_New( 2 );
    if( sAttrs == NULL )
    {
        Py_DECREF( aMsg );
        return NULL;
    }

    /* sAttrs now owns the aMsg reference; steals a reference, does not increment */
    (void) PyTuple_SetItem( sAttrs, 1, aMsg );

    sSqlState = PyString_FromString( aSqlState );
    if( sSqlState == NULL )
    {
        Py_DECREF( sAttrs );
        return NULL;
    }

    /* sAttrs now owns the sSqlState reference */
    (void) PyTuple_SetItem( sAttrs, 0, sSqlState );
    /* sError will incref sAttrs */
    sError = PyEval_CallObject( aExcClass, sAttrs );
    Py_XDECREF( sAttrs );
    
    return sError;
}

PyObject * RaiseErrorFromHandle( Connection * aConnection,
                                 const char * aSzFunction,
                                 SQLHDBC      aHdbc,
                                 SQLHSTMT     aHstmt )
{
    // The exception is "set" in the interpreter.  This function returns 0 so this can be used in a return statement.

    PyObject * sError = GetErrorFromHandle( aConnection,
                                            aSzFunction,
                                            aHdbc,
                                            aHstmt );

    if( sError != NULL )
    {
        RaiseErrorFromException(sError);
        Py_DECREF(sError);
    }

    return NULL;
}

PyObject * GetErrorFromHandle( Connection * aConnection,
                               const char * aFunction,
                               SQLHDBC      aHdbc,
                               SQLHSTMT     aHstmt )
{
    SQLSMALLINT sHandleType;
    SQLHANDLE   sHandle;

    char        sSqlState[6] = "";
    SQLINTEGER  sNativeError;
    SQLSMALLINT sMsgLen;

    char        sSqlStateT[6];
    char        sErrorMsg[1024];

    PyObject  * sMsg = NULL;
    PyObject  * sMsgPart = NULL;
    PyObject  * sTmp;
    
    SQLSMALLINT sRecord = 1;
    SQLRETURN   sRet;
    
    if( aHstmt != SQL_NULL_HANDLE )
    {
        sHandleType = SQL_HANDLE_STMT;
        sHandle = aHstmt;
    }
    else if( aHdbc != SQL_NULL_HANDLE )
    {
        sHandleType = SQL_HANDLE_DBC;
        sHandle = aHdbc;
    }
    else
    {
        sHandleType = SQL_HANDLE_ENV;
        sHandle = gHENV;
    }

    // unixODBC + PostgreSQL driver 07.01.0003 (Fedora 8 binaries from RPMs) crash if you call SQLGetDiagRec more than once.
    // I hate to do this, but I'm going to only call it once for non-Windows platforms for now...

    while( TRUE )
    {
        sErrorMsg[0]  = 0;
        sSqlStateT[0] = 0;
        sNativeError  = 0;
        sMsgLen       = 0;

        Py_BEGIN_ALLOW_THREADS;
        sRet = GDLGetDiagRec( sHandleType,
                              sHandle,
                              sRecord,
                              (SQLCHAR*)sSqlStateT,
                              &sNativeError,
                              (SQLCHAR*)sErrorMsg,
                              (short)(COUNTOF(sErrorMsg)-1 ),
                              &sMsgLen );
        Py_END_ALLOW_THREADS;

        if( !SQL_SUCCEEDED( sRet ) )
        {
            break;
        }

        sSqlStateT[5] = '\0';

        if( sMsgLen != 0 )
        {
            if( sRecord == 1 )
            {
                // This is the first error message,
                // so save the SQLSTATE for determining the exception class and
                // append the calling function name.

                memcpy( sSqlState,
                        sSqlStateT,
                        sizeof( sSqlState[0] ) * COUNTOF( sSqlState ) );
                
                sMsg = PyUnicode_FromFormat( "[%s] %s (%ld) (%s)\n",
                                             sSqlStateT,
                                             sErrorMsg,
                                             (long)sNativeError,
                                             aFunction );
                if( sMsg == NULL )
                {
                    return NULL;
                }
            }
            else
            {
                // This is not the first error message, so append to the existing one.
                sMsgPart = PyUnicode_FromFormat( "; [%s] %s (%ld)\n",
                                                 sSqlStateT,
                                                 sErrorMsg,
                                                 (long)sNativeError );

                if( sMsgPart == NULL )
                {
                    Py_XDECREF( sMsg );
                    return NULL;
                }

                sTmp = PyUnicode_Concat( sMsg, sMsgPart);

                Py_XDECREF( sMsgPart );
                Py_XDECREF( sMsg );
                sMsg = sTmp;
            }
        }

        sRecord++;
    }

    if( sMsg == NULL )
    {
        // This only happens using unixODBC.  (Haven't tried iODBC yet.)
        // Either the driver or the driver manager is
        // buggy and has signaled a fault without recording error information.
        sSqlState[0] = '\0';
        sMsg = PyString_FromString(DEFAULT_ERROR);
        if( sMsg == NULL )
        {
            PyErr_NoMemory();
            return NULL;
        }
    }

    return GetError( sSqlState, 0, sMsg );
}

PyObject * RaiseErrorFromException( PyObject * aError )
{
    /**
     * PyExceptionInstance_Class doesn't exist in 2.4
     */ 
#if PY_MAJOR_VERSION >= 3
    PyErr_SetObject( (PyObject*)Py_TYPE( aError ), aError );
#else
    PyObject * sClass;

    if( PyInstance_Check( aError ) )
    {
        sClass = (PyObject*)((PyInstanceObject*)aError)->in_class;
    }
    else
    {
        sClass = (PyObject*)Py_TYPE( aError );
    }
    
    PyErr_SetObject( sClass, aError );
#endif
    
    return NULL;
}


STATUS InitExceptions()
{
    ExceptionInfo * sInfo;
    PyObject      * sClassDict;
    PyObject      * sDoc;
    uint            i;

    for( i = 0; i < COUNTOF( gExcInfos ); i++ )
    {
        sInfo = &gExcInfos[i];

        sClassDict = PyDict_New();
        TRY( IS_VALID_PYOBJECT( sClassDict ) == TRUE );

        sDoc = PyString_FromString( sInfo->mDoc);
        TRY_THROW( IS_VALID_PYOBJECT( sDoc ) == TRUE, RAMP_ERR_DEC_CLASSDICT );

        (void)PyDict_SetItemString( sClassDict, "__doc__", sDoc );
        Py_DECREF( sDoc );

        *sInfo->mException = PyErr_NewException( (char*)sInfo->mFullName,
                                                 *sInfo->mExcParent,
                                                 sClassDict );
        TRY_THROW( IS_VALID_PYOBJECT( *sInfo->mException ) == TRUE,
                   RAMP_ERR_DEC_CLASSDICT );

        // Keep a reference for our internal (C++) use.
        Py_INCREF( *sInfo->mException );

        (void)PyModule_AddObject( gModule, (char*)sInfo->mName, *sInfo->mException );
    }

    return SUCCESS;

    CATCH( RAMP_ERR_DEC_CLASSDICT )
    {
        Py_DECREF( sClassDict );
    }
    
    FINISH;

    return FAILURE;
}
