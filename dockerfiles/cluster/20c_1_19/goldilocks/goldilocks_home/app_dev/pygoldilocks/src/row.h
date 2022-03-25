/*******************************************************************************
 * row.h
 *
 * Copyright (c) 2011, SUNJESOFT Inc.
 *
 *
 * IDENTIFICATION & REVISION
 *        $Id: row.h 25480 2018-07-31 07:57:03Z lkh $
 *
 * NOTES
 *
 *
 ******************************************************************************/

#ifndef _ROW_H_
#define _ROW_H_ 1

/**
 * @file row.h
 * @brief Python Row item for Goldilocks Python Database API
 */

/**
 * Used to make a new row from an array of column values.
 */
Row * MakeRowInternal( PyObject    * aDescription,
                       PyObject    * aMapNameToIndex,
                       Py_ssize_t    aValueCount,
                       PyObject   ** aColumnValues );


void FreeRowValues( PyObject ** aArr );

PyObject * Row_item( PyObject   * aObj,
                     Py_ssize_t   aIndex );

#endif /* _ROW_H_ */
