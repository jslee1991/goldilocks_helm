/*******************************************************************************
 * type.h
 *
 * Copyright (c) 2011, SUNJESOFT Inc.
 *
 *
 * IDENTIFICATION & REVISION
 *        $Id: type.h 26636 2018-12-24 07:39:08Z lkh $
 *
 * NOTES
 *
 *
 ******************************************************************************/

#ifndef _TYPE_H_
#define _TYPE_H_ 1

/**
 * @file type.h
 * @brief Python type for Goldilocks Python Database API
 */

void InitType();

#if PY_MAJOR_VERSION < 3
bool IsStringType( PyObject * aObj );
bool IsUnicodeType( PyObject * aObj );
#endif

bool IsTextType(PyObject * aObject );

bool IsWideType( SQLSMALLINT aSqlType );

bool IsLongVariableType( SQLSMALLINT aSqlType );

bool IsIntOrLong( PyObject * aObj );

bool DetectCType( PyObject  * aType,
                  ParamInfo * aParamInfo );

int PyToCType( Cursor     * aCursor,
               char      ** aOutBuf,
               PyObject   * aData,
               ParamInfo  * aParamInfo );

PyObject * CToPyTypeBySQLType( Cursor      * aCursor,
                               SQLSMALLINT   aSqlType,
                               void        * aValue,
                               SQLULEN       aColumnSize,
                               SQLSMALLINT   aDecimalDigits,
                               SQLLEN        aLen );

PyObject * CToPyTypeByCType( Cursor      * aCursor,
                             SQLSMALLINT   aCType,
                             void        * aValue,
                             SQLSMALLINT   aSQLType,
                             SQLULEN       aColumnSize,
                             SQLSMALLINT   aDecimalDigits,
                             SQLLEN        aLen );

SQLSMALLINT SQLTypeToCType( SQLSMALLINT aSqlType );

bool IsSamePyTypeWithCType( PyObject  * aPyData,
                            ParamInfo * aParamInfo );
#endif /* _TYPE_H_ */
