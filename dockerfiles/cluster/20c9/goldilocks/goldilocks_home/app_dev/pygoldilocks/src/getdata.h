/*******************************************************************************
 * getdata.h
 *
 * Copyright (c) 2011, SUNJESOFT Inc.
 *
 *
 * IDENTIFICATION & REVISION
 *        $Id: getdata.h 25480 2018-07-31 07:57:03Z lkh $
 *
 * NOTES
 *
 *
 ******************************************************************************/

#ifndef _GETDATA_H_
#define _GETDATA_H_ 1

/**
 * @file getdata.h
 * @brief Python Get Data functions for Goldilocks Python Database API
 */

void InitGetData();

PyObject * PythonTypeFromSqlType( Cursor      * aCursor,
                                  SQLSMALLINT   aType );

STATUS GetData( Cursor      * aCursor,
                Py_ssize_t    aIndex,
                PyObject   ** aData );

#endif /* _MGETDATA_H_ */

