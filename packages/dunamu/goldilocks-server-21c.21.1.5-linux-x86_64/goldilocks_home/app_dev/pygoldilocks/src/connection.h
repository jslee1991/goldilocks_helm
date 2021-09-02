/*******************************************************************************
 * connection.c
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

#ifndef _CONNECTION_H_
#define _CONNECTION_H_ 1

/**
 * @file connection.c
 * @brief Python Connection for Goldilocks Python Database API
 */
Connection * GetConnection( Cursor * aCursor );

/**
 * Used by the module's connect function to create new connection objects.
 * If unable to connect to the database, an exception is set and zero is returned.
 */
STATUS Connect( PyObject  * aConnectString,
                bool        aAutoCommit,
                long        aTimeout,
                bool        aReadOnly,
                PyObject  * aAttrsBefore,
                PyObject ** aOutCnxn );

/**
 * Used by the Cursor to implement commit and rollback.
 */
PyObject * Connection_endtrans( Connection * aCnxn, SQLSMALLINT aType );

SQLLEN GetMaxLength( Connection  * aCnxn, SQLSMALLINT   aCType );

#endif /* _MCONNECTION_H_ */
