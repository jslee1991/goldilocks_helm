/*******************************************************************************
 * cursor.h
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

#ifndef _CURSOR_H_
#define _CURSOR_H_ 1

/**
 * @file cursor.h
 * @brief Python Cursor for Goldilocks Python Database API
 */

void InitCursor(void);

Cursor * MakeCursor( Connection * aConnection );
STATUS   ProcessLongParamDatas( SQLRETURN * aRet,
                                Cursor    * aCursor );
PyObject * Cursor_execute( PyObject* aSelf, PyObject * aArgs );

#endif /* _CURSOR_H_ */
