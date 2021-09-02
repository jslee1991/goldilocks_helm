/*******************************************************************************
 * error.h
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

#ifndef _ERRORS_H_
#define _ERRORS_H_ 1

#include <pydbc.h>

/**
 * @file error.h
 * @brief Python exception handler for Goldilocks Python Database API
 */

void ErrorInit();

void ErrorCleanup();

PyObject * RaiseErrorV( const char * aSqlState,
                        PyObject   * aExcClass,
                        const char * aFormat,
                        ... );

/**
 * Sets an exception based on the ODBC SQLSTATE and error message and returns zero.
 * If either handle is not available, pass SQL_NULL_HANDLE.
 * szFunction, The name of the function that failed.
 * Python generates a useful stack trace, but we often don't know where in the C++ code we failed.
 */        
PyObject * RaiseErrorFromHandle( Connection * aConnection,
                                 const char * aSzFunction,
                                 SQLHDBC      aHdbc,
                                 SQLHSTMT     aHstmt );

/**
 * Constructs an exception and returns it.
 * This function is like RaiseErrorFromHandle, but gives you the ability to examine the error first (in particular, used to examine the SQLSTATE using HasSqlState).
 * If you want to use the error, call PyErr_SetObject(ex->ob_type, ex).
 * Otherwise, dispose of the error using Py_DECREF(ex).
 * szFunction, The name of the function that failed.
 * Python generates a useful stack trace, but we often don't know where in the C++ code we failed.
 */ 
PyObject * GetErrorFromHandle( Connection * aConnection,
                               const char * aSzFunction,
                               SQLHDBC      aHdbc,
                               SQLHSTMT     aHstmt );

PyObject * RaiseErrorFromException( PyObject * aError );

STATUS InitExceptions();

#endif /* _ERRORS_H_ */
